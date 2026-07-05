-- v34 perf optim #1 : profil de gout utilisateur materialise.
-- Replace computeUserTasteProfile() (3-4 queries dynamiques par appel
-- recommend-activity) par une lecture unique sur user_taste_profiles.
-- Le profil est recalcule par trigger a chaque change sur favorites.
-- (Les feedbacks etant en deprecation, on ne pose pas de trigger dessus —
-- les categories disliked sont rafraichies au prochain trigger favorites.)

CREATE TABLE IF NOT EXISTS public.user_taste_profiles (
  user_id              uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  total_signals        integer NOT NULL DEFAULT 0,
  top_categories       jsonb NOT NULL DEFAULT '{}'::jsonb,
  avg_price_level      double precision,
  indoor_outdoor_pref  text,
  popular_social_tags  text[] NOT NULL DEFAULT '{}',
  disliked_categories  text[] NOT NULL DEFAULT '{}',
  updated_at           timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT user_taste_profiles_indoor_outdoor_pref_check
    CHECK (indoor_outdoor_pref IS NULL OR indoor_outdoor_pref IN ('mostly_indoor','mostly_outdoor','mixed'))
);

ALTER TABLE public.user_taste_profiles ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS user_taste_profiles_self_select ON public.user_taste_profiles;
CREATE POLICY user_taste_profiles_self_select ON public.user_taste_profiles
  FOR SELECT TO authenticated
  USING (user_id = auth.uid());

CREATE OR REPLACE FUNCTION public.compute_user_taste_profile(p_user_id uuid)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $fn$
DECLARE
  v_total_signals      integer;
  v_top_categories     jsonb;
  v_avg_price_level    double precision;
  v_indoor_pref        text;
  v_popular_tags       text[];
  v_disliked           text[];
  v_indoor_n           integer;
  v_outdoor_n          integer;
