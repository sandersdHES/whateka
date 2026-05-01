-- v34 perf optim - hardening per Supabase advisors.
--   - search_path explicite sur les helpers (lints 0011).
--   - REVOKE EXECUTE depuis anon/authenticated sur fonctions appelees
--     uniquement cote serveur (lints 0028, 0029).
--   - RLS init plan optimise sur user_taste_profiles (lint 0003).

-- 1. search_path explicite sur les helpers.
ALTER FUNCTION public.haversine_km(double precision, double precision, double precision, double precision)
  SET search_path = public;
ALTER FUNCTION public.is_activity_proposable_now(text, date, date, integer[], integer[], text, timestamptz)
  SET search_path = public;
ALTER FUNCTION public.score_activities(
  text[], integer[], integer, text, text, text, text,
  double precision, double precision, double precision, uuid,
  bigint[], integer, double precision, timestamptz, integer
) SET search_path = public;

-- 2. REVOKE EXECUTE depuis anon/authenticated. Ces fonctions sont appelees
--    soit par triggers (donc avec les droits du proprietaire de la table),
--    soit par l'Edge Function qui utilise SERVICE_ROLE_KEY (postgres role
--    `service_role` — bypass RLS, droits eleves). Aucun client mobile / web
--    ne doit pouvoir les invoquer directement via /rest/v1/rpc/.
REVOKE EXECUTE ON FUNCTION public.compute_user_taste_profile(uuid) FROM anon, authenticated;
REVOKE EXECUTE ON FUNCTION public.refresh_user_taste_profile_from_favorites() FROM anon, authenticated;
REVOKE EXECUTE ON FUNCTION public.update_activity_favorites_count() FROM anon, authenticated;
REVOKE EXECUTE ON FUNCTION public.score_activities(
  text[], integer[], integer, text, text, text, text,
  double precision, double precision, double precision, uuid,
  bigint[], integer, double precision, timestamptz, integer
) FROM anon, authenticated;

-- 3. RLS init plan : remplacer auth.uid() par (SELECT auth.uid()) pour
--    eviter la re-evaluation par ligne (lint 0003).
DROP POLICY IF EXISTS user_taste_profiles_self_select ON public.user_taste_profiles;
CREATE POLICY user_taste_profiles_self_select ON public.user_taste_profiles
  FOR SELECT TO authenticated
  USING (user_id = (SELECT auth.uid()));
