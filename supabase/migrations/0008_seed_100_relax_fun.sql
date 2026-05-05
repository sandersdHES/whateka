-- Whateka -- Migration 0008 : 50 relax + 50 fun (VD+VS)
-- ============================================================
-- 100 activites attractives inserees comme soumissions a
-- valider (status='pending'). Doublons evites avec 0005.
-- 
-- 50 RELAX : 25 VD + 25 VS (spas hotel-stations, thermes,
--            sentiers detente, croisieres, yoga)
-- 50 FUN   : 25 VD + 25 VS (aquariums, trains touristiques,
--            karting, bowling, cinemas, marches, mountain-
--            carts, trottinettes, casinos)
-- 
-- Idempotent : WHERE NOT EXISTS sur (title, location_name)
-- dans activity_submissions ET activities.
-- ============================================================

-- Le Mirador Resort & Spa
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
  'Le Mirador Resort & Spa',
  'Mont-Pèlerin',
  'relax',
  'Hotel 5* avec spa Givenchy panoramique sur le Leman. Piscines, soins haut de gamme, vue Alpes.',
  46.4769, 6.8597,
  240, 5,
  ARRAY['Parking','Reservation necessaire'],
  ARRAY['Printemps','Été','Automne','Hiver'],
  ARRAY['Couple'],
  true, true,
  'https://www.mirador.ch', NULL, NULL,
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Le Mirador Resort & Spa' AND location_name = 'Mont-Pèlerin'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Le Mirador Resort & Spa' AND location_name = 'Mont-Pèlerin'
);

-- Spa Royal Savoy
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
  'Spa Royal Savoy',
  'Lausanne',
  'relax',
  'Spa 5* du Royal Savoy Hotel. Piscine inox, sauna fumant, hammam, soins signature, hammam oriental.',
  46.5097, 6.6336,
  180, 5,
  ARRAY['Reservation necessaire'],
  ARRAY['Printemps','Été','Automne','Hiver'],
  ARRAY['Couple'],
  true, true,
  'https://www.royalsavoy.ch', NULL, NULL,
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Spa Royal Savoy' AND location_name = 'Lausanne'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Spa Royal Savoy' AND location_name = 'Lausanne'
);

-- Spa Lausanne Palace
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
  'Spa Lausanne Palace',
  'Lausanne',
  'relax',
  'Spa CinqMondes du Lausanne Palace 5*. Piscine, sauna, hammam, soins signature inspires d''Asie.',
  46.5193, 6.6293,
  180, 5,
  ARRAY['Reservation necessaire'],
  ARRAY['Printemps','Été','Automne','Hiver'],
  ARRAY['Couple'],
  true, false,
  'https://www.lausanne-palace.com', NULL, NULL,
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Spa Lausanne Palace' AND location_name = 'Lausanne'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Spa Lausanne Palace' AND location_name = 'Lausanne'
);

-- Spa Mövenpick Lausanne
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
  'Spa Mövenpick Lausanne',
  'Lausanne',
  'relax',
  'Spa de l''hotel Movenpick a Ouchy. Piscine interieure, sauna, hammam, fitness, vue lac.',
  46.5106, 6.6389,
  180, 4,
  ARRAY['Reservation necessaire'],
  ARRAY['Printemps','Été','Automne','Hiver'],
  ARRAY['Couple','Famille'],
  true, false,
  'https://www.movenpick.com/lausanne', NULL, NULL,
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Spa Mövenpick Lausanne' AND location_name = 'Lausanne'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Spa Mövenpick Lausanne' AND location_name = 'Lausanne'
);

-- Spa Mirabeau Lausanne
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
  'Spa Mirabeau Lausanne',
  'Lausanne',
  'relax',
  'Spa boutique 4* a Lausanne, sauna, soins corps, hammam, ambiance feutree.',
  46.5189, 6.6286,
  120, 4,
  ARRAY['Reservation necessaire'],
  ARRAY['Printemps','Été','Automne','Hiver'],
  ARRAY['Couple'],
  true, false,
  'https://www.mirabeau.ch', NULL, NULL,
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Spa Mirabeau Lausanne' AND location_name = 'Lausanne'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Spa Mirabeau Lausanne' AND location_name = 'Lausanne'
);

-- Spa Continental Lausanne
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
  'Spa Continental Lausanne',
  'Lausanne',
  'relax',
  'Spa de l''hotel Continental, en gare. Soins du visage, du corps, sauna et hammam.',
  46.5167, 6.6294,
  120, 4,
  ARRAY['Reservation necessaire'],
  ARRAY['Printemps','Été','Automne','Hiver'],
  ARRAY['Couple','Solo'],
  true, false,
  'https://www.continentalhotel.ch', NULL, NULL,
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Spa Continental Lausanne' AND location_name = 'Lausanne'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Spa Continental Lausanne' AND location_name = 'Lausanne'
);

-- Spa Carlton Lausanne
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
  'Spa Carlton Lausanne',
  'Lausanne',
  'relax',
  'Spa 4* de l''hotel Carlton. Sauna, hammam, soins, ambiance art-deco.',
  46.5125, 6.6355,
  120, 4,
  ARRAY['Reservation necessaire'],
  ARRAY['Printemps','Été','Automne','Hiver'],
  ARRAY['Couple'],
  true, false,
  'https://www.carltonlausanne.com', NULL, NULL,
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Spa Carlton Lausanne' AND location_name = 'Lausanne'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Spa Carlton Lausanne' AND location_name = 'Lausanne'
);

-- Spa La Reserve Eden au Lac
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
  'Spa La Reserve Eden au Lac',
  'Lausanne',
  'relax',
  'Spa du Reserve Eden au Lac (Bellerive). Piscine indoor, jardin, soins haut de gamme face au Leman.',
  46.5072, 6.645,
  180, 5,
  ARRAY['Reservation necessaire'],
  ARRAY['Printemps','Été','Automne','Hiver'],
  ARRAY['Couple'],
  true, true,
  NULL, NULL, NULL,
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Spa La Reserve Eden au Lac' AND location_name = 'Lausanne'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Spa La Reserve Eden au Lac' AND location_name = 'Lausanne'
);

-- Puressens Spa Trois Couronnes
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
  'Puressens Spa Trois Couronnes',
  'Vevey',
  'relax',
  'Spa 5* de l''hotel des Trois Couronnes (1842). Piscine vue lac, hammam, soins exclusifs Cinq Mondes.',
  46.4617, 6.8478,
  240, 5,
  ARRAY['Reservation necessaire'],
  ARRAY['Printemps','Été','Automne','Hiver'],
  ARRAY['Couple'],
  true, true,
  'https://www.hoteltroiscouronnes.ch', NULL, NULL,
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Puressens Spa Trois Couronnes' AND location_name = 'Vevey'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Puressens Spa Trois Couronnes' AND location_name = 'Vevey'
);

-- Spa Grand Hôtel du Lac Vevey
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
  'Spa Grand Hôtel du Lac Vevey',
  'Vevey',
  'relax',
  'Spa 5* Relais & Châteaux. Piscine, hammam, soins corps et visage, jardin classe au bord du Leman.',
  46.4658, 6.84,
  180, 5,
  ARRAY['Reservation necessaire'],
  ARRAY['Printemps','Été','Automne','Hiver'],
  ARRAY['Couple'],
  true, true,
  'https://www.grandhoteldulac.ch', NULL, NULL,
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Spa Grand Hôtel du Lac Vevey' AND location_name = 'Vevey'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Spa Grand Hôtel du Lac Vevey' AND location_name = 'Vevey'
);

-- Spa Modern Times Hotel
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
  'Spa Modern Times Hotel',
  'Chexbres',
  'relax',
  'Spa 4* a Chexbres, vue panoramique sur Lavaux. Piscine, sauna, hammam, soins.',
  46.4842, 6.7917,
  180, 4,
  ARRAY['Reservation necessaire'],
  ARRAY['Printemps','Été','Automne','Hiver'],
  ARRAY['Couple'],
  true, true,
  'https://www.moderntimeshotel.ch', NULL, NULL,
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Spa Modern Times Hotel' AND location_name = 'Chexbres'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Spa Modern Times Hotel' AND location_name = 'Chexbres'
);

-- Willow Stream Spa Fairmont
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
  'Willow Stream Spa Fairmont',
  'Montreux',
  'relax',
  'Spa du Fairmont Le Montreux Palace 5*. Piscine vue lac, sauna, hammam, soins signature.',
  46.4337, 6.9111,
  240, 5,
  ARRAY['Reservation necessaire'],
  ARRAY['Printemps','Été','Automne','Hiver'],
  ARRAY['Couple'],
  true, true,
  'https://www.fairmont.com/montreux', NULL, NULL,
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Willow Stream Spa Fairmont' AND location_name = 'Montreux'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Willow Stream Spa Fairmont' AND location_name = 'Montreux'
);

