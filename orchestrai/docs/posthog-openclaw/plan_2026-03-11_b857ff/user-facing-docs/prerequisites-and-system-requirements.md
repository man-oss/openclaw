# Prerequisites & System Requirements

Before installing OpenClaw, confirm that your environment meets all of the following requirements. Skipping this step is the most common cause of failed installations.

---

## ✅ Quick Checklist

| Requirement | Minimum Version | How to Check |
|---|---|---|
| Node.js | 22.12.0 or higher | `node --version` |
| OpenClaw | 2026.2.16 (latest) | `openclaw --version` |
| Package manager | npm, pnpm, or yarn | `npm --version` |
| AI model account | Anthropic or OpenAI | See below |

---

## 1. Node.js Version

**Required: Node.js 22.12.0 or higher**

OpenClaw requires a modern version of Node.js to run. Using an older version will prevent the application from starting.

**How to check your current version:**

```bash
node --version
```

If the output shows a version lower than `v22.12.0`, you need to upgrade before continuing.

**How to install or upgrade Node.js:**

- **Recommended:** Download the latest LTS release from [nodejs.org](https://nodejs.org)
- **Alternative:** Use a Node version manager like [nvm](https://github.com/nvm-sh/nvm) or [fnm](https://github.com/Schniz/fnm) to install and switch between versions easily

> **Tip:** The README and official docs consistently refer to this as "Node ≥22" — version 22.12.0 is the exact minimum enforced by OpenClaw.

---

## 2. A Supported Package Manager

OpenClaw works with the following package managers:

| Package Manager | Install Command |
|---|---|
| **npm** | Included with Node.js — no separate install needed |
| **pnpm** | `npm install -g pnpm` |
| **yarn** | `npm install -g yarn` |

Any of these will work for installing OpenClaw globally. **pnpm** is the recommended choice if you plan to build OpenClaw from source.

---

## 3. An AI Model Account

OpenClaw needs access to a large language model to power the assistant. You must have at least one of the following:

### Option A: Anthropic (Recommended)

Anthropic's Claude models are the recommended choice for OpenClaw, offering strong performance for long conversations.

1. Sign up or log in at [anthropic.com](https://www.anthropic.com/)
2. Subscribe to **Claude Pro** or **Claude Max** (the 100 or 200 plan)
3. After logging in, OpenClaw can connect using your subscription via OAuth — no manual API key copy-paste required in most setups

> **Recommendation:** Anthropic Pro/Max with the Opus model is strongly recommended for the best experience.

### Option B: OpenAI

1. Sign up or log in at [openai.com](https://openai.com/)
2. A **ChatGPT** subscription or API access is required
3. OpenClaw connects via OAuth or API key

> **Note:** While OpenClaw supports any compatible model, Anthropic is the preferred option for reliability and context handling.

---

## 4. A Supported Operating System

OpenClaw runs on:

| Platform | Support Level |
|---|---|
| **macOS** | Fully supported |
| **Linux** | Fully supported |
| **Windows** | Supported via **WSL2** (Windows Subsystem for Linux 2) — strongly recommended |

> **Windows users:** Native Windows is not supported. You must install and use [WSL2](https://docs.microsoft.com/en-us/windows/wsl/install) before proceeding.

---

## 5. Internet Access

OpenClaw connects to external AI services (Anthropic, OpenAI) and messaging platforms (WhatsApp, Telegram, Slack, Discord, etc.). A stable internet connection is required both during setup and while the assistant is running.

---

## Confirming Your Environment Is Ready

Run the following commands in your terminal to verify everything is in place before installing:

```bash
# Check Node.js version (must be v22.12.0 or higher)
node --version

# Check your package manager
npm --version
# or: pnpm --version
# or: yarn --version
```

Once all requirements are confirmed, you are ready to install OpenClaw. The recommended next step is to follow the [Getting Started guide](https://docs.openclaw.ai/start/getting-started), which walks you through installation and initial setup using the built-in setup wizard.