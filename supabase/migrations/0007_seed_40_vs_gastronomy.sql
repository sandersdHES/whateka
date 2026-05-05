-- Whateka -- Migration 0007 : 20 bars + 20 restos VS
-- ============================================================
-- 40 etablissements gastronomiques reputes du canton du Valais,
-- inseres comme soumissions a valider (status='pending',
-- categorie 'gastronomy'). Selection editoriale, doublons evites
-- avec migration 0005.
-- 
-- 20 BARS : Verbier (5), Zermatt (5), Crans-Montana (3),
--           Sion (2), Saas-Fee (2), Bas-Valais (2),
--           Martigny/Saxon
-- 20 RESTOS : Sion (3), Sierre (2), Verbier (4),
--             Crans-Montana (2), Zermatt (5),
--             Bas-Valais (2), Vallee d'Herens & Saas (2)
-- 
-- Idempotent : WHERE NOT EXISTS sur (title, location_name)
-- dans activity_submissions ET activities.
-- ============================================================

-- Le Farinet After Ski
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
  'Le Farinet After Ski',
  'Verbier',
  'gastronomy',
  'Bar d''apres-ski mythique de Verbier. Concerts live, ambiance survoltee de 16h a 20h, l''institution en station.',
  46.0961, 7.2286,
  120, 4,
  ARRAY[]::text[],
  ARRAY['Hiver'],
  ARRAY['Amis','Couple'],
  true, true,
  'https://www.hotelfarinet.com', NULL, 'loc_central',
  NULL, NULL, NULL, NULL,
  'seasonal', ARRAY[12,1,2,3,4]::int[], NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Le Farinet After Ski' AND location_name = 'Verbier'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Le Farinet After Ski' AND location_name = 'Verbier'
);

-- Pub Mont Fort
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
  'Pub Mont Fort',
  'Verbier',
  'gastronomy',
  'Pub anglais culte de Verbier. Plus de 50 bieres, ambiance ski bums, soirees karaoke et matchs.',
  46.0961, 7.2286,
  120, 3,
  ARRAY[]::text[],
  ARRAY['Printemps','Été','Automne','Hiver'],
  ARRAY['Amis','Couple'],
  true, true,
  'https://www.pubmontfort.com', NULL, 'loc_central',
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Pub Mont Fort' AND location_name = 'Verbier'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Pub Mont Fort' AND location_name = 'Verbier'
);

-- T-Bar Verbier
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
  'T-Bar Verbier',
  'Verbier',
  'gastronomy',
  'Bar a cocktails branche au coeur de Verbier. Mixologie soignee, DJ residents, clientele international.',
  46.0961, 7.2286,
  120, 4,
  ARRAY[]::text[],
  ARRAY['Printemps','Été','Automne','Hiver'],
  ARRAY['Amis','Couple'],
  true, false,
  NULL, NULL, 'loc_central',
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'T-Bar Verbier' AND location_name = 'Verbier'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'T-Bar Verbier' AND location_name = 'Verbier'
);

-- Bar de la Cordée des Alpes
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
  'Bar de la Cordée des Alpes',
  'Verbier',
  'gastronomy',
  'Bar de l''hotel 5* La Cordée des Alpes. Ambiance feutree alpine, mixologie haut de gamme, terrasse vue Combin.',
  46.0961, 7.2286,
  120, 5,
  ARRAY['Reservation necessaire'],
  ARRAY['Printemps','Été','Automne','Hiver'],
  ARRAY['Couple'],
  true, true,
  'https://www.hotelcordee.com', NULL, 'loc_central',
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Bar de la Cordée des Alpes' AND location_name = 'Verbier'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Bar de la Cordée des Alpes' AND location_name = 'Verbier'
);

