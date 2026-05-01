// Whateka - Edge Function recommend-activity v34
// CHANGEMENTS v34 (perf + UX optimizations) :
//   #1 Profil utilisateur materialise dans user_taste_profiles, maintenu
//      par trigger DB sur la table favorites. computeUserTasteProfile()
//      se reduit a une seule lecture au lieu de 3-4 queries dynamiques.
//   #2 Scoring deplace dans Postgres (fonction score_activities). L'edge
//      function n'a plus a charger 100 candidats puis les scorer en JS :
//      tout est fait en une seule rpc(). Inclut les hard filters
//      (categories, price, environment, region), le filtre temporel
//      (is_activity_proposable_now), le rayon (haversine_km), et le
//      scoring complet (multi-cat, duration, social, weather, recency,
//      quality, taste). Voir migration create_score_activities_function.
//   #3 Reduction du nombre de candidats envoyes a Gemini : 50 -> 10
//      (top 5 par score + 5 diversifies par tier de prix).
//      Prompt ~5x plus court, cout tokens reduit, latence reduite.
//   #4 favorites_count materialise sur activities (colonne maintenue par
//      trigger DB sur la table favorites). Le scoring qualite lit la
//      colonne directement (pas de query separee). Voir migration
//      add_favorites_count_to_activities.
//   #5 Le pick "surprise" est selectionne AVANT l'appel Gemini et inclus
//      dans le prompt. Gemini genere une raison "decouverte" personnalisee
//      au lieu d'un texte generique. Fallback : texte generique inchange.
//
// CHANGEMENTS v33 (multi-categories priority) :
//   - Bonus categorie renforce pour multi-match (matched/requested * 12).
//   - Prompt Gemini explicite la priorite multi-categorie.
//
// CHANGEMENTS v32 (Smart Recommender Phase 2) : profil de gout user.
// CHANGEMENTS v31 (Smart Recommender Phase 1) : qualite + meteo + recence + surprise.
// CHANGEMENTS v30 : ponderation criteres (cat > price > env > duration > social).
// CHANGEMENTS anterieurs : voir historique git.

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "POST, GET, OPTIONS",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

const PRICE_LABELS: Record<number, string> = {
  1: "Gratuit",
  2: "1-20 CHF",
  3: "20-50 CHF",
  4: "50-100 CHF",
  5: "100+ CHF",
};

type Candidate = {
  id: number;
  title: string;
  category: string | null;
  price_level: number;
  duration_minutes: number | null;
  description: string | null;
  image_url: string | null;
  features: string[] | null;
  seasons: string[] | null;
  social_tags: string[] | null;
  location_name: string | null;
  is_outdoor: boolean | null;
  is_indoor: boolean | null;
  latitude: number | null;
  longitude: number | null;
  date_label: string | null;
  date_start: string | null;
  date_end: string | null;
  recurrence_type: string | null;
  seasonal_months: number[] | null;
  weekly_days: number[] | null;
  favorites_count: number | null;
  score: number;
};

// v34 #5 — choisit un candidat surprise dans les positions 5-30 du classement.
function pickSurpriseCandidate(
  sortedCandidates: Array<{ id: number; title?: string }>,
  excludedIds: Set<number>,
): { id: number; title?: string } | null {
  if (sortedCandidates.length < 6) return null;
  const pool = sortedCandidates
    .slice(5, 30)
    .filter((c) => !excludedIds.has(c.id));
  if (pool.length === 0) return null;
  return pool[Math.floor(Math.random() * pool.length)];
}

// Fallback : raison surprise generique si Gemini absent / parsing echoue.
function fallbackSurpriseReason(title?: string): string {
  return `💡 À découvrir : ${title ?? "une activité originale"}.`;
}

