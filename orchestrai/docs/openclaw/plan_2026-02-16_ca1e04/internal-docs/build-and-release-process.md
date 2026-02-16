# Build and Release Process

## Overview

OpenClaw uses a comprehensive build system based on Node.js/pnpm with multiple platform targets including desktop (macOS), mobile (iOS, Android), and container deployments. The build process is orchestrated through npm scripts defined in `package.json` with supporting shell scripts in the `scripts/` directory.

## Build System Architecture

### Core Build Tools

- **TypeScript Compiler**: Primary build tool using TypeScript 5.9.3
- **tsdown**: TypeScript bundler (v0.20.3) for creating distribution builds
- **pnpm**: Package manager (v10.23.0) with workspace support
- **Node.js**: Minimum version 22.12.0 required

### Build Configuration Files

- `tsconfig.json`: Main TypeScript configuration
- `tsconfig.plugin-sdk.dts.json`: Plugin SDK type definitions configuration
- `package.json`: Build scripts and dependency definitions
- `vitest.unit.config.ts`, `vitest.e2e.config.ts`, `vitest.live.config.ts`: Test configurations

## Build Scripts

### Primary Build Command

```bash
pnpm build
```

**Build Pipeline Sequence** (`package.json:70-71`):

```json
"build": "pnpm canvas:a2ui:bundle && tsdown && pnpm build:plugin-sdk:dts && node --import tsx scripts/write-plugin-sdk-entry-dts.ts && node --import tsx scripts/canvas-a2ui-copy.ts && node --import tsx scripts/copy-hook-metadata.ts && node --import tsx scripts/write-build-info.ts && node --import tsx scripts/write-cli-compat.ts"
```

**Build Steps**:

1. **Canvas A2UI Bundle** (`scripts/bundle-a2ui.sh`): Bundles adaptive UI components
2. **tsdown**: Compiles TypeScript to JavaScript with bundling
3. **Plugin SDK Types**: Generates type definitions for plugin developers
4. **Entry Point Generation** (`scripts/write-plugin-sdk-entry-dts.ts`): Creates plugin SDK entry types
5. **Canvas Copy** (`scripts/canvas-a2ui-copy.ts`): Copies canvas UI assets
6. **Hook Metadata** (`scripts/copy-hook-metadata.ts`): Copies hook metadata for extensions
7. **Build Info** (`scripts/write-build-info.ts`): Writes build metadata (version, commit, timestamp)
8. **CLI Compatibility** (`scripts/write-cli-compat.ts`): Generates CLI compatibility layer

### Build Output Structure

```
dist/
├── index.js                    # Main entry point
├── plugin-sdk/                 # Plugin SDK exports
│   ├── index.js
│   ├── index.d.ts
│   └── account-id.js
├── protocol.schema.json        # Protocol schema
└── [compiled modules]
```

### Development Build

```bash
pnpm dev
```

Runs development server using `scripts/run-node.mjs` with hot reload support.

### Watch Mode

```bash
pnpm gateway:watch
```

Uses `scripts/watch-node.mjs` for continuous rebuild on file changes.

## Cross-Platform Build Processes

### macOS Application

**Build macOS App** (`scripts/package-mac-app.sh`):

```bash
pnpm mac:package
```

**Process**:
1. Creates `.app` bundle structure
2. Copies compiled Node.js application
3. Packages native dependencies
4. Generates app icon from assets

**Code Signing** (`scripts/codesign-mac-app.sh`):
- Signs all native binaries and frameworks
- Signs the main application bundle
- Validates code signature

**DMG Creation** (`scripts/create-dmg.sh`):
- Creates disk image for distribution
- Sets custom background and icon layout
- Configures drag-to-Applications alias

**Notarization** (`scripts/notarize-mac-artifact.sh`):
- Submits to Apple notarization service
- Waits for notarization completion
- Staples notarization ticket

**Appcast Generation** (`scripts/make_appcast.sh`):
- Generates Sparkle framework update feed
- Signs update metadata
- Publishes to distribution server

### iOS Application

**Build Commands**:

