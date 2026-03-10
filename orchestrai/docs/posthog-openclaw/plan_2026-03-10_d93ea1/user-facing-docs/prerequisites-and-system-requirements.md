# Prerequisites & System Requirements

Before you can install and use OpenClaw, you'll need a few things in place. This page walks you through everything you need to gather — accounts, credentials, and software versions — so you're fully prepared before moving to installation.

---

## ✅ Quick Checklist

- [ ] Node.js version 22.12.0 or newer installed
- [ ] A package manager: npm, pnpm, or bun
- [ ] An AI model subscription (Anthropic or OpenAI)
- [ ] A supported operating system: macOS, Linux, or Windows via WSL2

---

## 1. Node.js Version 22.12.0 or Newer

OpenClaw requires **Node.js version 22.12.0 or higher** to run. This is a hard requirement — older versions of Node.js will not work.

Node.js is the engine that powers OpenClaw behind the scenes. Version 22+ provides the modern features and performance that OpenClaw depends on for running its gateway, handling multiple messaging channels simultaneously, and processing AI responses reliably.

### How to check your current version

Open your terminal and run:

```
node --version
```

You'll see something like `v22.12.0` or higher. If you see a lower number (for example, `v18.x` or `v20.x`), you'll need to upgrade before continuing.

### How to install or upgrade Node.js

The easiest way is to use the official installer at **[nodejs.org](https://nodejs.org)**. Download the "LTS" (Long-Term Support) version, which will be 22 or higher.

Alternatively, if you manage multiple Node.js versions, tools like **nvm** (Node Version Manager) or **fnm** make switching easy:

```bash
# Using nvm
nvm install 22
nvm use 22
```

---

## 2. A Package Manager

OpenClaw works with any of these three package managers. You only need one:

| Package Manager | How to install |
|---|---|
| **npm** | Comes bundled with Node.js — no extra setup needed |
| **pnpm** | Run `npm install -g pnpm` after installing Node.js |
| **bun** | Download from [bun.sh](https://bun.sh) |

> **Recommendation:** All three work, but **pnpm** is what the OpenClaw team uses internally and is recommended if you plan to build from source.

---

## 3. An AI Model Subscription

OpenClaw is a personal AI assistant, so it needs to connect to an AI model to power its responses. You'll need an active subscription with at least one of the following:

### Option A: Anthropic (Recommended)

- **Website:** [anthropic.com](https://www.anthropic.com/)
- **Required plan:** Claude Pro or Claude Max (100 or 200)
- **Recommended model:** Claude Opus 4.6

Anthropic is the recommended choice because Claude models handle long conversations especially well and have strong resistance to prompt-injection attacks — important when the assistant is receiving messages from various channels.

### Option B: OpenAI

- **Website:** [openai.com](https://openai.com/)
- **Required plan:** ChatGPT Plus or a paid API plan

Both providers support OAuth-based login through the OpenClaw onboarding wizard, so you won't need to manually copy API keys for the AI model itself.

---

## 4. Supported Operating Systems

OpenClaw runs on:

| Platform | Support Level |
|---|---|
| **macOS** | Fully supported, including optional companion app |
| **Linux** | Fully supported |
| **Windows** | Supported via **WSL2** (strongly recommended) |

> **Windows users:** Native Windows is not supported. You must use Windows Subsystem for Linux 2 (WSL2). See Microsoft's guide to [installing WSL](https://learn.microsoft.com/en-us/windows/wsl/install) if you haven't set it up yet.

---

## 5. Optional: PostHog Analytics Account

> **Note:** PostHog integration is optional and is only relevant if you plan to add usage analytics to your OpenClaw setup. Most users can skip this section entirely.

If you're using the `@posthog/openclaw` analytics integration, you'll additionally need:

### A PostHog Account

Sign up for a free account at **[posthog.com](https://posthog.com)**. PostHog offers a generous free tier that covers most personal and small-team usage.

### Your PostHog Project API Key

Once logged in to PostHog:

1. Navigate to your **Project Settings** (click your project name in the top navigation, then select **Settings**)
2. Look for the **Project API Key** section
3. Your key will be displayed in the format: `phc_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx`

> **What it looks like:** Every PostHog project API key starts with `phc_` followed by a long string of letters and numbers. Copy this key — you'll paste it into your OpenClaw configuration.

Keep this key private. It identifies your PostHog project and allows data to be sent to your analytics dashboard.

### Your PostHog Host URL

The host URL tells OpenClaw which PostHog server to send data to. Choose the one that matches where your PostHog account is hosted:

| Hosting Type | URL to use |
|---|---|
| **PostHog US Cloud** (default) | `https://us.i.posthog.com` |
| **PostHog EU Cloud** | `https://eu.i.posthog.com` |
| **Self-hosted PostHog** | Your own server URL, e.g. `https://posthog.yourdomain.com` |

> **How to check:** When you log in to PostHog, look at the URL in your browser's address bar. If it shows `us.posthog.com`, use the US host. If it shows `eu.posthog.com`, use the EU host. If you installed PostHog yourself on your own server, use that server's URL.

**Why this matters:** Using the wrong host URL means your analytics data won't reach your PostHog account — it will simply fail silently. EU-hosted accounts must use the EU URL to comply with data residency requirements.

---

## What's Next?

Once you have everything above in place, you're ready to install OpenClaw. Head to the [Getting Started guide](https://docs.openclaw.ai/start/getting-started) or run the interactive setup wizard:

```bash
npm install -g openclaw@latest
openclaw onboard --install-daemon
```

The wizard will guide you through connecting your AI model subscription, setting up channels, and configuring the gateway — all step by step.