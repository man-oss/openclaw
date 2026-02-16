# Build and Release Process

## Overview

OpenClaw uses a comprehensive build system based on **pnpm** for package management, **tsdown** for TypeScript compilation, and platform-specific scripts for desktop and mobile builds. The project supports multiple platforms: macOS (desktop and iOS), Android, Linux, and Windows, with automated CI/CD pipelines and release processes.

## Build System Architecture

### Core Build Technologies

- **Package Manager**: pnpm 10.23.0 (required)
- **Node Version**: >=22.12.0 (required, see `package.json` engines)
- **TypeScript Compiler**: tsdown for production builds
- **Type Checking**: Native TypeScript 5.9.3
- **Bundler**: rolldown 1.0.0-rc.4 for UI components

### Build Directory Structure

```
openclaw/
├── dist/                    # Compiled JavaScript output
│   ├── index.js            # Main entry point
│   ├── plugin-sdk/         # Plugin SDK compiled files
│   └── protocol.schema.json # Generated protocol schema
├── apps/
│   ├── macos/              # macOS native app
│   ├── ios/                # iOS native app
│   └── android/            # Android native app
├── scripts/                # Build and release scripts
├── ui/                     # Web UI components
└── openclaw.mjs           # CLI entry point
```

## Build Commands

### Primary Build Script

**Location**: `package.json` scripts section

```bash
# Full production build
pnpm build
```

**Build Pipeline** (`scripts.build`):
```bash
pnpm canvas:a2ui:bundle &&           # Bundle A2UI canvas components
tsdown &&                            # Compile TypeScript to JavaScript
pnpm build:plugin-sdk:dts &&        # Generate plugin SDK type definitions
node --import tsx scripts/write-plugin-sdk-entry-dts.ts &&  # Write SDK entry types
node --import tsx scripts/canvas-a2ui-copy.ts &&            # Copy canvas assets
node --import tsx scripts/copy-hook-metadata.ts &&          # Copy hook metadata
node --import tsx scripts/write-build-info.ts &&            # Generate build info
node --import tsx scripts/write-cli-compat.ts               # Write CLI compatibility
```

### Component Build Scripts

#### Plugin SDK Type Definitions

**Script**: `scripts/build:plugin-sdk:dts`
```bash
tsc -p tsconfig.plugin-sdk.dts.json
```

Generates TypeScript declaration files for the plugin SDK located at `dist/plugin-sdk/index.d.ts`.

#### Canvas A2UI Bundling

**Script**: `scripts/canvas:a2ui:bundle`
**Implementation**: `scripts/bundle-a2ui.sh`

Bundles the A2UI (Agent-to-UI) canvas components for web rendering.

#### Build Metadata Generation

**Script**: `scripts/write-build-info.ts`

Generates build metadata including:
- Git commit hash
- Build timestamp
- Version number (from `package.json`)

**Output**: `dist/build-info.json`

#### CLI Compatibility Layer

**Script**: `scripts/write-cli-compat.ts`

Generates CLI compatibility information for backward compatibility checks.

### Development Build Commands

```bash
# Development mode with hot reload
pnpm dev

# Watch mode for continuous compilation
pnpm gateway:watch

# Development with environment variables
OPENCLAW_SKIP_CHANNELS=1 pnpm dev
```

**Implementation**: `scripts/run-node.mjs` and `scripts/watch-node.mjs`

## Platform-Specific Builds

### macOS Desktop Application

#### Package Creation

**Script**: `scripts/package-mac-app.sh`
```bash
pnpm mac:package
```

**Key Steps** (from `scripts/package-mac-app.sh`):
1. Builds Node.js application using `pnpm build`
2. Creates `.app` bundle structure
3. Copies compiled assets to `Contents/Resources`
4. Sets executable permissions
5. Generates `Info.plist` with version information

#### Code Signing

**Script**: `scripts/codesign-mac-app.sh`

Signs the macOS application bundle with Apple Developer certificate:
```bash
# Environment variables required:
# - APPLE_CERTIFICATE_ID: Developer certificate identifier
# - APPLE_KEYCHAIN_PROFILE: Keychain profile name

bash scripts/codesign-mac-app.sh dist/OpenClaw.app
```

**Process**:
1. Signs all nested frameworks and libraries
2. Signs the main application bundle
3. Applies hardened runtime entitlements
4. Verifies signature with `codesign --verify`

#### Notarization

**Script**: `scripts/notarize-mac-artifact.sh`

