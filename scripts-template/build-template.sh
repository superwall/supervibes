#!/bin/bash

# Build script for $displayName app
UDID=$deviceUDID
SCHEME=$projectName

echo "🧞‍♂️ Generating xcode project..."
xcodegen generate

echo "🔨 Building $SCHEME..."
xcodebuild -scheme "$SCHEME" \
  -destination "platform=iOS,id=$UDID" \
  build

if [ $? -eq 0 ]; then
    echo "✅ Build succeeded!"
else
    echo "❌ Build failed!"
    exit 1
fi