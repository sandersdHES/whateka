-- Whateka — Migration 0014 : Security hardening (P0 audit)
-- =====================================================================
-- Corrige tous les findings critiques de l'audit Supabase :
--
--  1. REVOKE EXECUTE sur les fonctions admin / dangereuses au role anon
--     (rls_auto_enable, is_admin, list_promo_redemptions_admin)
--  2. Fix policy "always true" sur feedback_hot INSERT
--  3. Drop activity_images_public_read (bucket public -> GET direct
--     fonctionne sans cette policy, qui ne servait qu'a permettre LIST)
--  4. SET search_path immutable sur les SECURITY DEFINER /  triggers
--     (is_admin, set_updated_at, update_subscriptions_updated_at,
--      reset_translations_on_fr_change, rls_auto_enable)
--  5. Policies minimales sur feedback_cold + promo_codes (RLS enabled
--     but no policy -> blocage total non intentionnel)
-- =====================================================================

-- 1. REVOKE EXECUTE sur fonctions sensibles ---------------------------
-- Important : Postgres grante EXECUTE a PUBLIC par defaut sur toute
-- nouvelle fonction. REVOKE de anon/authenticated ne suffit PAS, il
-- faut aussi REVOKE de PUBLIC sinon /rest/v1/rpc/<fn> reste joignable
-- par n'importe quel role qui herite de PUBLIC. Cf. cache_key advisor
-- "anon_security_definer_function_executable" qui persiste sinon.

-- rls_auto_enable : helper interne admin, JAMAIS appelable par un client.
REVOKE EXECUTE ON FUNCTION public.rls_auto_enable() FROM PUBLIC, anon, authenticated;

-- is_admin : sert uniquement dans les RLS policies cote DB, pas appele
-- depuis le client.
REVOKE EXECUTE ON FUNCTION public.is_admin() FROM PUBLIC, anon, authenticated;
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'is_admin' AND pronargs = 1) THEN
    EXECUTE 'REVOKE EXECUTE ON FUNCTION public.is_admin(text) FROM PUBLIC, anon, authenticated';
  END IF;
END $$;

-- list_promo_redemptions_admin : verifie is_admin() en interne, on garde
-- seulement authenticated explicite (admins doivent pouvoir l'appeler).
REVOKE EXECUTE ON FUNCTION public.list_promo_redemptions_admin() FROM PUBLIC, anon;

-- RPCs business qui exigent un user authentifie (verifient auth.uid()
-- en interne et renvoient une erreur si anon). On retire anon de la
-- surface d'attaque REST publique :
REVOKE EXECUTE ON FUNCTION public.consume_free_quiz() FROM anon;
REVOKE EXECUTE ON FUNCTION public.ensure_subscription_row() FROM anon;
REVOKE EXECUTE ON FUNCTION public.change_region(text) FROM anon;
REVOKE EXECUTE ON FUNCTION public.redeem_promo_code(text) FROM anon;
REVOKE EXECUTE ON FUNCTION public.get_unanswered_quiz_count() FROM anon;
REVOKE EXECUTE ON FUNCTION public.increment_unanswered_quiz_count() FROM anon;
REVOKE EXECUTE ON FUNCTION public.reset_unanswered_quiz_count() FROM anon;


-- 2. Fix policy "always true" sur feedback_hot INSERT -----------------
DROP POLICY IF EXISTS "Users can insert feedbacks" ON public.feedback_hot;
CREATE POLICY "Users can insert feedbacks"
  ON public.feedback_hot FOR INSERT
  TO authenticated
  WITH CHECK ((SELECT auth.uid())::text = user_id);


-- 3. Storage : retirer le SELECT public qui permet LIST ---------------
-- Le bucket activity-images est `public = true`, donc les URLs directes
-- (https://<project>.supabase.co/storage/v1/object/public/activity-images/<file>)
-- restent accessibles SANS cette policy. La policy n'autorisait que LIST.
DROP POLICY IF EXISTS activity_images_public_read ON storage.objects;


-- 4. SET search_path immutable sur les SECURITY DEFINER / triggers ----
ALTER FUNCTION public.set_updated_at() SET search_path = public, pg_temp;
ALTER FUNCTION public.update_subscriptions_updated_at() SET search_path = public, pg_temp;
ALTER FUNCTION public.reset_translations_on_fr_change() SET search_path = public, pg_temp;
ALTER FUNCTION public.is_admin() SET search_path = public, pg_temp;
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'is_admin' AND pronargs = 1) THEN
    EXECUTE 'ALTER FUNCTION public.is_admin(text) SET search_path = public, pg_temp';
  END IF;
  IF EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'rls_auto_enable') THEN
    EXECUTE 'ALTER FUNCTION public.rls_auto_enable() SET search_path = public, pg_temp';
  END IF;
END $$;


-- 5. Policies minimales sur feedback_cold + promo_codes ---------------
-- Sans policy SELECT, l'admin ne peut pas lire ces tables depuis l'UI
-- (alors qu'il devrait). On ajoute "admin reads all".
DROP POLICY IF EXISTS "Admins read all feedback_cold" ON public.feedback_cold;
CREATE POLICY "Admins read all feedback_cold"
  ON public.feedback_cold FOR SELECT
  TO authenticated
  USING (public.is_admin());

DROP POLICY IF EXISTS "Users read own feedback_cold" ON public.feedback_cold;
CREATE POLICY "Users read own feedback_cold"
  ON public.feedback_cold FOR SELECT
  TO authenticated
  USING ((SELECT auth.uid())::text = user_id);

DROP POLICY IF EXISTS "Users insert own feedback_cold" ON public.feedback_cold;
CREATE POLICY "Users insert own feedback_cold"
  ON public.feedback_cold FOR INSERT
  TO authenticated
  WITH CHECK ((SELECT auth.uid())::text = user_id);

DROP POLICY IF EXISTS "Admins read all promo_codes" ON public.promo_codes;
CREATE POLICY "Admins read all promo_codes"
  ON public.promo_codes FOR SELECT
  TO authenticated
  USING (public.is_admin());

-- Note : pas de policy INSERT/UPDATE/DELETE publique sur promo_codes :
-- la gestion des codes se fait via la console Supabase ou un futur RPC
-- admin dedie. Le flow redeem passe par redeem_promo_code() (SECURITY
-- DEFINER) qui peut lire la table independamment des policies.

COMMENT ON POLICY "Admins read all feedback_cold" ON public.feedback_cold IS
  'Admin (is_admin()) lit toutes les soumissions cold. Migration 0014.';
COMMENT ON POLICY "Admins read all promo_codes" ON public.promo_codes IS
  'Admin lit les codes promo pour les afficher dans whateka-admin. Migration 0014.';