```bash
# Generate Xcode project
pnpm ios:gen

# Build iOS app
pnpm ios:build

# Run on simulator
pnpm ios:run
```

**Configuration**:
- Uses `xcodegen` for project generation from YAML specs
- Location: `apps/ios/`
- Default simulator: iPhone 17 (configurable via `IOS_DEST` env var)

**Swift Protocol Generation** (`scripts/protocol-gen-swift.ts`):
```bash
pnpm protocol:gen:swift
```
Generates Swift models from TypeScript protocol definitions at `apps/macos/Sources/OpenClawProtocol/GatewayModels.swift`

### Android Application

**Build Commands**:

```bash
# Assemble debug APK
pnpm android:assemble

# Install on connected device
pnpm android:install

# Build, install, and launch
pnpm android:run

# Run unit tests
pnpm android:test
```

**Configuration**:
- Gradle-based build system
- Location: `apps/android/`
- Debug APK output: `apps/android/app/build/outputs/apk/debug/`

## CI/CD Pipeline

### GitHub Actions Workflows

Located in `.github/workflows/` directory with supporting custom actions in `.github/actions/`.

### Workflow Configuration

**Dependabot** (`.github/dependabot.yml`):
- Automated dependency updates
- Configured for npm, GitHub Actions, and Docker ecosystems
- Weekly update schedule with grouped updates

**PR Labeler** (`.github/labeler.yml`):
- Automatically labels PRs based on changed files
- 7,017 bytes of path-based labeling rules

**Action Linting** (`.github/actionlint.yaml`):
- Validates GitHub Actions workflow syntax
- Enforces best practices for CI/CD definitions

### PR Workflow

**PR Template** (`.github/pull_request_template.md`):
- Standardized PR description format
- Checklist for code quality, tests, and documentation

**PR Automation Scripts**:
- `scripts/pr`: Main PR management script (30,861 bytes)
- `scripts/pr-merge`: Merge automation helper
- `scripts/pr-prepare`: Pre-PR validation
- `scripts/pr-review`: Code review helper

## Testing and Quality Assurance

### Test Suites

**Unit Tests**:
```bash
pnpm test
```
Runs parallel test suite using `scripts/test-parallel.mjs` with `vitest.unit.config.ts`.

**E2E Tests**:
```bash
pnpm test:e2e
```
End-to-end tests via `vitest.e2e.config.ts`.

**Live API Tests**:
```bash
pnpm test:live
```
Tests against live API endpoints when `OPENCLAW_LIVE_TEST=1`.

**Coverage Report**:
```bash
pnpm test:coverage
```
Generates coverage report using Vitest with V8 provider.

### Docker-Based Testing

**Complete Docker Test Suite**:
```bash
pnpm test:docker:all
```

**Individual Docker Tests**:
- `test:docker:live-models` (`scripts/test-live-models-docker.sh`): Live model API tests
- `test:docker:live-gateway` (`scripts/test-live-gateway-models-docker.sh`): Gateway integration tests
- `test:docker:onboard` (`scripts/e2e/onboard-docker.sh`): Onboarding flow tests
- `test:docker:gateway-network` (`scripts/e2e/gateway-network-docker.sh`): Network tests
- `test:docker:qr` (`scripts/e2e/qr-import-docker.sh`): QR code import tests
- `test:docker:doctor-switch` (`scripts/e2e/doctor-install-switch-docker.sh`): Install switch tests
- `test:docker:plugins` (`scripts/e2e/plugins-docker.sh`): Plugin system tests
- `test:docker:cleanup` (`scripts/test-cleanup-docker.sh`): Cleanup test artifacts

### Installation Testing

**Smoke Test**:
```bash
pnpm test:install:smoke
```
Basic installation verification via `scripts/test-install-sh-docker.sh`.

**E2E Installation Test**:
```bash
pnpm test:install:e2e
```
Full installation flow test via `scripts/test-install-sh-e2e-docker.sh`.

**Provider-Specific Tests**:
```bash
pnpm test:install:e2e:anthropic  # Anthropic models
pnpm test:install:e2e:openai     # OpenAI models
```