-- Carlsberg Café Verbier
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
  'Carlsberg Café Verbier',
  'Verbier',
  'gastronomy',
  'Cafe-bar central de Verbier. Terrasse animee sur la Place Centrale, biere a la pression, ambiance familiale.',
  46.0961, 7.2286,
  90, 3,
  ARRAY[]::text[],
  ARRAY['Printemps','Été','Automne','Hiver'],
  ARRAY['Amis','Famille','Couple'],
  true, true,
  NULL, NULL, 'loc_central',
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Carlsberg Café Verbier' AND location_name = 'Verbier'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Carlsberg Café Verbier' AND location_name = 'Verbier'
);

-- Hennu Stall
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
  'Hennu Stall',
  'Zermatt',
  'gastronomy',
  'Bar d''apres-ski mythique sur la piste Furi-Zermatt. Cabane en bois, ambiance après-ski legendaire avec DJs et hits revisites.',
  46.0044, 7.7508,
  120, 4,
  ARRAY[]::text[],
  ARRAY['Hiver'],
  ARRAY['Amis','Couple'],
  true, true,
  'https://www.hennustall.ch', NULL, 'loc_upper',
  NULL, NULL, NULL, NULL,
  'seasonal', ARRAY[12,1,2,3,4]::int[], NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Hennu Stall' AND location_name = 'Zermatt'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Hennu Stall' AND location_name = 'Zermatt'
);

-- Papperla Pub
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
  'Papperla Pub',
  'Zermatt',
  'gastronomy',
  'Pub culte de Zermatt depuis 1989. Concerts live, plus de 30 bieres, ambiance survoltee jusqu''au bout de la nuit.',
  46.0207, 7.7491,
  180, 3,
  ARRAY[]::text[],
  ARRAY['Printemps','Été','Automne','Hiver'],
  ARRAY['Amis','Couple'],
  true, false,
  'https://www.papperlapub.ch', NULL, 'loc_upper',
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Papperla Pub' AND location_name = 'Zermatt'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Papperla Pub' AND location_name = 'Zermatt'
);

-- Vernissage
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
  'Vernissage',
  'Zermatt',
  'gastronomy',
  'Bar-galerie d''art de Heinz Julen, lieu unique mêlant cocktails, design et expositions. Decoration spectaculaire.',
  46.0207, 7.7491,
  120, 4,
  ARRAY['Reservation necessaire'],
  ARRAY['Printemps','Été','Automne','Hiver'],
  ARRAY['Couple','Amis'],
  true, false,
  'https://www.heinzjulen.com', NULL, 'loc_upper',
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Vernissage' AND location_name = 'Zermatt'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Vernissage' AND location_name = 'Zermatt'
);

-- Cervo Bar Mountain Resort
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
  'Cervo Bar Mountain Resort',
  'Zermatt',
  'gastronomy',
  'Bar-lounge du Cervo Resort, terrasse panoramique avec vue sur le Cervin. Ambiance design alpine, cocktails signature.',
  46.0207, 7.7491,
  120, 5,
  ARRAY['Reservation necessaire'],
  ARRAY['Printemps','Été','Automne','Hiver'],
  ARRAY['Couple','Amis'],
  true, true,
  'https://www.cervo.swiss', NULL, 'loc_upper',
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Cervo Bar Mountain Resort' AND location_name = 'Zermatt'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Cervo Bar Mountain Resort' AND location_name = 'Zermatt'
);

-- Snowboat Bar
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
  'Snowboat Bar',
  'Zermatt',
  'gastronomy',
  'Bar-restaurant insolite en forme de bateau sur la Vispa. Terrasse riveraine, cocktails, sushis, ambiance estivale.',
  46.0207, 7.7491,
  120, 4,
  ARRAY[]::text[],
  ARRAY['Printemps','Été','Automne'],
  ARRAY['Couple','Amis','Famille'],
  true, true,
  'https://www.snowboat.ch', NULL, 'loc_upper',
  NULL, NULL, NULL, NULL,
  'seasonal', ARRAY[4,5,6,7,8,9,10]::int[], NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Snowboat Bar' AND location_name = 'Zermatt'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Snowboat Bar' AND location_name = 'Zermatt'
);

