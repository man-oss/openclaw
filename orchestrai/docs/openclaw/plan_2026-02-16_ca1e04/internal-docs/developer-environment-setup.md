# Developer Environment Setup

## Overview

This guide provides complete instructions for setting up a development environment for OpenClaw, a multi-channel AI gateway with extensible messaging integrations. Following these steps will give you a fully functional development environment ready for contribution.

## Prerequisites

### Required Software Versions

**Node.js**
- Minimum version: `22.12.0`
- Specified in `package.json` engines field
- Recommended: Use the latest LTS version that meets this requirement

**Package Manager**
- pnpm: `10.23.0` (exact version specified)
- Install via: `npm install -g pnpm@10.23.0`

### Platform-Specific Requirements

**macOS Development**
- Xcode Command Line Tools
- SwiftFormat for Swift code formatting (`.swiftformat` config)
- SwiftLint for Swift linting (`.swiftlint.yml` config)
- XcodeGen for iOS project generation

**Android Development**
- Android SDK
- Gradle (included in `apps/android`)
- ADB tools for device management

**iOS Development**
- Xcode
- XcodeGen: `cd apps/ios && xcodegen generate`
- Configure `IOS_DEST` and `IOS_SIM` environment variables for simulator targeting

## Repository Setup

### 1. Clone Repository

```bash
git clone https://github.com/openclaw/openclaw.git
cd openclaw
```

### 2. Install Dependencies

```bash
pnpm install
```

The project uses pnpm workspaces with the following configuration (`package.json`):

**Peer Dependencies (Optional)**
- `@napi-rs/canvas@^0.1.89`
- `node-llama-cpp@3.15.1`

**Build-Only Dependencies**
Configured in `pnpm.onlyBuiltDependencies`:
- `@lydell/node-pty`
- `@matrix-org/matrix-sdk-crypto-nodejs`
- `@napi-rs/canvas`
- `@whiskeysockets/baileys`
- `authenticate-pam`
- `esbuild`
- `node-llama-cpp`
- `protobufjs`
- `sharp`

### 3. Git Hooks Configuration

The repository automatically configures git hooks during setup:

**Automatic Setup** (`package.json` prepare script):
```bash
command -v git >/dev/null 2>&1 && git rev-parse --is-inside-work-tree >/dev/null 2>&1 && git config core.hooksPath git-hooks || exit 0
```

**Pre-commit Hook** (`git-hooks/pre-commit`):
- Runs automatically before each commit
- Executes quality checks to ensure code standards

## Build Configuration

### Development Build

**Standard Build Process**:
```bash
pnpm build
```

This executes the complete build pipeline (`package.json` scripts.build):
1. `pnpm canvas:a2ui:bundle` - Bundle A2UI canvas components
2. `tsdown` - TypeScript compilation with tsdown
3. `pnpm build:plugin-sdk:dts` - Generate plugin SDK type definitions
4. `node --import tsx scripts/write-plugin-sdk-entry-dts.ts` - Write plugin SDK entry types
5. `node --import tsx scripts/canvas-a2ui-copy.ts` - Copy canvas A2UI artifacts
6. `node --import tsx scripts/copy-hook-metadata.ts` - Copy hook metadata
7. `node --import tsx scripts/write-build-info.ts` - Write build information
8. `node --import tsx scripts/write-cli-compat.ts` - Write CLI compatibility layer

**Plugin SDK Types Generation**:
```bash
pnpm build:plugin-sdk:dts
```

Uses TypeScript compiler with configuration: `tsconfig.plugin-sdk.dts.json`

### Development Mode

**Node.js Development Server**:
```bash
pnpm dev
# or
node scripts/run-node.mjs
```

**Watch Mode**:
```bash
pnpm gateway:watch
# Runs: node scripts/watch-node.mjs gateway --force
```

**Development with Skip Channels**:
```bash
pnpm gateway:dev
# Sets: OPENCLAW_SKIP_CHANNELS=1 CLAWDBOT_SKIP_CHANNELS=1
```

