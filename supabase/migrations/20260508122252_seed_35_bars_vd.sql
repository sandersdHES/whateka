-- Whateka -- Migration 0006 : seed 35 bars/terrasses VD
-- 35 bars et terrasses reputes du canton de Vaud (status='pending', categorie 'gastronomy')
-- Idempotent : WHERE NOT EXISTS sur (title, location_name) dans activity_submissions ET activities

-- Le Great Escape
INSERT INTO activity_submissions (title, location_name, category, description, latitude, longitude, duration_minutes, price_level, features, seasons, social_tags, is_indoor, is_outdoor, activity_url, image_url, location_zone, date_label, date_label_en, date_start, date_end, recurrence_type, seasonal_months, weekly_days, status, submitted_by)
SELECT 'Le Great Escape', 'Lausanne', 'gastronomy', 'Bar etudiant culte sur la Place de la Palud, terrasse animee face a la fontaine de la Justice. Biere a prix doux, ambiance bouillonnante.', 46.5219, 6.6336, 120, 2, ARRAY[]::text[], ARRAY['Printemps','Été','Automne','Hiver'], ARRAY['Amis','Couple'], true, true, 'https://www.the-great.ch', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'pending', NULL
WHERE NOT EXISTS (SELECT 1 FROM activity_submissions WHERE title = 'Le Great Escape' AND location_name = 'Lausanne')
  AND NOT EXISTS (SELECT 1 FROM activities WHERE title = 'Le Great Escape' AND location_name = 'Lausanne');

-- Le Lacustre
INSERT INTO activity_submissions (title, location_name, category, description, latitude, longitude, duration_minutes, price_level, features, seasons, social_tags, is_indoor, is_outdoor, activity_url, image_url, location_zone, date_label, date_label_en, date_start, date_end, recurrence_type, seasonal_months, weekly_days, status, submitted_by)
SELECT 'Le Lacustre', 'Lausanne-Ouchy', 'gastronomy', 'Brasserie/bar avec une terrasse pieds-dans-l''eau a Ouchy, vue panoramique sur le Leman et les Alpes savoyardes. Spot incontournable au coucher de soleil.', 46.5083, 6.6261, 120, 3, ARRAY['Reservation necessaire'], ARRAY['Printemps','Été','Automne'], ARRAY['Couple','Amis','Famille'], true, true, 'https://www.lelacustre.ch', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'pending', NULL
WHERE NOT EXISTS (SELECT 1 FROM activity_submissions WHERE title = 'Le Lacustre' AND location_name = 'Lausanne-Ouchy')
  AND NOT EXISTS (SELECT 1 FROM activities WHERE title = 'Le Lacustre' AND location_name = 'Lausanne-Ouchy');

-- Les Arches
INSERT INTO activity_submissions (title, location_name, category, description, latitude, longitude, duration_minutes, price_level, features, seasons, social_tags, is_indoor, is_outdoor, activity_url, image_url, location_zone, date_label, date_label_en, date_start, date_end, recurrence_type, seasonal_months, weekly_days, status, submitted_by)
SELECT 'Les Arches', 'Lausanne', 'gastronomy', 'Bar a cocktails niche sous les arches du Grand-Pont. Ambiance cosy, mixologie soignee, programmation musicale eclectique.', 46.5198, 6.6299, 120, 3, ARRAY[]::text[], ARRAY['Printemps','Été','Automne','Hiver'], ARRAY['Couple','Amis'], true, true, 'https://www.les-arches.ch', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'pending', NULL
WHERE NOT EXISTS (SELECT 1 FROM activity_submissions WHERE title = 'Les Arches' AND location_name = 'Lausanne')
  AND NOT EXISTS (SELECT 1 FROM activities WHERE title = 'Les Arches' AND location_name = 'Lausanne');

-- Le Bleu Lezard
INSERT INTO activity_submissions (title, location_name, category, description, latitude, longitude, duration_minutes, price_level, features, seasons, social_tags, is_indoor, is_outdoor, activity_url, image_url, location_zone, date_label, date_label_en, date_start, date_end, recurrence_type, seasonal_months, weekly_days, status, submitted_by)
SELECT 'Le Bleu Lezard', 'Lausanne', 'gastronomy', 'Cafe-bar-resto culte de la rue Enning depuis 1991. Terrasse sympa, programmation musicale au sous-sol, brunch reconnu le weekend.', 46.5219, 6.6347, 120, 3, ARRAY[]::text[], ARRAY['Printemps','Été','Automne','Hiver'], ARRAY['Amis','Couple','Solo'], true, true, 'https://www.bleu-lezard.ch', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'pending', NULL
WHERE NOT EXISTS (SELECT 1 FROM activity_submissions WHERE title = 'Le Bleu Lezard' AND location_name = 'Lausanne')
  AND NOT EXISTS (SELECT 1 FROM activities WHERE title = 'Le Bleu Lezard' AND location_name = 'Lausanne');

