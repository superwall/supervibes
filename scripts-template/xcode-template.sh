#!/bin/bash

# Open Xcode project
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

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check if Xcode project exists
if [ ! -d "$PROJECT_NAME.xcodeproj" ]; then
    echo -e "${RED}❌ Xcode project not found!${NC}"
    echo "Run 'xcodegen generate' first to create the project"
    exit 1
fi

# Open the project in Xcode
echo "📱 Opening $DISPLAY_NAME in Xcode..."
open "$PROJECT_NAME.xcodeproj"

echo -e "${GREEN}✅ Opened in Xcode${NC}"