# Installation and Initial Setup

OpenClaw is a personal AI assistant that runs on your own devices and connects to messaging platforms you already use. This guide will walk you through installing OpenClaw and getting it ready for your first use.

## System Requirements

Before you begin, make sure your computer meets these requirements:

- **Node.js version 22.12.0 or newer** must be installed on your system
- A supported operating system:
  - **macOS** (recommended for full features)
  - **Linux** (fully supported)
  - **Windows** via WSL2 (Windows Subsystem for Linux - strongly recommended over native Windows)

## Installation Methods

You can install OpenClaw using any of these package managers:

### Using npm (most common)

```bash
npm install -g openclaw@latest
```

### Using pnpm

```bash
pnpm add -g openclaw@latest
```

### Using bun

```bash
bun add -g openclaw
```

The installation downloads OpenClaw and makes it available as a command you can run from anywhere on your computer.

## Initial Setup with the Setup Wizard

After installation, start the setup wizard to configure OpenClaw. This guided process helps you set up everything you need:

```bash
openclaw onboard --install-daemon
```

The `--install-daemon` flag ensures OpenClaw keeps running in the background automatically, even after you close your terminal window.

### What the Wizard Does

The setup wizard guides you through:

1. **Selecting your AI model provider** - Choose between Anthropic (Claude) or OpenAI (ChatGPT)
2. **Connecting messaging platforms** - Link WhatsApp, Telegram, Slack, Discord, or other channels
3. **Setting up workspace** - Configure where OpenClaw stores its files and settings
4. **Installing background service** - Set up OpenClaw to start automatically when your computer boots

Follow the on-screen prompts and answer each question. The wizard provides helpful explanations at each step.

## Verifying Your Installation

After the wizard completes, verify OpenClaw is working correctly:

### Check the Version

```bash
openclaw --version
```

This displays the installed version number.

### Start the Gateway

The Gateway is OpenClaw's control center that manages all connections and conversations:

```bash
openclaw gateway --port 18789 --verbose
```

You should see messages indicating the Gateway has started successfully. The Gateway runs on port 18789 by default and handles all communication between you and your assistant.

### Test Basic Commands

Try these commands to ensure everything works:

**Check system status:**
```bash
openclaw doctor
```

This diagnostic command checks your setup and reports any issues it finds.

**Send a test message:**
```bash
openclaw agent --message "Hello, are you working?"
```

If you receive a response, OpenClaw is installed and working correctly.

## Configuration File Location

OpenClaw stores its settings in a configuration file at:

```
~/.openclaw/openclaw.json
```

The setup wizard creates this file automatically. You can edit it later to customize your settings, though the wizard handles all essential configuration.

### Basic Configuration Structure

Your configuration file starts minimal and grows as you add features:

```json
{
  "agent": {
    "model": "anthropic/claude-opus-4-6"
  }
}
```

This sets your AI model. The wizard helps you choose the right model based on your subscription.

## Understanding Installation Components

### The Gateway Service

The Gateway service manages:
- Connections to messaging platforms
- Conversations with your AI assistant  
- Background automation and scheduled tasks
- Access to tools like web browsing and system commands

When you enable the background service during setup, the Gateway starts automatically when your computer boots.

### Workspace Directory

OpenClaw creates a workspace at:

```
~/.openclaw/workspace
```

This directory contains:
- Custom instructions for your assistant
- Skills and capabilities you add over time
- Conversation context and memory
- Temporary files created during assistant interactions

### Credentials Storage

Sensitive information like API keys and authentication tokens are stored securely in:

```
~/.openclaw/credentials
```

Never share files from this directory or commit them to version control systems.

## Common Installation Issues

### Node.js Version Too Old

**Problem:** You see an error about Node.js version compatibility.

**Solution:** Install Node.js 22.12.0 or newer from the official Node.js website.

### Permission Errors During Installation

**Problem:** Installation fails with "EACCES" or permission denied errors.

**Solution:** On macOS and Linux, avoid using `sudo` with global npm installs. Instead, configure npm to install packages in your home directory:

```bash
mkdir ~/.npm-global
npm config set prefix '~/.npm-global'
```

Then add this line to your shell profile (`~/.bashrc` or `~/.zshrc`):

```bash
export PATH=~/.npm-global/bin:$PATH
```

### Port Already in Use

**Problem:** The Gateway fails to start because port 18789 is already in use.

**Solution:** Either stop the other service using that port, or configure OpenClaw to use a different port in your configuration file.

### Command Not Found After Installation

**Problem:** Running `openclaw` shows "command not found".

**Solution:** Make sure your package manager's global bin directory is in your PATH. Close and reopen your terminal window, then try again.

## Next Steps After Installation

Once OpenClaw is installed and verified:

1. **Complete the onboarding wizard** if you haven't already - it configures your messaging platforms and AI preferences
2. **Review the Dashboard** - Access it by visiting `http://localhost:18789` in your web browser while the Gateway is running
3. **Connect your first messaging platform** - The wizard helps with this, or you can add platforms later through configuration
4. **Send your first message** - Try talking to your assistant through your connected messaging platform

## Updating OpenClaw

To update to the latest version:

```bash
npm update -g openclaw
```

Or with pnpm:

```bash
pnpm update -g openclaw
```

After updating, run the diagnostic command to ensure everything still works:

```bash
openclaw doctor
```

## Getting Help

If you encounter problems during installation:

- Run `openclaw doctor` to diagnose configuration issues
- Check the logs at `~/.openclaw/logs` for error messages
- Visit the documentation at [docs.openclaw.ai](https://docs.openclaw.ai)
- Join the Discord community for support

Your OpenClaw installation is now complete and ready for configuration with your AI models and messaging platforms.