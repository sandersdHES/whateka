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

## CI

Le workflow `.github/workflows/deploy-web.yml` lit les secrets repo :
- `SUPABASE_URL`
- `SUPABASE_ANON_KEY`
- `SENTRY_DSN` (optionnel)

Configurer ces secrets dans **GitHub > Repo Settings > Secrets and variables > Actions**.
