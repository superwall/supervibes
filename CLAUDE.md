# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is an iOS project generator system that automates the creation of SwiftUI iOS projects using XcodeGen. It generates complete project structures with build/run scripts for physical iOS devices.

## Architecture

The system uses a template-based approach:
- **generate.sh**: Interactive CLI that collects project parameters and generates a complete iOS project
- **Template files**: Define the structure for generated projects
  - `project-template.yml`: XcodeGen project specification with placeholders
  - `scripts-template/`: Folder containing all script templates
    - `build-template.sh`: Build script for physical devices  
    - `buildRun-template.sh`: Build, install, and launch script
    - `run-template.sh`: Install and launch latest build script
    - `unit-test-template.sh`: Run unit tests only
    - `ui-test-template.sh`: Run UI tests only

## Key Commands

### Generate a new iOS project
```bash
./generate.sh
```
This will:
1. Prompt for project details (name, bundle ID, team ID)
2. Show available physical devices for selection
3. Create project folder with Swift files
4. Generate customized build/run scripts
5. Run xcodegen to create Xcode project

### Build/run generated projects
```bash
cd projects/<project-name>
scripts/build.sh         # Build only
scripts/buildRun.sh      # Build, install, and launch on device (production scheme)
scripts/buildRun.sh --dev # Build, install, and launch on device (development scheme)
scripts/run.sh           # Install and launch latest build
scripts/run.sh --dev     # Install and launch latest dev build
scripts/unit-test.sh     # Run unit tests only (uses -dev scheme)
scripts/ui-test.sh       # Run UI tests only (uses -dev scheme)
```

The `--dev` flag:
- Uses the `<project>-dev` scheme
- Installs with `.dev` bundle identifier suffix  
- Shows as "<AppName> Dev" on device

### Testing Configuration
- **Production scheme**: No tests configured (optimized for running)
- **Development scheme (-dev)**: Includes both unit and UI tests
- Tests use the correct module name (display name without spaces)
- TEST_HOST properly configured for unit tests to link with main app

## Template Placeholders

The templates use these placeholders that get replaced during generation:
- `$projectName` - Lowercase project/scheme name
- `$displayName` - Pascal case app display name (used for PRODUCT_NAME)
- `$bundleIdentifier` - App bundle ID
- `$developmentTeam` - Apple Developer Team ID  
- `$deviceUDID` - Physical device UDID from xcrun xctrace
- `$deploymentTarget` - iOS deployment version
- `$marketingVersion` - App version
- `$projectVersion` - Build number
- `$swiftVersion` - Swift language version

## Important Technical Details

### App Bundle Name
The app bundle uses `$displayName.app` (e.g., "Jake3.app") not the scheme name. This is set via PRODUCT_NAME in project.yml configs.

### Source Directory Structure
Projects are generated in `./projects/` subdirectory. Each project uses `path: $projectName` for sources to avoid including build artifacts. The structure is:
```
/projects/
  /projectName/
    /project.yml
    /projectName/          # Source files only
      /Assets.xcassets     # Asset catalog
      /*.swift             # Swift source files
    /projectNameTests/
    /projectNameUITests/
    /scripts/              # All build/run/test scripts
      /build.sh
      /buildRun.sh
      /run.sh
      /unit-test.sh
      /ui-test.sh
    /.claude/              # Claude AI assistance files
    /CLAUDE.md             # Project-specific Claude documentation
```

### Device Selection
The script uses `xcrun xctrace list devices` to enumerate connected devices and parses the format:
```
Device Name (iOS Version) (UDID-FORMAT)
```

### Known Issues

1. **First launch error**: On first install, `xcrun devicectl device process launch` may fail with error 10004 even though the app launches successfully. The run script handles this with a warning message and exits cleanly.

2. **Build directory conflicts**: If sources use `path: .` instead of `path: $projectName`, XcodeGen will include build artifacts causing "Multiple commands produce" errors.

## Dependencies

Required tools:
- xcodegen (install via: `brew install xcodegen`)
- Xcode with command line tools
- Physical iOS device with developer mode enabled