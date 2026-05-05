-- Whateka — Migration 0005 : seed 150 activites VD/VS
-- ============================================================
-- 150 activites reelles (Vaud + Valais) inserees comme
-- soumissions a valider (status='pending'). Source : Google/
-- TripAdvisor avec notes >= 4.0.
-- 
-- Champs enrichis : activity_url (officiel), location_zone (VS),
-- date_label/date_start/date_end/recurrence_type/seasonal_months
-- pour les events et activites saisonnieres.
-- 
-- Idempotent : WHERE NOT EXISTS sur (title, location_name) dans
-- les deux tables (activity_submissions + activities).
-- ============================================================

-- Tour de Sauvabelin
INSERT INTO activity_submissions (
  title, location_name, category, description,
  latitude, longitude, duration_minutes, price_level,
  features, seasons, social_tags,
  is_indoor, is_outdoor,
  activity_url, image_url, location_zone,
  date_label, date_label_en, date_start, date_end,
  recurrence_type, seasonal_months, weekly_days,
  status, submitted_by
)
SELECT
  'Tour de Sauvabelin',
  'Lausanne',
  'nature',
  'Tour en bois de 35m offrant une vue 360° sur Lausanne, le Léman et les Alpes. Ascension gratuite par escalier en colimaçon.',
  46.54, 6.65,
  60, 1,
  ARRAY['Parking'],
  ARRAY['Printemps','Été','Automne','Hiver'],
  ARRAY['Famille','Couple','Solo','Amis'],
  false, true,
  'https://www.lausanne.ch/officiel/administration/sports-et-cohesion-sociale/service-des-parcs-et-domaines/parcs-promenades/tour-de-sauvabelin.html', NULL, NULL,
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Tour de Sauvabelin' AND location_name = 'Lausanne'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Tour de Sauvabelin' AND location_name = 'Lausanne'
);

-- Lavaux Vinorama
INSERT INTO activity_submissions (
  title, location_name, category, description,
  latitude, longitude, duration_minutes, price_level,
  features, seasons, social_tags,
  is_indoor, is_outdoor,
  activity_url, image_url, location_zone,
  date_label, date_label_en, date_start, date_end,
  recurrence_type, seasonal_months, weekly_days,
  status, submitted_by
)
SELECT
  'Lavaux Vinorama',
  'Rivaz',
  'nature',
  'Centre de découverte des vins de Lavaux, classés UNESCO. Dégustation de 290 vins issus de 165 vignerons.',
  46.4794, 6.7717,
  90, 3,
  ARRAY['Parking','Reservation necessaire'],
  ARRAY['Printemps','Été','Automne'],
  ARRAY['Couple','Amis'],
  true, false,
  'https://www.lavaux-vinorama.ch', NULL, NULL,
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Lavaux Vinorama' AND location_name = 'Rivaz'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Lavaux Vinorama' AND location_name = 'Rivaz'
);

-- Sentier des Vignerons Lavaux
INSERT INTO activity_submissions (
  title, location_name, category, description,
  latitude, longitude, duration_minutes, price_level,
  features, seasons, social_tags,
  is_indoor, is_outdoor,
  activity_url, image_url, location_zone,
  date_label, date_label_en, date_start, date_end,
  recurrence_type, seasonal_months, weekly_days,
  status, submitted_by
)
SELECT
  'Sentier des Vignerons Lavaux',
  'Lutry',
  'nature',
  'Randonnée de 11 km à travers les terrasses viticoles UNESCO, de Lutry à Saint-Saphorin. Vues spectaculaires sur le Léman.',
  46.5042, 6.6856,
  240, 1,
  ARRAY['Parking'],
  ARRAY['Printemps','Été','Automne'],
  ARRAY['Couple','Famille','Amis'],
  false, true,
  'https://www.montreuxriviera.com/fr/P38019/sentier-des-vignerons', NULL, NULL,
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Sentier des Vignerons Lavaux' AND location_name = 'Lutry'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Sentier des Vignerons Lavaux' AND location_name = 'Lutry'
);

-- Rochers-de-Naye
INSERT INTO activity_submissions (
  title, location_name, category, description,
  latitude, longitude, duration_minutes, price_level,
  features, seasons, social_tags,
  is_indoor, is_outdoor,
  activity_url, image_url, location_zone,
  date_label, date_label_en, date_start, date_end,
  recurrence_type, seasonal_months, weekly_days,
  status, submitted_by
)
SELECT
  'Rochers-de-Naye',
  'Montreux',
  'nature',
  'Sommet à 2042m accessible en train à crémaillère depuis Montreux. Marmottes paradise, vue Léman + Alpes.',
  46.4286, 6.9764,
  240, 4,
  ARRAY['Reservation necessaire','Horaires restreints'],
  ARRAY['Été','Automne'],
  ARRAY['Famille','Couple','Amis'],
  false, true,
  'https://www.goldenpass.ch/fr/excursions/rochers-de-naye', NULL, NULL,
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Rochers-de-Naye' AND location_name = 'Montreux'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Rochers-de-Naye' AND location_name = 'Montreux'
);

-- Lac de Bret
INSERT INTO activity_submissions (
  title, location_name, category, description,
  latitude, longitude, duration_minutes, price_level,
  features, seasons, social_tags,
  is_indoor, is_outdoor,
  activity_url, image_url, location_zone,
  date_label, date_label_en, date_start, date_end,
  recurrence_type, seasonal_months, weekly_days,
  status, submitted_by
)
SELECT
  'Lac de Bret',
  'Puidoux',
  'nature',
  'Petit lac glaciaire entouré de forêts. Sentier pédestre 3 km, baignade interdite mais idéal pour pique-nique.',
  46.5208, 6.8044,
  90, 1,
  ARRAY['Parking'],
  ARRAY['Printemps','Été','Automne'],
  ARRAY['Famille','Couple','Solo'],
  false, true,
  NULL, NULL, NULL,
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Lac de Bret' AND location_name = 'Puidoux'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Lac de Bret' AND location_name = 'Puidoux'
);

-- Mont Pèlerin
INSERT INTO activity_submissions (
  title, location_name, category, description,
  latitude, longitude, duration_minutes, price_level,
  features, seasons, social_tags,
  is_indoor, is_outdoor,
  activity_url, image_url, location_zone,
  date_label, date_label_en, date_start, date_end,
  recurrence_type, seasonal_months, weekly_days,
  status, submitted_by
)
SELECT
  'Mont Pèlerin',
  'Chardonne',
  'nature',
  'Funiculaire vers ce sommet de 1080m. Vue panoramique sur le Léman, Plein Ciel restaurant au sommet.',
  46.4769, 6.8597,
  120, 3,
  ARRAY['Parking'],
  ARRAY['Printemps','Été','Automne','Hiver'],
  ARRAY['Couple','Famille'],
  false, true,
  'https://www.mob.ch/lignes-train/funiculaire-vevey-mont-pelerin/', NULL, NULL,
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Mont Pèlerin' AND location_name = 'Chardonne'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Mont Pèlerin' AND location_name = 'Chardonne'
);

-- Bois du Jorat
INSERT INTO activity_submissions (
  title, location_name, category, description,
  latitude, longitude, duration_minutes, price_level,
  features, seasons, social_tags,
  is_indoor, is_outdoor,
  activity_url, image_url, location_zone,
  date_label, date_label_en, date_start, date_end,
  recurrence_type, seasonal_months, weekly_days,
  status, submitted_by
)
SELECT
  'Bois du Jorat',
  'Lausanne',
  'nature',
  'Forêt de 25 km² au nord de Lausanne avec sentiers balisés, parcours VTT et points de vue. Idéal pour la déconnexion.',
  46.5778, 6.6694,
  180, 1,
  ARRAY['Parking'],
  ARRAY['Printemps','Été','Automne'],
  ARRAY['Famille','Solo','Amis'],
  false, true,
  NULL, NULL, NULL,
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Bois du Jorat' AND location_name = 'Lausanne'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Bois du Jorat' AND location_name = 'Lausanne'
);

-- Lac de Joux
INSERT INTO activity_submissions (
  title, location_name, category, description,
  latitude, longitude, duration_minutes, price_level,
  features, seasons, social_tags,
  is_indoor, is_outdoor,
  activity_url, image_url, location_zone,
  date_label, date_label_en, date_start, date_end,
  recurrence_type, seasonal_months, weekly_days,
  status, submitted_by
)
SELECT
  'Lac de Joux',
  'Le Pont',
  'nature',
  'Plus grand lac du Jura. Baignade en été, ski de fond et patin à glace l''hiver. Vue spectaculaire sur les sommets.',
  46.6722, 6.3278,
  240, 2,
  ARRAY['Parking'],
  ARRAY['Printemps','Été','Automne','Hiver'],
  ARRAY['Famille','Couple','Amis'],
  false, true,
  'https://www.myvalleedejoux.ch', NULL, NULL,
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Lac de Joux' AND location_name = 'Le Pont'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Lac de Joux' AND location_name = 'Le Pont'
);

-- Réserve naturelle des Grangettes
INSERT INTO activity_submissions (
  title, location_name, category, description,
  latitude, longitude, duration_minutes, price_level,
  features, seasons, social_tags,
  is_indoor, is_outdoor,
  activity_url, image_url, location_zone,
  date_label, date_label_en, date_start, date_end,
  recurrence_type, seasonal_months, weekly_days,
  status, submitted_by
)
SELECT
  'Réserve naturelle des Grangettes',
  'Noville',
  'nature',
  'Plus grande zone humide de Suisse romande. 330 ha de roselières, observation des oiseaux migrateurs.',
  46.3833, 6.8667,
  180, 1,
  ARRAY['Parking'],
  ARRAY['Printemps','Été','Automne'],
  ARRAY['Famille','Solo','Couple'],
  false, true,
  'https://www.grangettes.ch', NULL, NULL,
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Réserve naturelle des Grangettes' AND location_name = 'Noville'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Réserve naturelle des Grangettes' AND location_name = 'Noville'
);

-- Glacier 3000
INSERT INTO activity_submissions (
  title, location_name, category, description,
  latitude, longitude, duration_minutes, price_level,
  features, seasons, social_tags,
  is_indoor, is_outdoor,
  activity_url, image_url, location_zone,
  date_label, date_label_en, date_start, date_end,
  recurrence_type, seasonal_months, weekly_days,
  status, submitted_by
)
SELECT
  'Glacier 3000',
  'Les Diablerets',
  'nature',
  'Glacier accessible en téléphérique, peak walk by Tissot (pont suspendu entre 2 sommets). Vue Mont-Blanc + Cervin.',
  46.3556, 7.2125,
  240, 5,
  ARRAY['Parking','Reservation necessaire'],
  ARRAY['Été','Automne','Hiver'],
  ARRAY['Couple','Amis','Famille'],
  false, true,
  'https://www.glacier3000.ch', NULL, NULL,
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Glacier 3000' AND location_name = 'Les Diablerets'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Glacier 3000' AND location_name = 'Les Diablerets'
);

-- Mont Tendre
INSERT INTO activity_submissions (
  title, location_name, category, description,
  latitude, longitude, duration_minutes, price_level,
  features, seasons, social_tags,
  is_indoor, is_outdoor,
  activity_url, image_url, location_zone,
  date_label, date_label_en, date_start, date_end,
  recurrence_type, seasonal_months, weekly_days,
  status, submitted_by
)
SELECT
  'Mont Tendre',
  'Vallée de Joux',
  'nature',
  'Plus haut sommet du Jura suisse (1679m). Randonnée de 4h depuis Le Pont, panorama exceptionnel sur les Alpes.',
  46.6017, 6.3186,
  360, 1,
  ARRAY['Parking'],
  ARRAY['Printemps','Été','Automne'],
  ARRAY['Solo','Amis','Couple'],
  false, true,
  NULL, NULL, NULL,
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Mont Tendre' AND location_name = 'Vallée de Joux'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Mont Tendre' AND location_name = 'Vallée de Joux'
);

-- Bois de Chênes
INSERT INTO activity_submissions (
  title, location_name, category, description,
  latitude, longitude, duration_minutes, price_level,
  features, seasons, social_tags,
  is_indoor, is_outdoor,
  activity_url, image_url, location_zone,
  date_label, date_label_en, date_start, date_end,
  recurrence_type, seasonal_months, weekly_days,
  status, submitted_by
)
SELECT
  'Bois de Chênes',
  'Genolier',
  'nature',
  'Réserve naturelle avec une chênaie centenaire. Sentier didactique de 2h sur les arbres et la biodiversité.',
  46.4456, 6.2306,
  120, 1,
  ARRAY['Parking'],
  ARRAY['Printemps','Été','Automne'],
  ARRAY['Famille','Solo'],
  false, true,
  NULL, NULL, NULL,
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Bois de Chênes' AND location_name = 'Genolier'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Bois de Chênes' AND location_name = 'Genolier'
);

-- Plage de Préverenges
INSERT INTO activity_submissions (
  title, location_name, category, description,
  latitude, longitude, duration_minutes, price_level,
  features, seasons, social_tags,
  is_indoor, is_outdoor,
  activity_url, image_url, location_zone,
  date_label, date_label_en, date_start, date_end,
  recurrence_type, seasonal_months, weekly_days,
  status, submitted_by
)
SELECT
  'Plage de Préverenges',
  'Préverenges',
  'nature',
  'Plage de sable au bord du Léman, vue Mont-Blanc. Lieu de migration des oiseaux. Baignade et pique-nique.',
  46.5092, 6.5269,
  120, 1,
  ARRAY['Parking'],
  ARRAY['Printemps','Été'],
  ARRAY['Famille','Couple','Amis'],
  false, true,
  NULL, NULL, NULL,
  NULL, NULL, NULL, NULL,
  'seasonal', ARRAY[5,6,7,8,9]::int[], NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Plage de Préverenges' AND location_name = 'Préverenges'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Plage de Préverenges' AND location_name = 'Préverenges'
);

-- Tour d'Aï
INSERT INTO activity_submissions (
  title, location_name, category, description,
  latitude, longitude, duration_minutes, price_level,
  features, seasons, social_tags,
  is_indoor, is_outdoor,
  activity_url, image_url, location_zone,
  date_label, date_label_en, date_start, date_end,
  recurrence_type, seasonal_months, weekly_days,
  status, submitted_by
)
SELECT
  'Tour d''Aï',
  'Leysin',
  'nature',
  'Sommet rocheux de 2331m au-dessus de Leysin. Randonnée alpine technique avec vue Dents du Midi + Mont-Blanc.',
  46.3517, 7.0153,
  360, 1,
  ARRAY['Reservation necessaire'],
  ARRAY['Été','Automne'],
  ARRAY['Solo','Amis','Couple'],
  false, true,
  NULL, NULL, NULL,
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Tour d''Aï' AND location_name = 'Leysin'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Tour d''Aï' AND location_name = 'Leysin'
);

-- Forêt du Risoud
INSERT INTO activity_submissions (
  title, location_name, category, description,
  latitude, longitude, duration_minutes, price_level,
  features, seasons, social_tags,
  is_indoor, is_outdoor,
  activity_url, image_url, location_zone,
  date_label, date_label_en, date_start, date_end,
  recurrence_type, seasonal_months, weekly_days,
  status, submitted_by
)
SELECT
  'Forêt du Risoud',
  'Vallée de Joux',
  'nature',
  'Plus grande forêt continue de Suisse, célèbre pour son bois de résonance utilisé en lutherie. Sentier des géants.',
  46.6444, 6.2944,
  180, 1,
  ARRAY['Parking'],
  ARRAY['Printemps','Été','Automne'],
  ARRAY['Famille','Solo','Couple'],
  false, true,
  'https://www.myvalleedejoux.ch/fr/N1410/le-risoud', NULL, NULL,
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Forêt du Risoud' AND location_name = 'Vallée de Joux'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Forêt du Risoud' AND location_name = 'Vallée de Joux'
);

-- Musée Olympique
INSERT INTO activity_submissions (
  title, location_name, category, description,
  latitude, longitude, duration_minutes, price_level,
  features, seasons, social_tags,
  is_indoor, is_outdoor,
  activity_url, image_url, location_zone,
  date_label, date_label_en, date_start, date_end,
  recurrence_type, seasonal_months, weekly_days,
  status, submitted_by
)
SELECT
  'Musée Olympique',
  'Lausanne',
  'culture',
  'Musée incontournable des Jeux Olympiques. Collections, films, expositions interactives. Note Google : 4.6/5.',
  46.5078, 6.6336,
  180, 4,
  ARRAY['Parking','Horaires restreints'],
  ARRAY['Printemps','Été','Automne','Hiver'],
  ARRAY['Famille','Couple','Solo','Amis'],
  true, false,
  'https://olympics.com/musee', NULL, NULL,
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Musée Olympique' AND location_name = 'Lausanne'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Musée Olympique' AND location_name = 'Lausanne'
);

-- Cathédrale Notre-Dame de Lausanne
INSERT INTO activity_submissions (
  title, location_name, category, description,
  latitude, longitude, duration_minutes, price_level,
  features, seasons, social_tags,
  is_indoor, is_outdoor,
  activity_url, image_url, location_zone,
  date_label, date_label_en, date_start, date_end,
  recurrence_type, seasonal_months, weekly_days,
  status, submitted_by
)
SELECT
  'Cathédrale Notre-Dame de Lausanne',
  'Lausanne',
  'culture',
  'Joyau gothique du XIIIe siècle. Le veilleur de nuit crie chaque heure de 22h à 2h. Tours offrant vue panoramique.',
  46.5228, 6.6353,
  90, 1,
  ARRAY[]::text[],
  ARRAY['Printemps','Été','Automne','Hiver'],
  ARRAY['Couple','Solo','Famille'],
  true, false,
  'https://www.cathedrale-lausanne.ch', NULL, NULL,
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Cathédrale Notre-Dame de Lausanne' AND location_name = 'Lausanne'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Cathédrale Notre-Dame de Lausanne' AND location_name = 'Lausanne'
);

-- Plateforme 10
INSERT INTO activity_submissions (
  title, location_name, category, description,
  latitude, longitude, duration_minutes, price_level,
  features, seasons, social_tags,
  is_indoor, is_outdoor,
  activity_url, image_url, location_zone,
  date_label, date_label_en, date_start, date_end,
  recurrence_type, seasonal_months, weekly_days,
  status, submitted_by
)
SELECT
  'Plateforme 10',
  'Lausanne',
  'culture',
  'Pôle muséal regroupant MCBA, Photo Élysée et mudac. Collections d''art contemporain et photographie.',
  46.5169, 6.6294,
  180, 4,
  ARRAY['Horaires restreints'],
  ARRAY['Printemps','Été','Automne','Hiver'],
  ARRAY['Couple','Solo','Amis'],
  true, false,
  'https://plateforme10.ch', NULL, NULL,
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Plateforme 10' AND location_name = 'Lausanne'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Plateforme 10' AND location_name = 'Lausanne'
);

