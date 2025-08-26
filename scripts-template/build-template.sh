#!/bin/bash

# Build script for $displayName app
UDID=$deviceUDID

# Check for --debug flag
if [[ "$1" == "--debug" ]]; then
    SCHEME="$projectName-debug"
    CONFIG="Debug"
    echo "🔧 Using debug scheme: $SCHEME"
else
    SCHEME="$projectName"
    CONFIG="Release"
    echo "🚀 Using release scheme: $SCHEME"
fi

echo "🧞‍♂️ Generating xcode project..."
xcodegen generate

echo "🔨 Building $SCHEME..."
xcodebuild -scheme "$SCHEME" \
  -configuration "$CONFIG" \
  -destination "platform=iOS,id=$UDID" \
  -derivedDataPath build \
  build

if [ $? -eq 0 ]; then
    echo "✅ Build succeeded!"
else
    echo "❌ Build failed!"
    exit 1
fi