**Development with Reset**:
```bash
pnpm gateway:dev:reset
```

**TUI Development Mode**:
```bash
pnpm tui:dev
# Sets: OPENCLAW_PROFILE=dev CLAWDBOT_PROFILE=dev
```

### UI Development

**Install UI Dependencies**:
```bash
pnpm ui:install
# Runs: node scripts/ui.js install
```

**UI Development Server**:
```bash
pnpm ui:dev
# Runs: node scripts/ui.js dev
```

**UI Production Build**:
```bash
pnpm ui:build
# Runs: node scripts/ui.js build
```

### Platform-Specific Builds

**macOS Application**:
```bash
# Package macOS app
pnpm mac:package
# Runs: bash scripts/package-mac-app.sh

# Open built application
pnpm mac:open
# Opens: dist/OpenClaw.app

# Restart macOS app
pnpm mac:restart
# Runs: bash scripts/restart-mac.sh
```

**iOS Application**:
```bash
# Generate Xcode project
pnpm ios:gen
# Runs: cd apps/ios && xcodegen generate

# Open in Xcode
pnpm ios:open

# Build iOS app
pnpm ios:build
# Default simulator: iPhone 17
# Override with: IOS_DEST="platform=iOS Simulator,name=iPhone 15"

# Build and run
pnpm ios:run
# Override simulator: IOS_SIM="iPhone 15"
```

**Android Application**:
```bash
# Assemble debug APK
pnpm android:assemble
# Runs: cd apps/android && ./gradlew :app:assembleDebug

# Install on device
pnpm android:install
# Runs: cd apps/android && ./gradlew :app:installDebug

# Build, install, and launch
pnpm android:run

# Run unit tests
pnpm android:test
# Runs: cd apps/android && ./gradlew :app:testDebugUnitTest
```

## Testing Environment Setup

### Unit Tests

**Run All Unit Tests**:
```bash
pnpm test
# Runs: node scripts/test-parallel.mjs
```

**Fast Test Suite**:
```bash
pnpm test:fast
# Runs: vitest run --config vitest.unit.config.ts
```

**Watch Mode**:
```bash
pnpm test:watch
# Runs: vitest
```

**Coverage Report**:
```bash
pnpm test:coverage
# Runs: vitest run --config vitest.unit.config.ts --coverage
```

**Test Configurations**:
- Unit tests: `vitest.unit.config.ts`
- E2E tests: `vitest.e2e.config.ts`
- Live tests: `vitest.live.config.ts`

### End-to-End Tests

**Run E2E Test Suite**:
```bash
pnpm test:e2e
# Runs: vitest run --config vitest.e2e.config.ts
```

### Live API Tests

**Run Live Tests** (requires API credentials):
```bash
pnpm test:live
# Sets: OPENCLAW_LIVE_TEST=1 CLAWDBOT_LIVE_TEST=1
# Runs: vitest run --config vitest.live.config.ts
```

### Docker-Based Tests

**Full Docker Test Suite**:
```bash
pnpm test:docker:all
```

Includes:
- `test:docker:live-models` - Live model integration tests
- `test:docker:live-gateway` - Gateway model tests
- `test:docker:onboard` - Onboarding flow tests
- `test:docker:gateway-network` - Gateway networking tests
- `test:docker:qr` - QR code import tests
- `test:docker:doctor-switch` - Doctor installation switching tests
- `test:docker:plugins` - Plugin system tests
- `test:docker:cleanup` - Cleanup test artifacts

**Installation Script Tests**:
```bash
# Smoke test
pnpm test:install:smoke

# E2E installation test
pnpm test:install:e2e

# Provider-specific tests
pnpm test:install:e2e:anthropic
pnpm test:install:e2e:openai
```

### Specialized Test Profiles

**Mac Mini Test Profile** (serial execution):
```bash
pnpm test:macmini
# Sets: OPENCLAW_TEST_VM_FORKS=0 OPENCLAW_TEST_PROFILE=serial
```