-- Château de Chillon
INSERT INTO activity_submissions (
  title, location_name, category, description,
  latitude, longitude, duration_minutes, price_level,
  features, seasons, social_tags,
  is_indoor, is_outdoor,
  activity_url, image_url, location_zone,
  date_label, date_label_en, date_start, date_end,
  recurrence_type, seasonal_months, weekly_days,
  status, submitted_by
)
SELECT
  'Château de Chillon',
  'Veytaux',
  'culture',
  'Château médiéval sur le Léman, plus visité de Suisse. Forteresse savoyarde du XIIIe siècle. 4.6/5 sur Google.',
  46.4144, 6.9275,
  150, 3,
  ARRAY['Parking','Reservation necessaire'],
  ARRAY['Printemps','Été','Automne','Hiver'],
  ARRAY['Famille','Couple','Solo','Amis'],
  true, false,
  'https://www.chillon.ch', 'https://upload.wikimedia.org/wikipedia/commons/thumb/2/2e/Chillon_Castle.jpg/1280px-Chillon_Castle.jpg', NULL,
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Château de Chillon' AND location_name = 'Veytaux'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Château de Chillon' AND location_name = 'Veytaux'
);

-- Chaplin's World
INSERT INTO activity_submissions (
  title, location_name, category, description,
  latitude, longitude, duration_minutes, price_level,
  features, seasons, social_tags,
  is_indoor, is_outdoor,
  activity_url, image_url, location_zone,
  date_label, date_label_en, date_start, date_end,
  recurrence_type, seasonal_months, weekly_days,
  status, submitted_by
)
SELECT
  'Chaplin''s World',
  'Corsier-sur-Vevey',
  'culture',
  'Musée immersif dédié à Charlie Chaplin dans son ancienne demeure. Studios reconstitués. Note 4.5/5.',
  46.4847, 6.8633,
  180, 4,
  ARRAY['Parking','Reservation necessaire'],
  ARRAY['Printemps','Été','Automne','Hiver'],
  ARRAY['Famille','Couple','Solo','Amis'],
  true, false,
  'https://www.chaplinsworld.com', NULL, NULL,
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Chaplin''s World' AND location_name = 'Corsier-sur-Vevey'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Chaplin''s World' AND location_name = 'Corsier-sur-Vevey'
);

-- Alimentarium
INSERT INTO activity_submissions (
  title, location_name, category, description,
  latitude, longitude, duration_minutes, price_level,
  features, seasons, social_tags,
  is_indoor, is_outdoor,
  activity_url, image_url, location_zone,
  date_label, date_label_en, date_start, date_end,
  recurrence_type, seasonal_months, weekly_days,
  status, submitted_by
)
SELECT
  'Alimentarium',
  'Vevey',
  'culture',
  'Premier musée au monde consacré à l''alimentation. Expositions interactives, cours de cuisine.',
  46.4647, 6.8472,
  150, 3,
  ARRAY['Reservation necessaire'],
  ARRAY['Printemps','Été','Automne','Hiver'],
  ARRAY['Famille','Solo','Couple'],
  true, false,
  'https://www.alimentarium.org', NULL, NULL,
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Alimentarium' AND location_name = 'Vevey'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Alimentarium' AND location_name = 'Vevey'
);

-- Musée suisse du jeu
INSERT INTO activity_submissions (
  title, location_name, category, description,
  latitude, longitude, duration_minutes, price_level,
  features, seasons, social_tags,
  is_indoor, is_outdoor,
  activity_url, image_url, location_zone,
  date_label, date_label_en, date_start, date_end,
  recurrence_type, seasonal_months, weekly_days,
  status, submitted_by
)
SELECT
  'Musée suisse du jeu',
  'La Tour-de-Peilz',
  'culture',
  'Au château de La Tour-de-Peilz : 700 jeux du monde entier, possibilité d''y jouer. Idéal famille.',
  46.4575, 6.8589,
  120, 2,
  ARRAY['Reservation necessaire'],
  ARRAY['Printemps','Été','Automne','Hiver'],
  ARRAY['Famille','Amis'],
  true, false,
  'https://www.museedujeu.ch', NULL, NULL,
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Musée suisse du jeu' AND location_name = 'La Tour-de-Peilz'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Musée suisse du jeu' AND location_name = 'La Tour-de-Peilz'
);

-- Site romain d'Avenches
INSERT INTO activity_submissions (
  title, location_name, category, description,
  latitude, longitude, duration_minutes, price_level,
  features, seasons, social_tags,
  is_indoor, is_outdoor,
  activity_url, image_url, location_zone,
  date_label, date_label_en, date_start, date_end,
  recurrence_type, seasonal_months, weekly_days,
  status, submitted_by
)
SELECT
  'Site romain d''Avenches',
  'Avenches',
  'culture',
  'Ancienne capitale de l''Helvétie romaine. Théâtre antique, amphithéâtre, musée romain. Site UNESCO en lice.',
  46.8819, 7.0431,
  180, 1,
  ARRAY['Parking'],
  ARRAY['Printemps','Été','Automne'],
  ARRAY['Famille','Solo','Couple'],
  false, true,
  'https://www.aventicum.org', NULL, NULL,
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Site romain d''Avenches' AND location_name = 'Avenches'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Site romain d''Avenches' AND location_name = 'Avenches'
);

-- Château de Grandson
INSERT INTO activity_submissions (
  title, location_name, category, description,
  latitude, longitude, duration_minutes, price_level,
  features, seasons, social_tags,
  is_indoor, is_outdoor,
  activity_url, image_url, location_zone,
  date_label, date_label_en, date_start, date_end,
  recurrence_type, seasonal_months, weekly_days,
  status, submitted_by
)
SELECT
  'Château de Grandson',
  'Grandson',
  'culture',
  'Forteresse médiévale du XIe siècle. Salle des chevaliers, expositions sur la bataille de 1476.',
  46.8128, 6.6433,
  90, 2,
  ARRAY['Parking'],
  ARRAY['Printemps','Été','Automne'],
  ARRAY['Famille','Couple','Solo'],
  true, false,
  'https://www.chateau-grandson.ch', NULL, NULL,
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Château de Grandson' AND location_name = 'Grandson'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Château de Grandson' AND location_name = 'Grandson'
);

-- Château d'Aigle (Musée du vin)
INSERT INTO activity_submissions (
  title, location_name, category, description,
  latitude, longitude, duration_minutes, price_level,
  features, seasons, social_tags,
  is_indoor, is_outdoor,
  activity_url, image_url, location_zone,
  date_label, date_label_en, date_start, date_end,
  recurrence_type, seasonal_months, weekly_days,
  status, submitted_by
)
SELECT
  'Château d''Aigle (Musée du vin)',
  'Aigle',
  'culture',
  'Château du XIIe siècle abritant le Musée de la vigne et du vin. Dégustations possibles.',
  46.3192, 6.9697,
  120, 2,
  ARRAY['Parking'],
  ARRAY['Printemps','Été','Automne'],
  ARRAY['Couple','Solo','Amis'],
  true, false,
  'https://www.chateauaigle.ch', NULL, NULL,
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Château d''Aigle (Musée du vin)' AND location_name = 'Aigle'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Château d''Aigle (Musée du vin)' AND location_name = 'Aigle'
);

-- Collection de l'Art Brut
INSERT INTO activity_submissions (
  title, location_name, category, description,
  latitude, longitude, duration_minutes, price_level,
  features, seasons, social_tags,
  is_indoor, is_outdoor,
  activity_url, image_url, location_zone,
  date_label, date_label_en, date_start, date_end,
  recurrence_type, seasonal_months, weekly_days,
  status, submitted_by
)
SELECT
  'Collection de l''Art Brut',
  'Lausanne',
  'culture',
  'Musée unique au monde dédié à l''art brut, créé par Jean Dubuffet en 1976. 70 000 oeuvres d''auteurs en marge.',
  46.5278, 6.6217,
  120, 2,
  ARRAY['Horaires restreints'],
  ARRAY['Printemps','Été','Automne','Hiver'],
  ARRAY['Solo','Couple'],
  true, false,
  'https://www.artbrut.ch', NULL, NULL,
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Collection de l''Art Brut' AND location_name = 'Lausanne'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Collection de l''Art Brut' AND location_name = 'Lausanne'
);

-- Musée romain de Lausanne-Vidy
INSERT INTO activity_submissions (
  title, location_name, category, description,
  latitude, longitude, duration_minutes, price_level,
  features, seasons, social_tags,
  is_indoor, is_outdoor,
  activity_url, image_url, location_zone,
  date_label, date_label_en, date_start, date_end,
  recurrence_type, seasonal_months, weekly_days,
  status, submitted_by
)
SELECT
  'Musée romain de Lausanne-Vidy',
  'Lausanne',
  'culture',
  'Musée sur l''ancienne ville romaine de Lousonna. Mosaïques, statues, vie quotidienne dans l''antiquité.',
  46.5181, 6.5928,
  90, 1,
  ARRAY['Parking'],
  ARRAY['Printemps','Été','Automne'],
  ARRAY['Famille','Solo'],
  true, false,
  'https://www.lausanne.ch/mrv', NULL, NULL,
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Musée romain de Lausanne-Vidy' AND location_name = 'Lausanne'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Musée romain de Lausanne-Vidy' AND location_name = 'Lausanne'
);

-- Musée Jenisch
INSERT INTO activity_submissions (
  title, location_name, category, description,
  latitude, longitude, duration_minutes, price_level,
  features, seasons, social_tags,
  is_indoor, is_outdoor,
  activity_url, image_url, location_zone,
  date_label, date_label_en, date_start, date_end,
  recurrence_type, seasonal_months, weekly_days,
  status, submitted_by
)
SELECT
  'Musée Jenisch',
  'Vevey',
  'culture',
  'Musée d''art consacré aux estampes et au dessin, plus ancien musée des beaux-arts du canton (1897).',
  46.4647, 6.85,
  90, 2,
  ARRAY[]::text[],
  ARRAY['Printemps','Été','Automne','Hiver'],
  ARRAY['Solo','Couple'],
  true, false,
  'https://www.museejenisch.ch', NULL, NULL,
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Musée Jenisch' AND location_name = 'Vevey'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Musée Jenisch' AND location_name = 'Vevey'
);

-- Musée historique de Vevey
INSERT INTO activity_submissions (
  title, location_name, category, description,
  latitude, longitude, duration_minutes, price_level,
  features, seasons, social_tags,
  is_indoor, is_outdoor,
  activity_url, image_url, location_zone,
  date_label, date_label_en, date_start, date_end,
  recurrence_type, seasonal_months, weekly_days,
  status, submitted_by
)
SELECT
  'Musée historique de Vevey',
  'Vevey',
  'culture',
  'Au château de l''Aile : histoire de la région, salle Brel, brasserie d''antan reconstituée.',
  46.4625, 6.8458,
  90, 2,
  ARRAY[]::text[],
  ARRAY['Printemps','Été','Automne','Hiver'],
  ARRAY['Solo','Famille'],
  true, false,
  'https://www.museehistoriquevevey.ch', NULL, NULL,
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Musée historique de Vevey' AND location_name = 'Vevey'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Musée historique de Vevey' AND location_name = 'Vevey'
);

-- Maison d'Ailleurs
INSERT INTO activity_submissions (
  title, location_name, category, description,
  latitude, longitude, duration_minutes, price_level,
  features, seasons, social_tags,
  is_indoor, is_outdoor,
  activity_url, image_url, location_zone,
  date_label, date_label_en, date_start, date_end,
  recurrence_type, seasonal_months, weekly_days,
  status, submitted_by
)
SELECT
  'Maison d''Ailleurs',
  'Yverdon-les-Bains',
  'culture',
  'Musée de la science-fiction, de l''utopie et des voyages extraordinaires. Unique en Europe, 4.4/5.',
  46.7783, 6.6406,
  120, 2,
  ARRAY[]::text[],
  ARRAY['Printemps','Été','Automne','Hiver'],
  ARRAY['Famille','Solo','Amis'],
  true, false,
  'https://www.ailleurs.ch', NULL, NULL,
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Maison d''Ailleurs' AND location_name = 'Yverdon-les-Bains'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Maison d''Ailleurs' AND location_name = 'Yverdon-les-Bains'
);

-- Restaurant Anne-Sophie Pic au Beau-Rivage
INSERT INTO activity_submissions (
  title, location_name, category, description,
  latitude, longitude, duration_minutes, price_level,
  features, seasons, social_tags,
  is_indoor, is_outdoor,
  activity_url, image_url, location_zone,
  date_label, date_label_en, date_start, date_end,
  recurrence_type, seasonal_months, weekly_days,
  status, submitted_by
)
SELECT
  'Restaurant Anne-Sophie Pic au Beau-Rivage',
  'Lausanne',
  'gastronomy',
  'Restaurant 3 étoiles Michelin de la chef la plus étoilée au monde. Expérience d''exception.',
  46.5097, 6.6361,
  240, 5,
  ARRAY['Reservation necessaire'],
  ARRAY['Printemps','Été','Automne','Hiver'],
  ARRAY['Couple','Amis'],
  true, false,
  'https://www.brp.ch/fr/restaurants-bars/anne-sophie-pic', NULL, NULL,
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Restaurant Anne-Sophie Pic au Beau-Rivage' AND location_name = 'Lausanne'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Restaurant Anne-Sophie Pic au Beau-Rivage' AND location_name = 'Lausanne'
);

-- Caveau de Lavaux
INSERT INTO activity_submissions (
  title, location_name, category, description,
  latitude, longitude, duration_minutes, price_level,
  features, seasons, social_tags,
  is_indoor, is_outdoor,
  activity_url, image_url, location_zone,
  date_label, date_label_en, date_start, date_end,
  recurrence_type, seasonal_months, weekly_days,
  status, submitted_by
)
SELECT
  'Caveau de Lavaux',
  'Cully',
  'gastronomy',
  'Bar à vins coopératif gérant la cave communale. Plus de 50 vins de Lavaux à déguster.',
  46.49, 6.7333,
  120, 3,
  ARRAY['Reservation necessaire','Horaires restreints'],
  ARRAY['Printemps','Été','Automne','Hiver'],
  ARRAY['Couple','Amis'],
  true, false,
  'https://www.caveau-cully.ch', NULL, NULL,
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Caveau de Lavaux' AND location_name = 'Cully'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Caveau de Lavaux' AND location_name = 'Cully'
);

-- Brasserie La Bavaria
INSERT INTO activity_submissions (
  title, location_name, category, description,
  latitude, longitude, duration_minutes, price_level,
  features, seasons, social_tags,
  is_indoor, is_outdoor,
  activity_url, image_url, location_zone,
  date_label, date_label_en, date_start, date_end,
  recurrence_type, seasonal_months, weekly_days,
  status, submitted_by
)
SELECT
  'Brasserie La Bavaria',
  'Lausanne',
  'gastronomy',
  'Institution lausannoise depuis 1908. Cuisine bistro suisse-bavaroise dans un décor Belle Époque.',
  46.5217, 6.6328,
  120, 3,
  ARRAY[]::text[],
  ARRAY['Printemps','Été','Automne','Hiver'],
  ARRAY['Famille','Couple','Amis'],
  true, false,
  'https://www.bavaria-lausanne.ch', NULL, NULL,
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Brasserie La Bavaria' AND location_name = 'Lausanne'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Brasserie La Bavaria' AND location_name = 'Lausanne'
);

-- Le Pavé
INSERT INTO activity_submissions (
  title, location_name, category, description,
  latitude, longitude, duration_minutes, price_level,
  features, seasons, social_tags,
  is_indoor, is_outdoor,
  activity_url, image_url, location_zone,
  date_label, date_label_en, date_start, date_end,
  recurrence_type, seasonal_months, weekly_days,
  status, submitted_by
)
SELECT
  'Le Pavé',
  'Lausanne',
  'gastronomy',
  'Restaurant néo-bistro plébiscité, cuisine du marché. Service convivial dans un cadre intime.',
  46.5217, 6.63,
  120, 3,
  ARRAY['Reservation necessaire'],
  ARRAY['Printemps','Été','Automne','Hiver'],
  ARRAY['Couple','Amis'],
  true, false,
  NULL, NULL, NULL,
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Le Pavé' AND location_name = 'Lausanne'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Le Pavé' AND location_name = 'Lausanne'
);

-- Café Romand
INSERT INTO activity_submissions (
  title, location_name, category, description,
  latitude, longitude, duration_minutes, price_level,
  features, seasons, social_tags,
  is_indoor, is_outdoor,
  activity_url, image_url, location_zone,
  date_label, date_label_en, date_start, date_end,
  recurrence_type, seasonal_months, weekly_days,
  status, submitted_by
)
SELECT
  'Café Romand',
  'Lausanne',
  'gastronomy',
  'Brasserie historique depuis 1951. Spécialités vaudoises : papet, fondue, malakoff. Atmosphère traditionnelle.',
  46.5197, 6.6328,
  120, 2,
  ARRAY[]::text[],
  ARRAY['Printemps','Été','Automne','Hiver'],
  ARRAY['Famille','Amis','Couple'],
  true, false,
  'https://www.caferomand.ch', NULL, NULL,
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Café Romand' AND location_name = 'Lausanne'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Café Romand' AND location_name = 'Lausanne'
);

-- La Croix d'Or
INSERT INTO activity_submissions (
  title, location_name, category, description,
  latitude, longitude, duration_minutes, price_level,
  features, seasons, social_tags,
  is_indoor, is_outdoor,
  activity_url, image_url, location_zone,
  date_label, date_label_en, date_start, date_end,
  recurrence_type, seasonal_months, weekly_days,
  status, submitted_by
)
SELECT
  'La Croix d''Or',
  'Lutry',
  'gastronomy',
  'Restaurant gastronomique en bord de Léman. Carte de saison, terrasse spectaculaire en été.',
  46.5028, 6.6856,
  180, 4,
  ARRAY['Reservation necessaire'],
  ARRAY['Printemps','Été','Automne','Hiver'],
  ARRAY['Couple'],
  true, false,
  NULL, NULL, NULL,
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'La Croix d''Or' AND location_name = 'Lutry'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'La Croix d''Or' AND location_name = 'Lutry'
);

-- Auberge de l'Onde
INSERT INTO activity_submissions (
  title, location_name, category, description,
  latitude, longitude, duration_minutes, price_level,
  features, seasons, social_tags,
  is_indoor, is_outdoor,
  activity_url, image_url, location_zone,
  date_label, date_label_en, date_start, date_end,
  recurrence_type, seasonal_months, weekly_days,
  status, submitted_by
)
SELECT
  'Auberge de l''Onde',
  'Saint-Saphorin',
  'gastronomy',
  'Auberge centenaire dans les vignobles de Lavaux. Cuisine raffinée, vins de la propriété.',
  46.4717, 6.7964,
  180, 4,
  ARRAY['Reservation necessaire'],
  ARRAY['Printemps','Été','Automne','Hiver'],
  ARRAY['Couple','Amis'],
  true, false,
  'https://www.aubergedelonde.ch', NULL, NULL,
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Auberge de l''Onde' AND location_name = 'Saint-Saphorin'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Auberge de l''Onde' AND location_name = 'Saint-Saphorin'
);

