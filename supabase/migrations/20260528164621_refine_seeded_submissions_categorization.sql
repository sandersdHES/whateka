-- Whateka — Refinement of the 213 seeded submissions
-- Adds multi-category support (a mountain hike becomes "nature,sport,adventure"
-- instead of just "sport"), refines seasons and enriches social_tags.

WITH base AS (
  SELECT
    id,
    LOWER(unaccent(COALESCE(title, '') || ' ' || COALESCE(description, ''))) AS t,
    LOWER(unaccent(COALESCE(title, ''))) AS tt
  FROM activity_submissions
  WHERE status = 'pending'
    AND created_at > now() - interval '4 hours'
)
UPDATE activity_submissions a
SET
  category = NULLIF(
    array_to_string(
      array_remove(ARRAY[
        -- nature
        CASE WHEN b.t ~ '(lac |lacs |etang|glacier|cascade|gorges|pinede|foret |jardin |pyramides|vignoble|vignes|sommet|col |source|panoram|flore|faune|nature|plateau|plage|bisse|paysage|sentier|randonn|botanique|chute |riviere|reserve|parc naturel|biodivers|montagne|colline|alpine|alpes|alpe |barrage|vallee|mont |val |village |\\malpe\\m|sauvage|fleur|arbre|bouquetin|chamois|marmotte|panorama|altitude|sentier)' THEN 'nature' END,
        -- culture
        CASE WHEN b.t ~ '(musee|chateau|abbaye|fondation|cathedrale|vestige|amphitheatre|vieille ville|romain|medieval|patrimoine|bourg|exposition|histor|art |basilique|ruines|gallo|monument|palais|chapelle|musique|orfevre|culturel|tradition|forteresse|tour bayart|stockalper|gianadda|matterhorn museum|world nature forum)' THEN 'culture' END,
        -- sport
        CASE WHEN b.t ~ '(randonn|vtt|velo|ski |skie|escalade|parapente|tubing|bikepark|raquette|via ferrata|alpinisme|trekking|trail |sport|sportif|grimper|escalad|cabane|refuge|sommet|altitude|piste|funiculaire|telecabine|telepherique|teleferique|teleski|sentier|ascension|montee|skinev|wanderung|bike)' THEN 'sport' END,
        -- adventure
        CASE WHEN b.t ~ '(parapente|via ferrata|slackline|escalade|bikepark|tubing|sensations|vertige|accrobranche|canyoning|rafting|passerelle suspendue|aventure|adrenaline|falaise|labyrinthe aventure|biplace|saut|sensations|vertigineu|extreme|adventur)' THEN 'adventure' END,
        -- gastronomy
        CASE WHEN b.t ~ '(vignoble|vigne|degustation|cave |caves|vin |vins |fromage|chocolat|brasserie|gourmand|ferme |gastronom|cellier|taverne|culinaire|verre |cep |raclette|fondue|terroir|alpage|specialite|chasselas|fendant|heida|paien)' THEN 'gastronomy' END,
        -- fun
        CASE WHEN b.t ~ '(aquaparc|labyrinthe|parc d.attraction|mini-train|train a vapeur|swiss vapeur|bains|thermes|thermal|grotte|metro alpin|paradise|vapeur|insolite|ludique|baignade|toboggan|jeux|enfant|ice pavilion|tubing|familial|amusement|attraction)' THEN 'fun' END
      ], NULL),
      ','
    ),
    ''
  ),

  -- =========================================================================
  -- SEASONS : recomputed by activity type
  -- =========================================================================
  seasons = (
    CASE
      -- Ski / glacier station: opens summer hike + winter ski
      WHEN b.t ~ '(ski|piste|verbier mont-fort|gornergrat|glacier paradise|crans-montana|zermatt|saas-fee|aletsch arena|riederalp|eggishorn|bettmeralp|mittelallalin|felskinn|hannigalp|portes du soleil|champery|anzere|aminona)'
        THEN ARRAY['ete','automne','hiver']::text[]
      -- Pure summer activities (baignade, lacs alpins, gorges hautes)
      WHEN b.t ~ '(baignade|plage |aquaparc|lac bleu|riffelsee|stellisee|moiry|tseuzier|champex|tanay|vert de morgins|lac retaud|cabane|refuge|3000 m|gornergrat|matterhorn|mont-fort|sommet|altitude|glacier)'
        AND b.t !~ '(thermal|thermes|bains|musee|chateau|abbaye)'
        THEN ARRAY['ete','automne']::text[]
      -- Spring-Summer-Autumn (vignobles, gorges, cascades, bisses, sentiers viticoles)
      WHEN b.t ~ '(vignoble|vigne|bisse|gorges|cascade|chute |sentier viticole|pyramides|barrage|jardin alpin|pinede|grotte aux fees|labyrinthe|swiss vapeur|amphitheatre|bourg|mini-train)'
        THEN ARRAY['printemps','ete','automne']::text[]
      -- All-season (musees, chateaux indoor, thermes, glacier express)
      WHEN b.t ~ '(musee|chateau|abbaye|cathedrale|fondation|stockalper|gianadda|thermes|thermal|bains de|glacier express|world nature forum|matterhorn museum)'
        THEN ARRAY['printemps','ete','automne','hiver']::text[]
      ELSE COALESCE(a.seasons, ARRAY['printemps','ete','automne']::text[])
    END
  ),

  -- =========================================================================
  -- SOCIAL TAGS : audience / mood
  -- =========================================================================
  social_tags = array_remove(ARRAY[
    CASE WHEN b.t ~ '(famille|enfant|familial|labyrinthe|aquaparc|mini-train|swiss vapeur|bains|thermes|bourg|musee|chateau famil|jardin|baignade|parc d.attraction)' THEN 'famille' END,
    CASE WHEN b.t ~ '(vignoble|vigne|degustation|coucher|romantique|vieille ville|cave|bourg medieval)' THEN 'romantique' END,
    CASE WHEN b.t ~ '(panoram|vue |sommet|col |altitude|gornergrat|eggishorn|matterhorn|mont-fort|paradise|bettmeralp|crans|grimentz|riederalp|aletsch)' THEN 'panorama' END,
    CASE WHEN b.t ~ '(sensations|adrenaline|parapente|via ferrata|slackline|bikepark|tubing|biplace|vertige|falaise)' THEN 'adrenaline' END,
    CASE WHEN b.t ~ '(randonn|vtt|velo|ski|escalade|alpinisme|cabane|refuge|trail|trekking|sentier|raquette|sport)' THEN 'sportif' END,
    CASE WHEN b.t ~ '(jardin|balade|calme|paisible|contemplat|reserve|pinede|coucher|lac de champex|lac retaud|tanay|vert de morgins|fafleralp)' THEN 'calme' END,
    CASE WHEN b.t ~ '(insolite|grotte|lac souterrain|labyrinthe|metro alpin|paradise|swiss vapeur|fafleralp|pyramides|ice pavilion|funiculaire le plus pentu|train a vapeur)' THEN 'insolite' END,
    CASE WHEN b.t ~ '(culture|art|musee|chateau|abbaye|exposition|histoire|histor|patrimoine|romain|medieval|gianadda|fondation|stockalper)' THEN 'culture' END,
    CASE WHEN b.t ~ '(degustation|gourmand|vin|fromage|chocolat|raclette|fondue|cave|gastronom|cellier|culinaire|terroir|cep)' THEN 'gourmand' END
  ], NULL)
FROM base b
WHERE a.id = b.id;

-- Safety net : ensure at least one category remains (fallback to 'nature' if all rules missed)
UPDATE activity_submissions
SET category = 'nature'
WHERE status = 'pending'
  AND created_at > now() - interval '4 hours'
  AND (category IS NULL OR category = '');