-- Pacha Mama Crans
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
  'Pacha Mama Crans',
  'Crans-Montana',
  'gastronomy',
  'Bar latino festif de Crans. Cocktails caribbean, salsa et reggaeton, ambiance chaude jusqu''a 4h.',
  46.3117, 7.4853,
  180, 3,
  ARRAY[]::text[],
  ARRAY['Printemps','Été','Automne','Hiver'],
  ARRAY['Amis','Couple'],
  true, false,
  NULL, NULL, 'loc_central',
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Pacha Mama Crans' AND location_name = 'Crans-Montana'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Pacha Mama Crans' AND location_name = 'Crans-Montana'
);

-- Café 1900 Crans
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
  'Café 1900 Crans',
  'Crans-Montana',
  'gastronomy',
  'Cafe-bar Belle Epoque au coeur de Crans. Terrasse pavee, planches valaisannes, vins de la region.',
  46.3117, 7.4853,
  90, 3,
  ARRAY[]::text[],
  ARRAY['Printemps','Été','Automne','Hiver'],
  ARRAY['Couple','Amis','Famille'],
  true, true,
  NULL, NULL, 'loc_central',
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Café 1900 Crans' AND location_name = 'Crans-Montana'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Café 1900 Crans' AND location_name = 'Crans-Montana'
);

-- Le Yeti Crans
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
  'Le Yeti Crans',
  'Crans-Montana',
  'gastronomy',
  'Bar/club emblematique de Crans-Montana. Apres-ski en hiver, club nocturne le weekend.',
  46.3117, 7.4853,
  180, 4,
  ARRAY[]::text[],
  ARRAY['Printemps','Été','Automne','Hiver'],
  ARRAY['Amis'],
  true, false,
  NULL, NULL, 'loc_central',
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Le Yeti Crans' AND location_name = 'Crans-Montana'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Le Yeti Crans' AND location_name = 'Crans-Montana'
);

-- Bar Tabac Sion
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
  'Bar Tabac Sion',
  'Sion',
  'gastronomy',
  'Cocktail bar contemporain au coeur de Sion. Mixologie pointue, carte saisonniere, ambiance speakeasy.',
  46.2306, 7.3603,
  120, 4,
  ARRAY['Reservation necessaire'],
  ARRAY['Printemps','Été','Automne','Hiver'],
  ARRAY['Couple','Amis'],
  true, false,
  NULL, NULL, 'loc_central',
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Bar Tabac Sion' AND location_name = 'Sion'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Bar Tabac Sion' AND location_name = 'Sion'
);

-- Le Verre à Pied
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
  'Le Verre à Pied',
  'Sion',
  'gastronomy',
  'Bar a vins valaisans niche dans la vieille ville de Sion. Selection pointue, planches du terroir, ambiance conviviale.',
  46.2306, 7.3603,
  120, 3,
  ARRAY['Reservation necessaire'],
  ARRAY['Printemps','Été','Automne','Hiver'],
  ARRAY['Couple','Amis'],
  true, true,
  NULL, NULL, 'loc_central',
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Le Verre à Pied' AND location_name = 'Sion'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Le Verre à Pied' AND location_name = 'Sion'
);

-- Nesti's Ski Bar
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
  'Nesti''s Ski Bar',
  'Saas-Fee',
  'gastronomy',
  'Bar d''apres-ski historique de Saas-Fee. Ambiance bouillonnante, hits internationaux, terrasse face aux pistes.',
  46.1086, 7.9272,
  120, 4,
  ARRAY[]::text[],
  ARRAY['Hiver'],
  ARRAY['Amis','Couple'],
  true, true,
  'https://www.nestiskibar.ch', NULL, 'loc_upper',
  NULL, NULL, NULL, NULL,
  'seasonal', ARRAY[12,1,2,3,4]::int[], NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Nesti''s Ski Bar' AND location_name = 'Saas-Fee'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Nesti''s Ski Bar' AND location_name = 'Saas-Fee'
);

