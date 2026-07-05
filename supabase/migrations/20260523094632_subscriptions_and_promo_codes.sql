-- Whateka — Migration 0003 (déployée tardivement) : système d'abonnement
-- Crée subscriptions, promo_codes, promo_redemptions + RPCs.
-- Voir whateka/supabase/migrations/0003_subscriptions.sql pour les détails.

-- 1. Table subscriptions
CREATE TABLE IF NOT EXISTS subscriptions (
  user_id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  tier TEXT NOT NULL DEFAULT 'free'
    CHECK (tier IN ('free', 'regional', 'evasion')),
  selected_region TEXT
    CHECK (selected_region IN ('vaud', 'valais') OR selected_region IS NULL),
  free_period_started_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  free_quizzes_used INTEGER NOT NULL DEFAULT 0,
  last_region_change TIMESTAMPTZ,
  trial_ends_at TIMESTAMPTZ,
  expires_at TIMESTAMPTZ,
  source TEXT CHECK (source IN ('apple', 'stripe', 'promo') OR source IS NULL),
  apple_transaction_id TEXT,
  stripe_subscription_id TEXT,
  promo_code TEXT,
  status TEXT NOT NULL DEFAULT 'active'
    CHECK (status IN ('active', 'canceled', 'expired')),
  canceled_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_subscriptions_tier ON subscriptions(tier);
CREATE INDEX IF NOT EXISTS idx_subscriptions_status ON subscriptions(status);
CREATE INDEX IF NOT EXISTS idx_subscriptions_expires_at ON subscriptions(expires_at);

CREATE OR REPLACE FUNCTION update_subscriptions_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS subscriptions_updated_at ON subscriptions;
CREATE TRIGGER subscriptions_updated_at
  BEFORE UPDATE ON subscriptions FOR EACH ROW
  EXECUTE FUNCTION update_subscriptions_updated_at();

-- 2. Table promo_codes
CREATE TABLE IF NOT EXISTS promo_codes (
  code TEXT PRIMARY KEY,
  tier TEXT NOT NULL DEFAULT 'evasion'
    CHECK (tier IN ('regional', 'evasion')),
  duration_months INTEGER NOT NULL DEFAULT 6 CHECK (duration_months > 0),
  max_redemptions INTEGER CHECK (max_redemptions IS NULL OR max_redemptions > 0),
  redemption_count INTEGER NOT NULL DEFAULT 0,
  expires_at TIMESTAMPTZ,
  active BOOLEAN NOT NULL DEFAULT true,
  description TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_promo_codes_active ON promo_codes(active) WHERE active = true;

-- 3. Table promo_redemptions
CREATE TABLE IF NOT EXISTS promo_redemptions (
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  code TEXT NOT NULL REFERENCES promo_codes(code) ON DELETE CASCADE,
  redeemed_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  PRIMARY KEY (user_id, code)
);

CREATE INDEX IF NOT EXISTS idx_promo_redemptions_user ON promo_redemptions(user_id);

-- 4. RPC redeem_promo_code
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
  v_user_id := auth.uid();
  IF v_user_id IS NULL THEN
    RETURN jsonb_build_object('success', false, 'error', 'not_authenticated');
  END IF;

  SELECT * INTO v_code FROM promo_codes
    WHERE code = upper(trim(p_code)) LIMIT 1;
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

  SELECT EXISTS (
    SELECT 1 FROM promo_redemptions WHERE user_id = v_user_id AND code = v_code.code
  ) INTO v_already_redeemed;
  IF v_already_redeemed THEN
    RETURN jsonb_build_object('success', false, 'error', 'already_redeemed');
  END IF;

  SELECT GREATEST(now(), COALESCE(expires_at, now()))
         + (v_code.duration_months || ' months')::INTERVAL
    INTO v_new_expires_at
    FROM subscriptions WHERE user_id = v_user_id;
  IF v_new_expires_at IS NULL THEN
    v_new_expires_at := now() + (v_code.duration_months || ' months')::INTERVAL;
  END IF;

  INSERT INTO subscriptions (user_id, tier, expires_at, source, promo_code, status)
  VALUES (v_user_id, v_code.tier, v_new_expires_at, 'promo', v_code.code, 'active')
  ON CONFLICT (user_id) DO UPDATE SET
    tier = v_code.tier, expires_at = v_new_expires_at, source = 'promo',
    promo_code = v_code.code, status = 'active', canceled_at = NULL;

  INSERT INTO promo_redemptions (user_id, code) VALUES (v_user_id, v_code.code);
  UPDATE promo_codes SET redemption_count = redemption_count + 1 WHERE code = v_code.code;

  RETURN jsonb_build_object('success', true, 'tier', v_code.tier,
    'expires_at', v_new_expires_at, 'duration_months', v_code.duration_months);
END;
$$;

-- 5. ensure_subscription_row
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

-- 6. consume_free_quiz
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
  PERFORM ensure_subscription_row();
  SELECT * INTO v_sub FROM subscriptions WHERE user_id = v_user_id;

  IF v_sub.tier IN ('regional', 'evasion')
     AND (v_sub.expires_at IS NULL OR v_sub.expires_at > v_now)
     AND v_sub.status = 'active' THEN
    RETURN jsonb_build_object('allowed', true, 'tier', v_sub.tier, 'used', 0, 'limit', NULL);
  END IF;

  v_period_end := v_sub.free_period_started_at + INTERVAL '30 days';
  IF v_now >= v_period_end THEN
    UPDATE subscriptions SET
      free_period_started_at = v_now, free_quizzes_used = 1,
      tier = 'free', status = 'active'
    WHERE user_id = v_user_id;
    RETURN jsonb_build_object('allowed', true, 'tier', 'free', 'used', 1, 'limit', v_limit,
      'reset_at', v_now + INTERVAL '30 days');
  END IF;

  IF v_sub.free_quizzes_used >= v_limit THEN
    RETURN jsonb_build_object('allowed', false, 'tier', 'free',
      'used', v_sub.free_quizzes_used, 'limit', v_limit,
      'reset_at', v_period_end, 'error', 'quota_exceeded');
  END IF;

  UPDATE subscriptions SET free_quizzes_used = free_quizzes_used + 1 WHERE user_id = v_user_id;
  RETURN jsonb_build_object('allowed', true, 'tier', 'free',
    'used', v_sub.free_quizzes_used + 1, 'limit', v_limit, 'reset_at', v_period_end);
END;
$$;

-- 7. change_region
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
  IF v_sub.selected_region = p_new_region THEN
    RETURN jsonb_build_object('success', true, 'region', p_new_region, 'unchanged', true);
  END IF;
  IF v_sub.last_region_change IS NOT NULL THEN
    v_next_change_at := v_sub.last_region_change + INTERVAL '30 days';
    IF v_now < v_next_change_at THEN
      RETURN jsonb_build_object('success', false, 'error', 'too_soon',
        'next_change_at', v_next_change_at);
    END IF;
  END IF;
  UPDATE subscriptions SET selected_region = p_new_region, last_region_change = v_now
    WHERE user_id = v_user_id;
  RETURN jsonb_build_object('success', true, 'region', p_new_region,
    'next_change_at', v_now + INTERVAL '30 days');
END;
$$;

-- 8. RLS
ALTER TABLE subscriptions ENABLE ROW LEVEL SECURITY;
ALTER TABLE promo_codes ENABLE ROW LEVEL SECURITY;
ALTER TABLE promo_redemptions ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users read own subscription" ON subscriptions;
CREATE POLICY "Users read own subscription"
  ON subscriptions FOR SELECT USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users read own redemptions" ON promo_redemptions;
CREATE POLICY "Users read own redemptions"
  ON promo_redemptions FOR SELECT USING (auth.uid() = user_id);

-- 9. Codes promo de demarrage
INSERT INTO promo_codes (code, tier, duration_months, max_redemptions, description)
VALUES ('WHATEKA2026', 'evasion', 6, 100, 'Code de lancement — 6 mois d''Évasion')
ON CONFLICT (code) DO NOTHING;

INSERT INTO promo_codes (code, tier, duration_months, max_redemptions, description)
VALUES ('WA2026', 'evasion', 3, NULL, 'Code promo — 3 mois d''Évasion (Premium)')
ON CONFLICT (code) DO NOTHING;
