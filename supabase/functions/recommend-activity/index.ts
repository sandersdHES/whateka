// Whateka - Edge Function recommend-activity v35
// CHANGEMENTS v35 (Subscription enforcement) :
//   - Lit la subscription du user (table 'subscriptions') pour appliquer
//     les regles de tier cote serveur :
//       * regional : force le filtre region = selected_region (override
//         de ce que le client a envoye)
//       * evasion  : pas de filtre region (Vaud + Valais autorises)
//       * free     : aucun changement (le quota est verifie via le RPC
//         consume_free_quiz cote client)
//   - Defense en profondeur : meme si le client est compromis, un user
//     'regional' ne peut voir que son canton, un user 'free' n'a aucun
//     traitement different (sa quota est appliquee par le RPC).
//
// CHANGEMENTS v34 (ton conversationnel des match_reason) :
// CHANGEMENTS v34 (ton conversationnel des match_reason) :
//   - Refonte du prompt Gemini pour generer des phrases CONVERSATIONNELLES
//     (style "ami qui te conseille") au lieu de listes d'attributs.
//     Avant : "Excellent score, gratuit, relax au bord de l'eau, parfait
//             pour une courte pause solo."
//     Apres : "Envie d'un break tranquille ? Pose-toi au bord du lac."
//   - Regles strictes ajoutees au prompt : utilise "tu", pas de jargon
//     (score, match, recommande), pas de liste d'attributs, pas de
//     repetition du titre, pas de mention explicite de la categorie.
//   - Exemples inclus dans le prompt (1-shot learning).
//   - Fallback (Gemini down) : pool de 5 templates conversationnels +
//     helper _friendlyCat() pour rendre les categories fluides.
//
// CHANGEMENTS v33 (multi-categories priority) :
//   - Renforcement du bonus pour les activites qui matchent PLUSIEURS
//     categories choisies par l'utilisateur :
//       * 1 cat demandee : pas de bonus diff (tout candidat passe le filtre SQL)
//       * 2 cat demandees : +12 si matche 2, +6 si matche 1 (baseline)
//       * 3 cat demandees : +12 si matche 3, +8 si matche 2, 0 si matche 1
//   - Bonus pondere "matched / requested * 12" : domine les autres signaux
//     (quality +3, duration +4, meteo +/-3) -> les multi-match remontent.
//   - Pour 1 categorie : le filtre SQL garantit deja sa presence dans tous
//     les candidats donc dans les 3 picks finaux (y compris le surprise).
//   - Prompt Gemini mis a jour pour expliciter la priorite multi-categorie.
//
// CHANGEMENTS v32 (Smart Recommender Phase 2 — personnalisation par historique) :
//   - computeUserTasteProfile() : construit un profil utilisateur a la volee
//     a partir de ses FAVORIS (signal principal). Si la table feedback existe
//     encore (deprecation prevue), elle est utilisee en signal secondaire :
//     ratings >= 4 = positif (renforce le profil), ratings <= 2 = negatif
//     (alimente disliked_categories).
//       * top_categories     : poids relatifs des categories likees
//       * avg_price_level    : prix moyen prefere (1-5)
//       * indoor_outdoor_pref: ratio des likes indoor vs outdoor
//       * popular_social_tags: tags les plus presents dans les likes
//       * disliked_categories: alimente seulement si feedback existe (sinon vide)
//   - tasteBonus() : applique des bonus/penalites par candidat selon le profil
//       * +4 max si match avec top_categories ponderee
//       * +2 si price_level dans la plage preferee +/-1
//       * +1 si indoor/outdoor matche la preference
//       * +1 si overlap social_tags
//       * -3 si categorie dans disliked_categories (no-op si feedback supprime)
//   - Cold start : si total_signals (= nb favoris + feedback positifs) < 3,
//     on skip la perso (Phase 1 seule). Evite d'orienter trop tot un nouvel
//     user vers un pattern bruite.
//   - Le profil est NON cache (calcul a chaque appel) car peu couteux et
//     toujours frais. ~2 queries supplementaires.
//   - NOTE deprecation feedback : quand les tables feedback_submissions /
//     feedback_answers seront supprimees, ce code degrade gracieusement
//     (queries vides). Pour conserver le signal negatif il faudra ajouter
//     un mecanisme explicite (ex : bouton "pas interesse" sur fiche activite).
//
// CHANGEMENTS v31 (Smart Recommender Phase 1) :
//   1. Score qualite : bonus selon nb de favoris + rating moyen feedback
//      - Top 20% qualite : +3
//      - Top 50% qualite : +1
//   2. Anti-repetition : penalite sur les activites recemment recommandees
//      (lues depuis user_prefs.recent_recommendations envoye par le client) :
//      - Position 0-4  (les 5 dernieres) : -5
//      - Position 5-19 (5e a 20e plus recente) : -2
//   3. Meteo intelligente :
//      - Pluie / neige / orage (weather_code >= 51) : -3 outdoor pur, +2 indoor
//      - Temp > 28C : +2 nature, +1 detente
//      - Temp <  5C : +2 indoor, -1 outdoor pur
//   4. Exploration controlled : remplace le 3e pick Gemini par un "surprise"
//      tire au sort dans les positions 5-30 (parmi les candidats triés).
//      Le match_reason est prefixe avec "💡 À découvrir :" pour signaler.
//      Permet de casser l'effet "toujours les memes" au 2eme/3eme quiz.
//
// CHANGEMENTS v30 (par rapport a v29) :
//   - Ponderation des criteres : les categories sont plus importantes que
//     la duree. La duree passe de filtre HARD a critere SOFT (scoring).
//     * Categories  : hard filter   (poids 5, doit matcher au moins une)
//     * Price       : hard filter   (poids 4, contrainte budget reelle)
//     * Environment : hard filter   (poids 3) MAIS conserve "any" si Gemini
//                     choisit une activite mixte indoor+outdoor.
//     * Duration    : SOFT scoring  (poids 2, exact = +4, adjacent = +2)
//     * Social      : SOFT scoring  (poids 1, +1 par tag matche)
//   - Apres SQL filter, on score chaque candidat puis tri desc par score.
//     Top 50 envoyes a Gemini (avant : top 50 dans l'ordre DB).
//   - Le prompt Gemini liste explicitement la hierarchie d'importance.
//   - Saisonniers : `recurrence_type='seasonal'` accepte aussi date_start /
//     date_end (fenetre MM-JJ recurrente, annee ignoree). Permet de definir
//     ouverture/fermeture precises (ex: telecabine 12 dec -> 5 avril).
//
// CHANGEMENTS v29 (deploye, conserves) :
//   - Exclut les activites 'event' sans date_start/date_end (fiches club /
//     institution sans match planifie).
//
// CHANGEMENTS v27 (par rapport a v26) :
//   - Nouvelle regle pour les evenements 1-jour (date_start == date_end) :
//     visible UNIQUEMENT les 5 jours avant + le jour meme.
//     Adapte aux matchs sportifs : un match samedi est propose du lundi
//     au samedi de la meme semaine.
//   - Hierarchie des regles one_off :
//       * 1 jour       : 5 jours avant date_end
//       * 2 a 7 jours  : 21 jours avant date_end
//       * 8 a 29 jours : 21 jours avant date_start
//       * >= 30 jours  : entre date_start et date_end
//
// CHANGEMENTS v26 :
//   - Contraintes additives. Une activite peut combiner :
//       * date_start/date_end (one_off, fenetre temporelle)
//       * weekly_days (jours de la semaine)
//       * seasonal_months (mois de l'annee)
//     Toutes les contraintes renseignees doivent etre satisfaites (AND).
//
// CHANGEMENTS v25 :
//   - weekly : visible UNIQUEMENT si le jour courant ∈ weekly_days.
//
// CHANGEMENTS v24 :
//   - Filtrage temporel : exclut les activites dont la contrainte de date
//     ne correspond pas a "maintenant" (regles selon recurrence_type).
//       * one_off (≤7j) : visible 21j avant date_end jusqu'a date_end
//       * one_off (8-29j) : visible 21j avant date_start jusqu'a date_end
//       * one_off (≥30j) : visible entre date_start et date_end
//       * seasonal : visible si mois courant ∈ seasonal_months
//       * NULL/sans contrainte : toujours visible
//   - Ajoute date_label, date_start, date_end, recurrence_type,
//     seasonal_months, weekly_days dans la reponse pour affichage cote client.
//
// CHANGEMENTS v22 (par rapport a v21) :
//   - Nouveau parametre `region` ('vaud' | 'valais') : filtre les activites
//     par canton au lieu d'un rayon geographique (utilise pour "Vaud complet"
//     et "Valais complet" dans le profil).
//     Regle : location_zone IS NULL -> Vaud, location_zone IS NOT NULL -> Valais.
//     Quand `region` est defini, le rayon et la position utilisateur sont ignores.
//
// CHANGEMENTS v21 (rappel, conserves) :
//   - Filtrage effectif sur duration_minutes selon le bucket choisi :
//       short  -> duration_minutes < 180        (moins de 3h)
//       medium -> 180 <= duration_minutes <= 300 (3h a 5h inclus)
//       long   -> duration_minutes > 300         (plus de 5h)
//     Avant : la duree etait passee a Gemini comme hint mais jamais filtree
//     en SQL, donc des activites hors-duree pouvaient etre recommandees.
//
// CHANGEMENTS v20 (rappel, conserves) :
//   - Support du nouveau modele Indoor/Outdoor non exclusifs (migration 0002).
//     Une activite peut avoir is_indoor=true ET is_outdoor=true.
//     Logique de filtrage :
//       * environment="outdoor" -> is_outdoor=true (peu importe is_indoor)
//       * environment="indoor"  -> is_indoor=true  (peu importe is_outdoor)
//       * autre                 -> pas de filtre environnement
//
// CHANGEMENTS v19 (rappel, conserves) :
//   - Support de "price_levels" (liste explicite) + diversite des prix
//     dans les recommandations (round-robin en fallback, swap si Gemini
//     renvoie 3 activites du meme tier).
//
// CHANGEMENTS v18 (rappel, conserves) :
//   - Filtrage par rayon de recherche (haversine) via radius_km.

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "POST, GET, OPTIONS",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

