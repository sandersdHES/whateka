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
  v_user_id := auth.uid();
  IF v_user_id IS NULL THEN
    RETURN jsonb_build_object('success', false, 'error', 'not_authenticated');
  END IF;

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

  SELECT EXISTS (
    SELECT 1 FROM promo_redemptions WHERE user_id = v_user_id
  ) INTO v_has_any_redemption;
  IF v_has_any_redemption THEN
    RETURN jsonb_build_object('success', false, 'error', 'already_used_a_promo');
  END IF;

  v_new_expires_at := now() + (v_code.duration_months || ' months')::INTERVAL;

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

  INSERT INTO promo_redemptions (user_id, code)
    VALUES (v_user_id, v_code.code);

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