Submits app to Apple notarization service:
```bash
# Environment variables required:
# - APPLE_ID: Apple Developer account email
# - APPLE_TEAM_ID: 10-character team identifier
# - APPLE_APP_SPECIFIC_PASSWORD: App-specific password

bash scripts/notarize-mac-artifact.sh dist/OpenClaw.app
```

#### DMG Creation

**Script**: `scripts/create-dmg.sh`

Creates distributable disk image:
```bash
bash scripts/create-dmg.sh
```

**Output**: `dist/OpenClaw-{version}-universal.dmg`

#### Distribution Packaging

**Script**: `scripts/package-mac-dist.sh`

Combines all macOS packaging steps:
```bash
bash scripts/package-mac-dist.sh
```

**Full Pipeline**:
1. Builds application (`pnpm build`)
2. Creates `.app` bundle
3. Code signs the application
4. Notarizes with Apple
5. Creates DMG installer
6. Generates update appcast (see `scripts/make_appcast.sh`)

#### Development Commands

```bash
# Open macOS app
pnpm mac:open

# Build and run development version
bash scripts/build-and-run-mac.sh

# Restart macOS app during development
pnpm mac:restart
```

**Script**: `scripts/restart-mac.sh` - Kills and relaunches the macOS app.

### iOS Application

#### Project Generation

**Script**: `ios:gen` using XcodeGen

```bash
# Generate Xcode project
pnpm ios:gen

# Open in Xcode
pnpm ios:open
```

**Configuration**: `apps/ios/project.yml` (XcodeGen specification)

#### Building

```bash
# Build for simulator
pnpm ios:build

# Run on simulator
pnpm ios:run
```

**Environment Variables**:
- `IOS_DEST`: Build destination (default: `platform=iOS Simulator,name=iPhone 17`)
- `IOS_SIM`: Simulator name (default: `iPhone 17`)

**Implementation** (from `package.json`):
```bash
xcodebuild -project OpenClaw.xcodeproj \
  -scheme OpenClaw \
  -destination "platform=iOS Simulator,name=iPhone 17" \
  -configuration Debug build
```

#### Team ID Detection

**Script**: `scripts/ios-team-id.sh`

Detects Apple Developer Team ID from provisioning profiles or keychain.

### Android Application

#### Build Commands

```bash
# Assemble debug APK
pnpm android:assemble

# Install to connected device
pnpm android:install

# Build, install, and run
pnpm android:run

# Run unit tests
pnpm android:test
```

**Implementation**:
- **Build System**: Gradle (via `apps/android/gradlew`)
- **Output**: `apps/android/app/build/outputs/apk/debug/app-debug.apk`

**Run Command** (from `package.json`):
```bash
cd apps/android && \
  ./gradlew :app:installDebug && \
  adb shell am start -n ai.openclaw.android/.MainActivity
```

## Protocol Generation

### TypeScript Protocol Schema

**Script**: `scripts/protocol-gen.ts`
```bash
pnpm protocol:gen
```

**Output**: `dist/protocol.schema.json`

Generates JSON schema for the gateway protocol used in cross-platform communication.

### Swift Protocol Models

**Script**: `scripts/protocol-gen-swift.ts`
```bash
pnpm protocol:gen:swift
```

**Output**: `apps/macos/Sources/OpenClawProtocol/GatewayModels.swift`

Generates Swift model classes from TypeScript protocol definitions for iOS/macOS apps.

### Protocol Verification

```bash
# Verify protocol sync across platforms
pnpm protocol:check
```

Ensures protocol definitions are synchronized between TypeScript and Swift implementations.

## UI Build System

### UI Build Scripts

**Script**: `scripts/ui.js`

```bash
# Install UI dependencies
pnpm ui:install

# Build production UI
pnpm ui:build

# Development mode with hot reload
pnpm ui:dev

# Run UI tests
pnpm ui:test
```

**UI Technologies**:
- **Framework**: Lit 3.3.2 (web components)
- **Context**: @lit/context 1.1.6
- **Signals**: @lit-labs/signals 0.2.0

## CI/CD Pipeline

### GitHub Actions Workflows

**Location**: `.github/workflows/`

The repository uses GitHub Actions for automated testing and deployment.

### Workflow Configuration

**Actionlint Configuration**: `.github/actionlint.yaml`

Validates GitHub Actions workflow files with custom rules:
```yaml
self-hosted-runner:
  labels:
    - ubuntu-latest
    - macos-latest
    - windows-latest
```

