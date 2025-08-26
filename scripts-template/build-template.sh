#!/bin/bash

# Build script for $displayName app
DEFAULT_UDID="$deviceUDID"
DEFAULT_TYPE="$deviceType"

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
    echo "🔧 Using debug scheme: $SCHEME"
else
    echo "🚀 Using release scheme: $SCHEME"
fi

# Set destination based on flags
if [ "$USE_SIMULATOR" = true ]; then
    echo "📲 Building for simulator"
    SDK="iphonesimulator"
    DESTINATION="platform=iOS Simulator,name=iPhone 15 Pro"
elif [ "$DEFAULT_TYPE" = "simulator" ] && [ "$DEFAULT_UDID" = "booted" ]; then
    echo "📲 Building for simulator (default target)"
    SDK="iphonesimulator"
    DESTINATION="platform=iOS Simulator,name=iPhone 15 Pro"
else
    echo "📱 Building for device"
    SDK="iphoneos"
    DESTINATION="platform=iOS,id=$DEFAULT_UDID"
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