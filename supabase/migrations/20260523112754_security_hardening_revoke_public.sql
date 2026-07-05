-- L'audit advisor montre que les SECURITY DEFINER restent appelables via
-- /rest/v1/rpc/... a cause du grant PUBLIC par defaut de Postgres
-- (`=X/postgres` dans proacl). On REVOKE explicitement de PUBLIC.

REVOKE EXECUTE ON FUNCTION public.rls_auto_enable() FROM PUBLIC;
REVOKE EXECUTE ON FUNCTION public.is_admin() FROM PUBLIC;
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'is_admin' AND pronargs = 1) THEN
    EXECUTE 'REVOKE EXECUTE ON FUNCTION public.is_admin(text) FROM PUBLIC';
  END IF;
END $$;

-- list_promo_redemptions_admin verifie is_admin() en interne donc
-- techniquement safe, mais on retire de PUBLIC : seul `authenticated`
-- l'a explicitement (PostgREST exposera quand meme via JWT auth).
REVOKE EXECUTE ON FUNCTION public.list_promo_redemptions_admin() FROM PUBLIC;
