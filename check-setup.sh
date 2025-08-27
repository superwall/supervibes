#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
CYAN='\033[0;96m'
NC='\033[0m'

# Check for --brief flag
BRIEF_MODE=false
if [[ "$1" == "--brief" ]]; then
    BRIEF_MODE=true
fi

MISSING_DEPS=0
MISSING_LIST=""

# Function to check if a command exists
check_command() {
    local cmd=$1
    local name=$2
    local install_cmd=$3
    
    if command -v $cmd &> /dev/null; then
        if [ "$BRIEF_MODE" = false ]; then
            echo -e "${GREEN}✓${NC} $name is installed"
            if [ "$cmd" != "xcode-select" ]; then
                $cmd --version 2>/dev/null || $cmd -v 2>/dev/null || echo "   Version: $(which $cmd)"
            fi
        fi
    else
        if [ "$BRIEF_MODE" = true ]; then
            MISSING_LIST="${MISSING_LIST}  ${RED}✗${NC} $name\n"
        else
            echo -e "${RED}✗${NC} $name is not installed"
            echo -e "  ${YELLOW}Install with: ${install_cmd}${NC}"
        fi
        MISSING_DEPS=$((MISSING_DEPS + 1))
    fi
}

# Brief mode - just check and report
if [ "$BRIEF_MODE" = true ]; then
    # Check all requirements silently
    xcode-select -p &> /dev/null || { MISSING_DEPS=$((MISSING_DEPS + 1)); MISSING_LIST="${MISSING_LIST}  ${RED}✗${NC} Xcode Command Line Tools\n"; }
    check_command "brew" "Homebrew" ""
    check_command "xcodegen" "XcodeGen" ""
    
    # Check for swiftformat
    if ! command -v swiftformat &> /dev/null; then
        MISSING_DEPS=$((MISSING_DEPS + 1))
        MISSING_LIST="${MISSING_LIST}  ${RED}✗${NC} SwiftFormat\n"
    fi
    
    check_command "gh" "GitHub CLI" ""
    
    # Return status and show missing dependencies
    if [ $MISSING_DEPS -gt 0 ]; then
        echo -e "${YELLOW}⚠ Missing $MISSING_DEPS required dependencies:${NC}"
        echo -e "$MISSING_LIST"
        echo -e "${YELLOW}Run ${NC}./check-setup.sh${YELLOW} for installation instructions${NC}"
        echo ""
        exit 1
    fi
    
    # All good - exit silently
    exit 0
fi

# Full mode - detailed check with instructions
echo -e "${CYAN}"
echo "═══════════════════════════════════════════════════"
echo "     Supervibes Prerequisites Check"
echo "═══════════════════════════════════════════════════"
echo -e "${NC}"

echo -e "${CYAN}Checking development tools...${NC}"
echo ""

# Check Xcode
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

# Check SwiftFormat
if command -v swiftformat &> /dev/null; then
    echo -e "${GREEN}✓${NC} SwiftFormat is installed"
    swiftformat --version 2>/dev/null || echo "   Version: swiftformat"
else
    echo -e "${RED}✗${NC} SwiftFormat is not installed"
    echo -e "  ${YELLOW}Install with: brew install swiftformat${NC}"
    MISSING_DEPS=$((MISSING_DEPS + 1))
fi

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
    echo -e "${CYAN}./supervibes${NC}"
else
    echo -e "${RED}✗ Missing $MISSING_DEPS required dependencies${NC}"
    echo ""
    echo "Install the missing dependencies above, then run this check again."
fi
echo -e "${CYAN}═══════════════════════════════════════════════════${NC}"