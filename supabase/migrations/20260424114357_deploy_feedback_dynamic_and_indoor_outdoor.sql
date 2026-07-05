CREATE EXTENSION IF NOT EXISTS "pgcrypto";

CREATE TABLE IF NOT EXISTS feedback_questions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  questionnaire_type TEXT NOT NULL
    CHECK (questionnaire_type IN ('hot', 'cold')),
  order_index INTEGER NOT NULL DEFAULT 0,
  text TEXT NOT NULL,
  answer_format TEXT NOT NULL
    CHECK (answer_format IN ('rating_5', 'yes_no', 'text', 'multi_choice')),
  choices JSONB,
  is_required BOOLEAN NOT NULL DEFAULT true,
  is_active BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_feedback_questions_type_active
  ON feedback_questions (questionnaire_type, is_active, order_index);

CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_feedback_questions_updated_at ON feedback_questions;
CREATE TRIGGER trg_feedback_questions_updated_at
  BEFORE UPDATE ON feedback_questions
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TABLE IF NOT EXISTS feedback_submissions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  activity_id BIGINT REFERENCES activities(id) ON DELETE SET NULL,
  questionnaire_type TEXT NOT NULL
    CHECK (questionnaire_type IN ('hot', 'cold')),
  searches_count INTEGER DEFAULT 1,
  submitted_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_feedback_submissions_user
  ON feedback_submissions (user_id);
CREATE INDEX IF NOT EXISTS idx_feedback_submissions_activity
  ON feedback_submissions (activity_id);