-- Spa Eden Palace au Lac
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
  'Spa Eden Palace au Lac',
  'Montreux',
  'relax',
  'Spa de l''hotel Eden Palace au Lac (4*+). Piscine, sauna, hammam, soins, terrasse face au Leman.',
  46.4318, 6.9117,
  180, 4,
  ARRAY['Reservation necessaire'],
  ARRAY['Printemps','Été','Automne','Hiver'],
  ARRAY['Couple'],
  true, true,
  'https://www.edenpalace.ch', NULL, NULL,
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Spa Eden Palace au Lac' AND location_name = 'Montreux'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Spa Eden Palace au Lac' AND location_name = 'Montreux'
);

-- Spa Eastwest Hotel
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
  'Spa Eastwest Hotel',
  'Montreux',
  'relax',
  'Spa boutique de l''hotel Eastwest 5*. Soins signatures asiatiques, hammam, ambiance feutree.',
  46.4337, 6.9119,
  120, 5,
  ARRAY['Reservation necessaire'],
  ARRAY['Printemps','Été','Automne','Hiver'],
  ARRAY['Couple'],
  true, false,
  'https://www.eastwest.ch', NULL, NULL,
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Spa Eastwest Hotel' AND location_name = 'Montreux'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Spa Eastwest Hotel' AND location_name = 'Montreux'
);

-- Spa Suisse-Majestic
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
  'Spa Suisse-Majestic',
  'Montreux',
  'relax',
  'Petit spa du Grand Hotel Suisse-Majestic. Piscine, sauna, hammam, vue lac.',
  46.4339, 6.9119,
  120, 4,
  ARRAY['Reservation necessaire'],
  ARRAY['Printemps','Été','Automne','Hiver'],
  ARRAY['Couple'],
  true, false,
  'https://www.suisse-majestic.com', NULL, NULL,
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Spa Suisse-Majestic' AND location_name = 'Montreux'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Spa Suisse-Majestic' AND location_name = 'Montreux'
);

-- Hôtel RoyAlp Spa Villars
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
  'Hôtel RoyAlp Spa Villars',
  'Villars-sur-Ollon',
  'relax',
  'Spa 5* du Hôtel RoyAlp. Piscine intérieure-extérieure chauffée, sauna, hammam, vue Alpes.',
  46.2986, 7.0467,
  240, 5,
  ARRAY['Parking','Reservation necessaire'],
  ARRAY['Printemps','Été','Automne','Hiver'],
  ARRAY['Couple','Famille'],
  true, true,
  'https://www.royalp.ch', NULL, NULL,
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Hôtel RoyAlp Spa Villars' AND location_name = 'Villars-sur-Ollon'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Hôtel RoyAlp Spa Villars' AND location_name = 'Villars-sur-Ollon'
);

-- Spa Bristol Villars
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
  'Spa Bristol Villars',
  'Villars-sur-Ollon',
  'relax',
  'Spa de l''hotel Bristol 4*+. Piscine vue Dents du Midi, sauna finlandais, hammam, soins.',
  46.2986, 7.047,
  180, 4,
  ARRAY['Reservation necessaire'],
  ARRAY['Printemps','Été','Automne','Hiver'],
  ARRAY['Couple','Famille'],
  true, false,
  'https://www.bristol-villars.ch', NULL, NULL,
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Spa Bristol Villars' AND location_name = 'Villars-sur-Ollon'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Spa Bristol Villars' AND location_name = 'Villars-sur-Ollon'
);

-- Spa Eurotel Victoria Villars
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
  'Spa Eurotel Victoria Villars',
  'Villars-sur-Ollon',
  'relax',
  'Spa de l''Eurotel Victoria 4*. Piscine, sauna, hammam, soins, ambiance familiale alpine.',
  46.298, 7.0461,
  150, 4,
  ARRAY['Parking','Reservation necessaire'],
  ARRAY['Printemps','Été','Automne','Hiver'],
  ARRAY['Couple','Famille'],
  true, false,
  'https://www.eurotel-victoria.ch', NULL, NULL,
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Spa Eurotel Victoria Villars' AND location_name = 'Villars-sur-Ollon'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Spa Eurotel Victoria Villars' AND location_name = 'Villars-sur-Ollon'
);

-- Spa Hôtel Christiania
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
  'Spa Hôtel Christiania',
  'Leysin',
  'relax',
  'Petit spa de l''Hotel Christiania. Sauna, jacuzzi, vue Dents du Midi, ambiance chalet.',
  46.3478, 7.0089,
  120, 4,
  ARRAY['Reservation necessaire'],
  ARRAY['Printemps','Été','Automne','Hiver'],
  ARRAY['Couple','Famille'],
  true, true,
  'https://www.christiania-leysin.ch', NULL, NULL,
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Spa Hôtel Christiania' AND location_name = 'Leysin'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Spa Hôtel Christiania' AND location_name = 'Leysin'
);

-- Spa Hôtel La Prairie Yverdon
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
  'Spa Hôtel La Prairie Yverdon',
  'Yverdon-les-Bains',
  'relax',
  'Spa de l''hotel 4* La Prairie. Soins haut de gamme, jacuzzi, hammam, complementaire aux Bains thermaux.',
  46.7847, 6.6428,
  150, 4,
  ARRAY['Parking','Reservation necessaire'],
  ARRAY['Printemps','Été','Automne','Hiver'],
  ARRAY['Couple'],
  true, false,
  'https://www.laprairiehotel.ch', NULL, NULL,
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Spa Hôtel La Prairie Yverdon' AND location_name = 'Yverdon-les-Bains'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Spa Hôtel La Prairie Yverdon' AND location_name = 'Yverdon-les-Bains'
);

-- Croisière sunset CGN Léman
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
  'Croisière sunset CGN Léman',
  'Lausanne-Ouchy',
  'relax',
  'Croisière au coucher de soleil sur le Léman, 1h30 a bord d''un bateau Belle Epoque CGN. Apéro panoramique.',
  46.5083, 6.6261,
  90, 3,
  ARRAY['Reservation necessaire','Horaires restreints'],
  ARRAY['Printemps','Été','Automne'],
  ARRAY['Couple','Famille','Amis'],
  true, true,
  'https://www.cgn.ch', NULL, NULL,
  NULL, NULL, NULL, NULL,
  'seasonal', ARRAY[4,5,6,7,8,9,10]::int[], NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Croisière sunset CGN Léman' AND location_name = 'Lausanne-Ouchy'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Croisière sunset CGN Léman' AND location_name = 'Lausanne-Ouchy'
);

-- Sentier des Sens Sauvabelin
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
  'Sentier des Sens Sauvabelin',
  'Lausanne',
  'relax',
  'Sentier didactique en boucle dans la foret de Sauvabelin. Forest bathing au-dessus de Lausanne, ideal pour decompresser.',
  46.54, 6.65,
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
  WHERE title = 'Sentier des Sens Sauvabelin' AND location_name = 'Lausanne'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Sentier des Sens Sauvabelin' AND location_name = 'Lausanne'
);

-- Plage relax de Cully
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
  'Plage relax de Cully',
  'Cully',
  'relax',
  'Petite plage de galets en plein cœur de Lavaux UNESCO. Baignade calme, vue vignes et lac, idéal pour bouquiner.',
  46.49, 6.7333,
  120, 1,
  ARRAY[]::text[],
  ARRAY['Printemps','Été'],
  ARRAY['Famille','Couple','Solo'],
  false, true,
  NULL, NULL, NULL,
  NULL, NULL, NULL, NULL,
  'seasonal', ARRAY[5,6,7,8,9]::int[], NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Plage relax de Cully' AND location_name = 'Cully'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Plage relax de Cully' AND location_name = 'Cully'
);

-- Centre Yoga Sereynité
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
  'Centre Yoga Sereynité',
  'Lausanne',
  'relax',
  'Studio de yoga de reference a Lausanne. Cours hatha, vinyasa, yin, ateliers meditation. Tous niveaux.',
  46.5197, 6.6328,
  90, 2,
  ARRAY['Reservation necessaire','Horaires restreints'],
  ARRAY['Printemps','Été','Automne','Hiver'],
  ARRAY['Solo','Couple'],
  true, false,
  NULL, NULL, NULL,
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Centre Yoga Sereynité' AND location_name = 'Lausanne'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Centre Yoga Sereynité' AND location_name = 'Lausanne'
);

-- Promenade des Quais Vevey-Montreux
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
  'Promenade des Quais Vevey-Montreux',
  'Vevey',
  'relax',
  'Promenade lacustre de 7 km le long du Leman, de Vevey a Montreux. Plage, sculptures, kiosques, sereinité.',
  46.4633, 6.8492,
  120, 1,
  ARRAY[]::text[],
  ARRAY['Printemps','Été','Automne','Hiver'],
  ARRAY['Famille','Couple','Solo'],
  false, true,
  NULL, NULL, NULL,
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Promenade des Quais Vevey-Montreux' AND location_name = 'Vevey'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Promenade des Quais Vevey-Montreux' AND location_name = 'Vevey'
);

