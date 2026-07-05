-- Supprime les 22 doublons dans activities (on garde l'id le plus petit).
-- Les favorites pointant vers ces ids seront orphelines, on les nettoie aussi.
DELETE FROM favorites WHERE activity_id IN (446, 502, 513, 523, 534, 536, 538, 551, 553, 564, 565, 568, 569, 578, 581, 583, 590, 592, 593, 595, 596, 597);
DELETE FROM activities WHERE id IN (446, 502, 513, 523, 534, 536, 538, 551, 553, 564, 565, 568, 569, 578, 581, 583, 590, 592, 593, 595, 596, 597);

-- Vérification
SELECT COUNT(*) AS remaining_duplicates FROM (
  SELECT LOWER(REGEXP_REPLACE(title, '[^a-zA-Z0-9]', '', 'g')) AS norm
  FROM activities
  GROUP BY LOWER(REGEXP_REPLACE(title, '[^a-zA-Z0-9]', '', 'g'))
  HAVING COUNT(*) > 1
) t;