function daysBetween(a: Date, b: Date): number {
  return Math.round((b.getTime() - a.getTime()) / 86400000);
}

// v28 : verifie si une activite est proposable a la date `now` selon sa
// contrainte temporelle. Support etendu :
//   - seasonal : `seasonal_months` (mois grossiers) OU `date_start/date_end`
//     (ouverture/fermeture precises, annee ignoree => fenetre MM-JJ recurrente)
//   - weekly   : `weekly_days`
//   - one_off  : `date_start/date_end` (fenetre absolue avec annee)
function isProposableNow(
  a: {
    recurrence_type?: string | null;
    date_start?: string | null;
    date_end?: string | null;
    seasonal_months?: number[] | null;
    weekly_days?: number[] | null;
    category?: string | null;
  },
  now: Date,
): boolean {
  // v29 : un event sans date_start est une fiche template (club, institution
  // sans match planifie) — pas recommandable.
  const cats = (a.category ?? "")
    .split(",")
    .map((c) => c.trim().toLowerCase())
    .filter(Boolean);
  const isEvent = cats.includes("event");
  if (isEvent && (!a.date_start || !a.date_end)) return false;

  const rec = a.recurrence_type;
  if (!rec) return true;

  // v26 : toutes les contraintes renseignees doivent etre satisfaites (AND).
  const hasWeekly = Array.isArray(a.weekly_days) && a.weekly_days.length > 0;
  const hasSeasonalMonths =
    Array.isArray(a.seasonal_months) && a.seasonal_months.length > 0;
  const hasDateRange = !!a.date_start && !!a.date_end;
  const hasOneOff = rec === "one_off" && hasDateRange;
  // v28 : pour les saisonniers, on accepte aussi des dates precises
  // (fenetre annuelle recurrente MM-JJ).
  const hasSeasonalDates = rec === "seasonal" && hasDateRange;

  // Filtre jour de la semaine
  if (hasWeekly && !a.weekly_days!.includes(now.getDay())) return false;
  // Filtre mois de l'annee
  if (hasSeasonalMonths && !a.seasonal_months!.includes(now.getMonth() + 1)) {
    return false;
  }
  // v28 : Filtre fenetre saisonniere precise (ouverture/fermeture sur MM-JJ).
  // L'annee stockee dans date_start/date_end est ignoree — on ne compare que
  // (mois, jour). Gere correctement les fenetres qui passent l'annee
  // (ex : 15 dec -> 5 avril).
  if (hasSeasonalDates) {
    const start = new Date(a.date_start!);
    const end = new Date(a.date_end!);
    const startKey = start.getMonth() * 100 + start.getDate();
    const endKey = end.getMonth() * 100 + end.getDate();
    const nowKey = now.getMonth() * 100 + now.getDate();
    const inWindow = startKey <= endKey
      // Fenetre standard dans la meme annee : 1er mars -> 30 sept
      ? (nowKey >= startKey && nowKey <= endKey)
      // Fenetre qui traverse le 1er janvier : 15 dec -> 5 avril
      : (nowKey >= startKey || nowKey <= endKey);
    if (!inWindow) return false;
  }
  // Filtre fenetre one_off (annee absolue, pas recurrente)
  if (hasOneOff) {
    const start = new Date(a.date_start!);
    const end = new Date(a.date_end!);
    end.setHours(23, 59, 59, 999);
    if (now > end) return false;
    const dur = daysBetween(start, end) + 1;
    if (dur <= 1) {
      // v27 : evenement 1-jour (match, concert, etc.) -> 5 jours avant + jour J
      const win = new Date(end);
      win.setDate(win.getDate() - 5);
      if (now < win) return false;
    } else if (dur <= 7) {
      const win = new Date(end);
      win.setDate(win.getDate() - 21);
      if (now < win) return false;
    } else if (dur < 30) {
      const win = new Date(start);
      win.setDate(win.getDate() - 21);
      if (now < win) return false;
    } else {
      if (now < start) return false;
    }
  }

  // Si recurrence_type='seasonal' mais ni mois ni dates renseignes -> exclure
  // (donnee incomplete = ne pas proposer)
  if (rec === "seasonal" && !hasSeasonalMonths && !hasSeasonalDates) {
    return false;
  }
  // Si recurrence_type='one_off' mais pas de dates -> retrocompat (visible)

  return true;
}

