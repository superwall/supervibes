#!/bin/bash

# Unit test script for $displayName app
UDID=$deviceUDID
SCHEME="$projectName-debug"

echo "🧪 Running unit tests..."

xcodebuild test \
  -scheme "$SCHEME" \
  -configuration Debug \
  -sdk iphoneos \
  -destination "platform=iOS,id=$UDID" \
  -only-testing:"$projectNameTests" \
  -derivedDataPath build \
  -quiet

if [ $? -eq 0 ]; then
    echo "✅ Unit tests passed!"
else
    echo "❌ Unit tests failed!"
    exit 1
fi