// Retourne N candidats en alternant les niveaux de prix (round-robin).
function diversifyByPriceLevel<T extends { price_level: number }>(
  candidates: T[],
  n: number,
): T[] {
  if (candidates.length <= n) return candidates;
  const byLevel = new Map<number, T[]>();
  for (const c of candidates) {
    const lvl = c.price_level;
    if (!byLevel.has(lvl)) byLevel.set(lvl, []);
    byLevel.get(lvl)!.push(c);
  }
  const levels = [...byLevel.keys()].sort((a, b) => a - b);
  const result: T[] = [];
  let rounds = 0;
  while (result.length < n && rounds < n * 2) {
    let added = false;
    for (const lvl of levels) {
      if (result.length >= n) break;
      const pool = byLevel.get(lvl);
      if (pool && pool.length > 0) {
        result.push(pool.shift()!);
        added = true;
      }
    }
    if (!added) break;
    rounds++;
  }
  return result;
}

// v19 garde-fou anti-monoculture : si Gemini renvoie 3 picks du meme tier
// alors que l'utilisateur en avait demande plusieurs ET que d'autres tiers
// sont dispos, on swap la derniere reco pour un autre tier.
function ensurePriceDiversity(
  recommendations: Array<{ id: number; match_reason: string }>,
  candidates: Array<
    { id: number; price_level: number; title: string; [k: string]: unknown }
  >,
  userSelectedLevels: Set<number>,
): Array<{ id: number; match_reason: string }> {
  if (recommendations.length < 2 || userSelectedLevels.size < 2) {
    return recommendations;
  }
  const candidateById = new Map(candidates.map((c) => [c.id, c]));
  const pickedLevels = new Set(
    recommendations
      .map((r) => candidateById.get(r.id)?.price_level)
      .filter((lvl): lvl is number => typeof lvl === "number"),
  );
  const availableLevels = new Set(
    candidates
      .map((c) => c.price_level)
      .filter((lvl) => userSelectedLevels.has(lvl)),
  );
  if (pickedLevels.size >= Math.min(2, availableLevels.size)) {
    return recommendations;
  }
  const missingLevels = [...availableLevels].filter(
    (lvl) => !pickedLevels.has(lvl),
  );
  if (missingLevels.length === 0) return recommendations;
  const pickedIds = new Set(recommendations.map((r) => r.id));
  const replacement = candidates.find(
    (c) => missingLevels.includes(c.price_level) && !pickedIds.has(c.id),
  );
  if (!replacement) return recommendations;
  const newRecs = [...recommendations];
  newRecs[newRecs.length - 1] = {
    id: replacement.id,
    match_reason: `Alternative budget ${
      PRICE_LABELS[replacement.price_level] || ""
    } pour varier : ${replacement.title}`,
  };
  return newRecs;
}

