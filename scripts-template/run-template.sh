#!/bin/bash

# Run script to install and launch the latest build of $displayName app
UDID=$deviceUDID
BUNDLE_ID=$bundleIdentifier

# Check for --dev flag to use dev build
if [[ "$1" == "--dev" ]]; then
    PRODUCT_NAME="$displayName Dev"
    BUNDLE_ID="$bundleIdentifier.dev"
    CONFIG="DebugDev"
    echo "🔧 Using development build"
else
    PRODUCT_NAME="$displayName"
    CONFIG="Debug"
fi

# Check if build exists
APP_PATH="build/Build/Products/${CONFIG}-iphoneos/${PRODUCT_NAME}.app"
if [ ! -d "$APP_PATH" ]; then
    echo "❌ Build not found at $APP_PATH"
    echo "Run ./build.sh or ./buildRun.sh first to create a build"
    exit 1
fi

echo "📱 Installing app on device..."
xcrun devicectl device install app \
  --device "$UDID" \
  "$APP_PATH"

if [ $? -ne 0 ]; then
    echo "❌ Installation failed!"
    exit 1
fi

echo "✅ App installed!"
echo ""

# Small delay for first-time installs
sleep 1

echo "🚀 Launching app..."
xcrun devicectl device process launch \
  --device "$UDID" \
  "$BUNDLE_ID"

if [ $? -ne 0 ]; then
    echo "⚠️  Launch command failed (this sometimes happens on first install)"
    echo "The app may have launched successfully anyway. Check your device!"
    exit 0
fi

echo "✅ App launched successfully!"