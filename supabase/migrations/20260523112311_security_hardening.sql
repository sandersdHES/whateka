REVOKE EXECUTE ON FUNCTION public.rls_auto_enable() FROM anon, authenticated;
REVOKE EXECUTE ON FUNCTION public.is_admin() FROM anon, authenticated;
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'is_admin' AND pronargs = 1) THEN
    EXECUTE 'REVOKE EXECUTE ON FUNCTION public.is_admin(text) FROM anon, authenticated';
  END IF;
END $$;
REVOKE EXECUTE ON FUNCTION public.list_promo_redemptions_admin() FROM anon;

DROP POLICY IF EXISTS "Users can insert feedbacks" ON public.feedback_hot;
CREATE POLICY "Users can insert feedbacks"
  ON public.feedback_hot FOR INSERT
  TO authenticated
  WITH CHECK ((SELECT auth.uid())::text = user_id);

DROP POLICY IF EXISTS activity_images_public_read ON storage.objects;

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
