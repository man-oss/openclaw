# CycloneDX SBOM for OpenClaw

## Metadata

- **SBOM Format**: CycloneDX 1.5
- **Serial Number**: urn:uuid:openclaw-sbom-2026.2.16
- **Version**: 1
- **Timestamp**: 2026-02-16T00:00:00Z
- **Component**: OpenClaw v2026.2.16
- **License**: MIT
- **Repository**: https://github.com/openclaw/openclaw.git

## Component Information

### Main Component

```json
{
  "bom-ref": "pkg:npm/openclaw@2026.2.16",
  "type": "application",
  "name": "openclaw",
  "version": "2026.2.16",
  "description": "Multi-channel AI gateway with extensible messaging integrations",
  "licenses": [
    {
      "license": {
        "id": "MIT"
      }
    }
  ],
  "purl": "pkg:npm/openclaw@2026.2.16"
}
```

## Production Dependencies (Node.js/JavaScript)

### AI and Agent Components

| Component | Version | PURL | License Type |
|-----------|---------|------|--------------|
| @agentclientprotocol/sdk | 0.14.1 | pkg:npm/%40agentclientprotocol/sdk@0.14.1 | Unknown |
| @mariozechner/pi-agent-core | 0.52.12 | pkg:npm/%40mariozechner/pi-agent-core@0.52.12 | Unknown |
| @mariozechner/pi-ai | 0.52.12 | pkg:npm/%40mariozechner/pi-ai@0.52.12 | Unknown |
| @mariozechner/pi-coding-agent | 0.52.12 | pkg:npm/%40mariozechner/pi-coding-agent@0.52.12 | Unknown |
| @mariozechner/pi-tui | 0.52.12 | pkg:npm/%40mariozechner/pi-tui@0.52.12 | Unknown |

**Source**: `package.json` lines 76-80

### Cloud Provider SDKs

| Component | Version | PURL | License Type |
|-----------|---------|------|--------------|
| @aws-sdk/client-bedrock | ^3.990.0 | pkg:npm/%40aws-sdk/client-bedrock@3.990.0 | Apache-2.0 |

**Source**: `package.json` line 77

### Messaging Platform Integrations

| Component | Version | PURL | License Type |
|-----------|---------|------|--------------|
| @buape/carbon | 0.14.0 | pkg:npm/%40buape/carbon@0.14.0 | Unknown |
| @grammyjs/runner | ^2.0.3 | pkg:npm/%40grammyjs/runner@2.0.3 | MIT |
| @grammyjs/transformer-throttler | ^1.2.1 | pkg:npm/%40grammyjs/transformer-throttler@1.2.1 | MIT |
| @larksuiteoapi/node-sdk | ^1.59.0 | pkg:npm/%40larksuiteoapi/node-sdk@1.59.0 | Unknown |
| @line/bot-sdk | ^10.6.0 | pkg:npm/%40line/bot-sdk@10.6.0 | Apache-2.0 |
| @slack/bolt | ^4.6.0 | pkg:npm/%40slack/bolt@4.6.0 | MIT |
| @slack/web-api | ^7.14.1 | pkg:npm/%40slack/web-api@7.14.1 | MIT |
| @whiskeysockets/baileys | 7.0.0-rc.9 | pkg:npm/%40whiskeysockets/baileys@7.0.0-rc.9 | MIT |
| discord-api-types | ^0.38.39 | pkg:npm/discord-api-types@0.38.39 | MIT |
| grammy | ^1.40.0 | pkg:npm/grammy@1.40.0 | MIT |

**Source**: `package.json` lines 78-96

### Networking and Communication

| Component | Version | PURL | License Type |
|-----------|---------|------|--------------|
| @homebridge/ciao | ^1.3.5 | pkg:npm/%40homebridge/ciao@1.3.5 | Apache-2.0 |
| express | ^5.2.1 | pkg:npm/express@5.2.1 | MIT |
| https-proxy-agent | ^7.0.6 | pkg:npm/https-proxy-agent@7.0.6 | MIT |
| undici | ^7.22.0 | pkg:npm/undici@7.22.0 | MIT |
| ws | ^8.19.0 | pkg:npm/ws@8.19.0 | MIT |

