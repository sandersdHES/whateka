-- Whateka — Migration : ajouter location_zone a activity_submissions
-- Pour aligner le schema avec la table 'activities' (qui a deja la colonne)
-- et permettre les seeds Valais avec zones loc_central/loc_upper/loc_lower.
ALTER TABLE public.activity_submissions
  ADD COLUMN IF NOT EXISTS location_zone text;

COMMENT ON COLUMN public.activity_submissions.location_zone IS
  'Zone Valais : loc_central / loc_upper / loc_lower. NULL pour Vaud.';
