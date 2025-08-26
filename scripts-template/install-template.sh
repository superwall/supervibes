#!/bin/bash

# Install script to install and launch the latest build of $displayName app
DEFAULT_UDID="$deviceUDID"
DEFAULT_TYPE="$deviceType"
BUNDLE_ID=$bundleIdentifier

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
    echo "📲 Installing to simulator"
elif [ "$DEFAULT_TYPE" = "simulator" ] && [ "$DEFAULT_UDID" = "booted" ]; then
    SDK_DIR="iphonesimulator"
    echo "📲 Installing to simulator (default target)"
else
    SDK_DIR="iphoneos"
    echo "📱 Installing to device"
fi

# Check if build exists
APP_PATH="build/Build/Products/${CONFIG}-${SDK_DIR}/$displayName.app"
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
    # Boot simulator if needed
    xcrun simctl boot "iPhone 15 Pro" 2>/dev/null || true
    # Install app
    xcrun simctl install "iPhone 15 Pro" "$APP_PATH"
    
    if [ $? -ne 0 ]; then
        echo "❌ Installation failed!"
        exit 1
    fi
    
    echo "✅ App installed!"
    echo ""
    
    echo "🚀 Launching app in simulator..."
    xcrun simctl launch "iPhone 15 Pro" "$BUNDLE_ID"
    echo "✅ App launched in simulator!"
else
    echo "📱 Installing app on device..."
    xcrun devicectl device install app \
      --device "$DEFAULT_UDID" \
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
      --device "$DEFAULT_UDID" \
      "$BUNDLE_ID"
    
    if [ $? -ne 0 ]; then
        echo "⚠️  Launch command failed (this sometimes happens on first install)"
        echo "The app may have launched successfully anyway. Check your device!"
        exit 0
    fi
    
    echo "✅ App launched successfully!"
fi