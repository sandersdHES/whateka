-- 1. Fermer la backdoor : tout user authentifie pouvait INSERER dans
--    public.activities via l'ancienne policy. On la supprime pour que seul
--    un admin puisse publier une activite (via activities_insert_admin).
DROP POLICY IF EXISTS "Enable insert for authenticated users only" ON public.activities;
-- (Note : la policy "Enable read access for all users" est conservee, c'est
-- juste un doublon benin de activities_select_all pour le SELECT public.)

-- 2. Deplacer les activites inserees pendant la session (2026-04-24 18:00 UTC)
--    vers activity_submissions en status 'pending', pour que l'admin les valide.
INSERT INTO activity_submissions (
  title, location_name, category, description, price_level, duration_minutes,
  latitude, longitude, is_outdoor, is_indoor, features, seasons, social_tags,
  activity_url, image_url, status, submitted_by
)
SELECT
  title, location_name, category, description, price_level, duration_minutes,
  latitude, longitude, is_outdoor, is_indoor, features, seasons, social_tags,
  activity_url, image_url, 'pending', 'vaud-import-reverted'
FROM activities
WHERE created_at > '2026-04-24 17:00:00+00';

-- 3. Supprimer ces activites de la table publique (elles reviendront apres
--    approbation admin).
DELETE FROM activities WHERE created_at > '2026-04-24 17:00:00+00';

-- Compteur de controle
SELECT
  (SELECT COUNT(*) FROM activities) AS remaining_activities,
  (SELECT COUNT(*) FROM activity_submissions WHERE submitted_by = 'vaud-import-reverted') AS moved_to_pending;
