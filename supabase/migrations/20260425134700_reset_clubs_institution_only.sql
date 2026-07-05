-- Les 26 clubs deviennent des "institutions" pures : pas user-facing.
-- Ils servent uniquement de point d'ancrage pour la planification.
-- Les MATCHS (créés à la maj avant saison) seront les vraies activités
-- proposées aux utilisateurs.

UPDATE activity_submissions
SET 
  -- Catégorie : 'institution' uniquement (pas event ni sport — sinon
  -- ils apparaîtraient dans les recommandations utilisateur)
  category = 'institution',
  -- Pas de contrainte temporelle (les clubs ne sont pas des activités proposables)
  recurrence_type = NULL,
  seasonal_months = NULL,
  weekly_days = NULL,
  date_label = 'Calendrier des matchs à confirmer (maj avant saison)',
  date_start = NULL,
  date_end = NULL,
  -- Retire 'Horaires restreints' : ce sont les MATCHS qui ont des horaires,
  -- pas le club lui-même
  features = array_remove(features, 'Horaires restreints'),
  -- Met à jour la note pour clarifier le workflow
  update_notes = CASE
    WHEN id BETWEEN 452 AND 463 THEN
      'Récupérer calendrier Super League 2026-27 sur sfl.ch et créer 1 activité par match (1 jour, au stade équipe à domicile)'
    ELSE
      'Récupérer calendrier National League 2026-27 sur sihf.ch et créer 1 activité par match (1 jour, à la patinoire équipe à domicile)'
  END
WHERE id BETWEEN 452 AND 477;

SELECT id, title, category, recurrence_type, date_label, features
FROM activity_submissions WHERE id IN (452, 460, 464, 469);
