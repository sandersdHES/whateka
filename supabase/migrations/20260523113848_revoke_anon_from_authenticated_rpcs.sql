-- Ces RPCs verifient auth.uid() en interne et renverraient une erreur a
-- un appelant anon. On retire l'expose REST publique pour silence les
-- advisor warnings et reduire la surface d'attaque (un attaquant non
-- logge ne devrait meme pas atteindre la verif interne).
REVOKE EXECUTE ON FUNCTION public.consume_free_quiz() FROM anon;
REVOKE EXECUTE ON FUNCTION public.ensure_subscription_row() FROM anon;
REVOKE EXECUTE ON FUNCTION public.change_region(text) FROM anon;
REVOKE EXECUTE ON FUNCTION public.redeem_promo_code(text) FROM anon;
REVOKE EXECUTE ON FUNCTION public.get_unanswered_quiz_count() FROM anon;
REVOKE EXECUTE ON FUNCTION public.increment_unanswered_quiz_count() FROM anon;
REVOKE EXECUTE ON FUNCTION public.reset_unanswered_quiz_count() FROM anon;
