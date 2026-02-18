# What is OpenClaw?

OpenClaw is a personal AI assistant that runs entirely on your own devices — your computer, phone, or home server — giving you a fast, private, and always-available AI helper that works through the messaging apps you already use every day.

## The Big Idea

Most AI assistants live in the cloud, meaning your conversations pass through someone else's servers. OpenClaw is different: you run it yourself, on hardware you control, and it connects to your existing messaging apps so you can talk to it wherever you already spend your time.

Whether you're sending a WhatsApp message, a Discord DM, or a Slack reply, OpenClaw is listening and responding as your own personal assistant — without your data leaving your hands.

## What Can OpenClaw Do?

Once set up, OpenClaw acts as an intelligent assistant you can reach through any of your connected messaging channels. You can ask it questions, have it help you write, plan, research, and more — all from the apps you already have open.

**Talk to it where you already are.** OpenClaw connects to:

- **WhatsApp**
- **Telegram**
- **Slack**
- **Discord**
- **Google Chat**
- **Signal**
- **iMessage** (via BlueBubbles, recommended, or the legacy macOS integration)
- **Microsoft Teams**
- **Matrix**
- **Zalo and Zalo Personal**
- **WebChat** (a built-in browser-based chat)

**Use it with your voice.** On Mac, iPhone, and Android, OpenClaw supports always-on voice wake and a Talk Mode so you can speak to your assistant hands-free.

**See it think visually.** OpenClaw can display a live Canvas — a visual workspace your assistant can write to and update in real time, controlled from your Mac, iPhone, or Android device.

**Keep it running in the background.** OpenClaw runs as a background service on your machine, so it's always ready — even when you're not actively using it.

## Who Is OpenClaw For?

OpenClaw is built for **individuals who want a powerful, privacy-focused AI assistant** that feels personal and immediate. It's ideal if you:

- Want an AI assistant but don't want your conversations stored on someone else's servers
- Already live in messaging apps like WhatsApp, Telegram, Slack, or Discord and want your AI right there alongside your other chats
- Want something that feels fast and local, not slow because it's routing through a distant service
- Want full control over which AI model powers your assistant (Claude, ChatGPT, and others are supported)

It is a **single-user, personal assistant** — not a team product or a chatbot platform. Think of it as your own private AI, running on your own hardware, speaking your language through your own apps.

## How It Works (Without the Technical Details)

Here's the simple picture: OpenClaw runs a central "hub" on your device or server. All your messaging channels — WhatsApp, Telegram, Discord, and the rest — connect to that hub. When you send a message on any of those platforms, it flows through your hub, gets answered by your chosen AI model, and the reply comes back to you in the same app.

```
Your WhatsApp / Telegram / Slack / Discord / Signal / iMessage / ...
               │
               ▼
     ┌─────────────────┐
     │  Your OpenClaw  │  ← runs on your machine
     │      Hub        │
     └────────┬────────┘
              │
       Your AI assistant
     (Claude, ChatGPT, etc.)
```

Everything stays in your control. Your messages, your model, your hardware.

## What Makes OpenClaw Different from Cloud AI Services?

| Feature | OpenClaw | Typical Cloud AI |
|---|---|---|
| Runs on your devices | ✅ Yes | ❌ No — runs on their servers |
| Your data stays private | ✅ Yes | ⚠️ Depends on their policy |
| Works inside your messaging apps | ✅ Yes | ❌ Usually requires their app/website |
| Always on, even offline | ✅ Yes (on local network) | ❌ Requires internet connection to their service |
| You choose the AI model | ✅ Yes | ⚠️ Limited to what they offer |
| Voice support on mobile | ✅ Yes (Mac, iPhone, Android) | ⚠️ Varies |

## Choosing Your AI Model

OpenClaw works with leading AI providers. You connect your own subscription account:

- **Anthropic** — Claude Pro or Max (Claude Opus is the recommended model for its strong reasoning and long conversation abilities)
- **OpenAI** — ChatGPT or Codex models

You bring your own subscription. OpenClaw is the bridge that connects your AI subscription to your messaging life — it is not itself an AI model.

## Companion Apps

While OpenClaw's core works on its own, optional companion apps enhance the experience:

- **macOS app** — A menu bar icon gives you quick control, voice push-to-talk, and a built-in WebChat window
- **iPhone app** — Pairs with your hub for voice wake, Canvas viewing, camera, and screen sharing
- **Android app** — Same capabilities as iPhone, plus optional SMS support

All apps are optional. The assistant works great through your messaging channels alone.

## Open Source and Community-Driven

OpenClaw is free and open source, released under the MIT License. It was originally built for **Molty**, a personal AI assistant, by Peter Steinberger and a growing community of contributors. You can find the project, report issues, and join the community on GitHub and Discord.

- **Website:** [openclaw.ai](https://openclaw.ai)
- **Documentation:** [docs.openclaw.ai](https://docs.openclaw.ai)
- **Community Discord:** [discord.gg/clawd](https://discord.gg/clawd)

---

*Ready to get started? Head to the [Getting Started guide](https://docs.openclaw.ai/start/getting-started) to set up your personal OpenClaw assistant in minutes.*