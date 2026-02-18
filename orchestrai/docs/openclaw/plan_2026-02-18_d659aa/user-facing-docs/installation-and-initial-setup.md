# Installation and Initial Setup

Welcome to OpenClaw — your personal AI assistant that runs on your own devices and connects to the messaging apps you already use, including WhatsApp, Telegram, Slack, Discord, Signal, iMessage, Microsoft Teams, and more.

This guide walks you through everything you need to get OpenClaw installed and ready to use.

---

## Before You Begin

Make sure your computer meets these requirements:

- **Operating system:** macOS, Linux, or Windows (via WSL2 — strongly recommended for Windows users)
- **Node.js version 22 or newer** must be installed on your computer

> **Windows users:** OpenClaw works best on Windows through WSL2 (Windows Subsystem for Linux 2). Setting up WSL2 first is strongly recommended before proceeding.

---

## Step 1: Install OpenClaw

Open a terminal window and run one of the following commands, depending on your preferred package manager:

**Using npm (most common):**
```
npm install -g openclaw@latest
```

**Using pnpm:**
```
pnpm add -g openclaw@latest
```

**Using bun:**
```
bun add -g openclaw@latest
```

All three options install the same version of OpenClaw. Use whichever package manager you already have, or npm if you're unsure.

---

## Step 2: Run the Onboarding Wizard (Recommended)

The fastest and easiest way to get set up is with the built-in onboarding wizard. It guides you through every step — setting up the gateway, connecting your workspace, choosing messaging channels, and installing skills.

Run this command in your terminal:

```
openclaw onboard --install-daemon
```

The `--install-daemon` flag automatically installs the Gateway as a background service on your computer (using launchd on macOS or systemd on Linux), so OpenClaw keeps running even after you close your terminal.

The wizard will walk you through:

1. **Gateway setup** — configuring the core engine that manages all your channels and conversations
2. **AI model authentication** — connecting your Anthropic or OpenAI account (see the section below)
3. **Channel connections** — linking your messaging apps (WhatsApp, Telegram, Discord, etc.)
4. **Workspace initialization** — setting up your personal assistant workspace
5. **Skills installation** — adding built-in capabilities to your assistant

> **Tip:** You can re-run `openclaw onboard` at any time to add new channels or update your configuration.

---

## Step 3: Connect an AI Model

OpenClaw works with both Anthropic (Claude) and OpenAI (ChatGPT/Codex) accounts. You need at least one active subscription.

**Recommended:** Anthropic Claude Pro/Max subscription with the Claude Opus model — it offers the best performance for long conversations and is more resistant to unwanted manipulation.

### Connecting via the Wizard

The onboarding wizard handles authentication automatically. When prompted, select your preferred provider and follow the on-screen instructions.

### Connecting Manually (after setup)

To log in or add a new AI provider at any time, run:

```
openclaw models auth login
```

You will be guided through selecting your provider (Anthropic or OpenAI) and choosing an authentication method — either via OAuth (browser-based login) or by pasting an API key or token.

**To add or update authentication using a token:**
```
openclaw models auth add
```

---

## Step 4: Verify Your Installation

After setup is complete, confirm everything is working correctly by running the health check tool:

```
openclaw doctor
```

This checks your configuration, connection to your AI model, channel settings, and background service status, and reports any issues with suggested fixes.

---

## What Gets Installed

After a successful setup, OpenClaw creates the following on your computer:

| What | Where |
|------|-------|
| Your settings and configuration | `~/.openclaw/openclaw.json` |
| Channel login credentials | `~/.openclaw/credentials` |
| Your assistant's workspace | `~/.openclaw/workspace` |
| Skills (assistant capabilities) | `~/.openclaw/workspace/skills/` |

---

## Starting the Gateway Manually

If you did not use `--install-daemon` or want to start OpenClaw manually, run:

```
openclaw gateway --port 18789
```

Add `--verbose` for detailed output while troubleshooting:

```
openclaw gateway --port 18789 --verbose
```

The Gateway is the heart of OpenClaw — it manages all your channel connections, conversations, and tools.

---

## Switching Release Channels

OpenClaw offers three release channels:

| Channel | Description |
|---------|-------------|
| **stable** | Official releases — recommended for most users |
| **beta** | Preview releases with new features before they reach stable |
| **dev** | The very latest development version (may be unstable) |

To switch channels, run:

```
openclaw update --channel stable
```

Replace `stable` with `beta` or `dev` as needed.

---

## Updating OpenClaw

When a new version is available, update by running the same install command you used initially:

```
npm install -g openclaw@latest
```

After updating, run `openclaw doctor` to check for any configuration changes needed.

For a full updating guide, visit [docs.openclaw.ai/install/updating](https://docs.openclaw.ai/install/updating).

---

## Troubleshooting Common Issues

### "Command not found: openclaw"
- Make sure your package manager's global bin directory is in your system PATH
- Try closing and reopening your terminal after installation

### Node.js version error
- OpenClaw requires Node.js version 22 or newer
- Check your version by running: `node --version`
- Download the latest version from [nodejs.org](https://nodejs.org)

### Windows installation issues
- Ensure you are running inside WSL2, not the standard Windows Command Prompt or PowerShell
- Follow Microsoft's guide to install WSL2 before retrying

### Gateway won't start
- Run `openclaw doctor` to diagnose the problem
- Check that port 18789 is not already in use by another application

### Authentication errors
- Re-run `openclaw models auth login` to refresh your credentials
- Verify your Anthropic or OpenAI subscription is active
- Check that your API key or token has not expired

### Configuration problems
- The settings file lives at `~/.openclaw/openclaw.json` — the doctor command can identify and repair many common issues automatically

---

## Next Steps

Once OpenClaw is installed and the health check passes, you're ready to:

- **Connect messaging channels** — follow the individual channel guides at [docs.openclaw.ai/channels](https://docs.openclaw.ai/channels)
- **Try talking to your assistant** — send a message and get a response in any connected channel
- **Explore optional companion apps** — macOS menu bar app, iOS node, and Android node for voice and camera features

For the full beginner walkthrough including channel pairing and first conversations, visit [docs.openclaw.ai/start/getting-started](https://docs.openclaw.ai/start/getting-started).