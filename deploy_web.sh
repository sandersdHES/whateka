#!/bin/bash

# Configuration
SUPABASE_URL="https://pqywriedvxsdngypplpg.supabase.co"
SUPABASE_ANON_KEY="sb_publishable_KzcTKvqLTbWoECaUkD--xw_xJ8A35K6"
REPO_URL="https://github.com/sandersdHES/whateka.git"

echo "🚀 Starting Web Deployment to GitHub Pages!"

# 1. Build Web
echo "🔨 Building Release Web..."
flutter build web --release \
  --base-href "/whateka/" \
  --dart-define=SUPABASE_URL=$SUPABASE_URL \
  --dart-define=SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY

if [ $? -ne 0 ]; then
    echo "❌ Build failed!"
    exit 1
fi

# 2. Deploy to gh-pages
echo "📤 Deploying to gh-pages..."
cd build/web

# Initialize a new git repo to push the contents of build/web to gh-pages branch
git init
git add .
git commit -m "Deploy to GitHub Pages"

# Force push to the gh-pages branch of the repository
git push --force --quiet "$REPO_URL" main:gh-pages

if [ $? -eq 0 ]; then
    echo "✅ Deployment Successful!"
else
    echo "❌ Deployment failed!"
    exit 1
fi

cd ../..
