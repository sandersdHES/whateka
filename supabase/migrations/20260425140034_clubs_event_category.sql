-- Les 26 clubs passent de category='institution' à category='event'.
-- Le suivi admin se fait via update_frequency='before_season' (pas la catégorie).
UPDATE activity_submissions
SET category = 'event'
WHERE id BETWEEN 452 AND 477 AND category = 'institution';