/**
 * v28 : score un candidat selon les criteres ponderes.
 * Le poids par critere reflete la hierarchie d'importance demandee :
 *   categories (5) > price (4) > environment (3) > duration (2) > social (1)
 * Categories/price/environment sont deja filtres hard au SQL — on score ici
 * surtout duration et social, plus un bonus par categorie supplementaire matchee.
 */
function scoreCandidate(
  a: {
    category?: string | null;
    duration_minutes?: number | null;
    social_tags?: string[] | null;
  },
  prefs: { categories: string[]; duration: string; social: string },
): number {
  let score = 0;

  // v33 : bonus categorie renforce pour favoriser les multi-match.
  // Si l'utilisateur a choisi 2 categories et qu'une activite matche les 2,
  // elle remonte fortement (+12). Si elle ne matche que la moitie, +6.
  // Pour 1 seule categorie demandee, le filtre SQL garantit deja la presence,
  // donc pas de bonus differenciant ici.
  const activityCats = (a.category ?? "")
    .split(",")
    .map((c) => c.trim().toLowerCase())
    .filter(Boolean);
  const matchedCats = prefs.categories.filter((c) =>
    activityCats.some((ac) => ac.includes(c.toLowerCase()))
  ).length;
  const requestedCats = prefs.categories.length;
  if (requestedCats >= 2 && matchedCats >= 1) {
    // Score proportionnel : matched/requested * 12.
    // matched=2 sur 2 -> +12 ; matched=1 sur 2 -> +6
    // matched=3 sur 3 -> +12 ; matched=2 sur 3 -> +8 ; matched=1 sur 3 -> +4
    score += (matchedCats / requestedCats) * 12;
  }

  // Score duration : exact = +4, adjacent = +2, sinon 0.
  // short < 180min, medium 180-300min, long > 300min.
  const dm = a.duration_minutes ?? 0;
  const actualBucket = dm < 180 ? "short" : dm <= 300 ? "medium" : "long";
  if (prefs.duration && prefs.duration !== "") {
    if (actualBucket === prefs.duration) {
      score += 4;
    } else if (
      (prefs.duration === "short" && actualBucket === "medium") ||
      (prefs.duration === "medium" &&
        (actualBucket === "short" || actualBucket === "long")) ||
      (prefs.duration === "long" && actualBucket === "medium")
    ) {
      score += 2;
    }
  }

  // Score social : +1 par tag match. La case "solo/couple/family/friends"
  // du quiz mappe approximativement aux tags activite (FR : Solo/Couple/Famille/Amis).
  if (prefs.social && prefs.social !== "") {
    const tagMap: Record<string, string> = {
      solo: "Solo",
      couple: "Couple",
      family: "Famille",
      friends: "Amis",
    };
    const wantedTag = tagMap[prefs.social.toLowerCase()];
    if (wantedTag && (a.social_tags ?? []).includes(wantedTag)) {
      score += 1;
    }
  }

  return score;
}

/**
 * v31 (Smart Recommender Phase 1.3) — bonus / penalite meteo selon les
 * caracteristiques de l'activite. Open-Meteo WMO codes :
 *   0       : ciel clair
 *   1-3     : partiellement nuageux
 *   45-48   : brouillard
 *   51-67   : bruine / pluie
 *   71-77   : neige
 *   80-82   : averses
 *   85-86   : averses neigeuses
 *   95-99   : orage
 */
function weatherBonus(
  a: { is_indoor?: boolean | null; is_outdoor?: boolean | null; category?: string | null },
  weather: { temperature?: number | null; weather_code?: number | null } | null,
): number {
  if (!weather) return 0;
  let bonus = 0;
  const code = weather.weather_code;
  const temp = weather.temperature;

  // Mauvais temps : pluie, neige, orage
  if (typeof code === "number" && code >= 51) {
    if (a.is_outdoor && !a.is_indoor) bonus -= 3; // outdoor pur penalise
    if (a.is_indoor) bonus += 2; // indoor / mixte favorise
  }

  if (typeof temp === "number") {
    const cats = (a.category ?? "").toLowerCase();
    // Chaleur : favoriser nature (foret, montagne, eau) et detente (spa)
    if (temp > 28) {
      if (cats.includes("nature")) bonus += 2;
      if (cats.includes("relax")) bonus += 1;
    }
    // Froid : favoriser indoor chaud, penaliser outdoor pur
    if (temp < 5) {
      if (a.is_indoor) bonus += 2;
      if (a.is_outdoor && !a.is_indoor) bonus -= 1;
    }
  }
  return bonus;
}

/**
 * v31 (Smart Recommender Phase 1.2) — penalite si l'activite a deja ete
 * recommandee recemment au meme utilisateur. Le client passe la liste
 * `recent_recommendations` (les plus recents en premier).
 */
function recencyPenalty(activityId: number, recentIds: number[] | null | undefined): number {
  if (!Array.isArray(recentIds)) return 0;
  const idx = recentIds.indexOf(activityId);
  if (idx < 0) return 0;
  if (idx < 5) return -5; // tres recent (5 dernieres reco)
  if (idx < 20) return -2; // moyennement recent (5-20)
  return 0;
}

