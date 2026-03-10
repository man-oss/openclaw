# OpenClaw — Frequently Asked Questions

Get answers to the most common questions about setting up and running OpenClaw.

---

## General

### What is OpenClaw?

OpenClaw is a personal AI assistant you run on your own devices. It connects to messaging apps you already use — including WhatsApp, Telegram, Slack, Discord, Signal, iMessage, Microsoft Teams, Google Chat, and more — and routes conversations through a local Gateway that you control. The assistant responds through whichever channel you message it on.

### What AI models does OpenClaw support?

OpenClaw works with any model, but the recommended setup is **Anthropic Claude (Pro/Max subscription, Opus 4.6)** for its long-context strength and better resistance to prompt injection. OpenAI (ChatGPT/Codex) is also fully supported. You can configure the model in your settings file:

```json
{
  "agent": {
    "model": "anthropic/claude-opus-4-6"
  }
}
```

---

## Installation & Setup

### What do I need to run OpenClaw?

- **Node.js version 22 or later** (required)
- A package manager: npm, pnpm, or bun
- macOS, Linux, or Windows via WSL2 (WSL2 strongly recommended on Windows)

### How do I get started?

The easiest path is the onboarding wizard. Open your terminal and run:

```bash
npm install -g openclaw@latest
openclaw onboard --install-daemon
```

