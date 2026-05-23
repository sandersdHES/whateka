-- Whateka — Migration 0012 : limite à 1 code promo par compte
-- =====================================================================
-- Avant cette migration, la RPC redeem_promo_code() empêchait seulement
-- de réutiliser LE MÊME code. Un utilisateur pouvait donc cumuler
-- WHATEKA2026 (6 mois) + WA2026 (3 mois) = 9 mois d'Évasion.
--
-- Désormais : un compte ne peut activer qu'UN SEUL code promo, quel qu'il
-- soit. Si l'utilisateur a déjà une ligne dans promo_redemptions, la RPC
-- renvoie l'erreur 'already_used_a_promo'.
-- =====================================================================

CREATE OR REPLACE FUNCTION public.redeem_promo_code(p_code TEXT)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_user_id UUID;
  v_code RECORD;
  v_has_any_redemption BOOLEAN;
  v_new_expires_at TIMESTAMPTZ;
BEGIN
  -- 1. Identité de l'appelant.
  v_user_id := auth.uid();
  IF v_user_id IS NULL THEN
    RETURN jsonb_build_object('success', false, 'error', 'not_authenticated');
  END IF;

  -- 2. Charge le code (uppercase pour insensibilité à la casse).
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

  -- 3. NOUVELLE RÈGLE : un compte ne peut activer qu'UN SEUL code promo.
  --    Si l'user a déjà une ligne dans promo_redemptions (n'importe quel
  --    code), on refuse — même s'il essaie un code différent.
  SELECT EXISTS (
    SELECT 1 FROM promo_redemptions WHERE user_id = v_user_id
  ) INTO v_has_any_redemption;
  IF v_has_any_redemption THEN
    RETURN jsonb_build_object('success', false, 'error', 'already_used_a_promo');
  END IF;

  -- 4. Calcule la nouvelle expires_at : démarre maintenant.
  --    (plus de logique de prolongation cumulative — un seul code par compte
  --    donc pas de cumul à gérer)
  v_new_expires_at := now() + (v_code.duration_months || ' months')::INTERVAL;

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

COMMENT ON FUNCTION public.redeem_promo_code(TEXT) IS
  'Active un code promo pour l''utilisateur authentifié. Validations atomiques : code existe, actif, non expiré, non saturé, ET l''utilisateur n''a encore JAMAIS utilisé de code promo (1 code par compte maximum). Migration 0012.';
