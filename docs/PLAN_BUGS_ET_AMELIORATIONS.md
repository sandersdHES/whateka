# Plan d'exécution — Bugs & Améliorations Whateka

> Établi le 5 juillet 2026 · basé sur un audit du code (`lib/`, `supabase/`), de la config de build/déploiement et du projet Supabase `pqywriedvxsdngypplpg`.
> Source : [BUGS_ET_AMELIORATIONS.md](../BUGS_ET_AMELIORATIONS.md).
> Suivi d'exécution & nouveaux items (dont **#15 site vitrine**) : [TRAVAIL_ULTERIEUR.md](TRAVAIL_ULTERIEUR.md).

Chaque item suit le même schéma demandé : **1) test de la situation actuelle → 2) correction → 3) tests pour contrôler que la correction tient**.

---

## 0. État des lieux (ce que l'audit a révélé)

| # | Item | État réel constaté | Écart vs. ce qu'on croyait | Effort |
|---|------|--------------------|-----------------------------|--------|
| 1 | Reset mot de passe | `redirectTo` = deep link mobile non traité ; `null` sur web | **Aucun handler de deep link dans l'app** + allow-list Supabase à vérifier | M |
| 2 | Confirmation e-mail | Idem #1 ; `/verification` est un écran statique | Même cause racine que #1 | S (mutualisé) |
| 3 | Images activités | **Remote (réel) : 0 activité sans image**. 149 → bucket `activity-images` (1006 objets), 204 → URLs externes (dont ~50 TripAdvisor, Bing, Pinterest = hotlink à risque), 2 URLs vides | Ce n'est PAS « tout NULL » (les seeds du repo l'étaient, mais le remote a été peuplé via `image_urls_chunk`). Vrai bug = **URLs externes cassées** | M |
| 4 | Photo de profil | ✅ **CORRIGÉ (5 juil.)** : le bucket `profile-photos` était **absent du remote** → créé + 4 policies RLS (migration appliquée & vérifiée). Code Flutter déjà correct | Cause = migration jamais appliquée en prod, pas un bug de code | S |
| 5 | Migration Supabase / OAuth | Projet lié au GitHub de l'école ; pas de `config.toml` versionné | Config auth (redirects, OAuth) vit **uniquement dans le dashboard** | L |
| 6 | Migration API Gemini | 1 seule edge function `recommend-activity` ; appel REST isolé + fallback | Swap propre, bien encapsulé | M |
| 7 | Stripe | **Backend complet** (checkout/portal/webhook/DB/promo) déjà en place | L'app route volontairement vers l'écran promo au lieu du vrai checkout | M |
| 8 | Commentaires | Rien. Patterns RLS/trigger réutilisables (cf. `contact_messages`) | Green-field, mais gabarit clair | M |
| 9 | Soumission activités/photos | Table `activity_submissions` existe (1151 lignes) ; écran `submit_activity` présent | À vérifier : upload photo + modération | M |
| 10 | API Business | Rien | Conception à initier | L |
| 11 | Traduction allemande | Système i18n maison, **403 chaînes × 2 locales** (FR/EN) | Ajout `de` = étendre enum + constante `_de` | M |
| 12 | Google Play Store | Signing Android configuré ; build APK → Firebase App Distribution | Play exige un **AAB** + Play Console, pas juste un APK | M |
| 13 | Logo Aventure | Asset SVG existant | Bloqué sur maquette (Louisa) | XS |
| 14 | Messagerie « équipe » | En réalité **support user↔admin** (`contact_messages` + `_replies`), requêtes one-shot, pas de realtime | Clarifié : ce n'est pas du chat entre membres | S (doc) |

### Fondation manquante : les tests
- `test/widget_test.dart` est le **template par défaut cassé** (teste un compteur inexistant, instancie `MyApp` qui exige `Supabase.initialize` + dart-defines) → `flutter test` **échoue aujourd'hui**.
- `dev_dependencies` : seulement `flutter_test`. Pas de `mocktail`, `integration_test`, ni tests Deno pour les edge functions.
- CI (`.github/workflows/deploy-web.yml`) **build & déploie mais ne teste rien** (pas de `flutter analyze` ni `flutter test`).

➡️ **La Phase 0 ci-dessous est un prérequis** pour pouvoir « contrôler que les corrections sont en place » comme demandé.

---

## Phase 0 — Fondations de test (prérequis, ~1 jour)

**Objectif :** disposer d'un harnais qui fait échouer la CI quand une régression apparaît.

