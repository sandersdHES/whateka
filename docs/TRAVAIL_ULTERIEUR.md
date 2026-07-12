# Travail ultérieur — backlog priorisé

> Établi le 5 juillet 2026, après la session « bugs critiques + tests ».
> Plan détaillé par item : [PLAN_BUGS_ET_AMELIORATIONS.md](PLAN_BUGS_ET_AMELIORATIONS.md).
> Runbooks : [AUTH_LINKS_FIX.md](AUTH_LINKS_FIX.md) · [IMAGES_FIX.md](IMAGES_FIX.md) · [../supabase/migrations/README.md](../supabase/migrations/README.md).

## ✅ Fait cette session (branche `fix/bugs-critiques-tests`, poussée)

- **Phase 0** — harnais de test réparé (16 tests verts) + garde-fou CI (`analyze` + `test` avant déploiement).
- **#1/#2 auth** — code corrigé (redirect unique, `verification_screen` réactif) + tests ; config dashboard faite.
- **#4 avatar** — bucket `profile-photos` + RLS créés en prod (cause = migration jamais appliquée).
- **#3 images** — 4/5 URLs cassées remplacées (vérifiées) + test de régression.
- **Réconciliation migrations** — repo aligné sur les 80 migrations réelles + `config.toml` versionné.

---

## 🔜 Suivis immédiats (faible effort, à faire côté toi)

| # | Action | Bloque quoi | Note |
|---|--------|-------------|------|
| A | **Ouvrir/merger la PR** `fix/bugs-critiques-tests` | rien | https://github.com/sandersdHES/whateka/pull/new/fix/bugs-critiques-tests |
| B | **Tests device/web** : liens reset+confirmation (iOS/Android/web), upload avatar, 4 fiches images (167/265/632/669) | validation #1/#2/#3/#4 | cf. runbooks |
| C | **#3 item 246** (Glacier 3000) : lancer `rehost_broken_images.sh` avec ta clé `service_role` | 1 image | script prêt en scratchpad |
| D | **Rebaser la PR sur `main`** si besoin (la branche part de `chore/ios-dart-define-build-config`) | propreté | `git rebase --onto main chore/… fix/…` |

---

## 📋 Backlog priorisé (prochains chantiers)

### 1. #5 — Baseline schéma reconstructible *(Haute · prérequis migration)*
- **Pourquoi** : les 80 migrations réconciliées sont un *record* fidèle mais ne rejouent pas from-scratch (schéma de base pré-tracking non capturé).
- **1ʳᵉ action** : installer le CLI Supabase → `supabase link` → `supabase db pull` (nécessite le **mot de passe DB**). Voir [migrations/README.md](../supabase/migrations/README.md).
- **Puis** : traiter les advisors sécurité (`is_admin()` exécutable par `anon`, fonctions `SECURITY DEFINER` exposées) et le reste de la migration Supabase (org GitHub indépendante, hébergement CH).

### 2. #7 — Stripe : activer le vrai paiement *(Haute)*
- **État** : backend prêt à ~80 % (checkout/portal/webhook/DB/promo). L'app route volontairement vers l'écran promo.
- **Décision requise** : activer le paiement réel maintenant, ou rester en promo jusqu'à l'Apple IAP ?
- **1ʳᵉ action** : brancher `_startCheckout` → `createStripeCheckoutSession` + `url_launcher` ; configurer les secrets Stripe ; ajouter le handler `charge.refunded`. Tests Deno sur la signature webhook.

### 3. #6 — Migration API Gemini *(Moyenne)*
- **Décision requise** : quel provider ? (reco : **Claude/Anthropic**).
- **1ʳᵉ action** : introduire une couche `generate(prompt) → text` dans `supabase/functions/recommend-activity/`, garder `parseGeminiResponse` + sanitisation. Tests Deno (prompt/parse/fallback).

### 4. #11 — Traduction allemande — ✅ FAIT (déployé le 5 juil.)
- 403 chaînes DE (orthographe suisse, tutoiement, Waadt/Wallis), `AppLocale.de`, puce 🇩🇪, `pickLocalized` (DE → EN puis FR). Vérifié visuellement (accueil/login/signup) + tests de parité. Live sur whateka.ch.

