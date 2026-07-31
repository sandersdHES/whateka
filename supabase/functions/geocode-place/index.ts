// Whateka - Edge Function geocode-place
//
// Recoit { query: string } (titre + lieu saisis dans le formulaire de
// soumission d'activite) et retourne { lat, lng, display_name } pour
// pre-remplir automatiquement les coordonnees.
//
// Utilise l'API de geocodage Nominatim (OpenStreetMap), gratuite et sans
// cle API a provisionner. La recherche est biaisee (pas restreinte) vers la
// Suisse romande via un viewbox englobant Vaud/Valais, pour privilegier les
// resultats locaux sans exclure un lieu hors de cette zone.
//
// Nominatim exige un User-Agent identifiant l'application (politique
// d'usage : https://operations.osmfoundation.org/policies/nominatim/).

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "POST, GET, OPTIONS",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

// Viewbox large autour de Vaud/Valais (ouest, nord, est, sud), utilise en
// biais non-exclusif (bounded=0) pour prioriser les resultats locaux.
const VD_VS_VIEWBOX = "6.0,47.1,8.1,45.8";

const NOMINATIM_URL = "https://nominatim.openstreetmap.org/search";
const USER_AGENT = "whateka-app/1.0 (contact@whateka.ch)";

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const body = await req.json();
    const query = (body?.query ?? "").toString().trim();

    if (!query) {
      return new Response(
        JSON.stringify({ error: "Le champ 'query' est requis." }),
        {
          headers: { ...corsHeaders, "Content-Type": "application/json" },
          status: 400,
        },
      );
    }

    const url = new URL(NOMINATIM_URL);
    url.searchParams.set("q", query);
    url.searchParams.set("format", "jsonv2");
    url.searchParams.set("limit", "1");
    url.searchParams.set("viewbox", VD_VS_VIEWBOX);
    url.searchParams.set("bounded", "0");

    const res = await fetch(url, {
      headers: { "User-Agent": USER_AGENT, "Accept-Language": "fr" },
    });

    if (!res.ok) {
      return new Response(
        JSON.stringify({ error: `Nominatim a repondu ${res.status}.` }),
        {
          headers: { ...corsHeaders, "Content-Type": "application/json" },
          status: 502,
        },
      );
    }

    const results = await res.json();
    if (!Array.isArray(results) || results.length === 0) {
      return new Response(
        JSON.stringify({ error: "Aucun lieu trouve pour cette recherche." }),
        {
          headers: { ...corsHeaders, "Content-Type": "application/json" },
          status: 404,
        },
      );
    }

    const best = results[0];
    const lat = parseFloat(best.lat);
    const lng = parseFloat(best.lon);
    if (Number.isNaN(lat) || Number.isNaN(lng)) {
      return new Response(
        JSON.stringify({ error: "Reponse de geocodage invalide." }),
        {
          headers: { ...corsHeaders, "Content-Type": "application/json" },
          status: 502,
        },
      );
    }

    return new Response(
      JSON.stringify({
        lat,
        lng,
        display_name: best.display_name ?? query,
      }),
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
