#!/bin/bash

# UI test script for app
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
SIMULATOR_ID=$(grep '"simulatorId"' "$CONFIG_FILE" | cut -d'"' -f4)
SIMULATOR_NAME=$(grep '"simulatorName"' "$CONFIG_FILE" | cut -d'"' -f4)

SCHEME="$PROJECT_NAME-debug"

echo "🖥️  Running UI tests on simulator: $SIMULATOR_NAME..."

# Boot simulator if needed
if [ "$SIMULATOR_ID" != "booted" ]; then
    xcrun simctl boot "$SIMULATOR_ID" 2>/dev/null || true
    DESTINATION="platform=iOS Simulator,id=$SIMULATOR_ID"
else
    xcrun simctl boot "iPhone 15 Pro" 2>/dev/null || true
    DESTINATION="platform=iOS Simulator,name=iPhone 15 Pro"
fi

echo "🧞‍♂️ Generating xcode project..."
xcodegen generate

xcodebuild test \
  -scheme "$SCHEME" \
  -configuration Debug \
  -sdk iphonesimulator \
  -destination "$DESTINATION" \
  -only-testing:"${PROJECT_NAME}UITests" \
  -derivedDataPath build \
  -quiet

if [ $? -eq 0 ]; then
    echo "✅ UI tests passed!"
else
    echo "❌ UI tests failed!"
    exit 1
fi