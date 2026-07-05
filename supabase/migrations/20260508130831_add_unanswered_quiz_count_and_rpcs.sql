-- Whateka : compteur de quiz non-feedbackes par user
-- Sert au popup feedback force apres 5 quiz sans aucun retour utilisateur

ALTER TABLE public.user_taste_profiles
  ADD COLUMN IF NOT EXISTS unanswered_quiz_count integer NOT NULL DEFAULT 0;

COMMENT ON COLUMN public.user_taste_profiles.unanswered_quiz_count IS
  'Quiz completes sans feedback hot. Reset a 0 quand l''user soumet ou ferme le popup. Si >= 5 au prochain quiz, popup force.';

-- RPC : incrementer le compteur a la fin du quiz
-- Cree la ligne profile si elle n''existe pas (premier quiz du user)
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

-- RPC : reset (appele quand user soumet feedback OU ferme le popup force)
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

-- RPC : lire le compteur courant (pour le check au start du quiz)
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

-- Permissions : authenticated peut appeler ces RPCs
GRANT EXECUTE ON FUNCTION public.increment_unanswered_quiz_count() TO authenticated;
GRANT EXECUTE ON FUNCTION public.reset_unanswered_quiz_count() TO authenticated;
GRANT EXECUTE ON FUNCTION public.get_unanswered_quiz_count() TO authenticated;