-- Therme 51° Loèche-les-Bains
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
  'Therme 51° Loèche-les-Bains',
  'Loèche-les-Bains',
  'relax',
  'Centre thermal 5*, eau sulfureuse a 51°C. Bassins panoramiques, hammam alpin, soins exclusifs.',
  46.385, 7.6311,
  240, 5,
  ARRAY['Parking','Reservation necessaire'],
  ARRAY['Printemps','Été','Automne','Hiver'],
  ARRAY['Couple'],
  true, true,
  'https://www.51grad.ch', NULL, 'loc_upper',
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Therme 51° Loèche-les-Bains' AND location_name = 'Loèche-les-Bains'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Therme 51° Loèche-les-Bains' AND location_name = 'Loèche-les-Bains'
);

-- Bains de Saillon
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
  'Bains de Saillon',
  'Saillon',
  'relax',
  'Centre thermal moderne en plaine du Rhone. 4 bassins, sauna, hammam, fitness. Eau a 33°C.',
  46.175, 7.1833,
  240, 4,
  ARRAY['Parking','Reservation necessaire'],
  ARRAY['Printemps','Été','Automne','Hiver'],
  ARRAY['Famille','Couple'],
  true, true,
  'https://www.bainsdesaillon.ch', NULL, 'loc_central',
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Bains de Saillon' AND location_name = 'Saillon'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Bains de Saillon' AND location_name = 'Saillon'
);

-- Walliser Alpentherme Leukerbad
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
  'Walliser Alpentherme Leukerbad',
  'Loèche-les-Bains',
  'relax',
  'Centre thermal du Lindner Hotel. Bassins interieur/exterieur, sauna nordique, hammam romain, vue Alpes.',
  46.3856, 7.6306,
  240, 4,
  ARRAY['Parking','Reservation necessaire'],
  ARRAY['Printemps','Été','Automne','Hiver'],
  ARRAY['Couple','Famille'],
  true, true,
  'https://www.alpentherme.ch', NULL, 'loc_upper',
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Walliser Alpentherme Leukerbad' AND location_name = 'Loèche-les-Bains'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Walliser Alpentherme Leukerbad' AND location_name = 'Loèche-les-Bains'
);

-- Spa W Verbier
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
  'Spa W Verbier',
  'Verbier',
  'relax',
  'Spa AWAY du W Hotel Verbier 5*. Piscine inox, hammam, sauna, soins design, vue Combin.',
  46.0961, 7.2286,
  240, 5,
  ARRAY['Reservation necessaire'],
  ARRAY['Printemps','Été','Automne','Hiver'],
  ARRAY['Couple'],
  true, true,
  'https://www.marriott.com/wver', NULL, 'loc_central',
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Spa W Verbier' AND location_name = 'Verbier'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Spa W Verbier' AND location_name = 'Verbier'
);

-- Spa Chalet d'Adrien
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
  'Spa Chalet d''Adrien',
  'Verbier',
  'relax',
  'Spa du Chalet d''Adrien (Relais & Châteaux). Piscine intérieure, soins exclusifs, ambiance alpine de luxe.',
  46.0961, 7.2286,
  180, 5,
  ARRAY['Reservation necessaire'],
  ARRAY['Printemps','Été','Automne','Hiver'],
  ARRAY['Couple'],
  true, false,
  'https://www.chalet-adrien.com', NULL, 'loc_central',
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Spa Chalet d''Adrien' AND location_name = 'Verbier'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Spa Chalet d''Adrien' AND location_name = 'Verbier'
);

-- Spa Cordée des Alpes
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
  'Spa Cordée des Alpes',
  'Verbier',
  'relax',
  'Spa 5* de l''hotel La Cordée des Alpes. Piscine couverte, sauna, hammam, soins haut de gamme.',
  46.0961, 7.2286,
  180, 5,
  ARRAY['Reservation necessaire'],
  ARRAY['Printemps','Été','Automne','Hiver'],
  ARRAY['Couple'],
  true, false,
  'https://www.hotelcordee.com', NULL, 'loc_central',
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Spa Cordée des Alpes' AND location_name = 'Verbier'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Spa Cordée des Alpes' AND location_name = 'Verbier'
);

-- Hôtel Nendaz 4 Vallées Spa
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
  'Hôtel Nendaz 4 Vallées Spa',
  'Nendaz',
  'relax',
  'Spa 4* du Hôtel Nendaz 4 Vallées. Piscine, sauna, hammam, soins, vue station 4 Vallées.',
  46.1839, 7.3092,
  180, 4,
  ARRAY['Reservation necessaire'],
  ARRAY['Printemps','Été','Automne','Hiver'],
  ARRAY['Couple','Famille'],
  true, false,
  'https://www.hotelnendaz4vallees.ch', NULL, 'loc_central',
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Hôtel Nendaz 4 Vallées Spa' AND location_name = 'Nendaz'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Hôtel Nendaz 4 Vallées Spa' AND location_name = 'Nendaz'
);

-- Spa Backstage Hotel Zermatt
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
  'Spa Backstage Hotel Zermatt',
  'Zermatt',
  'relax',
  'Spa boutique de l''hotel Backstage (du chef Heinz Julen). Piscine, sauna, soins, design avant-gardiste.',
  46.0207, 7.7491,
  180, 5,
  ARRAY['Reservation necessaire'],
  ARRAY['Printemps','Été','Automne','Hiver'],
  ARRAY['Couple'],
  true, true,
  'https://www.backstagehotel.ch', NULL, 'loc_upper',
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Spa Backstage Hotel Zermatt' AND location_name = 'Zermatt'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Spa Backstage Hotel Zermatt' AND location_name = 'Zermatt'
);

-- Spa Cervo Mountain Resort
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
  'Spa Cervo Mountain Resort',
  'Zermatt',
  'relax',
  'Spa du Cervo Resort 5*. Piscines panoramiques, hammam, sauna face au Cervin, soins valaisans.',
  46.0207, 7.7491,
  240, 5,
  ARRAY['Reservation necessaire'],
  ARRAY['Printemps','Été','Automne','Hiver'],
  ARRAY['Couple'],
  true, true,
  'https://www.cervo.swiss', NULL, 'loc_upper',
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Spa Cervo Mountain Resort' AND location_name = 'Zermatt'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Spa Cervo Mountain Resort' AND location_name = 'Zermatt'
);

-- Spa Schweizerhof Zermatt
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
  'Spa Schweizerhof Zermatt',
  'Zermatt',
  'relax',
  'Spa 5* du Grand Hotel Schweizerhof. Piscine indoor, sauna, hammam, soins, vue Cervin.',
  46.0207, 7.7491,
  180, 5,
  ARRAY['Reservation necessaire'],
  ARRAY['Printemps','Été','Automne','Hiver'],
  ARRAY['Couple'],
  true, false,
  'https://www.grandhotelzermatterhof.ch', NULL, 'loc_upper',
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Spa Schweizerhof Zermatt' AND location_name = 'Zermatt'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Spa Schweizerhof Zermatt' AND location_name = 'Zermatt'
);

-- Spa Mirabeau Zermatt
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
  'Spa Mirabeau Zermatt',
  'Zermatt',
  'relax',
  'Spa de l''hotel Mirabeau 4*. Piscine, sauna, hammam, soins, ambiance familiale alpine.',
  46.0207, 7.7491,
  150, 4,
  ARRAY['Reservation necessaire'],
  ARRAY['Printemps','Été','Automne','Hiver'],
  ARRAY['Couple','Famille'],
  true, false,
  'https://www.hotel-mirabeau.ch', NULL, 'loc_upper',
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Spa Mirabeau Zermatt' AND location_name = 'Zermatt'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Spa Mirabeau Zermatt' AND location_name = 'Zermatt'
);

-- Spa Park Hotel Beau-Site Zermatt
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
  'Spa Park Hotel Beau-Site Zermatt',
  'Zermatt',
  'relax',
  'Spa 5* du Park Hotel Beau-Site. Piscine, sauna finlandais, hammam, soins, vue Cervin depuis le toit.',
  46.0207, 7.7491,
  180, 5,
  ARRAY['Reservation necessaire'],
  ARRAY['Printemps','Été','Automne','Hiver'],
  ARRAY['Couple'],
  true, true,
  'https://www.parkhotel-beausite.ch', NULL, 'loc_upper',
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Spa Park Hotel Beau-Site Zermatt' AND location_name = 'Zermatt'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Spa Park Hotel Beau-Site Zermatt' AND location_name = 'Zermatt'
);

