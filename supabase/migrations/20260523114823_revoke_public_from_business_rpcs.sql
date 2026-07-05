-- L'audit advisor montre que change_region/consume_free_quiz/etc. sont
-- toujours executables par anon malgre le REVOKE FROM anon. Cause : le
-- grant PUBLIC subsiste, et anon herite implicitement de PUBLIC.
-- Solution : REVOKE FROM PUBLIC, puis GRANT explicit a authenticated.

REVOKE EXECUTE ON FUNCTION public.consume_free_quiz() FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.consume_free_quiz() TO authenticated;

REVOKE EXECUTE ON FUNCTION public.ensure_subscription_row() FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.ensure_subscription_row() TO authenticated;

REVOKE EXECUTE ON FUNCTION public.change_region(text) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.change_region(text) TO authenticated;

REVOKE EXECUTE ON FUNCTION public.redeem_promo_code(text) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.redeem_promo_code(text) TO authenticated;

REVOKE EXECUTE ON FUNCTION public.get_unanswered_quiz_count() FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.get_unanswered_quiz_count() TO authenticated;

REVOKE EXECUTE ON FUNCTION public.increment_unanswered_quiz_count() FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.increment_unanswered_quiz_count() TO authenticated;

REVOKE EXECUTE ON FUNCTION public.reset_unanswered_quiz_count() FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.reset_unanswered_quiz_count() TO authenticated;