function buildGeminiPrompt(
  candidates: Record<string, unknown>[],
  prefs: {
    categories: string[];
    priceMax: number;
    priceLevels: number[];
    environment: string;
    social: string;
    duration: string;
  },
  surprise?: { id: number; title?: string } | null,
): string {
  const budgetLabel = prefs.priceLevels.length > 0
    ? prefs.priceLevels.map((l) => PRICE_LABELS[l] || String(l)).join(", ")
    : `${PRICE_LABELS[prefs.priceMax] || "Tous budgets"} et en-dessous`;
  const catLabel = prefs.categories.join(", ") || "toutes categories";

  const activitiesList = candidates
    .map(
      (a) =>
        `ID ${a.id}: "${a.title}" | categorie: ${a.category} | prix: ${
          PRICE_LABELS[a.price_level as number] || a.price_level
        }`,
    )
    .join("\n");

  const diversityHint = prefs.priceLevels.length > 1
    ? "\n- DIVERSITE PRIX : l'utilisateur a coche plusieurs budgets. Privilegie une selection VARIEE couvrant differents niveaux de prix si possible (ex : 1 gratuite + 2 payantes), sauf si une seule activite est clairement la meilleure pour chaque critere."
    : "";

  const nCat = prefs.categories.length;
  const multiCatRule = nCat === 1
    ? `REGLE CATEGORIE : l'utilisateur a choisi 1 seule categorie (${prefs.categories[0]}). Toutes les activites de la liste la contiennent deja — choisis simplement les 3 meilleures.`
    : nCat >= 2
    ? `REGLE CATEGORIE PRIORITAIRE : l'utilisateur a choisi ${nCat} categories (${prefs.categories.join(", ")}). PRIVILEGIE FORTEMENT les activites qui en couvrent PLUSIEURS a la fois. Une activite qui matche les ${nCat} categories doit toujours etre prefere a une activite qui n'en matche qu'une, meme si cette derniere semble plus attractive sur d'autres criteres. Tu peux quand meme inclure une activite mono-categorie si elle est exceptionnelle.`
    : "";

  // v34 #5 : raison "decouverte" personnalisee pour le surprise.
  const surpriseBlock = surprise
    ? `\n\nACTIVITE SURPRISE (a decouvrir) : ID ${surprise.id} — "${surprise.title ?? ""}"\nGenere pour CETTE activite specifique une accroche courte (max 15 mots) qui donne envie de la decouvrir, en commencant par "💡 À découvrir : ". Mets-la dans le champ "surprise" de la reponse.`
    : "";
  const surpriseJsonField = surprise
    ? `,\n  "surprise": {"id": ${surprise.id}, "match_reason": "💡 À découvrir : <raison originale, max 15 mots>"}`
    : "";

  return `Tu es un assistant de recommandation d'activites touristiques en Vaud / Valais (Suisse).

L'utilisateur cherche, par ordre d'importance DECROISSANT :
1. Categories (PRIORITAIRE) : ${catLabel}
2. Budget(s) selectionne(s)  : ${budgetLabel}
   (Toutes les activites de la liste respectent deja ce budget.)${diversityHint}
3. Environnement             : ${prefs.environment || "indifferent"}
4. Duree (preference)        : ${prefs.duration || "indifferent"}
5. Social (preference)       : ${prefs.social || "indifferent"}

${multiCatRule}

REGLE DE PONDERATION : la duree et le social sont des PREFERENCES, pas des
contraintes dures. Si une activite hors-bucket de duree est nettement plus
pertinente sur les categories, choisis-la quand meme.

Voici les activites disponibles (deja filtrees + scorees cote serveur,
triees par score de pertinence DECROISSANT) :
${activitiesList}${surpriseBlock}

Selectionne les 3 meilleures activites pour cet utilisateur.
Reponds UNIQUEMENT en JSON valide, sans markdown, sans explication :
{
  "recommendations": [
    {"id": <id>, "match_reason": "<raison courte en francais, max 15 mots>"},
    {"id": <id>, "match_reason": "<raison courte en francais, max 15 mots>"},
    {"id": <id>, "match_reason": "<raison courte en francais, max 15 mots>"}
  ]${surpriseJsonField},
  "global_comment": "<phrase d'accroche courte en francais>"
}`;
}

function parseGeminiResponse(
  text: string,
  candidates: Record<string, unknown>[],
): {
  recommendations: Array<{ id: number; match_reason: string }>;
  surprise: { id: number; match_reason: string } | null;
  globalComment: string;
} {
  try {
    const jsonMatch = text.match(/\{[\s\S]*\}/);
    if (!jsonMatch) {
      return { recommendations: [], surprise: null, globalComment: "" };
    }
    const parsed = JSON.parse(jsonMatch[0]);
    const validIds = new Set(candidates.map((c) => c.id));

    const recommendations = (parsed.recommendations || [])
      .filter((r: { id: number }) => validIds.has(r.id))
      .slice(0, 3)
      .map((r: { id: number; match_reason: string }) => ({
        id: r.id,
        match_reason: r.match_reason || "",
      }));

    let surprise: { id: number; match_reason: string } | null = null;
    if (
      parsed.surprise &&
      typeof parsed.surprise === "object" &&
      typeof parsed.surprise.id === "number" &&
      validIds.has(parsed.surprise.id)
    ) {
      const reason = String(parsed.surprise.match_reason || "").trim();
      if (reason.length > 0) {
        surprise = {
          id: parsed.surprise.id,
          match_reason: reason.startsWith("💡")
            ? reason
            : `💡 À découvrir : ${reason}`,
        };
      }
    }
    return {
      recommendations,
      surprise,
      globalComment: parsed.global_comment || "",
    };
  } catch (_e) {
    return { recommendations: [], surprise: null, globalComment: "" };
  }
}