### Custom GitHub Actions

**Location**: `.github/actions/`

Contains reusable composite actions for common CI tasks.

### Dependency Management

**Dependabot Configuration**: `.github/dependabot.yml`

Automated dependency updates for:
- npm packages
- GitHub Actions
- Docker images (if applicable)

**Settings**:
- Update interval: weekly
- Security updates: immediate
- Grouped updates by ecosystem

### PR Labeling

**Configuration**: `.github/labeler.yml`

Automatically applies labels to pull requests based on changed files (7,017 bytes of rules).

## Testing Infrastructure

### Test Execution

```bash
# Run all tests (parallelized)
pnpm test

# Run specific test suites
pnpm test:fast        # Unit tests only
pnpm test:e2e         # End-to-end tests
pnpm test:live        # Live API tests (requires credentials)

# Run all test suites
pnpm test:all
```

**Parallel Test Runner**: `scripts/test-parallel.mjs`

Executes test suites in parallel with configurable concurrency:
- Supports VM-specific configurations
- Handles test isolation
- Aggregates results

### Test Configurations

**Vitest Configs**:
- `vitest.unit.config.ts`: Unit tests
- `vitest.e2e.config.ts`: End-to-end tests
- `vitest.live.config.ts`: Live integration tests

### Coverage Reports

```bash
pnpm test:coverage
```

Generates coverage reports using `@vitest/coverage-v8`.

### Docker-Based Testing

```bash
# Run all Docker tests
pnpm test:docker:all

# Individual Docker test suites
pnpm test:docker:live-models      # Live model testing
pnpm test:docker:live-gateway     # Gateway integration
pnpm test:docker:onboard          # Onboarding flow
pnpm test:docker:gateway-network  # Network testing
pnpm test:docker:qr               # QR code import
pnpm test:docker:doctor-switch    # Doctor mode switching
pnpm test:docker:plugins          # Plugin system
pnpm test:docker:cleanup          # Cleanup test artifacts
```

**Scripts Location**: `scripts/e2e/*.sh` and `scripts/test-*-docker.sh`

### Installation Testing

```bash
# Test installation script
pnpm test:install:smoke    # Basic smoke test
pnpm test:install:e2e      # Full E2E installation test

# Provider-specific tests
pnpm test:install:e2e:anthropic
pnpm test:install:e2e:openai
```

**Implementation**:
- `scripts/test-install-sh-docker.sh`: Basic installation verification
- `scripts/test-install-sh-e2e-docker.sh`: Full E2E installation flow

### Performance Testing

**Slowest Tests Analysis**: `scripts/vitest-slowest.mjs`

Identifies slowest test cases for optimization.

## Version Management

### Version Format

**Current Version**: `2026.2.16` (from `package.json`)

**Format**: `YYYY.M.D` (Calendar Versioning)
- Year: 2026
- Month: 2
- Day: 16

### Release Verification

**Script**: `scripts/release-check.ts`
```bash
pnpm release:check
```

**Checks**:
1. Version consistency across `package.json` and platform manifests
2. CHANGELOG.md updates
3. Git tag existence
4. Build artifact integrity

### Plugin Version Synchronization

**Script**: `scripts/sync-plugin-versions.ts`
```bash
pnpm plugins:sync
```

Ensures plugin versions match core version across:
- `extensions/*/package.json`
- Plugin manifests
- Documentation

## Distribution and Packaging

### Package Contents

**Files Included** (from `package.json` files field):
```
CHANGELOG.md
LICENSE
openclaw.mjs          # CLI entry point
README-header.png
README.md
assets/               # Static assets
dist/                 # Compiled code
docs/                 # Documentation
extensions/           # Plugin extensions
skills/               # AI skills
```

### NPM Package Configuration

**Binary**: `openclaw` (points to `openclaw.mjs`)

**Exports** (from `package.json`):
```javascript
{
  ".": "./dist/index.js",
  "./plugin-sdk": {
    "types": "./dist/plugin-sdk/index.d.ts",
    "default": "./dist/plugin-sdk/index.js"
  },
  "./plugin-sdk/account-id": {
    "types": "./dist/plugin-sdk/account-id.d.ts",
    "default": "./dist/plugin-sdk/account-id.js"
  },
  "./cli-entry": "./openclaw.mjs"
}
```

### Pre-pack Hook

**Script**: `prepack` (from `package.json`)
```bash
pnpm build && pnpm ui:build
```