1. **Réparer/retirer** `test/widget_test.dart` (le remplacer par un vrai test de smoke qui n'exige pas Supabase).
2. **Ajouter les dev-deps** : `mocktail`, `integration_test` (sdk), `build_runner` si besoin.
3. **Mettre en place 4 niveaux de test** :
   - **Unit (Dart pur)** : parsing des modèles, logique `SubscriptionState`, complétude i18n.
   - **Widget** : écrans à logique (login, profil) avec un client Supabase mocké.
   - **Edge functions (Deno)** : `deno test` sur les fonctions pures (signature webhook, `parseGeminiResponse`, mapping tier).
   - **DB / RLS (SQL ou pgTAP)** : exécutés sur une **branche Supabase** via le CLI/MCP (jamais sur la prod).
4. **CI** : ajouter un job `test` (`flutter analyze` + `flutter test`) **avant** le job de déploiement, et un job `deno test` pour `supabase/functions`.

**Test de contrôle de la Phase 0 :** la CI passe au vert avec au moins 1 test réel par niveau ; un `flutter analyze` propre.

---

## Phase 1 — Bugs critiques (#1 à #4)

### #1 + #2 — Liens reset mot de passe & confirmation e-mail
**Cause racine commune :** l'app ne capte jamais l'URL de callback.
- Web : `redirectTo: kIsWeb ? null : …` → dépend du **Site URL / Redirect allow-list** du dashboard (à vérifier ; le domaine prod réel est `https://whateka.ch`).
- Mobile : `io.supabase.whateka://login-callback` est déclaré dans `AndroidManifest.xml` / `Info.plist` mais **aucun code ne traite l'URI entrante** → la session n'est jamais posée, donc `onAuthStateChange(passwordRecovery)` dans `main.dart:114` ne se déclenche pas.

**1) Test de la situation actuelle**
- Manuel : demander un reset sur `whateka.ch` (web) et sur un build Android → cliquer le lien → constater l'échec (page blanche / app ouverte sans navigation).
- Vérifier dans le dashboard Supabase → Auth → URL Configuration : Site URL et Redirect URLs autorisées.

**2) Correction**
- Ajouter le package **`app_links`** (ou s'appuyer sur le deep-link intégré de `supabase_flutter`) et, dans `main.dart`, écouter l'URI initiale + le stream ; extraire le token et appeler `getSessionFromUrl` / `setSession`, puis router selon `type` (`recovery` → `/update_password`, `signup` → confirmation).
- Renseigner un **`redirectTo` explicite** cohérent (web : `https://whateka.ch`; mobile : le scheme) au lieu de `null`.
- **Ajouter les URLs à l'allow-list** du dashboard Supabase (whateka.ch + scheme mobile).
- Rendre `verification_screen.dart` réactif (succès/erreur) au lieu de statique.
- Activer la **protection contre les mots de passe compromis** (advisor sécurité `auth_leaked_password_protection`) tant qu'on est dans l'auth.

**3) Tests de contrôle**
- **Unit** : fonction de parsing du callback (`type`, `access_token`, `error`) couverte par des cas web & mobile.
- **Integration test** (`integration_test`) : simuler la réception de l'URI `…://login-callback?type=recovery&access_token=…` → l'app navigue vers `/update_password`.
- **Manuel de non-régression** : reset complet sur web + Android + iOS, aboutissant à un login.

---

### #3 — Images d'activités non affichées
**Cause racine :** **données**. Migrations `0005`–`0008` insèrent toutes `image_url = NULL`. L'UI (`activity_card.dart:119`, `single_activity_screen.dart:172`) gère déjà proprement le fallback.

**1) Test de la situation actuelle**
- SQL (via branche/MCP) : `select count(*) from activities where image_url is null;` → confirmer le volume.
- Visuel : liste d'activités → placeholders de couleur au lieu de photos.

**2) Correction** (2 options, non exclusives)
- **A (contenu, recommandé) :** créer un bucket public `activity-images`, y importer des visuels, et **peupler `image_url`** (migration de backfill ou outil admin). Prévoir un import massif scripté.
- **B (robustesse) :** passer à `cached_network_image` (cache + retry), forcer HTTPS, et garder le fallback catégoriel. Traiter le mixed-content web.

**3) Tests de contrôle**
- **SQL de non-régression** : `image_url` non NULL et en `https://` pour ≥ X % des activités publiées.
- **Widget test** : `ActivityCard` avec URL valide → affiche `Image`, avec URL cassée → affiche le fallback (via `errorBuilder`).
- **Lint data** : test qui échoue si une seed réintroduit `image_url = NULL` sur une activité « publiée ».

