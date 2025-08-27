#!/bin/bash

# Install script to install and launch the latest build of app
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
CONFIG="Release"
USE_SIMULATOR=false
USE_DEBUG=false

for arg in "$@"; do
    case $arg in
        --debug)
            USE_DEBUG=true
            CONFIG="Debug"
            ;;
        --simulator)
            USE_SIMULATOR=true
            ;;
    esac
done

# Display configuration
if [ "$USE_DEBUG" = true ]; then
    echo "🔧 Using debug build"
else
    echo "🚀 Using release build"
fi

# Determine SDK and path based on target
if [ "$USE_SIMULATOR" = true ]; then
    SDK_DIR="iphonesimulator"
    echo "📲 Installing to simulator: $SIMULATOR_NAME"
elif [ "$DEVICE_UDID" = "$SIMULATOR_ID" ] || [ "$DEVICE_UDID" = "booted" ] || [ -z "$DEVICE_UDID" ]; then
    SDK_DIR="iphonesimulator"
    echo "📲 Installing to simulator: $SIMULATOR_NAME (no device configured)"
else
    SDK_DIR="iphoneos"
    echo "📱 Installing to device: $DEVICE_NAME"
fi

# Check if build exists
APP_PATH="build/Build/Products/${CONFIG}-${SDK_DIR}/$DISPLAY_NAME.app"
if [ ! -d "$APP_PATH" ]; then
    echo "❌ Build not found at $APP_PATH"
    echo "Run ./build.sh or ./run.sh first to create a build"
    if [ "$USE_SIMULATOR" = true ]; then
        echo "Note: Use --simulator flag with build/run scripts to build for simulator"
    fi
    exit 1
fi

# Install and launch based on target
if [ "$SDK_DIR" = "iphonesimulator" ]; then
    echo "📲 Installing app to simulator..."
    
    # Open Simulator.app if not already running
    if ! pgrep -x "Simulator" > /dev/null; then
        echo "Opening Simulator.app..."
        open -a Simulator
        sleep 2  # Give Simulator.app time to launch
    fi
    
    # Boot simulator if needed
    if [ "$SIMULATOR_ID" != "booted" ]; then
        xcrun simctl boot "$SIMULATOR_ID" 2>/dev/null || true
    else
        xcrun simctl boot "iPhone 15 Pro" 2>/dev/null || true
    fi
    # Install app
    if [ "$SIMULATOR_ID" != "booted" ]; then
        xcrun simctl install "$SIMULATOR_ID" "$APP_PATH"
    else
        xcrun simctl install "iPhone 15 Pro" "$APP_PATH"
    fi
    
    if [ $? -ne 0 ]; then
        echo "❌ Installation failed!"
        exit 1
    fi
    
    echo "✅ App installed!"
    echo ""
    
    echo "🚀 Launching app in simulator..."
    if [ "$SIMULATOR_ID" != "booted" ]; then
        xcrun simctl launch "$SIMULATOR_ID" "$BUNDLE_ID"
    else
        xcrun simctl launch "iPhone 15 Pro" "$BUNDLE_ID"
    fi
    echo "✅ App launched in simulator!"
else
    echo "📱 Installing app on device..."
    xcrun devicectl device install app \
      --device "$DEVICE_UDID" \
      "$APP_PATH"
    
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