-- Bar Tabac
INSERT INTO activity_submissions (title, location_name, category, description, latitude, longitude, duration_minutes, price_level, features, seasons, social_tags, is_indoor, is_outdoor, activity_url, image_url, location_zone, date_label, date_label_en, date_start, date_end, recurrence_type, seasonal_months, weekly_days, status, submitted_by)
SELECT 'Bar Tabac', 'Lausanne', 'gastronomy', 'Cocktail bar de reference au Flon. Mixologie pointue, carte changeante, ambiance speakeasy. Reservation conseillee le weekend.', 46.5202, 6.6306, 120, 4, ARRAY['Reservation necessaire'], ARRAY['Printemps','Été','Automne','Hiver'], ARRAY['Couple','Amis'], true, false, 'https://www.bartabaclausanne.ch', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'pending', NULL
WHERE NOT EXISTS (SELECT 1 FROM activity_submissions WHERE title = 'Bar Tabac' AND location_name = 'Lausanne')
  AND NOT EXISTS (SELECT 1 FROM activities WHERE title = 'Bar Tabac' AND location_name = 'Lausanne');

-- La Datcha
INSERT INTO activity_submissions (title, location_name, category, description, latitude, longitude, duration_minutes, price_level, features, seasons, social_tags, is_indoor, is_outdoor, activity_url, image_url, location_zone, date_label, date_label_en, date_start, date_end, recurrence_type, seasonal_months, weekly_days, status, submitted_by)
SELECT 'La Datcha', 'Lausanne', 'gastronomy', 'Bar/club emblematique du Flon avec une grande terrasse animee. Ambiance festive le weekend, DJ residents.', 46.52, 6.6305, 180, 3, ARRAY[]::text[], ARRAY['Printemps','Été','Automne','Hiver'], ARRAY['Amis','Couple'], true, true, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'pending', NULL
WHERE NOT EXISTS (SELECT 1 FROM activity_submissions WHERE title = 'La Datcha' AND location_name = 'Lausanne')
  AND NOT EXISTS (SELECT 1 FROM activities WHERE title = 'La Datcha' AND location_name = 'Lausanne');

-- La Ferme Vaudoise
INSERT INTO activity_submissions (title, location_name, category, description, latitude, longitude, duration_minutes, price_level, features, seasons, social_tags, is_indoor, is_outdoor, activity_url, image_url, location_zone, date_label, date_label_en, date_start, date_end, recurrence_type, seasonal_months, weekly_days, status, submitted_by)
SELECT 'La Ferme Vaudoise', 'Lausanne', 'gastronomy', 'Bar a vins vaudois sur la Place de la Palud. Carte de plus de 100 references locales, planches du terroir, terrasse pavee historique.', 46.5219, 6.6336, 90, 3, ARRAY[]::text[], ARRAY['Printemps','Été','Automne','Hiver'], ARRAY['Couple','Amis'], true, true, 'https://www.lafermevaudoise.ch', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'pending', NULL
WHERE NOT EXISTS (SELECT 1 FROM activity_submissions WHERE title = 'La Ferme Vaudoise' AND location_name = 'Lausanne')
  AND NOT EXISTS (SELECT 1 FROM activities WHERE title = 'La Ferme Vaudoise' AND location_name = 'Lausanne');

-- Cafe Saint-Pierre
INSERT INTO activity_submissions (title, location_name, category, description, latitude, longitude, duration_minutes, price_level, features, seasons, social_tags, is_indoor, is_outdoor, activity_url, image_url, location_zone, date_label, date_label_en, date_start, date_end, recurrence_type, seasonal_months, weekly_days, status, submitted_by)
SELECT 'Cafe Saint-Pierre', 'Lausanne', 'gastronomy', 'Cafe-bar avec terrasse face a la cathedrale. Vue plongeante sur la ville, ambiance bohemienne, planches a partager.', 46.5225, 6.6356, 90, 2, ARRAY[]::text[], ARRAY['Printemps','Été','Automne'], ARRAY['Couple','Amis','Solo'], true, true, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'seasonal', ARRAY[4,5,6,7,8,9,10]::int[], NULL, 'pending', NULL
WHERE NOT EXISTS (SELECT 1 FROM activity_submissions WHERE title = 'Cafe Saint-Pierre' AND location_name = 'Lausanne')
  AND NOT EXISTS (SELECT 1 FROM activities WHERE title = 'Cafe Saint-Pierre' AND location_name = 'Lausanne');

-- White Horse Pub
INSERT INTO activity_submissions (title, location_name, category, description, latitude, longitude, duration_minutes, price_level, features, seasons, social_tags, is_indoor, is_outdoor, activity_url, image_url, location_zone, date_label, date_label_en, date_start, date_end, recurrence_type, seasonal_months, weekly_days, status, submitted_by)
SELECT 'White Horse Pub', 'Lausanne', 'gastronomy', 'Pub anglais historique de la Cite. Plus de 50 bieres, ambiance authentique, soirees quiz et matchs sportifs.', 46.5227, 6.6353, 120, 2, ARRAY[]::text[], ARRAY['Printemps','Été','Automne','Hiver'], ARRAY['Amis','Couple'], true, false, 'https://www.whitehorsepub.ch', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'pending', NULL
WHERE NOT EXISTS (SELECT 1 FROM activity_submissions WHERE title = 'White Horse Pub' AND location_name = 'Lausanne')
  AND NOT EXISTS (SELECT 1 FROM activities WHERE title = 'White Horse Pub' AND location_name = 'Lausanne');

