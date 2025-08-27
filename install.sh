#!/bin/bash

# Supervibes Installation Script
# One-liner: curl -fsSL https://raw.githubusercontent.com/superwall/supervibes/main/supervibes-cli/install.sh | bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;96m'
NC='\033[0m' # No Color

# GitHub repository details
GITHUB_REPO="superwall/supervibes"
BRANCH="main"
BASE_URL="https://raw.githubusercontent.com/$GITHUB_REPO/$BRANCH/supervibes-cli"

echo -e "${CYAN}"
echo ''
echo 'Made with ❤️ by Superwall.com'
echo -e "${NC}"
echo ""
echo -e "${GREEN}Installing Supervibes CLI...${NC}"
echo ""

# Create ~/.supervibes directory
echo -e "${GREEN}Creating ~/.supervibes directory...${NC}"
mkdir -p ~/.supervibes

# Download all necessary files
echo -e "${GREEN}Downloading Supervibes files...${NC}"

# Core files to download
FILES=(
    "supervibes"
    "project-template.yml"
    "check-setup.sh"
    "claude-template.md"
)

# Download each file
for file in "${FILES[@]}"; do
    echo -e "  Downloading $file..."
    if ! curl -fsSL "$BASE_URL/$file" -o ~/.supervibes/"$file"; then
        echo -e "${RED}Failed to download $file${NC}"
        exit 1
    fi
done

# Make scripts executable
chmod +x ~/.supervibes/supervibes
chmod +x ~/.supervibes/check-setup.sh

# Download template directories
echo -e "${GREEN}Downloading template directories...${NC}"

# Create directories
mkdir -p ~/.supervibes/scripts-template
mkdir -p ~/.supervibes/claude-template/agents

# Download script templates
SCRIPT_TEMPLATES=(
    "build-template.sh"
    "install-template.sh"
    "run-template.sh"
    "ui-test-template.sh"
    "unit-test-template.sh"
)

for template in "${SCRIPT_TEMPLATES[@]}"; do
    echo -e "  Downloading scripts-template/$template..."
    if ! curl -fsSL "$BASE_URL/scripts-template/$template" -o ~/.supervibes/scripts-template/"$template"; then
        echo -e "${RED}Failed to download $template${NC}"
        exit 1
    fi
done

# Download Claude templates
CLAUDE_AGENTS=(
    "settings.local.json"
)

CLAUDE_AGENT_FILES=(
    "swift-test-writer.md"
    "xcodegen-config-specialist.md"
)

# Download settings.local.json
echo -e "  Downloading claude-template/settings.local.json..."
curl -fsSL "$BASE_URL/claude-template/settings.local.json" -o ~/.supervibes/claude-template/settings.local.json 2>/dev/null || true

# Download agent files
for agent in "${CLAUDE_AGENT_FILES[@]}"; do
    echo -e "  Downloading claude-template/agents/$agent..."
    curl -fsSL "$BASE_URL/claude-template/agents/$agent" -o ~/.supervibes/claude-template/agents/"$agent" 2>/dev/null || true
done

# Create bin directory
mkdir -p ~/.local/bin

# Create the supervibes wrapper script
echo -e "${GREEN}Creating supervibes command...${NC}"
cat > ~/.local/bin/supervibes << 'EOF'
#!/bin/bash

# Get the current working directory
WORKING_DIR=$(pwd)

# Path to the actual supervibes script
SUPERVIBES_CLI="$HOME/.supervibes/supervibes"

# Check if supervibes CLI exists
if [ ! -f "$SUPERVIBES_CLI" ]; then
    echo "Error: Supervibes CLI not found at $SUPERVIBES_CLI"
    echo "Please run the installation script again:"
    echo "  curl -fsSL https://raw.githubusercontent.com/superwall/supervibes/main/supervibes-cli/install.sh | bash"
    exit 1
fi

# Parse arguments and handle --projects-dir
ARGS=()
HAS_PROJECTS_DIR=false

for arg in "$@"; do
    if [[ "$arg" == --projects-dir* ]]; then
        HAS_PROJECTS_DIR=true
    fi
    ARGS+=("$arg")
done

# If no --projects-dir specified, use current directory
if [ "$HAS_PROJECTS_DIR" = false ]; then
    # Add current directory as projects directory
    exec "$SUPERVIBES_CLI" "${ARGS[@]}" --projects-dir="$WORKING_DIR"
else
    # Pass through all arguments as-is
    exec "$SUPERVIBES_CLI" "${ARGS[@]}"
fi
EOF

chmod +x ~/.local/bin/supervibes

# Detect shell and update appropriate config file
SHELL_NAME=$(basename "$SHELL")
CONFIG_FILE=""

case "$SHELL_NAME" in
    bash)
        if [ -f ~/.bash_profile ]; then
            CONFIG_FILE=~/.bash_profile
        elif [ -f ~/.bashrc ]; then
            CONFIG_FILE=~/.bashrc
        else
            CONFIG_FILE=~/.bash_profile
            touch "$CONFIG_FILE"
        fi
        ;;
    zsh)
        CONFIG_FILE=~/.zshrc
        if [ ! -f "$CONFIG_FILE" ]; then
            touch "$CONFIG_FILE"
        fi
        ;;
    *)
        echo -e "${YELLOW}Unknown shell: $SHELL_NAME${NC}"
        echo -e "${YELLOW}Please manually add ~/.local/bin to your PATH${NC}"
        ;;
esac

# Add to PATH if config file was found
if [ -n "$CONFIG_FILE" ]; then
    # Check if ~/.local/bin is already in PATH
    if ! grep -q 'export PATH="$HOME/.local/bin:$PATH"' "$CONFIG_FILE"; then
        echo -e "${GREEN}Adding ~/.local/bin to PATH in $CONFIG_FILE...${NC}"
        echo "" >> "$CONFIG_FILE"
        echo "# Local bin directory (for supervibes)" >> "$CONFIG_FILE"
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$CONFIG_FILE"
        echo -e "${GREEN}✓ Added to PATH${NC}"
        PATH_ADDED=true
    else
        echo -e "${YELLOW}~/.local/bin already in PATH${NC}"
        PATH_ADDED=false
    fi
fi

echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✓ Supervibes installed successfully!${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

if [ "$PATH_ADDED" = true ]; then
    echo "To start using supervibes, either:"
    echo -e "  1. Run: ${CYAN}source $CONFIG_FILE${NC}"
    echo -e "  2. Open a new terminal window"
    echo ""
fi

echo "Usage:"
echo -e "  ${CYAN}supervibes${NC}          - Create project in current directory"
echo -e "  ${CYAN}supervibes --test${NC}   - Quick test mode"
echo ""
echo "Installation directory: ~/.supervibes"
echo "Configuration file: ~/.supervibes/supervibes.json"
echo ""
echo "To uninstall, run:"
echo -e "  ${YELLOW}rm -rf ~/.supervibes ~/.local/bin/supervibes${NC}"