---

### #4 — Photo de profil impossible
**Cause racine probable :** le flux (`profile_screen.dart:295`, bucket `profile-photos`, RLS `0004`) est correct. Blocages plausibles : **permissions natives manquantes** (iOS `NSPhotoLibraryUsageDescription`, Android lecture média) et **message d'erreur générique** qui masque la vraie cause.

**1) Test de la situation actuelle**
- Manuel : Profil → tap avatar → sélectionner une image → observer l'erreur exacte (logguer `e`).
- Vérifier `ios/Runner/Info.plist` (clé photo library) et `AndroidManifest.xml`.
- Vérifier via MCP que le bucket `profile-photos` existe bien et est `public`.

**2) Correction**
- Ajouter les clés de permission natives manquantes.
- Remonter le détail de l'exception (StorageException / message) dans le SnackBar + Sentry.
- Vérifier le edge case RLS `(storage.foldername(name))[1] == auth.uid()` (chemin `{uid}/avatar.ext`).

**3) Tests de contrôle**
- **Widget test** : upload simulé (client storage mocké) → succès met à jour `user_metadata.profile_photo_url` et l'avatar.
- **RLS test (SQL)** : user A ne peut pas écrire dans le dossier de user B ; lecture publique OK.
- **Manuel** : upload réel iOS + Android + web, persistance après relog.

---

## Phase 2 — Infrastructure (#5, #6)

### #5 — Migration Supabase / GitHub OAuth (Haute)
> Sensible : touche la prod et l'authentification. À faire hors période de forte activité, avec sauvegarde.

**1) Test de la situation actuelle**
- ⚠️ **Dérive migrations découverte (5 juil.)** : l'historique de migrations du
  **remote** (nommage horodaté : `add_activity_images_bucket_and_image_urls`,
  `image_urls_chunk_00..05`, `subscriptions_and_promo_codes`, `contact_messages`…)
  **ne correspond pas** au dossier `supabase/migrations/` du repo (nommage
  `0003_…` → `0019_…`). Le repo est un **miroir partiel/renommé**, pas la source
  de vérité. Conséquence : le bucket `profile-photos` (repo `0004`) n'avait jamais
  été appliqué en prod (→ bug #4). **Action prioritaire de #5** : réconcilier le
  repo avec le remote (générer les migrations réelles via `supabase db pull`) pour
  que la migration future soit fiable.
- Inventorier : provider GitHub OAuth (dashboard), Site URL/redirects, secrets edge functions (Stripe, Gemini), buckets storage, données.
- Confirmer l'org GitHub actuelle (école) et la cible indépendante.
- **Advisors sécurité à traiter au passage** (`is_admin()` exécutable par `anon`, fonctions `SECURITY DEFINER` exposées, mot de passe compromis) — [linter Supabase](https://supabase.com/docs/guides/database/database-linter).

**2) Correction**
- **Versionner la config** : générer `supabase/config.toml` (redirects, auth, templates e-mail) pour ne plus dépendre du dashboard seul.
- Créer le **nouveau projet Supabase** (région Suisse/UE pour LPD/RGPD si possible), migrer schéma (`supabase db push` avec les migrations `0003`→`0019`), données (dump/restore), storage (copie des objets), et secrets.
- Reconfigurer OAuth sous une **org GitHub indépendante** ; mettre à jour `SUPABASE_URL`/`ANON_KEY` dans dart-defines, CI secrets, `dart_define.json`, scripts de deploy.
- Bascule DNS/redirects + fenêtre de coupure planifiée.

**3) Tests de contrôle**
- Checklist de parité : login e-mail + OAuth, reset (#1), quiz IA (#6), Stripe test (#7), messagerie (#14), images/avatars sur le **nouveau** projet.
- `flutter test` + `deno test` verts pointés sur le nouveau projet (branche).
- Advisors sécurité re-vérifiés = 0 WARN critique.

### #6 — Migration API Gemini (Moyenne)
**1) Test de la situation actuelle**
- Isoler l'appel : `recommend-activity/index.ts` (fetch `generativelanguage…/gemini-2.0-flash`, `parseGeminiResponse`, fallback templates). Le contrat I/O est clair (prompt → JSON `{recommendations[], global_comment}`).