-- Maison Cailler
INSERT INTO activity_submissions (
  title, location_name, category, description,
  latitude, longitude, duration_minutes, price_level,
  features, seasons, social_tags,
  is_indoor, is_outdoor,
  activity_url, image_url, location_zone,
  date_label, date_label_en, date_start, date_end,
  recurrence_type, seasonal_months, weekly_days,
  status, submitted_by
)
SELECT
  'Maison Cailler',
  'Broc',
  'gastronomy',
  'Visite immersive de la chocolaterie centenaire. Histoire, dégustation à volonté en fin de parcours.',
  46.6075, 7.0917,
  90, 2,
  ARRAY['Parking','Reservation necessaire'],
  ARRAY['Printemps','Été','Automne','Hiver'],
  ARRAY['Famille','Couple','Amis'],
  true, false,
  'https://www.cailler.ch/fr/maison-cailler', NULL, NULL,
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Maison Cailler' AND location_name = 'Broc'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Maison Cailler' AND location_name = 'Broc'
);

-- Domaine Henri Cruchon
INSERT INTO activity_submissions (
  title, location_name, category, description,
  latitude, longitude, duration_minutes, price_level,
  features, seasons, social_tags,
  is_indoor, is_outdoor,
  activity_url, image_url, location_zone,
  date_label, date_label_en, date_start, date_end,
  recurrence_type, seasonal_months, weekly_days,
  status, submitted_by
)
SELECT
  'Domaine Henri Cruchon',
  'Échichens',
  'gastronomy',
  'Domaine viticole familial, vins biodynamiques. Caveau de dégustation, visites guidées.',
  46.5119, 6.4906,
  90, 3,
  ARRAY['Reservation necessaire'],
  ARRAY['Printemps','Été','Automne'],
  ARRAY['Couple','Amis'],
  true, false,
  'https://www.henricruchon.com', NULL, NULL,
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Domaine Henri Cruchon' AND location_name = 'Échichens'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Domaine Henri Cruchon' AND location_name = 'Échichens'
);

-- Brasserie de Montbenon
INSERT INTO activity_submissions (
  title, location_name, category, description,
  latitude, longitude, duration_minutes, price_level,
  features, seasons, social_tags,
  is_indoor, is_outdoor,
  activity_url, image_url, location_zone,
  date_label, date_label_en, date_start, date_end,
  recurrence_type, seasonal_months, weekly_days,
  status, submitted_by
)
SELECT
  'Brasserie de Montbenon',
  'Lausanne',
  'gastronomy',
  'Brasserie réputée près du Casino de Montbenon. Ambiance vintage, terrasse avec vue sur le Léman.',
  46.5189, 6.6286,
  120, 3,
  ARRAY[]::text[],
  ARRAY['Printemps','Été','Automne','Hiver'],
  ARRAY['Couple','Amis','Famille'],
  true, true,
  'https://www.brasseriedemontbenon.ch', NULL, NULL,
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Brasserie de Montbenon' AND location_name = 'Lausanne'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Brasserie de Montbenon' AND location_name = 'Lausanne'
);

-- Ski Villars-Gryon
INSERT INTO activity_submissions (
  title, location_name, category, description,
  latitude, longitude, duration_minutes, price_level,
  features, seasons, social_tags,
  is_indoor, is_outdoor,
  activity_url, image_url, location_zone,
  date_label, date_label_en, date_start, date_end,
  recurrence_type, seasonal_months, weekly_days,
  status, submitted_by
)
SELECT
  'Ski Villars-Gryon',
  'Villars-sur-Ollon',
  'sport',
  '100 km de pistes accessibles à tous niveaux, vue sur le Mont-Blanc et les Dents du Midi.',
  46.2972, 7.0481,
  480, 5,
  ARRAY['Parking','Reservation necessaire'],
  ARRAY['Hiver'],
  ARRAY['Famille','Amis','Couple'],
  false, true,
  'https://www.villars.ch', NULL, NULL,
  NULL, NULL, NULL, NULL,
  'seasonal', ARRAY[12,1,2,3,4]::int[], NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Ski Villars-Gryon' AND location_name = 'Villars-sur-Ollon'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Ski Villars-Gryon' AND location_name = 'Villars-sur-Ollon'
);

-- Ski Leysin
INSERT INTO activity_submissions (
  title, location_name, category, description,
  latitude, longitude, duration_minutes, price_level,
  features, seasons, social_tags,
  is_indoor, is_outdoor,
  activity_url, image_url, location_zone,
  date_label, date_label_en, date_start, date_end,
  recurrence_type, seasonal_months, weekly_days,
  status, submitted_by
)
SELECT
  'Ski Leysin',
  'Leysin',
  'sport',
  '60 km de pistes, station ensoleillée face aux Dents du Midi. Snow park réputé.',
  46.3478, 7.0089,
  480, 5,
  ARRAY['Parking'],
  ARRAY['Hiver'],
  ARRAY['Famille','Amis'],
  false, true,
  'https://www.leysin.ch', NULL, NULL,
  NULL, NULL, NULL, NULL,
  'seasonal', ARRAY[12,1,2,3,4]::int[], NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Ski Leysin' AND location_name = 'Leysin'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Ski Leysin' AND location_name = 'Leysin'
);

-- Ski Les Diablerets
INSERT INTO activity_submissions (
  title, location_name, category, description,
  latitude, longitude, duration_minutes, price_level,
  features, seasons, social_tags,
  is_indoor, is_outdoor,
  activity_url, image_url, location_zone,
  date_label, date_label_en, date_start, date_end,
  recurrence_type, seasonal_months, weekly_days,
  status, submitted_by
)
SELECT
  'Ski Les Diablerets',
  'Les Diablerets',
  'sport',
  'Domaine relié à Glacier 3000. Ski toute l''année sur le glacier, panoramas exceptionnels.',
  46.3553, 7.1572,
  480, 5,
  ARRAY['Parking'],
  ARRAY['Été','Automne','Hiver'],
  ARRAY['Famille','Amis','Couple'],
  false, true,
  'https://www.diablerets.ch', NULL, NULL,
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Ski Les Diablerets' AND location_name = 'Les Diablerets'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Ski Les Diablerets' AND location_name = 'Les Diablerets'
);

-- Aquaparc Le Bouveret
INSERT INTO activity_submissions (
  title, location_name, category, description,
  latitude, longitude, duration_minutes, price_level,
  features, seasons, social_tags,
  is_indoor, is_outdoor,
  activity_url, image_url, location_zone,
  date_label, date_label_en, date_start, date_end,
  recurrence_type, seasonal_months, weekly_days,
  status, submitted_by
)
SELECT
  'Aquaparc Le Bouveret',
  'Le Bouveret',
  'sport',
  'Parc aquatique avec 12 toboggans, piscine à vagues. Le plus grand parc aquatique de Suisse romande.',
  46.3839, 6.8472,
  240, 4,
  ARRAY['Parking','Reservation necessaire'],
  ARRAY['Printemps','Été'],
  ARRAY['Famille','Amis'],
  false, true,
  'https://www.aquaparc.ch', NULL, NULL,
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Aquaparc Le Bouveret' AND location_name = 'Le Bouveret'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Aquaparc Le Bouveret' AND location_name = 'Le Bouveret'
);

-- Patinoire de Malley
INSERT INTO activity_submissions (
  title, location_name, category, description,
  latitude, longitude, duration_minutes, price_level,
  features, seasons, social_tags,
  is_indoor, is_outdoor,
  activity_url, image_url, location_zone,
  date_label, date_label_en, date_start, date_end,
  recurrence_type, seasonal_months, weekly_days,
  status, submitted_by
)
SELECT
  'Patinoire de Malley',
  'Lausanne',
  'sport',
  'Patinage public dans une grande patinoire moderne. Cours et sessions disco le weekend.',
  46.5258, 6.5947,
  120, 2,
  ARRAY['Parking','Horaires restreints'],
  ARRAY['Automne','Hiver','Printemps'],
  ARRAY['Famille','Amis'],
  true, false,
  'https://www.vaudoisearena.ch', NULL, NULL,
  NULL, NULL, NULL, NULL,
  'seasonal', ARRAY[10,11,12,1,2,3]::int[], NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Patinoire de Malley' AND location_name = 'Lausanne'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Patinoire de Malley' AND location_name = 'Lausanne'
);

-- Voile et SUP Rolle
INSERT INTO activity_submissions (
  title, location_name, category, description,
  latitude, longitude, duration_minutes, price_level,
  features, seasons, social_tags,
  is_indoor, is_outdoor,
  activity_url, image_url, location_zone,
  date_label, date_label_en, date_start, date_end,
  recurrence_type, seasonal_months, weekly_days,
  status, submitted_by
)
SELECT
  'Voile et SUP Rolle',
  'Rolle',
  'sport',
  'Centre nautique sur le Léman. Cours de voile, paddle, kitesurf. Locations à l''heure.',
  46.4583, 6.3389,
  180, 3,
  ARRAY['Parking','Reservation necessaire'],
  ARRAY['Printemps','Été','Automne'],
  ARRAY['Solo','Couple','Amis'],
  false, true,
  NULL, NULL, NULL,
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Voile et SUP Rolle' AND location_name = 'Rolle'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Voile et SUP Rolle' AND location_name = 'Rolle'
);

-- Bike Park Villars
INSERT INTO activity_submissions (
  title, location_name, category, description,
  latitude, longitude, duration_minutes, price_level,
  features, seasons, social_tags,
  is_indoor, is_outdoor,
  activity_url, image_url, location_zone,
  date_label, date_label_en, date_start, date_end,
  recurrence_type, seasonal_months, weekly_days,
  status, submitted_by
)
SELECT
  'Bike Park Villars',
  'Villars-sur-Ollon',
  'sport',
  'Pistes VTT descentes, jumps et single tracks. Remontées mécaniques pour cyclistes.',
  46.3, 7.05,
  240, 4,
  ARRAY['Parking','Reservation necessaire'],
  ARRAY['Été','Automne'],
  ARRAY['Solo','Amis'],
  false, true,
  'https://www.villars.ch/fr/ete/bike-park', NULL, NULL,
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Bike Park Villars' AND location_name = 'Villars-sur-Ollon'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Bike Park Villars' AND location_name = 'Villars-sur-Ollon'
);

-- Centre Mountain Bike Lavaux
INSERT INTO activity_submissions (
  title, location_name, category, description,
  latitude, longitude, duration_minutes, price_level,
  features, seasons, social_tags,
  is_indoor, is_outdoor,
  activity_url, image_url, location_zone,
  date_label, date_label_en, date_start, date_end,
  recurrence_type, seasonal_months, weekly_days,
  status, submitted_by
)
SELECT
  'Centre Mountain Bike Lavaux',
  'Chexbres',
  'sport',
  'Réseau de sentiers VTT à travers les vignes UNESCO. Locations possibles.',
  46.4842, 6.7917,
  240, 2,
  ARRAY['Parking'],
  ARRAY['Printemps','Été','Automne'],
  ARRAY['Solo','Amis','Couple'],
  false, true,
  NULL, NULL, NULL,
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Centre Mountain Bike Lavaux' AND location_name = 'Chexbres'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Centre Mountain Bike Lavaux' AND location_name = 'Chexbres'
);

-- Plage piscine de Morges
INSERT INTO activity_submissions (
  title, location_name, category, description,
  latitude, longitude, duration_minutes, price_level,
  features, seasons, social_tags,
  is_indoor, is_outdoor,
  activity_url, image_url, location_zone,
  date_label, date_label_en, date_start, date_end,
  recurrence_type, seasonal_months, weekly_days,
  status, submitted_by
)
SELECT
  'Plage piscine de Morges',
  'Morges',
  'sport',
  'Piscine olympique au bord du Léman. Bassins, plongeoirs, plage de gazon.',
  46.5081, 6.5022,
  180, 2,
  ARRAY['Parking','Horaires restreints'],
  ARRAY['Printemps','Été'],
  ARRAY['Famille','Amis','Couple'],
  false, true,
  'https://www.morges.ch/fr/piscine', NULL, NULL,
  NULL, NULL, NULL, NULL,
  'seasonal', ARRAY[5,6,7,8,9]::int[], NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Plage piscine de Morges' AND location_name = 'Morges'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Plage piscine de Morges' AND location_name = 'Morges'
);

-- Centre sportif de Vidy
INSERT INTO activity_submissions (
  title, location_name, category, description,
  latitude, longitude, duration_minutes, price_level,
  features, seasons, social_tags,
  is_indoor, is_outdoor,
  activity_url, image_url, location_zone,
  date_label, date_label_en, date_start, date_end,
  recurrence_type, seasonal_months, weekly_days,
  status, submitted_by
)
SELECT
  'Centre sportif de Vidy',
  'Lausanne',
  'sport',
  'Complexe sportif au bord du Léman. Tennis, mini-golf, escalade, plage. Idéal pour la journée.',
  46.5172, 6.5917,
  240, 2,
  ARRAY['Parking'],
  ARRAY['Printemps','Été','Automne'],
  ARRAY['Famille','Amis','Couple'],
  false, true,
  'https://www.lausanne.ch/officiel/administration/sports-et-cohesion-sociale/centre-sportif-de-vidy.html', NULL, NULL,
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Centre sportif de Vidy' AND location_name = 'Lausanne'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Centre sportif de Vidy' AND location_name = 'Lausanne'
);

-- Canyoning Gorges du Chauderon
INSERT INTO activity_submissions (
  title, location_name, category, description,
  latitude, longitude, duration_minutes, price_level,
  features, seasons, social_tags,
  is_indoor, is_outdoor,
  activity_url, image_url, location_zone,
  date_label, date_label_en, date_start, date_end,
  recurrence_type, seasonal_months, weekly_days,
  status, submitted_by
)
SELECT
  'Canyoning Gorges du Chauderon',
  'Montreux',
  'adventure',
  'Descente en rappel, sauts et toboggans naturels. Encadrement professionnel obligatoire.',
  46.4208, 6.9097,
  240, 5,
  ARRAY['Reservation necessaire','Minimum de participants'],
  ARRAY['Été','Automne'],
  ARRAY['Amis','Couple'],
  false, true,
  NULL, NULL, NULL,
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Canyoning Gorges du Chauderon' AND location_name = 'Montreux'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Canyoning Gorges du Chauderon' AND location_name = 'Montreux'
);

-- Parapente biplace Villars
INSERT INTO activity_submissions (
  title, location_name, category, description,
  latitude, longitude, duration_minutes, price_level,
  features, seasons, social_tags,
  is_indoor, is_outdoor,
  activity_url, image_url, location_zone,
  date_label, date_label_en, date_start, date_end,
  recurrence_type, seasonal_months, weekly_days,
  status, submitted_by
)
SELECT
  'Parapente biplace Villars',
  'Villars-sur-Ollon',
  'adventure',
  'Vol biplace de 15-30 min au-dessus des Alpes vaudoises. Vue Mont-Blanc + Dents du Midi.',
  46.2972, 7.0481,
  90, 5,
  ARRAY['Reservation necessaire'],
  ARRAY['Printemps','Été','Automne'],
  ARRAY['Couple','Solo','Amis'],
  false, true,
  NULL, NULL, NULL,
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Parapente biplace Villars' AND location_name = 'Villars-sur-Ollon'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Parapente biplace Villars' AND location_name = 'Villars-sur-Ollon'
);

-- Via ferrata Tière
INSERT INTO activity_submissions (
  title, location_name, category, description,
  latitude, longitude, duration_minutes, price_level,
  features, seasons, social_tags,
  is_indoor, is_outdoor,
  activity_url, image_url, location_zone,
  date_label, date_label_en, date_start, date_end,
  recurrence_type, seasonal_months, weekly_days,
  status, submitted_by
)
SELECT
  'Via ferrata Tière',
  'Évionnaz',
  'adventure',
  'Via ferrata difficile au-dessus du Trient. Pont himalayen et tyroliennes.',
  46.1842, 7.0306,
  240, 4,
  ARRAY['Reservation necessaire'],
  ARRAY['Été','Automne'],
  ARRAY['Solo','Amis'],
  false, true,
  NULL, NULL, NULL,
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Via ferrata Tière' AND location_name = 'Évionnaz'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Via ferrata Tière' AND location_name = 'Évionnaz'
);

-- Acrobranche Aigle
INSERT INTO activity_submissions (
  title, location_name, category, description,
  latitude, longitude, duration_minutes, price_level,
  features, seasons, social_tags,
  is_indoor, is_outdoor,
  activity_url, image_url, location_zone,
  date_label, date_label_en, date_start, date_end,
  recurrence_type, seasonal_months, weekly_days,
  status, submitted_by
)
SELECT
  'Acrobranche Aigle',
  'Aigle',
  'adventure',
  'Parc de cordes dans la forêt. Parcours pour tous âges, tyroliennes géantes.',
  46.3192, 6.97,
  180, 4,
  ARRAY['Parking','Reservation necessaire'],
  ARRAY['Printemps','Été','Automne'],
  ARRAY['Famille','Amis'],
  false, true,
  NULL, NULL, NULL,
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Acrobranche Aigle' AND location_name = 'Aigle'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Acrobranche Aigle' AND location_name = 'Aigle'
);

-- Escape Room Lausanne Lock'd
INSERT INTO activity_submissions (
  title, location_name, category, description,
  latitude, longitude, duration_minutes, price_level,
  features, seasons, social_tags,
  is_indoor, is_outdoor,
  activity_url, image_url, location_zone,
  date_label, date_label_en, date_start, date_end,
  recurrence_type, seasonal_months, weekly_days,
  status, submitted_by
)
SELECT
  'Escape Room Lausanne Lock''d',
  'Lausanne',
  'adventure',
  'Salles d''évasion thématiques. Énigmes corsées en équipe, 60 minutes pour s''échapper.',
  46.5167, 6.63,
  90, 3,
  ARRAY['Reservation necessaire','Minimum de participants'],
  ARRAY['Printemps','Été','Automne','Hiver'],
  ARRAY['Amis','Famille'],
  true, false,
  'https://www.lockd.ch', NULL, NULL,
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Escape Room Lausanne Lock''d' AND location_name = 'Lausanne'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Escape Room Lausanne Lock''d' AND location_name = 'Lausanne'
);

-- Saut élastique Niouc
INSERT INTO activity_submissions (
  title, location_name, category, description,
  latitude, longitude, duration_minutes, price_level,
  features, seasons, social_tags,
  is_indoor, is_outdoor,
  activity_url, image_url, location_zone,
  date_label, date_label_en, date_start, date_end,
  recurrence_type, seasonal_months, weekly_days,
  status, submitted_by
)
SELECT
  'Saut élastique Niouc',
  'Vissoie',
  'adventure',
  'Saut depuis un pont à 190m de haut sur la rivière Navisence. Le plus haut saut élastique d''Europe.',
  46.2336, 7.5694,
  60, 5,
  ARRAY['Reservation necessaire'],
  ARRAY['Printemps','Été','Automne'],
  ARRAY['Amis','Solo'],
  false, true,
  'https://www.bungy.ch', NULL, NULL,
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Saut élastique Niouc' AND location_name = 'Vissoie'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Saut élastique Niouc' AND location_name = 'Vissoie'
);

