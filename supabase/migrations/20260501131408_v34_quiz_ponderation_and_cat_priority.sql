-- v34 quiz ponderation : applique les poids 3/3/2/2/1 sur les axes du quiz
-- et introduit le scoring categoriel par priorite (1/2/3).
--
-- Pondération demandée :
--   Categorie  : 3 pts  | prio 1 (exact set) = +3, prio 2 (superset) = +2,
--                       | prio 3 (≥1 match)  = +1
--   Social     : 3 pts  | match du tag = +3, sinon 0
--   Environnement: 2 pts| match pur (outdoor/outdoor-only) = +2,
--                       | mixte (l'activite est indoor+outdoor) = +1
--   Budget     : 2 pts  | hard filter only — la "ponderation 2 pts"
--                       | est portee par la strictness du filtre (binary
--                       | include/exclude). Pas de bonus differenciant
--                       | dans la mesure ou tous les candidats passent
--                       | deja le filtre.
--   Duree      : 1 pt   | bucket exact = +1, adjacent = +0.5
--
-- Note : avant cette migration, les coefficients implicites etaient
-- 12 / 1 / 0 / 0 / 4 (cat / soc / env / bud / dur), ce qui faisait
-- dominer la categorie au detriment des autres axes du quiz.

CREATE OR REPLACE FUNCTION public.score_activities(
  p_categories     text[]            DEFAULT '{}',
  p_price_levels   integer[]         DEFAULT '{}',
  p_price_max      integer           DEFAULT 5,
  p_environment    text              DEFAULT '',
  p_region         text              DEFAULT '',
  p_duration       text              DEFAULT '',
  p_social         text              DEFAULT '',
  p_radius_km      double precision  DEFAULT NULL,
  p_user_lat       double precision  DEFAULT NULL,
  p_user_lng       double precision  DEFAULT NULL,
  p_user_id        uuid              DEFAULT NULL,
  p_recent_ids     bigint[]          DEFAULT '{}',
  p_weather_code   integer           DEFAULT NULL,
  p_weather_temp   double precision  DEFAULT NULL,
  p_now            timestamptz       DEFAULT now(),
  p_limit          integer           DEFAULT 100
) RETURNS TABLE (
  id                bigint,
  title             text,
  category          text,
  price_level       integer,
  duration_minutes  integer,
  description       text,
  image_url         text,
  features          text[],
  seasons           text[],
  social_tags       text[],
  location_name     text,
  is_outdoor        boolean,
  is_indoor         boolean,
  latitude          double precision,
  longitude         double precision,
  date_label        text,
  date_start        date,
  date_end          date,
  recurrence_type   text,
  seasonal_months   integer[],
  weekly_days       integer[],
  favorites_count   integer,
  score             double precision
)
LANGUAGE sql
STABLE
SET search_path = public
AS $$
WITH
filtered AS (
  SELECT a.*
    FROM public.activities a
   WHERE a.archived = false
     AND (
       cardinality(p_categories) = 0
       OR EXISTS (
         SELECT 1 FROM unnest(p_categories) AS pc
          WHERE a.category ILIKE '%' || pc || '%'
       )
     )
     AND (
       (cardinality(p_price_levels) > 0 AND a.price_level = ANY (p_price_levels))
       OR (cardinality(p_price_levels) = 0 AND a.price_level <= p_price_max)
     )
     AND (p_environment <> 'outdoor' OR coalesce(a.is_outdoor, false) = true)
     AND (p_environment <> 'indoor'  OR a.is_indoor = true)
     AND (p_region <> 'valais' OR a.location_zone IS NOT NULL)
     AND (p_region <> 'vaud'   OR a.location_zone IS NULL)
     AND public.is_activity_proposable_now(
           a.recurrence_type, a.date_start, a.date_end,
           a.seasonal_months, a.weekly_days, a.category, p_now)
     AND (
       p_radius_km IS NULL
       OR p_radius_km >= 999
       OR p_user_lat IS NULL
       OR p_user_lng IS NULL
       OR a.latitude IS NULL
       OR a.longitude IS NULL
       OR public.haversine_km(p_user_lat, p_user_lng, a.latitude, a.longitude) <= p_radius_km
     )
),
quality_raw AS (
  SELECT
    f.id,
    coalesce(f.favorites_count, 0)::double precision AS fav_count,
    coalesce(fr.avg_rating, 0)::double precision     AS avg_rating,
    coalesce(fr.rating_count, 0)::int                AS rating_count
  FROM filtered f
  LEFT JOIN (
    SELECT fs.activity_id,
           AVG(fa.answer_rating)::double precision AS avg_rating,
           COUNT(*)::int                           AS rating_count
      FROM public.feedback_submissions fs
      JOIN public.feedback_answers fa ON fa.submission_id = fs.id
     WHERE fa.answer_rating IS NOT NULL
     GROUP BY fs.activity_id
  ) fr ON fr.activity_id = f.id
),
quality_max AS (
  SELECT GREATEST(MAX(fav_count), 0) AS max_fav FROM quality_raw
),
quality_score AS (
  SELECT qr.id,
    0.7 * (CASE WHEN qr.rating_count > 0 THEN qr.avg_rating / 5.0 ELSE 0 END)
    + 0.3 * (CASE WHEN qm.max_fav > 0
                  THEN ln(1 + qr.fav_count) / ln(1 + qm.max_fav)
                  ELSE 0 END) AS q_score
    FROM quality_raw qr CROSS JOIN quality_max qm
),
quality_ranked AS (
  SELECT id, q_score,
         ROW_NUMBER() OVER (ORDER BY q_score DESC) AS rk,
         COUNT(*)     OVER ()                      AS total
    FROM quality_score
   WHERE q_score > 0
),
quality_bonus AS (
  SELECT id,
    CASE
      WHEN rk <= GREATEST(1, FLOOR(total * 0.2)) THEN 3
      WHEN rk <= GREATEST(1, FLOOR(total * 0.5)) THEN 1
      ELSE 0
    END AS bonus
  FROM quality_ranked
),
user_profile AS (
  SELECT
    coalesce(p.total_signals, 0)                AS total_signals,
    coalesce(p.top_categories, '{}'::jsonb)     AS top_categories,
    p.avg_price_level                           AS avg_price_level,
    p.indoor_outdoor_pref                       AS indoor_outdoor_pref,
    coalesce(p.popular_social_tags, '{}'::text[]) AS popular_social_tags,
    coalesce(p.disliked_categories, '{}'::text[]) AS disliked_categories
  FROM (SELECT 1 AS dummy) d
  LEFT JOIN public.user_taste_profiles p ON p.user_id = p_user_id
)
SELECT
  f.id, f.title, f.category, f.price_level, f.duration_minutes,
  f.description, f.image_url, f.features, f.seasons, f.social_tags,
  f.location_name, f.is_outdoor, f.is_indoor, f.latitude, f.longitude,
  f.date_label, f.date_start, f.date_end, f.recurrence_type,
  f.seasonal_months, f.weekly_days, f.favorites_count,
  (
    -- v34 ponderation #cat (3 pts) : prio 1 / 2 / 3.
    --   prio 1 : meme set exact que l'utilisateur (ni plus, ni moins)
    --   prio 2 : tous les requested matchent + l'activite a des extras
    --   prio 3 : au moins un match (sous-ensemble)
    (CASE
       WHEN cm.user_n = 0 THEN 0
       WHEN cm.matched_n = cm.user_n AND cm.act_n = cm.user_n THEN 3
       WHEN cm.matched_n = cm.user_n AND cm.act_n > cm.user_n THEN 2
       WHEN cm.matched_n > 0 THEN 1
       ELSE 0
     END)::double precision

    -- v34 ponderation #social (3 pts).
    + (CASE
         WHEN p_social = '' THEN 0
         WHEN p_social = 'solo'    AND 'Solo'    = ANY (coalesce(f.social_tags, '{}')) THEN 3
         WHEN p_social = 'couple'  AND 'Couple'  = ANY (coalesce(f.social_tags, '{}')) THEN 3
         WHEN p_social = 'family'  AND 'Famille' = ANY (coalesce(f.social_tags, '{}')) THEN 3
         WHEN p_social = 'friends' AND 'Amis'    = ANY (coalesce(f.social_tags, '{}')) THEN 3
         ELSE 0
       END)::double precision

    -- v34 ponderation #environnement (2 pts).
    --   Match pur : +2 (ex : user='outdoor' & activite outdoor-only)
    --   Match mixte : +1 (activite indoor+outdoor : "moitie" du critere)
    + (CASE
         WHEN p_environment = '' THEN 0
         WHEN p_environment = 'outdoor' AND coalesce(f.is_outdoor, false) AND NOT f.is_indoor THEN 2
         WHEN p_environment = 'outdoor' AND coalesce(f.is_outdoor, false) AND f.is_indoor       THEN 1
         WHEN p_environment = 'indoor'  AND f.is_indoor AND NOT coalesce(f.is_outdoor, false)   THEN 2
         WHEN p_environment = 'indoor'  AND f.is_indoor AND coalesce(f.is_outdoor, false)       THEN 1
         ELSE 0
       END)::double precision

    -- v34 ponderation #budget (2 pts) : hard filter only. La strictness du
    -- filtre encode la priorite. Pas de bonus differenciant (tous les
    -- candidats passent deja). Documente ici pour clarte.

    -- v34 ponderation #duree (1 pt) : exact = +1, adjacent = +0.5.
    + (CASE
         WHEN p_duration = '' OR f.duration_minutes IS NULL THEN 0
         WHEN p_duration = 'short'  AND f.duration_minutes < 180  THEN 1
         WHEN p_duration = 'medium' AND f.duration_minutes BETWEEN 180 AND 300 THEN 1
         WHEN p_duration = 'long'   AND f.duration_minutes > 300  THEN 1
         WHEN p_duration = 'short'  AND f.duration_minutes BETWEEN 180 AND 300 THEN 0.5
         WHEN p_duration = 'medium' AND (f.duration_minutes < 180 OR f.duration_minutes > 300) THEN 0.5
         WHEN p_duration = 'long'   AND f.duration_minutes BETWEEN 180 AND 300 THEN 0.5
         ELSE 0
       END)::double precision

    -- weather bonus (inchange : +/-3)
    + (CASE WHEN p_weather_code IS NOT NULL AND p_weather_code >= 51
              AND coalesce(f.is_outdoor, false) AND NOT f.is_indoor THEN -3 ELSE 0 END
       + CASE WHEN p_weather_code IS NOT NULL AND p_weather_code >= 51
              AND f.is_indoor THEN 2 ELSE 0 END
       + CASE WHEN p_weather_temp IS NOT NULL AND p_weather_temp > 28
              AND f.category ILIKE '%nature%' THEN 2 ELSE 0 END
       + CASE WHEN p_weather_temp IS NOT NULL AND p_weather_temp > 28
              AND f.category ILIKE '%relax%' THEN 1 ELSE 0 END
       + CASE WHEN p_weather_temp IS NOT NULL AND p_weather_temp < 5
              AND f.is_indoor THEN 2 ELSE 0 END
       + CASE WHEN p_weather_temp IS NOT NULL AND p_weather_temp < 5
              AND coalesce(f.is_outdoor, false) AND NOT f.is_indoor THEN -1 ELSE 0 END)::double precision

    -- recency penalty (inchange : -2 ou -5)
    + (CASE
         WHEN cardinality(p_recent_ids) = 0 THEN 0
         WHEN array_position(p_recent_ids, f.id) BETWEEN 1 AND 5  THEN -5
         WHEN array_position(p_recent_ids, f.id) BETWEEN 6 AND 20 THEN -2
         ELSE 0
       END)::double precision

    -- quality bonus (inchange : top 20% = +3, top 50% = +1)
    + coalesce(qb.bonus, 0)::double precision

    -- taste bonus (inchange : -3 a +8 selon profil)
    + (CASE
         WHEN up.total_signals < 3 THEN 0
         ELSE
           LEAST(4, coalesce((
             SELECT SUM(coalesce((up.top_categories ->> lower(trim(ac)))::double precision, 0)) * 4
               FROM unnest(string_to_array(coalesce(f.category, ''), ',')) ac
           ), 0))
           - CASE WHEN EXISTS (
               SELECT 1 FROM unnest(string_to_array(coalesce(f.category, ''), ',')) ac
                WHERE lower(trim(ac)) = ANY (up.disliked_categories)
             ) THEN 3 ELSE 0 END
           + CASE
               WHEN up.avg_price_level IS NOT NULL AND f.price_level IS NOT NULL
                    AND abs(f.price_level - up.avg_price_level) <= 1 THEN 2
               ELSE 0
             END
           + CASE
               WHEN up.indoor_outdoor_pref = 'mostly_indoor'  AND f.is_indoor                          THEN 1
               WHEN up.indoor_outdoor_pref = 'mostly_outdoor' AND coalesce(f.is_outdoor, false)        THEN 1
               WHEN up.indoor_outdoor_pref = 'mixed'          AND f.is_indoor AND coalesce(f.is_outdoor, false) THEN 1
               ELSE 0
             END
           + CASE WHEN EXISTS (
               SELECT 1 FROM unnest(coalesce(f.social_tags, '{}'::text[])) t
                WHERE t = ANY (up.popular_social_tags)
             ) THEN 1 ELSE 0 END
       END)::double precision
  )::double precision AS score
FROM filtered f
LEFT JOIN quality_bonus qb ON qb.id = f.id
CROSS JOIN user_profile up
-- v34 cat scoring : compte les categories user / activite / matched
LEFT JOIN LATERAL (
  WITH user_set AS (
    SELECT DISTINCT lower(trim(c)) AS c
      FROM unnest(p_categories) AS c
     WHERE trim(c) <> ''
  ),
  act_set AS (
    SELECT DISTINCT lower(trim(c)) AS c
      FROM unnest(string_to_array(coalesce(f.category, ''), ',')) AS c
     WHERE trim(c) <> ''
  )
  SELECT
    (SELECT count(*)::int FROM user_set) AS user_n,
    (SELECT count(*)::int FROM act_set)  AS act_n,
    (SELECT count(*)::int FROM user_set u WHERE u.c IN (SELECT c FROM act_set)) AS matched_n
) cm ON true
ORDER BY score DESC
LIMIT p_limit;
$$;

-- Re-revoke EXECUTE depuis PUBLIC (CREATE OR REPLACE conserve les ACLs
-- mais par securite on confirme).
REVOKE EXECUTE ON FUNCTION public.score_activities(
  text[], integer[], integer, text, text, text, text,
  double precision, double precision, double precision, uuid,
  bigint[], integer, double precision, timestamptz, integer
) FROM PUBLIC;
REVOKE EXECUTE ON FUNCTION public.score_activities(
  text[], integer[], integer, text, text, text, text,
  double precision, double precision, double precision, uuid,
  bigint[], integer, double precision, timestamptz, integer
) FROM anon, authenticated;