**2) Correction**
- Décision équipe requise (cf. Décisions ouvertes). Recommandation : **Claude** (Anthropic) pour la qualité FR et la simplicité du swap (endpoint `/v1/messages`, `x-api-key`, `content[0].text`).
- Introduire une petite **couche d'abstraction provider** (interface `generate(prompt) → text`) pour isoler le reste du pipeline de scoring.
- Garder `parseGeminiResponse` + sanitisation vocabulaire (gastronomie→gourmandise) inchangés.

**3) Tests de contrôle**
- **Deno unit** : `buildPrompt`, `parseResponse` (JSON valide, JSON bruité, IDs hors liste), fallback quand pas de clé.
- **Test de contrat** : le nouveau provider renvoie 3 IDs valides + `global_comment` ≤ 12 mots sur un jeu de prompts figés.
- **A/B manuel** : comparer 10 quiz Gemini vs. nouveau provider (pertinence, ton).

---

## Phase 3 — Monétisation & fonctionnalités (#7, #8, #9, #11)

### #7 — Stripe (Haute) — *déjà à ~80 %*
**1) Test de la situation actuelle**
- Constater que `subscription_screen.dart:44` `_startCheckout()` pousse `ThanksForInterestScreen` (promo) au lieu d'appeler `createStripeCheckoutSession()`.
- Vérifier les secrets Supabase (`STRIPE_SECRET_KEY`, `STRIPE_PRICE_*`, `STRIPE_WEBHOOK_SECRET`, `APP_BASE_URL`) et le déploiement des 3 functions (dont webhook `--no-verify-jwt`).

**2) Correction**
- **Brancher le vrai checkout web** : `_startCheckout` → `createStripeCheckoutSession(tier)` → `url_launcher`. Gérer le retour `?stripe=success`.
- Respecter la contrainte **iOS interdit** (cf. `STRIPE_SETUP.md`) : bouton « Bientôt disponible » (Phase 3 Apple IAP).
- Compléter : **remboursements** (`charge.refunded`), reprise après `invoice.payment_failed`, événements analytics.

**3) Tests de contrôle**
- **Deno unit** : vérification de signature webhook (fenêtre 5 min, comparaison constante), mapping `price_id → tier`, `upsertSubscription` idempotent.
- **E2E test mode** : carte `4242…` → `subscriptions.tier` = `regional/evasion`, `expires_at` ≈ +37 j ; annulation portal → `status = canceled`.
- **RLS** : un user ne lit que sa propre subscription.

### #8 — Espace commentaires (Moyenne)
**1) Situation actuelle :** inexistant.
**2) Correction :** table `activity_comments` (schéma dans l'audit), RLS calquée sur `contact_messages` (lecture publique, écriture propre, modération admin via `is_admin()`), trigger `set_updated_at`, signalement + pagination ; UI type fil de discussion.
**3) Tests de contrôle :** RLS (écriture propre uniquement, suppression admin) ; widget (poster/afficher/paginer) ; modération (masquage d'un commentaire signalé).

### #9 — Soumission activités & photos (Moyenne)
**1) Situation actuelle :** `submit_activity_screen.dart` + table `activity_submissions` existent ; vérifier l'upload photo et le workflow de modération.
**2) Correction :** bucket `user-uploads` (RLS par user), statut `pending → approved/rejected`, écran/flux admin de modération, publication vers `activities`.
**3) Tests de contrôle :** RLS (soumission propre) ; workflow (pending non visible publiquement, approved visible) ; widget d'upload.

### #11 — Traduction allemande (Moyenne)
**1) Situation actuelle :** i18n maison, 403 chaînes, `enum AppLocale { fr, en }`, persistance dans `user_metadata.locale`.
**2) Correction :** étendre `AppLocale` (`de`), créer `const _Strings _de`, brancher `S.of`/`S.current`/`LocaleProvider`, ajouter la puce 🇩🇪 dans `language_toggle.dart`, traduire (UI + contenu éditorial) ; tester `de-DE`/`de-CH`.
**3) Tests de contrôle :**
- **Unit de complétude (clé de voûte)** : test qui vérifie que **chaque locale expose exactement les mêmes clés** → échoue si une chaîne allemande manque. (Réutilisable pour toute future langue.)
- **Widget** : bascule FR→DE change effectivement les libellés.
- **Manuel** : parcours complet en allemand, pas de débordement de layout.

---

## Phase 4 — Déploiement & divers (#12, #10, #13, #14)

