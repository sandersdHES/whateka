ALTER TABLE activities
  ADD COLUMN IF NOT EXISTS date_label TEXT,
  ADD COLUMN IF NOT EXISTS date_start DATE,
  ADD COLUMN IF NOT EXISTS date_end DATE,
  ADD COLUMN IF NOT EXISTS recurrence_type TEXT,
  ADD COLUMN IF NOT EXISTS seasonal_months INT[],
  ADD COLUMN IF NOT EXISTS weekly_days INT[];

ALTER TABLE activity_submissions
  ADD COLUMN IF NOT EXISTS date_label TEXT,
  ADD COLUMN IF NOT EXISTS date_start DATE,
  ADD COLUMN IF NOT EXISTS date_end DATE,
  ADD COLUMN IF NOT EXISTS recurrence_type TEXT,
  ADD COLUMN IF NOT EXISTS seasonal_months INT[],
  ADD COLUMN IF NOT EXISTS weekly_days INT[];

ALTER TABLE activities
  DROP CONSTRAINT IF EXISTS activities_recurrence_type_check;
ALTER TABLE activities
  ADD CONSTRAINT activities_recurrence_type_check
  CHECK (recurrence_type IS NULL OR recurrence_type IN ('one_off','weekly','seasonal'));

ALTER TABLE activity_submissions
  DROP CONSTRAINT IF EXISTS activity_submissions_recurrence_type_check;
ALTER TABLE activity_submissions
  ADD CONSTRAINT activity_submissions_recurrence_type_check
  CHECK (recurrence_type IS NULL OR recurrence_type IN ('one_off','weekly','seasonal'));

CREATE INDEX IF NOT EXISTS idx_activities_date_end ON activities(date_end) WHERE date_end IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_activities_recurrence ON activities(recurrence_type) WHERE recurrence_type IS NOT NULL;