function buildMatchReason(
  activity: Record<string, unknown>,
  categories: string[],
  priceMax: number,
): string {
  const budget = PRICE_LABELS[priceMax] || "votre budget";
  const cat = categories[0] || "vos envies";
  return `${activity.title} correspond a vos envies ${cat} dans votre budget ${budget}.`;
}

function buildGlobalComment(
  categories: string[],
  priceMax: number,
  priceLevels: number[],
): string {
  const budgetLabel = priceLevels.length > 0
    ? priceLevels.map((l) => PRICE_LABELS[l]).join(", ")
    : `${PRICE_LABELS[priceMax]} et moins`;
  const cat = categories.join(", ") || "vos envies";
  return `Voici des activites ${cat} dans votre budget (${budgetLabel}).`;
}

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }
  try {
    const body = await req.json();

    const userPrefs = body.user_prefs || {};
    const contextData = body.context || {};

    const categories: string[] = userPrefs.categories || body.categories || [];
    const priceMax: number = userPrefs.price_max || body.price_max || 5;
    const priceLevelsRaw = userPrefs.price_levels ?? body.price_levels ?? null;
    const priceLevels: number[] = Array.isArray(priceLevelsRaw)
      ? priceLevelsRaw.filter(
        (n: unknown) => typeof n === "number" && n >= 1 && n <= 5,
      )
      : [];
    const environment: string = userPrefs.environment || body.environment || "";
    const social: string = userPrefs.social || body.social || "";
    const duration: string = userPrefs.duration || body.duration || "";
    const radiusKm: number | null =
      userPrefs.radius_km !== undefined ? userPrefs.radius_km : null;
    const recentRecommendations: number[] = Array.isArray(
        userPrefs.recent_recommendations,
      )
      ? (userPrefs.recent_recommendations as unknown[])
        .filter((n): n is number => typeof n === "number")
      : [];
    const weather =
      (contextData.weather && typeof contextData.weather === "object")
        ? contextData.weather as { temperature?: number; weather_code?: number }
        : null;
    const region: string = (userPrefs.region || body.region || "")
      .toString()
      .toLowerCase();

    const userLat: number | null = contextData.location?.latitude ?? null;
    const userLng: number | null = contextData.location?.longitude ?? null;
    const userId: string | null = (typeof body.user_id === "string")
      ? body.user_id
      : null;

    const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
    const supabaseKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
    const geminiKey = Deno.env.get("GEMINI_API_KEY") || "";

    const supabase = createClient(supabaseUrl, supabaseKey);

    // v34 #2 : un seul rpc() Postgres fait tout :
    //   - hard filters (categories, price, environment, region)
    //   - filtre temporel (is_activity_proposable_now)
    //   - rayon haversine
    //   - scoring complet (multi-cat, duration, social, weather, recency, quality, taste)
    //   - tri DESC + LIMIT 100
    const { data: rpcData, error } = await supabase.rpc("score_activities", {
      p_categories: categories,
      p_price_levels: priceLevels,
      p_price_max: priceMax,
      p_environment: environment,
      p_region: region,
      p_duration: duration,
      p_social: social,
      p_radius_km: radiusKm,
      p_user_lat: userLat,
      p_user_lng: userLng,
      p_user_id: userId,
      p_recent_ids: recentRecommendations,
      p_weather_code: typeof weather?.weather_code === "number"
        ? weather.weather_code
        : null,
      p_weather_temp: typeof weather?.temperature === "number"
        ? weather.temperature
        : null,
      p_now: new Date().toISOString(),
      p_limit: 100,
    });
    if (error) throw error;
    const candidates = (rpcData ?? []) as Candidate[];

    if (candidates.length === 0) {
      return new Response(
        JSON.stringify({
          recommendations: [],
          global_comment:
            "Aucune activite ne correspond exactement a vos criteres. Essayez d'elargir votre rayon de recherche, votre budget ou vos categories.",
        }),
        { headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }

    // v34 #3 : top 10 pour Gemini (top 5 + 5 diversifies par tier de prix).
    // La liste complete reste utilisee pour le surprise pick et le swap diversite.
    const top5 = candidates.slice(0, 5);
    const diversifiedTail = diversifyByPriceLevel(candidates.slice(5, 50), 5);
    const geminiCandidates: Candidate[] = [...top5, ...diversifiedTail];

    const userSelectedLevels: Set<number> = priceLevels.length > 0
      ? new Set(priceLevels)
      : new Set(Array.from({ length: priceMax }, (_, i) => i + 1));

    // v34 #5 : pre-pick le surprise et l'inclure dans geminiCandidates s'il
    // n'y est pas deja, pour que Gemini puisse generer sa raison "decouverte".
    const surpriseCandidate = pickSurpriseCandidate(
      candidates,
      new Set(geminiCandidates.slice(0, 2).map((c) => c.id)),
    );
    if (
      surpriseCandidate &&
      !geminiCandidates.some((c) => c.id === surpriseCandidate.id)
    ) {
      const full = candidates.find((c) => c.id === surpriseCandidate.id);
      if (full) geminiCandidates.push(full);
    }

    let recommendations: Array<{ id: number; match_reason: string }> = [];
    let globalComment = "";
    let geminiSurpriseReason: string | null = null;

    if (geminiKey) {
      const prompt = buildGeminiPrompt(geminiCandidates, {
        categories,
        priceMax,
        priceLevels,
        environment,
        social,
        duration,
      }, surpriseCandidate);

      try {
        const geminiRes = await fetch(
          `https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=${geminiKey}`,
          {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({
              contents: [{ parts: [{ text: prompt }] }],
              generationConfig: { temperature: 0.7, maxOutputTokens: 1024 },
            }),
          },
        );
        if (geminiRes.ok) {
          const geminiData = await geminiRes.json();
          const text =
            geminiData.candidates?.[0]?.content?.parts?.[0]?.text || "";
          const parsed = parseGeminiResponse(text, geminiCandidates);
          if (parsed.recommendations.length > 0) {
            recommendations = parsed.recommendations;
            globalComment = parsed.globalComment;
          }
          if (
            parsed.surprise && surpriseCandidate &&
            parsed.surprise.id === surpriseCandidate.id
          ) {
            geminiSurpriseReason = parsed.surprise.match_reason;
          }
        }
      } catch (_e) {
        // Gemini indisponible -> fallback ci-dessous
      }
    }

    if (recommendations.length === 0) {
      const diversified = diversifyByPriceLevel(candidates, 3);
      recommendations = diversified.map((a) => ({
        id: a.id,
        match_reason: buildMatchReason(a, categories, priceMax),
      }));
      globalComment = buildGlobalComment(categories, priceMax, priceLevels);
    } else {
      recommendations = ensurePriceDiversity(
        recommendations,
        candidates,
        userSelectedLevels,
      );
    }

    // v34 #5 : injection du surprise pick avec raison Gemini si dispo.
    if (surpriseCandidate && recommendations.length >= 3) {
      const pickedTwo = recommendations
        .filter((r) => r.id !== surpriseCandidate.id)
        .slice(0, 2);
      const reason = geminiSurpriseReason ??
        fallbackSurpriseReason(surpriseCandidate.title);
      recommendations = [
        ...pickedTwo,
        { id: surpriseCandidate.id, match_reason: reason },
      ];
    }

    return new Response(
      JSON.stringify({ recommendations, global_comment: globalComment }),
      { headers: { ...corsHeaders, "Content-Type": "application/json" } },
    );
  } catch (err: unknown) {
    const message = err instanceof Error ? err.message : String(err);
    return new Response(JSON.stringify({ error: message }), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
      status: 400,
    });
  }
});
