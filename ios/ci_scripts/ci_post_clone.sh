#!/bin/sh

# Fail on any error
set -e

# The default is "ios/ci_scripts", so we go up two levels to reach the repo root
# OR use the predefined environment variable
cd $CI_PRIMARY_REPOSITORY_PATH

echo "🚀 Installing Flutter..."
git clone https://github.com/flutter/flutter.git --depth 1 -b stable $HOME/flutter
export PATH="$PATH:$HOME/flutter/bin"

echo "Running flutter doctor..."
flutter doctor -v

echo "📦 Installing Dependencies..."
flutter pub get

echo "⚙️ Precaching iOS artifacts..."
flutter precache --ios

# ----------------------------------------------------------------------------
# Injection des dart-defines dans la config de build iOS.
#
# CONTEXTE : l'app lit SUPABASE_URL / SUPABASE_ANON_KEY via
# String.fromEnvironment(...) (cf. lib/main.dart). Cote web, le workflow
# GitHub Actions passe ces valeurs en --dart-define. Cote iOS, l'archive est
# faite par Xcode Cloud (xcodebuild) qui lit les dart-defines depuis
# Flutter/Generated.xcconfig (cle DART_DEFINES, base64). Ce fichier est
# gitignore et, sans cette etape, ne contient AUCUN dart-define : a l'execution
# SUPABASE_URL est vide, main() leve une StateError AVANT runApp() et l'app
# affiche un ecran blanc / crash au lancement -> rejet App Store.
#
# `flutter build ios --config-only` ne compile rien : il se contente de
# (re)generer Generated.xcconfig avec les DART_DEFINES encodes, que l'archive
# Xcode Cloud reprendra ensuite.
#
# PREREQUIS : definir SUPABASE_URL et SUPABASE_ANON_KEY (et SENTRY_DSN
# optionnel) comme variables d'environnement dans Xcode Cloud
# (App Store Connect > Xcode Cloud > Workflow > Environment).
# ----------------------------------------------------------------------------
if [ -z "$SUPABASE_URL" ] || [ -z "$SUPABASE_ANON_KEY" ]; then
  echo "❌ SUPABASE_URL et SUPABASE_ANON_KEY doivent etre definis comme variables"
  echo "   d'environnement Xcode Cloud, sinon l'app affichera un ecran blanc au"
  echo "   lancement. Cf. BUILD.md."
  exit 1
fi

echo "🔧 Generating iOS build config with dart-defines..."
flutter build ios --config-only --release --no-codesign \
  --dart-define=SUPABASE_URL="$SUPABASE_URL" \
  --dart-define=SUPABASE_ANON_KEY="$SUPABASE_ANON_KEY" \
  --dart-define=SENTRY_DSN="${SENTRY_DSN:-}"

echo "🍎 Installing CocoaPods..."
cd ios
pod install

echo "✅ Pre-build setup complete!"
