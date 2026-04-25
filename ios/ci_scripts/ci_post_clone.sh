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

echo "🍎 Installing CocoaPods..."
cd ios
pod install

echo "✅ Pre-build setup complete!"
