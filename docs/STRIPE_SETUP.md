# 💳 Setup Stripe — Phase 2 du système d'abonnement

Cette doc te guide pour configurer Stripe et activer les paiements web pour les abonnements **Régional** (3 CHF) et **Évasion** (5 CHF).

⚠️ **Attention** : Stripe est **interdit sur iOS** par Apple. Cette intégration fonctionne **uniquement sur le site web** (whateka.ch). Sur iOS, le bouton « Démarrer l'essai » affichera un message « Bientôt disponible » jusqu'à la Phase 3 (Apple IAP).

---

## 1. Créer un compte Stripe

1. Va sur https://stripe.com et crée un compte (Suisse, en CHF)
2. Renseigne les infos de ton entreprise (Whateka SA / nom légal)
3. Active le mode **Test** d'abord, on passera en Live après validation

---

## 2. Créer les 2 produits

Dans le dashboard Stripe → **Catalogue de produits** → **+ Ajouter un produit** :

### Produit 1 : Whateka Régional
- **Nom** : `Whateka Régional`
- **Description** : `Quiz illimités sur 1 canton (Vaud ou Valais)`
- **Prix** :
  - Type : **Récurrent**
  - Montant : `3.00 CHF`
  - Facturation : **Mensuelle**
- **Sauvegarder** → copie le `price_id` (commence par `price_...`)

### Produit 2 : Whateka Évasion
- **Nom** : `Whateka Évasion`
- **Description** : `Quiz illimités sur Vaud et Valais`
- **Prix** :
  - Type : **Récurrent**
  - Montant : `5.00 CHF`
  - Facturation : **Mensuelle**
- **Sauvegarder** → copie le `price_id`

Tu auras donc 2 `price_id` à conserver :
- `STRIPE_PRICE_REGIONAL` = `price_...` (du produit Régional)
- `STRIPE_PRICE_EVASION` = `price_...` (du produit Évasion)

---

## 3. Activer le Customer Portal

Dans le dashboard Stripe → **Paramètres** → **Facturation** → **Portail client** :
1. **Activer** le portail
2. Choisis ce que les clients peuvent faire :
   - ✅ Mettre à jour les informations de paiement
   - ✅ Voir l'historique des factures
   - ✅ **Annuler des abonnements** (très important !)
   - Type d'annulation : **À la fin de la période** (l'abo continue jusqu'à la fin du mois payé)
3. Ajoute ton URL de retour : `https://whateka.ch/profile`
4. **Enregistrer**

---

## 4. Récupérer les clés API

Dashboard Stripe → **Développeurs** → **Clés API** :
- Mode **Test** d'abord :
  - `sk_test_...` (clé secrète test) ← celle qu'on met en backend
  - `pk_test_...` (clé publique test) — pas utilisée côté serveur

⚠️ **Ne JAMAIS partager la clé secrète** publiquement (pas dans GitHub, pas dans le code Flutter).

---

## 5. Configurer les secrets sur Supabase

Va dans le dashboard Supabase → **Edge Functions** → **Secrets** (ou via CLI) :

```bash
# Via CLI (recommandé)
supabase secrets set STRIPE_SECRET_KEY=sk_test_xxxxx --project-ref pqywriedvxsdngypplpg
supabase secrets set STRIPE_PRICE_REGIONAL=price_xxxxx --project-ref pqywriedvxsdngypplpg
supabase secrets set STRIPE_PRICE_EVASION=price_xxxxx --project-ref pqywriedvxsdngypplpg
supabase secrets set APP_BASE_URL=https://whateka.ch --project-ref pqywriedvxsdngypplpg
```

Ou via le dashboard : **Settings** → **Edge Functions** → **Secrets** → ajouter les 4 entrées.

---

## 6. Déployer les 3 edge functions

```bash
cd whateka-main
supabase functions deploy stripe-create-checkout --project-ref pqywriedvxsdngypplpg
supabase functions deploy stripe-portal --project-ref pqywriedvxsdngypplpg
supabase functions deploy stripe-webhook --project-ref pqywriedvxsdngypplpg --no-verify-jwt
```

⚠️ **Important** : `stripe-webhook` doit être déployée avec `--no-verify-jwt` car Stripe ne passe pas de JWT, on vérifie nous-mêmes la signature avec le webhook secret.

---

## 7. Configurer le webhook Stripe

Dashboard Stripe → **Développeurs** → **Webhooks** → **+ Ajouter un endpoint** :

- **URL de l'endpoint** :
  ```
  https://pqywriedvxsdngypplpg.supabase.co/functions/v1/stripe-webhook
  ```
