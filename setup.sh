#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;96m'
NC='\033[0m' # No Color

echo -e "${CYAN}Supervibes Setup Script${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Setup ~/.supervibes
if [ -d "/Users/jake/Projects/supervibes/supervibes-cli" ]; then
    # Development mode - create symlink for entire directory
    echo -e "${YELLOW}Development mode detected - creating symlink${NC}"
    rm -rf ~/.supervibes 2>/dev/null || true
    ln -sf /Users/jake/Projects/supervibes/supervibes-cli ~/.supervibes
    echo -e "${GREEN}✓ Symlinked ~/.supervibes -> /Users/jake/Projects/supervibes/supervibes-cli${NC}"
else
    # Production mode - copy files~
    echo -e "${GREEN}Copying supervibes files...${NC}"
    mkdir -p ~/.supervibes
    cp -r . ~/.supervibes/
    echo -e "${GREEN}✓ Copied files to ~/.supervibes${NC}"
fi

# Create bin directory for wrapper
mkdir -p ~/.local/bin

# Create the main supervibes executable wrapper
echo -e "${GREEN}Creating supervibes command wrapper...${NC}"
cat > ~/.local/bin/supervibes << 'EOF'
#!/bin/bash

# Get the current working directory
WORKING_DIR=$(pwd)

# Path to the actual supervibes script
SUPERVIBES_CLI="$HOME/.supervibes/supervibes"

# Check if supervibes CLI exists
if [ ! -f "$SUPERVIBES_CLI" ]; then
    echo "Error: Supervibes CLI not found at $SUPERVIBES_CLI"
    echo "Please run the setup script again."
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
if [ "$HAS_PROJECTS_DIR" = false ] && [ "$1" != "--test" ]; then
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
        echo -e "${YELLOW}Please manually add ~/.supervibes to your PATH${NC}"
        ;;
esac

# Add to PATH if config file was found
if [ -n "$CONFIG_FILE" ]; then
    # Check if already in PATH
    if ! grep -q "export PATH=\"\$HOME/.local/bin:\$PATH\"" "$CONFIG_FILE"; then
        echo -e "${GREEN}Adding ~/.local/bin to PATH in $CONFIG_FILE...${NC}"
        echo "" >> "$CONFIG_FILE"
        echo "# Supervibes CLI" >> "$CONFIG_FILE"
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$CONFIG_FILE"
        echo -e "${GREEN}✓ Added to PATH${NC}"
    else
        echo -e "${YELLOW}~/.local/bin already in PATH${NC}"
    fi
fi

echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✓ Supervibes installation complete!${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "To start using supervibes, either:"
echo -e "  1. Run: ${CYAN}source $CONFIG_FILE${NC}"
echo -e "  2. Open a new terminal window"
echo ""
echo "Then you can use supervibes from anywhere:"
echo -e "  ${CYAN}supervibes${NC}          - Create project in current directory"
echo -e "  ${CYAN}supervibes --test${NC}   - Quick test mode (uses ./projects)"
echo ""
echo "Configuration file: ~/.supervibes/supervibes.json"