-- Tyrolienne Champéry
INSERT INTO activity_submissions (
  title, location_name, category, description,
  latitude, longitude, duration_minutes, price_level,
  features, seasons, social_tags,
  is_indoor, is_outdoor,
  activity_url, image_url, location_zone,
  date_label, date_label_en, date_start, date_end,
  recurrence_type, seasonal_months, weekly_days,
  status, submitted_by
)
SELECT
  'Tyrolienne Champéry',
  'Champéry',
  'adventure',
  'Tyrolienne géante de 2 km dans les Portes du Soleil. Vitesse jusqu''à 80 km/h.',
  46.175, 6.8722,
  30, 4,
  ARRAY['Reservation necessaire'],
  ARRAY['Été','Automne'],
  ARRAY['Amis','Couple'],
  false, true,
  'https://www.champery.ch', NULL, NULL,
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Tyrolienne Champéry' AND location_name = 'Champéry'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Tyrolienne Champéry' AND location_name = 'Champéry'
);

-- Rafting Sarine
INSERT INTO activity_submissions (
  title, location_name, category, description,
  latitude, longitude, duration_minutes, price_level,
  features, seasons, social_tags,
  is_indoor, is_outdoor,
  activity_url, image_url, location_zone,
  date_label, date_label_en, date_start, date_end,
  recurrence_type, seasonal_months, weekly_days,
  status, submitted_by
)
SELECT
  'Rafting Sarine',
  'Saanen',
  'adventure',
  'Descente en raft sur la Sarine sauvage. Plusieurs niveaux, encadrement pro.',
  46.4953, 7.2606,
  240, 4,
  ARRAY['Reservation necessaire','Minimum de participants'],
  ARRAY['Printemps','Été'],
  ARRAY['Amis'],
  false, true,
  NULL, NULL, NULL,
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Rafting Sarine' AND location_name = 'Saanen'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Rafting Sarine' AND location_name = 'Saanen'
);

-- Bains de Lavey
INSERT INTO activity_submissions (
  title, location_name, category, description,
  latitude, longitude, duration_minutes, price_level,
  features, seasons, social_tags,
  is_indoor, is_outdoor,
  activity_url, image_url, location_zone,
  date_label, date_label_en, date_start, date_end,
  recurrence_type, seasonal_months, weekly_days,
  status, submitted_by
)
SELECT
  'Bains de Lavey',
  'Lavey-les-Bains',
  'relax',
  'Source thermale la plus chaude de Suisse (62°C). Spa, bains intérieurs/extérieurs, soins.',
  46.2056, 7.025,
  240, 4,
  ARRAY['Parking','Reservation necessaire'],
  ARRAY['Printemps','Été','Automne','Hiver'],
  ARRAY['Couple','Famille','Solo'],
  true, true,
  'https://www.lavey-les-bains.ch', NULL, NULL,
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Bains de Lavey' AND location_name = 'Lavey-les-Bains'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Bains de Lavey' AND location_name = 'Lavey-les-Bains'
);

-- Spa Royal Plaza
INSERT INTO activity_submissions (
  title, location_name, category, description,
  latitude, longitude, duration_minutes, price_level,
  features, seasons, social_tags,
  is_indoor, is_outdoor,
  activity_url, image_url, location_zone,
  date_label, date_label_en, date_start, date_end,
  recurrence_type, seasonal_months, weekly_days,
  status, submitted_by
)
SELECT
  'Spa Royal Plaza',
  'Montreux',
  'relax',
  'Spa luxe avec piscine intérieure, sauna, hammam, soins. Vue sur le lac Léman.',
  46.4308, 6.9117,
  180, 5,
  ARRAY['Reservation necessaire'],
  ARRAY['Printemps','Été','Automne','Hiver'],
  ARRAY['Couple'],
  true, false,
  'https://www.royalplaza.ch', NULL, NULL,
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Spa Royal Plaza' AND location_name = 'Montreux'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Spa Royal Plaza' AND location_name = 'Montreux'
);

-- Bains de Bex (Mines de sel)
INSERT INTO activity_submissions (
  title, location_name, category, description,
  latitude, longitude, duration_minutes, price_level,
  features, seasons, social_tags,
  is_indoor, is_outdoor,
  activity_url, image_url, location_zone,
  date_label, date_label_en, date_start, date_end,
  recurrence_type, seasonal_months, weekly_days,
  status, submitted_by
)
SELECT
  'Bains de Bex (Mines de sel)',
  'Bex',
  'relax',
  'Centre de bien-être dans une ancienne mine. Piscines au sel, hammam de roche.',
  46.2528, 7.0017,
  180, 4,
  ARRAY['Reservation necessaire'],
  ARRAY['Printemps','Été','Automne','Hiver'],
  ARRAY['Couple','Solo'],
  true, false,
  'https://www.mines.ch', NULL, NULL,
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Bains de Bex (Mines de sel)' AND location_name = 'Bex'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Bains de Bex (Mines de sel)' AND location_name = 'Bex'
);

-- Yverdon-les-Bains thermes
INSERT INTO activity_submissions (
  title, location_name, category, description,
  latitude, longitude, duration_minutes, price_level,
  features, seasons, social_tags,
  is_indoor, is_outdoor,
  activity_url, image_url, location_zone,
  date_label, date_label_en, date_start, date_end,
  recurrence_type, seasonal_months, weekly_days,
  status, submitted_by
)
SELECT
  'Yverdon-les-Bains thermes',
  'Yverdon-les-Bains',
  'relax',
  'Centre thermal de référence : eaux sulfureuses à 28°C, spa, fitness, hôtel.',
  46.7847, 6.6428,
  240, 4,
  ARRAY['Parking','Reservation necessaire'],
  ARRAY['Printemps','Été','Automne','Hiver'],
  ARRAY['Couple','Famille','Solo'],
  true, true,
  'https://www.cty.ch', NULL, NULL,
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Yverdon-les-Bains thermes' AND location_name = 'Yverdon-les-Bains'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Yverdon-les-Bains thermes' AND location_name = 'Yverdon-les-Bains'
);

-- Spa Beau-Rivage Palace
INSERT INTO activity_submissions (
  title, location_name, category, description,
  latitude, longitude, duration_minutes, price_level,
  features, seasons, social_tags,
  is_indoor, is_outdoor,
  activity_url, image_url, location_zone,
  date_label, date_label_en, date_start, date_end,
  recurrence_type, seasonal_months, weekly_days,
  status, submitted_by
)
SELECT
  'Spa Beau-Rivage Palace',
  'Lausanne',
  'relax',
  'Spa cinq étoiles avec piscine intérieure, salle de cardio, soins haut de gamme.',
  46.5097, 6.6361,
  180, 5,
  ARRAY['Reservation necessaire'],
  ARRAY['Printemps','Été','Automne','Hiver'],
  ARRAY['Couple'],
  true, false,
  'https://www.brp.ch/fr/cinq-mondes-spa', NULL, NULL,
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Spa Beau-Rivage Palace' AND location_name = 'Lausanne'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Spa Beau-Rivage Palace' AND location_name = 'Lausanne'
);

-- Thermes des Salines de Bex
INSERT INTO activity_submissions (
  title, location_name, category, description,
  latitude, longitude, duration_minutes, price_level,
  features, seasons, social_tags,
  is_indoor, is_outdoor,
  activity_url, image_url, location_zone,
  date_label, date_label_en, date_start, date_end,
  recurrence_type, seasonal_months, weekly_days,
  status, submitted_by
)
SELECT
  'Thermes des Salines de Bex',
  'Bex',
  'relax',
  'Bains de saumure dans les anciennes mines de sel. Expérience unique sous terre.',
  46.2444, 6.9883,
  180, 4,
  ARRAY['Reservation necessaire'],
  ARRAY['Printemps','Été','Automne','Hiver'],
  ARRAY['Couple','Solo'],
  true, false,
  NULL, NULL, NULL,
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Thermes des Salines de Bex' AND location_name = 'Bex'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Thermes des Salines de Bex' AND location_name = 'Bex'
);

-- Spa Hôtel Villars Palace
INSERT INTO activity_submissions (
  title, location_name, category, description,
  latitude, longitude, duration_minutes, price_level,
  features, seasons, social_tags,
  is_indoor, is_outdoor,
  activity_url, image_url, location_zone,
  date_label, date_label_en, date_start, date_end,
  recurrence_type, seasonal_months, weekly_days,
  status, submitted_by
)
SELECT
  'Spa Hôtel Villars Palace',
  'Villars-sur-Ollon',
  'relax',
  'Spa de l''Alpine Lodge, cadre montagnard, soins après ski.',
  46.2986, 7.0467,
  180, 5,
  ARRAY['Reservation necessaire'],
  ARRAY['Printemps','Été','Automne','Hiver'],
  ARRAY['Couple'],
  true, false,
  'https://www.villarspalace.com', NULL, NULL,
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Spa Hôtel Villars Palace' AND location_name = 'Villars-sur-Ollon'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Spa Hôtel Villars Palace' AND location_name = 'Villars-sur-Ollon'
);

-- Yoga Léman Vevey
INSERT INTO activity_submissions (
  title, location_name, category, description,
  latitude, longitude, duration_minutes, price_level,
  features, seasons, social_tags,
  is_indoor, is_outdoor,
  activity_url, image_url, location_zone,
  date_label, date_label_en, date_start, date_end,
  recurrence_type, seasonal_months, weekly_days,
  status, submitted_by
)
SELECT
  'Yoga Léman Vevey',
  'Vevey',
  'relax',
  'Cours de yoga et méditation au bord du Léman, niveau débutant à avancé.',
  46.4633, 6.8492,
  90, 2,
  ARRAY['Reservation necessaire','Horaires restreints'],
  ARRAY['Printemps','Été','Automne','Hiver'],
  ARRAY['Solo','Couple'],
  true, true,
  NULL, NULL, NULL,
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Yoga Léman Vevey' AND location_name = 'Vevey'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Yoga Léman Vevey' AND location_name = 'Vevey'
);

-- Le Signal de Bougy
INSERT INTO activity_submissions (
  title, location_name, category, description,
  latitude, longitude, duration_minutes, price_level,
  features, seasons, social_tags,
  is_indoor, is_outdoor,
  activity_url, image_url, location_zone,
  date_label, date_label_en, date_start, date_end,
  recurrence_type, seasonal_months, weekly_days,
  status, submitted_by
)
SELECT
  'Le Signal de Bougy',
  'Bougy-Villars',
  'fun',
  'Parc de loisirs avec animaux, mini-golf, places de jeux, restaurant. Vue Léman + Mont-Blanc.',
  46.4628, 6.3258,
  240, 2,
  ARRAY['Parking'],
  ARRAY['Printemps','Été','Automne'],
  ARRAY['Famille','Amis'],
  false, true,
  'https://www.signaldebougy.ch', NULL, NULL,
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Le Signal de Bougy' AND location_name = 'Bougy-Villars'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Le Signal de Bougy' AND location_name = 'Bougy-Villars'
);

-- Cinéma Open Air Lausanne
INSERT INTO activity_submissions (
  title, location_name, category, description,
  latitude, longitude, duration_minutes, price_level,
  features, seasons, social_tags,
  is_indoor, is_outdoor,
  activity_url, image_url, location_zone,
  date_label, date_label_en, date_start, date_end,
  recurrence_type, seasonal_months, weekly_days,
  status, submitted_by
)
SELECT
  'Cinéma Open Air Lausanne',
  'Lausanne',
  'fun',
  'Projections en plein air sur les bords du Léman, fin juillet. Films classiques et récents.',
  46.5097, 6.6361,
  180, 3,
  ARRAY['Horaires restreints'],
  ARRAY['Été'],
  ARRAY['Couple','Amis','Famille'],
  false, true,
  'https://www.openair-cinema.ch', NULL, NULL,
  'Juillet-août', 'July-August', NULL, NULL,
  'seasonal', ARRAY[7,8]::int[], NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Cinéma Open Air Lausanne' AND location_name = 'Lausanne'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Cinéma Open Air Lausanne' AND location_name = 'Lausanne'
);

-- Mini-golf Vidy
INSERT INTO activity_submissions (
  title, location_name, category, description,
  latitude, longitude, duration_minutes, price_level,
  features, seasons, social_tags,
  is_indoor, is_outdoor,
  activity_url, image_url, location_zone,
  date_label, date_label_en, date_start, date_end,
  recurrence_type, seasonal_months, weekly_days,
  status, submitted_by
)
SELECT
  'Mini-golf Vidy',
  'Lausanne',
  'fun',
  'Parcours 18 trous au bord du Léman, dans le parc de Vidy. Idéal famille.',
  46.5172, 6.5917,
  90, 2,
  ARRAY[]::text[],
  ARRAY['Printemps','Été','Automne'],
  ARRAY['Famille','Amis','Couple'],
  false, true,
  NULL, NULL, NULL,
  NULL, NULL, NULL, NULL,
  'seasonal', ARRAY[4,5,6,7,8,9,10]::int[], NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Mini-golf Vidy' AND location_name = 'Lausanne'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Mini-golf Vidy' AND location_name = 'Lausanne'
);

-- Bowling Vevey
INSERT INTO activity_submissions (
  title, location_name, category, description,
  latitude, longitude, duration_minutes, price_level,
  features, seasons, social_tags,
  is_indoor, is_outdoor,
  activity_url, image_url, location_zone,
  date_label, date_label_en, date_start, date_end,
  recurrence_type, seasonal_months, weekly_days,
  status, submitted_by
)
SELECT
  'Bowling Vevey',
  'Vevey',
  'fun',
  'Bowling moderne avec 12 pistes, billard, restaurant. Animations le weekend.',
  46.4633, 6.8472,
  120, 3,
  ARRAY[]::text[],
  ARRAY['Printemps','Été','Automne','Hiver'],
  ARRAY['Amis','Famille','Couple'],
  true, false,
  'https://www.bowlingvevey.ch', NULL, NULL,
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Bowling Vevey' AND location_name = 'Vevey'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Bowling Vevey' AND location_name = 'Vevey'
);

-- Magic Casino Crissier
INSERT INTO activity_submissions (
  title, location_name, category, description,
  latitude, longitude, duration_minutes, price_level,
  features, seasons, social_tags,
  is_indoor, is_outdoor,
  activity_url, image_url, location_zone,
  date_label, date_label_en, date_start, date_end,
  recurrence_type, seasonal_months, weekly_days,
  status, submitted_by
)
SELECT
  'Magic Casino Crissier',
  'Crissier',
  'fun',
  'Casino moderne, machines à sous, jeux de table. Restaurant et bar.',
  46.5497, 6.5775,
  180, 5,
  ARRAY['Reservation necessaire'],
  ARRAY['Printemps','Été','Automne','Hiver'],
  ARRAY['Couple','Amis'],
  true, false,
  NULL, NULL, NULL,
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Magic Casino Crissier' AND location_name = 'Crissier'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Magic Casino Crissier' AND location_name = 'Crissier'
);

-- Festival de la Cité
INSERT INTO activity_submissions (
  title, location_name, category, description,
  latitude, longitude, duration_minutes, price_level,
  features, seasons, social_tags,
  is_indoor, is_outdoor,
  activity_url, image_url, location_zone,
  date_label, date_label_en, date_start, date_end,
  recurrence_type, seasonal_months, weekly_days,
  status, submitted_by
)
SELECT
  'Festival de la Cité',
  'Lausanne',
  'event',
  'Festival pluridisciplinaire gratuit en juillet : musique, théâtre, danse dans la vieille ville.',
  46.5228, 6.6353,
  240, 1,
  ARRAY[]::text[],
  ARRAY['Été'],
  ARRAY['Famille','Amis','Couple','Solo'],
  false, true,
  'https://www.festivalcite.ch', NULL, NULL,
  'Début juillet 2026', 'Early July 2026', '2026-07-07'::date, '2026-07-12'::date,
  'one_off', NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Festival de la Cité' AND location_name = 'Lausanne'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Festival de la Cité' AND location_name = 'Lausanne'
);

-- Cully Jazz Festival
INSERT INTO activity_submissions (
  title, location_name, category, description,
  latitude, longitude, duration_minutes, price_level,
  features, seasons, social_tags,
  is_indoor, is_outdoor,
  activity_url, image_url, location_zone,
  date_label, date_label_en, date_start, date_end,
  recurrence_type, seasonal_months, weekly_days,
  status, submitted_by
)
SELECT
  'Cully Jazz Festival',
  'Cully',
  'event',
  'Festival de jazz historique en avril. Concerts dans 3 caveaux + scènes off gratuites.',
  46.49, 6.73,
  240, 4,
  ARRAY['Reservation necessaire'],
  ARRAY['Printemps'],
  ARRAY['Couple','Amis','Solo'],
  false, true,
  'https://www.cullyjazz.ch', NULL, NULL,
  'Avril 2026', 'April 2026', '2026-04-10'::date, '2026-04-18'::date,
  'one_off', NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Cully Jazz Festival' AND location_name = 'Cully'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Cully Jazz Festival' AND location_name = 'Cully'
);

-- Marché de Noël de Montreux
INSERT INTO activity_submissions (
  title, location_name, category, description,
  latitude, longitude, duration_minutes, price_level,
  features, seasons, social_tags,
  is_indoor, is_outdoor,
  activity_url, image_url, location_zone,
  date_label, date_label_en, date_start, date_end,
  recurrence_type, seasonal_months, weekly_days,
  status, submitted_by
)
SELECT
  'Marché de Noël de Montreux',
  'Montreux',
  'event',
  'Plus grand marché de Noël de Suisse romande sur les quais. Père Noël en tyrolienne au-dessus du lac.',
  46.4308, 6.9117,
  180, 2,
  ARRAY['Parking'],
  ARRAY['Hiver'],
  ARRAY['Famille','Couple','Amis'],
  false, true,
  'https://www.montreuxnoel.com', NULL, NULL,
  '20 nov - 24 déc 2026', '20 Nov - 24 Dec 2026', '2026-11-20'::date, '2026-12-24'::date,
  'one_off', NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Marché de Noël de Montreux' AND location_name = 'Montreux'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Marché de Noël de Montreux' AND location_name = 'Montreux'
);

-- Brandons d'Yverdon
INSERT INTO activity_submissions (
  title, location_name, category, description,
  latitude, longitude, duration_minutes, price_level,
  features, seasons, social_tags,
  is_indoor, is_outdoor,
  activity_url, image_url, location_zone,
  date_label, date_label_en, date_start, date_end,
  recurrence_type, seasonal_months, weekly_days,
  status, submitted_by
)
SELECT
  'Brandons d''Yverdon',
  'Yverdon-les-Bains',
  'event',
  'Carnaval avec cortèges, Guggenmusiks, bal masqué. Plus de 100 ans de tradition.',
  46.7783, 6.6406,
  240, 1,
  ARRAY['Parking'],
  ARRAY['Printemps'],
  ARRAY['Famille','Amis'],
  false, true,
  'https://www.brandons-yverdon.ch', NULL, NULL,
  'Mi-mars 2026', 'Mid-March 2026', '2026-03-13'::date, '2026-03-15'::date,
  'one_off', NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Brandons d''Yverdon' AND location_name = 'Yverdon-les-Bains'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Brandons d''Yverdon' AND location_name = 'Yverdon-les-Bains'
);