## Code Quality Tools

### Linting

**Primary Linter** (`oxlint`):
```bash
pnpm lint              # Type-aware linting
pnpm lint:fix          # Auto-fix issues
```

**Swift Linting**:
```bash
pnpm lint:swift        # SwiftLint for iOS/macOS
```

**All Platform Linting**:
```bash
pnpm lint:all
```

**Documentation Linting**:
```bash
pnpm lint:docs         # markdownlint-cli2
pnpm lint:docs:fix     # Auto-fix markdown
pnpm docs:check-links  # Validate hyperlinks
```

### Formatting

**Code Formatting** (`oxfmt`):
```bash
pnpm format            # Format TypeScript/JavaScript
pnpm format:check      # Check formatting without changes
```

**Swift Formatting** (`swiftformat`):
```bash
pnpm format:swift      # Format Swift code
```

**All Platform Formatting**:
```bash
pnpm format:all
```

**Documentation Formatting**:
```bash
pnpm format:docs       # Format markdown files
pnpm format:docs:check # Check markdown formatting
```

### Additional Quality Checks

**Lines of Code Check** (`scripts/check-ts-max-loc.ts`):
```bash
pnpm check:loc
```
Enforces maximum 500 lines per TypeScript file.

**Combined Check**:
```bash
pnpm check             # Format check + type check + lint
pnpm check:docs        # All documentation checks
```

## Release Process

### Version Management

**Version Format**: `YYYY.M.D` (CalVer with year, month, day)
- Example: `2026.2.16`
- Defined in `package.json:3`

### Release Validation

**Pre-release Check** (`scripts/release-check.ts`):
```bash
pnpm release:check
```

**Validation Steps**:
1. Verifies version format matches CalVer
2. Checks CHANGELOG.md has entry for current version
3. Validates git tag doesn't already exist
4. Ensures working directory is clean
5. Confirms on main/master branch

### Protocol Compatibility

**Protocol Check**:
```bash
pnpm protocol:check
```

**Process**:
1. Regenerates protocol schema (`scripts/protocol-gen.ts`)
2. Regenerates Swift protocol bindings (`scripts/protocol-gen-swift.ts`)
3. Verifies no changes to:
   - `dist/protocol.schema.json`
   - `apps/macos/Sources/OpenClawProtocol/GatewayModels.swift`

### Plugin Version Synchronization

**Sync Plugin Versions** (`scripts/sync-plugin-versions.ts`):
```bash
pnpm plugins:sync
```
Ensures all plugin packages reference compatible SDK versions.

### Changelog Management

**Changelog HTML Generation** (`scripts/changelog-to-html.sh`):
Converts CHANGELOG.md to HTML for in-app display.

## Distribution and Packaging

### Package Structure

**Published Files** (`package.json:24-36`):
```json
"files": [
  "CHANGELOG.md",
  "LICENSE",
  "openclaw.mjs",
  "README-header.png",
  "README.md",
  "assets/",
  "dist/",
  "docs/",
  "extensions/",
  "skills/"
]
```

### Package Preparation

**Pre-pack Hook**:
```bash
pnpm prepack
```
Runs full build and UI build before npm packaging.

### Binary Distribution

**CLI Entry Point**: `openclaw.mjs`
- Installed as `openclaw` command via `package.json:20`
- Uses Node.js shebang for direct execution

### Platform-Specific Packages

**macOS**:
- `.app` bundle with code signing
- `.dmg` disk image for distribution
- Sparkle appcast for auto-updates

**iOS**:
- Xcode project generation
- TestFlight distribution (manual)

**Android**:
- Debug APK for development
- Release APK signing (manual)

## Container Deployment

### Podman Support

**Run Script** (`scripts/run-openclaw-podman.sh`):
```bash
bash scripts/run-openclaw-podman.sh
```
7,207 bytes of container orchestration logic.

**Helper Scripts**:
- `scripts/podman/`: Podman-specific utilities
- `scripts/docker/`: Docker-specific utilities

### Sandbox Environments