The wizard walks you through setting up the Gateway, connecting channels, and configuring your assistant step by step. A full beginner guide is available at [docs.openclaw.ai/start/getting-started](https://docs.openclaw.ai/start/getting-started).

### How do I keep OpenClaw up to date?

Run the following command:

```bash
openclaw update --channel stable
```

You can also switch to **beta** (pre-release features) or **dev** (latest development build) by replacing `stable` with `beta` or `dev`. After updating, run `openclaw doctor` to check for any issues.

---

## Channels & Messaging

### Which messaging apps does OpenClaw support?

OpenClaw supports a wide range of channels out of the box:

- **WhatsApp** (via Baileys)
- **Telegram**
- **Slack**
- **Discord**
- **Signal** (requires signal-cli)
- **iMessage** via BlueBubbles (recommended) or the legacy macOS-only method
- **Microsoft Teams**
- **Google Chat**
- **Matrix**, **Zalo**, **Zalo Personal** (extension channels)
- **WebChat** (built-in web interface served directly from the Gateway)

### How do I control who can message my assistant?

Each channel has an allowlist. For example, on WhatsApp you set `channels.whatsapp.allowFrom`, on Discord you set `channels.discord.allowFrom`, and so on.

By default, unknown senders receive a short pairing code and their message is not processed. To approve a new sender, run:

```bash
openclaw pairing approve <channel> <code>
```

To allow anyone to message the assistant, set `dmPolicy="open"` and include `"*"` in the channel's allowlist. Run `openclaw doctor` at any time to check for risky configurations.

### Can I use OpenClaw in group chats?

Yes. Groups are supported across most channels. You can configure which groups are allowed, whether the assistant requires an @mention to respond, and how responses are routed. Group commands (like `/restart`) are restricted to the owner by default.

---

## Running the Gateway

### What is the Gateway?

The Gateway is the central piece of OpenClaw that runs on your device (or a server). It manages all channel connections, sessions, tools, and events. Clients like the macOS app, CLI, and WebChat all connect to the Gateway over a local WebSocket connection at `ws://127.0.0.1:18789` by default.

### Can I run the Gateway on a remote server (like a Linux VPS)?

Yes. The Gateway runs well on any small Linux instance. You can connect your local clients (macOS app, CLI, WebChat) to it remotely using **Tailscale Serve/Funnel** or an **SSH tunnel**. Device-specific actions (camera, screen recording, notifications) are handled by companion apps on your local device.

### How do I expose the Gateway dashboard securely?

OpenClaw has built-in Tailscale support. Set `gateway.tailscale.mode` in your configuration:

- `serve` — tailnet-only HTTPS (private to your Tailscale network)
- `funnel` — public HTTPS (requires password authentication)
- `off` — no Tailscale automation (default)

**Important:** Funnel will not start unless password authentication is enabled (`gateway.auth.mode: "password"`).

### What happens if the Gateway goes offline or is temporarily unreachable?

OpenClaw's Gateway is a local process — if it stops, incoming messages from channels will not be processed until it restarts. The Gateway daemon (installed via `openclaw onboard --install-daemon`) is set up as a system service (launchd on macOS, systemd on Linux) so it restarts automatically after crashes or reboots. There is no cloud-based message buffer; messages sent while the Gateway is offline may be lost or queued by the upstream messaging platform (behavior varies by channel). To check the Gateway's health at any time, use `openclaw doctor`.

---

## Privacy & Security

### Is my data sent to any cloud service?

OpenClaw is local-first. Your Gateway, sessions, tools, and configuration run on your own hardware. Conversations are processed by the AI model you configure (Anthropic or OpenAI), so message content is sent to your chosen AI provider. No message data is sent to OpenClaw's servers.

### How does OpenClaw handle security for inbound messages?

All inbound DMs are treated as untrusted input by default. The pairing system (`dmPolicy="pairing"`) requires unknown senders to complete a code exchange before the assistant responds to them. For group chats, you can require @mentions and restrict which groups are allowed. Run `openclaw doctor` to surface any risky or misconfigured policies.

### Can the assistant run commands on my computer?

Yes — by design, for the main (personal) session. This is what allows the assistant to run scripts, open the browser, take screenshots, and more. For group or channel sessions (non-main sessions), you can enable sandboxed Docker execution via `agents.defaults.sandbox.mode: "non-main"` to isolate those sessions from host-level access. See the [Security guide](https://docs.openclaw.ai/gateway/security) for full details.

---

## Chat Commands

### What commands can I send to the assistant?

You can send these commands directly in any supported chat (WhatsApp, Telegram, Slack, Discord, Google Chat, Microsoft Teams, WebChat):

| Command | What it does |
|---|---|
| `/status` | Shows current session status (model, token usage, cost) |
| `/new` or `/reset` | Starts a fresh conversation |
| `/compact` | Summarizes and compresses the current conversation |
| `/think <level>` | Sets thinking depth: `off`, `minimal`, `low`, `medium`, `high`, `xhigh` |
| `/verbose on\|off` | Toggles verbose responses |
| `/usage off\|tokens\|full` | Controls the usage summary shown after each reply |
| `/restart` | Restarts the Gateway (owner only in groups) |
| `/activation mention\|always` | Controls whether the assistant responds to all messages or only @mentions (groups only) |

---

## Companion Apps

### Do I need to install any apps?

No. The Gateway alone provides a complete experience through your existing messaging apps. The companion apps are optional and add extra features:

- **macOS app** — menu bar control, Voice Wake, push-to-talk, WebChat, remote gateway management
- **iOS app** — Canvas, Voice Wake, Talk Mode, camera, screen recording
- **Android app** — Canvas, Talk Mode, camera, screen recording, optional SMS

### Does OpenClaw work on Windows?

Yes, via **WSL2** (Windows Subsystem for Linux 2). WSL2 is strongly recommended for the best experience on Windows. The macOS and iOS/Android companion apps are not available on Windows, but the Gateway and all channel integrations work normally.

---

## Troubleshooting

### The assistant isn't responding. What should I check?

1. Run `openclaw doctor` — it checks for common configuration issues, risky DM policies, and connectivity problems.
2. Confirm the Gateway is running: `openclaw gateway --port 18789 --verbose`
3. Check that the sender is on the channel's allowlist, or approve them via the pairing flow.
4. Review logs for errors: see the [Logging guide](https://docs.openclaw.ai/logging) for log file locations.

### How do I completely reset a conversation?

Send `/new` or `/reset` in any chat. This clears the current session and starts fresh.

### Where can I get more help?

- **Full documentation:** [docs.openclaw.ai](https://docs.openclaw.ai)
- **Community Discord:** [discord.gg/clawd](https://discord.gg/clawd)
- **Troubleshooting guide:** [docs.openclaw.ai/channels/troubleshooting](https://docs.openclaw.ai/channels/troubleshooting)
- **GitHub Issues:** [github.com/openclaw/openclaw/issues](https://github.com/openclaw/openclaw/issues)