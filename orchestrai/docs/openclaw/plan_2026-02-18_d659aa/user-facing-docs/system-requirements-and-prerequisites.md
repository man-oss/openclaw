# System Requirements and Prerequisites

Before installing OpenClaw, check that your device and accounts meet the requirements below.

---

## Supported Operating Systems

### Primary Platforms (Full Support)

| Platform | Status |
|---|---|
| **macOS** | ✅ Fully supported — recommended for the best experience |
| **Linux** | ✅ Fully supported |
| **Windows (via WSL2)** | ✅ Supported — WSL2 is strongly recommended |

> **Windows users:** OpenClaw runs on Windows through WSL2 (Windows Subsystem for Linux 2). Running OpenClaw directly in a native Windows environment (outside WSL2) is not supported.

### Mobile Platforms (Optional Companion Apps)

| Platform | Status |
|---|---|
| **iOS** | ✅ Optional companion app available — connects as a node to your main OpenClaw setup |
| **Android** | ✅ Optional companion app available — connects as a node to your main OpenClaw setup |

**Important:** iOS and Android apps are companion devices, not standalone installations. They pair with an existing OpenClaw Gateway running on macOS, Linux, or a server. You cannot run OpenClaw's core Gateway on a mobile device alone.

---

## Software Requirements

### Node.js

OpenClaw requires **Node.js version 22 or higher** (minimum 22.12.0).

- Download Node.js from [nodejs.org](https://nodejs.org)
- Versions below 22 are not supported and will not work

### Package Manager

You need one of the following package managers to install OpenClaw:

| Package Manager | Supported | Notes |
|---|---|---|
| **npm** | ✅ Yes | Included with Node.js |
| **pnpm** | ✅ Yes | Recommended if building from source |
| **bun** | ✅ Yes | Optional alternative |

For the standard installation, npm or pnpm works great. If you are building from source code, pnpm is preferred.

---

## AI Provider Accounts

OpenClaw requires an active subscription with at least one AI provider to function. You will connect your account during the setup process.

### Supported Providers

| Provider | Product | Notes |
|---|---|---|
| **Anthropic** | Claude Pro or Max (100/200) | **Strongly recommended** — best for long conversations and security |
| **OpenAI** | ChatGPT / Codex | Fully supported alternative |

> **Recommendation:** Anthropic Pro/Max with the Opus 4.6 model is the preferred choice for the best experience with OpenClaw. It offers stronger performance for long conversations and better resistance to unwanted inputs.

You will need to sign in to your chosen provider during the guided setup process. Both OAuth-based login (for Claude Pro/Max and ChatGPT subscriptions) and direct API keys are supported.

---

## Hardware Requirements

OpenClaw is designed to be lightweight and runs efficiently on modest hardware. No specific minimum hardware specifications are required beyond what is needed to run Node.js 22. It works well on:

- Standard desktop and laptop computers
- Small Linux servers or single-board computers (such as a Raspberry Pi or a small cloud instance)

> **Tip:** Running the Gateway on a small Linux server is a perfectly valid and popular setup. You can then connect your Mac, phone, or other devices to it remotely.

---

## Network Requirements

- **Internet connection** is required to communicate with AI providers (Anthropic, OpenAI) and to use messaging channels (WhatsApp, Telegram, Slack, Discord, etc.)
- The Gateway runs locally on your machine and by default listens on your local network only
- For remote access from outside your home network, optional tools like Tailscale or SSH tunnels can be configured after setup

---

## Mobile App Requirements

### iOS Companion App

- An iPhone or iPad running a recent version of iOS
- An existing OpenClaw Gateway already running on macOS, Linux, or a server
- The iOS app pairs with your Gateway over your local network or remotely

### Android Companion App

- An Android phone or tablet
- An existing OpenClaw Gateway already running on macOS, Linux, or a server
- The Android app pairs with your Gateway the same way as iOS

---

## Quick Compatibility Check

Ask yourself these questions before installing:

1. **Are you on macOS or Linux?** → Ready to install directly.
2. **Are you on Windows?** → Install WSL2 first, then install OpenClaw inside it.
3. **Is Node.js 22 or higher installed?** → Run `node --version` to check. If not, install it from [nodejs.org](https://nodejs.org).
4. **Do you have an Anthropic or OpenAI account?** → You need at least one active subscription before completing setup.
5. **Are you on iOS or Android?** → You'll need a Mac, Linux machine, or server running the Gateway first, then install the mobile companion app to connect to it.

---

## Where to Go Next

Once your system meets these requirements, follow the [Getting Started guide](https://docs.openclaw.ai/start/getting-started) to install OpenClaw and run the setup wizard. The wizard will walk you through every step, including connecting your AI provider account and setting up your first messaging channel.