BEGIN
  -- 1. Liste des activites positives = favoris UNION feedbacks dont la
  --    moyenne des ratings >= 4.
  CREATE TEMP TABLE tmp_pos ON COMMIT DROP AS
  WITH user_act_avg AS (
    SELECT fs.activity_id, AVG(fa.answer_rating)::double precision AS avg_rating
      FROM public.feedback_submissions fs
      JOIN public.feedback_answers fa ON fa.submission_id = fs.id
     WHERE fs.user_id = p_user_id
       AND fa.answer_rating IS NOT NULL
     GROUP BY fs.activity_id
  ),
  positives_union AS (
    SELECT a.id, a.category, a.price_level, a.is_indoor, a.is_outdoor, a.social_tags
      FROM public.favorites f
      JOIN public.activities a ON a.id = f.activity_id
     WHERE f.user_id = p_user_id
    UNION
    SELECT a.id, a.category, a.price_level, a.is_indoor, a.is_outdoor, a.social_tags
      FROM user_act_avg uaa
      JOIN public.activities a ON a.id = uaa.activity_id
     WHERE uaa.avg_rating >= 4
  )
  SELECT * FROM positives_union;

  SELECT count(*) INTO v_total_signals FROM tmp_pos;

  -- 2. Top categories : split CSV, count, normalise.
  WITH cat_split AS (
    SELECT lower(trim(c)) AS cat
      FROM tmp_pos, LATERAL unnest(string_to_array(coalesce(category,''), ',')) AS c
     WHERE trim(c) <> ''
  ),
  cat_count AS (SELECT cat, count(*)::int AS cnt FROM cat_split GROUP BY cat),
  cat_total AS (SELECT COALESCE(sum(cnt), 0)::double precision AS total FROM cat_count)
  SELECT COALESCE(
           jsonb_object_agg(cat, cnt::double precision / NULLIF(total, 0)),
           '{}'::jsonb
         )
    INTO v_top_categories
    FROM cat_count, cat_total;

  -- 3. Avg price level (ignore null).
  SELECT AVG(price_level)::double precision
    INTO v_avg_price_level
    FROM tmp_pos
   WHERE price_level IS NOT NULL;

  -- 4. Indoor/outdoor preference.
  SELECT count(*) FILTER (WHERE is_indoor),
         count(*) FILTER (WHERE is_outdoor)
    INTO v_indoor_n, v_outdoor_n
    FROM tmp_pos;

  IF (v_indoor_n + v_outdoor_n) > 0 THEN
    IF v_outdoor_n::double precision / (v_indoor_n + v_outdoor_n) >= 0.7 THEN
      v_indoor_pref := 'mostly_outdoor';
    ELSIF v_outdoor_n::double precision / (v_indoor_n + v_outdoor_n) <= 0.3 THEN
      v_indoor_pref := 'mostly_indoor';
    ELSE
      v_indoor_pref := 'mixed';
    END IF;
  ELSE
    v_indoor_pref := NULL;
  END IF;

  -- 5. Popular social tags : tags dans >= 30% des positifs.
  WITH tag_unnest AS (
    SELECT unnest(social_tags) AS tag FROM tmp_pos WHERE social_tags IS NOT NULL
  ),
  tag_count AS (SELECT tag, count(*)::int AS cnt FROM tag_unnest GROUP BY tag),
  threshold AS (SELECT GREATEST(1, floor(v_total_signals * 0.3))::int AS thr)
  SELECT COALESCE(array_agg(tag), '{}'::text[])
    INTO v_popular_tags
    FROM tag_count, threshold
   WHERE cnt >= thr;

  -- 6. Disliked categories : depuis feedback ratings <= 2 (avg per activity).
  WITH user_neg AS (
    SELECT fs.activity_id
      FROM public.feedback_submissions fs
      JOIN public.feedback_answers fa ON fa.submission_id = fs.id
     WHERE fs.user_id = p_user_id
       AND fa.answer_rating IS NOT NULL
     GROUP BY fs.activity_id
    HAVING AVG(fa.answer_rating) <= 2
  ),
  neg_split AS (
    SELECT lower(trim(c)) AS cat
      FROM user_neg un
      JOIN public.activities a ON a.id = un.activity_id,
      LATERAL unnest(string_to_array(coalesce(a.category,''), ',')) AS c
     WHERE trim(c) <> ''
  )
  SELECT COALESCE(array_agg(DISTINCT cat), '{}'::text[])
    INTO v_disliked
    FROM neg_split
   WHERE NOT (v_top_categories ? cat);

  -- 7. Upsert.
  INSERT INTO public.user_taste_profiles AS p (
    user_id, total_signals, top_categories, avg_price_level,
    indoor_outdoor_pref, popular_social_tags, disliked_categories, updated_at
  ) VALUES (
    p_user_id, v_total_signals, v_top_categories, v_avg_price_level,
    v_indoor_pref, v_popular_tags, v_disliked, now()
  )
  ON CONFLICT (user_id) DO UPDATE SET
    total_signals       = EXCLUDED.total_signals,
    top_categories      = EXCLUDED.top_categories,
    avg_price_level     = EXCLUDED.avg_price_level,
    indoor_outdoor_pref = EXCLUDED.indoor_outdoor_pref,
    popular_social_tags = EXCLUDED.popular_social_tags,
    disliked_categories = EXCLUDED.disliked_categories,
    updated_at          = now();

  DROP TABLE IF EXISTS tmp_pos;
END;
$fn$;

-- Trigger sur favorites : recompute apres chaque change.
CREATE OR REPLACE FUNCTION public.refresh_user_taste_profile_from_favorites()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  IF (TG_OP = 'INSERT' OR TG_OP = 'UPDATE') AND NEW.user_id IS NOT NULL THEN
    PERFORM public.compute_user_taste_profile(NEW.user_id);
  END IF;
  IF (TG_OP = 'DELETE' OR (TG_OP = 'UPDATE' AND OLD.user_id IS DISTINCT FROM NEW.user_id))
     AND OLD.user_id IS NOT NULL THEN
    PERFORM public.compute_user_taste_profile(OLD.user_id);
  END IF;
  RETURN NULL;
END;
$$;

DROP TRIGGER IF EXISTS user_taste_profile_from_favorites_trigger ON public.favorites;
CREATE TRIGGER user_taste_profile_from_favorites_trigger
AFTER INSERT OR UPDATE OR DELETE ON public.favorites
FOR EACH ROW EXECUTE FUNCTION public.refresh_user_taste_profile_from_favorites();

-- Backfill pour les users existants ayant au moins un favori.
DO $$
DECLARE u uuid;
BEGIN
  FOR u IN SELECT DISTINCT user_id FROM public.favorites WHERE user_id IS NOT NULL LOOP
    PERFORM public.compute_user_taste_profile(u);
  END LOOP;
END $$;
