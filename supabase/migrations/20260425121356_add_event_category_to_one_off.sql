-- Ajoute 'event' aux activités à dates précises (one_off avec date_start ET date_end)
UPDATE activities
SET category = CASE
  WHEN category IS NULL OR category = '' THEN 'event'
  WHEN ',' || category || ',' LIKE '%,event,%' THEN category
  ELSE category || ',event'
END
WHERE recurrence_type = 'one_off'
  AND date_start IS NOT NULL
  AND date_end IS NOT NULL;

UPDATE activity_submissions
SET category = CASE
  WHEN category IS NULL OR category = '' THEN 'event'
  WHEN ',' || category || ',' LIKE '%,event,%' THEN category
  ELSE category || ',event'
END
WHERE recurrence_type = 'one_off'
  AND date_start IS NOT NULL
  AND date_end IS NOT NULL;