/**
 * v31 (Smart Recommender Phase 1.1) — score qualite agrege calcule depuis :
 *   - nb de favoris    (signal "j'y retournerai")
 *   - rating moyen     (signal "j'ai aime")
 *   - nb de feedbacks  (volume = confiance dans la note)
 * Les top 20% des activites avec un score positif gagnent +3, les 30%
 * suivantes (top 50%) gagnent +1. Le reste : 0.
 *
 * On retourne une Map<activityId, bonus> pour eviter de recalculer dans la boucle.
 */
async function fetchQualityBonus(
  supabase: ReturnType<typeof createClient>,
  candidateIds: number[],
): Promise<Map<number, number>> {
  if (candidateIds.length === 0) return new Map();

  // Compte les favoris par activite (1 query batch)
  const { data: favRows } = await supabase
    .from("favorites")
    .select("activity_id")
    .in("activity_id", candidateIds);

  const favCount = new Map<number, number>();
  for (const r of (favRows ?? []) as Array<{ activity_id: number }>) {
    favCount.set(r.activity_id, (favCount.get(r.activity_id) ?? 0) + 1);
  }

  // Rating moyen via feedback_submissions + feedback_answers (DEPRECATION en cours).
  // Si tables vides/supprimees, le score qualite sera base uniquement sur les
  // favoris — toujours fonctionnel.
  const ratingSum = new Map<number, number>();
  const ratingCount = new Map<number, number>();
  try {
    const { data: subRows } = await supabase
      .from("feedback_submissions")
      .select("id, activity_id")
      .in("activity_id", candidateIds);
    const subToActivity = new Map<string, number>();
    for (
      const r of (subRows ?? []) as Array<{ id: string; activity_id: number }>
    ) {
      subToActivity.set(r.id, r.activity_id);
    }
    if (subToActivity.size > 0) {
      const subIds = Array.from(subToActivity.keys());
      const { data: ansRows } = await supabase
        .from("feedback_answers")
        .select("submission_id, answer_rating")
        .in("submission_id", subIds)
        .not("answer_rating", "is", null);
      for (
        const r of (ansRows ?? []) as Array<{
          submission_id: string;
          answer_rating: number;
        }>
      ) {
        const aid = subToActivity.get(r.submission_id);
        if (aid == null) continue;
        ratingSum.set(aid, (ratingSum.get(aid) ?? 0) + r.answer_rating);
        ratingCount.set(aid, (ratingCount.get(aid) ?? 0) + 1);
      }
    }
  } catch (_e) {
    // Tables feedback supprimees : le score qualite passe en mode favoris-only.
  }

  // Score qualite combine : 0.7 * (rating moyen / 5) + 0.3 * (favoris normalises)
  // Normalisation favoris : log(1 + nb_fav) / log(1 + max_fav) pour aplatir.
  const maxFav = Math.max(0, ...favCount.values());
  const rawScores = new Map<number, number>();
  for (const id of candidateIds) {
    const f = favCount.get(id) ?? 0;
    const rs = ratingSum.get(id) ?? 0;
    const rc = ratingCount.get(id) ?? 0;
    const ratingPart = rc > 0 ? rs / rc / 5 : 0; // 0..1
    const favPart = maxFav > 0 ? Math.log(1 + f) / Math.log(1 + maxFav) : 0;
    rawScores.set(id, 0.7 * ratingPart + 0.3 * favPart);
  }

  // Tri descendant pour determiner les seuils top20%/top50%.
  const sorted = [...rawScores.entries()]
    .filter(([, s]) => s > 0)
    .sort((a, b) => b[1] - a[1]);
  const top20Cutoff = Math.max(1, Math.floor(sorted.length * 0.2));
  const top50Cutoff = Math.max(1, Math.floor(sorted.length * 0.5));

  const bonus = new Map<number, number>();
  for (let i = 0; i < sorted.length; i++) {
    if (i < top20Cutoff) bonus.set(sorted[i][0], 3);
    else if (i < top50Cutoff) bonus.set(sorted[i][0], 1);
  }
  return bonus;
}

/**
 * v32 (Smart Recommender Phase 2) — profil de gout calcule depuis l'historique
 * d'un user (favoris + feedbacks positifs et negatifs).
 */
type UserTasteProfile = {
  totalSignals: number; // nb total d'activites likees + feedbacks pos
  topCategories: Map<string, number>; // poids 0..1 par categorie
  avgPriceLevel: number | null; // moyenne 1-5 ou null si pas de signal
  indoorOutdoorPref: "mostly_indoor" | "mostly_outdoor" | "mixed" | null;
  popularSocialTags: Set<string>; // tags presents dans >= 30% des likes
  dislikedCategories: Set<string>; // categories notees <= 2 dans le feedback
};

/**
 * Construit le profil de gout du user a la volee. Lit :
 *   - favorites jointes a activities (signal positif fort)
 *   - feedback_submissions + feedback_answers avec rating >= 4 (positif)
 *   - feedback avec rating <= 2 (negatif, alimente dislikedCategories)
 *
 * Si le user a < 3 signaux totaux, retourne un profil vide (cold start).
 * Echec gracieux : en cas d'erreur DB on retourne null (l'algo continue
 * sans personnalisation).
 */