**Force Test Execution**:
```bash
pnpm test:force
# Runs: node --import tsx scripts/test-force.ts
```

**UI Component Tests**:
```bash
pnpm test:ui
# Runs: pnpm --dir ui test
```

## Code Quality Tools

### Linting

**TypeScript Linting**:
```bash
pnpm lint
# Runs: oxlint --type-aware
```

**Auto-fix Issues**:
```bash
pnpm lint:fix
# Runs: oxlint --type-aware --fix && pnpm format
```

**Swift Linting** (macOS/iOS):
```bash
pnpm lint:swift
# Runs SwiftLint on macOS and iOS sources
```

**Documentation Linting**:
```bash
pnpm lint:docs
# Runs: pnpm dlx markdownlint-cli2

# Auto-fix documentation
pnpm lint:docs:fix
```

### Code Formatting

**Format TypeScript/JavaScript**:
```bash
pnpm format
# Runs: oxfmt --write
```

**Check Formatting** (CI-friendly):
```bash
pnpm format:check
# Runs: oxfmt --check
```

**Format Documentation**:
```bash
pnpm format:docs
# Formats: docs/**/*.md, docs/**/*.mdx, README.md
```

**Swift Formatting**:
```bash
pnpm format:swift
# Uses: .swiftformat configuration
# Targets: apps/macos/Sources, apps/ios/Sources, apps/shared/OpenClawKit/Sources
```

**Format All Code**:
```bash
pnpm format:all
# Runs: pnpm format && pnpm format:swift
```

### Type Checking

**TypeScript Type Check**:
```bash
pnpm tsgo:test
# Runs: tsgo -p tsconfig.test.json
```

### Code Quality Checks

**Lines of Code Limit Check**:
```bash
pnpm check:loc
# Runs: node --import tsx scripts/check-ts-max-loc.ts --max 500
# Enforces maximum 500 lines per TypeScript file
```

**Full Quality Check Suite**:
```bash
pnpm check
# Runs: pnpm format:check && pnpm tsgo && pnpm lint
```

**Documentation Quality Check**:
```bash
pnpm check:docs
# Runs: pnpm format:docs:check && pnpm lint:docs && pnpm docs:check-links
```

**Link Validation**:
```bash
pnpm docs:check-links
# Runs: node scripts/docs-link-audit.mjs
```

## IDE Configuration

### Visual Studio Code

**Recommended Extensions** (`.vscode/extensions.json`):
The project specifies recommended extensions for optimal development experience.

**Workspace Settings** (`.vscode/settings.json`):
- Pre-configured settings for TypeScript, formatting, and linting
- File path: `.vscode/settings.json` (662 bytes)

### EditorConfig

The project follows consistent coding standards across IDEs through configuration files.

## Development Scripts

### Utility Scripts

**Run OpenClaw Agent**:
```bash
pnpm openclaw
# Runs: node scripts/run-node.mjs
```

**RPC Mode**:
```bash
pnpm openclaw:rpc
# Runs: node scripts/run-node.mjs agent --mode rpc --json
```

**TUI Interface**:
```bash
pnpm tui
# Runs: node scripts/run-node.mjs tui
```

### Protocol Generation

**Generate Protocol Schemas**:
```bash
pnpm protocol:gen
# Runs: node --import tsx scripts/protocol-gen.ts
# Output: dist/protocol.schema.json
```

**Generate Swift Protocol Models**:
```bash
pnpm protocol:gen:swift
# Runs: node --import tsx scripts/protocol-gen-swift.ts
# Output: apps/macos/Sources/OpenClawProtocol/GatewayModels.swift
```

**Verify Protocol Consistency**:
```bash
pnpm protocol:check
# Generates protocols and checks for uncommitted changes
```

### Plugin Management

**Sync Plugin Versions**:
```bash
pnpm plugins:sync
# Runs: node --import tsx scripts/sync-plugin-versions.ts
```

### Documentation Development

**Start Documentation Server**:
```bash
pnpm docs:dev
# Runs: cd docs && mint dev
```