### #12 — Google Play Store (Haute)
**1) Situation actuelle :** signing release configuré (`key.properties` local), mais `deploy_android.sh` build un **APK** vers Firebase App Distribution — pas un AAB pour Play.
**2) Correction :** `flutter build appbundle --release` (dart-define-from-file), fiche Play Console, politique de confidentialité, data safety, screenshots ; **piste testeurs internes/fermée** puis production. Idéalement automatiser via GitHub Actions (`r0adkll/upload-google-play`) avec un service account.
**3) Tests de contrôle :** l'AAB s'installe depuis la piste interne ; pré-lancement Play (crash/robo test) au vert ; smoke test manuel du build de prod (login, quiz, paiement).

### #10 — API Business (Basse — conception)
**1) Situation actuelle :** inexistant.
**2) Correction (conception) :** choisir l'auth (API key par partenaire, table `partners` + `api_keys` hashées), définir le schéma d'activité entrante, un edge function `ingest-activity` (validation + insertion en `activity_submissions` statut `pending`), rate-limiting, workflow de modération.
**3) Tests de contrôle :** Deno unit (validation payload, rejet clé invalide/expirée) ; test d'intégration ingestion→modération→publication.

### #13 — Logo Aventure (Basse)
**1) Situation actuelle :** bloqué sur la maquette de Louisa.
**2) Correction :** remplacer l'asset SVG à réception ; vérifier tailles/couleurs de marque.
**3) Tests de contrôle :** revue visuelle (golden test optionnel sur la puce catégorie Aventure).

### #14 — Messagerie « équipe » (à clarifier → clarifié)
**Réponse d'audit :** ce n'est **pas** du chat entre membres d'équipe. C'est un **support user↔admin** :
- Stockage : Supabase — `contact_messages` (ticket initial) + `contact_message_replies` (fil).
- Acheminement : **requêtes one-shot** (pas de realtime) ; refetch complet à l'envoi / au pull-to-refresh ; statut `new/read/responded/archived` piloté par triggers.
- Côté admin : dashboard séparé lisant les mêmes tables (RLS `is_admin()`).

**Décision recommandée :** conserver le système (simple, fonctionnel) et l'améliorer plutôt que le refondre :
- Ajouter le **realtime** (subscription Supabase) pour éviter le refetch.
- Corriger les advisors perf : index manquant sur `contact_message_replies.author_user_id`, policies permissives multiples à fusionner.

**Tests de contrôle :** RLS (user ne voit que ses fils) ; realtime (nouvelle réponse admin apparaît sans refresh) ; requête indexée (plan d'exécution).

---

## Décisions ouvertes (input requis)

1. **#6 Gemini →** quel provider ? *(reco : Claude/Anthropic)*.
2. **#5 Supabase →** région d'hébergement (Suisse/UE) et org GitHub cible indépendante.
3. **#7 Stripe →** activer le vrai paiement maintenant, ou rester en promo jusqu'à l'Apple IAP (Phase 3) ?
4. **#3 Images →** source des visuels (import massif ? photos partenaires ? généré ?).
5. **Priorisation d'exécution** : par quoi commencer (voir séquencement).

---

## Séquencement recommandé

1. **Phase 0** — fondations de test (débloque tout le reste). *~1 j*
2. **#1/#2** — auth (impact utilisateur direct, cause commune). *~1,5 j*
3. **#4** — avatar (petit, rapide). *~0,5 j*
4. **#3** — images (contenu + robustesse). *~1–2 j*
5. **#7** — Stripe (flip + remboursements). *~1,5 j*
6. **#11** — allemand (test de complétude d'abord). *~2 j + trad*
7. **#14** realtime, **#8** commentaires, **#9** soumissions. *~1 j chacun*
8. **#5** — migration Supabase (chantier isolé, sensible). *~2–3 j*
9. **#6** — swap LLM (après décision). *~1 j*
10. **#12** — Play Store. *~1–2 j*
11. **#10** conception API Business, **#13** logo (au fil de l'eau).

---

## Comment « contrôler que les corrections sont en place » (synthèse)

| Niveau | Outil | Couvre |
|--------|-------|--------|
| Unit Dart | `flutter test` | modèles, i18n complétude, `SubscriptionState`, parsing callback |
| Widget | `flutter test` + `mocktail` | écrans (login, profil, activité, commentaires) |
| Integration | `integration_test` | deep link auth (#1/#2), parcours de bout en bout |
| Edge functions | `deno test` | webhook Stripe, prompt/parse LLM, ingestion API |
| DB / RLS | SQL / pgTAP sur **branche** Supabase | policies (avatars, commentaires, subs, messages) |
| CI | GitHub Actions | `analyze` + `test` + `deno test` **avant** déploiement |
