-- Quand title ou description (ou date_label) change, on reset la version EN
-- a NULL pour qu'elle soit re-traduite. Une fonction ulterieure (cron ou
-- post-action admin) appelle l'edge function translate-activity pour les
-- lignes ayant FR rempli mais EN null.

CREATE OR REPLACE FUNCTION reset_translations_on_fr_change() RETURNS TRIGGER AS $$
BEGIN
  IF NEW.title IS DISTINCT FROM OLD.title THEN
    NEW.title_en := NULL;
  END IF;
  IF NEW.description IS DISTINCT FROM OLD.description THEN
    NEW.description_en := NULL;
  END IF;
  IF NEW.date_label IS DISTINCT FROM OLD.date_label THEN
    NEW.date_label_en := NULL;
  END IF;
  IF NEW.update_notes IS DISTINCT FROM OLD.update_notes THEN
    NEW.update_notes_en := NULL;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS reset_translations_on_activities_update ON activities;
CREATE TRIGGER reset_translations_on_activities_update
  BEFORE UPDATE ON activities
  FOR EACH ROW EXECUTE FUNCTION reset_translations_on_fr_change();

DROP TRIGGER IF EXISTS reset_translations_on_submissions_update ON activity_submissions;
CREATE TRIGGER reset_translations_on_submissions_update
  BEFORE UPDATE ON activity_submissions
  FOR EACH ROW EXECUTE FUNCTION reset_translations_on_fr_change();

-- Index pour identifier rapidement les lignes a traduire
CREATE INDEX IF NOT EXISTS idx_activities_needs_translation
  ON activities(id) WHERE title_en IS NULL AND title IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_submissions_needs_translation
  ON activity_submissions(id) WHERE title_en IS NULL AND title IS NOT NULL;