-- La Cabane de Vidy
INSERT INTO activity_submissions (title, location_name, category, description, latitude, longitude, duration_minutes, price_level, features, seasons, social_tags, is_indoor, is_outdoor, activity_url, image_url, location_zone, date_label, date_label_en, date_start, date_end, recurrence_type, seasonal_months, weekly_days, status, submitted_by)
SELECT 'La Cabane de Vidy', 'Lausanne', 'gastronomy', 'Bar de plage estival a Vidy, ambiance pieds dans le sable, cocktails et planches a partager au coucher de soleil.', 46.5169, 6.5908, 180, 3, ARRAY[]::text[], ARRAY['Printemps','Été'], ARRAY['Amis','Couple','Famille'], false, true, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'seasonal', ARRAY[5,6,7,8,9]::int[], NULL, 'pending', NULL
WHERE NOT EXISTS (SELECT 1 FROM activity_submissions WHERE title = 'La Cabane de Vidy' AND location_name = 'Lausanne')
  AND NOT EXISTS (SELECT 1 FROM activities WHERE title = 'La Cabane de Vidy' AND location_name = 'Lausanne');

-- SkyLab Lausanne Palace
INSERT INTO activity_submissions (title, location_name, category, description, latitude, longitude, duration_minutes, price_level, features, seasons, social_tags, is_indoor, is_outdoor, activity_url, image_url, location_zone, date_label, date_label_en, date_start, date_end, recurrence_type, seasonal_months, weekly_days, status, submitted_by)
SELECT 'SkyLab Lausanne Palace', 'Lausanne', 'gastronomy', 'Rooftop bar du Lausanne Palace (5*). Vue degagee sur le Leman et les Alpes, cocktails signature, ambiance lounge.', 46.5193, 6.6293, 120, 5, ARRAY['Reservation necessaire'], ARRAY['Printemps','Été','Automne'], ARRAY['Couple','Amis'], true, true, 'https://www.lausanne-palace.com', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'pending', NULL
WHERE NOT EXISTS (SELECT 1 FROM activity_submissions WHERE title = 'SkyLab Lausanne Palace' AND location_name = 'Lausanne')
  AND NOT EXISTS (SELECT 1 FROM activities WHERE title = 'SkyLab Lausanne Palace' AND location_name = 'Lausanne');

-- Cafe de Grancy
INSERT INTO activity_submissions (title, location_name, category, description, latitude, longitude, duration_minutes, price_level, features, seasons, social_tags, is_indoor, is_outdoor, activity_url, image_url, location_zone, date_label, date_label_en, date_start, date_end, recurrence_type, seasonal_months, weekly_days, status, submitted_by)
SELECT 'Cafe de Grancy', 'Lausanne', 'gastronomy', 'Bistro-bar de quartier Sous-Gare. Ambiance conviviale, cuisine du marche, longue carte de vins suisses au verre.', 46.5145, 6.6314, 120, 3, ARRAY['Reservation necessaire'], ARRAY['Printemps','Été','Automne','Hiver'], ARRAY['Amis','Couple','Famille'], true, true, 'https://www.cafedegrancy.ch', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'pending', NULL
WHERE NOT EXISTS (SELECT 1 FROM activity_submissions WHERE title = 'Cafe de Grancy' AND location_name = 'Lausanne')
  AND NOT EXISTS (SELECT 1 FROM activities WHERE title = 'Cafe de Grancy' AND location_name = 'Lausanne');

-- Les Brasseurs
INSERT INTO activity_submissions (title, location_name, category, description, latitude, longitude, duration_minutes, price_level, features, seasons, social_tags, is_indoor, is_outdoor, activity_url, image_url, location_zone, date_label, date_label_en, date_start, date_end, recurrence_type, seasonal_months, weekly_days, status, submitted_by)
SELECT 'Les Brasseurs', 'Lausanne', 'gastronomy', 'Microbrasserie urbaine a la Place du Tunnel. Bieres brassees sur place, planches du brasseur, terrasse en ete.', 46.5266, 6.6358, 120, 3, ARRAY[]::text[], ARRAY['Printemps','Été','Automne','Hiver'], ARRAY['Amis','Couple','Famille'], true, true, 'https://www.les-brasseurs.ch', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'pending', NULL
WHERE NOT EXISTS (SELECT 1 FROM activity_submissions WHERE title = 'Les Brasseurs' AND location_name = 'Lausanne')
  AND NOT EXISTS (SELECT 1 FROM activities WHERE title = 'Les Brasseurs' AND location_name = 'Lausanne');

