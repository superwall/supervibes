#!/bin/bash

# UI test script for $displayName app
UDID=$deviceUDID
SCHEME="$projectName-dev"

echo "🖥️  Running UI tests..."

xcodebuild test \
  -scheme "$SCHEME" \
  -configuration DebugDev \
  -sdk iphoneos \
  -destination "platform=iOS,id=$UDID" \
  -only-testing:"$projectNameUITests" \
  -derivedDataPath build \
  -quiet

if [ $? -eq 0 ]; then
    echo "✅ UI tests passed!"
else
    echo "❌ UI tests failed!"
    exit 1
fi