Runs before `npm pack` to ensure fresh builds.

## Asset and Icon Management

### Icon Generation

**Script**: `scripts/build_icon.sh`

Generates platform-specific icons from source assets:
- macOS: `.icns` format
- iOS: `.xcassets` bundle
- Android: Various `mipmap-*` densities

**Input**: High-resolution source image
**Outputs**: Platform-specific icon files

### Changelog Conversion

**Script**: `scripts/changelog-to-html.sh`

Converts `CHANGELOG.md` to HTML for embedding in applications:
```bash
bash scripts/changelog-to-html.sh
```

**Output**: `dist/changelog.html`

## Code Quality and Formatting

### Linting

```bash
# Run linters
pnpm lint              # TypeScript/JavaScript (oxlint)
pnpm lint:swift        # Swift (SwiftLint)
pnpm lint:docs         # Markdown (markdownlint)
pnpm lint:all          # All linters

# Auto-fix issues
pnpm lint:fix          # Fix TS/JS issues
pnpm lint:docs:fix     # Fix markdown issues
```

**Configuration**:
- **oxlint**: Type-aware linting with oxlint 1.47.0
- **SwiftLint**: `.swiftlint.yml` configuration
- **markdownlint**: `.markdownlint.json` rules

### Formatting

```bash
# Format code
pnpm format            # TypeScript/JavaScript (oxfmt)
pnpm format:swift      # Swift (swiftformat)
pnpm format:docs       # Documentation only
pnpm format:all        # All code

# Check formatting without changes
pnpm format:check
pnpm format:docs:check
```

**Tools**:
- **oxfmt** 0.32.0: Fast TypeScript/JavaScript formatter
- **swiftformat**: Swift code formatter (`.swiftformat` config)

### Pre-commit Hooks

**Script**: `scripts/prepare` (from `package.json`)

Sets up Git hooks on `npm install`:
```bash
git config core.hooksPath git-hooks
```

**Hook Scripts**: `scripts/pre-commit/`

### Code Metrics

**Line of Code Check**: `scripts/check-ts-max-loc.ts`
```bash
pnpm check:loc
```

Enforces maximum 500 lines per TypeScript file.

## Documentation Build System

### Documentation Links

```bash
# Build documentation list
pnpm docs:list
pnpm docs:bin

# Check documentation links
pnpm docs:check-links

# Verify all documentation
pnpm check:docs
```

**Scripts**:
- `scripts/docs-list.js`: Generates documentation index
- `scripts/build-docs-list.mjs`: Builds documentation manifest
- `scripts/docs-link-audit.mjs`: Validates all documentation links

### Documentation Development

```bash
# Run local docs server
pnpm docs:dev
```

Uses **Mintlify** for documentation hosting (see `docs/mint.json`).

### Documentation Synchronization

**Script**: `scripts/sync-moonshot-docs.ts`

Synchronizes documentation with external Moonshot platform.

## Cross-Platform Build Considerations

### Node.js Native Modules

**Peer Dependencies** (from `package.json`):
```json
{
  "@napi-rs/canvas": "^0.1.89",
  "node-llama-cpp": "3.15.1"
}
```

**Build-Only Dependencies** (`pnpm.onlyBuiltDependencies`):
```
@lydell/node-pty
@matrix-org/matrix-sdk-crypto-nodejs
@napi-rs/canvas
@whiskeysockets/baileys
authenticate-pam
esbuild
node-llama-cpp
protobufjs
sharp
```

These require compilation during installation.

### Platform-Specific Scripts

**macOS/iOS**:
- Shell scripts use `bash -lc` for login shell environment
- Xcode project generation via XcodeGen
- Code signing and notarization pipeline

**Android**:
- Gradle wrapper (`gradlew`) for builds
- ADB integration for device deployment

**Linux**:
- Systemd service configuration (`scripts/systemd/`)
- Podman/Docker container support (`scripts/podman/`, `scripts/docker/`)

### Container Builds

**Docker Scripts**:
- `scripts/docker/*`: Docker build configurations
- `scripts/podman/*`: Podman-specific scripts
- `scripts/run-openclaw-podman.sh`: Podman execution wrapper

**Sandbox Setup**:
- `scripts/sandbox-setup.sh`: Basic sandbox environment
- `scripts/sandbox-browser-setup.sh`: Browser sandbox
- `scripts/sandbox-common-setup.sh`: Shared sandbox utilities