-- Popcorn Pub Saas-Fee
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
  'Popcorn Pub Saas-Fee',
  'Saas-Fee',
  'gastronomy',
  'Pub culte de la scene snowboard internationale. Concerts live, DJ sets, atmosphere ride/festive.',
  46.1086, 7.9272,
  180, 3,
  ARRAY[]::text[],
  ARRAY['Printemps','Été','Automne','Hiver'],
  ARRAY['Amis'],
  true, false,
  'https://www.popcorn.ch', NULL, 'loc_upper',
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Popcorn Pub Saas-Fee' AND location_name = 'Saas-Fee'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Popcorn Pub Saas-Fee' AND location_name = 'Saas-Fee'
);

-- La Vache Qui Vole
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
  'La Vache Qui Vole',
  'Martigny',
  'gastronomy',
  'Pub-restaurant de reference a Martigny. Plus de 100 bieres, terrasse en ete, ambiance conviviale.',
  46.1011, 7.075,
  120, 3,
  ARRAY[]::text[],
  ARRAY['Printemps','Été','Automne','Hiver'],
  ARRAY['Amis','Couple','Famille'],
  true, true,
  NULL, NULL, 'loc_lower',
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'La Vache Qui Vole' AND location_name = 'Martigny'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'La Vache Qui Vole' AND location_name = 'Martigny'
);

-- Bar Casino Saxon
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
  'Bar Casino Saxon',
  'Saxon',
  'gastronomy',
  'Bar du Casino de Saxon. Ambiance lounge, cocktails, animations le weekend, l''un des rares casinos du Valais.',
  46.15, 7.175,
  120, 4,
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
  WHERE title = 'Bar Casino Saxon' AND location_name = 'Saxon'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Bar Casino Saxon' AND location_name = 'Saxon'
);

-- Bar Walliserhof Leukerbad
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
  'Bar Walliserhof Leukerbad',
  'Loèche-les-Bains',
  'gastronomy',
  'Bar de l''hotel historique Walliserhof a Loeche-les-Bains. Cocktails alpins, terrasse face aux falaises, ambiance feutree post-thermes.',
  46.385, 7.6311,
  90, 4,
  ARRAY['Reservation necessaire'],
  ARRAY['Printemps','Été','Automne','Hiver'],
  ARRAY['Couple','Amis'],
  true, true,
  'https://www.walliserhof-leukerbad.ch', NULL, 'loc_upper',
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Bar Walliserhof Leukerbad' AND location_name = 'Loèche-les-Bains'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Bar Walliserhof Leukerbad' AND location_name = 'Loèche-les-Bains'
);

-- Le Cerf
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
  'Le Cerf',
  'Sion',
  'gastronomy',
  'Restaurant gastronomique historique de Sion (1* Michelin selon les annees). Cuisine valaisanne raffinee, cave d''exception.',
  46.23, 7.36,
  180, 5,
  ARRAY['Reservation necessaire'],
  ARRAY['Printemps','Été','Automne','Hiver'],
  ARRAY['Couple','Amis'],
  true, false,
  'https://www.hotel-du-cerf.ch', NULL, 'loc_central',
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Le Cerf' AND location_name = 'Sion'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Le Cerf' AND location_name = 'Sion'
);

-- Le Mazot Sion
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
  'Le Mazot Sion',
  'Sion',
  'gastronomy',
  'Restaurant traditionnel valaisan : raclette, fondue, viande sechee. Ambiance chalet authentique en plein centre-ville.',
  46.2306, 7.3603,
  120, 3,
  ARRAY['Reservation necessaire'],
  ARRAY['Printemps','Été','Automne','Hiver'],
  ARRAY['Couple','Famille','Amis'],
  true, false,
  NULL, NULL, 'loc_central',
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Le Mazot Sion' AND location_name = 'Sion'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Le Mazot Sion' AND location_name = 'Sion'
);

