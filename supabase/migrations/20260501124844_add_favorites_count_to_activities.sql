-- v34 perf optim #4 : favorites_count materialise sur activities
-- Evite la query SELECT count(*) FROM favorites GROUP BY activity_id a chaque
-- appel de recommend-activity. La colonne est maintenue par trigger sur la
-- table favorites (INSERT / DELETE).

ALTER TABLE public.activities
  ADD COLUMN IF NOT EXISTS favorites_count integer NOT NULL DEFAULT 0;

-- Index utile pour les futures queries "top activites par popularite".
CREATE INDEX IF NOT EXISTS activities_favorites_count_idx
  ON public.activities (favorites_count DESC);

-- Trigger function : maintient activities.favorites_count en sync avec la table favorites.
CREATE OR REPLACE FUNCTION public.update_activity_favorites_count()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    UPDATE public.activities
       SET favorites_count = favorites_count + 1
     WHERE id = NEW.activity_id;
  ELSIF TG_OP = 'DELETE' THEN
    UPDATE public.activities
       SET favorites_count = GREATEST(favorites_count - 1, 0)
     WHERE id = OLD.activity_id;
  ELSIF TG_OP = 'UPDATE' AND OLD.activity_id IS DISTINCT FROM NEW.activity_id THEN
    UPDATE public.activities
       SET favorites_count = GREATEST(favorites_count - 1, 0)
     WHERE id = OLD.activity_id;
    UPDATE public.activities
       SET favorites_count = favorites_count + 1
     WHERE id = NEW.activity_id;
  END IF;
  RETURN NULL;
END;
$$;

DROP TRIGGER IF EXISTS favorites_count_trigger ON public.favorites;
CREATE TRIGGER favorites_count_trigger
AFTER INSERT OR UPDATE OR DELETE ON public.favorites
FOR EACH ROW EXECUTE FUNCTION public.update_activity_favorites_count();

-- Backfill : recalcule les compteurs pour les favoris existants.
UPDATE public.activities a
   SET favorites_count = COALESCE(c.cnt, 0)
  FROM (
    SELECT activity_id, COUNT(*)::int AS cnt
      FROM public.favorites
     GROUP BY activity_id
  ) c
 WHERE a.id = c.activity_id;
