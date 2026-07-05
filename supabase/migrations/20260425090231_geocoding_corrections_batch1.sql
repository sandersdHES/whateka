-- Corrections de coordonnees via Nominatim pour 16 activites avec ecart > 300m.
-- #134 Virtual Reality Center exclu (Nominatim a trouve a Bale, faux match).

UPDATE activities SET latitude = 46.5903659, longitude = 6.6437161 WHERE id = 266; -- Sentier du Talent
UPDATE activities SET latitude = 46.2858137, longitude = 7.0427823 WHERE id = 237; -- Mines de Sel de Bex
UPDATE activities SET latitude = 46.5189571, longitude = 6.5986725 WHERE id = 290; -- Musée Romain Lausanne-Vidy
UPDATE activities SET latitude = 46.2331077, longitude = 7.338935 WHERE id = 152; -- Musée de la Nature Valais
UPDATE activities SET latitude = 46.4748916, longitude = 6.8344451 WHERE id = 243; -- Funiculaire Vevey-Mont Pelerin
UPDATE activities SET latitude = 46.2719055, longitude = 7.3283377 WHERE id = 5;   -- Bisse du Torrent-Neuf
UPDATE activities SET latitude = 46.5086895, longitude = 6.6340686 WHERE id = 249; -- Musee Olympique
UPDATE activities SET latitude = 46.4381377, longitude = 6.9071714 WHERE id = 261; -- Montreux Jazz Cafe
UPDATE activities SET latitude = 46.3895077, longitude = 6.8623498 WHERE id = 271; -- Aquaparc
UPDATE activities SET latitude = 46.5801289, longitude = 6.2078157 WHERE id = 298; -- Musee Atelier Audemars Piguet
UPDATE activities SET latitude = 46.3799759, longitude = 6.2403229 WHERE id = 239; -- Musee du Leman
UPDATE activities SET latitude = 46.4730805, longitude = 7.1303164 WHERE id = 304; -- Espace Ballon
UPDATE activities SET latitude = 46.2124023, longitude = 7.3280001 WHERE id = 174; -- Domaine des iles Sion
UPDATE activities SET latitude = 46.3812118, longitude = 6.2399422 WHERE id = 278; -- Musee Romain Nyon
UPDATE activities SET latitude = 46.5222197, longitude = 6.6349237 WHERE id = 264; -- Musee Historique Lausanne
UPDATE activities SET latitude = 46.2394877, longitude = 7.382579 WHERE id = 153;  -- Golf Club Sion

-- Correction manuelle Jardin Botanique de Lausanne (Nominatim a echoue avec
-- le titre "Visite du Jardin Botanique de Lausanne - Natureum"), trouve via
-- requete simplifiee "Jardin botanique Lausanne".
UPDATE activities SET latitude = 46.5124720, longitude = 6.6235030 WHERE id = 308;