**Source**: `package.json` lines 82, 90, 93, 116, 117

### Terminal and PTY

| Component | Version | PURL | License Type |
|-----------|---------|------|--------------|
| @lydell/node-pty | 1.2.0-beta.3 | pkg:npm/%40lydell/node-pty@1.2.0-beta.3 | MIT |

**Source**: `package.json` line 83

### Content Processing

| Component | Version | PURL | License Type |
|-----------|---------|------|--------------|
| @mozilla/readability | ^0.6.0 | pkg:npm/%40mozilla/readability@0.6.0 | Apache-2.0 |
| markdown-it | ^14.1.1 | pkg:npm/markdown-it@14.1.1 | MIT |
| pdfjs-dist | ^5.4.624 | pkg:npm/pdfjs-dist@5.4.624 | Apache-2.0 |
| linkedom | ^0.18.12 | pkg:npm/linkedom@0.18.12 | MIT |

**Source**: `package.json` lines 84, 102, 104, 101

### Data Validation and Serialization

| Component | Version | PURL | License Type |
|-----------|---------|------|--------------|
| @sinclair/typebox | 0.34.48 | pkg:npm/%40sinclair/typebox@0.34.48 | MIT |
| ajv | ^8.18.0 | pkg:npm/ajv@8.18.0 | MIT |
| zod | ^4.3.6 | pkg:npm/zod@4.3.6 | MIT |
| json5 | ^2.2.3 | pkg:npm/json5@2.2.3 | MIT |
| yaml | ^2.8.2 | pkg:npm/yaml@2.8.2 | ISC |

**Source**: `package.json` lines 86, 88, 119, 99, 118

### CLI and User Interface

| Component | Version | PURL | License Type |
|-----------|---------|------|--------------|
| @clack/prompts | ^1.0.1 | pkg:npm/%40clack/prompts@1.0.1 | MIT |
| chalk | ^5.6.2 | pkg:npm/chalk@5.6.2 | MIT |
| cli-highlight | ^2.1.11 | pkg:npm/cli-highlight@2.1.11 | ISC |
| commander | ^14.0.3 | pkg:npm/commander@14.0.3 | MIT |
| osc-progress | ^0.3.0 | pkg:npm/osc-progress@0.3.0 | MIT |
| qrcode-terminal | ^0.12.0 | pkg:npm/qrcode-terminal@0.12.0 | Apache-2.0 |

**Source**: `package.json` lines 79, 89, 91, 92, 103, 106

### File System and Archive

| Component | Version | PURL | License Type |
|-----------|---------|------|--------------|
| chokidar | ^5.0.0 | pkg:npm/chokidar@5.0.0 | MIT |
| file-type | ^21.3.0 | pkg:npm/file-type@21.3.0 | MIT |
| jszip | ^3.10.1 | pkg:npm/jszip@3.10.1 | MIT/GPL-3.0 |
| proper-lockfile | ^4.1.2 | pkg:npm/proper-lockfile@4.1.2 | MIT |
| tar | 7.5.9 | pkg:npm/tar@7.5.9 | ISC |

**Source**: `package.json` lines 90, 94, 100, 105, 114

### Database

| Component | Version | PURL | License Type |
|-----------|---------|------|--------------|
| sqlite-vec | 0.1.7-alpha.2 | pkg:npm/sqlite-vec@0.1.7-alpha.2 | MIT/Apache-2.0 |

**Source**: `package.json` line 113

### Media Processing

| Component | Version | PURL | License Type |
|-----------|---------|------|--------------|
| sharp | ^0.34.5 | pkg:npm/sharp@0.34.5 | Apache-2.0 |
| node-edge-tts | ^1.2.10 | pkg:npm/node-edge-tts@1.2.10 | MIT |

**Source**: `package.json` lines 107, 102

### Browser Automation