async function computeUserTasteProfile(
  supabase: ReturnType<typeof createClient>,
  userId: string | null,
): Promise<UserTasteProfile | null> {
  if (!userId) return null;
  try {
    // 1. Favoris : signal positif fort. Joint avec activities pour metadata.
    const { data: favData } = await supabase
      .from("favorites")
      .select(
        "activities!inner(id, category, price_level, is_indoor, is_outdoor, social_tags)",
      )
      .eq("user_id", userId);

    type ActMeta = {
      id: number;
      category: string | null;
      price_level: number | null;
      is_indoor: boolean | null;
      is_outdoor: boolean | null;
      social_tags: string[] | null;
    };
    const positives: ActMeta[] = ((favData ?? []) as Array<{ activities: ActMeta }>)
      .map((r) => r.activities)
      .filter(Boolean);

    // 2. Feedbacks (DEPRECATION en cours) : si les tables existent encore on
    //    extrait les ratings positifs (>=4) et negatifs (<=2) en moyennant
    //    par activity_id. Si tables vides ou supprimees -> queries renvoient
    //    rien, on continue en favoris-only.
    const ratingsByActivity = new Map<number, number[]>();
    try {
      const { data: subData } = await supabase
        .from("feedback_submissions")
        .select("id, activity_id")
        .eq("user_id", userId);
      const subToActivity = new Map<string, number>();
      for (
        const s of (subData ?? []) as Array<{ id: string; activity_id: number }>
      ) {
        subToActivity.set(s.id, s.activity_id);
      }
      if (subToActivity.size > 0) {
        const subIds = Array.from(subToActivity.keys());
        const { data: ansData } = await supabase
          .from("feedback_answers")
          .select("submission_id, answer_rating")
          .in("submission_id", subIds)
          .not("answer_rating", "is", null);
        for (
          const a of (ansData ?? []) as Array<{
            submission_id: string;
            answer_rating: number;
          }>
        ) {
          const aid = subToActivity.get(a.submission_id);
          if (aid == null) continue;
          if (!ratingsByActivity.has(aid)) ratingsByActivity.set(aid, []);
          ratingsByActivity.get(aid)!.push(a.answer_rating);
        }
      }
    } catch (_e) {
      // Tables feedback supprimees ou erreur de lecture : pas grave, le
      // profil sera construit uniquement depuis les favoris (signal principal).
    }

    // Calcule rating moyen par activite ET separe positifs (>=4) vs negatifs (<=2).
    const positiveActivityIds = new Set<number>();
    const negativeActivityIds = new Set<number>();
    for (const [aid, ratings] of ratingsByActivity.entries()) {
      const avg = ratings.reduce((a, b) => a + b, 0) / ratings.length;
      if (avg >= 4) positiveActivityIds.add(aid);
      else if (avg <= 2) negativeActivityIds.add(aid);
    }

    // 3. Charge les metadata des activites positives feedback (pas deja dans favoris)
    //    et des negatives (pour disliked categories).
    const knownIds = new Set(positives.map((a) => a.id));
    const additionalIds = [
      ...positiveActivityIds,
      ...negativeActivityIds,
    ].filter((id) => !knownIds.has(id));
    let additionalActs: ActMeta[] = [];
    if (additionalIds.length > 0) {
      const { data: addData } = await supabase
        .from("activities")
        .select("id, category, price_level, is_indoor, is_outdoor, social_tags")
        .in("id", additionalIds);
      additionalActs = (addData ?? []) as ActMeta[];
    }
    const allActs = new Map<number, ActMeta>();
    for (const a of positives) allActs.set(a.id, a);
    for (const a of additionalActs) allActs.set(a.id, a);

    // Combine signals positifs : favoris + feedback>=4 (deduplique)
    const positiveActs: ActMeta[] = [];
    for (const a of positives) positiveActs.push(a);
    for (const aid of positiveActivityIds) {
      if (knownIds.has(aid)) continue;
      const a = allActs.get(aid);
      if (a) positiveActs.push(a);
    }
    const negativeActs: ActMeta[] = [];
    for (const aid of negativeActivityIds) {
      const a = allActs.get(aid);
      if (a) negativeActs.push(a);
    }

    const totalSignals = positiveActs.length;
    if (totalSignals === 0 && negativeActs.length === 0) return null;

    // --- Aggregations ---
    // top_categories : compte les occurrences puis normalise.
    const catCount = new Map<string, number>();
    for (const a of positiveActs) {
      const cats = (a.category ?? "")
        .split(",")
        .map((c) => c.trim().toLowerCase())
        .filter(Boolean);
      for (const c of cats) catCount.set(c, (catCount.get(c) ?? 0) + 1);
    }
    const totalCatOcc = [...catCount.values()].reduce((a, b) => a + b, 0) || 1;
    const topCategories = new Map<string, number>();
    for (const [c, n] of catCount.entries()) {
      topCategories.set(c, n / totalCatOcc);
    }

    // avg_price_level : moyenne (ignore les null)
    const prices = positiveActs
      .map((a) => a.price_level)
      .filter((p): p is number => typeof p === "number");
    const avgPriceLevel = prices.length > 0
      ? prices.reduce((a, b) => a + b, 0) / prices.length
      : null;

    // indoor_outdoor_pref : ratio outdoor vs indoor
    let indoorN = 0, outdoorN = 0;
    for (const a of positiveActs) {
      if (a.is_indoor) indoorN++;
      if (a.is_outdoor) outdoorN++;
    }
    let indoorOutdoorPref: UserTasteProfile["indoorOutdoorPref"] = null;
    if (indoorN + outdoorN > 0) {
      const ratio = outdoorN / (indoorN + outdoorN);
      if (ratio >= 0.7) indoorOutdoorPref = "mostly_outdoor";
      else if (ratio <= 0.3) indoorOutdoorPref = "mostly_indoor";
      else indoorOutdoorPref = "mixed";
    }

    // popular_social_tags : tags qui apparaissent dans >= 30% des likes
    const tagCount = new Map<string, number>();
    for (const a of positiveActs) {
      for (const t of a.social_tags ?? []) {
        tagCount.set(t, (tagCount.get(t) ?? 0) + 1);
      }
    }
    const popThreshold = Math.max(1, Math.floor(positiveActs.length * 0.3));
    const popularSocialTags = new Set<string>();
    for (const [t, n] of tagCount.entries()) {
      if (n >= popThreshold) popularSocialTags.add(t);
    }

    // disliked_categories : categories presentes dans les feedback negatifs.
    const dislikedCategories = new Set<string>();
    for (const a of negativeActs) {
      const cats = (a.category ?? "")
        .split(",")
        .map((c) => c.trim().toLowerCase())
        .filter(Boolean);
      for (const c of cats) dislikedCategories.add(c);
    }
    // Garde-fou : si une categorie est a la fois dans top et disliked
    // (cas theorique : like d'une activite mixte + dislike d'une autre),
    // on retire de disliked.
    for (const c of [...dislikedCategories]) {
      if (topCategories.has(c)) dislikedCategories.delete(c);
    }

    return {
      totalSignals,
      topCategories,
      avgPriceLevel,
      indoorOutdoorPref,
      popularSocialTags,
      dislikedCategories,
    };
  } catch (_e) {
    return null;
  }
}

/**
 * v32 (Smart Recommender Phase 2) — bonus / penalite par candidat selon
 * le profil de gout du user. Cold start : si totalSignals < 3, on retourne 0
 * (la personnalisation requiert un minimum d'historique).
 */