CREATE TABLE IF NOT EXISTS feedback_answers (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  submission_id UUID NOT NULL
    REFERENCES feedback_submissions(id) ON DELETE CASCADE,
  question_id UUID NOT NULL REFERENCES feedback_questions(id),
  question_text_snapshot TEXT NOT NULL,
  question_format_snapshot TEXT NOT NULL,
  answer_rating INTEGER,
  answer_bool BOOLEAN,
  answer_text TEXT,
  answer_choice TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_feedback_answers_submission
  ON feedback_answers (submission_id);
CREATE INDEX IF NOT EXISTS idx_feedback_answers_question
  ON feedback_answers (question_id);

ALTER TABLE feedback_questions ENABLE ROW LEVEL SECURITY;
ALTER TABLE feedback_submissions ENABLE ROW LEVEL SECURITY;
ALTER TABLE feedback_answers ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Anyone can read active questions" ON feedback_questions;
CREATE POLICY "Anyone can read active questions"
  ON feedback_questions FOR SELECT
  USING (is_active = true);

DROP POLICY IF EXISTS "Authenticated users can submit feedback" ON feedback_submissions;
CREATE POLICY "Authenticated users can submit feedback"
  ON feedback_submissions FOR INSERT
  WITH CHECK (auth.uid() IS NOT NULL);

DROP POLICY IF EXISTS "Users can read their own submissions" ON feedback_submissions;
CREATE POLICY "Users can read their own submissions"
  ON feedback_submissions FOR SELECT
  USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can insert their own answers" ON feedback_answers;
CREATE POLICY "Users can insert their own answers"
  ON feedback_answers FOR INSERT
  WITH CHECK (EXISTS (
    SELECT 1 FROM feedback_submissions s
    WHERE s.id = submission_id AND s.user_id = auth.uid()
  ));

DROP POLICY IF EXISTS "Users can read their own answers" ON feedback_answers;
CREATE POLICY "Users can read their own answers"
  ON feedback_answers FOR SELECT
  USING (EXISTS (
    SELECT 1 FROM feedback_submissions s
    WHERE s.id = submission_id AND s.user_id = auth.uid()
  ));

INSERT INTO feedback_questions
  (questionnaire_type, order_index, text, answer_format, is_required)
SELECT * FROM (VALUES
  ('hot', 1,
    'La recommandation personnalisée correspond à vos attentes ?',
    'rating_5', true),
  ('hot', 2,
    'Avez-vous découvert de nouvelles activités grâce à l''application ?',
    'yes_no', true),
  ('hot', 3,
    'Le niveau de personnalisation est satisfaisant ?',
    'rating_5', true),
  ('hot', 4,
    'Le niveau d''information de l''activité est suffisant ?',
    'rating_5', true),
  ('hot', 5,
    'Avez-vous une remarque, suggestion ou autre ?',
    'text', false)
) AS v(questionnaire_type, order_index, text, answer_format, is_required)
WHERE NOT EXISTS (
  SELECT 1 FROM feedback_questions WHERE questionnaire_type = 'hot'
);

DO $$
DECLARE
  q1_id UUID; q2_id UUID; q3_id UUID; q4_id UUID; q5_id UUID;
  old_row RECORD;
  new_sub_id UUID;
  already_migrated BOOLEAN;
BEGIN
  SELECT id INTO q1_id FROM feedback_questions WHERE questionnaire_type='hot' AND order_index=1 LIMIT 1;
  SELECT id INTO q2_id FROM feedback_questions WHERE questionnaire_type='hot' AND order_index=2 LIMIT 1;
  SELECT id INTO q3_id FROM feedback_questions WHERE questionnaire_type='hot' AND order_index=3 LIMIT 1;
  SELECT id INTO q4_id FROM feedback_questions WHERE questionnaire_type='hot' AND order_index=4 LIMIT 1;
  SELECT id INTO q5_id FROM feedback_questions WHERE questionnaire_type='hot' AND order_index=5 LIMIT 1;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.tables
    WHERE table_schema = 'public' AND table_name = 'feedback_hot'
  ) THEN
    RAISE NOTICE 'Table feedback_hot absente, migration sautee.';
    RETURN;
  END IF;

  FOR old_row IN
    SELECT * FROM feedback_hot
    WHERE user_id ~* '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$'
  LOOP
    SELECT EXISTS (
      SELECT 1 FROM feedback_submissions s
      WHERE s.user_id = old_row.user_id::uuid
        AND s.activity_id = old_row.activity_id
        AND s.submitted_at = old_row.created_at
        AND s.questionnaire_type = 'hot'
    ) INTO already_migrated;

    IF already_migrated THEN
      CONTINUE;
    END IF;

    INSERT INTO feedback_submissions
      (user_id, activity_id, questionnaire_type, searches_count, submitted_at)
    VALUES
      (old_row.user_id::uuid, old_row.activity_id, 'hot',
       COALESCE(old_row.searches_count, 1),
       COALESCE(old_row.created_at, now()))
    RETURNING id INTO new_sub_id;

    INSERT INTO feedback_answers
      (submission_id, question_id, question_text_snapshot, question_format_snapshot, answer_rating)
    VALUES
      (new_sub_id, q1_id, 'La recommandation personnalisée correspond à vos attentes ?', 'rating_5', old_row.recommendation_satisfaction);

    INSERT INTO feedback_answers
      (submission_id, question_id, question_text_snapshot, question_format_snapshot, answer_bool)
    VALUES
      (new_sub_id, q2_id, 'Avez-vous découvert de nouvelles activités grâce à l''application ?', 'yes_no', old_row.discovered_new_activities);

    INSERT INTO feedback_answers
      (submission_id, question_id, question_text_snapshot, question_format_snapshot, answer_rating)
    VALUES
      (new_sub_id, q3_id, 'Le niveau de personnalisation est satisfaisant ?', 'rating_5', old_row.personalization_satisfaction);

    INSERT INTO feedback_answers
      (submission_id, question_id, question_text_snapshot, question_format_snapshot, answer_rating)
    VALUES
      (new_sub_id, q4_id, 'Le niveau d''information de l''activité est suffisant ?', 'rating_5', old_row.information_level_satisfaction);

    IF old_row.comments IS NOT NULL AND old_row.comments != '' THEN
      INSERT INTO feedback_answers
        (submission_id, question_id, question_text_snapshot, question_format_snapshot, answer_text)
      VALUES
        (new_sub_id, q5_id, 'Avez-vous une remarque, suggestion ou autre ?', 'text', old_row.comments);
    END IF;
  END LOOP;
END $$;

ALTER TABLE activities
  ADD COLUMN IF NOT EXISTS is_indoor BOOLEAN NOT NULL DEFAULT false;

UPDATE activities
   SET is_indoor = true
 WHERE is_outdoor = false
   AND is_indoor = false;

ALTER TABLE activities
  DROP CONSTRAINT IF EXISTS activities_must_be_indoor_or_outdoor;

ALTER TABLE activities
  ADD CONSTRAINT activities_must_be_indoor_or_outdoor
  CHECK (is_outdoor = true OR is_indoor = true);

CREATE INDEX IF NOT EXISTS idx_activities_is_indoor
  ON activities (is_indoor) WHERE is_indoor = true;
CREATE INDEX IF NOT EXISTS idx_activities_is_outdoor
  ON activities (is_outdoor) WHERE is_outdoor = true;