-- Gornergrat Bahn
INSERT INTO activity_submissions (
  title, location_name, category, description,
  latitude, longitude, duration_minutes, price_level,
  features, seasons, social_tags,
  is_indoor, is_outdoor,
  activity_url, image_url, location_zone,
  date_label, date_label_en, date_start, date_end,
  recurrence_type, seasonal_months, weekly_days,
  status, submitted_by
)
SELECT
  'Gornergrat Bahn',
  'Zermatt',
  'nature',
  'Train à crémaillère vers 3089m face au Cervin. Plus haut chemin de fer à ciel ouvert d''Europe.',
  45.9839, 7.7956,
  240, 5,
  ARRAY['Parking','Reservation necessaire'],
  ARRAY['Été','Automne','Hiver'],
  ARRAY['Famille','Couple','Amis'],
  false, true,
  'https://www.gornergrat.ch', NULL, 'loc_upper',
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Gornergrat Bahn' AND location_name = 'Zermatt'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Gornergrat Bahn' AND location_name = 'Zermatt'
);

-- Glacier d'Aletsch
INSERT INTO activity_submissions (
  title, location_name, category, description,
  latitude, longitude, duration_minutes, price_level,
  features, seasons, social_tags,
  is_indoor, is_outdoor,
  activity_url, image_url, location_zone,
  date_label, date_label_en, date_start, date_end,
  recurrence_type, seasonal_months, weekly_days,
  status, submitted_by
)
SELECT
  'Glacier d''Aletsch',
  'Bettmeralp',
  'nature',
  'Plus grand glacier des Alpes (23 km). Sites UNESCO, accès en téléphérique.',
  46.4361, 8.0386,
  360, 4,
  ARRAY['Parking','Reservation necessaire'],
  ARRAY['Été','Automne'],
  ARRAY['Couple','Amis','Famille'],
  false, true,
  'https://www.aletscharena.ch', NULL, 'loc_upper',
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Glacier d''Aletsch' AND location_name = 'Bettmeralp'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Glacier d''Aletsch' AND location_name = 'Bettmeralp'
);

-- Lac d'Émosson
INSERT INTO activity_submissions (
  title, location_name, category, description,
  latitude, longitude, duration_minutes, price_level,
  features, seasons, social_tags,
  is_indoor, is_outdoor,
  activity_url, image_url, location_zone,
  date_label, date_label_en, date_start, date_end,
  recurrence_type, seasonal_months, weekly_days,
  status, submitted_by
)
SELECT
  'Lac d''Émosson',
  'Finhaut',
  'nature',
  'Barrage et lac de montagne à 1930m. Empreintes de dinosaures, train du Mont-Blanc.',
  46.0731, 6.9242,
  360, 3,
  ARRAY['Parking','Reservation necessaire'],
  ARRAY['Été','Automne'],
  ARRAY['Famille','Couple','Amis'],
  false, true,
  'https://www.verticalp-emosson.ch', NULL, 'loc_lower',
  NULL, NULL, NULL, NULL,
  'seasonal', ARRAY[5,6,7,8,9,10]::int[], NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Lac d''Émosson' AND location_name = 'Finhaut'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Lac d''Émosson' AND location_name = 'Finhaut'
);

-- Pyramides d'Euseigne
INSERT INTO activity_submissions (
  title, location_name, category, description,
  latitude, longitude, duration_minutes, price_level,
  features, seasons, social_tags,
  is_indoor, is_outdoor,
  activity_url, image_url, location_zone,
  date_label, date_label_en, date_start, date_end,
  recurrence_type, seasonal_months, weekly_days,
  status, submitted_by
)
SELECT
  'Pyramides d''Euseigne',
  'Euseigne',
  'nature',
  'Formations rocheuses uniques en Europe : colonnes de moraine coiffées de blocs rocheux.',
  46.17, 7.435,
  60, 1,
  ARRAY['Parking'],
  ARRAY['Printemps','Été','Automne'],
  ARRAY['Famille','Couple','Solo'],
  false, true,
  'https://www.evolene-region.ch', NULL, 'loc_central',
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Pyramides d''Euseigne' AND location_name = 'Euseigne'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Pyramides d''Euseigne' AND location_name = 'Euseigne'
);

-- Bisse de Clavau
INSERT INTO activity_submissions (
  title, location_name, category, description,
  latitude, longitude, duration_minutes, price_level,
  features, seasons, social_tags,
  is_indoor, is_outdoor,
  activity_url, image_url, location_zone,
  date_label, date_label_en, date_start, date_end,
  recurrence_type, seasonal_months, weekly_days,
  status, submitted_by
)
SELECT
  'Bisse de Clavau',
  'Sion',
  'nature',
  'Le plus accessible des bisses, le long des vignes. Vue sur Sion et la vallée du Rhône.',
  46.2208, 7.3889,
  180, 1,
  ARRAY[]::text[],
  ARRAY['Printemps','Été','Automne'],
  ARRAY['Famille','Couple','Solo'],
  false, true,
  'https://www.siontourisme.ch', NULL, 'loc_central',
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Bisse de Clavau' AND location_name = 'Sion'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Bisse de Clavau' AND location_name = 'Sion'
);

-- Lac Bleu d'Arolla
INSERT INTO activity_submissions (
  title, location_name, category, description,
  latitude, longitude, duration_minutes, price_level,
  features, seasons, social_tags,
  is_indoor, is_outdoor,
  activity_url, image_url, location_zone,
  date_label, date_label_en, date_start, date_end,
  recurrence_type, seasonal_months, weekly_days,
  status, submitted_by
)
SELECT
  'Lac Bleu d''Arolla',
  'Arolla',
  'nature',
  'Petit lac de montagne à 2090m. Couleur turquoise saisissante. Accès randonnée 1h.',
  46.0322, 7.485,
  240, 1,
  ARRAY[]::text[],
  ARRAY['Été','Automne'],
  ARRAY['Couple','Solo','Amis'],
  false, true,
  NULL, NULL, 'loc_central',
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Lac Bleu d''Arolla' AND location_name = 'Arolla'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Lac Bleu d''Arolla' AND location_name = 'Arolla'
);

-- Mont Fort
INSERT INTO activity_submissions (
  title, location_name, category, description,
  latitude, longitude, duration_minutes, price_level,
  features, seasons, social_tags,
  is_indoor, is_outdoor,
  activity_url, image_url, location_zone,
  date_label, date_label_en, date_start, date_end,
  recurrence_type, seasonal_months, weekly_days,
  status, submitted_by
)
SELECT
  'Mont Fort',
  'Verbier',
  'nature',
  'Sommet à 3328m accessible en téléphérique. Vue 360° sur 4000m suisses, italiens et français.',
  46.0833, 7.3056,
  240, 5,
  ARRAY['Reservation necessaire'],
  ARRAY['Été','Hiver'],
  ARRAY['Couple','Amis'],
  false, true,
  'https://www.verbier4vallees.ch', NULL, 'loc_central',
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Mont Fort' AND location_name = 'Verbier'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Mont Fort' AND location_name = 'Verbier'
);

-- Cabane des Vignettes
INSERT INTO activity_submissions (
  title, location_name, category, description,
  latitude, longitude, duration_minutes, price_level,
  features, seasons, social_tags,
  is_indoor, is_outdoor,
  activity_url, image_url, location_zone,
  date_label, date_label_en, date_start, date_end,
  recurrence_type, seasonal_months, weekly_days,
  status, submitted_by
)
SELECT
  'Cabane des Vignettes',
  'Arolla',
  'nature',
  'Refuge alpin à 3160m, base pour la haute route Chamonix-Zermatt. Panorama exceptionnel.',
  45.9889, 7.45,
  480, 3,
  ARRAY['Reservation necessaire'],
  ARRAY['Été'],
  ARRAY['Solo','Amis','Couple'],
  false, true,
  'https://www.cabanedesvignettes.ch', NULL, 'loc_central',
  NULL, NULL, NULL, NULL,
  'seasonal', ARRAY[6,7,8,9]::int[], NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Cabane des Vignettes' AND location_name = 'Arolla'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Cabane des Vignettes' AND location_name = 'Arolla'
);

-- Lac de Tseuzier
INSERT INTO activity_submissions (
  title, location_name, category, description,
  latitude, longitude, duration_minutes, price_level,
  features, seasons, social_tags,
  is_indoor, is_outdoor,
  activity_url, image_url, location_zone,
  date_label, date_label_en, date_start, date_end,
  recurrence_type, seasonal_months, weekly_days,
  status, submitted_by
)
SELECT
  'Lac de Tseuzier',
  'Anzère',
  'nature',
  'Lac de barrage à 1777m, sentier autour. Vue Bernoises et Valaisannes.',
  46.3506, 7.4111,
  180, 1,
  ARRAY['Parking'],
  ARRAY['Printemps','Été','Automne'],
  ARRAY['Famille','Couple','Solo'],
  false, true,
  NULL, NULL, 'loc_central',
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Lac de Tseuzier' AND location_name = 'Anzère'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Lac de Tseuzier' AND location_name = 'Anzère'
);

-- Gorges du Trient
INSERT INTO activity_submissions (
  title, location_name, category, description,
  latitude, longitude, duration_minutes, price_level,
  features, seasons, social_tags,
  is_indoor, is_outdoor,
  activity_url, image_url, location_zone,
  date_label, date_label_en, date_start, date_end,
  recurrence_type, seasonal_months, weekly_days,
  status, submitted_by
)
SELECT
  'Gorges du Trient',
  'Vernayaz',
  'nature',
  'Sentier suspendu dans une gorge profonde de 100m, sur 750m. Cascade impressionnante.',
  46.1311, 7.0497,
  90, 2,
  ARRAY['Parking','Horaires restreints'],
  ARRAY['Printemps','Été','Automne'],
  ARRAY['Famille','Couple','Solo'],
  false, true,
  'https://www.gorgesdutrient.ch', NULL, 'loc_lower',
  NULL, NULL, NULL, NULL,
  'seasonal', ARRAY[5,6,7,8,9,10]::int[], NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Gorges du Trient' AND location_name = 'Vernayaz'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Gorges du Trient' AND location_name = 'Vernayaz'
);

-- Lac de Salanfe
INSERT INTO activity_submissions (
  title, location_name, category, description,
  latitude, longitude, duration_minutes, price_level,
  features, seasons, social_tags,
  is_indoor, is_outdoor,
  activity_url, image_url, location_zone,
  date_label, date_label_en, date_start, date_end,
  recurrence_type, seasonal_months, weekly_days,
  status, submitted_by
)
SELECT
  'Lac de Salanfe',
  'Mex',
  'nature',
  'Lac alpin à 1925m entouré de sommets. Randonnée 4h depuis Van d''En Haut.',
  46.1639, 7.0306,
  360, 1,
  ARRAY[]::text[],
  ARRAY['Été','Automne'],
  ARRAY['Solo','Amis','Couple'],
  false, true,
  NULL, NULL, 'loc_lower',
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Lac de Salanfe' AND location_name = 'Mex'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Lac de Salanfe' AND location_name = 'Mex'
);

-- Pic Chaussy
INSERT INTO activity_submissions (
  title, location_name, category, description,
  latitude, longitude, duration_minutes, price_level,
  features, seasons, social_tags,
  is_indoor, is_outdoor,
  activity_url, image_url, location_zone,
  date_label, date_label_en, date_start, date_end,
  recurrence_type, seasonal_months, weekly_days,
  status, submitted_by
)
SELECT
  'Pic Chaussy',
  'Les Mosses',
  'nature',
  'Sommet de 2351m accessible en 4h depuis Lausenen. Vue Diablerets + Cervin.',
  46.3792, 7.1417,
  360, 1,
  ARRAY[]::text[],
  ARRAY['Été','Automne'],
  ARRAY['Solo','Amis','Couple'],
  false, true,
  NULL, NULL, 'loc_lower',
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Pic Chaussy' AND location_name = 'Les Mosses'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Pic Chaussy' AND location_name = 'Les Mosses'
);

-- Dent du Midi
INSERT INTO activity_submissions (
  title, location_name, category, description,
  latitude, longitude, duration_minutes, price_level,
  features, seasons, social_tags,
  is_indoor, is_outdoor,
  activity_url, image_url, location_zone,
  date_label, date_label_en, date_start, date_end,
  recurrence_type, seasonal_months, weekly_days,
  status, submitted_by
)
SELECT
  'Dent du Midi',
  'Champéry',
  'nature',
  'Massif emblématique des 7 sommets. Tour de la Dent du Midi : 4 jours de rando inoubliable.',
  46.1644, 6.9233,
  480, 2,
  ARRAY['Reservation necessaire'],
  ARRAY['Été','Automne'],
  ARRAY['Solo','Amis'],
  false, true,
  'https://www.champery.ch', NULL, 'loc_lower',
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Dent du Midi' AND location_name = 'Champéry'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Dent du Midi' AND location_name = 'Champéry'
);

-- Champ de tulipes Saxon
INSERT INTO activity_submissions (
  title, location_name, category, description,
  latitude, longitude, duration_minutes, price_level,
  features, seasons, social_tags,
  is_indoor, is_outdoor,
  activity_url, image_url, location_zone,
  date_label, date_label_en, date_start, date_end,
  recurrence_type, seasonal_months, weekly_days,
  status, submitted_by
)
SELECT
  'Champ de tulipes Saxon',
  'Saxon',
  'nature',
  'Champs de tulipes spectaculaires en avril-mai. Photos garanties, gratuit.',
  46.15, 7.175,
  60, 1,
  ARRAY['Parking'],
  ARRAY['Printemps'],
  ARRAY['Famille','Couple','Solo'],
  false, true,
  NULL, NULL, 'loc_central',
  'Avril-mai', 'April-May', NULL, NULL,
  'seasonal', ARRAY[4,5]::int[], NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Champ de tulipes Saxon' AND location_name = 'Saxon'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Champ de tulipes Saxon' AND location_name = 'Saxon'
);

-- Lac de Montorge
INSERT INTO activity_submissions (
  title, location_name, category, description,
  latitude, longitude, duration_minutes, price_level,
  features, seasons, social_tags,
  is_indoor, is_outdoor,
  activity_url, image_url, location_zone,
  date_label, date_label_en, date_start, date_end,
  recurrence_type, seasonal_months, weekly_days,
  status, submitted_by
)
SELECT
  'Lac de Montorge',
  'Sion',
  'nature',
  'Petit lac à proximité de Sion, sentier didactique nature, observation oiseaux.',
  46.2417, 7.3406,
  90, 1,
  ARRAY['Parking'],
  ARRAY['Printemps','Été','Automne'],
  ARRAY['Famille','Solo','Couple'],
  false, true,
  NULL, NULL, 'loc_central',
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Lac de Montorge' AND location_name = 'Sion'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Lac de Montorge' AND location_name = 'Sion'
);

-- Bisse du Ro
INSERT INTO activity_submissions (
  title, location_name, category, description,
  latitude, longitude, duration_minutes, price_level,
  features, seasons, social_tags,
  is_indoor, is_outdoor,
  activity_url, image_url, location_zone,
  date_label, date_label_en, date_start, date_end,
  recurrence_type, seasonal_months, weekly_days,
  status, submitted_by
)
SELECT
  'Bisse du Ro',
  'Crans-Montana',
  'nature',
  'Bisse spectaculaire creusé dans la falaise. Vues vertigineuses, pas pour le vertige.',
  46.3083, 7.4889,
  180, 1,
  ARRAY[]::text[],
  ARRAY['Printemps','Été','Automne'],
  ARRAY['Solo','Amis','Couple'],
  false, true,
  'https://www.crans-montana.ch', NULL, 'loc_central',
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Bisse du Ro' AND location_name = 'Crans-Montana'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Bisse du Ro' AND location_name = 'Crans-Montana'
);

-- Riffelsee
INSERT INTO activity_submissions (
  title, location_name, category, description,
  latitude, longitude, duration_minutes, price_level,
  features, seasons, social_tags,
  is_indoor, is_outdoor,
  activity_url, image_url, location_zone,
  date_label, date_label_en, date_start, date_end,
  recurrence_type, seasonal_months, weekly_days,
  status, submitted_by
)
SELECT
  'Riffelsee',
  'Zermatt',
  'nature',
  'Petit lac à 2757m offrant un reflet parfait du Cervin. Spot photo iconique de Suisse.',
  45.9892, 7.7642,
  180, 4,
  ARRAY['Reservation necessaire'],
  ARRAY['Été','Automne'],
  ARRAY['Couple','Solo','Amis'],
  false, true,
  NULL, NULL, 'loc_upper',
  NULL, NULL, NULL, NULL,
  'seasonal', ARRAY[6,7,8,9,10]::int[], NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Riffelsee' AND location_name = 'Zermatt'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Riffelsee' AND location_name = 'Zermatt'
);

-- Marais des Iles Sion
INSERT INTO activity_submissions (
  title, location_name, category, description,
  latitude, longitude, duration_minutes, price_level,
  features, seasons, social_tags,
  is_indoor, is_outdoor,
  activity_url, image_url, location_zone,
  date_label, date_label_en, date_start, date_end,
  recurrence_type, seasonal_months, weekly_days,
  status, submitted_by
)
SELECT
  'Marais des Iles Sion',
  'Sion',
  'nature',
  'Réserve naturelle aux portes de Sion. Sentiers, oiseaux migrateurs, étangs.',
  46.2278, 7.3556,
  90, 1,
  ARRAY['Parking'],
  ARRAY['Printemps','Été','Automne'],
  ARRAY['Famille','Solo'],
  false, true,
  NULL, NULL, 'loc_central',
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Marais des Iles Sion' AND location_name = 'Sion'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Marais des Iles Sion' AND location_name = 'Sion'
);

-- Château de Valère
INSERT INTO activity_submissions (
  title, location_name, category, description,
  latitude, longitude, duration_minutes, price_level,
  features, seasons, social_tags,
  is_indoor, is_outdoor,
  activity_url, image_url, location_zone,
  date_label, date_label_en, date_start, date_end,
  recurrence_type, seasonal_months, weekly_days,
  status, submitted_by
)
SELECT
  'Château de Valère',
  'Sion',
  'culture',
  'Forteresse médiévale et basilique avec le plus ancien orgue jouable du monde (1430).',
  46.23, 7.3636,
  120, 2,
  ARRAY['Parking'],
  ARRAY['Printemps','Été','Automne'],
  ARRAY['Couple','Famille','Solo'],
  true, true,
  'https://www.musees-valais.ch/musee-d-histoire', NULL, 'loc_central',
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Château de Valère' AND location_name = 'Sion'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Château de Valère' AND location_name = 'Sion'
);

