ALTER TABLE activity_submissions
  ADD COLUMN IF NOT EXISTS is_indoor boolean NOT NULL DEFAULT false,
  ADD COLUMN IF NOT EXISTS price_level integer DEFAULT 1;

UPDATE activity_submissions
SET is_indoor = false
WHERE is_indoor IS NULL;

UPDATE activity_submissions
SET price_level = 1
WHERE price_level IS NULL;
