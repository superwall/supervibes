#!/bin/bash

# Build and Run script for app
# Load configuration from supervibes.local.json
CONFIG_FILE="supervibes.local.json"

if [ ! -f "$CONFIG_FILE" ]; then
    echo "❌ Configuration file $CONFIG_FILE not found!"
    echo "Please ensure the project was generated properly."
    exit 1
fi

# Parse JSON configuration
PROJECT_NAME=$(grep '"projectName"' "$CONFIG_FILE" | cut -d'"' -f4)
DISPLAY_NAME=$(grep '"displayName"' "$CONFIG_FILE" | cut -d'"' -f4)
BUNDLE_ID=$(grep '"bundleIdentifier"' "$CONFIG_FILE" | cut -d'"' -f4)
DEVICE_UDID=$(grep '"deviceUDID"' "$CONFIG_FILE" | cut -d'"' -f4)
DEVICE_NAME=$(grep '"deviceName"' "$CONFIG_FILE" | cut -d'"' -f4)
SIMULATOR_ID=$(grep '"simulatorId"' "$CONFIG_FILE" | cut -d'"' -f4)
SIMULATOR_NAME=$(grep '"simulatorName"' "$CONFIG_FILE" | cut -d'"' -f4)

# Parse command line arguments
SCHEME="$PROJECT_NAME"
CONFIG="Release"
USE_SIMULATOR=false
USE_DEBUG=false

for arg in "$@"; do
    case $arg in
        --debug)
            USE_DEBUG=true
            SCHEME="$PROJECT_NAME-debug"
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

# Determine target based on configuration and flags
if [ "$USE_SIMULATOR" = true ]; then
    # User explicitly wants simulator
    echo "📲 Building for simulator: $SIMULATOR_NAME"
    SDK="iphonesimulator"
    if [ "$SIMULATOR_ID" = "booted" ]; then
        DESTINATION="platform=iOS Simulator,name=iPhone 15 Pro"
    else
        DESTINATION="platform=iOS Simulator,id=$SIMULATOR_ID"
    fi
    PRODUCTS_DIR="build/Build/Products/${CONFIG}-iphonesimulator"
    TARGET_ID="$SIMULATOR_ID"
    TARGET_NAME="$SIMULATOR_NAME"
    IS_SIMULATOR=true
elif [ "$DEVICE_UDID" = "$SIMULATOR_ID" ] || [ "$DEVICE_UDID" = "booted" ] || [ -z "$DEVICE_UDID" ]; then
    # No physical device configured, use simulator
    echo "📲 Building for simulator: $SIMULATOR_NAME (no device configured)"
    SDK="iphonesimulator"
    if [ "$SIMULATOR_ID" = "booted" ]; then
        DESTINATION="platform=iOS Simulator,name=iPhone 15 Pro"
    else
        DESTINATION="platform=iOS Simulator,id=$SIMULATOR_ID"
    fi
    PRODUCTS_DIR="build/Build/Products/${CONFIG}-iphonesimulator"
    TARGET_ID="$SIMULATOR_ID"
    TARGET_NAME="$SIMULATOR_NAME"
    IS_SIMULATOR=true
else
    # Physical device is primary target
    echo "📱 Building for device: $DEVICE_NAME"
    SDK="iphoneos"
    DESTINATION="platform=iOS,id=$DEVICE_UDID"
    PRODUCTS_DIR="build/Build/Products/${CONFIG}-iphoneos"
    TARGET_ID="$DEVICE_UDID"
    TARGET_NAME="$DEVICE_NAME"
    IS_SIMULATOR=false
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
if [ "$IS_SIMULATOR" = true ]; then
    echo "🚀 Launching in simulator..."
    # Boot simulator if needed
    if [ "$SIMULATOR_ID" != "booted" ]; then
        xcrun simctl boot "$SIMULATOR_ID" 2>/dev/null || true
    else
        xcrun simctl boot "iPhone 15 Pro" 2>/dev/null || true
    fi
    
    # Install app
    if [ "$SIMULATOR_ID" != "booted" ]; then
        xcrun simctl install "$SIMULATOR_ID" "$PRODUCTS_DIR/$DISPLAY_NAME.app"
        xcrun simctl launch "$SIMULATOR_ID" "$BUNDLE_ID"
    else
        xcrun simctl install "iPhone 15 Pro" "$PRODUCTS_DIR/$DISPLAY_NAME.app"
        xcrun simctl launch "iPhone 15 Pro" "$BUNDLE_ID"
    fi
    
    echo "✅ App launched in simulator!"
else
    echo "📱 Installing app on device..."
    xcrun devicectl device install app \
      --device "$DEVICE_UDID" \
      "$PRODUCTS_DIR/$DISPLAY_NAME.app"
    
    if [ $? -ne 0 ]; then
        echo "❌ Installation failed!"
        exit 1
    fi
    
    echo "✅ App installed!"
    echo ""
    
    echo "🚀 Launching app..."
    sleep 1
    
    xcrun devicectl device process launch \
      --device "$DEVICE_UDID" \
      "$BUNDLE_ID"
    
    if [ $? -ne 0 ]; then
        echo "⚠️  Launch command failed (this sometimes happens on first install)"
        echo "The app may have launched successfully anyway. Check your device!"
        exit 0
    fi
    
    echo "✅ App launched successfully!"
fi