-- Spa La Couronne Zermatt
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
  'Spa La Couronne Zermatt',
  'Zermatt',
  'relax',
  'Spa de l''hotel La Couronne 4*. Piscine, sauna, hammam, soins, ambiance traditionnelle.',
  46.0207, 7.7491,
  120, 4,
  ARRAY['Reservation necessaire'],
  ARRAY['Printemps','Été','Automne','Hiver'],
  ARRAY['Couple','Famille'],
  true, false,
  'https://www.hotelcouronne.ch', NULL, 'loc_upper',
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Spa La Couronne Zermatt' AND location_name = 'Zermatt'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Spa La Couronne Zermatt' AND location_name = 'Zermatt'
);

-- Hôtel Bella Tola Spa
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
  'Hôtel Bella Tola Spa',
  'Saint-Luc',
  'relax',
  'Spa du Bella Tola 4*+ (Swiss Historic Hotel). Piscine couverte, sauna, hammam, ambiance Belle Epoque.',
  46.2178, 7.6122,
  180, 4,
  ARRAY['Reservation necessaire'],
  ARRAY['Printemps','Été','Automne','Hiver'],
  ARRAY['Couple','Famille'],
  true, false,
  'https://www.bellatola.ch', NULL, 'loc_central',
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Hôtel Bella Tola Spa' AND location_name = 'Saint-Luc'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Hôtel Bella Tola Spa' AND location_name = 'Saint-Luc'
);

-- Spa Mountain Lodge Saas-Fee
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
  'Spa Mountain Lodge Saas-Fee',
  'Saas-Fee',
  'relax',
  'Spa 4*+ du Mountain Lodge. Piscine intérieure, sauna, hammam, soins, ambiance chalet contemporain.',
  46.1086, 7.9272,
  180, 4,
  ARRAY['Reservation necessaire'],
  ARRAY['Printemps','Été','Automne','Hiver'],
  ARRAY['Couple'],
  true, false,
  NULL, NULL, 'loc_upper',
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Spa Mountain Lodge Saas-Fee' AND location_name = 'Saas-Fee'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Spa Mountain Lodge Saas-Fee' AND location_name = 'Saas-Fee'
);

-- Spa Walliserhof Saas-Fee
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
  'Spa Walliserhof Saas-Fee',
  'Saas-Fee',
  'relax',
  'Spa du Walliserhof Grand Hotel 4*+. Piscine, sauna, hammam, soins, ambiance alpine traditionnelle.',
  46.1086, 7.9272,
  180, 4,
  ARRAY['Reservation necessaire'],
  ARRAY['Printemps','Été','Automne','Hiver'],
  ARRAY['Couple','Famille'],
  true, false,
  'https://www.walliserhof-saasfee.ch', NULL, 'loc_upper',
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Spa Walliserhof Saas-Fee' AND location_name = 'Saas-Fee'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Spa Walliserhof Saas-Fee' AND location_name = 'Saas-Fee'
);

-- Spa Beau-Site Saas-Fee
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
  'Spa Beau-Site Saas-Fee',
  'Saas-Fee',
  'relax',
  'Spa de l''hotel Beau-Site 4*. Piscine panoramique sur les 4000m, sauna, hammam, soins.',
  46.1086, 7.9272,
  180, 4,
  ARRAY['Reservation necessaire'],
  ARRAY['Printemps','Été','Automne','Hiver'],
  ARRAY['Couple'],
  true, true,
  'https://www.beausite.ch', NULL, 'loc_upper',
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Spa Beau-Site Saas-Fee' AND location_name = 'Saas-Fee'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Spa Beau-Site Saas-Fee' AND location_name = 'Saas-Fee'
);

-- Spa La Ferme Saas-Fee
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
  'Spa La Ferme Saas-Fee',
  'Saas-Fee',
  'relax',
  'Spa boutique de la Ferme. Sauna, hammam, soins corps et visage, ambiance chalet de charme.',
  46.1086, 7.9272,
  120, 4,
  ARRAY['Reservation necessaire'],
  ARRAY['Printemps','Été','Automne','Hiver'],
  ARRAY['Couple'],
  true, false,
  NULL, NULL, 'loc_upper',
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Spa La Ferme Saas-Fee' AND location_name = 'Saas-Fee'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Spa La Ferme Saas-Fee' AND location_name = 'Saas-Fee'
);

-- Spa LeCrans Hotel
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
  'Spa LeCrans Hotel',
  'Crans-Montana',
  'relax',
  'Spa du LeCrans Hotel 5* (Relais & Châteaux). Piscine indoor, hammam, soins exclusifs, vue Alpes.',
  46.3117, 7.4853,
  240, 5,
  ARRAY['Reservation necessaire'],
  ARRAY['Printemps','Été','Automne','Hiver'],
  ARRAY['Couple'],
  true, false,
  'https://www.lecrans.com', NULL, 'loc_central',
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Spa LeCrans Hotel' AND location_name = 'Crans-Montana'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Spa LeCrans Hotel' AND location_name = 'Crans-Montana'
);

-- Spa Royal Hotel Crans
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
  'Spa Royal Hotel Crans',
  'Crans-Montana',
  'relax',
  'Spa du Royal Hotel 5*. Piscine 25m, sauna, hammam, soins du visage et corps haut de gamme.',
  46.3117, 7.4853,
  180, 5,
  ARRAY['Reservation necessaire'],
  ARRAY['Printemps','Été','Automne','Hiver'],
  ARRAY['Couple','Famille'],
  true, false,
  'https://www.hotel-royal.ch', NULL, 'loc_central',
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Spa Royal Hotel Crans' AND location_name = 'Crans-Montana'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Spa Royal Hotel Crans' AND location_name = 'Crans-Montana'
);

-- Spa Faern Crans-Montana
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
  'Spa Faern Crans-Montana',
  'Crans-Montana',
  'relax',
  'Spa du Faern Crans-Montana 4*+ (ex Mont-Blanc). Piscine, sauna, hammam, soins, terrasse vue Alpes.',
  46.3117, 7.4853,
  180, 4,
  ARRAY['Reservation necessaire'],
  ARRAY['Printemps','Été','Automne','Hiver'],
  ARRAY['Couple','Famille'],
  true, true,
  'https://www.faern.com', NULL, 'loc_central',
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Spa Faern Crans-Montana' AND location_name = 'Crans-Montana'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Spa Faern Crans-Montana' AND location_name = 'Crans-Montana'
);

-- Spa Pas de l'Ours
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
  'Spa Pas de l''Ours',
  'Crans-Montana',
  'relax',
  'Spa boutique du Pas de l''Ours 5*. Piscine, sauna, hammam, soins exclusifs, ambiance feutree.',
  46.3117, 7.4853,
  180, 5,
  ARRAY['Reservation necessaire'],
  ARRAY['Printemps','Été','Automne','Hiver'],
  ARRAY['Couple'],
  true, false,
  'https://www.pasdelours.ch', NULL, 'loc_central',
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Spa Pas de l''Ours' AND location_name = 'Crans-Montana'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Spa Pas de l''Ours' AND location_name = 'Crans-Montana'
);

-- Spa Helvetia Intergolf
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
  'Spa Helvetia Intergolf',
  'Crans-Montana',
  'relax',
  'Spa de l''hotel 4* Helvetia Intergolf. Piscine, sauna, hammam, soins, vue golf et Alpes.',
  46.3117, 7.4853,
  150, 4,
  ARRAY['Reservation necessaire'],
  ARRAY['Printemps','Été','Automne','Hiver'],
  ARRAY['Couple','Famille'],
  true, false,
  'https://www.helvetia-intergolf.ch', NULL, 'loc_central',
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Spa Helvetia Intergolf' AND location_name = 'Crans-Montana'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Spa Helvetia Intergolf' AND location_name = 'Crans-Montana'
);

-- Sentier des Bisses sereins
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
  'Sentier des Bisses sereins',
  'Anzère',
  'relax',
  'Parcours zen le long des bisses d''Anzere : eau qui coule, panoramas alpins, points meditation. Ideal forest bathing alpin.',
  46.2842, 7.4108,
  180, 1,
  ARRAY['Parking'],
  ARRAY['Printemps','Été','Automne'],
  ARRAY['Famille','Solo','Couple'],
  false, true,
  NULL, NULL, 'loc_central',
  NULL, NULL, NULL, NULL,
  'seasonal', ARRAY[4,5,6,7,8,9,10]::int[], NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Sentier des Bisses sereins' AND location_name = 'Anzère'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Sentier des Bisses sereins' AND location_name = 'Anzère'
);

-- Sauna panoramique Riffelalp Resort
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
  'Sauna panoramique Riffelalp Resort',
  'Zermatt',
  'relax',
  'Sauna et bains chauds extérieurs a 2''222m face au Cervin. Plus haut spa hotel d''Europe (Riffelalp Resort 5*).',
  46.0064, 7.7611,
  180, 5,
  ARRAY['Reservation necessaire'],
  ARRAY['Été','Automne','Hiver'],
  ARRAY['Couple'],
  true, true,
  'https://www.riffelalp.com', NULL, 'loc_upper',
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Sauna panoramique Riffelalp Resort' AND location_name = 'Zermatt'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Sauna panoramique Riffelalp Resort' AND location_name = 'Zermatt'
);