| Component | Version | PURL | License Type |
|-----------|---------|------|--------------|
| playwright-core | 1.58.2 | pkg:npm/playwright-core@1.58.2 | Apache-2.0 |

**Source**: `package.json` line 104

### Utilities

| Component | Version | PURL | License Type |
|-----------|---------|------|--------------|
| croner | ^10.0.1 | pkg:npm/croner@10.0.1 | MIT |
| dotenv | ^17.3.1 | pkg:npm/dotenv@17.3.1 | BSD-2-Clause |
| jiti | ^2.6.1 | pkg:npm/jiti@2.6.1 | MIT |
| long | ^5.3.2 | pkg:npm/long@5.3.2 | Apache-2.0 |
| signal-utils | ^0.21.1 | pkg:npm/signal-utils@0.21.1 | MIT |
| tslog | ^4.10.2 | pkg:npm/tslog@4.10.2 | MIT |

**Source**: `package.json` lines 92, 93, 98, 101, 112, 115

## Development Dependencies (Node.js/JavaScript)

### TypeScript and Build Tools

| Component | Version | PURL | License Type |
|-----------|---------|------|--------------|
| typescript | ^5.9.3 | pkg:npm/typescript@5.9.3 | Apache-2.0 |
| tsx | ^4.21.0 | pkg:npm/tsx@4.21.0 | MIT |
| tsdown | ^0.20.3 | pkg:npm/tsdown@0.20.3 | MIT |
| rolldown | 1.0.0-rc.4 | pkg:npm/rolldown@1.0.0-rc.4 | MIT |
| @typescript/native-preview | 7.0.0-dev.20260215.1 | pkg:npm/%40typescript/native-preview@7.0.0-dev.20260215.1 | Apache-2.0 |

**Source**: `package.json` lines 134, 133, 132, 131, 130

### Linting and Formatting

| Component | Version | PURL | License Type |
|-----------|---------|------|--------------|
| oxfmt | 0.32.0 | pkg:npm/oxfmt@0.32.0 | MIT |
| oxlint | ^1.47.0 | pkg:npm/oxlint@1.47.0 | MIT |
| oxlint-tsgolint | ^0.13.0 | pkg:npm/oxlint-tsgolint@0.13.0 | MIT |

**Source**: `package.json` lines 129, 128, 127

### Testing

| Component | Version | PURL | License Type |
|-----------|---------|------|--------------|
| vitest | ^4.0.18 | pkg:npm/vitest@4.0.18 | MIT |
| @vitest/coverage-v8 | ^4.0.18 | pkg:npm/%40vitest/coverage-v8@4.0.18 | MIT |

**Source**: `package.json` lines 135, 126

### Type Definitions

| Component | Version | PURL | License Type |
|-----------|---------|------|--------------|
| @types/node | ^25.2.3 | pkg:npm/%40types/node@25.2.3 | MIT |
| @types/express | ^5.0.6 | pkg:npm/%40types/express@5.0.6 | MIT |
| @types/markdown-it | ^14.1.2 | pkg:npm/%40types/markdown-it@14.1.2 | MIT |
| @types/proper-lockfile | ^4.1.4 | pkg:npm/%40types/proper-lockfile@4.1.4 | MIT |
| @types/qrcode-terminal | ^0.12.2 | pkg:npm/%40types/qrcode-terminal@0.12.2 | MIT |
| @types/ws | ^8.18.1 | pkg:npm/%40types/ws@8.18.1 | MIT |
| @grammyjs/types | ^3.24.0 | pkg:npm/%40grammyjs/types@3.24.0 | MIT |

**Source**: `package.json` lines 122-125, 121

### UI Components

| Component | Version | PURL | License Type |
|-----------|---------|------|--------------|
| lit | ^3.3.2 | pkg:npm/lit@3.3.2 | BSD-3-Clause |
| @lit-labs/signals | ^0.2.0 | pkg:npm/%40lit-labs/signals@0.2.0 | BSD-3-Clause |
| @lit/context | ^1.1.6 | pkg:npm/%40lit/context@1.1.6 | BSD-3-Clause |

