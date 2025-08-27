# Supervibes ⚡️

An opinionated workflow for using Claude Code to build native swift iOS apps, mostly without (but definitely alongside) Xcode. Built by [Superwall](https://superwall.com).

```
   /$$$$$$$
  /$$__  $$
 | $$  \__/ /$$   /$$ /$$$$$$$   /$$$$$$  /$$$$$$
 |  $$$$$$ | $$  | $$| $$__  $$ /$$__  $$| $$__  $$
  \____  $$| $$  | $$| $$  \ $$| $$$$$$$$| $$  \__/
  /$$  \ $$| $$  | $$| $$  | $$| $$_____/| $$
 |  $$$$$$/|  $$$$$$/| $$$$$$$/|  $$$$$$$| $$  /$$  /$$|
  \______/  \______/ | $$____/  \_______/|__/ |__/ | $$|
                     | $$           /$$    /$$ /$$ | $$$$$$$ | $$$$$$   /$$$$$$$
                     | $$          |  $$  /$$/| $$ | $$__  $$| $$__  $$ /$$_____/
                     |__/           \  $$/$$/ | $$ | $$  \ $$| $$$$$$$$|  $$$$$$
                                     \  $$$/  | $$ | $$  | $$| $$_____/ \____  $$
                                      \  $/   | $$ | $$$$$$$/|  $$$$$$$ /$$$$$$$/
                                       \_/    |__/ |_______/  \_______/|_______/

```

## Features

- 🚀 **Quick Setup** - Generate a complete iOS project in seconds
- 📱 **Build to Device** - Automatically builds to connected iOS devices
- 🎨 **SwiftUI Templates** - Modern SwiftUI app structure out of the box
- 🛠 **Build Scripts** - Scripts for building, running, and testing from the terminal
- 🧪 **Test Configuration** - Separate schemes for development with unit and UI tests
- 🎯 **XcodeGen Integration** - Create files outside of Xcode while maintaining interoperability
- 🤖 **Claude AI Ready** - Battle tested Agents & CLAUDE.md files

## Generated Project Structure

```
projects/YourProject/
├── project.yml                 # XcodeGen configuration
├── YourProject/                # Source code
│   ├── YourProjectApp.swift   # App entry point
│   └── ContentView.swift      # Main view
├── YourProjectTests/           # Unit tests
├── YourProjectUITests/         # UI tests
├── scripts/                    # Automation scripts
│   ├── build               # Build only
│   ├── run                 # Build and run on device
│   ├── install             # Install and run latest build
│   ├── unit-test           # Run unit tests
│   └── ui-test             # Run UI tests
├── CLAUDE.md                   # Project documentation for Claude AI
└── .claude/                    # Claude AI configuration
    └── agents/                 # Specialized AI agents
```

## Build Scripts

All scripts are generated in the `scripts/` directory of your project:

| Script      | Description                        | Flags                    |
| ----------- | ---------------------------------- | ------------------------ |
| `build`     | Builds the project                 | `--debug`, `--simulator` |
| `run`       | Builds and runs the app            | `--debug`, `--simulator` |
| `install`   | Installs and launches latest build | `--debug`, `--simulator` |
| `unit-test` | Runs unit tests (debug scheme)     | -                        |
| `ui-test`   | Runs UI tests (debug scheme)       | -                        |

**Flag descriptions:**

- `--debug` - Uses debug configuration with test support
- `--simulator` - Targets iOS simulator instead of physical device
- Flags can be combined: `scripts/run --debug --simulator`

## Installation

### Quick Install

Install Supervibes with one command:

```bash
curl -fsSL "https://raw.githubusercontent.com/superwall/supervibes/refs/heads/main/supervibes-cli/install.sh?$(date +%s)" | bash
```

Then restart your terminal or run:

```bash
source ~/.zshrc  # or ~/.bashrc for bash
```

### Prerequisites

Before using Supervibes, ensure you have all the required tools installed.

**Quick check:** Run our setup checker to see what's missing:

```bash
supervibes-check  # After installation
# or
~/.supervibes/check-setup.sh  # Direct path
```

#### Required Tools

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

#### 4. **SwiftFormat**

For consistent code formatting across generated projects:

```bash
brew install swiftformat
swiftformat --version  # Verify installation
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

You'll need your Apple Developer Team ID. To find it:

1. Visit https://developer.apple.com/account
2. Sign in with your Apple ID
3. Scroll down to "Membership details" and copy your Team ID:

```
┌────────────────────────────────┐
│       Membership details       │
├────────────────────────────────┤
│ Entity name:  Your Company     │
│ Team ID:      XXXXXXXXXX       │ <- copy this
│ Entity type:  Organization     │
└────────────────────────────────┘
```

## Getting Started

Once Supervibes is installed, you can use it from any directory:

### Interactive Mode

Navigate to where you want your project and run:

```bash
supervibes
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
./supervibes --test
```

This requires running the interactive mode at least once to save your Team ID and device.

### Custom Projects Directory

By default, projects are generated in `./projects`. You can specify a different directory:

```bash
./supervibes --projects-dir=/path/to/custom/directory
# or
./supervibes --projects-dir /path/to/custom/directory
```

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

## Acknowledgments

Supervibes stands on the shoulders of giants. Special thanks to:

- **[XcodeGen](https://github.com/yonaskolb/XcodeGen)** by Yonas Kolb - The foundation of our project generation
- **[SwiftFormat](https://github.com/nicklockwood/SwiftFormat)** by Nick Lockwood - Keeping our code beautifully formatted
- **[Claude Code](https://claude.ai/code)** by Anthropic - AI-powered development assistance

## Contributing

This is an internal Superwall tool (for now)! Please implement the features you think are necessary for launch.

## License

Private repository - Superwall internal use only.

## Development Setup

If you want to contribute to Supervibes or run the development version:

```bash
# Clone the repository
git clone https://github.com/superwall/supervibes.git
cd supervibes/supervibes-cli

# Run the development setup
./setup-dev.sh
```

This creates `supervibes-dev` command that runs from your development directory.

## Uninstall

To remove Supervibes:

```bash
rm -rf ~/.supervibes ~/.local/bin/supervibes
```

For development version:

```bash
rm -rf ~/.supervibes-dev ~/.local/bin/supervibes-dev
```

---

Built with 💙 by [Superwall](https://superwall.com)
