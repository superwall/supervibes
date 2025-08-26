#!/bin/bash

# Build script for app
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
    echo "🔧 Using debug scheme: $SCHEME"
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
elif [ "$DEVICE_UDID" = "$SIMULATOR_ID" ] || [ "$DEVICE_UDID" = "booted" ] || [ -z "$DEVICE_UDID" ]; then
    # No physical device configured, use simulator
    echo "📲 Building for simulator: $SIMULATOR_NAME (no device configured)"
    SDK="iphonesimulator"
    if [ "$SIMULATOR_ID" = "booted" ]; then
        DESTINATION="platform=iOS Simulator,name=iPhone 15 Pro"
    else
        DESTINATION="platform=iOS Simulator,id=$SIMULATOR_ID"
    fi
else
    # Physical device is primary target
    echo "📱 Building for device: $DEVICE_NAME"
    SDK="iphoneos"
    DESTINATION="platform=iOS,id=$DEVICE_UDID"
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

if [ $? -eq 0 ]; then
    echo "✅ Build succeeded!"
else
    echo "❌ Build failed!"
    exit 1
fi