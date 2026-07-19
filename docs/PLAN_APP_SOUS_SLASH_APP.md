# Plan — servir la vitrine à la racine et l'app sous `/app`

> Contexte : #15 (site vitrine). Décision d'archi retenue : **vitrine à la racine
> `whateka.ch/`, application Flutter déplacée sous `whateka.ch/app/`**.
> Objectif SEO + première impression marketing, sans casser l'app ni l'auth.

## État actuel (source de vérité : `.github/workflows/deploy-web.yml`)

- Sur push `main` → job `test` (analyze + `flutter test`) puis `build-and-deploy`.
- Build : `flutter build web --release --base-href "/"` (+ dart-defines Supabase/Sentry).
- Déploiement : `peaceiris/actions-gh-pages@v3`, `publish_dir: ./build/web`,
  `cname: whateka.ch` → branche `gh-pages`, servie à la **racine** de whateka.ch.
- `deploy_web.sh` (script manuel, base-href `/whateka/`) est **obsolète** : le CI
  est la vraie prod. À corriger ou supprimer pour éviter la confusion.

Conséquence : aujourd'hui `whateka.ch/` = l'app. On veut `whateka.ch/` = vitrine,
`whateka.ch/app/` = l'app.

---

## Points sensibles à ne PAS oublier

1. **Redirection d'auth web** — `lib/config/auth_redirects.dart` renvoie
   `Uri.base.origin` (schéma+host, **sans chemin**). Après déplacement, les liens
   e-mail (reset MDP #1, confirmation #2) redirigeraient vers `whateka.ch/`
   = la **vitrine**, qui ne traite pas le token → auth cassée.
   → il faut rediriger vers `whateka.ch/app/` (voir Phase 2).
2. **Allow-list Supabase** — Dashboard → Auth → URL Configuration : le **Site URL**
   et les **Redirect URLs** doivent inclure `https://whateka.ch/app/`
   (garder `http://localhost:*` pour le dev).
3. **PWA** — `web/manifest.json` : `start_url` `/` → `/app/` (sinon l'app installée
   ouvre la vitrine). Ajouter idéalement `"scope": "/app/"`.
4. **Fichier de vérification Search Console** — `web/googlecd8d6a525de2f50d.html`
   est servi à la racine aujourd'hui. Il doit **rester à la racine** (le copier
   dans la vitrine), sinon la propriété Search Console se dé-vérifie.
5. **SEO** — l'`index.html` riche (meta, JSON-LD, sitemap) part avec l'app sous
   `/app`. La racine devient la vitrine : lui donner ses propres meta/OG/sitemap.
6. **Deep links natifs** — inchangés : iOS/Android utilisent le scheme
   `io.supabase.whateka://login-callback` (pas un lien https), donc pas d'impact.

---

## Phase 1 — Build de l'app sous `/app/`

`.github/workflows/deploy-web.yml`, étape *Build Flutter Web* :

```diff
- flutter build web --release --base-href "/" \
+ flutter build web --release --base-href "/app/" \
    --dart-define=SUPABASE_URL="$SUPABASE_URL" \
    --dart-define=SUPABASE_ANON_KEY="$SUPABASE_ANON_KEY" \
+   --dart-define=WEB_BASE_PATH="/app/" \
    --dart-define=SENTRY_DSN="${SENTRY_DSN:-}"
```

`$FLUTTER_BASE_HREF` dans `web/index.html` sera remplacé par `/app/` → tous les
assets (`main.dart.js`, `flutter_bootstrap.js`, icônes…) se résolvent sous `/app/`.

## Phase 2 — Corriger la redirection d'auth web (code)

`lib/config/auth_redirects.dart` : injecter le base-path web plutôt que l'origine nue.

