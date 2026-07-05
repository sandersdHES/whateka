DROP POLICY IF EXISTS "Users can view own favorites" ON public.favorites;
CREATE POLICY "Users can view own favorites" ON public.favorites FOR SELECT TO authenticated USING ((SELECT auth.uid()) = user_id);
DROP POLICY IF EXISTS "Users can insert own favorites" ON public.favorites;
CREATE POLICY "Users can insert own favorites" ON public.favorites FOR INSERT TO authenticated WITH CHECK ((SELECT auth.uid()) = user_id);
DROP POLICY IF EXISTS "Users can delete own favorites" ON public.favorites;
CREATE POLICY "Users can delete own favorites" ON public.favorites FOR DELETE TO authenticated USING ((SELECT auth.uid()) = user_id);
DROP POLICY IF EXISTS "Admins can view all favorites" ON public.favorites;
CREATE POLICY "Admins can view all favorites" ON public.favorites FOR SELECT TO authenticated USING ((SELECT public.is_admin()));

DROP POLICY IF EXISTS "Enable read access for all users" ON public.activities;
DROP POLICY IF EXISTS activities_insert_admin ON public.activities;
CREATE POLICY activities_insert_admin ON public.activities FOR INSERT TO authenticated WITH CHECK ((SELECT public.is_admin()));
DROP POLICY IF EXISTS activities_update_admin ON public.activities;
CREATE POLICY activities_update_admin ON public.activities FOR UPDATE TO authenticated USING ((SELECT public.is_admin())) WITH CHECK ((SELECT public.is_admin()));
DROP POLICY IF EXISTS activities_delete_admin ON public.activities;
CREATE POLICY activities_delete_admin ON public.activities FOR DELETE TO authenticated USING ((SELECT public.is_admin()));

DROP POLICY IF EXISTS submissions_insert_auth ON public.activity_submissions;
CREATE POLICY submissions_insert_auth ON public.activity_submissions FOR INSERT TO authenticated WITH CHECK ((SELECT auth.role()) = 'authenticated');
DROP POLICY IF EXISTS submissions_select_admin ON public.activity_submissions;
CREATE POLICY submissions_select_admin ON public.activity_submissions FOR SELECT TO authenticated USING ((SELECT public.is_admin()));
DROP POLICY IF EXISTS submissions_update_admin ON public.activity_submissions;
CREATE POLICY submissions_update_admin ON public.activity_submissions FOR UPDATE TO authenticated USING ((SELECT public.is_admin())) WITH CHECK ((SELECT public.is_admin()));
DROP POLICY IF EXISTS submissions_delete_admin ON public.activity_submissions;
CREATE POLICY submissions_delete_admin ON public.activity_submissions FOR DELETE TO authenticated USING ((SELECT public.is_admin()));

DROP POLICY IF EXISTS "Admins can view all feedbacks" ON public.feedback_hot;
CREATE POLICY "Admins can view all feedbacks" ON public.feedback_hot FOR SELECT TO authenticated USING ((SELECT public.is_admin()));
DROP POLICY IF EXISTS "Users can view own feedbacks" ON public.feedback_hot;
CREATE POLICY "Users can view own feedbacks" ON public.feedback_hot FOR SELECT TO authenticated USING (user_id = (SELECT auth.uid())::text);

DROP POLICY IF EXISTS "Authenticated users can submit feedback" ON public.feedback_submissions;
CREATE POLICY "Authenticated users can submit feedback" ON public.feedback_submissions FOR INSERT TO authenticated WITH CHECK ((SELECT auth.uid()) IS NOT NULL);
DROP POLICY IF EXISTS "Users can read their own submissions" ON public.feedback_submissions;
CREATE POLICY "Users can read their own submissions" ON public.feedback_submissions FOR SELECT TO authenticated USING ((SELECT auth.uid()) = user_id);

DROP POLICY IF EXISTS "Users can insert their own answers" ON public.feedback_answers;
CREATE POLICY "Users can insert their own answers" ON public.feedback_answers FOR INSERT TO authenticated WITH CHECK (EXISTS (SELECT 1 FROM public.feedback_submissions s WHERE s.id = feedback_answers.submission_id AND s.user_id = (SELECT auth.uid())));
DROP POLICY IF EXISTS "Users can read their own answers" ON public.feedback_answers;
CREATE POLICY "Users can read their own answers" ON public.feedback_answers FOR SELECT TO authenticated USING (EXISTS (SELECT 1 FROM public.feedback_submissions s WHERE s.id = feedback_answers.submission_id AND s.user_id = (SELECT auth.uid())));

DROP POLICY IF EXISTS app_access_select_all ON public.app_access;
DROP POLICY IF EXISTS app_access_admin_all ON public.app_access;
CREATE POLICY app_access_admin_all ON public.app_access FOR ALL TO authenticated USING ((SELECT public.is_admin())) WITH CHECK ((SELECT public.is_admin()));

DROP POLICY IF EXISTS "Users read own subscription" ON public.subscriptions;
CREATE POLICY "Users read own subscription" ON public.subscriptions FOR SELECT TO authenticated USING ((SELECT auth.uid()) = user_id);

DROP POLICY IF EXISTS "Users read own redemptions" ON public.promo_redemptions;
CREATE POLICY "Users read own redemptions" ON public.promo_redemptions FOR SELECT TO authenticated USING ((SELECT auth.uid()) = user_id);

CREATE INDEX IF NOT EXISTS favorites_activity_id_idx ON public.favorites(activity_id);
CREATE INDEX IF NOT EXISTS promo_redemptions_code_idx ON public.promo_redemptions(code);