**Build Documentation List**:
```bash
pnpm docs:bin
# Runs: node scripts/build-docs-list.mjs
```

**List Documentation Files**:
```bash
pnpm docs:list
# Runs: node scripts/docs-list.js
```

### Release Management

**Release Validation**:
```bash
pnpm release:check
# Runs: node --import tsx scripts/release-check.ts
```

**Pre-package Hook**:
```bash
pnpm prepack
# Automatically runs: pnpm build && pnpm ui:build
```

## Environment Variables

### Development Mode Configuration

**Profile Selection**:
- `OPENCLAW_PROFILE=dev` - Development profile
- `CLAWDBOT_PROFILE=dev` - Clawdbot development profile

**Channel Control**:
- `OPENCLAW_SKIP_CHANNELS=1` - Skip channel initialization
- `CLAWDBOT_SKIP_CHANNELS=1` - Skip Clawdbot channels

**Testing Configuration**:
- `OPENCLAW_LIVE_TEST=1` - Enable live API tests
- `CLAWDBOT_LIVE_TEST=1` - Enable Clawdbot live tests
- `OPENCLAW_TEST_VM_FORKS=0` - Disable test forking
- `OPENCLAW_TEST_PROFILE=serial` - Use serial test execution
- `OPENCLAW_E2E_MODELS=anthropic` - Specify E2E model provider
- `CLAWDBOT_E2E_MODELS=openai` - Specify Clawdbot E2E models

**Platform Configuration**:
- `IOS_DEST` - iOS simulator destination (default: `platform=iOS Simulator,name=iPhone 17`)
- `IOS_SIM` - iOS simulator name (default: `iPhone 17`)

## Troubleshooting

### Common Build Issues

**Missing Dependencies**:
```bash
# Clean install
rm -rf node_modules
pnpm install
```

**Build Artifacts**:
```bash
# Clean build directory
rm -rf dist
pnpm build
```

**Native Module Issues**:
The project uses `pnpm.onlyBuiltDependencies` to control which packages are built. If native modules fail:
1. Ensure you have build tools installed
2. Check Node.js version compatibility (>=22.12.0)
3. Review platform-specific requirements

### Test Failures

**Docker Test Cleanup**:
```bash
pnpm test:docker:cleanup
# Runs: bash scripts/test-cleanup-docker.sh
```

**Test Process Recovery**:
```bash
bash scripts/recover-orphaned-processes.sh
```

### Platform-Specific Issues

**iOS Signing**:
```bash
bash scripts/ios-team-id.sh
# Retrieves Apple Developer Team ID
```

**macOS Codesigning**:
```bash
bash scripts/codesign-mac-app.sh
# Signs macOS application bundle
```

## Additional Development Tools

### Benchmarking

**Model Benchmarking**:
```bash
node --import tsx scripts/bench-model.ts
```

### Debugging

**Claude API Usage Debug**:
```bash
node --import tsx scripts/debug-claude-usage.ts
```

**Authentication Monitoring**:
```bash
bash scripts/auth-monitor.sh
```

**Shell Completion Testing**:
```bash
node --import tsx scripts/test-shell-completion.ts
```

### Performance Analysis

**Vitest Performance Report**:
```bash
node scripts/vitest-slowest.mjs
```

## Continuous Integration Preparation

**Full CI Check** (runs all validations):
```bash
pnpm test:all
# Executes: lint, build, test, test:e2e, test:live, test:docker:all
```

This ensures your changes pass all quality gates before submitting a pull request.

## Summary

After completing this setup:
1. ✅ Node.js 22.12.0+ and pnpm 10.23.0 installed
2. ✅ Repository cloned and dependencies installed
3. ✅ Git hooks configured automatically
4. ✅ Development build completed successfully
5. ✅ Test suite runs without errors
6. ✅ Code quality tools (linting, formatting) operational
7. ✅ IDE configured with recommended settings
8. ✅ Platform-specific tools installed (if developing for iOS/Android/macOS)

You now have a fully functional development environment for contributing to OpenClaw.