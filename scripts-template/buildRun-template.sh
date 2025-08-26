#!/bin/bash

# Build and Run script for $displayName app
UDID=$deviceUDID
BUNDLE_ID=$bundleIdentifier

# Check for --dev flag to use dev scheme
if [[ "$1" == "--dev" ]]; then
    SCHEME="$projectName-dev"
    BUNDLE_ID="$bundleIdentifier.dev"
    PRODUCT_NAME="$displayName Dev"
    CONFIG="DebugDev"
    echo "🔧 Using development scheme: $SCHEME"
else
    SCHEME="$projectName"
    PRODUCT_NAME="$displayName"
    CONFIG="Debug"
fi

echo "🧞‍♂️ Generating xcode project..."
xcodegen generate

echo "🔨 Building $SCHEME..."
xcodebuild -scheme "$SCHEME" \
  -configuration "$CONFIG" \
  -sdk iphoneos \
  -destination "platform=iOS,id=$UDID" \
  -derivedDataPath build \
  build

if [ $? -ne 0 ]; then
    echo "❌ Build failed!"
    exit 1
fi

echo "✅ Build succeeded!"
echo ""

echo "📱 Installing app on device..."
xcrun devicectl device install app \
  --device "$UDID" \
  "build/Build/Products/${CONFIG}-iphoneos/${PRODUCT_NAME}.app"

if [ $? -ne 0 ]; then
    echo "❌ Installation failed!"
    exit 1
fi

echo "✅ App installed!"
echo ""

# Small delay for first-time installs to ensure the app is fully registered
echo "🚀 Launching app..."
sleep 1

xcrun devicectl device process launch \
  --device "$UDID" \
  "$BUNDLE_ID"

if [ $? -ne 0 ]; then
    echo "⚠️  Launch command failed (this sometimes happens on first install)"
    echo "The app may have launched successfully anyway. Check your device!"
    exit 0
fi

echo "✅ App launched successfully!"