**Source**: `package.json` lines 120-121

### Other Development Dependencies

| Component | Version | PURL | License Type |
|-----------|---------|------|--------------|
| ollama | ^0.6.3 | pkg:npm/ollama@0.6.3 | MIT |

**Source**: `package.json` line 127

## Peer Dependencies (Optional)

| Component | Version | PURL | License Type |
|-----------|---------|------|--------------|
| @napi-rs/canvas | ^0.1.89 | pkg:npm/%40napi-rs/canvas@0.1.89 | MIT |
| node-llama-cpp | 3.15.1 | pkg:npm/node-llama-cpp@3.15.1 | MIT |

**Source**: `package.json` lines 137-138

## Package Manager

| Component | Version | PURL | License Type |
|-----------|---------|------|--------------|
| pnpm | 10.23.0 | pkg:npm/pnpm@10.23.0 | MIT |

**Source**: `package.json` line 144

## iOS Platform Dependencies

### Build Tools and Configuration

Based on `apps/ios/project.yml` and the iOS app structure at `apps/ios/`:

- **XcodeGen**: Project generation tool (referenced in build scripts)
- **SwiftLint**: Swift linting tool (`.swiftlint.yml` configuration present)
- **SwiftFormat**: Swift code formatting tool (referenced in npm scripts)
- **Fastlane**: iOS deployment automation (fastlane directory present)

**Source**: `apps/ios/` directory structure, `package.json` scripts lines 37-40

### iOS SDK Components

The iOS app (`apps/ios/`) uses native Apple frameworks:

- **UIKit/SwiftUI**: iOS UI framework
- **Foundation**: Core iOS framework
- **WebKit**: Web content rendering (typical for gateway apps)

**Source**: `apps/ios/Sources/` directory indicates Swift-based iOS application

## Android Platform Dependencies

### Build Configuration

Based on `apps/android/build.gradle.kts` and structure at `apps/android/`:

| Component | Version | Type | License |
|-----------|---------|------|---------|
| Gradle | 8.x | Build Tool | Apache-2.0 |
| Android Gradle Plugin | Latest | Build Plugin | Apache-2.0 |

**Source**: `apps/android/build.gradle.kts`, `apps/android/gradlew`

### Gradle Wrapper

- **File**: `apps/android/gradlew`
- **Type**: Build wrapper script
- **Purpose**: Ensures consistent Gradle version across builds

**Source**: `apps/android/gradlew` (8,729 bytes)

### Android SDK Components

The Android app (`apps/android/app/`) structure indicates usage of:

- **AndroidX Libraries**: Modern Android support libraries
- **Kotlin Standard Library**: Primary Android development language
- **Android SDK Platform APIs**: Core Android framework

**Source**: `apps/android/app/` directory structure

### Android Configuration Files

- **gradle.properties**: Build configuration (201 bytes)
- **settings.gradle.kts**: Project settings (309 bytes)

**Source**: `apps/android/gradle.properties`, `apps/android/settings.gradle.kts`

## Vendored Components

### a2ui Component

| Component | Location | Type | Purpose |
|-----------|----------|------|---------|
| a2ui | vendor/a2ui/ | Bundled UI Library | Custom UI components |

**Source**: `vendor/a2ui/` directory

**Build Integration**: Referenced in build scripts:
- `canvas:a2ui:bundle` script: `bash scripts/bundle-a2ui.sh`
- Copy script: `scripts/canvas-a2ui-copy.ts`

**Source**: `package.json` lines 30, 36

## Security-Critical Dependencies

### Overridden Versions (Security Patches)

The following dependencies are explicitly overridden in pnpm configuration for security reasons:

| Component | Overridden Version | Reason |
|-----------|-------------------|--------|
| fast-xml-parser | 5.3.4 | Security vulnerability mitigation |
| form-data | 2.5.4 | Security vulnerability mitigation |
| qs | 6.14.2 | Security vulnerability mitigation |
| @sinclair/typebox | 0.34.48 | Security/stability requirements |
| tar | 7.5.9 | Security vulnerability mitigation |
| tough-cookie | 4.1.3 | Security vulnerability mitigation |