## Development Utilities

### Build and Run Shortcuts

```bash
# macOS development
bash scripts/build-and-run-mac.sh

# Node.js development with auto-reload
pnpm dev

# Gateway development (skip channels)
pnpm gateway:dev
pnpm gateway:dev:reset  # With database reset

# TUI development
pnpm tui:dev
```

### Monitoring and Debugging

**Authentication Monitor**: `scripts/auth-monitor.sh`

Monitors authentication state during development.

**Claude Auth Status**: `scripts/claude-auth-status.sh`

Checks Claude API authentication status and credentials.

**Process Recovery**: `scripts/recover-orphaned-processes.sh`

Cleans up orphaned processes from crashed development sessions.

### Developer Tools

**PR Management**: `scripts/pr`, `scripts/pr-merge`, `scripts/pr-prepare`, `scripts/pr-review`

Command-line tools for pull request workflows.

**Committer Tool**: `scripts/committer`

Interactive commit message helper.

**Clawlog**: `scripts/clawlog.sh`

Formatted log viewing utility.

## Security and Dependencies

### Dependency Overrides

**pnpm Overrides** (from `package.json`):
```json
{
  "fast-xml-parser": "5.3.4",
  "form-data": "2.5.4",
  "qs": "6.14.2",
  "@sinclair/typebox": "0.34.48",
  "tar": "7.5.9",
  "tough-cookie": "4.1.3"
}
```

Applied for security patches and compatibility.

### Minimum Release Age

**pnpm Configuration**:
```json
{
  "minimumReleaseAge": 2880  // 48 hours in minutes
}
```

Prevents installation of packages released within 48 hours (supply chain attack mitigation).

## Environment Configuration

### Required Environment Variables

**macOS Signing and Notarization**:
- `APPLE_CERTIFICATE_ID`: Code signing certificate
- `APPLE_KEYCHAIN_PROFILE`: Keychain profile name
- `APPLE_ID`: Apple Developer account
- `APPLE_TEAM_ID`: Developer team identifier
- `APPLE_APP_SPECIFIC_PASSWORD`: App-specific password

**Development**:
- `OPENCLAW_SKIP_CHANNELS`: Skip channel initialization
- `OPENCLAW_PROFILE`: Development profile selection
- `OPENCLAW_LIVE_TEST`: Enable live API tests
- `OPENCLAW_E2E_MODELS`: Model provider for E2E tests

**Testing**:
- `OPENCLAW_TEST_VM_FORKS`: Number of test forks (0 for serial)
- `OPENCLAW_TEST_PROFILE`: Test execution profile

### Configuration Files

**Environment Loading**: Uses `dotenv` (version 17.3.1)

**Config Locations**:
- `.env`: Local environment variables (gitignored)
- `.env.example`: Template for required variables

## Maintenance Scripts

### Contributor Management

**Update Contributors**: `scripts/update-clawtributors.ts`

Updates contributor list from Git history and GitHub API.

**Contributor Mapping**: `scripts/clawtributors-map.json`

Maps Git authors to canonical contributor identities.

### Label Management

**Sync GitHub Labels**: `scripts/sync-labels.ts`

Synchronizes issue and PR labels across repositories.

**Label Open Issues**: `scripts/label-open-issues.ts`

Automatically applies labels to open issues based on content analysis.

## Release Checklist

1. **Version Update**
   - Update `version` in `package.json`
   - Run `pnpm plugins:sync` to sync plugin versions
   - Update `CHANGELOG.md` with release notes

2. **Pre-release Verification**
   ```bash
   pnpm release:check     # Verify release readiness
   pnpm protocol:check    # Verify protocol sync
   pnpm check             # Run all linters
   pnpm test:all          # Run complete test suite
   ```

3. **Build All Platforms**
   ```bash
   pnpm build             # Core build
   pnpm ui:build          # UI build
   pnpm mac:package       # macOS package
   pnpm ios:build         # iOS build
   pnpm android:assemble  # Android build
   ```

4. **macOS Distribution**
   ```bash
   bash scripts/package-mac-dist.sh  # Full macOS pipeline
   ```

5. **Verification**
   - Test macOS DMG installation
   - Test iOS simulator deployment
   - Test Android APK installation
   - Verify protocol compatibility

6. **Publish**
   ```bash
   npm publish            # Publish to NPM
   ```

7. **Post-release**
   - Create GitHub release with artifacts
   - Update documentation
   - Announce release