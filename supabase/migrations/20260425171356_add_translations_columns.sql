-- Colonnes de traduction EN. Le FR original reste dans title/description/...
-- Si _en est NULL, le frontend tombe en fallback FR.
ALTER TABLE activities
  ADD COLUMN IF NOT EXISTS title_en TEXT,
  ADD COLUMN IF NOT EXISTS description_en TEXT,
  ADD COLUMN IF NOT EXISTS date_label_en TEXT,
  ADD COLUMN IF NOT EXISTS update_notes_en TEXT;

ALTER TABLE activity_submissions
  ADD COLUMN IF NOT EXISTS title_en TEXT,
  ADD COLUMN IF NOT EXISTS description_en TEXT,
  ADD COLUMN IF NOT EXISTS date_label_en TEXT,
  ADD COLUMN IF NOT EXISTS update_notes_en TEXT;