-- Château de Tourbillon
INSERT INTO activity_submissions (
  title, location_name, category, description,
  latitude, longitude, duration_minutes, price_level,
  features, seasons, social_tags,
  is_indoor, is_outdoor,
  activity_url, image_url, location_zone,
  date_label, date_label_en, date_start, date_end,
  recurrence_type, seasonal_months, weekly_days,
  status, submitted_by
)
SELECT
  'Château de Tourbillon',
  'Sion',
  'culture',
  'Ruines d''un château épiscopal du XIIIe siècle, vue 360° sur la vallée du Rhône.',
  46.2347, 7.3614,
  90, 1,
  ARRAY[]::text[],
  ARRAY['Printemps','Été','Automne'],
  ARRAY['Famille','Couple','Solo'],
  false, true,
  'https://www.siontourisme.ch', NULL, 'loc_central',
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Château de Tourbillon' AND location_name = 'Sion'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Château de Tourbillon' AND location_name = 'Sion'
);

-- Abbaye de Saint-Maurice
INSERT INTO activity_submissions (
  title, location_name, category, description,
  latitude, longitude, duration_minutes, price_level,
  features, seasons, social_tags,
  is_indoor, is_outdoor,
  activity_url, image_url, location_zone,
  date_label, date_label_en, date_start, date_end,
  recurrence_type, seasonal_months, weekly_days,
  status, submitted_by
)
SELECT
  'Abbaye de Saint-Maurice',
  'Saint-Maurice',
  'culture',
  'Plus ancien monastère d''Europe occidentale (515). Trésor avec joaillerie millénaire.',
  46.2189, 7.0064,
  120, 2,
  ARRAY['Reservation necessaire'],
  ARRAY['Printemps','Été','Automne'],
  ARRAY['Couple','Famille','Solo'],
  true, false,
  'https://www.abbaye-stmaurice.ch', NULL, 'loc_lower',
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Abbaye de Saint-Maurice' AND location_name = 'Saint-Maurice'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Abbaye de Saint-Maurice' AND location_name = 'Saint-Maurice'
);

-- Musée et Chiens du Saint-Bernard
INSERT INTO activity_submissions (
  title, location_name, category, description,
  latitude, longitude, duration_minutes, price_level,
  features, seasons, social_tags,
  is_indoor, is_outdoor,
  activity_url, image_url, location_zone,
  date_label, date_label_en, date_start, date_end,
  recurrence_type, seasonal_months, weekly_days,
  status, submitted_by
)
SELECT
  'Musée et Chiens du Saint-Bernard',
  'Martigny',
  'culture',
  'Histoire des chiens du col, chenil avec vrais saint-bernards à voir et caresser.',
  46.1011, 7.075,
  120, 2,
  ARRAY['Parking'],
  ARRAY['Printemps','Été','Automne','Hiver'],
  ARRAY['Famille'],
  true, false,
  'https://www.museesaintbernard.ch', NULL, 'loc_lower',
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Musée et Chiens du Saint-Bernard' AND location_name = 'Martigny'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Musée et Chiens du Saint-Bernard' AND location_name = 'Martigny'
);

-- Musée du Lötschental
INSERT INTO activity_submissions (
  title, location_name, category, description,
  latitude, longitude, duration_minutes, price_level,
  features, seasons, social_tags,
  is_indoor, is_outdoor,
  activity_url, image_url, location_zone,
  date_label, date_label_en, date_start, date_end,
  recurrence_type, seasonal_months, weekly_days,
  status, submitted_by
)
SELECT
  'Musée du Lötschental',
  'Kippel',
  'culture',
  'Musée régional des traditions du Lötschental : masques, costumes, art populaire.',
  46.4133, 7.7867,
  90, 2,
  ARRAY[]::text[],
  ARRAY['Printemps','Été','Automne','Hiver'],
  ARRAY['Famille','Couple','Solo'],
  true, false,
  'https://www.loetschentalermuseum.ch', NULL, 'loc_upper',
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Musée du Lötschental' AND location_name = 'Kippel'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Musée du Lötschental' AND location_name = 'Kippel'
);

-- Musée des bisses
INSERT INTO activity_submissions (
  title, location_name, category, description,
  latitude, longitude, duration_minutes, price_level,
  features, seasons, social_tags,
  is_indoor, is_outdoor,
  activity_url, image_url, location_zone,
  date_label, date_label_en, date_start, date_end,
  recurrence_type, seasonal_months, weekly_days,
  status, submitted_by
)
SELECT
  'Musée des bisses',
  'Botyre',
  'culture',
  'Musée consacré aux bisses du Valais. Maquettes, vidéos, sentier didactique.',
  46.2433, 7.4444,
  90, 2,
  ARRAY['Parking'],
  ARRAY['Printemps','Été','Automne'],
  ARRAY['Famille','Solo'],
  true, false,
  'https://www.musee-des-bisses.ch', NULL, 'loc_central',
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Musée des bisses' AND location_name = 'Botyre'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Musée des bisses' AND location_name = 'Botyre'
);

-- Musée d'art du Valais
INSERT INTO activity_submissions (
  title, location_name, category, description,
  latitude, longitude, duration_minutes, price_level,
  features, seasons, social_tags,
  is_indoor, is_outdoor,
  activity_url, image_url, location_zone,
  date_label, date_label_en, date_start, date_end,
  recurrence_type, seasonal_months, weekly_days,
  status, submitted_by
)
SELECT
  'Musée d''art du Valais',
  'Sion',
  'culture',
  'Collections d''art du XVIIe siècle à nos jours. Expositions temporaires de qualité.',
  46.2306, 7.3603,
  90, 2,
  ARRAY[]::text[],
  ARRAY['Printemps','Été','Automne','Hiver'],
  ARRAY['Solo','Couple'],
  true, false,
  'https://www.musees-valais.ch/musee-d-art', NULL, 'loc_central',
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Musée d''art du Valais' AND location_name = 'Sion'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Musée d''art du Valais' AND location_name = 'Sion'
);

-- Mines de Bagnes
INSERT INTO activity_submissions (
  title, location_name, category, description,
  latitude, longitude, duration_minutes, price_level,
  features, seasons, social_tags,
  is_indoor, is_outdoor,
  activity_url, image_url, location_zone,
  date_label, date_label_en, date_start, date_end,
  recurrence_type, seasonal_months, weekly_days,
  status, submitted_by
)
SELECT
  'Mines de Bagnes',
  'Le Châble',
  'culture',
  'Mines de cuivre exploitées pendant 200 ans. Visite guidée souterraine, casque obligatoire.',
  46.0647, 7.2125,
  120, 3,
  ARRAY['Reservation necessaire'],
  ARRAY['Été','Automne'],
  ARRAY['Famille','Couple','Amis'],
  false, true,
  'https://www.mines.bagnes.ch', NULL, 'loc_central',
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Mines de Bagnes' AND location_name = 'Le Châble'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Mines de Bagnes' AND location_name = 'Le Châble'
);

-- Stockalperschloss
INSERT INTO activity_submissions (
  title, location_name, category, description,
  latitude, longitude, duration_minutes, price_level,
  features, seasons, social_tags,
  is_indoor, is_outdoor,
  activity_url, image_url, location_zone,
  date_label, date_label_en, date_start, date_end,
  recurrence_type, seasonal_months, weekly_days,
  status, submitted_by
)
SELECT
  'Stockalperschloss',
  'Brig',
  'culture',
  'Plus grand château privé baroque de Suisse (XVIIe), bâti par le ''roi du Simplon''.',
  46.3167, 7.9833,
  120, 3,
  ARRAY['Reservation necessaire'],
  ARRAY['Printemps','Été','Automne'],
  ARRAY['Famille','Couple','Solo'],
  true, false,
  'https://www.brig-simplon.ch/stockalperschloss', NULL, 'loc_upper',
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Stockalperschloss' AND location_name = 'Brig'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Stockalperschloss' AND location_name = 'Brig'
);

-- Église de Rarogne
INSERT INTO activity_submissions (
  title, location_name, category, description,
  latitude, longitude, duration_minutes, price_level,
  features, seasons, social_tags,
  is_indoor, is_outdoor,
  activity_url, image_url, location_zone,
  date_label, date_label_en, date_start, date_end,
  recurrence_type, seasonal_months, weekly_days,
  status, submitted_by
)
SELECT
  'Église de Rarogne',
  'Raron',
  'culture',
  'Église perchée sur un piton rocheux. Tombe de Rilke. Vue spectaculaire.',
  46.3083, 7.8,
  60, 1,
  ARRAY[]::text[],
  ARRAY['Printemps','Été','Automne'],
  ARRAY['Solo','Couple'],
  true, false,
  NULL, NULL, 'loc_upper',
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Église de Rarogne' AND location_name = 'Raron'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Église de Rarogne' AND location_name = 'Raron'
);

-- Musée Suisse de Spéléologie
INSERT INTO activity_submissions (
  title, location_name, category, description,
  latitude, longitude, duration_minutes, price_level,
  features, seasons, social_tags,
  is_indoor, is_outdoor,
  activity_url, image_url, location_zone,
  date_label, date_label_en, date_start, date_end,
  recurrence_type, seasonal_months, weekly_days,
  status, submitted_by
)
SELECT
  'Musée Suisse de Spéléologie',
  'Chamoson',
  'culture',
  'Tout sur les grottes : géologie, faune cavernicole, équipements. Unique en Suisse.',
  46.2042, 7.2256,
  90, 2,
  ARRAY[]::text[],
  ARRAY['Printemps','Été','Automne','Hiver'],
  ARRAY['Famille','Solo'],
  true, false,
  'https://www.museespeleo.ch', NULL, 'loc_central',
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Musée Suisse de Spéléologie' AND location_name = 'Chamoson'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Musée Suisse de Spéléologie' AND location_name = 'Chamoson'
);

-- Tibetisches Klosterhaus
INSERT INTO activity_submissions (
  title, location_name, category, description,
  latitude, longitude, duration_minutes, price_level,
  features, seasons, social_tags,
  is_indoor, is_outdoor,
  activity_url, image_url, location_zone,
  date_label, date_label_en, date_start, date_end,
  recurrence_type, seasonal_months, weekly_days,
  status, submitted_by
)
SELECT
  'Tibetisches Klosterhaus',
  'Visp',
  'culture',
  'Petit temple bouddhiste, le seul du Valais. Visite et méditation possibles.',
  46.2944, 7.8806,
  60, 1,
  ARRAY[]::text[],
  ARRAY['Printemps','Été','Automne','Hiver'],
  ARRAY['Solo','Couple'],
  true, false,
  NULL, NULL, 'loc_upper',
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Tibetisches Klosterhaus' AND location_name = 'Visp'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Tibetisches Klosterhaus' AND location_name = 'Visp'
);

-- Damien Germanier
INSERT INTO activity_submissions (
  title, location_name, category, description,
  latitude, longitude, duration_minutes, price_level,
  features, seasons, social_tags,
  is_indoor, is_outdoor,
  activity_url, image_url, location_zone,
  date_label, date_label_en, date_start, date_end,
  recurrence_type, seasonal_months, weekly_days,
  status, submitted_by
)
SELECT
  'Damien Germanier',
  'Sion',
  'gastronomy',
  'Restaurant gastronomique 1 étoile Michelin. Cuisine valaisanne créative, produits locaux.',
  46.2306, 7.3592,
  240, 5,
  ARRAY['Reservation necessaire'],
  ARRAY['Printemps','Été','Automne','Hiver'],
  ARRAY['Couple','Amis'],
  true, false,
  'https://www.damiengermanier.ch', NULL, 'loc_central',
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Damien Germanier' AND location_name = 'Sion'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Damien Germanier' AND location_name = 'Sion'
);

-- Caves Provins
INSERT INTO activity_submissions (
  title, location_name, category, description,
  latitude, longitude, duration_minutes, price_level,
  features, seasons, social_tags,
  is_indoor, is_outdoor,
  activity_url, image_url, location_zone,
  date_label, date_label_en, date_start, date_end,
  recurrence_type, seasonal_months, weekly_days,
  status, submitted_by
)
SELECT
  'Caves Provins',
  'Sion',
  'gastronomy',
  'Plus grande cave coopérative de Suisse. Visite + dégustation de Petite Arvine, Cornalin, Humagne.',
  46.2297, 7.3686,
  90, 2,
  ARRAY['Reservation necessaire'],
  ARRAY['Printemps','Été','Automne','Hiver'],
  ARRAY['Couple','Amis'],
  true, false,
  'https://www.provins.ch', NULL, 'loc_central',
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Caves Provins' AND location_name = 'Sion'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Caves Provins' AND location_name = 'Sion'
);

-- Château de Villa
INSERT INTO activity_submissions (
  title, location_name, category, description,
  latitude, longitude, duration_minutes, price_level,
  features, seasons, social_tags,
  is_indoor, is_outdoor,
  activity_url, image_url, location_zone,
  date_label, date_label_en, date_start, date_end,
  recurrence_type, seasonal_months, weekly_days,
  status, submitted_by
)
SELECT
  'Château de Villa',
  'Sierre',
  'gastronomy',
  'Restaurant gastronomique dans un château renaissance. Cuisine valaisanne moderne.',
  46.2917, 7.5333,
  180, 4,
  ARRAY['Reservation necessaire'],
  ARRAY['Printemps','Été','Automne','Hiver'],
  ARRAY['Couple','Amis'],
  true, false,
  'https://www.chateaudevilla.ch', NULL, 'loc_central',
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Château de Villa' AND location_name = 'Sierre'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Château de Villa' AND location_name = 'Sierre'
);

-- Le Mille Sens
INSERT INTO activity_submissions (
  title, location_name, category, description,
  latitude, longitude, duration_minutes, price_level,
  features, seasons, social_tags,
  is_indoor, is_outdoor,
  activity_url, image_url, location_zone,
  date_label, date_label_en, date_start, date_end,
  recurrence_type, seasonal_months, weekly_days,
  status, submitted_by
)
SELECT
  'Le Mille Sens',
  'Sion',
  'gastronomy',
  'Bistro de quartier réputé, cuisine du marché. Très bon rapport qualité-prix.',
  46.2333, 7.3611,
  120, 3,
  ARRAY['Reservation necessaire'],
  ARRAY['Printemps','Été','Automne','Hiver'],
  ARRAY['Couple','Amis','Famille'],
  true, false,
  'https://www.lemillesens.ch', NULL, 'loc_central',
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Le Mille Sens' AND location_name = 'Sion'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Le Mille Sens' AND location_name = 'Sion'
);

-- Heida Visperterminen
INSERT INTO activity_submissions (
  title, location_name, category, description,
  latitude, longitude, duration_minutes, price_level,
  features, seasons, social_tags,
  is_indoor, is_outdoor,
  activity_url, image_url, location_zone,
  date_label, date_label_en, date_start, date_end,
  recurrence_type, seasonal_months, weekly_days,
  status, submitted_by
)
SELECT
  'Heida Visperterminen',
  'Visperterminen',
  'gastronomy',
  'Plus haute vigne d''Europe (1100m). Dégustation Heida (Païen) avec vue spectaculaire.',
  46.2683, 7.8839,
  120, 3,
  ARRAY['Parking'],
  ARRAY['Printemps','Été','Automne'],
  ARRAY['Couple','Amis'],
  false, true,
  'https://www.stjodernkellerei.ch', NULL, 'loc_upper',
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Heida Visperterminen' AND location_name = 'Visperterminen'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Heida Visperterminen' AND location_name = 'Visperterminen'
);

-- Domaine du Mont d'Or
INSERT INTO activity_submissions (
  title, location_name, category, description,
  latitude, longitude, duration_minutes, price_level,
  features, seasons, social_tags,
  is_indoor, is_outdoor,
  activity_url, image_url, location_zone,
  date_label, date_label_en, date_start, date_end,
  recurrence_type, seasonal_months, weekly_days,
  status, submitted_by
)
SELECT
  'Domaine du Mont d''Or',
  'Pont-de-la-Morge',
  'gastronomy',
  'Domaine viticole historique. Cave creusée dans la roche. Dégustations et visites.',
  46.22, 7.3,
  90, 3,
  ARRAY['Reservation necessaire'],
  ARRAY['Printemps','Été','Automne'],
  ARRAY['Couple','Amis'],
  true, false,
  'https://www.montdor-wine.ch', NULL, 'loc_central',
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Domaine du Mont d''Or' AND location_name = 'Pont-de-la-Morge'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Domaine du Mont d''Or' AND location_name = 'Pont-de-la-Morge'
);

-- Restaurant Schloss Leuk
INSERT INTO activity_submissions (
  title, location_name, category, description,
  latitude, longitude, duration_minutes, price_level,
  features, seasons, social_tags,
  is_indoor, is_outdoor,
  activity_url, image_url, location_zone,
  date_label, date_label_en, date_start, date_end,
  recurrence_type, seasonal_months, weekly_days,
  status, submitted_by
)
SELECT
  'Restaurant Schloss Leuk',
  'Leuk',
  'gastronomy',
  'Restaurant gastronomique dans un château. Cuisine méditerranéenne raffinée.',
  46.3144, 7.6342,
  180, 4,
  ARRAY['Reservation necessaire'],
  ARRAY['Printemps','Été','Automne'],
  ARRAY['Couple'],
  true, false,
  NULL, NULL, 'loc_upper',
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Restaurant Schloss Leuk' AND location_name = 'Leuk'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Restaurant Schloss Leuk' AND location_name = 'Leuk'
);

-- Brasserie Valaisanne
INSERT INTO activity_submissions (
  title, location_name, category, description,
  latitude, longitude, duration_minutes, price_level,
  features, seasons, social_tags,
  is_indoor, is_outdoor,
  activity_url, image_url, location_zone,
  date_label, date_label_en, date_start, date_end,
  recurrence_type, seasonal_months, weekly_days,
  status, submitted_by
)
SELECT
  'Brasserie Valaisanne',
  'Sion',
  'gastronomy',
  'Brasserie historique du Valais (depuis 1865). Visite avec dégustation des bières locales.',
  46.23, 7.36,
  90, 2,
  ARRAY['Reservation necessaire'],
  ARRAY['Printemps','Été','Automne','Hiver'],
  ARRAY['Amis'],
  true, false,
  'https://www.valaisanne.ch', NULL, 'loc_central',
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Brasserie Valaisanne' AND location_name = 'Sion'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Brasserie Valaisanne' AND location_name = 'Sion'
);

-- Caveau de Salquenen
INSERT INTO activity_submissions (
  title, location_name, category, description,
  latitude, longitude, duration_minutes, price_level,
  features, seasons, social_tags,
  is_indoor, is_outdoor,
  activity_url, image_url, location_zone,
  date_label, date_label_en, date_start, date_end,
  recurrence_type, seasonal_months, weekly_days,
  status, submitted_by
)
SELECT
  'Caveau de Salquenen',
  'Salquenen',
  'gastronomy',
  'Plus de 60 vignerons de Salgesch présentent leurs vins. Idéal pour découvrir le Pinot Noir.',
  46.3083, 7.5667,
  120, 2,
  ARRAY['Parking','Reservation necessaire'],
  ARRAY['Printemps','Été','Automne','Hiver'],
  ARRAY['Couple','Amis'],
  true, false,
  'https://www.salgesch.ch', NULL, 'loc_central',
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Caveau de Salquenen' AND location_name = 'Salquenen'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Caveau de Salquenen' AND location_name = 'Salquenen'
);

