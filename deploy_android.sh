#!/bin/bash

# Configuration
APP_ID="1:1012253356889:android:ec0a1dda44c05ed2ea9248"
GROUPS="testers"
RELEASE_NOTES="Update from deployment script"
SUPABASE_URL="https://pqywriedvxsdngypplpg.supabase.co"
SUPABASE_ANON_KEY="sb_publishable_KzcTKvqLTbWoECaUkD--xw_xJ8A35K6"

echo "🚀 Starting Android Deployment to Firebase!"

# 1. Build APK
echo "🔨 Building Release APK..."
flutter build apk --release \
  --dart-define=SUPABASE_URL=$SUPABASE_URL \
  --dart-define=SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY

if [ $? -ne 0 ]; then
    echo "❌ Build failed!"
    exit 1
fi

# 2. Upload to Firebase
echo "📤 Uploading to Firebase App Distribution..."
firebase appdistribution:distribute build/app/outputs/flutter-apk/app-release.apk \
  --app "$APP_ID" \
  --groups "$GROUPS" \
  --release-notes "$RELEASE_NOTES"

if [ $? -eq 0 ]; then
    echo "✅ Deployment Successful!"
else
    echo "❌ Upload failed!"
exit 1
fi
