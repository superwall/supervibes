#!/bin/bash

# Supervibes Installation Script
# One-liner: curl -fsSL "https://raw.githubusercontent.com/superwall/supervibes/refs/heads/main/install.sh?$(date +%s)" | bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;96m'
NC='\033[0m' # No Color

echo -e "${CYAN}"
echo '   ____                             _ __              '
echo '  / __/__ _____  ___ _____  __(_) /  ___ ___         '
echo ' _\ \/ // / _ \/ -_) __/| |/ / / _ \/ -_|_-<         '
echo '/___/\_,_/ .__/\__/_/   |___/_/_.__/\__/___/         '
echo '        /_/                                           '
echo ''
echo 'Made by Superwall.com'
echo -e "${NC}"
echo ""
echo -e "${GREEN}Installing Supervibes CLI...${NC}"
echo ""

# Check if git is installed
if ! command -v git &> /dev/null; then
    echo -e "${RED}Error: git is not installed${NC}"
    echo "Please install git first:"
    echo "  xcode-select --install"
    exit 1
fi

# Remove old installation if exists
if [ -d ~/.supervibes ]; then
    echo -e "${YELLOW}Removing old installation...${NC}"
    rm -rf ~/.supervibes
fi

# Clone the repository
echo -e "${GREEN}Cloning Supervibes repository...${NC}"
if ! git clone https://github.com/superwall/supervibes.git ~/.supervibes; then
    echo -e "${RED}Failed to clone repository${NC}"
    echo ""
    echo "This is a private repository. Please ensure:"
    echo "  1. You have access to the repository"
    echo "  2. You're authenticated with GitHub"
    echo ""
    echo "Try running:"
    echo "  gh auth login"
    echo "Or setup SSH keys for GitHub"
    exit 1
fi

# Make scripts executable
chmod +x ~/.supervibes/supervibes
chmod +x ~/.supervibes/check-setup.sh

echo -e "${GREEN}✓ Repository cloned successfully${NC}"

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
    echo "  curl -fsSL \"https://raw.githubusercontent.com/superwall/supervibes/refs/heads/main/install.sh?\$(date +%s)\" | bash"
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
echo "To update supervibes:"
echo -e "  ${YELLOW}cd ~/.supervibes && git pull${NC}"
echo ""
echo "To uninstall:"
echo -e "  ${YELLOW}rm -rf ~/.supervibes ~/.local/bin/supervibes${NC}"