function tasteBonus(
  a: {
    category?: string | null;
    price_level?: number | null;
    is_indoor?: boolean | null;
    is_outdoor?: boolean | null;
    social_tags?: string[] | null;
  },
  profile: UserTasteProfile | null,
): number {
  if (!profile || profile.totalSignals < 3) return 0;
  let bonus = 0;
  const cats = (a.category ?? "")
    .split(",")
    .map((c) => c.trim().toLowerCase())
    .filter(Boolean);

  // 1. Top categories : somme des poids matches, plafonnee a +4.
  let catWeight = 0;
  for (const c of cats) {
    const w = profile.topCategories.get(c);
    if (typeof w === "number") catWeight += w;
  }
  bonus += Math.min(4, catWeight * 4);

  // 2. Disliked categories : -3 si au moins une categorie matchee.
  for (const c of cats) {
    if (profile.dislikedCategories.has(c)) {
      bonus -= 3;
      break;
    }
  }

  // 3. Prix : +2 si dans la plage preferee +/-1.
  if (profile.avgPriceLevel != null && typeof a.price_level === "number") {
    if (Math.abs(a.price_level - profile.avgPriceLevel) <= 1) bonus += 2;
  }

  // 4. Indoor / outdoor pref.
  if (profile.indoorOutdoorPref === "mostly_indoor" && a.is_indoor) bonus += 1;
  if (profile.indoorOutdoorPref === "mostly_outdoor" && a.is_outdoor) bonus += 1;
  // mixed : bonus +1 si l'activite est mixte (indoor ET outdoor)
  if (profile.indoorOutdoorPref === "mixed" && a.is_indoor && a.is_outdoor) {
    bonus += 1;
  }

  // 5. Social tags : +1 si overlap avec les tags populaires.
  if (profile.popularSocialTags.size > 0) {
    for (const t of a.social_tags ?? []) {
      if (profile.popularSocialTags.has(t)) {
        bonus += 1;
        break;
      }
    }
  }

  return bonus;
}

/**
 * v31 (Smart Recommender Phase 1.4) — remplace le dernier pick Gemini par un
 * "surprise" tire au sort dans les candidats classes 5e a 30e. Marque le
 * match_reason avec un emoji 💡 pour que l'UI puisse afficher un badge
 * "À découvrir". L'idee : casser l'effet "toujours les memes" tout en
 * gardant les 2 premiers picks (best matches) intacts.
 */
function injectSurprise(
  recommendations: Array<{ id: number; match_reason: string }>,
  sortedCandidates: Array<{ id: number; title?: string }>,
): Array<{ id: number; match_reason: string }> {
  if (recommendations.length < 3 || sortedCandidates.length < 6) {
    return recommendations;
  }
  const pickedIds = new Set(recommendations.slice(0, 2).map((r) => r.id));
  // Pool : positions 5-30 (index 5 a 29), exclure ce qui a deja ete choisi.
  const pool = sortedCandidates
    .slice(5, 30)
    .filter((c) => !pickedIds.has(c.id));
  if (pool.length === 0) return recommendations;
  const surprise = pool[Math.floor(Math.random() * pool.length)];
  return [
    ...recommendations.slice(0, 2),
    {
      id: surprise.id,
      match_reason: `💡 À découvrir : ${surprise.title ?? "une activité originale"}.`,
    },
  ];
}

