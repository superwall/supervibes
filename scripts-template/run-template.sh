#!/bin/bash

# Build and Run script for $displayName app
DEFAULT_UDID="$deviceUDID"
DEFAULT_TYPE="$deviceType"
BUNDLE_ID=$bundleIdentifier

# Parse command line arguments
SCHEME="$projectName"
CONFIG="Release"
USE_SIMULATOR=false
USE_DEBUG=false

for arg in "$@"; do
    case $arg in
        --debug)
            USE_DEBUG=true
            SCHEME="$projectName-debug"
            CONFIG="Debug"
            ;;
        --simulator)
            USE_SIMULATOR=true
            ;;
    esac
done

# Display build configuration
if [ "$USE_DEBUG" = true ]; then
    echo "🔧 Using debug scheme: $SCHEME (with tests)"
else
    echo "🚀 Using release scheme: $SCHEME"
fi

# Set destination based on flags
if [ "$USE_SIMULATOR" = true ]; then
    echo "📲 Building for simulator"
    SDK="iphonesimulator"
    DESTINATION="platform=iOS Simulator,name=iPhone 15 Pro"
    PRODUCTS_DIR="build/Build/Products/${CONFIG}-iphonesimulator"
else
    echo "📱 Building for device"
    SDK="iphoneos"
    if [ "$DEFAULT_TYPE" = "simulator" ] && [ "$DEFAULT_UDID" = "booted" ]; then
        # Default was simulator but user didn't specify --simulator
        echo "⚠️  Default target is simulator. Use --simulator flag or select a device in generate.sh"
        SDK="iphonesimulator"
        DESTINATION="platform=iOS Simulator,name=iPhone 15 Pro"
        PRODUCTS_DIR="build/Build/Products/${CONFIG}-iphonesimulator"
    else
        DESTINATION="platform=iOS,id=$DEFAULT_UDID"
        PRODUCTS_DIR="build/Build/Products/${CONFIG}-iphoneos"
    fi
fi

echo "🧞‍♂️ Generating xcode project..."
xcodegen generate

echo "🔨 Building $SCHEME..."
xcodebuild -scheme "$SCHEME" \
  -configuration "$CONFIG" \
  -sdk "$SDK" \
  -destination "$DESTINATION" \
  -derivedDataPath build \
  build

if [ $? -ne 0 ]; then
    echo "❌ Build failed!"
    exit 1
fi

echo "✅ Build succeeded!"
echo ""

# Install and launch based on target
if [ "$SDK" = "iphonesimulator" ]; then
    echo "🚀 Launching in simulator..."
    # Boot simulator if needed
    xcrun simctl boot "iPhone 15 Pro" 2>/dev/null || true
    # Install app
    xcrun simctl install "iPhone 15 Pro" "$PRODUCTS_DIR/$displayName.app"
    # Launch app
    xcrun simctl launch "iPhone 15 Pro" "$BUNDLE_ID"
    echo "✅ App launched in simulator!"
else
    echo "📱 Installing app on device..."
    xcrun devicectl device install app \
      --device "$DEFAULT_UDID" \
      "$PRODUCTS_DIR/$displayName.app"
    
    if [ $? -ne 0 ]; then
        echo "❌ Installation failed!"
        exit 1
    fi
    
    echo "✅ App installed!"
    echo ""
    
    echo "🚀 Launching app..."
    sleep 1
    
    xcrun devicectl device process launch \
      --device "$DEFAULT_UDID" \
      "$BUNDLE_ID"
    
    if [ $? -ne 0 ]; then
        echo "⚠️  Launch command failed (this sometimes happens on first install)"
        echo "The app may have launched successfully anyway. Check your device!"
        exit 0
    fi
    
    echo "✅ App launched successfully!"
fi