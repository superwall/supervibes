#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
CYAN='\033[0;96m'
NC='\033[0m'

echo -e "${CYAN}"
echo "═══════════════════════════════════════════════════"
echo "     Supervibes Prerequisites Check"
echo "═══════════════════════════════════════════════════"
echo -e "${NC}"

MISSING_DEPS=0

# Function to check if a command exists
check_command() {
    local cmd=$1
    local name=$2
    local install_cmd=$3
    
    if command -v $cmd &> /dev/null; then
        echo -e "${GREEN}✓${NC} $name is installed"
        if [ "$cmd" != "xcode-select" ]; then
            $cmd --version 2>/dev/null || $cmd -v 2>/dev/null || echo "   Version: $(which $cmd)"
        fi
    else
        echo -e "${RED}✗${NC} $name is not installed"
        echo -e "  ${YELLOW}Install with: ${install_cmd}${NC}"
        MISSING_DEPS=$((MISSING_DEPS + 1))
    fi
}

# Check Xcode
echo -e "${CYAN}Checking development tools...${NC}"
echo ""

if xcode-select -p &> /dev/null; then
    echo -e "${GREEN}✓${NC} Xcode Command Line Tools installed"
    echo "   Path: $(xcode-select -p)"
else
    echo -e "${RED}✗${NC} Xcode Command Line Tools not installed"
    echo -e "  ${YELLOW}Install with: xcode-select --install${NC}"
    MISSING_DEPS=$((MISSING_DEPS + 1))
fi

# Check Homebrew
check_command "brew" "Homebrew" '/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'

# Check XcodeGen
check_command "xcodegen" "XcodeGen" "brew install xcodegen"

# Check Swift Format
check_command "swift-format" "Swift Format" "brew install swift-format"

# Check GitHub CLI
if command -v gh &> /dev/null; then
    echo -e "${GREEN}✓${NC} GitHub CLI is installed"
    gh --version | head -1
    
    # Check if authenticated
    if gh auth status &> /dev/null; then
        echo -e "  ${GREEN}✓${NC} GitHub authentication configured"
    else
        echo -e "  ${YELLOW}!${NC} Not authenticated. Run: gh auth login"
    fi
else
    echo -e "${RED}✗${NC} GitHub CLI is not installed"
    echo -e "  ${YELLOW}Install with: brew install gh${NC}"
    MISSING_DEPS=$((MISSING_DEPS + 1))
fi

# Check Node/npm (for Claude Code)
echo ""
echo -e "${CYAN}Checking optional tools...${NC}"
echo ""

if command -v node &> /dev/null; then
    echo -e "${GREEN}✓${NC} Node.js is installed"
    echo "   Version: $(node --version)"
else
    echo -e "${YELLOW}!${NC} Node.js is not installed (needed for Claude Code)"
    echo -e "  ${YELLOW}Install with: brew install node${NC}"
fi

# Check Claude Code
if command -v claude &> /dev/null; then
    echo -e "${GREEN}✓${NC} Claude Code is installed"
    claude -v 2>/dev/null || echo "   Claude CLI available"
else
    echo -e "${YELLOW}!${NC} Claude Code is not installed (optional but recommended)"
    echo -e "  ${YELLOW}Install with: npm install -g @anthropic-ai/claude-code${NC}"
fi

# Check code signing identities
echo ""
echo -e "${CYAN}Checking Apple Developer setup...${NC}"
echo ""

IDENTITIES=$(security find-identity -v -p codesigning 2>/dev/null | grep -c "Apple Development\|Apple Distribution")

if [ "$IDENTITIES" -gt 0 ]; then
    echo -e "${GREEN}✓${NC} Found $IDENTITIES code signing identities"
    echo ""
    echo "Available identities:"
    security find-identity -v -p codesigning | grep "Apple" | head -5
else
    echo -e "${YELLOW}!${NC} No code signing identities found"
    echo -e "  Make sure Xcode is signed in to your Apple Developer account"
    echo -e "  Xcode → Settings → Accounts → Add your Apple ID"
fi

# Summary
echo ""
echo -e "${CYAN}═══════════════════════════════════════════════════${NC}"
if [ $MISSING_DEPS -eq 0 ]; then
    echo -e "${GREEN}✓ All required dependencies are installed!${NC}"
    echo ""
    echo "You're ready to use Supervibes! Run:"
    echo -e "${CYAN}./generate.sh${NC}"
else
    echo -e "${RED}✗ Missing $MISSING_DEPS required dependencies${NC}"
    echo ""
    echo "Install the missing dependencies above, then run this check again."
fi
echo -e "${CYAN}═══════════════════════════════════════════════════${NC}"