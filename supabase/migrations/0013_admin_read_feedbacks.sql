-- Whateka — Migration 0013 : RLS — admins lisent TOUS les feedbacks
-- =====================================================================
-- Bug constate : la page Feedbacks de whateka-admin semblait vide pour
-- l'admin connecte, alors que la base contient 11 submissions + 47
-- answers. Cause : les policies SELECT existantes ne laissent un user
-- voir QUE ses propres lignes (auth.uid() = user_id).
--
-- Fix : ajoute des policies SELECT permissives pour tout compte
-- present dans public.admin_users (matching par email JWT). Coexistent
-- avec les policies user-scoped existantes (RLS = OR entre policies).
-- =====================================================================

-- Helper : retourne true si l'appelant authentifie est dans admin_users.
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

-- ───────────────────────────────────────────────────────────────────
-- feedback_submissions : laisse les admins voir TOUT.
-- ───────────────────────────────────────────────────────────────────
DROP POLICY IF EXISTS "Admins read all submissions" ON public.feedback_submissions;
CREATE POLICY "Admins read all submissions"
  ON public.feedback_submissions FOR SELECT
  USING (public.is_admin());

-- ───────────────────────────────────────────────────────────────────
-- feedback_answers : pareil.
-- ───────────────────────────────────────────────────────────────────
DROP POLICY IF EXISTS "Admins read all answers" ON public.feedback_answers;
CREATE POLICY "Admins read all answers"
  ON public.feedback_answers FOR SELECT
  USING (public.is_admin());

-- ───────────────────────────────────────────────────────────────────
-- Bonus : pareil sur promo_redemptions et subscriptions pour que la
-- page Acces puisse aussi tout afficher sans dependance au RPC dedie
-- (sert juste de defense en profondeur, le RPC reste la voie officielle).
-- ───────────────────────────────────────────────────────────────────
DROP POLICY IF EXISTS "Admins read all promo redemptions" ON public.promo_redemptions;
CREATE POLICY "Admins read all promo redemptions"
  ON public.promo_redemptions FOR SELECT
  USING (public.is_admin());

DROP POLICY IF EXISTS "Admins read all subscriptions" ON public.subscriptions;
CREATE POLICY "Admins read all subscriptions"
  ON public.subscriptions FOR SELECT
  USING (public.is_admin());
