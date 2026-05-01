-- v34 perf optim #2 : scoring deplace dans Postgres.
-- L'Edge Function recommend-activity n'a plus a charger 100 candidats, les
-- scorer en JS, puis trier. Tout est fait en une seule rpc().

-- Helper : reproduit la logique isProposableNow() de l'edge function en SQL.
CREATE OR REPLACE FUNCTION public.is_activity_proposable_now(
  p_recurrence_type text,
  p_date_start date,
  p_date_end date,
  p_seasonal_months integer[],
  p_weekly_days integer[],
  p_category text,
  p_now timestamptz DEFAULT now()
) RETURNS boolean
LANGUAGE plpgsql
IMMUTABLE
AS $$
DECLARE
  is_event           boolean;
  has_date_range     boolean;
  has_weekly         boolean;
  has_seasonal_mo    boolean;
  has_seasonal_dates boolean;
  has_one_off        boolean;
  now_dow            int;
  now_month          int;
  now_key            int;
  start_key          int;
  end_key            int;
  duration_days      int;
BEGIN
  is_event := EXISTS (
    SELECT 1
      FROM unnest(string_to_array(coalesce(p_category, ''), ',')) c
     WHERE lower(trim(c)) = 'event'
  );
  has_date_range  := p_date_start IS NOT NULL AND p_date_end IS NOT NULL;

  -- v29 : event sans dates -> pas recommandable.
  IF is_event AND NOT has_date_range THEN RETURN false; END IF;
  -- Pas de recurrence_type : visible.
  IF p_recurrence_type IS NULL THEN RETURN true; END IF;

  has_weekly         := p_weekly_days IS NOT NULL AND array_length(p_weekly_days, 1) > 0;
  has_seasonal_mo    := p_seasonal_months IS NOT NULL AND array_length(p_seasonal_months, 1) > 0;
  has_seasonal_dates := p_recurrence_type = 'seasonal' AND has_date_range;
  has_one_off        := p_recurrence_type = 'one_off' AND has_date_range;

  now_dow   := EXTRACT(DOW   FROM p_now)::int;
  now_month := EXTRACT(MONTH FROM p_now)::int;
  now_key   := EXTRACT(MONTH FROM p_now)::int * 100 + EXTRACT(DAY FROM p_now)::int;

  IF has_weekly AND NOT (now_dow = ANY (p_weekly_days)) THEN RETURN false; END IF;
  IF has_seasonal_mo AND NOT (now_month = ANY (p_seasonal_months)) THEN RETURN false; END IF;

  -- Fenetre saisonniere MM-JJ (annee ignoree, peut traverser le 1er janvier).
  IF has_seasonal_dates THEN
    start_key := EXTRACT(MONTH FROM p_date_start)::int * 100 + EXTRACT(DAY FROM p_date_start)::int;
    end_key   := EXTRACT(MONTH FROM p_date_end)::int   * 100 + EXTRACT(DAY FROM p_date_end)::int;
    IF start_key <= end_key THEN
      IF NOT (now_key >= start_key AND now_key <= end_key) THEN RETURN false; END IF;
    ELSE
      IF NOT (now_key >= start_key OR  now_key <= end_key) THEN RETURN false; END IF;
    END IF;
  END IF;

  -- Fenetre one_off (annee absolue, hierarchie selon duree).
  IF has_one_off THEN
    IF p_now::date > p_date_end THEN RETURN false; END IF;
    duration_days := (p_date_end - p_date_start) + 1;
    IF duration_days <= 1 THEN
      IF p_now::date < (p_date_end - 5) THEN RETURN false; END IF;
    ELSIF duration_days <= 7 THEN
      IF p_now::date < (p_date_end - 21) THEN RETURN false; END IF;
    ELSIF duration_days < 30 THEN
      IF p_now::date < (p_date_start - 21) THEN RETURN false; END IF;
    ELSE
      IF p_now::date < p_date_start THEN RETURN false; END IF;
    END IF;
  END IF;

  -- seasonal incomplet (ni mois ni dates) -> exclure.
  IF p_recurrence_type = 'seasonal' AND NOT has_seasonal_mo AND NOT has_seasonal_dates THEN
    RETURN false;
  END IF;

  RETURN true;
END;
$$;

-- Helper : haversine en km (evite la dependance postgis/earthdistance).
CREATE OR REPLACE FUNCTION public.haversine_km(
  lat1 double precision, lon1 double precision,
  lat2 double precision, lon2 double precision
) RETURNS double precision
LANGUAGE sql
IMMUTABLE
AS $$
  SELECT 6371 * 2 * asin(sqrt(
    sin(radians((lat2 - lat1) / 2)) ^ 2 +
    cos(radians(lat1)) * cos(radians(lat2)) *
    sin(radians((lon2 - lon1) / 2)) ^ 2
  ));
$$;

-- Fonction principale : retourne les candidats filtres + scores, tries DESC.
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
    -- v33 multi-cat bonus : matched/requested * 12, seulement si >= 2 demandees
    CASE
      WHEN cardinality(p_categories) < 2 THEN 0
      ELSE (
        SELECT COUNT(*)::double precision
          FROM unnest(p_categories) pc
         WHERE EXISTS (
           SELECT 1 FROM unnest(string_to_array(coalesce(f.category, ''), ',')) ac
            WHERE lower(trim(ac)) LIKE '%' || lower(pc) || '%'
         )
      ) / NULLIF(cardinality(p_categories), 0) * 12
    END

    -- duration scoring : exact = +4, adjacent = +2
    + CASE
        WHEN p_duration = '' OR f.duration_minutes IS NULL THEN 0
        WHEN p_duration = 'short'  AND f.duration_minutes < 180  THEN 4
        WHEN p_duration = 'medium' AND f.duration_minutes BETWEEN 180 AND 300 THEN 4
        WHEN p_duration = 'long'   AND f.duration_minutes > 300  THEN 4
        WHEN p_duration = 'short'  AND f.duration_minutes BETWEEN 180 AND 300 THEN 2
        WHEN p_duration = 'medium' AND (f.duration_minutes < 180 OR f.duration_minutes > 300) THEN 2
        WHEN p_duration = 'long'   AND f.duration_minutes BETWEEN 180 AND 300 THEN 2
        ELSE 0
      END

    -- social : +1 si tag matche
    + CASE
        WHEN p_social = '' THEN 0
        WHEN p_social = 'solo'    AND 'Solo'    = ANY (coalesce(f.social_tags, '{}')) THEN 1
        WHEN p_social = 'couple'  AND 'Couple'  = ANY (coalesce(f.social_tags, '{}')) THEN 1
        WHEN p_social = 'family'  AND 'Famille' = ANY (coalesce(f.social_tags, '{}')) THEN 1
        WHEN p_social = 'friends' AND 'Amis'    = ANY (coalesce(f.social_tags, '{}')) THEN 1
        ELSE 0
      END

    -- weather bonus
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

    -- recency penalty (array_position is 1-based)
    + (CASE
         WHEN cardinality(p_recent_ids) = 0 THEN 0
         WHEN array_position(p_recent_ids, f.id) BETWEEN 1 AND 5  THEN -5
         WHEN array_position(p_recent_ids, f.id) BETWEEN 6 AND 20 THEN -2
         ELSE 0
       END)::double precision

    -- quality bonus (top 20% = +3, top 50% = +1)
    + coalesce(qb.bonus, 0)::double precision

    -- taste bonus (cold start si total_signals < 3)
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
ORDER BY score DESC
LIMIT p_limit;
$$;