-- Aquatis Aquarium-Vivarium
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
  'Aquatis Aquarium-Vivarium',
  'Lausanne',
  'fun',
  'Plus grand aquarium-vivarium d''eau douce d''Europe. 10 000 animaux, 20 ecosystemes recreces. Note Google 4.3.',
  46.5417, 6.6486,
  180, 4,
  ARRAY['Parking','Reservation necessaire'],
  ARRAY['Printemps','Été','Automne','Hiver'],
  ARRAY['Famille','Couple','Amis'],
  true, false,
  'https://www.aquatis.ch', NULL, NULL,
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Aquatis Aquarium-Vivarium' AND location_name = 'Lausanne'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Aquatis Aquarium-Vivarium' AND location_name = 'Lausanne'
);

-- Train Belle Époque GoldenPass
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
  'Train Belle Époque GoldenPass',
  'Montreux',
  'fun',
  'Train panoramique vintage Montreux-Zweisimmen, voitures restaurees Belle Epoque. Vue Alpes, Pre-Alpes, Lavaux.',
  46.4339, 6.9119,
  240, 4,
  ARRAY['Reservation necessaire','Horaires restreints'],
  ARRAY['Printemps','Été','Automne','Hiver'],
  ARRAY['Famille','Couple','Amis'],
  true, false,
  'https://www.goldenpass.ch', NULL, NULL,
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Train Belle Époque GoldenPass' AND location_name = 'Montreux'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Train Belle Époque GoldenPass' AND location_name = 'Montreux'
);

-- Train du Chocolat
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
  'Train du Chocolat',
  'Montreux',
  'fun',
  'Train touristique GoldenPass de Montreux a la chocolaterie Cailler de Broc. Inclus visite et degustation.',
  46.4339, 6.9119,
  480, 5,
  ARRAY['Reservation necessaire','Horaires restreints'],
  ARRAY['Printemps','Été','Automne'],
  ARRAY['Famille','Couple','Amis'],
  true, false,
  'https://www.goldenpass.ch', NULL, NULL,
  NULL, NULL, NULL, NULL,
  'seasonal', ARRAY[5,6,7,8,9,10]::int[], NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Train du Chocolat' AND location_name = 'Montreux'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Train du Chocolat' AND location_name = 'Montreux'
);

-- Bateau Belle Époque CGN
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
  'Bateau Belle Époque CGN',
  'Lausanne-Ouchy',
  'fun',
  'Croisiere a bord d''un bateau a vapeur classe (Simplon, Italie, Savoie...). Ambiance Belle Epoque, traversee Leman.',
  46.5083, 6.6261,
  180, 3,
  ARRAY['Reservation necessaire','Horaires restreints'],
  ARRAY['Printemps','Été','Automne'],
  ARRAY['Famille','Couple','Amis'],
  true, true,
  'https://www.cgn.ch', NULL, NULL,
  NULL, NULL, NULL, NULL,
  'seasonal', ARRAY[4,5,6,7,8,9,10]::int[], NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Bateau Belle Époque CGN' AND location_name = 'Lausanne-Ouchy'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Bateau Belle Époque CGN' AND location_name = 'Lausanne-Ouchy'
);

-- Karting Lausanne
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
  'Karting Lausanne',
  'Crissier',
  'fun',
  'Piste de karting indoor de Crissier, 600m. Karts puissants, courses chronometrees, sessions arcade pour enfants.',
  46.5497, 6.5775,
  90, 4,
  ARRAY['Parking','Reservation necessaire','Minimum de participants'],
  ARRAY['Printemps','Été','Automne','Hiver'],
  ARRAY['Amis','Famille'],
  true, false,
  NULL, NULL, NULL,
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Karting Lausanne' AND location_name = 'Crissier'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Karting Lausanne' AND location_name = 'Crissier'
);

-- Laser Game Lausanne
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
  'Laser Game Lausanne',
  'Lausanne',
  'fun',
  'Centre de laser game multi-niveaux a Lausanne. Decors thematiques, parties d''equipes, ideal anniversaires.',
  46.5202, 6.6306,
  60, 3,
  ARRAY['Reservation necessaire','Minimum de participants'],
  ARRAY['Printemps','Été','Automne','Hiver'],
  ARRAY['Famille','Amis'],
  true, false,
  NULL, NULL, NULL,
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Laser Game Lausanne' AND location_name = 'Lausanne'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Laser Game Lausanne' AND location_name = 'Lausanne'
);

-- Jumpville Lausanne
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
  'Jumpville Lausanne',
  'Lausanne',
  'fun',
  'Trampoline park indoor a Lausanne : 2''500 m² de trampolines, free jump, dodgeball, slamball pour tous ages.',
  46.54, 6.62,
  90, 3,
  ARRAY['Parking','Reservation necessaire'],
  ARRAY['Printemps','Été','Automne','Hiver'],
  ARRAY['Famille','Amis'],
  true, false,
  'https://www.jumpville.ch', NULL, NULL,
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Jumpville Lausanne' AND location_name = 'Lausanne'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Jumpville Lausanne' AND location_name = 'Lausanne'
);

-- Bowling Lausanne Centre
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
  'Bowling Lausanne Centre',
  'Lausanne',
  'fun',
  'Centre de bowling a Lausanne. 14 pistes, billard, restaurant, animations weekend.',
  46.524, 6.632,
  90, 3,
  ARRAY[]::text[],
  ARRAY['Printemps','Été','Automne','Hiver'],
  ARRAY['Famille','Amis','Couple'],
  true, false,
  NULL, NULL, NULL,
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Bowling Lausanne Centre' AND location_name = 'Lausanne'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Bowling Lausanne Centre' AND location_name = 'Lausanne'
);

-- Cinéma Pathé Flon
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
  'Cinéma Pathé Flon',
  'Lausanne',
  'fun',
  'Multiplexe Pathé du Flon (12 salles, IMAX, 4DX). L''un des plus gros cinemas de Suisse romande.',
  46.5202, 6.6306,
  120, 3,
  ARRAY['Reservation necessaire','Horaires restreints'],
  ARRAY['Printemps','Été','Automne','Hiver'],
  ARRAY['Famille','Couple','Amis','Solo'],
  true, false,
  'https://www.pathe.ch', NULL, NULL,
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Cinéma Pathé Flon' AND location_name = 'Lausanne'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Cinéma Pathé Flon' AND location_name = 'Lausanne'
);

-- Cinéma Capitole
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
  'Cinéma Capitole',
  'Lausanne',
  'fun',
  'Plus grand cinéma à salle unique de Suisse, monument historique. Programmation art-et-essai et grand public.',
  46.5197, 6.6306,
  120, 3,
  ARRAY['Reservation necessaire','Horaires restreints'],
  ARRAY['Printemps','Été','Automne','Hiver'],
  ARRAY['Famille','Couple','Amis','Solo'],
  true, false,
  'https://www.capitolelausanne.ch', NULL, NULL,
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Cinéma Capitole' AND location_name = 'Lausanne'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Cinéma Capitole' AND location_name = 'Lausanne'
);

-- Casino Barrière Montreux
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
  'Casino Barrière Montreux',
  'Montreux',
  'fun',
  'Casino emblematique de Montreux. Machines a sous, jeux de table, bar, restaurant, programmation evenementielle.',
  46.4316, 6.9124,
  180, 5,
  ARRAY['Reservation necessaire'],
  ARRAY['Printemps','Été','Automne','Hiver'],
  ARRAY['Couple','Amis'],
  true, false,
  'https://www.casinosbarriere.com/fr/montreux.html', NULL, NULL,
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Casino Barrière Montreux' AND location_name = 'Montreux'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Casino Barrière Montreux' AND location_name = 'Montreux'
);

-- Train à vapeur Blonay-Chamby
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
  'Train à vapeur Blonay-Chamby',
  'Blonay',
  'fun',
  'Train a vapeur historique entre Blonay et Chamby (mai-octobre). Locomotives centenaires, musee ferroviaire en gare.',
  46.4628, 6.9103,
  180, 3,
  ARRAY['Parking','Reservation necessaire','Horaires restreints'],
  ARRAY['Printemps','Été','Automne'],
  ARRAY['Famille','Couple'],
  true, true,
  'https://www.blonay-chamby.ch', NULL, NULL,
  NULL, NULL, NULL, NULL,
  'seasonal', ARRAY[5,6,7,8,9,10]::int[], NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Train à vapeur Blonay-Chamby' AND location_name = 'Blonay'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Train à vapeur Blonay-Chamby' AND location_name = 'Blonay'
);

