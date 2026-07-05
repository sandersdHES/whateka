-- Champs pour gérer les institutions et la planification des mises à jour.
-- Frequency: 'weekly' | 'monthly' | 'quarterly' | 'yearly' | 'before_season' | 'manual'
-- 'before_season' = 2 semaines avant la saison (foot/hockey).

ALTER TABLE activities
  ADD COLUMN IF NOT EXISTS update_frequency TEXT,
  ADD COLUMN IF NOT EXISTS last_updated_at TIMESTAMPTZ,
  ADD COLUMN IF NOT EXISTS next_update_at DATE,
  ADD COLUMN IF NOT EXISTS update_notes TEXT,
  ADD COLUMN IF NOT EXISTS parent_institution_id INT;

ALTER TABLE activity_submissions
  ADD COLUMN IF NOT EXISTS update_frequency TEXT,
  ADD COLUMN IF NOT EXISTS last_updated_at TIMESTAMPTZ,
  ADD COLUMN IF NOT EXISTS next_update_at DATE,
  ADD COLUMN IF NOT EXISTS update_notes TEXT,
  ADD COLUMN IF NOT EXISTS parent_institution_id INT;

-- Contrainte sur update_frequency
ALTER TABLE activities DROP CONSTRAINT IF EXISTS activities_update_frequency_check;
ALTER TABLE activities ADD CONSTRAINT activities_update_frequency_check
  CHECK (update_frequency IS NULL OR update_frequency IN ('weekly','monthly','quarterly','yearly','before_season','manual'));

ALTER TABLE activity_submissions DROP CONSTRAINT IF EXISTS activity_submissions_update_frequency_check;
ALTER TABLE activity_submissions ADD CONSTRAINT activity_submissions_update_frequency_check
  CHECK (update_frequency IS NULL OR update_frequency IN ('weekly','monthly','quarterly','yearly','before_season','manual'));

CREATE INDEX IF NOT EXISTS idx_activity_submissions_parent_institution
  ON activity_submissions(parent_institution_id) WHERE parent_institution_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_activity_submissions_next_update
  ON activity_submissions(next_update_at) WHERE next_update_at IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_activities_parent_institution
  ON activities(parent_institution_id) WHERE parent_institution_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_activities_next_update
  ON activities(next_update_at) WHERE next_update_at IS NOT NULL;