- **Events à écouter** (clique « Sélectionner des events ») :
  - ✅ `checkout.session.completed`
  - ✅ `customer.subscription.updated`
  - ✅ `customer.subscription.deleted`
  - ✅ `invoice.paid`
  - ✅ `invoice.payment_failed`
- **Sauvegarder**

Une fois créé, clique sur l'endpoint → **Récupère le signing secret** (commence par `whsec_...`).

Ajoute-le aux secrets Supabase :
```bash
supabase secrets set STRIPE_WEBHOOK_SECRET=whsec_xxxxx --project-ref pqywriedvxsdngypplpg
```

Puis redéploie le webhook (les secrets sont chargés au démarrage) :
```bash
supabase functions deploy stripe-webhook --project-ref pqywriedvxsdngypplpg --no-verify-jwt
```

---

## 8. Tester en mode Test

1. Sur `whateka.ch` (en mode test) :
   - Va dans Profil → Abonnement → "Passer Premium"
   - Choisis Régional ou Évasion → "Démarrer l'essai"
   - Tu seras redirigé vers Stripe Checkout
2. Utilise une **carte de test** Stripe :
   - Numéro : `4242 4242 4242 4242`
   - Date : n'importe quoi futur (ex `12/30`)
   - CVC : n'importe quoi (ex `123`)
   - ZIP : n'importe quoi (ex `1000`)
3. Valide → tu reviens sur `whateka.ch?stripe=success`
4. Vérifie en DB Supabase :
   - Table `subscriptions` : ton tier doit être à `regional` ou `evasion`, `expires_at` à +37j (7j essai + 30j période)
5. Test annulation :
   - Profil → "Gérer / annuler mon abonnement →"
   - Tu arrives sur le Customer Portal Stripe
   - Annule → vérifie en DB que `status = 'canceled'`

---

## 9. Passer en mode Live

Quand tout est validé en test :

1. Dashboard Stripe → bascule en mode **Live** (en haut à gauche)
2. Recrée les **mêmes produits** en mode Live (pas de migration auto entre test et live)
3. Récupère les nouveaux `price_id` Live
4. Régénère les clés API en mode Live (`sk_live_...`)
5. Reconfigure le webhook en mode Live (nouveau `whsec_...`)
6. Mets à jour les secrets Supabase :
   ```bash
   supabase secrets set STRIPE_SECRET_KEY=sk_live_... --project-ref pqywriedvxsdngypplpg
   supabase secrets set STRIPE_PRICE_REGIONAL=price_LIVE_... --project-ref pqywriedvxsdngypplpg
   supabase secrets set STRIPE_PRICE_EVASION=price_LIVE_... --project-ref pqywriedvxsdngypplpg
   supabase secrets set STRIPE_WEBHOOK_SECRET=whsec_LIVE_... --project-ref pqywriedvxsdngypplpg
   ```
7. Redéploie les 3 edge functions

---

## 10. Frais Stripe à connaître

- **Frais Stripe Suisse** : 2.9% + 0.30 CHF par transaction (cartes européennes)
- **Sur 3 CHF/mois** : tu reçois ≈ 2.41 CHF
- **Sur 5 CHF/mois** : tu reçois ≈ 4.41 CHF
- Stripe gère automatiquement la TVA suisse (8.1%) si tu actives **Stripe Tax**

---

## ❓ Troubleshooting

### Le webhook n'est pas reçu
- Vérifie l'URL : `https://pqywriedvxsdngypplpg.supabase.co/functions/v1/stripe-webhook`
- Vérifie que le webhook a été déployé avec `--no-verify-jwt`
- Dans Stripe → Webhooks → ton endpoint → onglet "Tentatives" : tu vois les requêtes envoyées + leur réponse (si erreur 401, c'est que le `--no-verify-jwt` a été oublié)

### "Signature invalide" dans les logs
- Le `STRIPE_WEBHOOK_SECRET` n'est pas configuré ou pas à jour
- Tu as redéployé après avoir mis à jour le secret ?

### La table `subscriptions` n'est pas mise à jour
- Vérifie les logs Supabase → Edge Functions → `stripe-webhook` → Logs
- Le webhook est-il bien reçu ? (Dashboard Stripe → Webhooks → Tentatives)
- Le `user_id` est-il bien dans `subscription_data.metadata.user_id` ? (créé automatiquement par `stripe-create-checkout`)

---

## 📅 Et après ?

**Phase 3** (à venir) : Apple In-App Purchase via RevenueCat pour les utilisateurs iOS. RevenueCat unifiera la gestion (dashboard unique pour iOS + web).