**Browser Sandbox**:
- Setup: `scripts/sandbox-browser-setup.sh`
- Entrypoint: `scripts/sandbox-browser-entrypoint.sh`
- Common setup: `scripts/sandbox-common-setup.sh`

**General Sandbox**:
- Setup: `scripts/sandbox-setup.sh`

## Development Utilities

### Build Monitoring

**Icon Builder** (`scripts/build_icon.sh`):
Generates application icons from source assets for macOS.

**Documentation Builder** (`scripts/build-docs-list.mjs`):
Generates documentation index for quick reference.

### Developer Tools

**Auth Monitoring** (`scripts/auth-monitor.sh`):
Monitors authentication system status during development.

**Log Analysis** (`scripts/clawlog.sh`):
10,244 bytes of log parsing and analysis utilities.

**Orphaned Process Recovery** (`scripts/recover-orphaned-processes.sh`):
Cleans up orphaned development processes.

**Mac Restart Helper** (`scripts/restart-mac.sh`):
9,316 bytes of macOS app restart automation.

### Model Benchmarking

**Benchmark Script** (`scripts/bench-model.ts`):
Performance testing for AI model integrations.

### Code Generation

**Protocol Generators**:
- TypeScript: `scripts/protocol-gen.ts`
- Swift: `scripts/protocol-gen-swift.ts`

**Build Info Writer** (`scripts/write-build-info.ts`):
Generates `build-info.json` with:
- Version number
- Git commit hash
- Build timestamp
- Build environment

**CLI Compatibility Writer** (`scripts/write-cli-compat.ts`):
Generates backward compatibility shims for CLI commands.

## Pre-commit Hooks

**Git Hooks Path**: `git-hooks/`
- Configured via `package.json:101` prepare script
- Hooks location: `scripts/pre-commit/`

**Hook Installation**:
```bash
git config core.hooksPath git-hooks
```

## Environment Configuration

### Build-Time Variables

**Required for macOS Notarization**:
- `APPLE_ID`: Apple Developer account email
- `APPLE_APP_SPECIFIC_PASSWORD`: App-specific password
- `APPLE_TEAM_ID`: Developer team ID

**Optional Build Flags**:
- `OPENCLAW_SKIP_CHANNELS=1`: Skip channel integrations in build
- `CLAWDBOT_SKIP_CHANNELS=1`: Skip Clawdbot channels
- `OPENCLAW_PROFILE=dev`: Development profile mode
- `IOS_DEST`: iOS simulator destination
- `IOS_SIM`: iOS simulator name

### Runtime Variables

**Test Configuration**:
- `OPENCLAW_LIVE_TEST=1`: Enable live API tests
- `OPENCLAW_E2E_MODELS=provider`: Specify E2E model provider
- `OPENCLAW_TEST_VM_FORKS=0`: Disable test forking (for CI)
- `OPENCLAW_TEST_PROFILE=serial`: Serial test execution

## Performance Optimization

### Parallel Testing

**Test Parallelization** (`scripts/test-parallel.mjs`):
13,230 bytes of parallel test orchestration with:
- Worker pool management
- Test sharding
- Resource isolation
- Progress reporting

### Slowest Test Detection

**Analysis Tool** (`scripts/vitest-slowest.mjs`):
Identifies and reports slowest test cases for optimization.

## Dependency Management

### Package Manager Configuration

**pnpm Settings** (`package.json:129-149`):

```json
"pnpm": {
  "minimumReleaseAge": 2880,
  "overrides": {
    "fast-xml-parser": "5.3.4",
    "form-data": "2.5.4",
    "qs": "6.14.2",
    "@sinclair/typebox": "0.34.48",
    "tar": "7.5.9",
    "tough-cookie": "4.1.3"
  },
  "onlyBuiltDependencies": [
    "@lydell/node-pty",
    "@matrix-org/matrix-sdk-crypto-nodejs",
    "@napi-rs/canvas",
    "@whiskeysockets/baileys",
    "authenticate-pam",
    "esbuild",
    "node-llama-cpp",
    "protobufjs",
    "sharp"
  ]
}
```

