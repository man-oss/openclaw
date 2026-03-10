# Quick Start: Install OpenClaw and Run Your First Trace

Get OpenClaw up and running in minutes. By the end of this guide, you will have sent your first message through the assistant and seen it respond live.

---

## What You Need Before Starting

- **Node.js version 22 or higher** installed on your computer
- **npm or pnpm** (comes with Node.js)
- A terminal or command prompt open and ready
- An active account with [Anthropic](https://www.anthropic.com/) (Claude) or [OpenAI](https://openai.com/) (ChatGPT)

---

## Step 1: Install OpenClaw

Open your terminal and run one of the following commands to install OpenClaw globally on your machine:

**Using npm:**
```bash
npm install -g openclaw@latest
```

**Using pnpm:**
```bash
pnpm add -g openclaw@latest
```

This installs the `openclaw` command so you can use it from anywhere on your computer.

---

## Step 2: Run the Setup Wizard

OpenClaw includes a guided setup wizard that walks you through everything — connecting your AI account, choosing your channels, and starting the assistant for the first time.

Run this command to start the wizard and install the background service:

```bash
openclaw onboard --install-daemon
```

The wizard will:
1. Ask which AI service you want to use (Anthropic or OpenAI)
2. Help you connect your account
3. Set up the OpenClaw Gateway as a background service that stays running automatically

Follow the on-screen prompts to complete each step. The whole process takes about 2–5 minutes.

---

## Step 3: Set Your AI Model

Once the wizard finishes, OpenClaw creates a settings file on your computer. You can open it and make sure it has a model selected. Here is the minimal configuration you need:

```json
{
  "agent": {
    "model": "anthropic/claude-opus-4-6"
  }
}
```

> **Recommended:** Claude Opus 4.6 (Anthropic Pro/Max subscription) is the best choice for long conversations and strong performance. Any model is supported, but this one is the top pick.

If you prefer OpenAI, you can set `"model"` to your preferred OpenAI model name instead.

---

## Step 4: Start the Gateway

If the background service is not already running, start the Gateway manually:

```bash
openclaw gateway --port 18789 --verbose
```

The `--verbose` flag shows you live activity so you can see what is happening as messages flow through. You will see log output confirming the Gateway is running.

---

## Step 5: Send Your First Message

Now send a message to your assistant:

```bash
openclaw agent --message "Hello! Are you there?" --thinking high
```

You will see a response printed directly in your terminal. The `--thinking high` option gives the assistant more processing time for better answers.

That's it — you have just run your first successful interaction through OpenClaw! 🦞

---

## Step 6: Verify Everything Is Working

Run the built-in health check to confirm your setup is correct:

```bash
openclaw doctor
```

This scans your configuration and surfaces any issues — misconfigurations, missing credentials, or anything that needs attention.

---

## What Happens Next

Once your assistant is responding, you can:

- **Connect messaging apps** — link WhatsApp, Telegram, Slack, Discord, Signal, and more so your assistant lives inside the apps you already use
- **Use voice** — enable always-on Voice Wake or Talk Mode on macOS, iOS, or Android
- **Add skills** — install extra capabilities through the Skills platform and ClawHub registry
- **Open the web dashboard** — the Gateway serves a live Control UI at `http://127.0.0.1:18789` for managing sessions and settings

---

## Useful Commands at a Glance

| What you want to do | Command |
|---|---|
| Start the setup wizard | `openclaw onboard --install-daemon` |
| Start the Gateway manually | `openclaw gateway --port 18789` |
| Chat with your assistant | `openclaw agent --message "your message"` |
| Check for problems | `openclaw doctor` |
| Send a message to a contact | `openclaw message send --to +1234567890 --message "Hello"` |

---

## Need Help?

- **Full getting started guide:** [docs.openclaw.ai/start/getting-started](https://docs.openclaw.ai/start/getting-started)
- **All configuration options:** [docs.openclaw.ai/gateway/configuration](https://docs.openclaw.ai/gateway/configuration)
- **Troubleshooting guide:** [docs.openclaw.ai/channels/troubleshooting](https://docs.openclaw.ai/channels/troubleshooting)
- **Community Discord:** [discord.gg/clawd](https://discord.gg/clawd)