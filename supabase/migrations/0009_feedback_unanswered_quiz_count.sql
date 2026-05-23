-- Whateka — Migration 0009 : compteur feedback "quiz sans avis"
-- ============================================================
-- Ajoute un compteur sur user_taste_profiles qui s'incremente apres
-- chaque quiz complete sans qu'un feedback hot ait ete soumis. Si
-- l'user atteint 5, un popup apparait au start du quiz suivant pour
-- l'inviter a donner son avis (avec bouton "Plus tard" qui reset).
--
-- Coupes :
-- 1. ALTER TABLE : ajoute la colonne unanswered_quiz_count
-- 2. RPC increment_unanswered_quiz_count() : appelee a la fin du quiz
--    (ai_result_screen) une fois les recos chargees
-- 3. RPC reset_unanswered_quiz_count() : appelee quand l'user soumet
--    un feedback OU quand il ferme le popup force (pour eviter spam)
-- 4. RPC get_unanswered_quiz_count() : appelee au start du quiz pour
--    decider si on affiche le popup
-- ============================================================

ALTER TABLE public.user_taste_profiles
  ADD COLUMN IF NOT EXISTS unanswered_quiz_count integer NOT NULL DEFAULT 0;

COMMENT ON COLUMN public.user_taste_profiles.unanswered_quiz_count IS
  'Quiz completes sans feedback hot. Reset a 0 quand l''user soumet ou ferme le popup. Si >= 5 au prochain quiz, popup force.';

CREATE OR REPLACE FUNCTION public.increment_unanswered_quiz_count()
RETURNS integer
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  uid uuid := auth.uid();
  new_count integer;
BEGIN
  IF uid IS NULL THEN
    RETURN 0;
  END IF;

  INSERT INTO user_taste_profiles (user_id, unanswered_quiz_count)
  VALUES (uid, 1)
  ON CONFLICT (user_id) DO UPDATE
    SET unanswered_quiz_count = user_taste_profiles.unanswered_quiz_count + 1,
        updated_at = NOW()
  RETURNING unanswered_quiz_count INTO new_count;

  RETURN new_count;
END;
$$;

CREATE OR REPLACE FUNCTION public.reset_unanswered_quiz_count()
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  uid uuid := auth.uid();
BEGIN
  IF uid IS NULL THEN
    RETURN;
  END IF;

  UPDATE user_taste_profiles
    SET unanswered_quiz_count = 0,
        updated_at = NOW()
    WHERE user_id = uid;
END;
$$;

CREATE OR REPLACE FUNCTION public.get_unanswered_quiz_count()
RETURNS integer
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
STABLE
AS $$
DECLARE
  uid uuid := auth.uid();
  cnt integer;
BEGIN
  IF uid IS NULL THEN
    RETURN 0;
  END IF;
  SELECT unanswered_quiz_count INTO cnt
    FROM user_taste_profiles WHERE user_id = uid;
  RETURN COALESCE(cnt, 0);
END;
$$;

GRANT EXECUTE ON FUNCTION public.increment_unanswered_quiz_count() TO authenticated;
GRANT EXECUTE ON FUNCTION public.reset_unanswered_quiz_count() TO authenticated;
GRANT EXECUTE ON FUNCTION public.get_unanswered_quiz_count() TO authenticated;
