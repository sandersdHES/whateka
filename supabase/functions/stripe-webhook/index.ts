// Whateka — Edge Function : stripe-webhook
// =====================================================================
// Recoit les events Stripe et met a jour la table `subscriptions` en DB.
//
// Events traites :
//   - checkout.session.completed       → trial commence
//   - customer.subscription.updated    → renouvellement, status change
//   - customer.subscription.deleted    → cancellation effective
//   - invoice.paid                     → paiement reussi (renouvellement)
//   - invoice.payment_failed           → paiement echoue
//
// Pre-requis :
//   - SUPABASE secrets :
//       STRIPE_SECRET_KEY            (sk_test_... ou sk_live_...)
//       STRIPE_WEBHOOK_SECRET        (whsec_... du webhook config)
//       STRIPE_PRICE_REGIONAL        (pour mapper price_id -> tier)
//       STRIPE_PRICE_EVASION
//
// Configuration Stripe :
//   - Crer un webhook endpoint pointant vers cette URL
//   - Selectionner les events listes ci-dessus
//   - Copier le signing secret (whsec_...) dans STRIPE_WEBHOOK_SECRET
// =====================================================================

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

serve(async (req) => {
  if (req.method !== "POST") {
    return new Response("Method not allowed", { status: 405 });
  }

  const stripeKey = Deno.env.get("STRIPE_SECRET_KEY");
  const webhookSecret = Deno.env.get("STRIPE_WEBHOOK_SECRET");
  const priceRegional = Deno.env.get("STRIPE_PRICE_REGIONAL");
  const priceEvasion = Deno.env.get("STRIPE_PRICE_EVASION");
  const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
  const supabaseKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

  if (!stripeKey || !webhookSecret) {
    console.error("Missing Stripe secrets.");
    return new Response("Server misconfigured", { status: 500 });
  }

  // 1. Verifier la signature Stripe (anti-forgery).
  const signature = req.headers.get("stripe-signature");
  if (!signature) return new Response("Missing signature", { status: 400 });

  const rawBody = await req.text();
  const valid = await verifyStripeSignature(rawBody, signature, webhookSecret);
  if (!valid) {
    console.error("Invalid Stripe signature");
    return new Response("Invalid signature", { status: 400 });
  }

  let event: any;
  try {
    event = JSON.parse(rawBody);
  } catch {
    return new Response("Invalid JSON", { status: 400 });
  }

  console.log(`Stripe event received: ${event.type}`);
  const supabase = createClient(supabaseUrl, supabaseKey);

  try {
    switch (event.type) {
      case "checkout.session.completed":
        await handleCheckoutCompleted(supabase, stripeKey, event.data.object,
          priceRegional ?? "", priceEvasion ?? "");
        break;
      case "customer.subscription.updated":
        await handleSubscriptionUpdated(supabase, event.data.object,
          priceRegional ?? "", priceEvasion ?? "");
        break;
      case "customer.subscription.deleted":
        await handleSubscriptionDeleted(supabase, event.data.object);
        break;
      case "invoice.paid":
        await handleInvoicePaid(supabase, event.data.object);
        break;
      case "invoice.payment_failed":
        await handleInvoiceFailed(supabase, event.data.object);
        break;
      default:
        console.log(`Unhandled event type: ${event.type}`);
    }
    return new Response(JSON.stringify({ received: true }), {
      status: 200,
      headers: { "Content-Type": "application/json" },
    });
  } catch (err: unknown) {
    const msg = err instanceof Error ? err.message : String(err);
    console.error(`Error handling ${event.type}:`, msg);
    return new Response(`Error: ${msg}`, { status: 500 });
  }
});

// ---------------------------------------------------------------------
// Event handlers
// ---------------------------------------------------------------------

async function handleCheckoutCompleted(
  supabase: ReturnType<typeof createClient>,
  stripeKey: string,
  session: any,
  priceRegional: string,
  priceEvasion: string,
) {
  const userId = session.metadata?.user_id || session.subscription_data?.metadata?.user_id;
  const subscriptionId = session.subscription as string | null;
  if (!userId) {
    console.warn("checkout.completed without user_id in metadata");
    return;
  }
  if (!subscriptionId) {
    // Peut arriver si mode = payment au lieu de subscription. Skip.
    return;
  }

  // Charge la subscription Stripe pour avoir tier + dates.
  const sub = await fetchStripeSubscription(stripeKey, subscriptionId);
  const tier = priceIdToTier(sub.items.data[0]?.price?.id, priceRegional, priceEvasion);
  if (!tier) {
    console.warn(`Unknown price_id : ${sub.items.data[0]?.price?.id}`);
    return;
  }

  await upsertSubscription(supabase, userId, {
    tier,
    stripe_subscription_id: subscriptionId,
    source: "stripe",
    status: sub.status === "active" || sub.status === "trialing" ? "active" : "canceled",
    trial_ends_at: sub.trial_end ? new Date(sub.trial_end * 1000).toISOString() : null,
    expires_at: new Date(sub.current_period_end * 1000).toISOString(),
  });
  console.log(`User ${userId} subscribed to ${tier} via Stripe`);
}

