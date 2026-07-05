-- 12 clubs FOOT (Super League) : saison aoû→mai (mois 1-5 et 8-12)
UPDATE activity_submissions
SET 
  recurrence_type = 'seasonal',
  seasonal_months = ARRAY[1,2,3,4,5,8,9,10,11,12]::int[],
  date_label = 'Saison 2026-27 — prochain match à confirmer',
  features = CASE 
    WHEN NOT ('Horaires restreints' = ANY(features)) THEN array_append(features, 'Horaires restreints')
    ELSE features
  END
WHERE id BETWEEN 452 AND 463;

-- 14 clubs HOCKEY (National League) : saison sep→mars (mois 1-3 et 9-12)
UPDATE activity_submissions
SET
  recurrence_type = 'seasonal',
  seasonal_months = ARRAY[1,2,3,4,9,10,11,12]::int[],
  date_label = 'Saison 2026-27 — prochain match à confirmer',
  features = CASE 
    WHEN NOT ('Horaires restreints' = ANY(features)) THEN array_append(features, 'Horaires restreints')
    ELSE features
  END
WHERE id BETWEEN 464 AND 477;

-- Ajouter category 'event' pour qu'ils s'affichent comme événements
UPDATE activity_submissions
SET category = CASE
  WHEN ',' || category || ',' LIKE '%,event,%' THEN category
  ELSE category || ',event'
END
WHERE id BETWEEN 452 AND 477;
