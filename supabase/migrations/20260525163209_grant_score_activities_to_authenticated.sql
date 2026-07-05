-- score_activities est une fonction SQL STABLE (lecture seule) qui retourne
-- les activites scorees + filtrees temporellement. Necessaire pour le quiz
-- ("Plus d'idees" la consomme directement). Aucun risque securitaire :
-- elle applique deja les memes filtres que les policies RLS.
GRANT EXECUTE ON FUNCTION public.score_activities(
  text[], integer[], integer, text, text, text, text,
  double precision, double precision, double precision, uuid,
  bigint[], integer, double precision, timestamptz, integer
) TO authenticated;

-- Verif
DO $$
BEGIN
  IF NOT has_function_privilege('authenticated', 'public.score_activities(text[], integer[], integer, text, text, text, text, double precision, double precision, double precision, uuid, bigint[], integer, double precision, timestamptz, integer)', 'EXECUTE') THEN
    RAISE EXCEPTION 'GRANT failed';
  END IF;
END $$;