async function handleSubscriptionUpdated(
  supabase: ReturnType<typeof createClient>,
  sub: any,
  priceRegional: string,
  priceEvasion: string,
) {
  const userId = sub.metadata?.user_id;
  if (!userId) {
    console.warn("subscription.updated without user_id in metadata");
    return;
  }
  const tier = priceIdToTier(sub.items.data[0]?.price?.id, priceRegional, priceEvasion);
  if (!tier) return;

  const status = sub.cancel_at_period_end
    ? "canceled" // marque comme cancele mais reste actif jusqu'au end
    : (sub.status === "active" || sub.status === "trialing" ? "active" : "expired");

  await upsertSubscription(supabase, userId, {
    tier,
    stripe_subscription_id: sub.id,
    source: "stripe",
    status,
    canceled_at: sub.canceled_at
      ? new Date(sub.canceled_at * 1000).toISOString()
      : null,
    trial_ends_at: sub.trial_end ? new Date(sub.trial_end * 1000).toISOString() : null,
    expires_at: new Date(sub.current_period_end * 1000).toISOString(),
  });
  console.log(`User ${userId} subscription updated (${status})`);
}

async function handleSubscriptionDeleted(
  supabase: ReturnType<typeof createClient>,
  sub: any,
) {
  const userId = sub.metadata?.user_id;
  if (!userId) return;
  // Subscription est terminee : revenir a free.
  await supabase.from("subscriptions").update({
    tier: "free",
    status: "expired",
    canceled_at: new Date().toISOString(),
    expires_at: new Date().toISOString(),
    selected_region: null,
  }).eq("user_id", userId);
  console.log(`User ${userId} downgraded to free (subscription deleted)`);
}

async function handleInvoicePaid(
  supabase: ReturnType<typeof createClient>,
  invoice: any,
) {
  const subId = invoice.subscription;
  if (!subId) return;
  // Met a jour expires_at pour reporter la fin de periode.
  if (invoice.lines?.data?.[0]?.period?.end) {
    await supabase.from("subscriptions").update({
      expires_at: new Date(invoice.lines.data[0].period.end * 1000).toISOString(),
      status: "active",
    }).eq("stripe_subscription_id", subId);
  }
}

async function handleInvoiceFailed(
  supabase: ReturnType<typeof createClient>,
  invoice: any,
) {
  const subId = invoice.subscription;
  if (!subId) return;
  // Note : Stripe retentera. On marque pas immediatement comme expired.
  // On loggue pour qu'un admin puisse investiguer.
  console.warn(`Payment failed for subscription ${subId}, customer ${invoice.customer}`);
}

// ---------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------

function priceIdToTier(
  priceId: string | undefined,
  priceRegional: string,
  priceEvasion: string,
): "regional" | "evasion" | null {
  if (priceId === priceRegional) return "regional";
  if (priceId === priceEvasion) return "evasion";
  return null;
}

async function fetchStripeSubscription(stripeKey: string, id: string): Promise<any> {
  const res = await fetch(`https://api.stripe.com/v1/subscriptions/${id}`, {
    headers: { "Authorization": `Bearer ${stripeKey}` },
  });
  if (!res.ok) throw new Error(`Stripe subscription fetch failed: ${await res.text()}`);
  return res.json();
}

async function upsertSubscription(
  supabase: ReturnType<typeof createClient>,
  userId: string,
  patch: Record<string, unknown>,
) {
  // Insert si pas de ligne, sinon update. Utilise ON CONFLICT (user_id).
  const { error } = await supabase
    .from("subscriptions")
    .upsert({ user_id: userId, ...patch }, { onConflict: "user_id" });
  if (error) {
    console.error("Upsert subscription error:", error);
    throw error;
  }
}

/**
 * Verifie la signature Stripe (HMAC SHA256) du webhook.
 * Format header : "t=timestamp,v1=signature[,v0=...]"
 */
async function verifyStripeSignature(
  payload: string,
  signatureHeader: string,
  secret: string,
): Promise<boolean> {
  try {
    const parts = signatureHeader.split(",").reduce<Record<string, string>>((acc, kv) => {
      const [k, v] = kv.split("=");
      acc[k] = v;
      return acc;
    }, {});
    const timestamp = parts["t"];
    const signature = parts["v1"];
    if (!timestamp || !signature) return false;

    // Verifie qu'on est dans une fenetre de 5 minutes (anti-replay).
    const now = Math.floor(Date.now() / 1000);
    if (Math.abs(now - parseInt(timestamp, 10)) > 300) return false;

    const signedPayload = `${timestamp}.${payload}`;
    const enc = new TextEncoder();
    const key = await crypto.subtle.importKey(
      "raw",
      enc.encode(secret),
      { name: "HMAC", hash: "SHA-256" },
      false,
      ["sign"],
    );
    const hmac = await crypto.subtle.sign("HMAC", key, enc.encode(signedPayload));
    const expected = Array.from(new Uint8Array(hmac))
      .map((b) => b.toString(16).padStart(2, "0"))
      .join("");
    // Comparaison constante-time.
    if (signature.length !== expected.length) return false;
    let diff = 0;
    for (let i = 0; i < signature.length; i++) {
      diff |= signature.charCodeAt(i) ^ expected.charCodeAt(i);
    }
    return diff === 0;
  } catch (err) {
    console.error("Signature verification error:", err);
    return false;
  }
}