-- Bar a Quai
INSERT INTO activity_submissions (title, location_name, category, description, latitude, longitude, duration_minutes, price_level, features, seasons, social_tags, is_indoor, is_outdoor, activity_url, image_url, location_zone, date_label, date_label_en, date_start, date_end, recurrence_type, seasonal_months, weekly_days, status, submitted_by)
SELECT 'Bar a Quai', 'Lausanne-Vidy', 'gastronomy', 'Buvette du port de Vidy, terrasse face aux bateaux. Ambiance estivale relax, vue Leman + Alpes, planches et bieres locales.', 46.5141, 6.5921, 120, 2, ARRAY[]::text[], ARRAY['Printemps','Été','Automne'], ARRAY['Amis','Couple','Famille'], false, true, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'seasonal', ARRAY[4,5,6,7,8,9,10]::int[], NULL, 'pending', NULL
WHERE NOT EXISTS (SELECT 1 FROM activity_submissions WHERE title = 'Bar a Quai' AND location_name = 'Lausanne-Vidy')
  AND NOT EXISTS (SELECT 1 FROM activities WHERE title = 'Bar a Quai' AND location_name = 'Lausanne-Vidy');

-- Lobby Bar Beau-Rivage Palace
INSERT INTO activity_submissions (title, location_name, category, description, latitude, longitude, duration_minutes, price_level, features, seasons, social_tags, is_indoor, is_outdoor, activity_url, image_url, location_zone, date_label, date_label_en, date_start, date_end, recurrence_type, seasonal_months, weekly_days, status, submitted_by)
SELECT 'Lobby Bar Beau-Rivage Palace', 'Lausanne-Ouchy', 'gastronomy', 'Bar 5* du Beau-Rivage Palace. Salons feutres, terrasse classee donnant sur le parc et le lac, mixologie d''exception.', 46.5097, 6.6361, 120, 5, ARRAY['Reservation necessaire'], ARRAY['Printemps','Été','Automne','Hiver'], ARRAY['Couple','Amis'], true, true, 'https://www.brp.ch', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'pending', NULL
WHERE NOT EXISTS (SELECT 1 FROM activity_submissions WHERE title = 'Lobby Bar Beau-Rivage Palace' AND location_name = 'Lausanne-Ouchy')
  AND NOT EXISTS (SELECT 1 FROM activities WHERE title = 'Lobby Bar Beau-Rivage Palace' AND location_name = 'Lausanne-Ouchy');

-- Funky Claude's Bar
INSERT INTO activity_submissions (title, location_name, category, description, latitude, longitude, duration_minutes, price_level, features, seasons, social_tags, is_indoor, is_outdoor, activity_url, image_url, location_zone, date_label, date_label_en, date_start, date_end, recurrence_type, seasonal_months, weekly_days, status, submitted_by)
SELECT 'Funky Claude''s Bar', 'Montreux', 'gastronomy', 'Bar legendaire du Fairmont Le Montreux Palace, hommage a Claude Nobs (Montreux Jazz). Concerts live tous les soirs, atmosphere musicale unique.', 46.4337, 6.9111, 180, 4, ARRAY['Reservation necessaire'], ARRAY['Printemps','Été','Automne','Hiver'], ARRAY['Couple','Amis'], true, false, 'https://www.fairmont.com/montreux', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'pending', NULL
WHERE NOT EXISTS (SELECT 1 FROM activity_submissions WHERE title = 'Funky Claude''s Bar' AND location_name = 'Montreux')
  AND NOT EXISTS (SELECT 1 FROM activities WHERE title = 'Funky Claude''s Bar' AND location_name = 'Montreux');

-- Bar du Grand Hotel Suisse-Majestic
INSERT INTO activity_submissions (title, location_name, category, description, latitude, longitude, duration_minutes, price_level, features, seasons, social_tags, is_indoor, is_outdoor, activity_url, image_url, location_zone, date_label, date_label_en, date_start, date_end, recurrence_type, seasonal_months, weekly_days, status, submitted_by)
SELECT 'Bar du Grand Hotel Suisse-Majestic', 'Montreux', 'gastronomy', 'Terrasse 5* sur le quai de Montreux. Vue spectaculaire sur le lac, cocktails au coucher de soleil, ambiance Belle Epoque.', 46.4339, 6.9119, 120, 4, ARRAY['Reservation necessaire'], ARRAY['Printemps','Été','Automne'], ARRAY['Couple','Amis'], true, true, 'https://www.suisse-majestic.com', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'pending', NULL
WHERE NOT EXISTS (SELECT 1 FROM activity_submissions WHERE title = 'Bar du Grand Hotel Suisse-Majestic' AND location_name = 'Montreux')
  AND NOT EXISTS (SELECT 1 FROM activities WHERE title = 'Bar du Grand Hotel Suisse-Majestic' AND location_name = 'Montreux');

