#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
CYAN='\033[0;96m'  # Bright cyan for Supervibes branding (#75FFF1)
NC='\033[0m' # No Color

# Default values
DEFAULT_DEPLOYMENT_TARGET="17.0"
DEFAULT_MARKETING_VERSION="1.0.0"
DEFAULT_PROJECT_VERSION="1"
DEFAULT_SWIFT_VERSION="5.0"

# Storage file for last used values
SUPERVIBES_JSON="supervibes.json"

# Arrays for random name generation
COLORS=("red" "blue" "green" "yellow" "purple" "orange" "pink" "cyan" "magenta" "lime")
ANIMALS=("bear" "wolf" "fox" "hawk" "eagle" "tiger" "lion" "panda" "koala" "otter")

# Function to load saved values from xclaude.json
load_saved_values() {
    if [ -f "$SUPERVIBES_JSON" ]; then
        if command -v jq &> /dev/null; then
            SAVED_TEAM_ID=$(jq -r '.teamId // empty' "$SUPERVIBES_JSON" 2>/dev/null)
            SAVED_DEVICE_UDID=$(jq -r '.deviceUdid // empty' "$SUPERVIBES_JSON" 2>/dev/null)
            SAVED_DEVICE_NAME=$(jq -r '.deviceName // empty' "$SUPERVIBES_JSON" 2>/dev/null)
        else
            # Fallback to grep if jq not available
            SAVED_TEAM_ID=$(grep -o '"teamId"[[:space:]]*:[[:space:]]*"[^"]*"' "$SUPERVIBES_JSON" 2>/dev/null | cut -d'"' -f4)
            SAVED_DEVICE_UDID=$(grep -o '"deviceUdid"[[:space:]]*:[[:space:]]*"[^"]*"' "$SUPERVIBES_JSON" 2>/dev/null | cut -d'"' -f4)
            SAVED_DEVICE_NAME=$(grep -o '"deviceName"[[:space:]]*:[[:space:]]*"[^"]*"' "$SUPERVIBES_JSON" 2>/dev/null | cut -d'"' -f4)
        fi
    fi
}

# Function to save values to xclaude.json
save_values() {
    local team_id="$1"
    local device_udid="$2"
    local device_name="$3"
    
    cat > "$SUPERVIBES_JSON" << EOF
{
  "teamId": "$team_id",
  "deviceUdid": "$device_udid",
  "deviceName": "$device_name"
}
EOF
}

# Function to prompt for input with default value
prompt_with_default() {
    local prompt="$1"
    local default="$2"
    local var_name="$3"
    
    if [ -n "$default" ]; then
        echo -e "${BLUE}$prompt${NC} [${YELLOW}$default${NC}]: "
    else
        echo -e "${BLUE}$prompt${NC}: "
    fi
    
    read -r value
    
    if [ -z "$value" ] && [ -n "$default" ]; then
        value="$default"
    fi
    
    eval "$var_name='$value'"
}

