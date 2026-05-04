// Whateka — Edge Function : stripe-create-checkout
// =====================================================================
// Cree une session Stripe Checkout pour un user authentifie. Web only
// (interdit par Apple sur iOS).
//
// Body de la requete :
//   {
//     tier: "regional" | "evasion",
//     return_url: "https://whateka.ch/profile?stripe=success" (optionnel)
//   }
//
// Reponse :
//   { url: "https://checkout.stripe.com/c/pay/cs_..." }
//   ou { error: "..." }
//
// Pre-requis (a configurer une fois) :
//   - SUPABASE secrets :
//       STRIPE_SECRET_KEY          (sk_test_... ou sk_live_...)
//       STRIPE_PRICE_REGIONAL      (price_... du produit Regional)
//       STRIPE_PRICE_EVASION       (price_... du produit Evasion)
//       APP_BASE_URL               (ex : https://whateka.ch)
//
// Le Stripe customer_id est sauve dans subscriptions.stripe_subscription_id
// apres confirmation par le webhook.
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
    const priceRegional = Deno.env.get("STRIPE_PRICE_REGIONAL");
    const priceEvasion = Deno.env.get("STRIPE_PRICE_EVASION");
    const appBaseUrl = Deno.env.get("APP_BASE_URL") ?? "https://whateka.ch";
    const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
    const supabaseKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

    if (!stripeKey || !priceRegional || !priceEvasion) {
      return jsonError(500,
        "Stripe non configure. Verifie STRIPE_SECRET_KEY, STRIPE_PRICE_REGIONAL, STRIPE_PRICE_EVASION dans les secrets Supabase.");
    }

    // Auth : recupere l'user depuis le JWT.
    const authHeader = req.headers.get("authorization");
    if (!authHeader) return jsonError(401, "Missing authorization header");
    const token = authHeader.replace("Bearer ", "");

    const supabase = createClient(supabaseUrl, supabaseKey);
    const { data: userData, error: userErr } = await supabase.auth.getUser(token);
    if (userErr || !userData.user) {
      return jsonError(401, "Invalid token");
    }
    const user = userData.user;

    const body = await req.json();
    const tier = (body.tier as string)?.toLowerCase();
    if (tier !== "regional" && tier !== "evasion") {
      return jsonError(400, "Invalid tier. Must be 'regional' or 'evasion'.");
    }
    const priceId = tier === "regional" ? priceRegional : priceEvasion;
    const returnUrlBase = (body.return_url as string) ?? appBaseUrl;

    // Recupere ou cree le Stripe Customer pour cet user.
    const customerId = await getOrCreateStripeCustomer(
      stripeKey,
      supabase,
      user.id,
      user.email ?? "",
    );

    // Cree la session Checkout en mode subscription, 7j d'essai.
    const successUrl = `${returnUrlBase}?stripe=success&session_id={CHECKOUT_SESSION_ID}`;
    const cancelUrl = `${returnUrlBase}?stripe=canceled`;

    const params = new URLSearchParams();
    params.set("mode", "subscription");
    params.set("customer", customerId);
    params.set("line_items[0][price]", priceId);
    params.set("line_items[0][quantity]", "1");
    params.set("subscription_data[trial_period_days]", "7");
    // Important : on attache le user_id pour que le webhook fasse la liaison.
    params.set("subscription_data[metadata][user_id]", user.id);
    params.set("subscription_data[metadata][tier]", tier);
    params.set("metadata[user_id]", user.id);
    params.set("metadata[tier]", tier);
    params.set("success_url", successUrl);
    params.set("cancel_url", cancelUrl);
    params.set("allow_promotion_codes", "true");
    params.set("locale", "fr");

    const stripeRes = await fetch("https://api.stripe.com/v1/checkout/sessions", {
      method: "POST",
      headers: {
        "Authorization": `Bearer ${stripeKey}`,
        "Content-Type": "application/x-www-form-urlencoded",
      },
      body: params,
    });

    if (!stripeRes.ok) {
      const errText = await stripeRes.text();
      console.error("Stripe API error:", errText);
      return jsonError(502, `Stripe error: ${errText.slice(0, 200)}`);
    }

    const session = await stripeRes.json();
    return new Response(
      JSON.stringify({ url: session.url, session_id: session.id }),
      { headers: { ...corsHeaders, "Content-Type": "application/json" } },
    );
  } catch (err: unknown) {
    const msg = err instanceof Error ? err.message : String(err);
    console.error("create-checkout error:", msg);
    return jsonError(500, msg);
  }
});

/**
 * Recupere le Stripe customer_id de l'user (stocke en user_metadata) ou en
 * cree un nouveau via Stripe Customers API.
 * Utilise user_metadata.stripe_customer_id pour persistance.
 */
async function getOrCreateStripeCustomer(
  stripeKey: string,
  supabase: ReturnType<typeof createClient>,
  userId: string,
  email: string,
): Promise<string> {
  // 1. Lire le metadata de l'user.
  const { data: userInfo } = await supabase.auth.admin.getUserById(userId);
  const existing = userInfo.user?.user_metadata?.stripe_customer_id as string | undefined;
  if (existing && existing.startsWith("cus_")) {
    return existing;
  }

  // 2. Creer un nouveau customer.
  const params = new URLSearchParams();
  if (email) params.set("email", email);
  params.set("metadata[supabase_user_id]", userId);
  const res = await fetch("https://api.stripe.com/v1/customers", {
    method: "POST",
    headers: {
      "Authorization": `Bearer ${stripeKey}`,
      "Content-Type": "application/x-www-form-urlencoded",
    },
    body: params,
  });
  if (!res.ok) {
    throw new Error(`Stripe customer create failed: ${await res.text()}`);
  }
  const customer = await res.json();
  const customerId = customer.id as string;

  // 3. Sauve le customer_id dans user_metadata pour les futures invocations.
  await supabase.auth.admin.updateUserById(userId, {
    user_metadata: {
      ...(userInfo.user?.user_metadata ?? {}),
      stripe_customer_id: customerId,
    },
  });

  return customerId;
}

function jsonError(status: number, message: string) {
  return new Response(JSON.stringify({ error: message }), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}