-- Funiculaire Vevey-Mont Pèlerin
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
  'Funiculaire Vevey-Mont Pèlerin',
  'Vevey',
  'fun',
  'Funiculaire historique reliant Vevey au Mont Pèlerin. 10 minutes de monte, vue lac et Alpes au sommet.',
  46.4633, 6.8492,
  60, 2,
  ARRAY['Horaires restreints'],
  ARRAY['Printemps','Été','Automne','Hiver'],
  ARRAY['Famille','Couple'],
  true, false,
  'https://www.mob.ch', NULL, NULL,
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Funiculaire Vevey-Mont Pèlerin' AND location_name = 'Vevey'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Funiculaire Vevey-Mont Pèlerin' AND location_name = 'Vevey'
);

-- Téléphérique Les Avants-Sonloup
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
  'Téléphérique Les Avants-Sonloup',
  'Les Avants',
  'fun',
  'Petit telecabine touristique entre Les Avants et Sonloup, dans les hauts de Montreux. Vue Riviera et Dents-du-Midi.',
  46.45, 6.97,
  60, 2,
  ARRAY['Parking','Horaires restreints'],
  ARRAY['Printemps','Été','Automne','Hiver'],
  ARRAY['Famille','Couple','Amis'],
  true, false,
  NULL, NULL, NULL,
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Téléphérique Les Avants-Sonloup' AND location_name = 'Les Avants'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Téléphérique Les Avants-Sonloup' AND location_name = 'Les Avants'
);

-- Karting Payerne
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
  'Karting Payerne',
  'Payerne',
  'fun',
  'Piste outdoor de karting a Payerne, 1km. Karts adultes et enfants, courses endurance, ideal enterrement de vie.',
  46.8228, 6.9433,
  90, 4,
  ARRAY['Parking','Reservation necessaire'],
  ARRAY['Printemps','Été','Automne'],
  ARRAY['Amis','Famille'],
  false, true,
  NULL, NULL, NULL,
  NULL, NULL, NULL, NULL,
  'seasonal', ARRAY[4,5,6,7,8,9,10]::int[], NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Karting Payerne' AND location_name = 'Payerne'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Karting Payerne' AND location_name = 'Payerne'
);

-- Marché folklorique de Vevey
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
  'Marché folklorique de Vevey',
  'Vevey',
  'fun',
  'Marche d''ete sur la Grand-Place : produits du terroir, artisanat, animations folkloriques (samedis juillet-aout).',
  46.4625, 6.8458,
  120, 1,
  ARRAY['Horaires restreints'],
  ARRAY['Été'],
  ARRAY['Famille','Couple','Amis'],
  false, true,
  NULL, NULL, NULL,
  NULL, NULL, NULL, NULL,
  'seasonal', ARRAY[7,8]::int[], ARRAY[6]::int[],
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Marché folklorique de Vevey' AND location_name = 'Vevey'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Marché folklorique de Vevey' AND location_name = 'Vevey'
);

-- Métro M2 Lausanne (touristique)
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
  'Métro M2 Lausanne (touristique)',
  'Lausanne',
  'fun',
  'Le M2, metro le plus pentu d''Europe (12% pente). Trajet panoramique Ouchy-Croisettes, attraction insolite.',
  46.5083, 6.6261,
  30, 1,
  ARRAY[]::text[],
  ARRAY['Printemps','Été','Automne','Hiver'],
  ARRAY['Famille','Couple','Solo'],
  true, false,
  'https://www.t-l.ch', NULL, NULL,
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Métro M2 Lausanne (touristique)' AND location_name = 'Lausanne'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Métro M2 Lausanne (touristique)' AND location_name = 'Lausanne'
);

-- Smashland Lausanne
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
  'Smashland Lausanne',
  'Lausanne',
  'fun',
  'Smash room a Lausanne. Casser des objets pour relacher le stress, equipement et combinaison fournis.',
  46.54, 6.62,
  60, 4,
  ARRAY['Reservation necessaire','Minimum de participants'],
  ARRAY['Printemps','Été','Automne','Hiver'],
  ARRAY['Amis','Couple'],
  true, false,
  NULL, NULL, NULL,
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Smashland Lausanne' AND location_name = 'Lausanne'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Smashland Lausanne' AND location_name = 'Lausanne'
);

-- Foire Habitat & Jardin Beaulieu
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
  'Foire Habitat & Jardin Beaulieu',
  'Lausanne',
  'fun',
  'Plus grand salon habitat de Suisse romande, mars chaque annee. 350 exposants, conferences, espaces decoration.',
  46.53, 6.628,
  240, 2,
  ARRAY['Parking','Horaires restreints'],
  ARRAY['Printemps'],
  ARRAY['Famille','Couple','Amis'],
  true, false,
  'https://www.habitat-jardin.ch', NULL, NULL,
  'Mars 2026', 'March 2026', '2026-03-07'::date, '2026-03-15'::date,
  'one_off', NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Foire Habitat & Jardin Beaulieu' AND location_name = 'Lausanne'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Foire Habitat & Jardin Beaulieu' AND location_name = 'Lausanne'
);

-- Comptoir Suisse Beaulieu
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
  'Comptoir Suisse Beaulieu',
  'Lausanne',
  'fun',
  'Foire commerciale de reference de Suisse romande. Salons themes (auto, loisirs, gastronomie), animations.',
  46.53, 6.628,
  240, 2,
  ARRAY['Parking','Horaires restreints'],
  ARRAY['Automne'],
  ARRAY['Famille','Couple','Amis'],
  true, false,
  NULL, NULL, NULL,
  'Septembre 2026', 'September 2026', '2026-09-11'::date, '2026-09-20'::date,
  'one_off', NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Comptoir Suisse Beaulieu' AND location_name = 'Lausanne'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Comptoir Suisse Beaulieu' AND location_name = 'Lausanne'
);

-- Cinéma Bellevaux
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
  'Cinéma Bellevaux',
  'Lausanne',
  'fun',
  'Cine-club historique de Lausanne. Programmation pointue, films d''auteur, debats post-projection. Atmosphere conviviale.',
  46.5333, 6.6361,
  120, 2,
  ARRAY['Horaires restreints'],
  ARRAY['Printemps','Été','Automne','Hiver'],
  ARRAY['Solo','Couple','Amis'],
  true, false,
  'https://www.cinema-bellevaux.ch', NULL, NULL,
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Cinéma Bellevaux' AND location_name = 'Lausanne'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Cinéma Bellevaux' AND location_name = 'Lausanne'
);

-- Mini-golf Préverenges
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
  'Mini-golf Préverenges',
  'Préverenges',
  'fun',
  'Parcours mini-golf 18 trous au bord du Leman. Ambiance familiale, restaurant terrasse, vue Mont-Blanc.',
  46.5092, 6.5269,
  90, 2,
  ARRAY['Parking'],
  ARRAY['Printemps','Été','Automne'],
  ARRAY['Famille','Couple','Amis'],
  false, true,
  NULL, NULL, NULL,
  NULL, NULL, NULL, NULL,
  'seasonal', ARRAY[4,5,6,7,8,9,10]::int[], NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Mini-golf Préverenges' AND location_name = 'Préverenges'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Mini-golf Préverenges' AND location_name = 'Préverenges'
);

-- Plage de Préverenges (été)
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
  'Plage de Préverenges (été)',
  'Préverenges',
  'fun',
  'Plage de sable, baignade Léman, beach-volley, locations paddle, snack. Spot estival familial très apprécié.',
  46.5092, 6.5269,
  240, 1,
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
  WHERE title = 'Plage de Préverenges (été)' AND location_name = 'Préverenges'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Plage de Préverenges (été)' AND location_name = 'Préverenges'
);

-- Téléphérique Caux-Glion
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
  'Téléphérique Caux-Glion',
  'Glion',
  'fun',
  'Funiculaire historique entre Glion et Caux. Vue panoramique sur Riviera, prolongement vers Rochers-de-Naye.',
  46.4333, 6.9417,
  60, 2,
  ARRAY['Horaires restreints'],
  ARRAY['Printemps','Été','Automne','Hiver'],
  ARRAY['Famille','Couple'],
  true, false,
  'https://www.mob.ch', NULL, NULL,
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Téléphérique Caux-Glion' AND location_name = 'Glion'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Téléphérique Caux-Glion' AND location_name = 'Glion'
);

-- Marché de Lausanne (Riponne)
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
  'Marché de Lausanne (Riponne)',
  'Lausanne',
  'fun',
  'Marche bi-hebdomadaire (mercredi et samedi) sur la Place de la Riponne. Produits du terroir, artisanat, ambiance.',
  46.5236, 6.6336,
  90, 1,
  ARRAY['Horaires restreints'],
  ARRAY['Printemps','Été','Automne','Hiver'],
  ARRAY['Famille','Couple','Solo'],
  false, true,
  NULL, NULL, NULL,
  NULL, NULL, NULL, NULL,
  'weekly', NULL, ARRAY[3,6]::int[],
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Marché de Lausanne (Riponne)' AND location_name = 'Lausanne'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Marché de Lausanne (Riponne)' AND location_name = 'Lausanne'
);

