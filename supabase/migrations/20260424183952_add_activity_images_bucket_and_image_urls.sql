-- Colonne image_urls (tableau de URLs) pour stocker plusieurs photos
ALTER TABLE activity_submissions ADD COLUMN IF NOT EXISTS image_urls text[] DEFAULT '{}'::text[];
ALTER TABLE activities ADD COLUMN IF NOT EXISTS image_urls text[] DEFAULT '{}'::text[];

-- Bucket public pour les photos d'activites (upload auth, lecture publique)
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'activity-images',
  'activity-images',
  true,
  5242880,
  ARRAY['image/jpeg','image/jpg','image/png','image/webp','image/heic']
)
ON CONFLICT (id) DO UPDATE SET
  public = EXCLUDED.public,
  file_size_limit = EXCLUDED.file_size_limit,
  allowed_mime_types = EXCLUDED.allowed_mime_types;

-- Policies : tout user authentifie peut uploader, tout le monde peut lire.
-- DROP IF EXISTS pour idempotence (migration peut etre rejouee).
DROP POLICY IF EXISTS "activity_images_public_read" ON storage.objects;
DROP POLICY IF EXISTS "activity_images_auth_insert" ON storage.objects;
DROP POLICY IF EXISTS "activity_images_auth_update_own" ON storage.objects;
DROP POLICY IF EXISTS "activity_images_auth_delete_own" ON storage.objects;

CREATE POLICY "activity_images_public_read"
ON storage.objects FOR SELECT
USING (bucket_id = 'activity-images');

CREATE POLICY "activity_images_auth_insert"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'activity-images');

CREATE POLICY "activity_images_auth_update_own"
ON storage.objects FOR UPDATE
TO authenticated
USING (bucket_id = 'activity-images' AND owner = auth.uid())
WITH CHECK (bucket_id = 'activity-images' AND owner = auth.uid());

CREATE POLICY "activity_images_auth_delete_own"
ON storage.objects FOR DELETE
TO authenticated
USING (bucket_id = 'activity-images' AND owner = auth.uid());
