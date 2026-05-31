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

## Méthode recommandée : `dart_define.json` (mobile + local)

Au lieu de retaper les `--dart-define` à chaque fois, on les regroupe dans un
fichier `dart_define.json` à la racine, **non versionné** (cf. `.gitignore`,
audit 2026-05). C'est ce fichier que lit VS Code (`.vscode/launch.json`) et
que tu passes au build mobile.

```json
{
  "SUPABASE_URL": "https://<your>.supabase.co",
  "SUPABASE_ANON_KEY": "<anon-publishable-key>",
  "SENTRY_DSN": ""
}
```

Run / build avec :

```bash
flutter run --dart-define-from-file=dart_define.json
flutter build web    --release --dart-define-from-file=dart_define.json
```

## iOS — build & publication App Store

Les `--dart-define` sont compilés **dans le binaire** au moment du build. Il
faut donc construire l'IPA via la CLI Flutter (pas un simple *Product > Archive*
dans Xcode, qui n'injecterait pas les defines) :

```bash
flutter pub get
flutter build ipa --release --dart-define-from-file=dart_define.json
```

L'IPA est généré dans `build/ios/ipa/`. Ensuite :

1. **Signing** : ouvrir `ios/Runner.xcworkspace` dans Xcode une première fois,
   onglet *Signing & Capabilities*, choisir la Team Apple et un profil de
   distribution pour le bundle id `com.shz.whateka`.
2. **Upload** : envoyer l'IPA à App Store Connect via **Transporter** (Mac App
   Store) ou `xcrun altool --upload-app -f build/ios/ipa/*.ipa`, puis soumettre
   la build pour review depuis App Store Connect.

> Vérifié le 2026-05-31 : la clé `anon` publishable authentifie bien l'app
> contre Supabase (auth email + Google actifs, RLS protège `favorites`,
> `subscriptions`, `contact_messages`). Le 401 sur la racine `/rest/v1/` est
> normal (introspection schéma réservée aux clés secrètes).