# Function to convert to Pascal case (for display name)
to_pascal_case() {
    # Capitalize first letter and letter after each hyphen/underscore
    local input="$1"
    # Remove leading/trailing spaces and convert to lowercase first
    input=$(echo "$input" | tr '[:upper:]' '[:lower:]' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    # Capitalize first letter and letter after - or _
    echo "$input" | awk -F'[-_]' '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) substr($i,2)}1' OFS=""
}

# Function to validate bundle identifier
validate_bundle_id() {
    if [[ ! "$1" =~ ^[a-zA-Z][a-zA-Z0-9]*(\.[a-zA-Z][a-zA-Z0-9]*)+$ ]]; then
        echo -e "${RED}Invalid bundle identifier format. Use reverse domain notation (e.g., com.company.app)${NC}"
        return 1
    fi
    return 0
}

# Check for --test flag
TEST_MODE=false
if [[ "$1" == "--test" ]]; then
    TEST_MODE=true
    # Generate random project name
    COLOR=${COLORS[$RANDOM % ${#COLORS[@]}]}
    ANIMAL=${ANIMALS[$RANDOM % ${#ANIMALS[@]}]}
    DIGITS=$((RANDOM % 90 + 10))
    PROJECT_NAME="${COLOR}${ANIMAL}${DIGITS}"
    
    # Load saved values
    load_saved_values
    
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo -e "     Quick Test Project Generation"
    echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "${YELLOW}Generating test project: $PROJECT_NAME${NC}"
    
    # Set all values using defaults
    DISPLAY_NAME=$(to_pascal_case "$PROJECT_NAME")
    BUNDLE_ID="com.$PROJECT_NAME.app"
    DEV_TEAM="$SAVED_TEAM_ID"
    DEVICE_UDID="$SAVED_DEVICE_UDID"
    SELECTED_DEVICE_NAME="$SAVED_DEVICE_NAME"
    DEPLOYMENT_TARGET="$DEFAULT_DEPLOYMENT_TARGET"
    SWIFT_VERSION="$DEFAULT_SWIFT_VERSION"
    MARKETING_VERSION="$DEFAULT_MARKETING_VERSION"
    PROJECT_VERSION="$DEFAULT_PROJECT_VERSION"
    PROJECT_OVERVIEW="A test iOS application built with SwiftUI."
    
    if [ -z "$DEV_TEAM" ] || [ -z "$DEVICE_UDID" ]; then
        echo -e "${RED}Error: No saved Team ID or Device found!${NC}"
        echo "Please run the generator normally first to save your settings."
        exit 1
    fi
    
    echo -e "Using Team ID: ${YELLOW}$DEV_TEAM${NC}"
    echo -e "Using Device: ${YELLOW}$SELECTED_DEVICE_NAME${NC}"
    echo ""
else
    # Header for normal mode
    echo -e "${CYAN}"
    echo '                                                      '
    echo '    /$$$$$$$                                          '
    echo '   /$$__  $$                                          '
    echo '  | $$  \__/ /$$   /$$ /$$$$$$$   /$$$$$$  /$$$$$$    '
    echo '  |  $$$$$$ | $$  | $$| $$__  $$ /$$__  $$| $$__  $$  '
    echo '   \____  $$| $$  | $$| $$  \ $$| $$$$$$$$| $$  \__/  '
    echo '   /$$  \ $$| $$  | $$| $$  | $$| $$_____/| $$        '
    echo '  |  $$$$$$/|  $$$$$$/| $$$$$$$/|  $$$$$$$| $$        '
    echo '   \______/  \______/ | $$____/  \_______/|__/        '
    echo '                      | $$                            '
    echo '                      | $$                            '
    echo '                      |__/                            '
    echo '              /$$ /$$|                                '
    echo '             |__/| $$|                                '
    echo '   /$$    /$$ /$$| $$$$$$$ | $$$$$$   /$$$$$$$        '
    echo '  |  $$  /$$/| $$| $$__  $$| $$__  $$ /$$_____/       '
    echo '   \  $$/$$/ | $$| $$  \ $$| $$$$$$$$|  $$$$$$        '
    echo '    \  $$$/  | $$| $$  | $$| $$_____/ \____  $$       '
    echo '     \  $/   | $$| $$$$$$$/|  $$$$$$$ /$$$$$$$/       '
    echo '      \_/    |__/|_______/  \_______/|_______/        '
    echo '                                                      '
    echo '                                                      '
    echo '  by Superwall.com                                    '
    echo -e "${NC}"
    echo ""
fi

# Check prerequisites
if [ -f "./check-setup.sh" ]; then
    if ! ./check-setup.sh --brief; then
        exit 1
    fi
fi

# Check if template exists
TEMPLATE_FILE="project-template.yml"
if [ ! -f "$TEMPLATE_FILE" ]; then
    echo -e "${RED}Error: Template file '$TEMPLATE_FILE' not found!${NC}"
    echo "Please ensure the template file exists in the current directory."
    exit 1
fi

# Skip interactive prompts in test mode
if [ "$TEST_MODE" = false ]; then
    # Gather project information
    echo -e "${GREEN}Project Information${NC}"
    echo -e "───────────────────"

# Project name (required - alphanumeric only)
while true; do
    prompt_with_default "Project name (lowercase, alphanumeric only)" "" "PROJECT_NAME"
    if [ -n "$PROJECT_NAME" ]; then
        # Remove non-alphanumeric characters and convert to lowercase
        PROJECT_NAME=$(echo "$PROJECT_NAME" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]//g')
        if [ -z "$PROJECT_NAME" ]; then
            echo -e "${RED}Project name must contain at least one alphanumeric character!${NC}"
        elif [[ "$PROJECT_NAME" =~ ^[0-9]+$ ]]; then
            echo -e "${RED}Project name cannot be all numbers!${NC}"
        elif [[ ! "$PROJECT_NAME" =~ ^[a-z][a-z0-9]*$ ]]; then
            echo -e "${RED}Project name must start with a letter and contain only lowercase letters and numbers!${NC}"
        else
            break
        fi
    else
        echo -e "${RED}Project name is required!${NC}"
    fi
done

# Display name (auto-generate from project name)
DEFAULT_DISPLAY_NAME=$(to_pascal_case "$PROJECT_NAME")
prompt_with_default "Display name" "$DEFAULT_DISPLAY_NAME" "DISPLAY_NAME"

# Bundle identifier (required)
while true; do
    # Project name is already alphanumeric only, so use it directly
    DEFAULT_BUNDLE_ID="com.$PROJECT_NAME.app"
    prompt_with_default "Bundle identifier" "$DEFAULT_BUNDLE_ID" "BUNDLE_ID"
    if validate_bundle_id "$BUNDLE_ID"; then
        break
    fi
done

# Development team (required)
load_saved_values

# Always show help for Team ID
echo ""
echo -e "${YELLOW}How to find your Team ID:${NC}"
echo ""
echo "Visit https://developer.apple.com/account"
echo "Scroll down and copy your Team ID:"
echo ""
echo "┌────────────────────────────────┐"
echo "│       Membership details       │"
echo "├────────────────────────────────┤"
echo "│ Entity name:  Your Company     │"
echo "│ Team ID:      XXXXXXXXXX       │ <- copy this"
echo "└────────────────────────────────┘"
echo ""

while true; do
    prompt_with_default "Development Team ID" "$SAVED_TEAM_ID" "DEV_TEAM"
    if [ -n "$DEV_TEAM" ]; then
        break
    else
        echo -e "${RED}Development Team ID is required!${NC}"
    fi
done

# Device/Simulator selection
echo ""
echo -e "${GREEN}Build Target Configuration${NC}"
echo -e "───────────────────"
echo -e "${BLUE}Select a device or simulator for build scripts${NC}"
echo ""

# Get list of devices and simulators
echo -e "${YELLOW}Loading devices and simulators...${NC}"
DEVICES_OUTPUT=$(xcrun xctrace list devices 2>/dev/null)

# Clear the loading message
echo -e "\033[1A\033[2K"

# Extract physical devices
DEVICES=$(echo "$DEVICES_OUTPUT" | awk '/== Devices ==/{flag=1; next} /== Devices Offline ==|== Simulators ==/{flag=0} flag' | grep -E '\([0-9A-F]{8}-[0-9A-F]{16}\)' || true)

# Extract simulators (filter for iPhone Pro models with highest version)
SIMULATORS=$(echo "$DEVICES_OUTPUT" | awk '/== Simulators ==/{flag=1; next} /^==/{flag=0} flag' | grep "iPhone.*Pro" | sort -t'(' -k2 -rV | head -5 || true)

# Create arrays for all options
declare -a TARGET_NAMES
declare -a TARGET_IDS
declare -a TARGET_TYPES
TARGET_COUNT=0

# Add physical devices
if [ -n "$DEVICES" ]; then
    echo -e "${CYAN}Physical Devices:${NC}"
    while IFS= read -r line; do
        if [ -n "$line" ]; then
            DEVICE_NAME=$(echo "$line" | sed -E 's/ \([0-9A-F]{8}-[0-9A-F]{16}\)$//')
            UDID=$(echo "$line" | grep -oE '[0-9A-F]{8}-[0-9A-F]{16}')
            
            if [ -n "$UDID" ]; then
                TARGET_COUNT=$((TARGET_COUNT + 1))
                TARGET_NAMES+=("$DEVICE_NAME")
                TARGET_IDS+=("$UDID")
                TARGET_TYPES+=("device")
                echo -e "  ${YELLOW}$TARGET_COUNT)${NC} 📱 $DEVICE_NAME"
            fi
        fi
    done <<< "$DEVICES"
fi

# Add simulators
if [ -n "$SIMULATORS" ]; then
    [ $TARGET_COUNT -gt 0 ] && echo ""
    echo -e "${CYAN}Simulators:${NC}"
    while IFS= read -r line; do
        if [ -n "$line" ]; then
            # Extract simulator name and ID
            SIM_NAME=$(echo "$line" | sed -E 's/ \([0-9A-F]{8}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{12}\)$//')
            SIM_ID=$(echo "$line" | grep -oE '[0-9A-F]{8}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{12}')
            
            if [ -n "$SIM_ID" ]; then
                TARGET_COUNT=$((TARGET_COUNT + 1))
                TARGET_NAMES+=("$SIM_NAME")
                TARGET_IDS+=("$SIM_ID")
                TARGET_TYPES+=("simulator")
                echo -e "  ${YELLOW}$TARGET_COUNT)${NC} 📲 $SIM_NAME"
            fi
        fi
    done <<< "$SIMULATORS"
fi

if [ $TARGET_COUNT -eq 0 ]; then
    echo -e "${YELLOW}No devices or simulators found. Using default simulator.${NC}"
    DEVICE_UDID=""
    DEVICE_TYPE="simulator"
else
    echo ""
    echo -e "${BLUE}Select target (1-$TARGET_COUNT) or press Enter for default simulator:${NC} "
    read -r TARGET_SELECTION
    
    if [ -z "$TARGET_SELECTION" ]; then
        echo -e "${YELLOW}Using default simulator${NC}"
        DEVICE_UDID=""
        DEVICE_TYPE="simulator"
    elif [[ "$TARGET_SELECTION" =~ ^[0-9]+$ ]] && [ "$TARGET_SELECTION" -ge 1 ] && [ "$TARGET_SELECTION" -le "$TARGET_COUNT" ]; then
        SELECTED_INDEX=$((TARGET_SELECTION - 1))
        DEVICE_UDID="${TARGET_IDS[$SELECTED_INDEX]}"
        SELECTED_DEVICE_NAME="${TARGET_NAMES[$SELECTED_INDEX]}"
        DEVICE_TYPE="${TARGET_TYPES[$SELECTED_INDEX]}"
        echo -e "${GREEN}Selected: $SELECTED_DEVICE_NAME ($DEVICE_TYPE)${NC}"
    else
        echo -e "${YELLOW}Invalid selection. Using default simulator.${NC}"
        DEVICE_UDID=""
        DEVICE_TYPE="simulator"
    fi
fi

echo ""
echo -e "${GREEN}Version Information${NC}"
echo -e "───────────────────"

# Optional fields with defaults
prompt_with_default "iOS Deployment target" "$DEFAULT_DEPLOYMENT_TARGET" "DEPLOYMENT_TARGET"
prompt_with_default "Swift version" "$DEFAULT_SWIFT_VERSION" "SWIFT_VERSION"

# Use defaults for marketing and project versions
MARKETING_VERSION="$DEFAULT_MARKETING_VERSION"
PROJECT_VERSION="$DEFAULT_PROJECT_VERSION"

echo ""
echo -e "${GREEN}Project Description${NC}"
echo -e "───────────────────"
echo -e "${BLUE}Provide a brief description of your app (for AI assistance):${NC}"
read -r PROJECT_OVERVIEW
if [ -z "$PROJECT_OVERVIEW" ]; then
    PROJECT_OVERVIEW="An iOS application built with SwiftUI."
fi
fi  # End of interactive prompts (TEST_MODE = false)

# Create projects directory if it doesn't exist
mkdir -p ./projects

# Create project directory
PROJECT_DIR="./projects/$PROJECT_NAME"

echo ""
echo -e "${GREEN}Configuration Summary${NC}"
echo -e "───────────────────"
echo -e "Project Name:        ${YELLOW}$PROJECT_NAME${NC}"
echo -e "Display Name:        ${YELLOW}$DISPLAY_NAME${NC}"
echo -e "Bundle ID:           ${YELLOW}$BUNDLE_ID${NC}"
echo -e "Development Team:    ${YELLOW}$DEV_TEAM${NC}"
echo -e "Deployment Target:   ${YELLOW}$DEPLOYMENT_TARGET${NC}"
echo -e "Marketing Version:   ${YELLOW}$MARKETING_VERSION${NC}"
echo -e "Project Version:     ${YELLOW}$PROJECT_VERSION${NC}"
echo -e "Swift Version:       ${YELLOW}$SWIFT_VERSION${NC}"
if [ -n "$DEVICE_UDID" ]; then
    echo -e "Selected Device:     ${YELLOW}$SELECTED_DEVICE_NAME${NC}"
    echo -e "Device UDID:         ${YELLOW}$DEVICE_UDID${NC}"
fi
echo -e "Project Directory:   ${YELLOW}$PROJECT_DIR${NC}"
echo ""

# Save values for future use
if [ "$TEST_MODE" = false ]; then
    save_values "$DEV_TEAM" "$DEVICE_UDID" "$SELECTED_DEVICE_NAME"
fi

# Generate the file
echo -e "${GREEN}Generating configuration...${NC}"

# Create project directory
mkdir -p "$PROJECT_DIR"

# Create project.yml from template in the project directory
OUTPUT_FILE="$PROJECT_DIR/project.yml"
cp "$TEMPLATE_FILE" "$OUTPUT_FILE"

# Replace placeholders
sed -i '' "s/\$projectName/$PROJECT_NAME/g" "$OUTPUT_FILE"
sed -i '' "s/\$displayName/$DISPLAY_NAME/g" "$OUTPUT_FILE"
sed -i '' "s/\$bundleIdentifier/$BUNDLE_ID/g" "$OUTPUT_FILE"
sed -i '' "s/\$developmentTeam/$DEV_TEAM/g" "$OUTPUT_FILE"
sed -i '' "s/\$deploymentTarget/$DEPLOYMENT_TARGET/g" "$OUTPUT_FILE"
sed -i '' "s/\$marketingVersion/$MARKETING_VERSION/g" "$OUTPUT_FILE"
sed -i '' "s/\$projectVersion/$PROJECT_VERSION/g" "$OUTPUT_FILE"
sed -i '' "s/\$swiftVersion/$SWIFT_VERSION/g" "$OUTPUT_FILE"

# Handle test target naming
sed -i '' "s/\$projectNameTests/${PROJECT_NAME}Tests/g" "$OUTPUT_FILE"
sed -i '' "s/\$projectNameUITests/${PROJECT_NAME}UITests/g" "$OUTPUT_FILE"

echo -e "${GREEN}✓ Configuration generated successfully!${NC}"

# Generate build and run scripts
echo ""
echo -e "${GREEN}Generating scripts...${NC}"

# Set device/simulator configuration
if [ -z "$DEVICE_UDID" ]; then
    SCRIPT_DEVICE_UDID="booted"
    SCRIPT_DEVICE_TYPE="simulator"
else
    SCRIPT_DEVICE_UDID="$DEVICE_UDID"
    SCRIPT_DEVICE_TYPE="${DEVICE_TYPE:-device}"
fi
    
# Check if scripts-template folder exists
if [ -d "scripts-template" ]; then
    # Create scripts directory in project
    mkdir -p "$PROJECT_DIR/scripts"
    
    # Copy and process all template scripts
    for template in scripts-template/*-template.sh; do
        if [ -f "$template" ]; then
            # Get the base name without -template suffix
            script_name=$(basename "$template" | sed 's/-template//')
            target="$PROJECT_DIR/scripts/$script_name"
            
            # Copy template
            cp "$template" "$target"
            
            # Replace placeholders
            sed -i '' "s/\$projectName/$PROJECT_NAME/g" "$target"
            sed -i '' "s/\$displayName/$DISPLAY_NAME/g" "$target"
            sed -i '' "s/\$bundleIdentifier/$BUNDLE_ID/g" "$target"
            sed -i '' "s/\$deviceUDID/$SCRIPT_DEVICE_UDID/g" "$target"
            sed -i '' "s/\$deviceType/$SCRIPT_DEVICE_TYPE/g" "$target"
            
            # Make executable
            chmod +x "$target"
        fi
    done
    
    echo -e "${GREEN}✓ Scripts generated in scripts/ folder!${NC}"
    if [ "$SCRIPT_DEVICE_TYPE" = "simulator" ]; then
        echo -e "${CYAN}Note: Scripts configured for simulator${NC}"
    else
        echo -e "${CYAN}Note: Scripts configured for physical device${NC}"
    fi
else
    echo -e "${YELLOW}Warning: scripts-template folder not found${NC}"
fi

echo ""
echo -e "Next steps:"
echo -e "1. Review the generated ${YELLOW}$OUTPUT_FILE${NC}"
echo -e "2. Run: ${YELLOW}cd $PROJECT_DIR && scripts/build.sh${NC} to build only"
echo -e "3. Run: ${YELLOW}cd $PROJECT_DIR && scripts/run.sh${NC} to build and run"
echo -e "4. Run: ${YELLOW}cd $PROJECT_DIR && scripts/install.sh${NC} to install the last build"
echo -e "5. Run: ${YELLOW}cd $PROJECT_DIR && scripts/unit-test.sh${NC} to run unit tests"
echo -e "6. Run: ${YELLOW}cd $PROJECT_DIR && scripts/ui-test.sh${NC} to run UI tests"
if [ "$SCRIPT_DEVICE_TYPE" = "simulator" ]; then
    echo -e ""
    echo -e "${CYAN}Note: Add --simulator flag to use simulator instead of default${NC}"
fi
echo ""

# Create initial Swift files and directories
echo ""
echo -e "${GREEN}Creating initial project structure...${NC}"

# Create main app source directory
mkdir -p "$PROJECT_DIR/$PROJECT_NAME"

# Create main app file
cat > "$PROJECT_DIR/$PROJECT_NAME/${PROJECT_NAME}App.swift" << EOF
import SwiftUI

@main
struct ${DISPLAY_NAME}App: App {
  var body: some Scene {
    WindowGroup {
      ContentView()
    }
  }
}
EOF

    # Create Assets.xcassets directory structure
    mkdir -p "$PROJECT_DIR/$PROJECT_NAME/Assets.xcassets"
    mkdir -p "$PROJECT_DIR/$PROJECT_NAME/Assets.xcassets/AccentColor.colorset"
    mkdir -p "$PROJECT_DIR/$PROJECT_NAME/Assets.xcassets/AppIcon.appiconset"
    
    # Create Contents.json for Assets.xcassets
    cat > "$PROJECT_DIR/$PROJECT_NAME/Assets.xcassets/Contents.json" << 'EOF'
{
  "info": {
    "author": "xcode",
    "version": 1
  }
}
EOF
    
    # Create AccentColor.colorset Contents.json with cyan color (#75FFF1)
    cat > "$PROJECT_DIR/$PROJECT_NAME/Assets.xcassets/AccentColor.colorset/Contents.json" << 'EOF'
{
  "colors": [
    {
      "color": {
        "color-space": "srgb",
        "components": {
          "red": "0.459",
          "green": "1.000",
          "blue": "0.945",
          "alpha": "1.000"
        }
      },
      "idiom": "universal"
    }
  ],
  "info": {
    "author": "xcode",
    "version": 1
  }
}
EOF
    
    # Create AppIcon.appiconset Contents.json
    cat > "$PROJECT_DIR/$PROJECT_NAME/Assets.xcassets/AppIcon.appiconset/Contents.json" << 'EOF'
{
  "images": [
    {
      "filename": "icon.png",
      "idiom": "universal",
      "platform": "ios",
      "size": "1024x1024"
    }
  ],
  "info": {
    "author": "xcode",
    "version": 1
  }
}
EOF
    
    # Create ContentView
    cat > "$PROJECT_DIR/$PROJECT_NAME/ContentView.swift" << EOF
import SwiftUI

struct ContentView: View {
  var body: some View {
    VStack {
      Image(systemName: "globe")
        .imageScale(.large)
        .foregroundStyle(.tint)
      Text("Hello, world!")
    }
    .padding()
  }
}

#Preview {
  ContentView()
}
EOF

    # Create test directories with sample tests
    mkdir -p "$PROJECT_DIR/${PROJECT_NAME}Tests"
    # Use display name without spaces for module name
    MODULE_NAME=$(echo "$DISPLAY_NAME" | tr -d ' ')
    cat > "$PROJECT_DIR/${PROJECT_NAME}Tests/${PROJECT_NAME}Tests.swift" << EOF
import XCTest
@testable import ${MODULE_NAME}

final class ${PROJECT_NAME}Tests: XCTestCase {
  func testExample() throws {
    XCTAssertEqual(1 + 1, 2)
  }
}
EOF

    mkdir -p "$PROJECT_DIR/${PROJECT_NAME}UITests"
    cat > "$PROJECT_DIR/${PROJECT_NAME}UITests/${PROJECT_NAME}UITests.swift" << EOF
import XCTest

final class ${PROJECT_NAME}UITests: XCTestCase {
  override func setUpWithError() throws {
    continueAfterFailure = false
  }

  func testLaunch() throws {
    let app = XCUIApplication()
    app.launch()
  }
}
EOF

echo -e "${GREEN}✓ Project structure created!${NC}"

# Copy claude-template.md as CLAUDE.md if it exists
if [ -f "claude-template.md" ]; then
    echo ""
    echo -e "${GREEN}Creating CLAUDE.md documentation...${NC}"
    # Copy and replace the ProjectOverview placeholder
    awk -v overview="$PROJECT_OVERVIEW" '{gsub(/<ProjectOverview\/>/, overview)}1' "claude-template.md" > "$PROJECT_DIR/CLAUDE.md"
    echo -e "${GREEN}✓ CLAUDE.md created!${NC}"
fi

# Copy claude-template folder as .claude if it exists
if [ -d "claude-template" ]; then
    echo ""
    echo -e "${GREEN}Setting up Claude AI assistance...${NC}"
    cp -r claude-template "$PROJECT_DIR/.claude"
    
    # Fetch XcodeGen docs and replace placeholder in xcodegen-config-specialist.md
    if [ -f "$PROJECT_DIR/.claude/agents/xcodegen-config-specialist.md" ]; then
        echo "Fetching XcodeGen documentation..."
        XCODEGEN_DOCS=$(curl -s https://raw.githubusercontent.com/yonaskolb/XcodeGen/refs/heads/master/Docs/ProjectSpec.md)
        if [ $? -eq 0 ] && [ -n "$XCODEGEN_DOCS" ]; then
            # Save original file and create new one with replacement
            ORIGINAL_FILE="$PROJECT_DIR/.claude/agents/xcodegen-config-specialist.md"
            TEMP_FILE=$(mktemp)
            
            # Read the original file and replace the placeholder
            while IFS= read -r line; do
                if [[ "$line" == *"<XcodeGenDocs/>"* ]]; then
                    echo "$XCODEGEN_DOCS"
                else
                    echo "$line"
                fi
            done < "$ORIGINAL_FILE" > "$TEMP_FILE"
            
            mv "$TEMP_FILE" "$ORIGINAL_FILE"
            echo -e "${GREEN}✓ XcodeGen documentation integrated!${NC}"
        else
            echo -e "${YELLOW}Warning: Could not fetch XcodeGen documentation${NC}"
        fi
    fi
    
    echo -e "${GREEN}✓ Claude AI assistance configured!${NC}"
fi

# Run xcodegen
echo ""
if command -v xcodegen &> /dev/null; then
    echo -e "${GREEN}Running xcodegen...${NC}"
    cd "$PROJECT_DIR"
    xcodegen generate
    echo -e "${GREEN}✓ Xcode project generated!${NC}"
    cd ../..
else
    echo -e "${RED}xcodegen is not installed.${NC}"
    echo "Install it with: brew install xcodegen"
    echo "Then run: cd $PROJECT_DIR && xcodegen generate"
fi