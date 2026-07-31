// Whateka - Edge Function geocode-place v3
//
// Recoit { query: string } (titre + lieu saisis dans le formulaire de
// soumission d'activite) et retourne { lat, lng, display_name } pour
// pre-remplir automatiquement les coordonnees.
//
// v3 (fix bug "geolocation auto introuvable") : la v2 dependait uniquement
// de Google Places API (New), via la cle GOOGLE_MAPS_API_KEY (secret
// Supabase). Si cette cle est absente, expiree, ou si l'API Places /
// facturation GCP a un probleme, TOUTE requete echouait (500/502) sans
// filet de secours -> "impossible de trouver la geolocalisation automatique"
// pour l'utilisateur. On garde Google Places en 1re intention (meilleure
// precision sur les POI touristiques : gorges, musees, remontees
// mecaniques...), mais on bascule desormais automatiquement sur Nominatim
// (OpenStreetMap, gratuit, sans cle) si Google echoue pour n'importe quelle
// raison (cle manquante/invalide, quota, panne, aucun resultat). La fonction
// ne peut donc plus etre totalement indisponible a cause d'un probleme cote
// cle API Google.
//
// POST /functions/v1/geocode-place
// Body : { "query": "Gorges du Chauderon, Montreux" }
// Reponse : { "lat": 46.4368, "lng": 6.9250, "display_name": "..." }

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

type GeocodeResult = { lat: number; lng: number; display_name: string };

/** 1re intention : Google Places API (New) - Text Search. */
async function geocodeWithGoogle(query: string): Promise<GeocodeResult | null> {
  const apiKey = Deno.env.get("GOOGLE_MAPS_API_KEY");
  if (!apiKey) return null;

  try {
    const resp = await fetch("https://places.googleapis.com/v1/places:searchText", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-Goog-Api-Key": apiKey,
        "X-Goog-FieldMask":
          "places.displayName,places.formattedAddress,places.location",
      },
      body: JSON.stringify({
        textQuery: query,
        regionCode: "CH",
        languageCode: "fr",
      }),
    });
    if (!resp.ok) return null;

    const data = await resp.json();
    const places = data.places as Array<{
      displayName?: { text?: string };
      formattedAddress?: string;
      location?: { latitude?: number; longitude?: number };
    }> | undefined;
    if (!places || places.length === 0) return null;

    const first = places[0];
    const lat = first.location?.latitude;
    const lng = first.location?.longitude;
    if (typeof lat !== "number" || typeof lng !== "number") return null;

    const name = first.displayName?.text || "";
    const addr = first.formattedAddress || "";
    return { lat, lng, display_name: name && addr ? `${name}, ${addr}` : (name || addr) };
  } catch (_e) {
    return null;
  }
}

// Viewbox large autour de Vaud/Valais (ouest, nord, est, sud), utilise en
// biais non-exclusif (bounded=0) pour prioriser les resultats locaux sans
// exclure un lieu hors de cette zone.
const VD_VS_VIEWBOX = "6.0,47.1,8.1,45.8";
const USER_AGENT = "whateka-app/1.0 (contact@whateka.ch)";

/** Filet de secours : Nominatim (OpenStreetMap), gratuit, sans cle API. */
async function geocodeWithNominatim(query: string): Promise<GeocodeResult | null> {
  try {
    const url = new URL("https://nominatim.openstreetmap.org/search");
    url.searchParams.set("q", query);
    url.searchParams.set("format", "jsonv2");
    url.searchParams.set("limit", "1");
    url.searchParams.set("viewbox", VD_VS_VIEWBOX);
    url.searchParams.set("bounded", "0");

    const res = await fetch(url, {
      headers: { "User-Agent": USER_AGENT, "Accept-Language": "fr" },
    });
    if (!res.ok) return null;

    const results = await res.json();
    if (!Array.isArray(results) || results.length === 0) return null;

    const best = results[0];
    const lat = parseFloat(best.lat);
    const lng = parseFloat(best.lon);
    if (Number.isNaN(lat) || Number.isNaN(lng)) return null;

    return { lat, lng, display_name: best.display_name ?? query };
  } catch (_e) {
    return null;
  }
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const body = await req.json().catch(() => ({}));
    const query = (body?.query as string | undefined)?.trim();
    if (!query) {
      return new Response(
        JSON.stringify({ error: "Le champ 'query' est requis (ex: 'Nom de l'activite, Lieu')." }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }

    const result =
      (await geocodeWithGoogle(query)) ?? (await geocodeWithNominatim(query));

    if (!result) {
      return new Response(
        JSON.stringify({ error: "Aucun lieu trouve pour cette recherche.", query }),
        { status: 404, headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }

    return new Response(JSON.stringify(result), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  } catch (err: unknown) {
    const msg = err instanceof Error ? err.message : String(err);
    return new Response(JSON.stringify({ error: msg }), {
      status: 500,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }
});