function haversineDistanceKm(
  lat1: number,
  lon1: number,
  lat2: number,
  lon2: number,
): number {
  const R = 6371;
  const dLat = ((lat2 - lat1) * Math.PI) / 180;
  const dLon = ((lon2 - lon1) * Math.PI) / 180;
  const a = Math.sin(dLat / 2) * Math.sin(dLat / 2) +
    Math.cos((lat1 * Math.PI) / 180) *
      Math.cos((lat2 * Math.PI) / 180) *
      Math.sin(dLon / 2) *
      Math.sin(dLon / 2);
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
  return R * c;
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
    // v31 : recent_recommendations envoye par le client (lus de user_metadata).
    // Les IDs les plus recents en premier — utilises pour la penalite de
    // recence (anti-repetition).
    const recentRecommendations: number[] = Array.isArray(
        userPrefs.recent_recommendations,
      )
      ? (userPrefs.recent_recommendations as unknown[])
        .filter((n): n is number => typeof n === "number")
      : [];
    // v31 : meteo extraite du contexte pour le scoring meteo.
    const weather = (contextData.weather && typeof contextData.weather === "object")
      ? contextData.weather
      : null;
    // v22 : Filtre canton ('vaud' | 'valais'). Prioritaire sur le rayon.
    const region: string = (userPrefs.region || body.region || "")
      .toString()
      .toLowerCase();

    const userLat: number | null = contextData.location?.latitude ?? null;
    const userLng: number | null = contextData.location?.longitude ?? null;
    // v32 : user_id passe en body (deja le cas, ligne 143 d'activity_service.dart)
    // pour personnaliser le scoring via taste profile.
    const userId: string | null = (typeof body.user_id === "string")
      ? body.user_id
      : null;

    const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
    const supabaseKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
    const geminiKey = Deno.env.get("GEMINI_API_KEY") || "";

    const supabase = createClient(supabaseUrl, supabaseKey);

    // v35 (Subscription enforcement) : lit l'abonnement du user pour appliquer
    // les regles de tier cote serveur (defense en profondeur).
    //   - free     : le client a deja appele consume_free_quiz() pour verifier
    //                le quota. Si le client est compromis, le quota n'est pas
    //                applique mais ce n'est pas critique (le quiz reste).
    //   - regional : on FORCE le filtre region = subscription.selected_region,
    //                meme si le client a envoye autre chose.
    //   - evasion  : on AUTORISE Vaud + Valais (override du filtre region).
    let effectiveRegion: string = region;
    if (userId) {
      try {
        const { data: subRow } = await supabase
          .from("subscriptions")
          .select("tier, selected_region, status, expires_at")
          .eq("user_id", userId)
          .maybeSingle();
        if (subRow) {
          const isPaidActive = (subRow.tier === "regional" || subRow.tier === "evasion")
            && subRow.status === "active"
            && (subRow.expires_at == null || new Date(subRow.expires_at as string) > new Date());
          if (isPaidActive) {
            if (subRow.tier === "regional" && subRow.selected_region) {
              // Force le canton choisi par l'abo Regional.
              effectiveRegion = subRow.selected_region as string;
            } else if (subRow.tier === "evasion") {
              // Evasion : pas de filtre canton (Vaud + Valais).
              effectiveRegion = "";
            }
          }
        }
      } catch (_e) {
        // Echec silencieux : on garde le filtre region envoye par le client.
      }
    }

    let query = supabase
      .from("activities")
      .select(
        "id, title, category, price_level, duration_minutes, description, image_url, features, seasons, social_tags, location_name, is_outdoor, is_indoor, latitude, longitude, date_label, date_start, date_end, recurrence_type, seasonal_months, weekly_days",
      );

    if (categories.length > 0) {
      const catFilter = categories
        .map((c: string) => `category.ilike.%${c.trim()}%`)
        .join(",");
      query = query.or(catFilter);
    }

    // --- Filtre budget ---
    // v19 : si une liste explicite de niveaux est fournie, on filtre dessus
    // (permet les selections non contigues).
    // Sinon, fallback sur price_level <= priceMax (retrocompatibilite v16-v18).
    if (priceLevels.length > 0) {
      query = query.in("price_level", priceLevels);
    } else if (priceMax && priceMax >= 1 && priceMax <= 5) {
      query = query.lte("price_level", priceMax);
    }

    // v20 : Indoor/Outdoor non exclusifs. Une activite "mixte" (is_outdoor=true
    // ET is_indoor=true) est valide dans les deux cas.
    if (environment === "outdoor") {
      query = query.eq("is_outdoor", true);
    } else if (environment === "indoor") {
      query = query.eq("is_indoor", true);
    }

    // v28 : la duree devient un critere SOFT (scoring). On ne filtre plus
    // hard sur le bucket — on garde toutes les durees et on score plus haut
    // les activites qui matchent exactement le bucket choisi. Cela respecte
    // la priorite utilisateur : categories > price > environment > duration > social.
    // (la fonction scoreCandidate plus bas applique +4 si exact, +2 si adjacent)

    // v22 + v35 : Filtre canton. effectiveRegion peut avoir ete force par
    // l'abonnement (regional → selected_region, evasion → ""/no filter).
    if (effectiveRegion === "valais") {
      query = query.not("location_zone", "is", null);
    } else if (effectiveRegion === "vaud") {
      query = query.is("location_zone", null);
    }

    // v28 : on prend une fenetre plus large (100) puisque la duree n'est
    // plus filtree au SQL — le scoring + tri choisira les meilleurs.
    query = query.limit(100);

    const { data: rawCandidates, error } = await query;
    if (error) throw error;

    let candidates = rawCandidates || [];

    // v24 : filtre temporel — exclut les activites echues / hors-fenetre /
    // hors-saison. Les activites sans contrainte temporelle restent visibles.
    const nowDate = new Date();
    candidates = candidates.filter((a) => isProposableNow(a as any, nowDate));

    // v22 + v35 : si region (effective) est definie, on ignore le rayon (canton-wide).
    if (
      !effectiveRegion &&
      radiusKm !== null &&
      radiusKm < 999 &&
      userLat !== null &&
      userLng !== null
    ) {
      candidates = candidates.filter((a) => {
        if (a.latitude == null || a.longitude == null) return true;
        const d = haversineDistanceKm(
          userLat,
          userLng,
          a.latitude,
          a.longitude,
        );
        return d <= radiusKm;
      });
    }

    if (!candidates || candidates.length === 0) {
      return new Response(
        JSON.stringify({
          recommendations: [],
          global_comment:
            "Aucune activite ne correspond exactement a vos criteres. Essayez d'elargir votre rayon de recherche, votre budget ou vos categories.",
        }),
        { headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }

    // v32 : Smart Recommender Phase 2 — scoring personnalise.
    // Composants (au-dela des hard filters categories/price/environment) :
    //   - bonus categories supplementaires (v28)
    //   - duration scoring soft (v28)
    //   - social tag match (v28)
    //   - QUALITE       : favoris + ratings (v31, bonus jusqu'a +3)
    //   - METEO         : indoor/outdoor selon temp + weather_code (v31, +/-3)
    //   - RECENCE       : penalite si deja recommande recemment (v31, -2 a -5)
    //   - PERSO PROFIL  : top categories + prix + indoor/outdoor + tags (v32, +/- 7)
    const candidateIds = candidates.map((c) => c.id as number);
    // Charge en parallele : qualite agregee globale ET profil de gout du user.
    const [qualityBonusMap, tasteProfile] = await Promise.all([
      fetchQualityBonus(supabase, candidateIds),
      computeUserTasteProfile(supabase, userId),
    ]);

    candidates = candidates
      .map((a) => {
        const baseScore = scoreCandidate(a, { categories, duration, social });
        const qBonus = qualityBonusMap.get(a.id as number) ?? 0;
        const wBonus = weatherBonus(a as any, weather as any);
        const rPenalty = recencyPenalty(a.id as number, recentRecommendations);
        const tBonus = tasteBonus(a as any, tasteProfile);
        return {
          ...a,
          _score: baseScore + qBonus + wBonus + rPenalty + tBonus,
        };
      })
      .sort((a, b) => (b._score as number) - (a._score as number));
    // On garde au max 50 candidats apres tri pour limiter la taille du
    // prompt Gemini (ne change rien tant que la base est < 100 entrees).
    if (candidates.length > 50) candidates = candidates.slice(0, 50);

    // Niveaux effectivement "demandes" par l'utilisateur : soit la liste
    // explicite (v19), soit la plage deduite de priceMax (retrocompat).
    const userSelectedLevels: Set<number> = priceLevels.length > 0
      ? new Set(priceLevels)
      : new Set(Array.from({ length: priceMax }, (_, i) => i + 1));

    let recommendations: Array<{ id: number; match_reason: string }> = [];
    let globalComment = "";

    if (geminiKey) {
      const prompt = buildGeminiPrompt(candidates, {
        categories,
        priceMax,
        priceLevels,
        environment,
        social,
        duration,
      });

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
          const parsed = parseGeminiResponse(text, candidates);
          if (parsed.recommendations.length > 0) {
            recommendations = parsed.recommendations;
            globalComment = parsed.globalComment;
          }
        }
      } catch (_e) {
        // Gemini indisponible -> fallback
      }
    }

    if (recommendations.length === 0) {
      // Fallback sans Gemini : top 3 candidats en alternant les niveaux de prix
      const diversified = diversifyByPriceLevel(candidates, 3);
      recommendations = diversified.map((a) => ({
        id: a.id,
        match_reason: buildMatchReason(a, categories, priceMax),
      }));
      globalComment = buildGlobalComment(categories, priceMax, priceLevels);
    } else {
      // v19 : garde-fou anti-monoculture. Si Gemini a choisi 3 activites du
      // meme tier budget mais que l'utilisateur avait demande plusieurs tiers
      // ET que d'autres tiers existent dans les candidats, on remplace la
      // derniere recommandation par une activite d'un autre tier.
      recommendations = ensurePriceDiversity(
        recommendations,
        candidates,
        userSelectedLevels,
      );
    }

    // v31 (Phase 1.4) : injection du "surprise pick" en position 3.
    // Garde les 2 meilleurs picks intacts, remplace le 3eme par une
    // activite tiree au sort dans les positions 5-30 du classement.
    // Marquee "💡 À découvrir" pour que le client puisse afficher un badge.
    recommendations = injectSurprise(recommendations, candidates as any);

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

const PRICE_LABELS: Record<number, string> = {
  1: "Gratuit",
  2: "1-20 CHF",
  3: "20-50 CHF",
  4: "50-100 CHF",
  5: "100+ CHF",
};

// Retourne N candidats en alternant les niveaux de prix (round-robin).
// Utilise en fallback quand Gemini n'est pas disponible.
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

// Si les 3 recommandations Gemini sont toutes du meme tier ET que plusieurs
// tiers etaient demandes ET disponibles, on swap la derniere pour un autre tier.
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

  // Niveaux disponibles dans les candidats ET demandes par l'utilisateur
  const availableLevels = new Set(
    candidates
      .map((c) => c.price_level)
      .filter((lvl) => userSelectedLevels.has(lvl)),
  );

  // Tout va bien si on a deja au moins 2 niveaux distincts (ou si un seul etait dispo)
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

  // v33 : explicite la regle multi-categorie selon le nombre demande.
  const nCat = prefs.categories.length;
  const multiCatRule = nCat === 1
    ? `REGLE CATEGORIE : l'utilisateur a choisi 1 seule categorie (${prefs.categories[0]}). Toutes les activites de la liste la contiennent deja — choisis simplement les 3 meilleures.`
    : nCat >= 2
    ? `REGLE CATEGORIE PRIORITAIRE : l'utilisateur a choisi ${nCat} categories (${prefs.categories.join(", ")}). PRIVILEGIE FORTEMENT les activites qui en couvrent PLUSIEURS a la fois. Une activite qui matche les ${nCat} categories doit toujours etre prefere a une activite qui n'en matche qu'une, meme si cette derniere semble plus attractive sur d'autres criteres. Tu peux quand meme inclure une activite mono-categorie si elle est exceptionnelle.`
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

Voici les activites disponibles (deja filtrees par categorie, budget et rayon
de recherche, triees par score de pertinence DECROISSANT) :
${activitiesList}

Selectionne les 3 meilleures activites pour cet utilisateur.

REGLE DE TON pour match_reason (TRES IMPORTANT) :
Le match_reason est affiche dans une banniere bleue sous le titre de l'activite.
Il doit etre une phrase CONVERSATIONNELLE et CHALEUREUSE qui donne envie, PAS une
liste d'attributs.

  ✅ STYLE A ADOPTER : question ou suggestion directe avec "tu",
     comme un pote qui te conseille. Une seule phrase, max 15 mots.
     Exemples :
       "Envie d'un break tranquille ? Pose-toi au bord du lac."
       "Pour souffler en famille un dimanche, c'est ici."
       "Une vraie pause culture, sans se ruiner."
       "Si tu cherches un bon resto sympa entre amis, fonce."
       "Parfait pour bouger sans planifier toute une journee."

  ❌ A EVITER ABSOLUMENT :
       - Listes d'attributs separes par virgules (ex : "Gratuit, relax, parfait pour solo")
       - Mots techniques : "score", "match", "pertinence", "recommande"
       - Ton catalogue / fiche produit
       - Repeter le titre de l'activite
       - Mentionner explicitement la categorie (ex : "Activite nature")

global_comment doit etre une phrase d'accroche generale courte et chaleureuse,
sans jargon, max 12 mots (ex : "Voici tes 3 idees pour aujourd'hui." ou
"De quoi te poser un peu cette semaine.").

Reponds UNIQUEMENT en JSON valide, sans markdown, sans explication :
{
  "recommendations": [
    {"id": <id>, "match_reason": "<phrase conversationnelle avec tu, max 15 mots>"},
    {"id": <id>, "match_reason": "<phrase conversationnelle avec tu, max 15 mots>"},
    {"id": <id>, "match_reason": "<phrase conversationnelle avec tu, max 15 mots>"}
  ],
  "global_comment": "<phrase d'accroche chaleureuse, max 12 mots>"
}`;
}

function parseGeminiResponse(
  text: string,
  candidates: Record<string, unknown>[],
): {
  recommendations: Array<{ id: number; match_reason: string }>;
  globalComment: string;
} {
  try {
    const jsonMatch = text.match(/\{[\s\S]*\}/);
    if (!jsonMatch) return { recommendations: [], globalComment: "" };

    const parsed = JSON.parse(jsonMatch[0]);
    const validIds = new Set(candidates.map((c) => c.id));

    const recommendations = (parsed.recommendations || [])
      .filter((r: { id: number }) => validIds.has(r.id))
      .slice(0, 3)
      .map((r: { id: number; match_reason: string }) => ({
        id: r.id,
        match_reason: r.match_reason || "",
      }));

    return { recommendations, globalComment: parsed.global_comment || "" };
  } catch (_e) {
    return { recommendations: [], globalComment: "" };
  }
}

/**
 * v34 : fallbacks conversationnels (ton "ami qui te conseille") utilises
 * quand Gemini est indisponible. Chaque appel choisit aleatoirement parmi
 * 5 templates pour eviter la repetition robotique.
 */
function buildMatchReason(
  activity: Record<string, unknown>,
  categories: string[],
  _priceMax: number,
): string {
  const cat = categories[0] || "";
  const templates = [
    `Une bonne idee pour aujourd'hui, vraiment.`,
    `Pose-toi, c'est ce qu'il te faut.`,
    `Si tu cherches a changer d'air, fonce.`,
    `Un bon plan pour souffler un peu.`,
    cat
      ? `Envie de ${_friendlyCat(cat)} ? Ca tombe bien.`
      : `Une vraie pause qui fait du bien.`,
  ];
  return templates[Math.floor(Math.random() * templates.length)];
}

function buildGlobalComment(
  _categories: string[],
  _priceMax: number,
  _priceLevels: number[],
): string {
  const templates = [
    `Voici tes 3 idees pour aujourd'hui.`,
    `Petite selection rien que pour toi.`,
    `De quoi te poser un peu cette semaine.`,
    `Trois bons plans, choisis ton humeur.`,
    `Allez, on bouge ?`,
  ];
  return templates[Math.floor(Math.random() * templates.length)];
}

/** Convertit la cle DB en mot fluide pour le ton conversationnel. */
function _friendlyCat(cat: string): string {
  switch (cat.toLowerCase()) {
    case "nature": return "nature";
    case "culture": return "culture";
    case "gastronomy": return "bien manger";
    case "sport": return "bouger";
    case "adventure": return "sensations";
    case "relax": return "te detendre";
    case "fun": return "rigoler";
    case "event": return "decouvrir un evenement";
    default: return cat;
  }
}