-- Harry's New York Bar
INSERT INTO activity_submissions (title, location_name, category, description, latitude, longitude, duration_minutes, price_level, features, seasons, social_tags, is_indoor, is_outdoor, activity_url, image_url, location_zone, date_label, date_label_en, date_start, date_end, recurrence_type, seasonal_months, weekly_days, status, submitted_by)
SELECT 'Harry''s New York Bar', 'Montreux', 'gastronomy', 'Bar de l''Eden Palace au Lac. Ambiance new-yorkaise, piano live, carte de cocktails classiques.', 46.4318, 6.9117, 120, 4, ARRAY['Reservation necessaire'], ARRAY['Printemps','Été','Automne','Hiver'], ARRAY['Couple','Amis'], true, false, 'https://www.edenpalace.ch', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'pending', NULL
WHERE NOT EXISTS (SELECT 1 FROM activity_submissions WHERE title = 'Harry''s New York Bar' AND location_name = 'Montreux')
  AND NOT EXISTS (SELECT 1 FROM activities WHERE title = 'Harry''s New York Bar' AND location_name = 'Montreux');

-- La Rouvenaz
INSERT INTO activity_submissions (title, location_name, category, description, latitude, longitude, duration_minutes, price_level, features, seasons, social_tags, is_indoor, is_outdoor, activity_url, image_url, location_zone, date_label, date_label_en, date_start, date_end, recurrence_type, seasonal_months, weekly_days, status, submitted_by)
SELECT 'La Rouvenaz', 'Montreux', 'gastronomy', 'Trattoria-bar emblematique des quais. Terrasse avec vue lac, carte italienne, ambiance familiale-festive.', 46.4334, 6.9125, 120, 3, ARRAY['Reservation necessaire'], ARRAY['Printemps','Été','Automne','Hiver'], ARRAY['Couple','Amis','Famille'], true, true, 'https://www.rouvenaz.ch', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'pending', NULL
WHERE NOT EXISTS (SELECT 1 FROM activity_submissions WHERE title = 'La Rouvenaz' AND location_name = 'Montreux')
  AND NOT EXISTS (SELECT 1 FROM activities WHERE title = 'La Rouvenaz' AND location_name = 'Montreux');

-- Lobby Bar Royal Plaza
INSERT INTO activity_submissions (title, location_name, category, description, latitude, longitude, duration_minutes, price_level, features, seasons, social_tags, is_indoor, is_outdoor, activity_url, image_url, location_zone, date_label, date_label_en, date_start, date_end, recurrence_type, seasonal_months, weekly_days, status, submitted_by)
SELECT 'Lobby Bar Royal Plaza', 'Montreux', 'gastronomy', 'Bar de l''hotel 5* Royal Plaza. Terrasse panoramique sur le Leman, mixologie soignee, ambiance feutree.', 46.4308, 6.9117, 120, 4, ARRAY['Reservation necessaire'], ARRAY['Printemps','Été','Automne','Hiver'], ARRAY['Couple','Amis'], true, true, 'https://www.royalplaza.ch', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'pending', NULL
WHERE NOT EXISTS (SELECT 1 FROM activity_submissions WHERE title = 'Lobby Bar Royal Plaza' AND location_name = 'Montreux')
  AND NOT EXISTS (SELECT 1 FROM activities WHERE title = 'Lobby Bar Royal Plaza' AND location_name = 'Montreux');

-- Le Mazot
INSERT INTO activity_submissions (title, location_name, category, description, latitude, longitude, duration_minutes, price_level, features, seasons, social_tags, is_indoor, is_outdoor, activity_url, image_url, location_zone, date_label, date_label_en, date_start, date_end, recurrence_type, seasonal_months, weekly_days, status, submitted_by)
SELECT 'Le Mazot', 'Vevey', 'gastronomy', 'Bar a vins authentique au cœur de Vevey. Vins de Lavaux, fondue maison, ambiance chalet en plein centre-ville.', 46.4625, 6.8455, 120, 3, ARRAY['Reservation necessaire'], ARRAY['Printemps','Été','Automne','Hiver'], ARRAY['Couple','Amis','Famille'], true, false, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'pending', NULL
WHERE NOT EXISTS (SELECT 1 FROM activity_submissions WHERE title = 'Le Mazot' AND location_name = 'Vevey')
  AND NOT EXISTS (SELECT 1 FROM activities WHERE title = 'Le Mazot' AND location_name = 'Vevey');

-- Bar des Trois Couronnes
INSERT INTO activity_submissions (title, location_name, category, description, latitude, longitude, duration_minutes, price_level, features, seasons, social_tags, is_indoor, is_outdoor, activity_url, image_url, location_zone, date_label, date_label_en, date_start, date_end, recurrence_type, seasonal_months, weekly_days, status, submitted_by)
SELECT 'Bar des Trois Couronnes', 'Vevey', 'gastronomy', 'Terrasse 5* de l''hotel des Trois Couronnes (1842). Vue Riviera, parc anglais, cocktails et afternoon tea.', 46.4617, 6.8478, 120, 5, ARRAY['Reservation necessaire'], ARRAY['Printemps','Été','Automne','Hiver'], ARRAY['Couple','Amis'], true, true, 'https://www.hoteltroiscouronnes.ch', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'pending', NULL
WHERE NOT EXISTS (SELECT 1 FROM activity_submissions WHERE title = 'Bar des Trois Couronnes' AND location_name = 'Vevey')
  AND NOT EXISTS (SELECT 1 FROM activities WHERE title = 'Bar des Trois Couronnes' AND location_name = 'Vevey');