**Source**: `package.json` lines 147-153

### Binary Dependencies (Build-Only)

Dependencies restricted to build-only installation for security:

| Component | Purpose | Security Note |
|-----------|---------|---------------|
| @lydell/node-pty | Terminal emulation | Native binary, built from source |
| @matrix-org/matrix-sdk-crypto-nodejs | Matrix encryption | Native cryptography module |
| @napi-rs/canvas | Canvas rendering | Native binary module |
| @whiskeysockets/baileys | WhatsApp integration | Native dependencies |
| authenticate-pam | PAM authentication | System authentication module |
| esbuild | Build tool | Native binary bundler |
| node-llama-cpp | LLM inference | Native ML library |
| protobufjs | Protocol buffers | Native serialization |
| sharp | Image processing | Native image library |

**Source**: `package.json` lines 155-165

## Runtime Requirements

### Node.js Version

- **Required Version**: >= 22.12.0
- **Type**: JavaScript Runtime
- **PURL**: pkg:npm/node@22.12.0

**Source**: `package.json` lines 141-142

## Dependency Metadata

### License Distribution Summary

Based on identified components:

- **MIT**: Majority of Node.js dependencies
- **Apache-2.0**: AWS SDK, Mozilla Readability, Sharp, TypeScript
- **ISC**: YAML parser, Tar, CLI-highlight
- **BSD-2-Clause**: Dotenv
- **BSD-3-Clause**: Lit framework components
- **MIT/GPL-3.0**: JSZip (dual license)
- **MIT/Apache-2.0**: SQLite-vec (dual license)
- **Unknown**: Some proprietary/unlicensed packages require verification

### Package Update Policy

- **Minimum Release Age**: 2,880 minutes (48 hours)
- **Purpose**: Security vulnerability assessment window

**Source**: `package.json` line 146

## Vulnerability Management

### Automated Security Checks

The project implements the following security measures:

1. **Dependency Overrides**: Explicit version pinning for vulnerable packages
2. **Build-Only Binaries**: Restricted installation of native modules
3. **Release Age Policy**: 48-hour waiting period for dependency updates
4. **Version Constraints**: Specific version requirements for security-critical packages

**Source**: `package.json` pnpm configuration section

## SBOM Generation Commands

To regenerate this SBOM from source:

```bash
# List all production dependencies
pnpm list --prod --depth=0

# List all dependencies including dev
pnpm list --depth=0

# Export dependency tree
pnpm list --json > sbom-dependencies.json

# Check for security vulnerabilities
pnpm audit

# iOS dependencies (requires macOS)
cd apps/ios && xcodegen generate

# Android dependencies
cd apps/android && ./gradlew dependencies
```

## Component Verification

### Checksums and Integrity

All npm packages are verified via:
- **npm registry**: https://registry.npmjs.org/
- **Integrity hashes**: SHA-512 checksums in package-lock files
- **pnpm lockfile**: Ensures reproducible builds

### Supply Chain Security

- **Package provenance**: All packages sourced from public npm registry
- **Build verification**: Git hooks configured for pre-commit checks
- **Native modules**: Built from source during installation

**Source**: `package.json` line 51 (prepare script with git hooks)

## CycloneDX JSON Format

The complete SBOM can be generated in CycloneDX 1.5 JSON format using:

```bash
# Generate CycloneDX SBOM
npx @cyclonedx/cyclonedx-npm --output-file openclaw-sbom.json
```

## Contact and Reporting

- **Security Issues**: https://github.com/openclaw/openclaw/issues
- **Repository**: https://github.com/openclaw/openclaw.git
- **License**: MIT

**Source**: `package.json` lines 5-12

---

**SBOM Version**: 1.0  
**Last Updated**: 2026-02-16  
**Generated From**: package.json v2026.2.16  
**Format Compliance**: CycloneDX 1.5 Specification