-- Restaurant Ogo Sion
INSERT INTO activity_submissions (
  title, location_name, category, description,
  latitude, longitude, duration_minutes, price_level,
  features, seasons, social_tags,
  is_indoor, is_outdoor,
  activity_url, image_url, location_zone,
  date_label, date_label_en, date_start, date_end,
  recurrence_type, seasonal_months, weekly_days,
  status, submitted_by
)
SELECT
  'Restaurant Ogo Sion',
  'Sion',
  'gastronomy',
  'Restaurant tendance, cuisine fusion locale. Brunch dominical réputé.',
  46.23, 7.36,
  120, 3,
  ARRAY['Reservation necessaire'],
  ARRAY['Printemps','Été','Automne','Hiver'],
  ARRAY['Couple','Amis','Famille'],
  true, false,
  NULL, NULL, 'loc_central',
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Restaurant Ogo Sion' AND location_name = 'Sion'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Restaurant Ogo Sion' AND location_name = 'Sion'
);

-- Ski Verbier 4 Vallées
INSERT INTO activity_submissions (
  title, location_name, category, description,
  latitude, longitude, duration_minutes, price_level,
  features, seasons, social_tags,
  is_indoor, is_outdoor,
  activity_url, image_url, location_zone,
  date_label, date_label_en, date_start, date_end,
  recurrence_type, seasonal_months, weekly_days,
  status, submitted_by
)
SELECT
  'Ski Verbier 4 Vallées',
  'Verbier',
  'sport',
  '412 km de pistes, 92 remontées. Plus grand domaine de Suisse romande, cadre Mont-Blanc.',
  46.0961, 7.2286,
  480, 5,
  ARRAY['Parking','Reservation necessaire'],
  ARRAY['Hiver'],
  ARRAY['Famille','Amis','Couple'],
  false, true,
  'https://www.verbier.ch', NULL, 'loc_central',
  NULL, NULL, NULL, NULL,
  'seasonal', ARRAY[12,1,2,3,4]::int[], NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Ski Verbier 4 Vallées' AND location_name = 'Verbier'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Ski Verbier 4 Vallées' AND location_name = 'Verbier'
);

-- Ski Crans-Montana
INSERT INTO activity_submissions (
  title, location_name, category, description,
  latitude, longitude, duration_minutes, price_level,
  features, seasons, social_tags,
  is_indoor, is_outdoor,
  activity_url, image_url, location_zone,
  date_label, date_label_en, date_start, date_end,
  recurrence_type, seasonal_months, weekly_days,
  status, submitted_by
)
SELECT
  'Ski Crans-Montana',
  'Crans-Montana',
  'sport',
  '140 km de pistes ensoleillées, vue 360° sur les Alpes. Domaine de prestige.',
  46.3117, 7.4853,
  480, 5,
  ARRAY['Parking'],
  ARRAY['Hiver'],
  ARRAY['Famille','Couple','Amis'],
  false, true,
  'https://www.crans-montana.ch', NULL, 'loc_central',
  NULL, NULL, NULL, NULL,
  'seasonal', ARRAY[12,1,2,3,4]::int[], NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Ski Crans-Montana' AND location_name = 'Crans-Montana'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Ski Crans-Montana' AND location_name = 'Crans-Montana'
);

-- Ski Zermatt-Cervinia
INSERT INTO activity_submissions (
  title, location_name, category, description,
  latitude, longitude, duration_minutes, price_level,
  features, seasons, social_tags,
  is_indoor, is_outdoor,
  activity_url, image_url, location_zone,
  date_label, date_label_en, date_start, date_end,
  recurrence_type, seasonal_months, weekly_days,
  status, submitted_by
)
SELECT
  'Ski Zermatt-Cervinia',
  'Zermatt',
  'sport',
  '360 km de pistes Suisse + Italie. Glacier ouvert à l''année. Vue Cervin partout.',
  46.0207, 7.7491,
  480, 5,
  ARRAY['Parking'],
  ARRAY['Été','Hiver','Automne'],
  ARRAY['Famille','Couple','Amis'],
  false, true,
  'https://www.zermatt.ch', NULL, 'loc_upper',
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Ski Zermatt-Cervinia' AND location_name = 'Zermatt'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Ski Zermatt-Cervinia' AND location_name = 'Zermatt'
);

-- Ski Saas-Fee
INSERT INTO activity_submissions (
  title, location_name, category, description,
  latitude, longitude, duration_minutes, price_level,
  features, seasons, social_tags,
  is_indoor, is_outdoor,
  activity_url, image_url, location_zone,
  date_label, date_label_en, date_start, date_end,
  recurrence_type, seasonal_months, weekly_days,
  status, submitted_by
)
SELECT
  'Ski Saas-Fee',
  'Saas-Fee',
  'sport',
  '150 km de pistes au pied du Dom. Glacier accessible été comme hiver. Village sans voiture.',
  46.1086, 7.9272,
  480, 5,
  ARRAY['Parking'],
  ARRAY['Été','Hiver','Automne'],
  ARRAY['Famille','Couple','Amis'],
  false, true,
  'https://www.saas-fee.ch', NULL, 'loc_upper',
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Ski Saas-Fee' AND location_name = 'Saas-Fee'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Ski Saas-Fee' AND location_name = 'Saas-Fee'
);

-- Ski Champéry Portes du Soleil
INSERT INTO activity_submissions (
  title, location_name, category, description,
  latitude, longitude, duration_minutes, price_level,
  features, seasons, social_tags,
  is_indoor, is_outdoor,
  activity_url, image_url, location_zone,
  date_label, date_label_en, date_start, date_end,
  recurrence_type, seasonal_months, weekly_days,
  status, submitted_by
)
SELECT
  'Ski Champéry Portes du Soleil',
  'Champéry',
  'sport',
  'Domaine franco-suisse de 600 km de pistes. 12 stations reliées, ambiance internationale.',
  46.175, 6.8722,
  480, 5,
  ARRAY['Parking'],
  ARRAY['Hiver'],
  ARRAY['Famille','Couple','Amis'],
  false, true,
  'https://www.portesdusoleil.com', NULL, 'loc_lower',
  NULL, NULL, NULL, NULL,
  'seasonal', ARRAY[12,1,2,3,4]::int[], NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Ski Champéry Portes du Soleil' AND location_name = 'Champéry'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Ski Champéry Portes du Soleil' AND location_name = 'Champéry'
);

-- Ski Anzère
INSERT INTO activity_submissions (
  title, location_name, category, description,
  latitude, longitude, duration_minutes, price_level,
  features, seasons, social_tags,
  is_indoor, is_outdoor,
  activity_url, image_url, location_zone,
  date_label, date_label_en, date_start, date_end,
  recurrence_type, seasonal_months, weekly_days,
  status, submitted_by
)
SELECT
  'Ski Anzère',
  'Anzère',
  'sport',
  '60 km de pistes, station familiale, vue impressionnante sur la vallée du Rhône.',
  46.2842, 7.4108,
  480, 4,
  ARRAY['Parking'],
  ARRAY['Hiver'],
  ARRAY['Famille'],
  false, true,
  'https://www.anzere.ch', NULL, 'loc_central',
  NULL, NULL, NULL, NULL,
  'seasonal', ARRAY[12,1,2,3,4]::int[], NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Ski Anzère' AND location_name = 'Anzère'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Ski Anzère' AND location_name = 'Anzère'
);

-- VTT Verbier Bikepark
INSERT INTO activity_submissions (
  title, location_name, category, description,
  latitude, longitude, duration_minutes, price_level,
  features, seasons, social_tags,
  is_indoor, is_outdoor,
  activity_url, image_url, location_zone,
  date_label, date_label_en, date_start, date_end,
  recurrence_type, seasonal_months, weekly_days,
  status, submitted_by
)
SELECT
  'VTT Verbier Bikepark',
  'Verbier',
  'sport',
  'Plus grand bike park de Suisse romande. Pistes pour tous niveaux, remontées vélos.',
  46.0961, 7.2286,
  360, 4,
  ARRAY['Parking','Reservation necessaire'],
  ARRAY['Été','Automne'],
  ARRAY['Solo','Amis'],
  false, true,
  'https://www.verbier.ch/ete/bikepark', NULL, 'loc_central',
  NULL, NULL, NULL, NULL,
  'seasonal', ARRAY[6,7,8,9,10]::int[], NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'VTT Verbier Bikepark' AND location_name = 'Verbier'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'VTT Verbier Bikepark' AND location_name = 'Verbier'
);

-- Sierre-Zinal Trail
INSERT INTO activity_submissions (
  title, location_name, category, description,
  latitude, longitude, duration_minutes, price_level,
  features, seasons, social_tags,
  is_indoor, is_outdoor,
  activity_url, image_url, location_zone,
  date_label, date_label_en, date_start, date_end,
  recurrence_type, seasonal_months, weekly_days,
  status, submitted_by
)
SELECT
  'Sierre-Zinal Trail',
  'Sierre',
  'sport',
  'Course mythique de trail running (31 km, 2200m D+). Pour participer ou regarder en août.',
  46.2925, 7.5356,
  480, 1,
  ARRAY['Reservation necessaire'],
  ARRAY['Été'],
  ARRAY['Solo','Amis'],
  false, true,
  'https://www.sierre-zinal.com', NULL, 'loc_central',
  'Août 2026', 'August 2026', '2026-08-08'::date, '2026-08-09'::date,
  'one_off', NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Sierre-Zinal Trail' AND location_name = 'Sierre'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Sierre-Zinal Trail' AND location_name = 'Sierre'
);

-- Téléphérique du Petit Cervin
INSERT INTO activity_submissions (
  title, location_name, category, description,
  latitude, longitude, duration_minutes, price_level,
  features, seasons, social_tags,
  is_indoor, is_outdoor,
  activity_url, image_url, location_zone,
  date_label, date_label_en, date_start, date_end,
  recurrence_type, seasonal_months, weekly_days,
  status, submitted_by
)
SELECT
  'Téléphérique du Petit Cervin',
  'Zermatt',
  'sport',
  'Plus haut téléphérique d''Europe (3883m). Glacier paradise, ski d''été possible.',
  45.9389, 7.7178,
  240, 5,
  ARRAY['Reservation necessaire'],
  ARRAY['Été','Hiver','Automne'],
  ARRAY['Couple','Amis','Famille'],
  false, true,
  'https://www.matterhornparadise.ch', NULL, 'loc_upper',
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Téléphérique du Petit Cervin' AND location_name = 'Zermatt'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Téléphérique du Petit Cervin' AND location_name = 'Zermatt'
);

-- Cabane des Becs de Bosson
INSERT INTO activity_submissions (
  title, location_name, category, description,
  latitude, longitude, duration_minutes, price_level,
  features, seasons, social_tags,
  is_indoor, is_outdoor,
  activity_url, image_url, location_zone,
  date_label, date_label_en, date_start, date_end,
  recurrence_type, seasonal_months, weekly_days,
  status, submitted_by
)
SELECT
  'Cabane des Becs de Bosson',
  'Arolla',
  'sport',
  'Randonnée alpine d''une journée vers la cabane (2785m). Refuge avec vue, repas chauds.',
  46.025, 7.4889,
  360, 3,
  ARRAY['Reservation necessaire'],
  ARRAY['Été','Automne'],
  ARRAY['Solo','Amis'],
  false, true,
  NULL, NULL, 'loc_central',
  NULL, NULL, NULL, NULL,
  'seasonal', ARRAY[6,7,8,9,10]::int[], NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Cabane des Becs de Bosson' AND location_name = 'Arolla'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Cabane des Becs de Bosson' AND location_name = 'Arolla'
);

-- Ski de fond Goms
INSERT INTO activity_submissions (
  title, location_name, category, description,
  latitude, longitude, duration_minutes, price_level,
  features, seasons, social_tags,
  is_indoor, is_outdoor,
  activity_url, image_url, location_zone,
  date_label, date_label_en, date_start, date_end,
  recurrence_type, seasonal_months, weekly_days,
  status, submitted_by
)
SELECT
  'Ski de fond Goms',
  'Oberwald',
  'sport',
  '100 km de pistes de ski de fond dans la haute vallée du Rhône. Site nordique réputé.',
  46.5314, 8.3614,
  240, 3,
  ARRAY['Parking'],
  ARRAY['Hiver'],
  ARRAY['Famille','Solo','Couple'],
  false, true,
  'https://www.obergoms.ch', NULL, 'loc_upper',
  NULL, NULL, NULL, NULL,
  'seasonal', ARRAY[12,1,2,3]::int[], NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Ski de fond Goms' AND location_name = 'Oberwald'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Ski de fond Goms' AND location_name = 'Oberwald'
);

-- Téléphérique Mittelallalin
INSERT INTO activity_submissions (
  title, location_name, category, description,
  latitude, longitude, duration_minutes, price_level,
  features, seasons, social_tags,
  is_indoor, is_outdoor,
  activity_url, image_url, location_zone,
  date_label, date_label_en, date_start, date_end,
  recurrence_type, seasonal_months, weekly_days,
  status, submitted_by
)
SELECT
  'Téléphérique Mittelallalin',
  'Saas-Fee',
  'sport',
  'Plus haut métro souterrain du monde (3500m). Restaurant tournant, glacier 360°.',
  46.1086, 7.9272,
  240, 5,
  ARRAY['Reservation necessaire'],
  ARRAY['Été','Hiver','Automne'],
  ARRAY['Couple','Amis','Famille'],
  true, true,
  'https://www.saas-fee.ch', NULL, 'loc_upper',
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Téléphérique Mittelallalin' AND location_name = 'Saas-Fee'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Téléphérique Mittelallalin' AND location_name = 'Saas-Fee'
);

-- Pont suspendu Charles Kuonen
INSERT INTO activity_submissions (
  title, location_name, category, description,
  latitude, longitude, duration_minutes, price_level,
  features, seasons, social_tags,
  is_indoor, is_outdoor,
  activity_url, image_url, location_zone,
  date_label, date_label_en, date_start, date_end,
  recurrence_type, seasonal_months, weekly_days,
  status, submitted_by
)
SELECT
  'Pont suspendu Charles Kuonen',
  'Randa',
  'adventure',
  'Plus long pont suspendu piéton du monde (494m, 85m de haut). Frissons garantis.',
  46.0917, 7.7972,
  240, 1,
  ARRAY['Parking'],
  ARRAY['Printemps','Été','Automne'],
  ARRAY['Couple','Amis'],
  false, true,
  'https://www.randa.ch', NULL, 'loc_upper',
  NULL, NULL, NULL, NULL,
  'seasonal', ARRAY[5,6,7,8,9,10]::int[], NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Pont suspendu Charles Kuonen' AND location_name = 'Randa'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Pont suspendu Charles Kuonen' AND location_name = 'Randa'
);

-- Via ferrata Saillon
INSERT INTO activity_submissions (
  title, location_name, category, description,
  latitude, longitude, duration_minutes, price_level,
  features, seasons, social_tags,
  is_indoor, is_outdoor,
  activity_url, image_url, location_zone,
  date_label, date_label_en, date_start, date_end,
  recurrence_type, seasonal_months, weekly_days,
  status, submitted_by
)
SELECT
  'Via ferrata Saillon',
  'Saillon',
  'adventure',
  'Via ferrata facile à difficile dans une falaise. Vue plaine du Rhône.',
  46.175, 7.1833,
  180, 3,
  ARRAY['Reservation necessaire'],
  ARRAY['Printemps','Été','Automne'],
  ARRAY['Solo','Amis'],
  false, true,
  'https://www.saillon.ch', NULL, 'loc_central',
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Via ferrata Saillon' AND location_name = 'Saillon'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Via ferrata Saillon' AND location_name = 'Saillon'
);

-- Via ferrata Loèche-les-Bains
INSERT INTO activity_submissions (
  title, location_name, category, description,
  latitude, longitude, duration_minutes, price_level,
  features, seasons, social_tags,
  is_indoor, is_outdoor,
  activity_url, image_url, location_zone,
  date_label, date_label_en, date_start, date_end,
  recurrence_type, seasonal_months, weekly_days,
  status, submitted_by
)
SELECT
  'Via ferrata Loèche-les-Bains',
  'Loèche-les-Bains',
  'adventure',
  '3 itinéraires de via ferrata avec vue sur les Alpes valaisannes.',
  46.385, 7.6311,
  240, 3,
  ARRAY['Reservation necessaire'],
  ARRAY['Printemps','Été','Automne'],
  ARRAY['Solo','Amis'],
  false, true,
  'https://www.leukerbad.ch', NULL, 'loc_upper',
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Via ferrata Loèche-les-Bains' AND location_name = 'Loèche-les-Bains'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Via ferrata Loèche-les-Bains' AND location_name = 'Loèche-les-Bains'
);

-- Canyoning Saillon
INSERT INTO activity_submissions (
  title, location_name, category, description,
  latitude, longitude, duration_minutes, price_level,
  features, seasons, social_tags,
  is_indoor, is_outdoor,
  activity_url, image_url, location_zone,
  date_label, date_label_en, date_start, date_end,
  recurrence_type, seasonal_months, weekly_days,
  status, submitted_by
)
SELECT
  'Canyoning Saillon',
  'Saillon',
  'adventure',
  'Canyoning dans les gorges de la Salentse. Cascades, sauts, toboggans.',
  46.175, 7.1833,
  240, 5,
  ARRAY['Reservation necessaire'],
  ARRAY['Été','Automne'],
  ARRAY['Amis'],
  false, true,
  NULL, NULL, 'loc_central',
  NULL, NULL, NULL, NULL,
  'seasonal', ARRAY[6,7,8,9]::int[], NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Canyoning Saillon' AND location_name = 'Saillon'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Canyoning Saillon' AND location_name = 'Saillon'
);

-- Canyoning Sierre
INSERT INTO activity_submissions (
  title, location_name, category, description,
  latitude, longitude, duration_minutes, price_level,
  features, seasons, social_tags,
  is_indoor, is_outdoor,
  activity_url, image_url, location_zone,
  date_label, date_label_en, date_start, date_end,
  recurrence_type, seasonal_months, weekly_days,
  status, submitted_by
)
SELECT
  'Canyoning Sierre',
  'Sierre',
  'adventure',
  'Plusieurs niveaux de canyoning sur les rivières de la région.',
  46.2925, 7.5356,
  240, 5,
  ARRAY['Reservation necessaire'],
  ARRAY['Été','Automne'],
  ARRAY['Amis'],
  false, true,
  NULL, NULL, 'loc_central',
  NULL, NULL, NULL, NULL,
  'seasonal', ARRAY[6,7,8,9]::int[], NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Canyoning Sierre' AND location_name = 'Sierre'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Canyoning Sierre' AND location_name = 'Sierre'
);

