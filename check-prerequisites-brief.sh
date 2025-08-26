#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m'

MISSING_DEPS=0
MISSING_LIST=""

# Function to check if a command exists
check_command() {
    local cmd=$1
    local name=$2
    
    if ! command -v $cmd &> /dev/null; then
        MISSING_DEPS=$((MISSING_DEPS + 1))
        MISSING_LIST="${MISSING_LIST}  ${RED}✗${NC} $name\n"
        return 1
    fi
    return 0
}

# Check all requirements silently
xcode-select -p &> /dev/null || { MISSING_DEPS=$((MISSING_DEPS + 1)); MISSING_LIST="${MISSING_LIST}  ${RED}✗${NC} Xcode Command Line Tools\n"; }
check_command "brew" "Homebrew"
check_command "xcodegen" "XcodeGen"

# Check for either swift-format or swiftformat
if ! command -v swift-format &> /dev/null && ! command -v swiftformat &> /dev/null; then
    MISSING_DEPS=$((MISSING_DEPS + 1))
    MISSING_LIST="${MISSING_LIST}  ${RED}✗${NC} Swift Format (swiftformat or swift-format)\n"
fi

check_command "gh" "GitHub CLI"

# Return status and show missing dependencies
if [ $MISSING_DEPS -gt 0 ]; then
    echo -e "${YELLOW}⚠ Missing $MISSING_DEPS required dependencies:${NC}"
    echo -e "$MISSING_LIST"
    echo -e "${YELLOW}Run ${NC}./check-prerequisites.sh${YELLOW} for installation instructions${NC}"
    echo ""
    exit 1
fi

# All good - exit silently
exit 0