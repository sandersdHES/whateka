-- Whateka — Migration 0003 : systeme d'abonnement
-- ===================================================================
-- Trois tiers :
--   1. free     : 5 quiz / 30 jours glissants depuis profil_created_at
--   2. regional : 1 canton (Vaud OU Valais), changement 1x / 30 jours
--   3. evasion  : tous les cantons, avant-premiere des nouvelles activites
--
-- Mecanique de paiement (Phase 2/3) :
--   - source = 'apple'  → Apple IAP via RevenueCat
--   - source = 'stripe' → Stripe Checkout (web)
--   - source = 'promo'  → code promo (donne 6 mois d'Evasion par defaut)
--
-- Cette migration cree uniquement le schema. Les flows de paiement
-- seront ajoutes dans des migrations ulterieures.
-- ===================================================================

-- ───────────────────────────────────────────────────────────────────
-- 1. Table subscriptions : 1 ligne par utilisateur (PK = user_id).
-- Si pas de ligne pour un user → considere comme 'free' avec quota 5.
-- ───────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS subscriptions (
  user_id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,

  -- Tier actuel.
  tier TEXT NOT NULL DEFAULT 'free'
    CHECK (tier IN ('free', 'regional', 'evasion')),

  -- Pour regional : canton choisi.
  selected_region TEXT
    CHECK (selected_region IN ('vaud', 'valais') OR selected_region IS NULL),

  -- Fenetre de 30 jours glissante pour le quota free.
  -- A la creation : free_period_started_at = now() (= profil cree).
  -- Quand 30 jours sont ecoules ET un nouveau quiz est tente :
  --   free_period_started_at = now() ; free_quizzes_used = 0.
  free_period_started_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  free_quizzes_used INTEGER NOT NULL DEFAULT 0,

  -- Pour regional : timestamp du dernier changement de canton.
  -- Permet de calculer "prochain changement possible le ..."
  last_region_change TIMESTAMPTZ,

  -- Lifecycle de l'abonnement payant.
  -- trial_ends_at : null si pas d'essai (ex : code promo) ou essai termine.
  -- expires_at    : date d'expiration de l'abonnement (renouvelle ou non).
  trial_ends_at TIMESTAMPTZ,
  expires_at TIMESTAMPTZ,

  -- Source de l'abonnement.
  source TEXT CHECK (source IN ('apple', 'stripe', 'promo') OR source IS NULL),
  apple_transaction_id TEXT,
  stripe_subscription_id TEXT,
  promo_code TEXT,

  -- Status : 'active' tant que valide, 'canceled' si annule (mais
  -- continue jusqu'a expires_at), 'expired' apres expires_at.
  status TEXT NOT NULL DEFAULT 'active'
    CHECK (status IN ('active', 'canceled', 'expired')),
  canceled_at TIMESTAMPTZ,

  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_subscriptions_tier ON subscriptions(tier);
CREATE INDEX IF NOT EXISTS idx_subscriptions_status ON subscriptions(status);
CREATE INDEX IF NOT EXISTS idx_subscriptions_expires_at ON subscriptions(expires_at);

-- Trigger : maj updated_at automatique.
CREATE OR REPLACE FUNCTION update_subscriptions_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS subscriptions_updated_at ON subscriptions;
CREATE TRIGGER subscriptions_updated_at
  BEFORE UPDATE ON subscriptions
  FOR EACH ROW
  EXECUTE FUNCTION update_subscriptions_updated_at();

-- ───────────────────────────────────────────────────────────────────
-- 2. Table promo_codes : codes promotionnels (1 code = N redemptions).
-- Exemple : "WHATEKA2026" = 100 redemptions, 6 mois d'Evasion.
-- ───────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS promo_codes (
  code TEXT PRIMARY KEY, -- ex : "FRIENDS2026"
  tier TEXT NOT NULL DEFAULT 'evasion'
    CHECK (tier IN ('regional', 'evasion')),
  duration_months INTEGER NOT NULL DEFAULT 6 CHECK (duration_months > 0),

  -- Limite d'utilisations : null = illimite.
  max_redemptions INTEGER CHECK (max_redemptions IS NULL OR max_redemptions > 0),
  redemption_count INTEGER NOT NULL DEFAULT 0,

  -- Date d'expiration du code lui-meme : null = jamais.
  expires_at TIMESTAMPTZ,

  -- Permet de desactiver un code sans le supprimer.
  active BOOLEAN NOT NULL DEFAULT true,

  -- Note admin (ex : "Code lance Aux Salons Vaud 2026").
  description TEXT,

  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_promo_codes_active ON promo_codes(active) WHERE active = true;

-- ───────────────────────────────────────────────────────────────────
-- 3. Table promo_redemptions : trace les utilisations d'un code par user.
-- Empeche un user de redeem le meme code 2x (PK composite).
-- ───────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS promo_redemptions (
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  code TEXT NOT NULL REFERENCES promo_codes(code) ON DELETE CASCADE,
  redeemed_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  PRIMARY KEY (user_id, code)
);

CREATE INDEX IF NOT EXISTS idx_promo_redemptions_user ON promo_redemptions(user_id);

-- ───────────────────────────────────────────────────────────────────
-- 4. Fonction RPC : redeem_promo_code(p_code TEXT)
-- Logique atomique :
--   - Verifie que le code existe, est actif, non expire, non sature
--   - Verifie que l'user ne l'a pas deja utilise
--   - Cree/met a jour l'abonnement de l'user (tier + expires_at)
--   - Insert dans promo_redemptions
--   - Increment redemption_count
-- Retourne un JSON avec succes/erreur + details.
-- ───────────────────────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION redeem_promo_code(p_code TEXT)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_user_id UUID;
  v_code RECORD;
  v_already_redeemed BOOLEAN;
  v_new_expires_at TIMESTAMPTZ;
BEGIN
  -- 1. Identite de l'appelant (auth.uid() est l'user JWT).
  v_user_id := auth.uid();
  IF v_user_id IS NULL THEN
    RETURN jsonb_build_object('success', false, 'error', 'not_authenticated');
  END IF;

  -- 2. Charge le code (uppercase pour insensibilite a la casse).
  SELECT * INTO v_code FROM promo_codes
    WHERE code = upper(trim(p_code))
    LIMIT 1;
  IF NOT FOUND THEN
    RETURN jsonb_build_object('success', false, 'error', 'code_not_found');
  END IF;
  IF NOT v_code.active THEN
    RETURN jsonb_build_object('success', false, 'error', 'code_inactive');
  END IF;
  IF v_code.expires_at IS NOT NULL AND v_code.expires_at < now() THEN
    RETURN jsonb_build_object('success', false, 'error', 'code_expired');
  END IF;
  IF v_code.max_redemptions IS NOT NULL
     AND v_code.redemption_count >= v_code.max_redemptions THEN
    RETURN jsonb_build_object('success', false, 'error', 'code_exhausted');
  END IF;

  -- 3. Already redeemed by this user ?
  SELECT EXISTS (
    SELECT 1 FROM promo_redemptions
    WHERE user_id = v_user_id AND code = v_code.code
  ) INTO v_already_redeemed;
  IF v_already_redeemed THEN
    RETURN jsonb_build_object('success', false, 'error', 'already_redeemed');
  END IF;

  -- 4. Calcule la nouvelle expires_at : si l'user est deja sur un tier
  --    payant non expire, on PROLONGE son abo. Sinon on demarre maintenant.
  SELECT GREATEST(now(), COALESCE(expires_at, now()))
         + (v_code.duration_months || ' months')::INTERVAL
    INTO v_new_expires_at
    FROM subscriptions
    WHERE user_id = v_user_id;
  IF v_new_expires_at IS NULL THEN
    v_new_expires_at := now() + (v_code.duration_months || ' months')::INTERVAL;
  END IF;

  -- 5. Upsert subscription : promote au tier du code, set expires_at.
  INSERT INTO subscriptions (
    user_id, tier, expires_at, source, promo_code, status
  ) VALUES (
    v_user_id, v_code.tier, v_new_expires_at, 'promo', v_code.code, 'active'
  )
  ON CONFLICT (user_id) DO UPDATE SET
    tier = v_code.tier,
    expires_at = v_new_expires_at,
    source = 'promo',
    promo_code = v_code.code,
    status = 'active',
    canceled_at = NULL;

  -- 6. Insert redemption record.
  INSERT INTO promo_redemptions (user_id, code)
    VALUES (v_user_id, v_code.code);

  -- 7. Increment redemption_count.
  UPDATE promo_codes
    SET redemption_count = redemption_count + 1
    WHERE code = v_code.code;

  RETURN jsonb_build_object(
    'success', true,
    'tier', v_code.tier,
    'expires_at', v_new_expires_at,
    'duration_months', v_code.duration_months
  );
END;
$$;

COMMENT ON FUNCTION redeem_promo_code(TEXT) IS
  'Active un code promo pour l''utilisateur authentifie. Validations atomiques : code existe, actif, non expire, non sature, non deja redeem par cet user. Prolonge l''abonnement existant si applicable.';

-- ───────────────────────────────────────────────────────────────────
-- 5. Fonction RPC : ensure_subscription_row()
-- Cree une ligne 'free' pour un user qui n'en a pas encore.
-- Idempotent : ne fait rien si la ligne existe deja.
-- ───────────────────────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION ensure_subscription_row()
RETURNS subscriptions
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_user_id UUID;
  v_row subscriptions;
BEGIN
  v_user_id := auth.uid();
  IF v_user_id IS NULL THEN
    RAISE EXCEPTION 'not_authenticated';
  END IF;

  INSERT INTO subscriptions (user_id) VALUES (v_user_id)
    ON CONFLICT (user_id) DO NOTHING;

  SELECT * INTO v_row FROM subscriptions WHERE user_id = v_user_id;
  RETURN v_row;
END;
$$;

-- ───────────────────────────────────────────────────────────────────
-- 6. Fonction RPC : consume_free_quiz()
-- Verifie le quota free + incremente le compteur. Reset auto la fenetre
-- de 30 jours si elle est echue.
-- Retourne : { allowed: bool, used: int, limit: int, reset_at: timestamp }
-- ───────────────────────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION consume_free_quiz()
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_user_id UUID;
  v_sub subscriptions;
  v_now TIMESTAMPTZ := now();
  v_period_end TIMESTAMPTZ;
  v_limit INTEGER := 5;
BEGIN
  v_user_id := auth.uid();
  IF v_user_id IS NULL THEN
    RETURN jsonb_build_object('allowed', false, 'error', 'not_authenticated');
  END IF;

  -- Cree la ligne free si absente.
  PERFORM ensure_subscription_row();
  SELECT * INTO v_sub FROM subscriptions WHERE user_id = v_user_id;

  -- Si tier > free et abo encore valide → consomme rien, allowed=true.
  IF v_sub.tier IN ('regional', 'evasion')
     AND (v_sub.expires_at IS NULL OR v_sub.expires_at > v_now)
     AND v_sub.status = 'active' THEN
    RETURN jsonb_build_object(
      'allowed', true,
      'tier', v_sub.tier,
      'used', 0,
      'limit', NULL
    );
  END IF;

  -- Tier free : verifier la fenetre 30j glissante.
  v_period_end := v_sub.free_period_started_at + INTERVAL '30 days';
  IF v_now >= v_period_end THEN
    -- Reset : nouvelle fenetre de 30j a partir de maintenant.
    UPDATE subscriptions SET
      free_period_started_at = v_now,
      free_quizzes_used = 1,
      tier = 'free',
      status = 'active'
    WHERE user_id = v_user_id;
    RETURN jsonb_build_object(
      'allowed', true,
      'tier', 'free',
      'used', 1,
      'limit', v_limit,
      'reset_at', v_now + INTERVAL '30 days'
    );
  END IF;

  -- Toujours dans la fenetre courante : check quota.
  IF v_sub.free_quizzes_used >= v_limit THEN
    RETURN jsonb_build_object(
      'allowed', false,
      'tier', 'free',
      'used', v_sub.free_quizzes_used,
      'limit', v_limit,
      'reset_at', v_period_end,
      'error', 'quota_exceeded'
    );
  END IF;

  -- Increment + allow.
  UPDATE subscriptions SET
    free_quizzes_used = free_quizzes_used + 1
  WHERE user_id = v_user_id;

  RETURN jsonb_build_object(
    'allowed', true,
    'tier', 'free',
    'used', v_sub.free_quizzes_used + 1,
    'limit', v_limit,
    'reset_at', v_period_end
  );
END;
$$;

-- ───────────────────────────────────────────────────────────────────
-- 7. Fonction RPC : change_region(p_new_region TEXT)
-- Pour les abonnes 'regional' : change le canton. Limite a 1x / 30 jours.
-- ───────────────────────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION change_region(p_new_region TEXT)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_user_id UUID;
  v_sub subscriptions;
  v_now TIMESTAMPTZ := now();
  v_next_change_at TIMESTAMPTZ;
BEGIN
  v_user_id := auth.uid();
  IF v_user_id IS NULL THEN
    RETURN jsonb_build_object('success', false, 'error', 'not_authenticated');
  END IF;

  IF p_new_region NOT IN ('vaud', 'valais') THEN
    RETURN jsonb_build_object('success', false, 'error', 'invalid_region');
  END IF;

  SELECT * INTO v_sub FROM subscriptions WHERE user_id = v_user_id;
  IF NOT FOUND OR v_sub.tier != 'regional' THEN
    RETURN jsonb_build_object('success', false, 'error', 'not_regional_tier');
  END IF;

  -- Si meme region : succes silencieux.
  IF v_sub.selected_region = p_new_region THEN
    RETURN jsonb_build_object('success', true, 'region', p_new_region, 'unchanged', true);
  END IF;

  -- Verifier les 30 jours depuis le dernier changement.
  IF v_sub.last_region_change IS NOT NULL THEN
    v_next_change_at := v_sub.last_region_change + INTERVAL '30 days';
    IF v_now < v_next_change_at THEN
      RETURN jsonb_build_object(
        'success', false,
        'error', 'too_soon',
        'next_change_at', v_next_change_at
      );
    END IF;
  END IF;

  UPDATE subscriptions SET
    selected_region = p_new_region,
    last_region_change = v_now
  WHERE user_id = v_user_id;

  RETURN jsonb_build_object(
    'success', true,
    'region', p_new_region,
    'next_change_at', v_now + INTERVAL '30 days'
  );
END;
$$;

-- ───────────────────────────────────────────────────────────────────
-- 8. Row Level Security
-- ───────────────────────────────────────────────────────────────────
ALTER TABLE subscriptions ENABLE ROW LEVEL SECURITY;
ALTER TABLE promo_codes ENABLE ROW LEVEL SECURITY;
ALTER TABLE promo_redemptions ENABLE ROW LEVEL SECURITY;

-- subscriptions : un user lit sa propre ligne uniquement.
DROP POLICY IF EXISTS "Users read own subscription" ON subscriptions;
CREATE POLICY "Users read own subscription"
  ON subscriptions FOR SELECT
  USING (auth.uid() = user_id);

-- promo_codes : lecture publique limitee aux codes actifs (pour validation client-side).
-- En realite, on passe par la fonction RPC redeem_promo_code() qui est SECURITY DEFINER.
-- On ne donne PAS de SELECT public car ca permettrait de scanner les codes.
DROP POLICY IF EXISTS "Promo codes are not publicly readable" ON promo_codes;
-- Pas de policy SELECT = aucun acces direct, seulement via RPC.

-- promo_redemptions : un user lit ses propres redemptions.
DROP POLICY IF EXISTS "Users read own redemptions" ON promo_redemptions;
CREATE POLICY "Users read own redemptions"
  ON promo_redemptions FOR SELECT
  USING (auth.uid() = user_id);

-- ───────────────────────────────────────────────────────────────────
-- 9. Code promo de demarrage (a personnaliser par l'admin) :
-- ───────────────────────────────────────────────────────────────────
INSERT INTO promo_codes (code, tier, duration_months, max_redemptions, description)
VALUES ('WHATEKA2026', 'evasion', 6, 100, 'Code de lancement — 6 mois d''Evasion')
ON CONFLICT (code) DO NOTHING;