-- Restaurant L'Ardévaz
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
  'Restaurant L''Ardévaz',
  'Chamoson',
  'gastronomy',
  'Restaurant gastronomique au coeur des vignes de Chamoson. Cuisine du terroir revisitee, vins du Domaine de l''Ardevaz.',
  46.2042, 7.2256,
  180, 4,
  ARRAY['Reservation necessaire'],
  ARRAY['Printemps','Été','Automne','Hiver'],
  ARRAY['Couple','Amis'],
  true, true,
  NULL, NULL, 'loc_central',
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Restaurant L''Ardévaz' AND location_name = 'Chamoson'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Restaurant L''Ardévaz' AND location_name = 'Chamoson'
);

-- L'Atelier Gourmand
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
  'L''Atelier Gourmand',
  'Sierre',
  'gastronomy',
  'Restaurant gastronomique de Sierre, cuisine creative aux saveurs du sud. Carte de saison, vins valaisans pointus.',
  46.2917, 7.5333,
  180, 4,
  ARRAY['Reservation necessaire'],
  ARRAY['Printemps','Été','Automne','Hiver'],
  ARRAY['Couple'],
  true, false,
  NULL, NULL, 'loc_central',
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'L''Atelier Gourmand' AND location_name = 'Sierre'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'L''Atelier Gourmand' AND location_name = 'Sierre'
);

-- Restaurant La Mi-Côte
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
  'Restaurant La Mi-Côte',
  'Mollens',
  'gastronomy',
  'Bistro reconnu dans les hauts de Sierre. Cuisine du marche, terrasse vue Alpes, vins de la region.',
  46.3194, 7.5125,
  150, 4,
  ARRAY['Reservation necessaire'],
  ARRAY['Printemps','Été','Automne','Hiver'],
  ARRAY['Couple','Amis'],
  true, true,
  NULL, NULL, 'loc_central',
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Restaurant La Mi-Côte' AND location_name = 'Mollens'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Restaurant La Mi-Côte' AND location_name = 'Mollens'
);

-- Le Chalet d'Adrien
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
  'Le Chalet d''Adrien',
  'Verbier',
  'gastronomy',
  'Restaurant gastronomique du Chalet d''Adrien (Relais & Châteaux). Cuisine raffinee aux produits valaisans, terrasse vue Combin.',
  46.0961, 7.2286,
  240, 5,
  ARRAY['Reservation necessaire'],
  ARRAY['Printemps','Été','Automne','Hiver'],
  ARRAY['Couple'],
  true, true,
  'https://www.chalet-adrien.com', NULL, 'loc_central',
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Le Chalet d''Adrien' AND location_name = 'Verbier'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Le Chalet d''Adrien' AND location_name = 'Verbier'
);

-- Le Carnotzet du Chalet d'Adrien
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
  'Le Carnotzet du Chalet d''Adrien',
  'Verbier',
  'gastronomy',
  'Annexe traditionnelle du Chalet d''Adrien : raclette, fondue, viande sechee. Cadre chalet authentique.',
  46.0961, 7.2286,
  150, 4,
  ARRAY['Reservation necessaire'],
  ARRAY['Printemps','Été','Automne','Hiver'],
  ARRAY['Couple','Famille','Amis'],
  true, false,
  'https://www.chalet-adrien.com', NULL, 'loc_central',
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Le Carnotzet du Chalet d''Adrien' AND location_name = 'Verbier'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Le Carnotzet du Chalet d''Adrien' AND location_name = 'Verbier'
);

-- Restaurant Le Roxor
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
  'Restaurant Le Roxor',
  'Verbier',
  'gastronomy',
  'Restaurant gastronomique de l''hotel La Cordée des Alpes. Cuisine creative, produits locaux, ambiance feutree.',
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
  WHERE title = 'Restaurant Le Roxor' AND location_name = 'Verbier'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Restaurant Le Roxor' AND location_name = 'Verbier'
);

-- Restaurant Le Truffé
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
  'Restaurant Le Truffé',
  'Verbier',
  'gastronomy',
  'Restaurant tendance de Verbier specialise truffes et viandes maturees. Cave a vins exceptionnelle.',
  46.0961, 7.2286,
  180, 5,
  ARRAY['Reservation necessaire'],
  ARRAY['Printemps','Été','Automne','Hiver'],
  ARRAY['Couple','Amis'],
  true, false,
  NULL, NULL, 'loc_central',
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Restaurant Le Truffé' AND location_name = 'Verbier'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Restaurant Le Truffé' AND location_name = 'Verbier'
);