-- Le Bout du Monde
INSERT INTO activity_submissions (title, location_name, category, description, latitude, longitude, duration_minutes, price_level, features, seasons, social_tags, is_indoor, is_outdoor, activity_url, image_url, location_zone, date_label, date_label_en, date_start, date_end, recurrence_type, seasonal_months, weekly_days, status, submitted_by)
SELECT 'Le Bout du Monde', 'Vevey', 'gastronomy', 'Bar/restaurant au bout du quai Maria-Belgia. Terrasse les pieds dans le lac, ambiance balneaire, planches simples.', 46.4581, 6.8489, 120, 3, ARRAY[]::text[], ARRAY['Printemps','Été','Automne'], ARRAY['Couple','Amis','Famille'], true, true, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'seasonal', ARRAY[4,5,6,7,8,9,10]::int[], NULL, 'pending', NULL
WHERE NOT EXISTS (SELECT 1 FROM activity_submissions WHERE title = 'Le Bout du Monde' AND location_name = 'Vevey')
  AND NOT EXISTS (SELECT 1 FROM activities WHERE title = 'Le Bout du Monde' AND location_name = 'Vevey');

-- Le Galetas
INSERT INTO activity_submissions (title, location_name, category, description, latitude, longitude, duration_minutes, price_level, features, seasons, social_tags, is_indoor, is_outdoor, activity_url, image_url, location_zone, date_label, date_label_en, date_start, date_end, recurrence_type, seasonal_months, weekly_days, status, submitted_by)
SELECT 'Le Galetas', 'Vevey', 'gastronomy', 'Bar a vins atypique dans la vieille ville de Vevey. Selection pointue, cuisine sincere, ambiance bohemiennne.', 46.4631, 6.8456, 120, 3, ARRAY['Reservation necessaire'], ARRAY['Printemps','Été','Automne','Hiver'], ARRAY['Couple','Amis'], true, false, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'pending', NULL
WHERE NOT EXISTS (SELECT 1 FROM activity_submissions WHERE title = 'Le Galetas' AND location_name = 'Vevey')
  AND NOT EXISTS (SELECT 1 FROM activities WHERE title = 'Le Galetas' AND location_name = 'Vevey');

-- Caveau de Cully
INSERT INTO activity_submissions (title, location_name, category, description, latitude, longitude, duration_minutes, price_level, features, seasons, social_tags, is_indoor, is_outdoor, activity_url, image_url, location_zone, date_label, date_label_en, date_start, date_end, recurrence_type, seasonal_months, weekly_days, status, submitted_by)
SELECT 'Caveau de Cully', 'Cully', 'gastronomy', 'Bar a vins coooperatif de Cully. Plus de 50 references de vignerons de Lavaux, planches du terroir, ambiance authentique.', 46.49, 6.7333, 120, 3, ARRAY['Reservation necessaire','Horaires restreints'], ARRAY['Printemps','Été','Automne','Hiver'], ARRAY['Couple','Amis'], true, true, 'https://www.caveau-cully.ch', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'pending', NULL
WHERE NOT EXISTS (SELECT 1 FROM activity_submissions WHERE title = 'Caveau de Cully' AND location_name = 'Cully')
  AND NOT EXISTS (SELECT 1 FROM activities WHERE title = 'Caveau de Cully' AND location_name = 'Cully');

-- Auberge de l'Onde
INSERT INTO activity_submissions (title, location_name, category, description, latitude, longitude, duration_minutes, price_level, features, seasons, social_tags, is_indoor, is_outdoor, activity_url, image_url, location_zone, date_label, date_label_en, date_start, date_end, recurrence_type, seasonal_months, weekly_days, status, submitted_by)
SELECT 'Auberge de l''Onde', 'Saint-Saphorin', 'gastronomy', 'Auberge centenaire au cœur des vignobles UNESCO. Bar a vins reconnu, terrasse spectaculaire au-dessus du Leman.', 46.4717, 6.7964, 120, 4, ARRAY['Reservation necessaire'], ARRAY['Printemps','Été','Automne','Hiver'], ARRAY['Couple','Amis'], true, true, 'https://www.aubergedelonde.ch', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'pending', NULL
WHERE NOT EXISTS (SELECT 1 FROM activity_submissions WHERE title = 'Auberge de l''Onde' AND location_name = 'Saint-Saphorin')
  AND NOT EXISTS (SELECT 1 FROM activities WHERE title = 'Auberge de l''Onde' AND location_name = 'Saint-Saphorin');

