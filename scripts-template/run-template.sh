#!/bin/bash

# Run script to install and launch the latest build of $displayName app
UDID=$deviceUDID
BUNDLE_ID=$bundleIdentifier

# Check for --debug flag to use debug build
if [[ "$1" == "--debug" ]]; then
    PRODUCT_NAME="$displayName"
    CONFIG="Debug"
    echo "🔧 Using debug build"
else
    PRODUCT_NAME="$displayName"
    CONFIG="Release"
    echo "🚀 Using release build"
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