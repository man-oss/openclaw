# OpenClaw — Frequently Asked Questions

## General

### What is OpenClaw?

OpenClaw is a personal AI assistant you run on your own devices. It connects to the messaging apps you already use — including WhatsApp, Telegram, Slack, Discord, Google Chat, Signal, iMessage, Microsoft Teams, and more — and lets you interact with an AI assistant through any of them. Everything runs locally on your own machine, keeping you in control.

---

### Is OpenClaw free to use?

OpenClaw itself is free and open-source under the MIT license. However, to use it meaningfully, you need access to an AI model. OpenClaw currently supports:

- **Anthropic** (Claude Pro/Max subscription)
- **OpenAI** (ChatGPT/Codex subscription)

You bring your own account and credentials — OpenClaw connects to these services on your behalf. API key access is also supported.

---

### What AI model should I use?

While OpenClaw works with any supported model, the recommended setup is **Anthropic Claude Opus (Pro/Max plan)** for its long-context strength and better resistance to prompt injection from untrusted message sources. See the [onboarding guide](https://docs.openclaw.ai/start/onboarding) for details.

---

### Is this an official product? Who makes it?

OpenClaw is an open-source community project, not an official product of Anthropic, OpenAI, or any AI provider. It was created by Peter Steinberger and is maintained by a growing community of contributors. The source code is publicly available on GitHub at [github.com/openclaw/openclaw](https://github.com/openclaw/openclaw).

---

## Installation & Setup

### What do I need to get started?

- **Node.js version 22.12.0 or newer** (Node ≥22 is required)
- A package manager: npm, pnpm, or bun
- An account with Anthropic or OpenAI

---

### What platforms does OpenClaw run on?

OpenClaw runs on **macOS, Linux, and Windows via WSL2** (Windows Subsystem for Linux 2, which is strongly recommended over native Windows). The optional companion apps for voice, canvas, and mobile features are available on macOS, iOS, and Android.

---

### How do I install OpenClaw?

Run the following in your terminal:

```bash
npm install -g openclaw@latest
openclaw onboard --install-daemon
```

The onboarding wizard walks you through every step — gateway setup, channel connections, and AI model configuration. This is the recommended starting point for all new users.

---

### What are the release channels, and which should I use?

| Channel | Description | npm tag |
|---------|-------------|---------|
| **stable** | Tagged, production-ready releases | `latest` |
| **beta** | Pre-release builds for early testing | `beta` |
| **dev** | Moving head of the main branch | `dev` |

Most users should stay on **stable**. You can switch channels at any time with `openclaw update --channel stable`.

---

## Channels & Messaging

### Which messaging apps does OpenClaw support?

OpenClaw connects to:

- WhatsApp
- Telegram
- Slack
- Discord
- Google Chat
- Signal
- iMessage (via BlueBubbles — recommended, or the legacy imsg integration on macOS)
- Microsoft Teams
- Matrix
- Zalo & Zalo Personal
- WebChat (built into the Gateway)

---

### Can I connect multiple channels at the same time?

Yes. OpenClaw's Gateway acts as a single control plane that manages all your connected channels simultaneously. You can route different channels or accounts to different isolated agents (workspaces) if needed.

---

### Who can message my assistant?

By default, OpenClaw uses a **pairing policy** — unknown senders receive a short pairing code and their message is not processed until you approve them. You approve senders with `openclaw pairing approve <channel> <code>`.

To allow anyone to message your assistant, you would need to explicitly opt in by setting an open DM policy. The default is intentionally restrictive to keep your assistant secure.

---

### Can I use OpenClaw in a group chat?

Yes. Group chats are supported across most channels. By default, the assistant only responds when mentioned in a group. You can toggle this behavior with `/activation mention|always` from within the chat. Group access is also controlled by allowlists you configure.

---

## Privacy & Security

### Is my data sent anywhere?

Your messages are sent to your chosen AI provider (Anthropic or OpenAI) for processing — that is inherent to how these models work. OpenClaw itself runs locally on your device. The Gateway does not relay your data to any OpenClaw-operated servers.

---

### How does OpenClaw handle security for inbound messages?

OpenClaw treats all inbound messages as untrusted input. Key security defaults include:

- **DM pairing** is on by default — strangers cannot interact with your assistant without approval
- **Sandbox mode** is available for group/channel sessions, running AI actions inside isolated Docker containers
- Run `openclaw doctor` at any time to surface risky or misconfigured settings

Review the full [security guide](https://docs.openclaw.ai/gateway/security) before exposing the Gateway to the internet.

---

### Is it safe to expose the Gateway remotely?

You can expose the Gateway remotely using Tailscale Serve (tailnet-only) or Tailscale Funnel (public internet). Public exposure via Funnel requires password authentication to be enabled — OpenClaw enforces this. For most users, Tailscale Serve (tailnet-only) is the safer option.

---

## Features & Capabilities

### Does OpenClaw support voice?

Yes. On macOS and iOS/Android, OpenClaw supports:

- **Voice Wake** — always-on wake word detection
- **Talk Mode** — continuous spoken conversation with the assistant (using ElevenLabs for voice synthesis)
- Push-to-talk via the macOS menu bar app

---

### What are "skills"?

Skills are extensions that give your assistant new capabilities — things like browsing the web, running automations, or interacting with specific services. Skills can be bundled (built-in), managed (installed via the ClawHub registry), or custom (your own workspace skills placed in `~/.openclaw/workspace/skills/`).

---

### What is the Live Canvas?

Live Canvas is an agent-driven visual workspace available on macOS and iOS/Android. Your assistant can push visual content and interactive elements to the Canvas in real time. It uses a system called A2UI for agent-to-interface communication.

---

### Can I run the Gateway on a remote server?

Yes. Running the Gateway on a small Linux server is fully supported. Your devices (macOS app, CLI, mobile nodes) connect to it over Tailscale or SSH tunnels. Device-specific features like camera, screen recording, and notifications run on the device itself via the node system, not on the server.

---

## Troubleshooting & Maintenance

### Something isn't working. Where do I start?

Run `openclaw doctor` — it checks your configuration, surfaces common issues, and flags risky settings. This is always the first step when something seems off.

---

### How do I update OpenClaw?

```bash
openclaw update --channel stable
```

After updating, refer to the [updating guide](https://docs.openclaw.ai/install/updating) and run `openclaw doctor` to catch any migration issues.

---

### What chat commands are available?

You can send these commands directly in any connected chat (WhatsApp, Telegram, Slack, etc.):

| Command | What it does |
|---------|--------------|
| `/status` | Shows current session status (model, token usage, cost) |
| `/new` or `/reset` | Starts a fresh session |
| `/compact` | Summarizes and compresses the session context |
| `/think <level>` | Sets thinking depth: off, minimal, low, medium, high, xhigh |
| `/verbose on\|off` | Toggles verbose mode |
| `/usage off\|tokens\|full` | Controls the usage footer shown after responses |
| `/restart` | Restarts the Gateway (owner only in groups) |
| `/activation mention\|always` | Toggles group activation mode |

---

### Where can I get help?

- **Documentation**: [docs.openclaw.ai](https://docs.openclaw.ai)
- **Community Discord**: [discord.gg/clawd](https://discord.gg/clawd)
- **Bug reports**: [GitHub Issues](https://github.com/openclaw/openclaw/issues)
- **Getting started guide**: [docs.openclaw.ai/start/getting-started](https://docs.openclaw.ai/start/getting-started)