```dart
/// Base-path web (doit correspondre au --base-href du build). Dev = "/".
const String kWebBasePath =
    String.fromEnvironment('WEB_BASE_PATH', defaultValue: '/');

String computeAuthRedirect({
  required bool isWeb,
  required String webOrigin,
  String webBasePath = kWebBasePath,
}) {
  if (!isWeb) return kMobileAuthRedirect;
  // Ex. prod : https://whateka.ch + /app/ ; dev : http://localhost:xxxx + /
  return webOrigin + webBasePath;
}

String authRedirectUrl() => computeAuthRedirect(
      isWeb: kIsWeb,
      webOrigin: Uri.base.origin,
    );
```

- Mettre à jour le test associé (redirect web attend désormais `origin + basePath`).
- **Supabase Dashboard** : ajouter `https://whateka.ch/app/` au Site URL + Redirect URLs.

## Phase 3 — PWA & vérifications racine

- `web/manifest.json` : `"start_url": "/app/"`, ajouter `"scope": "/app/"`.
- S'assurer que `web/googlecd8d6a525de2f50d.html` finit **à la racine** du site publié
  (le copier dans `site/`).

## Phase 4 — Assembler vitrine (racine) + app (`/app`) dans un seul déploiement

`peaceiris` ne publie qu'un dossier. On assemble une arborescence combinée avant deploy.

Nouvelle étape CI (après *Update sitemap date*, avant *Deploy*) :

```yaml
      - name: Assemble site (vitrine à la racine + app sous /app)
        run: |
          rm -rf public && mkdir -p public
          cp -R site/.        public/          # vitrine -> racine
          cp -R build/web      public/app       # app Flutter -> /app
          # Filet SPA : refresh/deep-link direct sous /app -> recharge l'app
          cp build/web/index.html public/app/404.html
```

Puis l'étape *Deploy to GitHub Pages* pointe sur le dossier assemblé :

```diff
-          publish_dir: ./build/web
+          publish_dir: ./public
           cname: whateka.ch
```

Notes :
- Le CNAME est géré par le paramètre `cname:` de peaceiris (inutile de le versionner).
- **Filet SPA** : GitHub Pages ne sert le 404 personnalisé qu'à la racine du site.
  Le cas auth (redirect vers `/app/`, un vrai fichier) fonctionne sans 404.
  Le `public/app/404.html` couvre les rafraîchissements sur une route cliente
  (`/app/xxx`) ; si insuffisant, forcer la **HashUrlStrategy** de l'app.
- Adapter `site/`'s meta/OG/sitemap à la racine (la vitrine a déjà ses OG ;
  ajouter un `sitemap.xml`/`robots.txt` racine listant `/` et `/app/`).

## Phase 5 — Nettoyage & garde-fous

- Corriger ou supprimer `deploy_web.sh` (base-href `/whateka/` trompeur).
- Vérifier `web/robots.txt` / `web/sitemap.xml` (ils partent sous `/app` avec l'app) :
  créer les équivalents **racine** pour la vitrine.

---

## Checklist de test (avant de fusionner sur `main`)

- [ ] `whateka.ch/` affiche la **vitrine** ; `whateka.ch/app/` affiche l'**app**.
- [ ] Assets de l'app OK sous `/app/` (aucune 404 réseau : `main.dart.js`, icônes).
- [ ] **Login** puis **reset mot de passe** (#1) : le lien e-mail ouvre
      `whateka.ch/app/…`, établit la session, route vers `/update_password`.
- [ ] **Confirmation d'e-mail** (#2) : idem, session établie.
- [ ] PWA installée : ouvre bien `/app/` (pas la vitrine).
- [ ] Search Console toujours vérifiée (fichier de vérif présent à la racine).
- [ ] Boutons « Démarrer l'aventure » de la vitrine (`/app`) → ouvrent l'app.
- [ ] Deep links natifs iOS/Android d'auth toujours OK (non impactés).

## Ordre de bascule recommandé

1. Merger d'abord la vitrine (déjà prête) **sans** toucher au déploiement.
2. PR séparée « app sous /app » regroupant Phases 1–5 + la mise à jour Supabase
   (allow-list) faite **juste avant** le merge (fenêtre courte où l'auth pointe
   vers `/app/`).
3. Déployer hors heure de pointe, dérouler la checklist, prévoir un rollback
   (revert du commit CI → app revient à la racine).
