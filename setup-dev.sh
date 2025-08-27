#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;96m'
NC='\033[0m' # No Color

echo -e "${CYAN}"
echo "╔══════════════════════════════════════════════╗"
echo "║     Supervibes Development Setup              ║"
echo "╚══════════════════════════════════════════════╝"
echo -e "${NC}"

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Create symlink for development
echo -e "${GREEN}Creating development symlink...${NC}"
rm -rf ~/.supervibes-dev 2>/dev/null || true
ln -sf "$SCRIPT_DIR" ~/.supervibes-dev
echo -e "${GREEN}✓ Symlinked ~/.supervibes-dev -> $SCRIPT_DIR${NC}"

# Create bin directory
mkdir -p ~/.local/bin

# Create the supervibes-dev wrapper script
echo -e "${GREEN}Creating supervibes-dev command...${NC}"
cat > ~/.local/bin/supervibes-dev << 'EOF'
#!/bin/bash

# Get the current working directory
WORKING_DIR=$(pwd)

# Path to the actual supervibes script
SUPERVIBES_CLI="$HOME/.supervibes-dev/supervibes"

# Check if supervibes CLI exists
if [ ! -f "$SUPERVIBES_CLI" ]; then
    echo "Error: Supervibes CLI not found at $SUPERVIBES_CLI"
    echo "Please run setup-dev.sh again."
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

chmod +x ~/.local/bin/supervibes-dev

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
        echo "# Local bin directory (for supervibes-dev)" >> "$CONFIG_FILE"
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$CONFIG_FILE"
        echo -e "${GREEN}✓ Added to PATH${NC}"
    else
        echo -e "${YELLOW}~/.local/bin already in PATH${NC}"
    fi
fi

echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✓ Development setup complete!${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "To start using supervibes-dev, either:"
echo -e "  1. Run: ${CYAN}source $CONFIG_FILE${NC}"
echo -e "  2. Open a new terminal window"
echo ""
echo "Then you can use:"
echo -e "  ${CYAN}supervibes-dev${NC}          - Create project in current directory"
echo -e "  ${CYAN}supervibes-dev --test${NC}   - Quick test mode"
echo ""
echo "Development directory: $SCRIPT_DIR"
echo "Configuration file: ~/.supervibes-dev/supervibes.json"