# Supervibes 🎵

A streamlined iOS project generator with XcodeGen integration, built by [Superwall](https://superwall.com).

```
    /$$$$$$$                                          
   /$$__  $$                                          
  | $$  \__/ /$$   /$$ /$$$$$$$   /$$$$$$  /$$$$$$    
  |  $$$$$$ | $$  | $$| $$__  $$ /$$__  $$| $$__  $$  
   \____  $$| $$  | $$| $$  \ $$| $$$$$$$$| $$  \__/  
   /$$  \ $$| $$  | $$| $$  | $$| $$_____/| $$        
  |  $$$$$$/|  $$$$$$/| $$$$$$$/|  $$$$$$$| $$        
   \______/  \______/ | $$____/  \_______/|__/        
                      | $$                            
                      | $$                            
                      |__/                            
              /$$ /$$|                                
             |__/| $$|                                
   /$$    /$$ /$$| $$$$$$$ | $$$$$$   /$$$$$$$        
  |  $$  /$$/| $$| $$__  $$| $$__  $$ /$$_____/       
   \  $$/$$/ | $$| $$  \ $$| $$$$$$$$|  $$$$$$        
    \  $$$/  | $$| $$  | $$| $$_____/ \____  $$       
     \  $/   | $$| $$$$$$$/|  $$$$$$$ /$$$$$$$/       
      \_/    |__/|_______/  \_______/|_______/        
```

## Features

- 🚀 **Quick Setup** - Generate a complete iOS project in seconds
- 📱 **Device Detection** - Automatically detects connected iOS devices
- 🎨 **SwiftUI Templates** - Modern SwiftUI app structure out of the box
- 🛠 **Build Scripts** - Pre-configured scripts for building, running, and testing
- 🧪 **Test Configuration** - Separate schemes for development with unit and UI tests
- 💾 **Smart Defaults** - Remembers your Team ID and device selection
- 🎯 **XcodeGen Integration** - Clean project configuration with `project.yml`
- 🤖 **Claude AI Ready** - Includes CLAUDE.md for AI-assisted development

## Installation

### Prerequisites

Before using Supervibes, ensure you have all the required tools installed.

**Quick check:** Run our setup checker to see what's missing:
```bash
./check-setup.sh
```

#### Manual Installation

#### 1. **Xcode & Command Line Tools**
Make sure Xcode is installed from the App Store and command line tools are set up:
```bash
xcode-select --install
```

#### 2. **Homebrew**
The package manager for macOS. If not installed:
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

#### 3. **XcodeGen**
For generating Xcode projects from YAML specifications:
```bash
brew install xcodegen
xcodegen --version  # Verify installation
```

#### 4. **Swift Format**
For consistent code formatting across generated projects (either one):
```bash
brew install swiftformat     # Recommended (Nick Lockwood's SwiftFormat)
# OR
brew install swift-format    # Apple's swift-format
```

#### 5. **GitHub CLI**
For repository operations and pull request management:
```bash
brew install gh
gh auth login  # Follow the prompts to authenticate
```

#### 6. **Claude Code** (Optional but Recommended)
For AI-powered development assistance:
```bash
npm install -g @anthropic-ai/claude-code
claude -v  # Verify installation
```

If you don't have npm, install Node.js first:
```bash
brew install node
```

#### 7. **Apple Developer Setup**
- Ensure you have an active Apple Developer account
- Your development certificates should be properly configured

To view available code signing identities:
```bash
security find-identity -v -p codesigning
```

You should see output like:
```
1) XXXXXXXXXX "Apple Development: Your Name (TEAMID)"
2) XXXXXXXXXX "Apple Distribution: Your Name (TEAMID)"
```

### Clone the Repository

Once all prerequisites are installed:

```bash
git clone https://github.com/superwall/supervibes.git
cd supervibes
```

## Usage

### Interactive Mode

Run the generator and follow the prompts:

```bash
./generate.sh
```

You'll be asked for:
- Project name (lowercase, alphanumeric)
- Display name
- Bundle identifier
- Development Team ID (with visual guide to find it)
- Device selection (optional, for deployment scripts)
- Project description (for AI assistance)

### Quick Test Mode

Generate a test project with a random name using saved settings:

```bash
./generate.sh --test
```

This requires running the interactive mode at least once to save your Team ID and device.

## What Gets Generated

```
projects/YourProject/
├── project.yml                 # XcodeGen configuration
├── YourProject/                # Source code
│   ├── YourProjectApp.swift   # App entry point
│   └── ContentView.swift      # Main view
├── YourProjectTests/           # Unit tests
├── YourProjectUITests/         # UI tests  
├── scripts/                    # Automation scripts
│   ├── build.sh               # Build only
│   ├── buildRun.sh            # Build and run on device
│   ├── run.sh                 # Run latest build
│   ├── unit-test.sh           # Run unit tests
│   └── ui-test.sh             # Run UI tests
├── CLAUDE.md                   # Project documentation for Claude AI
└── .claude/                    # Claude AI configuration
    └── agents/                 # Specialized AI agents
```

## Build Scripts

All scripts are generated in the `scripts/` directory of your project:

- **`build.sh`** - Builds the project in release mode
- **`build.sh --debug`** - Builds the project in debug mode
- **`buildRun.sh`** - Builds and runs on device (release mode)
- **`buildRun.sh --debug`** - Builds and runs on device (debug mode with tests)
- **`run.sh`** - Installs and runs the latest release build
- **`run.sh --debug`** - Installs and runs the latest debug build
- **`unit-test.sh`** - Runs unit tests (uses debug scheme)
- **`ui-test.sh`** - Runs UI tests (uses debug scheme)

## Configuration

### Schemes

Two schemes are generated:

1. **Release** (`YourProject`) - Optimized for production
   - No test targets
   - Release configuration
   - Used by default in scripts
   
2. **Debug** (`YourProject-debug`) - For development and testing
   - Includes unit and UI test targets
   - Debug configuration with symbols
   - Used with `--debug` flag in scripts

### Saved Settings

Your Team ID and device selection are automatically saved in `supervibes.json` for future use.

### Finding Your Team ID

The generator shows a visual guide:

```
Visit https://developer.apple.com/account
Scroll down and copy your Team ID:

┌────────────────────────────────┐
│       Membership details       │
├────────────────────────────────┤
│ Entity name:  Your Company     │
│ Team ID:      XXXXXXXXXX       │ <- copy this
└────────────────────────────────┘
```

## Claude AI Integration

Each project includes:
- **CLAUDE.md** - Project-specific documentation with your project overview
- **.claude/** - Configuration directory with specialized AI agents
- Modern Swift development guidelines
- XcodeGen documentation integration

## Contributing

This is an internal Superwall tool. For issues or suggestions, please contact the iOS team.

## License

Private repository - Superwall internal use only.

---

Built with 💙 by [Superwall](https://superwall.com)