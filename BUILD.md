# Build & run — Whateka (Flutter)

## Pre-requis

- Flutter SDK >= 3.3 (canal stable)
- Dart SDK >= 3.3

## Variables d'environnement

Depuis l'audit 2026-05, les credentials Supabase ne sont **plus** committés en
clair dans `lib/main.dart`. Tu dois les fournir au build via `--dart-define` :

| Variable | Source |
|---|---|
| `SUPABASE_URL` | Dashboard Supabase > Project Settings > API |
| `SUPABASE_ANON_KEY` | Dashboard Supabase > Project Settings > API (`anon public`) |
| `SENTRY_DSN` (optionnel) | Sentry > Project > Client Keys > DSN. Vide = pas d'envoi d'erreurs. |

## Build local (web)

```bash
flutter pub get

flutter run -d chrome \
  --dart-define=SUPABASE_URL="https://<your>.supabase.co" \
  --dart-define=SUPABASE_ANON_KEY="<anon-key>" \
  --dart-define=SENTRY_DSN=""
```

## Build release (web)

```bash
flutter build web --release \
  --dart-define=SUPABASE_URL="$SUPABASE_URL" \
  --dart-define=SUPABASE_ANON_KEY="$SUPABASE_ANON_KEY" \
  --dart-define=SENTRY_DSN="$SENTRY_DSN"
```

## Build release (iOS / App Store)

L'app iOS est archivée par **Xcode Cloud**. Comme pour le web, les
dart-defines Supabase doivent être injectés, sinon `main()` lève une
`StateError` avant `runApp()` → **écran blanc au lancement / rejet App Store**.

Le script `ios/ci_scripts/ci_post_clone.sh` s'en charge automatiquement via
`flutter build ios --config-only` (qui écrit `DART_DEFINES` dans
`Generated.xcconfig`, repris ensuite par l'archive Xcode Cloud).

**Prérequis** : définir ces variables dans
**App Store Connect > Xcode Cloud > Workflow > Environment** :
- `SUPABASE_URL`
- `SUPABASE_ANON_KEY`
- `SENTRY_DSN` (optionnel)

Pour un build local manuel :

```bash
flutter build ipa --release \
  --dart-define=SUPABASE_URL="$SUPABASE_URL" \
  --dart-define=SUPABASE_ANON_KEY="$SUPABASE_ANON_KEY" \
  --dart-define=SENTRY_DSN="$SENTRY_DSN"
```

## CI

Le workflow `.github/workflows/deploy-web.yml` lit les secrets repo :
- `SUPABASE_URL`
- `SUPABASE_ANON_KEY`
- `SENTRY_DSN` (optionnel)

Configurer ces secrets dans **GitHub > Repo Settings > Secrets and variables > Actions**.