-- Glacier Express
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
  'Glacier Express',
  'Zermatt',
  'fun',
  'Train panoramique de prestige Zermatt-Saint-Moritz, ''le train rapide le plus lent du monde'' (8h, 91 tunnels, 291 ponts).',
  46.0207, 7.7491,
  480, 5,
  ARRAY['Reservation necessaire','Horaires restreints'],
  ARRAY['Printemps','Été','Automne','Hiver'],
  ARRAY['Famille','Couple','Amis'],
  true, false,
  'https://www.glacierexpress.ch', NULL, 'loc_upper',
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Glacier Express' AND location_name = 'Zermatt'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Glacier Express' AND location_name = 'Zermatt'
);

-- Funiculaire Saint-Luc-Tignousa
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
  'Funiculaire Saint-Luc-Tignousa',
  'Saint-Luc',
  'fun',
  'Funiculaire vers Tignousa (2''200m), point de depart du chemin des planetes. Vue 4000m valaisans.',
  46.2178, 7.6122,
  60, 3,
  ARRAY['Parking','Horaires restreints'],
  ARRAY['Printemps','Été','Automne','Hiver'],
  ARRAY['Famille','Couple','Amis'],
  true, false,
  'https://www.funiluc.ch', NULL, 'loc_central',
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Funiculaire Saint-Luc-Tignousa' AND location_name = 'Saint-Luc'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Funiculaire Saint-Luc-Tignousa' AND location_name = 'Saint-Luc'
);

-- Funiculaire Crans-Cry d'Er
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
  'Funiculaire Crans-Cry d''Er',
  'Crans-Montana',
  'fun',
  'Telecabine de Crans-Montana au sommet de Cry d''Er (2''267m). Restaurant panoramique, depart de randonnees.',
  46.3117, 7.4853,
  60, 4,
  ARRAY['Parking'],
  ARRAY['Printemps','Été','Automne','Hiver'],
  ARRAY['Famille','Couple','Amis'],
  true, false,
  'https://www.crans-montana.ch', NULL, 'loc_central',
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Funiculaire Crans-Cry d''Er' AND location_name = 'Crans-Montana'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Funiculaire Crans-Cry d''Er' AND location_name = 'Crans-Montana'
);

-- Karting Châteauneuf-Conthey
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
  'Karting Châteauneuf-Conthey',
  'Châteauneuf-Conthey',
  'fun',
  'Piste de karting indoor en plaine du Rhone. Karts puissants, championnat, ideal pour tous niveaux.',
  46.2167, 7.3083,
  90, 4,
  ARRAY['Parking','Reservation necessaire'],
  ARRAY['Printemps','Été','Automne','Hiver'],
  ARRAY['Amis','Famille'],
  true, false,
  NULL, NULL, 'loc_central',
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Karting Châteauneuf-Conthey' AND location_name = 'Châteauneuf-Conthey'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Karting Châteauneuf-Conthey' AND location_name = 'Châteauneuf-Conthey'
);

-- Mountain Cart Verbier
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
  'Mountain Cart Verbier',
  'Verbier',
  'fun',
  'Descente en chariots de montagne sur 4 km depuis La Chaux. Sensations, vue Combin, accessible des 7 ans.',
  46.0961, 7.2286,
  60, 4,
  ARRAY['Reservation necessaire'],
  ARRAY['Été','Automne'],
  ARRAY['Famille','Amis'],
  false, true,
  'https://www.verbier.ch', NULL, 'loc_central',
  NULL, NULL, NULL, NULL,
  'seasonal', ARRAY[6,7,8,9,10]::int[], NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Mountain Cart Verbier' AND location_name = 'Verbier'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Mountain Cart Verbier' AND location_name = 'Verbier'
);

-- Mountain Cart Crans-Montana
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
  'Mountain Cart Crans-Montana',
  'Crans-Montana',
  'fun',
  'Descente en mountain cart depuis Cry d''Er. Karts bridés pour les enfants, sensations garanties.',
  46.3117, 7.4853,
  60, 4,
  ARRAY['Reservation necessaire'],
  ARRAY['Été','Automne'],
  ARRAY['Famille','Amis'],
  false, true,
  NULL, NULL, 'loc_central',
  NULL, NULL, NULL, NULL,
  'seasonal', ARRAY[6,7,8,9,10]::int[], NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Mountain Cart Crans-Montana' AND location_name = 'Crans-Montana'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Mountain Cart Crans-Montana' AND location_name = 'Crans-Montana'
);

-- Trottinette tout-terrain Saas-Fee
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
  'Trottinette tout-terrain Saas-Fee',
  'Saas-Fee',
  'fun',
  'Descente en trottinette VTT depuis Hannig (2''350m) vers le village. 7 km de fun garanti.',
  46.1086, 7.9272,
  60, 3,
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
  WHERE title = 'Trottinette tout-terrain Saas-Fee' AND location_name = 'Saas-Fee'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Trottinette tout-terrain Saas-Fee' AND location_name = 'Saas-Fee'
);

-- Trottinette Crans-Montana
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
  'Trottinette Crans-Montana',
  'Crans-Montana',
  'fun',
  'Descente en trottinette tout-terrain depuis Cry d''Er. Plusieurs parcours selon niveau.',
  46.3117, 7.4853,
  60, 3,
  ARRAY['Reservation necessaire'],
  ARRAY['Été','Automne'],
  ARRAY['Famille','Amis'],
  false, true,
  NULL, NULL, 'loc_central',
  NULL, NULL, NULL, NULL,
  'seasonal', ARRAY[6,7,8,9,10]::int[], NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Trottinette Crans-Montana' AND location_name = 'Crans-Montana'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Trottinette Crans-Montana' AND location_name = 'Crans-Montana'
);

-- Trottinette Champéry
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
  'Trottinette Champéry',
  'Champéry',
  'fun',
  'Descente en trottinette tout-terrain depuis Croix-de-Culet vers Champery. 1100m de denivele negatif.',
  46.175, 6.8722,
  60, 3,
  ARRAY['Reservation necessaire'],
  ARRAY['Été','Automne'],
  ARRAY['Famille','Amis'],
  false, true,
  'https://www.champery.ch', NULL, 'loc_lower',
  NULL, NULL, NULL, NULL,
  'seasonal', ARRAY[6,7,8,9,10]::int[], NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Trottinette Champéry' AND location_name = 'Champéry'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Trottinette Champéry' AND location_name = 'Champéry'
);

-- Cinéma Capitole Sion
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
  'Cinéma Capitole Sion',
  'Sion',
  'fun',
  'Cinéma historique au cœur de Sion. 6 salles, programmation grand public et art-et-essai.',
  46.2306, 7.3603,
  120, 3,
  ARRAY['Reservation necessaire','Horaires restreints'],
  ARRAY['Printemps','Été','Automne','Hiver'],
  ARRAY['Famille','Couple','Amis','Solo'],
  true, false,
  'https://www.cinemas-sion.ch', NULL, 'loc_central',
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Cinéma Capitole Sion' AND location_name = 'Sion'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Cinéma Capitole Sion' AND location_name = 'Sion'
);

-- Cinéma Lux Sion
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
  'Cinéma Lux Sion',
  'Sion',
  'fun',
  'Cinéma de quartier de Sion. Programmation art-et-essai, films d''auteur, films suisses en VO.',
  46.2306, 7.3603,
  120, 3,
  ARRAY['Reservation necessaire','Horaires restreints'],
  ARRAY['Printemps','Été','Automne','Hiver'],
  ARRAY['Solo','Couple','Amis'],
  true, false,
  'https://www.cinemas-sion.ch', NULL, 'loc_central',
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Cinéma Lux Sion' AND location_name = 'Sion'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Cinéma Lux Sion' AND location_name = 'Sion'
);

-- Bowling Sion
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
  'Bowling Sion',
  'Sion',
  'fun',
  'Centre de bowling moderne a Sion. 10 pistes, billard, snack-bar, tournois reguliers.',
  46.2306, 7.3603,
  90, 3,
  ARRAY[]::text[],
  ARRAY['Printemps','Été','Automne','Hiver'],
  ARRAY['Famille','Amis','Couple'],
  true, false,
  NULL, NULL, 'loc_central',
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Bowling Sion' AND location_name = 'Sion'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Bowling Sion' AND location_name = 'Sion'
);

-- Bowling Sierre
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
  'Bowling Sierre',
  'Sierre',
  'fun',
  'Centre de bowling de Sierre. 8 pistes, restaurant, ideal pour soirees entre amis.',
  46.2917, 7.5333,
  90, 3,
  ARRAY[]::text[],
  ARRAY['Printemps','Été','Automne','Hiver'],
  ARRAY['Famille','Amis','Couple'],
  true, false,
  NULL, NULL, 'loc_central',
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Bowling Sierre' AND location_name = 'Sierre'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Bowling Sierre' AND location_name = 'Sierre'
);

