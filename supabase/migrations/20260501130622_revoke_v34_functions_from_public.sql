-- v34 hardening : revoque EXECUTE depuis PUBLIC sur les fonctions
-- SECURITY DEFINER. Sans ca, anon/authenticated heritent de PUBLIC
-- meme apres le REVOKE explicite (lints 0028, 0029).
REVOKE EXECUTE ON FUNCTION public.compute_user_taste_profile(uuid) FROM PUBLIC;
REVOKE EXECUTE ON FUNCTION public.refresh_user_taste_profile_from_favorites() FROM PUBLIC;
REVOKE EXECUTE ON FUNCTION public.update_activity_favorites_count() FROM PUBLIC;
REVOKE EXECUTE ON FUNCTION public.score_activities(
  text[], integer[], integer, text, text, text, text,
  double precision, double precision, double precision, uuid,
  bigint[], integer, double precision, timestamptz, integer
) FROM PUBLIC;
