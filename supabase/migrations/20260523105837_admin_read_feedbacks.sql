CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
STABLE
SET search_path = public
AS $$
DECLARE
  v_email TEXT;
BEGIN
  SELECT u.email INTO v_email FROM auth.users u WHERE u.id = auth.uid();
  IF v_email IS NULL THEN RETURN false; END IF;
  RETURN EXISTS (
    SELECT 1 FROM public.admin_users a
     WHERE lower(a.email) = lower(v_email)
  );
END;
$$;

COMMENT ON FUNCTION public.is_admin() IS
  'Renvoie true si l''utilisateur authentifie est present dans admin_users (match insensible a la casse sur l''email).';

GRANT EXECUTE ON FUNCTION public.is_admin() TO authenticated;

DROP POLICY IF EXISTS "Admins read all submissions" ON public.feedback_submissions;
CREATE POLICY "Admins read all submissions"
  ON public.feedback_submissions FOR SELECT
  USING (public.is_admin());

DROP POLICY IF EXISTS "Admins read all answers" ON public.feedback_answers;
CREATE POLICY "Admins read all answers"
  ON public.feedback_answers FOR SELECT
  USING (public.is_admin());

DROP POLICY IF EXISTS "Admins read all promo redemptions" ON public.promo_redemptions;
CREATE POLICY "Admins read all promo redemptions"
  ON public.promo_redemptions FOR SELECT
  USING (public.is_admin());

DROP POLICY IF EXISTS "Admins read all subscriptions" ON public.subscriptions;
CREATE POLICY "Admins read all subscriptions"
  ON public.subscriptions FOR SELECT
  USING (public.is_admin());