-- Le Major Davel
INSERT INTO activity_submissions (title, location_name, category, description, latitude, longitude, duration_minutes, price_level, features, seasons, social_tags, is_indoor, is_outdoor, activity_url, image_url, location_zone, date_label, date_label_en, date_start, date_end, recurrence_type, seasonal_months, weekly_days, status, submitted_by)
SELECT 'Le Major Davel', 'Cully', 'gastronomy', 'Brasserie-bar sur la Place d''Armes de Cully. Terrasse face au port et au lac, ambiance chaleureuse, cuisine vaudoise.', 46.4895, 6.7327, 120, 3, ARRAY[]::text[], ARRAY['Printemps','Été','Automne','Hiver'], ARRAY['Couple','Amis','Famille'], true, true, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'pending', NULL
WHERE NOT EXISTS (SELECT 1 FROM activity_submissions WHERE title = 'Le Major Davel' AND location_name = 'Cully')
  AND NOT EXISTS (SELECT 1 FROM activities WHERE title = 'Le Major Davel' AND location_name = 'Cully');

-- Cafe de la Place Lutry
INSERT INTO activity_submissions (title, location_name, category, description, latitude, longitude, duration_minutes, price_level, features, seasons, social_tags, is_indoor, is_outdoor, activity_url, image_url, location_zone, date_label, date_label_en, date_start, date_end, recurrence_type, seasonal_months, weekly_days, status, submitted_by)
SELECT 'Cafe de la Place Lutry', 'Lutry', 'gastronomy', 'Cafe-bar du centre historique de Lutry. Terrasse pavee a deux pas du port, bonne carte des vins de la region.', 46.5028, 6.6856, 90, 2, ARRAY[]::text[], ARRAY['Printemps','Été','Automne','Hiver'], ARRAY['Couple','Amis','Famille'], true, true, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'pending', NULL
WHERE NOT EXISTS (SELECT 1 FROM activity_submissions WHERE title = 'Cafe de la Place Lutry' AND location_name = 'Lutry')
  AND NOT EXISTS (SELECT 1 FROM activities WHERE title = 'Cafe de la Place Lutry' AND location_name = 'Lutry');

-- Le Moleson
INSERT INTO activity_submissions (title, location_name, category, description, latitude, longitude, duration_minutes, price_level, features, seasons, social_tags, is_indoor, is_outdoor, activity_url, image_url, location_zone, date_label, date_label_en, date_start, date_end, recurrence_type, seasonal_months, weekly_days, status, submitted_by)
SELECT 'Le Moleson', 'Morges', 'gastronomy', 'Bar/cafe historique sur le quai de Morges. Terrasse face au port et au Leman, ambiance bistrot familial.', 46.5078, 6.5022, 90, 2, ARRAY[]::text[], ARRAY['Printemps','Été','Automne','Hiver'], ARRAY['Couple','Amis','Famille'], true, true, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'pending', NULL
WHERE NOT EXISTS (SELECT 1 FROM activity_submissions WHERE title = 'Le Moleson' AND location_name = 'Morges')
  AND NOT EXISTS (SELECT 1 FROM activities WHERE title = 'Le Moleson' AND location_name = 'Morges');

-- Bar de la Rive
INSERT INTO activity_submissions (title, location_name, category, description, latitude, longitude, duration_minutes, price_level, features, seasons, social_tags, is_indoor, is_outdoor, activity_url, image_url, location_zone, date_label, date_label_en, date_start, date_end, recurrence_type, seasonal_months, weekly_days, status, submitted_by)
SELECT 'Bar de la Rive', 'Morges', 'gastronomy', 'Buvette du Quai Charles-Veillon. Terrasse pieds dans l''herbe face au Mont-Blanc, ambiance estivale relax.', 46.5083, 6.5028, 90, 2, ARRAY[]::text[], ARRAY['Printemps','Été','Automne'], ARRAY['Amis','Famille','Couple'], false, true, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'seasonal', ARRAY[4,5,6,7,8,9,10]::int[], NULL, 'pending', NULL
WHERE NOT EXISTS (SELECT 1 FROM activity_submissions WHERE title = 'Bar de la Rive' AND location_name = 'Morges')
  AND NOT EXISTS (SELECT 1 FROM activities WHERE title = 'Bar de la Rive' AND location_name = 'Morges');

-- Cafe du Marche Nyon
INSERT INTO activity_submissions (title, location_name, category, description, latitude, longitude, duration_minutes, price_level, features, seasons, social_tags, is_indoor, is_outdoor, activity_url, image_url, location_zone, date_label, date_label_en, date_start, date_end, recurrence_type, seasonal_months, weekly_days, status, submitted_by)
SELECT 'Cafe du Marche Nyon', 'Nyon', 'gastronomy', 'Brasserie-bar sur la Place du Marche. Terrasse pavee dans la vieille ville, vins de La Cote, fondue reputee.', 46.3833, 6.2389, 120, 3, ARRAY['Reservation necessaire'], ARRAY['Printemps','Été','Automne','Hiver'], ARRAY['Couple','Amis','Famille'], true, true, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'pending', NULL
WHERE NOT EXISTS (SELECT 1 FROM activity_submissions WHERE title = 'Cafe du Marche Nyon' AND location_name = 'Nyon')
  AND NOT EXISTS (SELECT 1 FROM activities WHERE title = 'Cafe du Marche Nyon' AND location_name = 'Nyon');

