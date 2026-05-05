-- Whateka — Migration 0004 : photos de profil utilisateur
-- =====================================================================
-- Cree un bucket Storage public 'profile-photos' avec RLS pour que :
--   - Tout le monde puisse VOIR les photos (public read)
--   - Chaque user ne puisse upload/update/delete QUE sa propre photo
--     (verification via auth.uid() = nom du dossier racine)
--
-- Convention de chemin : profile-photos/{user_id}/avatar.{ext}
-- Exemple : profile-photos/abc123-uuid/avatar.jpg
-- =====================================================================

-- 1. Creer le bucket (idempotent)
INSERT INTO storage.buckets (id, name, public)
VALUES ('profile-photos', 'profile-photos', true)
ON CONFLICT (id) DO NOTHING;

-- 2. Policies RLS
DROP POLICY IF EXISTS "Profile photos are publicly readable" ON storage.objects;
CREATE POLICY "Profile photos are publicly readable"
  ON storage.objects FOR SELECT
  USING (bucket_id = 'profile-photos');

DROP POLICY IF EXISTS "Users can upload their own profile photo" ON storage.objects;
CREATE POLICY "Users can upload their own profile photo"
  ON storage.objects FOR INSERT
  WITH CHECK (
    bucket_id = 'profile-photos'
    AND auth.uid()::text = (storage.foldername(name))[1]
  );

DROP POLICY IF EXISTS "Users can update their own profile photo" ON storage.objects;
CREATE POLICY "Users can update their own profile photo"
  ON storage.objects FOR UPDATE
  USING (
    bucket_id = 'profile-photos'
    AND auth.uid()::text = (storage.foldername(name))[1]
  );

DROP POLICY IF EXISTS "Users can delete their own profile photo" ON storage.objects;
CREATE POLICY "Users can delete their own profile photo"
  ON storage.objects FOR DELETE
  USING (
    bucket_id = 'profile-photos'
    AND auth.uid()::text = (storage.foldername(name))[1]
  );