-- Restaurant L'Etrier
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
  'Restaurant L''Etrier',
  'Crans-Montana',
  'gastronomy',
  'Restaurant gastronomique de Crans-Montana. Cuisine raffinee aux saveurs valaisannes, cave reputee, terrasse en ete.',
  46.3117, 7.4853,
  180, 5,
  ARRAY['Reservation necessaire'],
  ARRAY['Printemps','Été','Automne','Hiver'],
  ARRAY['Couple'],
  true, true,
  NULL, NULL, 'loc_central',
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Restaurant L''Etrier' AND location_name = 'Crans-Montana'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Restaurant L''Etrier' AND location_name = 'Crans-Montana'
);

-- Le Mont Blanc Crans
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
  'Le Mont Blanc Crans',
  'Crans-Montana',
  'gastronomy',
  'Restaurant traditionnel valaisan a Crans. Specialites : fondue au safran, raclette AOC, viande sechee maison.',
  46.3117, 7.4853,
  150, 4,
  ARRAY['Reservation necessaire'],
  ARRAY['Printemps','Été','Automne','Hiver'],
  ARRAY['Couple','Famille','Amis'],
  true, true,
  NULL, NULL, 'loc_central',
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Le Mont Blanc Crans' AND location_name = 'Crans-Montana'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Le Mont Blanc Crans' AND location_name = 'Crans-Montana'
);

-- After Seven
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
  'After Seven',
  'Zermatt',
  'gastronomy',
  'Restaurant gastronomique 2* Michelin de l''hotel Backstage. Cuisine creative experimentale, l''une des meilleures tables de Suisse.',
  46.0207, 7.7491,
  240, 5,
  ARRAY['Reservation necessaire'],
  ARRAY['Printemps','Été','Automne','Hiver'],
  ARRAY['Couple'],
  true, false,
  'https://www.backstagehotel.ch', NULL, 'loc_upper',
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'After Seven' AND location_name = 'Zermatt'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'After Seven' AND location_name = 'Zermatt'
);

-- Chez Vrony
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
  'Chez Vrony',
  'Findeln',
  'gastronomy',
  'Restaurant d''altitude iconique a Findeln (2''130m), terrasse face au Cervin. Cuisine valaisanne raffinee, l''un des plus beaux restaurants de montagne au monde.',
  45.9956, 7.7592,
  180, 5,
  ARRAY['Reservation necessaire'],
  ARRAY['Été','Hiver'],
  ARRAY['Couple','Amis','Famille'],
  true, true,
  'https://www.chezvrony.ch', NULL, 'loc_upper',
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Chez Vrony' AND location_name = 'Findeln'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Chez Vrony' AND location_name = 'Findeln'
);

-- Findlerhof
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
  'Findlerhof',
  'Findeln',
  'gastronomy',
  'Restaurant de montagne historique a Findeln. Terrasse spectaculaire face au Cervin, specialites valaisannes, jardin d''herbes alpines.',
  45.9961, 7.76,
  150, 4,
  ARRAY['Reservation necessaire'],
  ARRAY['Été','Hiver'],
  ARRAY['Couple','Amis','Famille'],
  true, true,
  'https://www.findlerhof.ch', NULL, 'loc_upper',
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Findlerhof' AND location_name = 'Findeln'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Findlerhof' AND location_name = 'Findeln'
);

-- Schäferstube Zermatt
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
  'Schäferstube Zermatt',
  'Zermatt',
  'gastronomy',
  'Restaurant emblematique de l''Hotel Julen specialise dans l''agneau du Val d''Herens. Decor chalet, viandes au feu de bois.',
  46.0207, 7.7491,
  180, 4,
  ARRAY['Reservation necessaire'],
  ARRAY['Printemps','Été','Automne','Hiver'],
  ARRAY['Couple','Famille','Amis'],
  true, false,
  'https://www.julen.ch', NULL, 'loc_upper',
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Schäferstube Zermatt' AND location_name = 'Zermatt'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Schäferstube Zermatt' AND location_name = 'Zermatt'
);