-- La Barcarolle
INSERT INTO activity_submissions (title, location_name, category, description, latitude, longitude, duration_minutes, price_level, features, seasons, social_tags, is_indoor, is_outdoor, activity_url, image_url, location_zone, date_label, date_label_en, date_start, date_end, recurrence_type, seasonal_months, weekly_days, status, submitted_by)
SELECT 'La Barcarolle', 'Prangins', 'gastronomy', 'Bar de l''hotel La Barcarolle (5*). Terrasse de l''hotel face au Leman et au Mont-Blanc, jardin classe, cocktails et brunches.', 46.3961, 6.2422, 120, 5, ARRAY['Reservation necessaire'], ARRAY['Printemps','Été','Automne','Hiver'], ARRAY['Couple','Amis'], true, true, 'https://www.barcarolle.ch', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'pending', NULL
WHERE NOT EXISTS (SELECT 1 FROM activity_submissions WHERE title = 'La Barcarolle' AND location_name = 'Prangins')
  AND NOT EXISTS (SELECT 1 FROM activities WHERE title = 'La Barcarolle' AND location_name = 'Prangins');

-- Bar du Villars Palace
INSERT INTO activity_submissions (title, location_name, category, description, latitude, longitude, duration_minutes, price_level, features, seasons, social_tags, is_indoor, is_outdoor, activity_url, image_url, location_zone, date_label, date_label_en, date_start, date_end, recurrence_type, seasonal_months, weekly_days, status, submitted_by)
SELECT 'Bar du Villars Palace', 'Villars-sur-Ollon', 'gastronomy', 'Bar de l''hotel Villars Palace. Apres-ski reconnu, terrasse face Dents du Midi, mixologie alpine.', 46.2986, 7.0467, 120, 5, ARRAY['Reservation necessaire'], ARRAY['Printemps','Été','Automne','Hiver'], ARRAY['Couple','Amis'], true, true, 'https://www.villarspalace.com', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'pending', NULL
WHERE NOT EXISTS (SELECT 1 FROM activity_submissions WHERE title = 'Bar du Villars Palace' AND location_name = 'Villars-sur-Ollon')
  AND NOT EXISTS (SELECT 1 FROM activities WHERE title = 'Bar du Villars Palace' AND location_name = 'Villars-sur-Ollon');

-- Botta Bar (Glacier 3000)
INSERT INTO activity_submissions (title, location_name, category, description, latitude, longitude, duration_minutes, price_level, features, seasons, social_tags, is_indoor, is_outdoor, activity_url, image_url, location_zone, date_label, date_label_en, date_start, date_end, recurrence_type, seasonal_months, weekly_days, status, submitted_by)
SELECT 'Botta Bar (Glacier 3000)', 'Les Diablerets', 'gastronomy', 'Bar du sommet de Glacier 3000 (2''971m), batiment signe Mario Botta. Terrasse face Mont-Blanc + Cervin, l''un des plus hauts bars de Suisse romande.', 46.3556, 7.2125, 90, 4, ARRAY['Parking'], ARRAY['Printemps','Été','Automne','Hiver'], ARRAY['Couple','Amis','Famille'], true, true, 'https://www.glacier3000.ch', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'pending', NULL
WHERE NOT EXISTS (SELECT 1 FROM activity_submissions WHERE title = 'Botta Bar (Glacier 3000)' AND location_name = 'Les Diablerets')
  AND NOT EXISTS (SELECT 1 FROM activities WHERE title = 'Botta Bar (Glacier 3000)' AND location_name = 'Les Diablerets');

-- Le Refuge Leysin
INSERT INTO activity_submissions (title, location_name, category, description, latitude, longitude, duration_minutes, price_level, features, seasons, social_tags, is_indoor, is_outdoor, activity_url, image_url, location_zone, date_label, date_label_en, date_start, date_end, recurrence_type, seasonal_months, weekly_days, status, submitted_by)
SELECT 'Le Refuge Leysin', 'Leysin', 'gastronomy', 'Bar de montagne avec terrasse panoramique sur les Dents du Midi. Carte alpine, fondue, vin chaud en hiver.', 46.3478, 7.0089, 90, 3, ARRAY[]::text[], ARRAY['Printemps','Été','Automne','Hiver'], ARRAY['Couple','Amis','Famille'], true, true, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'pending', NULL
WHERE NOT EXISTS (SELECT 1 FROM activity_submissions WHERE title = 'Le Refuge Leysin' AND location_name = 'Leysin')
  AND NOT EXISTS (SELECT 1 FROM activities WHERE title = 'Le Refuge Leysin' AND location_name = 'Leysin');
