# Your First AI Conversation with OpenClaw — Quick Start

Welcome to OpenClaw! This guide walks you through connecting to an AI provider and having your first real conversation with your personal assistant. Follow these steps and you'll be chatting with AI in under 15 minutes.

---

## What You'll Need Before Starting

- **OpenClaw installed** on your computer (macOS, Linux, or Windows via WSL2)
- **An account with at least one AI provider:**
  - [Anthropic](https://www.anthropic.com/) — for Claude (recommended for best results)
  - [OpenAI](https://openai.com/) — for ChatGPT models
- About 10–15 minutes of your time

> **Recommended:** Anthropic Claude Pro or Max subscription with the Opus model gives the best experience for most users.

---

## Step 1 — Install OpenClaw

If you haven't installed OpenClaw yet, open your terminal and run:

```
npm install -g openclaw@latest
```

Then run the setup wizard, which guides you through everything interactively:

```
openclaw onboard --install-daemon
```

The wizard walks you through each step, including connecting to your AI provider. If you used the full onboarding wizard and already set up a provider, skip to **Step 4**.

---

## Step 2 — Connect Your AI Provider

This is where OpenClaw learns how to reach your AI service. You have two options depending on your provider.

### Option A — Anthropic (Claude) via Setup Token (Easiest)

If you have a Claude Pro or Max subscription, this is the recommended path.

**1. Get your setup token from the Claude app:**
Open a terminal and run the Claude desktop app command to generate a token:
```
claude setup-token
```
Copy the token it displays.

**2. Add the token to OpenClaw:**
```
openclaw models auth setup-token
```

OpenClaw will ask:
> *"Have you run `claude setup-token` and copied the token?"*

Confirm with **Yes**, then paste your token when prompted. That's it — Anthropic is connected!

---

### Option B — Any Provider via API Key

If you're using OpenAI or another provider with an API key:

```
openclaw models auth add
```

You'll see a menu to choose your provider:
```
  ● anthropic
  ○ custom (type provider id)
```

Select your provider, then choose **"paste token"** and enter your API key when asked. OpenClaw will also ask if your key has an expiry date — enter a duration like `365d` if it does, or skip it if not.

---

### Option C — Guided Interactive Login (OAuth or API Key)

For a fully guided experience that supports both OAuth sign-in and API keys:

```
openclaw models auth login
```

OpenClaw shows you every available provider and walks you through selecting an authentication method step by step. For Anthropic, you can sign in via your Claude account directly (OAuth) without needing to copy any tokens manually.

---

## Step 3 — Check That Everything Is Connected

Before sending your first message, verify your setup is working:

```
openclaw models status
```

You'll see a summary like this:

```
Config          : ~/.openclaw/openclaw.json
Default         : anthropic/claude-opus-4-6
Fallbacks (0)   : -

Auth overview
Auth store      : ~/.openclaw/auth-profiles.json
Shell env       : off
Providers w/ OAuth/tokens (1): anthropic (1)

- anthropic  effective:oauth  profiles: 1 (oauth=1, token=0, api_key=0)

OAuth/token status
- anthropic
  - anthropic:manual  ok  expires in 29d
```

**What to look for:**
- ✅ Your provider (e.g., `anthropic`) appears under **"Providers w/ OAuth/tokens"**
- ✅ The status next to your profile says **ok**
- ❌ If you see **expired** or **missing**, re-run the auth step above

To check status in a simple pass/fail way (useful for troubleshooting):
```
openclaw models status --check
```

---

## Step 4 — Send Your First Message

You're ready to talk to the AI! Run:

```
openclaw agent --message "Hello! What can you help me with today?"
```

The assistant will respond directly in your terminal. You should see a reply explaining its capabilities within a few seconds.

**Try a few more examples:**

```
openclaw agent --message "Summarize what OpenClaw is in two sentences"
```

```
openclaw agent --message "Write a short to-do list for setting up a home office"
```

```
openclaw agent --message "What's the weather like on Mars?"
```

---

## Step 5 — Understanding How Responses Work

When you send a message, here's what happens behind the scenes (in plain terms):

1. **Your message goes to the OpenClaw Gateway** — the central hub running on your computer
2. **The Gateway forwards it to your AI provider** (Anthropic or OpenAI) using the credentials you set up
3. **The AI generates a response** and streams it back to OpenClaw
4. **OpenClaw displays the response** in your terminal (and can also deliver it to any connected messaging apps like WhatsApp or Telegram)

Responses stream in as they're generated, so you'll see text appearing progressively — just like a live chat.

---

## Step 6 — Connect to Your Messaging Apps (Optional)

Once your AI conversation is working in the terminal, you can bring it to the apps you already use every day. OpenClaw supports:

- **WhatsApp** — message your assistant just like a contact
- **Telegram** — chat via a bot
- **Discord** — talk to the assistant in a server or DM
- **Slack** — get answers directly in your workspace
- **iMessage, Signal, Microsoft Teams, Google Chat**, and more

To set up a messaging channel, run the configuration wizard again:
```
openclaw onboard
```

Or see the [full channel setup guides](https://docs.openclaw.ai/channels) for step-by-step instructions for each app.

---

## Quick Troubleshooting

| Problem | Solution |
|---|---|
| "No provider plugins found" | Run `openclaw onboard` to install a provider |
| Status shows **expired** | Re-run `openclaw models auth login` or `openclaw models auth setup-token` |
| Status shows **missing** | You haven't connected a provider yet — follow Step 2 |
| No response from the agent | Make sure the Gateway is running: `openclaw gateway --port 18789` |
| "models auth login requires an interactive TTY" | Run the command directly in a terminal window, not via a script |

**Run a full health check at any time:**
```
openclaw doctor
```

This surfaces any misconfigured settings and tells you exactly what needs attention.

---

## What's Next?

Now that you have a working AI conversation, explore what else OpenClaw can do:

- 💬 **Chat commands** — send `/status`, `/new`, `/think high`, or `/compact` directly in any conversation to control your assistant
- 🎤 **Voice mode** — on macOS and iOS, you can speak to your assistant hands-free
- 🔁 **Always-on assistant** — with the daemon installed, your assistant is available 24/7 across all your connected apps
- 📖 **Full documentation** — [docs.openclaw.ai](https://docs.openclaw.ai) covers every feature in depth