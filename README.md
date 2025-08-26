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

1. **Xcode** - Make sure you have Xcode installed
2. **XcodeGen** - Install via Homebrew:
   ```bash
   brew install xcodegen
   ```
3. **Apple Developer Account** - Required for device deployment

### Clone the Repository

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

- **`build.sh`** - Builds the project without running
- **`buildRun.sh`** - Builds and immediately runs on selected device
- **`buildRun.sh --dev`** - Builds and runs the development scheme (with tests)
- **`run.sh`** - Installs and runs the latest build without rebuilding
- **`unit-test.sh`** - Runs unit tests only
- **`ui-test.sh`** - Runs UI tests only

## Configuration

### Schemes

Two schemes are generated:

1. **Production** (`YourProject`) - Optimized for App Store releases
   - No test targets included
   - Release configuration for archives
   
2. **Development** (`YourProject-dev`) - For development and testing
   - Includes unit and UI test targets
   - Different bundle ID (`.dev` suffix)
   - Different app name (adds "Dev" suffix)

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