**Security Overrides**: Forces specific versions for known vulnerabilities
**Build-Only Dependencies**: Limits native builds to essential packages
**Minimum Release Age**: 48-hour delay before adopting new versions

## Troubleshooting Build Issues

### Common Build Failures

**Native Module Issues**:
- Ensure Node.js >= 22.12.0
- Check native build tools (Python, C++ compiler)
- Verify pnpm version 10.23.0

**macOS Code Signing**:
- Verify certificate in Keychain
- Check provisioning profiles
- Validate entitlements configuration

**iOS Build Failures**:
- Run `pnpm ios:gen` to regenerate project
- Check Xcode version compatibility
- Verify provisioning profiles

**Android Build Issues**:
- Ensure Android SDK installed
- Check ANDROID_HOME environment variable
- Verify Gradle daemon status

### Debug Tools

**Verbose Logging**:
Add `--verbose` to pnpm commands for detailed output.

**Build Cleanup**:
```bash
rm -rf node_modules dist
pnpm install
pnpm build
```

**Test Diagnostics**:
```bash
pnpm test:force        # Force re-run failed tests
```

## Contributor Workflow

### Label Management

**Issue Labeling** (`scripts/label-open-issues.ts`):
24,099 bytes of automated issue labeling logic.

**Label Synchronization** (`scripts/sync-labels.ts`):
Syncs GitHub labels across repository.

### Contributor Recognition

**Clawtributors Update** (`scripts/update-clawtributors.ts`):
Generates and updates contributor list with:
- GitHub API integration
- Avatar fetching
- Contribution metrics
- Mapping file: `scripts/clawtributors-map.json`

## Integration Testing

### Shell Completion Testing

**Test Script** (`scripts/test-shell-completion.ts`):
7,506 bytes of shell completion validation for bash/zsh.

### Force Testing

**Force Test Utility** (`scripts/test-force.ts`):
Bypasses test caching to force re-execution.

## Documentation Generation

### Documentation Scripts

**Documentation List** (`scripts/docs-list.js`):
Generates structured documentation index.

**Documentation Binary** (`scripts/build-docs-list.mjs`):
Compiles documentation assets for bundling.

**Link Auditing** (`scripts/docs-link-audit.mjs`):
6,378 bytes of documentation link validation.

### Internationalization

**i18n Scripts**: `scripts/docs-i18n/`
Documentation translation and localization tooling.

## Mobile-Specific Tooling

### iOS Team Management

**Team ID Script** (`scripts/ios-team-id.sh`):
Retrieves Apple Developer team ID for configuration.

### Android Development

**Build and Run** (`scripts/build-and-run-mac.sh`):
533 bytes of macOS-specific Android build automation.

## Monitoring and Diagnostics

### Authentication Status

**Claude Auth Status** (`scripts/claude-auth-status.sh`):
8,632 bytes of authentication monitoring and diagnostics.

**Auth System Setup** (`scripts/setup-auth-system.sh`):
Initial authentication system configuration.

### Mobile Auth Tools

**Termux Scripts**:
- `scripts/termux-auth-widget.sh`: Android widget authentication
- `scripts/termux-quick-auth.sh`: Quick authentication helper
- `scripts/termux-sync-widget.sh`: Sync widget for Android

**Mobile Reauth** (`scripts/mobile-reauth.sh`):
Handles mobile re-authentication flows.

## Summary

The OpenClaw build and release process is a sophisticated multi-platform system orchestrated through npm scripts with extensive automation for:

- **Build**: TypeScript compilation, bundling, and asset processing
- **Testing**: Parallel unit tests, E2E tests, Docker-based integration tests
- **Quality**: Automated linting, formatting, and code quality checks
- **Distribution**: Platform-specific packaging for macOS, iOS, and Android
- **Release**: CalVer versioning with automated validation and protocol checks
- **CI/CD**: GitHub Actions integration with automated PR management

All build scripts are located in `scripts/` with primary orchestration through `package.json` npm scripts. The system supports development, testing, and production builds across multiple platforms with comprehensive quality assurance at each stage.