### 5. #8 / #9 — Commentaires & soumissions user *(Moyenne)*
- Réutiliser les patterns RLS/trigger existants (`contact_messages`). Bucket `user-uploads` pour #9.

### 6. #12 — Google Play Store *(Haute, quand prêt)*
- **1ʳᵉ action** : `flutter build appbundle --release` (AAB, pas APK) ; fiche Play Console + data safety ; piste testeurs interne. Automatisable via `r0adkll/upload-google-play`.

### 7. #10 · #13 · #14 *(Basse / au fil de l'eau)*
- #10 API Business (conception : auth par clé, `ingest-activity`). #13 logo Aventure (attend maquette Louisa). #14 messagerie = déjà clarifié (support user↔admin) → ajouter le realtime + index manquant `contact_message_replies.author_user_id`.

### 8. #15 — Site vitrine (landing marketing) *(Moyenne)*
- **But** : présenter Whateka publiquement (acquisition + SEO) — expliquer l'app, montrer l'équipe, et centraliser les liens de téléchargement/suivi.
- **Contenu / sections** :
  - **Hero** : logo + tagline « L'activité te trouvera ! » + CTA vers l'app web.
  - **Comment ça marche** : captures d'écran (« prints ») du parcours — quiz → reco IA, carte Vaud/Valais, favoris, fiche activité.
  - **Fonctionnalités clés** : quiz personnalisé, carte, favoris, multilingue FR/EN/DE, activités certifiées.
  - **L'équipe** : photos + noms + rôles.
  - **Liens** : app web (whateka.ch), **App Store** (iOS), **Google Play** (#12, à venir), **Instagram** ([@whateka.ch](https://instagram.com/whateka.ch)).
- **Décision d'archi** (cf. décisions ouvertes) : `whateka.ch` sert aujourd'hui l'app Flutter. Options :
  - (a) vitrine à la racine `whateka.ch`, app déplacée sous `/app` — **recommandé** (meilleur SEO, 1ʳᵉ impression marketing) ;
  - (b) vitrine sur sous-domaine (`www.`/`hello.whateka.ch`), app à la racine ;
  - (c) page statique séparée liée depuis l'app.
- **Techno** : site **statique léger** (HTML/CSS/JS, ou générateur type Astro/11ty) pour SEO + perf, déployé sur GitHub Pages à côté de l'app ; Open Graph (partage social), responsive, i18n FR/EN/DE cohérente avec l'app.
- **1ʳᵉ action** : trancher l'archi (a/b/c) ; rassembler les assets (captures à jour, photos + bios équipe, **lien App Store réel** si l'app iOS est publiée — sinon « Bientôt sur l'App Store ») ; puis maquette + intégration.
- **Prérequis / à préciser** : l'app iOS est-elle déjà en ligne sur l'App Store (lien direct) ? Play Store = #12.

---

## 🧹 Dette technique notée (non bloquante)

- **7 lints `info`** tolérés par la CI (`--no-fatal-infos`) : à résorber puis durcir la CI (retirer le flag). Cf. `strings.dart` (private type in public API), `questionnaire_screen.dart` (BuildContext across async gaps).
- **Images base64** (activités id 4 et 124) : inline dans la colonne `image_url` → alourdit les requêtes. À migrer vers le bucket.
- **Advisors perf** : index manquant `contact_message_replies.author_user_id` ; policies permissives multiples (fusionner) ; ~25 index inutilisés (candidats à suppression après vérif).
- **Durabilité images #3** : les remplacements restent externes ; option = mirror des 202 dans le bucket (même script).

---

## ❓ Décisions ouvertes (à trancher avant les chantiers concernés)

1. **#6** : provider LLM de remplacement (reco Claude).
2. **#5** : région d'hébergement Supabase (CH/UE) + org GitHub cible.
3. **#7** : activer le paiement réel maintenant ou après Apple IAP ?
4. **#3/#4/base64** : re-héberger toutes les images externes dans le bucket (durabilité) ?
5. **#15 (site vitrine)** : architecture du domaine (vitrine à la racine + app sous `/app`, vs sous-domaine) ? + assets équipe/captures + lien App Store réel dispo ?
