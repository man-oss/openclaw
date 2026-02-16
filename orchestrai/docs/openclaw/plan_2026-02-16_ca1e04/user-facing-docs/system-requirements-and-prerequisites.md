# System Requirements and Prerequisites

## Overview

Before installing OpenClaw, ensure your system meets the following requirements. OpenClaw is a personal AI assistant that runs locally on your devices and requires specific software, hardware, and account prerequisites.

## Supported Operating Systems

### macOS
- **Supported**: macOS (version not specified, but modern versions recommended)
- **Use Case**: Full feature set including menu bar app, Voice Wake, Canvas, and all node capabilities
- **Notes**: Can run both the Gateway server and companion app

### Linux
- **Supported**: All major Linux distributions
- **Use Case**: Ideal for running the Gateway server on cloud or local instances
- **Notes**: Recommended for remote deployments; all core features supported

### Windows
- **Supported**: Windows via WSL2 (Windows Subsystem for Linux 2)
- **Requirement**: WSL2 is **strongly recommended** and required for proper operation
- **Notes**: Native Windows support not available; must use WSL2 environment

## Node.js Requirements

### Version Requirement
- **Minimum Version**: Node.js 22.12.0 or higher
- **Required**: Node.js ≥22 is mandatory
- **Module Type**: ESM (ECMAScript Modules) - the project uses `"type": "module"`

### Package Manager Options

OpenClaw supports multiple package managers:

**npm** (Node Package Manager)
- Built into Node.js
- Fully supported for installation and operation

**pnpm** (Preferred for Development)
- **Version**: pnpm 10.23.0
- Recommended for building from source
- Faster and more efficient than npm

**bun** (Alternative Runtime)
- Supported for running TypeScript directly
- Optional but provides performance benefits

## Required Accounts and Subscriptions

OpenClaw requires active subscriptions to AI model providers. These are **mandatory prerequisites**.

### Anthropic Subscription
- **Provider**: [Anthropic](https://www.anthropic.com/)
- **Plans**: Claude Pro or Claude Max
- **Recommended**: Claude Pro/Max with Opus 4.6 model
- **Why Recommended**: Superior long-context processing and better prompt-injection resistance
- **OAuth Support**: Yes

### OpenAI Subscription
- **Provider**: [OpenAI](https://openai.com/)
- **Plans**: ChatGPT or Codex subscriptions
- **OAuth Support**: Yes

**Note**: While any model provider is technically supported, Anthropic Pro/Max (100/200) with Opus 4.6 is strongly recommended for optimal performance.

## Mobile Device Requirements

### iOS Devices
- **Compatibility**: iOS devices running modern iOS versions
- **Features**: 
  - Canvas interface
  - Voice Wake functionality
  - Talk Mode
  - Camera access
  - Screen recording
  - Bonjour pairing for Gateway connection

### Android Devices
- **Compatibility**: Android devices (version not specified)
- **Features**:
  - Canvas interface
  - Talk Mode
  - Camera access
  - Screen recording
  - Optional SMS integration
  - Gateway pairing via Bridge

**Note**: Mobile apps are **optional**. The Gateway alone provides full functionality through messaging channels.

## Network Requirements

### Local Network
- **WebSocket Support**: Required for Gateway communication (default port: 18789)
- **mDNS/Bonjour**: Used for device discovery (optional but recommended)
- **Internet Connection**: Required for AI model API access

### Remote Access Options

**Tailscale** (Optional but Recommended)
- Enables secure remote access to Gateway
- Supports Serve (tailnet-only) or Funnel (public) modes
- No additional port forwarding needed

**SSH Tunnels** (Alternative)
- Can be used for remote Gateway access
- Manual configuration required

## Hardware Recommendations

### For Gateway Server

**Minimum Requirements**:
- Single-core processor capable of running Node.js 22+
- 512MB RAM (1GB+ recommended)
- 500MB disk space for installation
- Additional space for workspace and session data

**Recommended Setup**:
- Multi-core processor for better performance
- 2GB+ RAM for handling multiple channels
- SSD storage for faster operation
- Stable internet connection for AI API calls

**Remote Instance**: A small Linux cloud instance is perfectly adequate for running the Gateway server.

### For Client Devices

**macOS App**:
- Modern Mac with macOS support
- Required for device-local actions (system.run, notifications)
- Microphone access for Voice Wake
- Screen recording permissions for certain features

**iOS/Android Apps**:
- Mobile device with camera
- Microphone for voice features
- Sufficient storage for app installation
- Location services (if using location features)

## Additional Software Dependencies

### For Browser Control (Optional)
- Chrome or Chromium browser
- OpenClaw can manage a dedicated browser instance
- Required only if using browser automation features

### For Signal Integration (Optional)
- `signal-cli` package
- Required only for Signal messaging channel

### For Docker Sandboxing (Optional)
- Docker or compatible container runtime
- Required only if enabling sandbox mode for non-main sessions
- Provides isolation for group/channel interactions

## Permission Requirements

### macOS Permissions
When using the macOS app in node mode:
- **Screen Recording**: Required for certain system.run commands
- **Notifications**: Required for system.notify
- **Microphone**: Required for Voice Wake and Talk Mode
- **Camera**: Required for camera snap/clip features
- **Location**: Required for location.get command

### iOS Permissions
- Camera access
- Microphone access
- Location services
- Local network access for Gateway connection

### Android Permissions
- Camera
- Microphone
- Storage
- Optional: SMS (if using SMS features)

## Pre-Installation Checklist

Before proceeding with installation, verify you have:

- [ ] Operating system: macOS, Linux, or Windows with WSL2
- [ ] Node.js version 22.12.0 or higher installed
- [ ] Active Anthropic or OpenAI subscription with OAuth credentials
- [ ] Package manager installed (npm, pnpm, or bun)
- [ ] Internet connection for downloading packages and accessing AI APIs
- [ ] (Optional) Tailscale account for remote access
- [ ] (Optional) Mobile device for iOS/Android companion apps
- [ ] (Optional) Docker installed if planning to use sandbox mode

## Not Required

The following are **not** prerequisites:
- Specific messaging app accounts (configured during setup)
- Public IP address or domain name
- Advanced technical knowledge (wizard guides you through setup)
- Dedicated server hardware (can run on personal computer)
- Multiple devices (single device can run everything)

## Next Steps

Once you have confirmed your system meets all requirements:

1. Install OpenClaw globally using your package manager
2. Run the onboarding wizard: `openclaw onboard --install-daemon`
3. Follow the wizard to configure your AI model subscriptions
4. Set up messaging channels as needed
5. (Optional) Install companion apps on mobile devices

For detailed installation instructions, proceed to the Getting Started guide.