-- Whateka : badge "verified" / certifié par l'équipe Whateka
-- Permet à l'admin de marquer une activité comme testée+approuvée.
-- Affiché côté app sous forme d'un badge starburst cyan avec W blanc.

ALTER TABLE public.activities
  ADD COLUMN IF NOT EXISTS is_whateka_certified boolean NOT NULL DEFAULT false;

ALTER TABLE public.activity_submissions
  ADD COLUMN IF NOT EXISTS is_whateka_certified boolean NOT NULL DEFAULT false;

COMMENT ON COLUMN public.activities.is_whateka_certified IS
  'Activité testée et approuvée par l''équipe Whateka. Badge "W verified" affiché côté app à côté des catégories.';

COMMENT ON COLUMN public.activity_submissions.is_whateka_certified IS
  'Activité testée et approuvée par l''équipe Whateka. Conservé lors du passage submission -> activities.';
