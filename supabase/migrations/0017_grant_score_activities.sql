-- Whateka — Migration 0017 : GRANT score_activities() a authenticated
-- =====================================================================
-- La RPC score_activities est utilisee par le bouton "Plus d'idees"
-- (AiResultScreen) pour proposer des activites coherentes avec les
-- reponses du quiz (memes categories, budget, environnement, etc.).
--
-- Elle etait revokee de PUBLIC/anon/authenticated par une migration v34
-- precedente. On re-GRANT a authenticated uniquement (anon ne fait
-- jamais de quiz).
--
-- Cote securite : fonction SQL STABLE (lecture seule), pas SECURITY
-- DEFINER, applique les memes filtres que les policies RLS. Aucun
-- risque d'exfiltration.
-- =====================================================================

GRANT EXECUTE ON FUNCTION public.score_activities(
  text[], integer[], integer, text, text, text, text,
  double precision, double precision, double precision, uuid,
  bigint[], integer, double precision, timestamptz, integer
) TO authenticated;
