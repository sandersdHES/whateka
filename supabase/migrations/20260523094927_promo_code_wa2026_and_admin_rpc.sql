-- 1. Code promo WA2026 (3 mois Evasion, illimité).
INSERT INTO public.promo_codes (code, tier, duration_months, max_redemptions, description)
VALUES ('WA2026', 'evasion', 3, NULL, 'Code promo WA2026 — 3 mois d''Evasion (illimité)')
ON CONFLICT (code) DO UPDATE SET
  tier = EXCLUDED.tier,
  duration_months = EXCLUDED.duration_months,
  max_redemptions = EXCLUDED.max_redemptions,
  description = EXCLUDED.description,
  active = true;

-- 2. RPC admin : liste toutes les redemptions avec infos user + abonnement.
CREATE OR REPLACE FUNCTION public.list_promo_redemptions_admin()
RETURNS TABLE (
  user_id UUID,
  email TEXT,
  code TEXT,
  tier TEXT,
  duration_months INTEGER,
  redeemed_at TIMESTAMPTZ,
  expires_at TIMESTAMPTZ,
  status TEXT,
  seconds_remaining BIGINT
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_caller_email TEXT;
  v_is_admin BOOLEAN;
BEGIN
  SELECT u.email INTO v_caller_email
    FROM auth.users u
   WHERE u.id = auth.uid();

  IF v_caller_email IS NULL THEN
    RAISE EXCEPTION 'not_authenticated';
  END IF;

  SELECT EXISTS (
    SELECT 1 FROM public.admin_users a WHERE lower(a.email) = lower(v_caller_email)
  ) INTO v_is_admin;

  IF NOT v_is_admin THEN
    RAISE EXCEPTION 'not_admin';
  END IF;

  RETURN QUERY
  SELECT
    r.user_id,
    u.email::TEXT                                          AS email,
    r.code,
    pc.tier,
    pc.duration_months,
    r.redeemed_at,
    s.expires_at,
    s.status,
    CASE
      WHEN s.expires_at IS NULL THEN NULL
      ELSE GREATEST(0, EXTRACT(EPOCH FROM (s.expires_at - now()))::BIGINT)
    END                                                    AS seconds_remaining
  FROM public.promo_redemptions r
  JOIN public.promo_codes pc       ON pc.code = r.code
  LEFT JOIN public.subscriptions s ON s.user_id = r.user_id
  LEFT JOIN auth.users u           ON u.id = r.user_id
  ORDER BY r.redeemed_at DESC;
END;
$$;

COMMENT ON FUNCTION public.list_promo_redemptions_admin() IS
  'Liste toutes les redemptions de codes promo avec email + expiration + temps restant. Réservée aux admins (admin_users).';

GRANT EXECUTE ON FUNCTION public.list_promo_redemptions_admin() TO authenticated;