-- Whymper-Stube
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
  'Whymper-Stube',
  'Zermatt',
  'gastronomy',
  'Restaurant traditionnel ou loger Edward Whymper avant son ascension du Cervin. Fondues primees, ambiance historique.',
  46.0207, 7.7491,
  120, 3,
  ARRAY['Reservation necessaire'],
  ARRAY['Printemps','Été','Automne','Hiver'],
  ARRAY['Famille','Couple','Amis'],
  true, false,
  'https://www.whymper-stube.ch', NULL, 'loc_upper',
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Whymper-Stube' AND location_name = 'Zermatt'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Whymper-Stube' AND location_name = 'Zermatt'
);

-- La Porte d'Octodure
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
  'La Porte d''Octodure',
  'Martigny',
  'gastronomy',
  'Restaurant gastronomique reference a Martigny. Cuisine raffinee aux produits du terroir, vins valaisans pointus.',
  46.1011, 7.075,
  180, 4,
  ARRAY['Reservation necessaire'],
  ARRAY['Printemps','Été','Automne','Hiver'],
  ARRAY['Couple'],
  true, true,
  'https://www.porte-octodure.ch', NULL, 'loc_lower',
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'La Porte d''Octodure' AND location_name = 'Martigny'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'La Porte d''Octodure' AND location_name = 'Martigny'
);

-- Auberge du Mont-Gelé
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
  'Auberge du Mont-Gelé',
  'Isérables',
  'gastronomy',
  'Auberge de charme a Iserables, accessible par teleferique. Specialites valaisannes, vue plongeante sur la vallee du Rhone.',
  46.1583, 7.2333,
  180, 3,
  ARRAY['Reservation necessaire'],
  ARRAY['Printemps','Été','Automne','Hiver'],
  ARRAY['Couple','Famille','Amis'],
  true, true,
  NULL, NULL, 'loc_central',
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Auberge du Mont-Gelé' AND location_name = 'Isérables'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Auberge du Mont-Gelé' AND location_name = 'Isérables'
);

-- Auberge d'Évolène
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
  'Auberge d''Évolène',
  'Évolène',
  'gastronomy',
  'Auberge traditionnelle au coeur du Val d''Herens. Cuisine du terroir, fromages d''alpage, ambiance authentique.',
  46.1106, 7.5025,
  150, 3,
  ARRAY['Reservation necessaire'],
  ARRAY['Printemps','Été','Automne','Hiver'],
  ARRAY['Couple','Famille','Amis'],
  true, true,
  NULL, NULL, 'loc_central',
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL,
  'pending', NULL
WHERE NOT EXISTS (
  SELECT 1 FROM activity_submissions
  WHERE title = 'Auberge d''Évolène' AND location_name = 'Évolène'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Auberge d''Évolène' AND location_name = 'Évolène'
);

-- Restaurant Beau-Site Saas-Fee
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
  'Restaurant Beau-Site Saas-Fee',
  'Saas-Fee',
  'gastronomy',
  'Restaurant gastronomique du Beau-Site (4*). Cuisine raffinee, terrasse panoramique sur les 4000m, cave reputee.',
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
  WHERE title = 'Restaurant Beau-Site Saas-Fee' AND location_name = 'Saas-Fee'
) AND NOT EXISTS (
  SELECT 1 FROM activities
  WHERE title = 'Restaurant Beau-Site Saas-Fee' AND location_name = 'Saas-Fee'
);

-- ============================================================
-- Total : 40 etablissements (Valais)
-- Avec activity_url : 23/40
-- Avec location_zone : 40/40
-- Saisonniers (apres-ski / terrasses pures) : 4/40
-- ============================================================