-- Casino de Crans-Montana
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
  'Casino de Crans-Montana',
  'Crans-Montana',
  'fun',
  'Casino de la station de Crans. Machines a sous, jeux de table, restaurant, evenements.',
  46.3117, 7.4853,
  180, 5,
  ARRAY['Reservation necessaire'],
  ARRAY['Printemps','Été','Automne','Hiver'],
  ARRAY['Couple','Amis'],
  true, false,
  'https://www.casinodecrans.ch', NULL, 'loc_central',
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Casino de Crans-Montana' AND location_name = 'Crans-Montana'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Casino de Crans-Montana' AND location_name = 'Crans-Montana'
);

-- Casino de Saxon
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
  'Casino de Saxon',
  'Saxon',
  'fun',
  'Plus ancien casino du Valais (1856). Machines a sous, jeux de table, ambiance retro.',
  46.15, 7.175,
  180, 5,
  ARRAY['Reservation necessaire'],
  ARRAY['Printemps','Été','Automne','Hiver'],
  ARRAY['Couple','Amis'],
  true, false,
  'https://www.casinodesaxon.ch', NULL, 'loc_central',
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Casino de Saxon' AND location_name = 'Saxon'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Casino de Saxon' AND location_name = 'Saxon'
);

-- Téléphérique Saas-Almagell-Heidbodme
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
  'Téléphérique Saas-Almagell-Heidbodme',
  'Saas-Almagell',
  'fun',
  'Telecabine entre Saas-Almagell et Heidbodme (2''400m). Acces randos, panorama 4000m.',
  46.0944, 7.9583,
  60, 3,
  ARRAY['Parking','Horaires restreints'],
  ARRAY['Été','Automne','Hiver'],
  ARRAY['Famille','Couple','Amis'],
  true, false,
  'https://www.saas-almagell.ch', NULL, 'loc_upper',
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Téléphérique Saas-Almagell-Heidbodme' AND location_name = 'Saas-Almagell'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Téléphérique Saas-Almagell-Heidbodme' AND location_name = 'Saas-Almagell'
);

-- Tubing Saas-Fee Spielboden
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
  'Tubing Saas-Fee Spielboden',
  'Saas-Fee',
  'fun',
  'Piste de tubing en hiver a Spielboden. Descente en bouée gonflable sur 100m de denivele, fun garanti.',
  46.1086, 7.9272,
  60, 3,
  ARRAY['Reservation necessaire'],
  ARRAY['Hiver'],
  ARRAY['Famille','Amis'],
  false, true,
  NULL, NULL, 'loc_upper',
  NULL, NULL, NULL, NULL,
  'seasonal', ARRAY[12,1,2,3]::int[], NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Tubing Saas-Fee Spielboden' AND location_name = 'Saas-Fee'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Tubing Saas-Fee Spielboden' AND location_name = 'Saas-Fee'
);

-- Gravity Park Saas-Fee
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
  'Gravity Park Saas-Fee',
  'Saas-Fee',
  'fun',
  'Snowpark international au glacier de Saas-Fee. 25+ kickers, rails, half-pipe. Open ete et hiver.',
  46.1086, 7.9272,
  240, 5,
  ARRAY['Reservation necessaire'],
  ARRAY['Été','Automne','Hiver'],
  ARRAY['Amis','Solo'],
  false, true,
  'https://www.saas-fee.ch', NULL, 'loc_upper',
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Gravity Park Saas-Fee' AND location_name = 'Saas-Fee'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Gravity Park Saas-Fee' AND location_name = 'Saas-Fee'
);

-- Marché de Sion
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
  'Marché de Sion',
  'Sion',
  'fun',
  'Marche traditionnel sur la rue du Grand-Pont (vendredis et samedis). Produits valaisans, ambiance medievale.',
  46.2306, 7.3603,
  90, 1,
  ARRAY['Horaires restreints'],
  ARRAY['Printemps','Été','Automne','Hiver'],
  ARRAY['Famille','Couple','Solo'],
  false, true,
  NULL, NULL, 'loc_central',
  NULL, NULL, NULL, NULL,
  'weekly', NULL, ARRAY[5,6]::int[],
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Marché de Sion' AND location_name = 'Sion'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Marché de Sion' AND location_name = 'Sion'
);

-- Marché de Martigny
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
  'Marché de Martigny',
  'Martigny',
  'fun',
  'Marche du jeudi place Centrale. Produits du terroir valaisan, vins, fromages, animations.',
  46.1011, 7.075,
  90, 1,
  ARRAY['Horaires restreints'],
  ARRAY['Printemps','Été','Automne','Hiver'],
  ARRAY['Famille','Couple','Solo'],
  false, true,
  NULL, NULL, 'loc_lower',
  NULL, NULL, NULL, NULL,
  'weekly', NULL, ARRAY[4]::int[],
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Marché de Martigny' AND location_name = 'Martigny'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Marché de Martigny' AND location_name = 'Martigny'
);

-- Saint-Bernard Express
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
  'Saint-Bernard Express',
  'Orsières',
  'fun',
  'Train touristique du Saint-Bernard Express, dessert le Pays du Saint-Bernard (Champex, La Fouly, Bourg-Saint-Pierre).',
  46.0306, 7.1481,
  90, 3,
  ARRAY['Horaires restreints'],
  ARRAY['Printemps','Été','Automne','Hiver'],
  ARRAY['Famille','Couple','Amis'],
  true, false,
  'https://www.tmrsa.ch', NULL, 'loc_lower',
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Saint-Bernard Express' AND location_name = 'Orsières'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Saint-Bernard Express' AND location_name = 'Orsières'
);

-- Funi-Park Saint-Luc
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
  'Funi-Park Saint-Luc',
  'Saint-Luc',
  'fun',
  'Parc de jeux et de detente au sommet du funiculaire de Saint-Luc. Tyrolienne, parcours aventure, restaurant.',
  46.2178, 7.6122,
  180, 4,
  ARRAY['Parking','Reservation necessaire'],
  ARRAY['Été','Automne'],
  ARRAY['Famille'],
  false, true,
  NULL, NULL, 'loc_central',
  NULL, NULL, NULL, NULL,
  'seasonal', ARRAY[6,7,8,9]::int[], NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Funi-Park Saint-Luc' AND location_name = 'Saint-Luc'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Funi-Park Saint-Luc' AND location_name = 'Saint-Luc'
);

-- Brigerbad Wasserspielpark
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
  'Brigerbad Wasserspielpark',
  'Brig-Glis',
  'fun',
  'Parc aquatique enfants des Bains de Brigerbad. Toboggans thermaux, rivière sauvage, châteaux d''eau.',
  46.3056, 7.9694,
  240, 4,
  ARRAY['Parking','Reservation necessaire'],
  ARRAY['Été','Automne'],
  ARRAY['Famille'],
  false, true,
  'https://www.thermalbad-brigerbad.ch', NULL, 'loc_upper',
  NULL, NULL, NULL, NULL,
  'seasonal', ARRAY[5,6,7,8,9]::int[], NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Brigerbad Wasserspielpark' AND location_name = 'Brig-Glis'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Brigerbad Wasserspielpark' AND location_name = 'Brig-Glis'
);

-- Espace Mont-Cervin Findeln
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
  'Espace Mont-Cervin Findeln',
  'Findeln',
  'fun',
  'Hameau alpin a 2''130m face au Cervin. Restaurants etagés sur la pente, ambiance unique entre les melezes.',
  45.9961, 7.76,
  180, 3,
  ARRAY['Reservation necessaire'],
  ARRAY['Été','Hiver'],
  ARRAY['Couple','Famille','Amis'],
  false, true,
  NULL, NULL, 'loc_upper',
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Espace Mont-Cervin Findeln' AND location_name = 'Findeln'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Espace Mont-Cervin Findeln' AND location_name = 'Findeln'
);

-- Marché de Brigue (Manor)
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
  'Marché de Brigue (Manor)',
  'Brigue',
  'fun',
  'Marche hebdomadaire de Brigue, en alemanique, produits du Haut-Valais : pain de seigle AOP, viande sechee, vin Heida.',
  46.3167, 7.9833,
  90, 1,
  ARRAY['Horaires restreints'],
  ARRAY['Printemps','Été','Automne','Hiver'],
  ARRAY['Famille','Couple','Solo'],
  false, true,
  NULL, NULL, 'loc_upper',
  NULL, NULL, NULL, NULL,
  'weekly', NULL, ARRAY[4]::int[],
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Marché de Brigue (Manor)' AND location_name = 'Brigue'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Marché de Brigue (Manor)' AND location_name = 'Brigue'
);

-- ============================================================
-- Total : 100 activites (50 relax + 50 fun)
-- Avec activity_url : 70/100
-- Avec location_zone (Valais) : 50/100
-- Avec contraintes temporelles : 24/100
-- ============================================================