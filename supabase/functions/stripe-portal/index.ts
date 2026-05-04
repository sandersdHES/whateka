// Whateka — Edge Function : stripe-portal
// =====================================================================
// Cree une session Stripe Customer Portal pour qu'un user puisse :
//   - Mettre a jour sa carte
//   - Annuler son abonnement
//   - Voir l'historique de facturation
//
// Body : optionnel { return_url: "..." }
// Reponse : { url: "https://billing.stripe.com/..." }
//
// Pre-requis :
//   - Stripe Customer Portal active dans le dashboard Stripe (Settings → Billing → Customer Portal)
//   - SUPABASE secrets : STRIPE_SECRET_KEY, APP_BASE_URL
// =====================================================================

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }
  try {
    const stripeKey = Deno.env.get("STRIPE_SECRET_KEY");
    const appBaseUrl = Deno.env.get("APP_BASE_URL") ?? "https://whateka.ch";
    const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
    const supabaseKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
    if (!stripeKey) {
      return jsonError(500, "STRIPE_SECRET_KEY non configure");
    }

    const authHeader = req.headers.get("authorization");
    if (!authHeader) return jsonError(401, "Missing authorization");
    const token = authHeader.replace("Bearer ", "");

    const supabase = createClient(supabaseUrl, supabaseKey);
    const { data: userData, error: uErr } = await supabase.auth.getUser(token);
    if (uErr || !userData.user) return jsonError(401, "Invalid token");

    const { data: userInfo } = await supabase.auth.admin.getUserById(userData.user.id);
    const customerId = userInfo.user?.user_metadata?.stripe_customer_id as string | undefined;
    if (!customerId) {
      return jsonError(400, "Aucun customer Stripe trouve. Souscris d'abord.");
    }

    let body: any = {};
    try {
      body = await req.json();
    } catch {/* ignore : body optionnel */}
    const returnUrl = body?.return_url ?? `${appBaseUrl}/profile`;

    const params = new URLSearchParams();
    params.set("customer", customerId);
    params.set("return_url", returnUrl);

    const res = await fetch("https://api.stripe.com/v1/billing_portal/sessions", {
      method: "POST",
      headers: {
        "Authorization": `Bearer ${stripeKey}`,
        "Content-Type": "application/x-www-form-urlencoded",
      },
      body: params,
    });
    if (!res.ok) {
      const txt = await res.text();
      console.error("Portal session error:", txt);
      return jsonError(502, `Stripe portal error: ${txt.slice(0, 200)}`);
    }
    const session = await res.json();
    return new Response(
      JSON.stringify({ url: session.url }),
      { headers: { ...corsHeaders, "Content-Type": "application/json" } },
    );
  } catch (err: unknown) {
    const msg = err instanceof Error ? err.message : String(err);
    return jsonError(500, msg);
  }
});

function jsonError(status: number, message: string) {
  return new Response(JSON.stringify({ error: message }), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}
