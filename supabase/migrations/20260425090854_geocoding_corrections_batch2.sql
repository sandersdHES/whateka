-- Pass 2 : 8 corrections valides via Nominatim avec titres nettoyes.
-- Skip #244 Musee Vigne (faux match Liddes au lieu d'Aigle).
-- Skip #270 Abbaye Saint-Maurice (faux match Choex/Monthey).
-- Skip #306 Cave Emery (faux match Grimisuat 31km off).

UPDATE activities SET latitude = 46.2430315, longitude = 7.3725493 WHERE id = 169; -- Guerite Brulefer (Sion)
UPDATE activities SET latitude = 46.6982473, longitude = 6.345664  WHERE id = 242; -- Grottes de Vallorbe
UPDATE activities SET latitude = 46.6072547, longitude = 7.109204  WHERE id = 250; -- Maison Cailler (Broc)
UPDATE activities SET latitude = 46.5235869, longitude = 6.6338031 WHERE id = 260; -- Palais de Rumine
UPDATE activities SET latitude = 46.4516324, longitude = 8.0775081 WHERE id = 275; -- Glacier d'Aletsch
UPDATE activities SET latitude = 46.2887866, longitude = 7.5427851 WHERE id = 279; -- Lac de Geronde
UPDATE activities SET latitude = 46.5179141, longitude = 6.6253361 WHERE id = 285; -- MCBA
UPDATE activities SET latitude = 46.5113441, longitude = 6.6139684 WHERE id = 291; -- Piscine de Bellerive