-- Parapente Verbier
INSERT INTO activity_submissions (
  title, location_name, category, description,
  latitude, longitude, duration_minutes, price_level,
  features, seasons, social_tags,
  is_indoor, is_outdoor,
  activity_url, image_url, location_zone,
  date_label, date_label_en, date_start, date_end,
  recurrence_type, seasonal_months, weekly_days,
  status, submitted_by
)
SELECT
  'Parapente Verbier',
  'Verbier',
  'adventure',
  'Vol biplace au-dessus de la vallée. Plusieurs sites de décollage selon la météo.',
  46.0961, 7.2286,
  90, 5,
  ARRAY['Reservation necessaire'],
  ARRAY['Printemps','Été','Automne'],
  ARRAY['Couple','Solo','Amis'],
  false, true,
  'https://www.flyverbier.ch', NULL, 'loc_central',
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Parapente Verbier' AND location_name = 'Verbier'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Parapente Verbier' AND location_name = 'Verbier'
);

-- Parapente Crans-Montana
INSERT INTO activity_submissions (
  title, location_name, category, description,
  latitude, longitude, duration_minutes, price_level,
  features, seasons, social_tags,
  is_indoor, is_outdoor,
  activity_url, image_url, location_zone,
  date_label, date_label_en, date_start, date_end,
  recurrence_type, seasonal_months, weekly_days,
  status, submitted_by
)
SELECT
  'Parapente Crans-Montana',
  'Crans-Montana',
  'adventure',
  'Vol biplace face aux Alpes valaisannes. Décollage du Bella Lui (2543m).',
  46.3117, 7.4853,
  90, 5,
  ARRAY['Reservation necessaire'],
  ARRAY['Printemps','Été','Automne'],
  ARRAY['Couple','Solo','Amis'],
  false, true,
  NULL, NULL, 'loc_central',
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Parapente Crans-Montana' AND location_name = 'Crans-Montana'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Parapente Crans-Montana' AND location_name = 'Crans-Montana'
);

-- Tyrolienne Sky Glide Crans
INSERT INTO activity_submissions (
  title, location_name, category, description,
  latitude, longitude, duration_minutes, price_level,
  features, seasons, social_tags,
  is_indoor, is_outdoor,
  activity_url, image_url, location_zone,
  date_label, date_label_en, date_start, date_end,
  recurrence_type, seasonal_months, weekly_days,
  status, submitted_by
)
SELECT
  'Tyrolienne Sky Glide Crans',
  'Crans-Montana',
  'adventure',
  'Tyrolienne quadruple à Crans-Montana. Vitesse à 90 km/h sur 2 km.',
  46.3117, 7.4853,
  60, 4,
  ARRAY['Reservation necessaire'],
  ARRAY['Été','Automne'],
  ARRAY['Amis','Famille'],
  false, true,
  'https://www.crans-montana.ch', NULL, 'loc_central',
  NULL, NULL, NULL, NULL,
  'seasonal', ARRAY[6,7,8,9,10]::int[], NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Tyrolienne Sky Glide Crans' AND location_name = 'Crans-Montana'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Tyrolienne Sky Glide Crans' AND location_name = 'Crans-Montana'
);

-- Saut élastique Verbier
INSERT INTO activity_submissions (
  title, location_name, category, description,
  latitude, longitude, duration_minutes, price_level,
  features, seasons, social_tags,
  is_indoor, is_outdoor,
  activity_url, image_url, location_zone,
  date_label, date_label_en, date_start, date_end,
  recurrence_type, seasonal_months, weekly_days,
  status, submitted_by
)
SELECT
  'Saut élastique Verbier',
  'Verbier',
  'adventure',
  'Saut depuis le téléphérique au-dessus du barrage de Mauvoisin (180m).',
  46.0833, 7.4111,
  60, 5,
  ARRAY['Reservation necessaire'],
  ARRAY['Été','Automne'],
  ARRAY['Amis','Solo'],
  false, true,
  'https://www.verbier.ch', NULL, 'loc_central',
  NULL, NULL, NULL, NULL,
  'seasonal', ARRAY[6,7,8,9,10]::int[], NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Saut élastique Verbier' AND location_name = 'Verbier'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Saut élastique Verbier' AND location_name = 'Verbier'
);

-- Glacier hike Aletsch
INSERT INTO activity_submissions (
  title, location_name, category, description,
  latitude, longitude, duration_minutes, price_level,
  features, seasons, social_tags,
  is_indoor, is_outdoor,
  activity_url, image_url, location_zone,
  date_label, date_label_en, date_start, date_end,
  recurrence_type, seasonal_months, weekly_days,
  status, submitted_by
)
SELECT
  'Glacier hike Aletsch',
  'Bettmeralp',
  'adventure',
  'Randonnée encadrée sur le glacier d''Aletsch. Crampons fournis, accompagnement guide.',
  46.4361, 8.0386,
  360, 5,
  ARRAY['Reservation necessaire','Minimum de participants'],
  ARRAY['Été','Automne'],
  ARRAY['Solo','Amis','Couple'],
  false, true,
  'https://www.aletscharena.ch', NULL, 'loc_upper',
  NULL, NULL, NULL, NULL,
  'seasonal', ARRAY[6,7,8,9]::int[], NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Glacier hike Aletsch' AND location_name = 'Bettmeralp'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Glacier hike Aletsch' AND location_name = 'Bettmeralp'
);

-- Loèche-les-Bains thermes
INSERT INTO activity_submissions (
  title, location_name, category, description,
  latitude, longitude, duration_minutes, price_level,
  features, seasons, social_tags,
  is_indoor, is_outdoor,
  activity_url, image_url, location_zone,
  date_label, date_label_en, date_start, date_end,
  recurrence_type, seasonal_months, weekly_days,
  status, submitted_by
)
SELECT
  'Loèche-les-Bains thermes',
  'Loèche-les-Bains',
  'relax',
  'Plus grand centre thermal des Alpes. 3.9 millions L/jour à 51°C. 30 bassins.',
  46.385, 7.6311,
  240, 4,
  ARRAY['Parking','Reservation necessaire'],
  ARRAY['Printemps','Été','Automne','Hiver'],
  ARRAY['Couple','Famille','Solo'],
  true, true,
  'https://www.leukerbad.ch', NULL, 'loc_upper',
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Loèche-les-Bains thermes' AND location_name = 'Loèche-les-Bains'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Loèche-les-Bains thermes' AND location_name = 'Loèche-les-Bains'
);

-- Bains de Brigerbad
INSERT INTO activity_submissions (
  title, location_name, category, description,
  latitude, longitude, duration_minutes, price_level,
  features, seasons, social_tags,
  is_indoor, is_outdoor,
  activity_url, image_url, location_zone,
  date_label, date_label_en, date_start, date_end,
  recurrence_type, seasonal_months, weekly_days,
  status, submitted_by
)
SELECT
  'Bains de Brigerbad',
  'Brig-Glis',
  'relax',
  'Plus ancien centre thermal du Valais. Toboggan thermal (eau chaude !), grottes, jacuzzi.',
  46.3056, 7.9694,
  180, 4,
  ARRAY['Parking'],
  ARRAY['Printemps','Été','Automne','Hiver'],
  ARRAY['Famille','Couple','Amis'],
  true, true,
  'https://www.thermalbad-brigerbad.ch', NULL, 'loc_upper',
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Bains de Brigerbad' AND location_name = 'Brig-Glis'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Bains de Brigerbad' AND location_name = 'Brig-Glis'
);

-- Bains thermaux d'Ovronnaz
INSERT INTO activity_submissions (
  title, location_name, category, description,
  latitude, longitude, duration_minutes, price_level,
  features, seasons, social_tags,
  is_indoor, is_outdoor,
  activity_url, image_url, location_zone,
  date_label, date_label_en, date_start, date_end,
  recurrence_type, seasonal_months, weekly_days,
  status, submitted_by
)
SELECT
  'Bains thermaux d''Ovronnaz',
  'Ovronnaz',
  'relax',
  'Centre thermal en montagne (1400m). Bassins panoramiques face aux Alpes.',
  46.1922, 7.1644,
  180, 4,
  ARRAY['Parking'],
  ARRAY['Printemps','Été','Automne','Hiver'],
  ARRAY['Couple','Famille'],
  true, true,
  'https://www.thermalp.ch', NULL, 'loc_central',
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Bains thermaux d''Ovronnaz' AND location_name = 'Ovronnaz'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Bains thermaux d''Ovronnaz' AND location_name = 'Ovronnaz'
);

-- Spa Mont-Cervin
INSERT INTO activity_submissions (
  title, location_name, category, description,
  latitude, longitude, duration_minutes, price_level,
  features, seasons, social_tags,
  is_indoor, is_outdoor,
  activity_url, image_url, location_zone,
  date_label, date_label_en, date_start, date_end,
  recurrence_type, seasonal_months, weekly_days,
  status, submitted_by
)
SELECT
  'Spa Mont-Cervin',
  'Zermatt',
  'relax',
  'Spa cinq étoiles avec piscine intérieure, hammam. Vue Cervin depuis le bassin.',
  46.0207, 7.7491,
  180, 5,
  ARRAY['Reservation necessaire'],
  ARRAY['Printemps','Été','Automne','Hiver'],
  ARRAY['Couple'],
  true, false,
  'https://www.montcervinpalace.ch', NULL, 'loc_upper',
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Spa Mont-Cervin' AND location_name = 'Zermatt'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Spa Mont-Cervin' AND location_name = 'Zermatt'
);

-- Spa Crans Ambassador
INSERT INTO activity_submissions (
  title, location_name, category, description,
  latitude, longitude, duration_minutes, price_level,
  features, seasons, social_tags,
  is_indoor, is_outdoor,
  activity_url, image_url, location_zone,
  date_label, date_label_en, date_start, date_end,
  recurrence_type, seasonal_months, weekly_days,
  status, submitted_by
)
SELECT
  'Spa Crans Ambassador',
  'Crans-Montana',
  'relax',
  'Spa de luxe avec piscine, sauna, hammam, soins. Vue Alpes valaisannes.',
  46.3117, 7.4853,
  180, 5,
  ARRAY['Reservation necessaire'],
  ARRAY['Printemps','Été','Automne','Hiver'],
  ARRAY['Couple'],
  true, false,
  'https://www.cransambassador.ch', NULL, 'loc_central',
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Spa Crans Ambassador' AND location_name = 'Crans-Montana'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Spa Crans Ambassador' AND location_name = 'Crans-Montana'
);

-- Aqua-Spa Loèche-les-Bains
INSERT INTO activity_submissions (
  title, location_name, category, description,
  latitude, longitude, duration_minutes, price_level,
  features, seasons, social_tags,
  is_indoor, is_outdoor,
  activity_url, image_url, location_zone,
  date_label, date_label_en, date_start, date_end,
  recurrence_type, seasonal_months, weekly_days,
  status, submitted_by
)
SELECT
  'Aqua-Spa Loèche-les-Bains',
  'Loèche-les-Bains',
  'relax',
  'Centre wellness moderne avec piscines à différentes températures, sauna, hammam.',
  46.3833, 7.63,
  240, 4,
  ARRAY['Reservation necessaire'],
  ARRAY['Printemps','Été','Automne','Hiver'],
  ARRAY['Couple','Solo'],
  true, true,
  'https://www.leukerbad.ch', NULL, 'loc_upper',
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Aqua-Spa Loèche-les-Bains' AND location_name = 'Loèche-les-Bains'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Aqua-Spa Loèche-les-Bains' AND location_name = 'Loèche-les-Bains'
);

-- Spa Lindner Zermatt
INSERT INTO activity_submissions (
  title, location_name, category, description,
  latitude, longitude, duration_minutes, price_level,
  features, seasons, social_tags,
  is_indoor, is_outdoor,
  activity_url, image_url, location_zone,
  date_label, date_label_en, date_start, date_end,
  recurrence_type, seasonal_months, weekly_days,
  status, submitted_by
)
SELECT
  'Spa Lindner Zermatt',
  'Zermatt',
  'relax',
  'Spa de l''hôtel Lindner avec vue Cervin. Piscine extérieure chauffée même en hiver.',
  46.0207, 7.7491,
  180, 5,
  ARRAY['Reservation necessaire'],
  ARRAY['Printemps','Été','Automne','Hiver'],
  ARRAY['Couple'],
  true, true,
  'https://www.lindnerhotels.com', NULL, 'loc_upper',
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Spa Lindner Zermatt' AND location_name = 'Zermatt'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Spa Lindner Zermatt' AND location_name = 'Zermatt'
);

-- Anzère Spa & Wellness
INSERT INTO activity_submissions (
  title, location_name, category, description,
  latitude, longitude, duration_minutes, price_level,
  features, seasons, social_tags,
  is_indoor, is_outdoor,
  activity_url, image_url, location_zone,
  date_label, date_label_en, date_start, date_end,
  recurrence_type, seasonal_months, weekly_days,
  status, submitted_by
)
SELECT
  'Anzère Spa & Wellness',
  'Anzère',
  'relax',
  'Centre wellness avec piscine, sauna, hammam. Vue plongeante sur la vallée.',
  46.2842, 7.4108,
  180, 4,
  ARRAY['Reservation necessaire'],
  ARRAY['Printemps','Été','Automne','Hiver'],
  ARRAY['Couple','Famille'],
  true, false,
  'https://www.anzere.ch', NULL, 'loc_central',
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Anzère Spa & Wellness' AND location_name = 'Anzère'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Anzère Spa & Wellness' AND location_name = 'Anzère'
);

-- Labyrinthe Aventure
INSERT INTO activity_submissions (
  title, location_name, category, description,
  latitude, longitude, duration_minutes, price_level,
  features, seasons, social_tags,
  is_indoor, is_outdoor,
  activity_url, image_url, location_zone,
  date_label, date_label_en, date_start, date_end,
  recurrence_type, seasonal_months, weekly_days,
  status, submitted_by
)
SELECT
  'Labyrinthe Aventure',
  'Évionnaz',
  'fun',
  'Plus grand labyrinthe végétal de Suisse. Énigmes pour tous âges, parc pour enfants.',
  46.1839, 7.0314,
  180, 3,
  ARRAY['Parking','Reservation necessaire'],
  ARRAY['Printemps','Été','Automne'],
  ARRAY['Famille','Amis'],
  false, true,
  'https://www.labyrinthe.ch', NULL, 'loc_lower',
  NULL, NULL, NULL, NULL,
  'seasonal', ARRAY[4,5,6,7,8,9,10]::int[], NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Labyrinthe Aventure' AND location_name = 'Évionnaz'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Labyrinthe Aventure' AND location_name = 'Évionnaz'
);

-- Adventure Park Hannig
INSERT INTO activity_submissions (
  title, location_name, category, description,
  latitude, longitude, duration_minutes, price_level,
  features, seasons, social_tags,
  is_indoor, is_outdoor,
  activity_url, image_url, location_zone,
  date_label, date_label_en, date_start, date_end,
  recurrence_type, seasonal_months, weekly_days,
  status, submitted_by
)
SELECT
  'Adventure Park Hannig',
  'Saas-Fee',
  'fun',
  'Parc d''aventure : tyrolienne géante, trottinettes, sentiers thématiques pour familles.',
  46.1086, 7.9272,
  240, 4,
  ARRAY['Reservation necessaire'],
  ARRAY['Été','Automne'],
  ARRAY['Famille','Amis'],
  false, true,
  'https://www.saas-fee.ch', NULL, 'loc_upper',
  NULL, NULL, NULL, NULL,
  'seasonal', ARRAY[6,7,8,9,10]::int[], NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Adventure Park Hannig' AND location_name = 'Saas-Fee'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Adventure Park Hannig' AND location_name = 'Saas-Fee'
);

-- Zoo Alpin des Marécottes
INSERT INTO activity_submissions (
  title, location_name, category, description,
  latitude, longitude, duration_minutes, price_level,
  features, seasons, social_tags,
  is_indoor, is_outdoor,
  activity_url, image_url, location_zone,
  date_label, date_label_en, date_start, date_end,
  recurrence_type, seasonal_months, weekly_days,
  status, submitted_by
)
SELECT
  'Zoo Alpin des Marécottes',
  'Salvan',
  'fun',
  'Petit zoo alpin avec lynx, loups, ours bruns. Cadre de montagne authentique.',
  46.11, 7.0164,
  180, 3,
  ARRAY['Parking'],
  ARRAY['Printemps','Été','Automne'],
  ARRAY['Famille'],
  false, true,
  'https://www.zoo-alpin.ch', NULL, 'loc_lower',
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Zoo Alpin des Marécottes' AND location_name = 'Salvan'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Zoo Alpin des Marécottes' AND location_name = 'Salvan'
);

-- Foire du Valais
INSERT INTO activity_submissions (
  title, location_name, category, description,
  latitude, longitude, duration_minutes, price_level,
  features, seasons, social_tags,
  is_indoor, is_outdoor,
  activity_url, image_url, location_zone,
  date_label, date_label_en, date_start, date_end,
  recurrence_type, seasonal_months, weekly_days,
  status, submitted_by
)
SELECT
  'Foire du Valais',
  'Martigny',
  'event',
  'Plus grande foire de Suisse romande, en octobre. Combats de reines, gastronomie locale.',
  46.1011, 7.075,
  240, 2,
  ARRAY['Parking'],
  ARRAY['Automne'],
  ARRAY['Famille','Amis'],
  false, true,
  'https://www.foireduvalais.ch', NULL, 'loc_lower',
  'Début octobre 2026', 'Early October 2026', '2026-10-02'::date, '2026-10-11'::date,
  'one_off', NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Foire du Valais' AND location_name = 'Martigny'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Foire du Valais' AND location_name = 'Martigny'
);

-- Festival International de Cor des Alpes
INSERT INTO activity_submissions (
  title, location_name, category, description,
  latitude, longitude, duration_minutes, price_level,
  features, seasons, social_tags,
  is_indoor, is_outdoor,
  activity_url, image_url, location_zone,
  date_label, date_label_en, date_start, date_end,
  recurrence_type, seasonal_months, weekly_days,
  status, submitted_by
)
SELECT
  'Festival International de Cor des Alpes',
  'Nendaz',
  'event',
  'Plus grand rassemblement mondial de cors des Alpes en juillet. Concerts gratuits.',
  46.1839, 7.3092,
  240, 1,
  ARRAY[]::text[],
  ARRAY['Été'],
  ARRAY['Famille','Couple','Solo','Amis'],
  false, true,
  'https://www.cor-des-alpes.ch', NULL, 'loc_central',
  'Mi-juillet 2026', 'Mid-July 2026', '2026-07-17'::date, '2026-07-19'::date,
  'one_off', NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Festival International de Cor des Alpes' AND location_name = 'Nendaz'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Festival International de Cor des Alpes' AND location_name = 'Nendaz'
);

-- ============================================================
-- Total : 150 activites
-- Repartition : adventure=18, culture=27, event=6, fun=8, gastronomy=20, nature=33, relax=16, sport=22
-- Avec activity_url : 115/150
-- Avec location_zone (Valais) : 75/150
-- Avec contraintes temporelles : 34/150
-- ============================================================