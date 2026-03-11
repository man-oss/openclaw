# Prerequisites & System Requirements

Before installing the PostHog OpenClaw plugin, make sure you have everything listed below in place. Skipping any of these steps is the most common reason installations fail.

---

## 1. Node.js Version 20 or Higher

Your computer (or server) must be running **Node.js version 20.0.0 or newer**.

- To check your current version, open a terminal and run: `node --version`
- If the number shown is lower than `20.0.0`, visit [nodejs.org](https://nodejs.org) to download and install a current release.

---

## 2. OpenClaw Version 2026.2.0 or Higher

This plugin is designed to work with **OpenClaw version 2026.2.0 or later**.

- To check your OpenClaw version, run: `openclaw --version`
- If you need to upgrade, follow the update instructions from the [OpenClaw project](https://github.com/openclaw/openclaw).

---

## 3. A PostHog Account and Project API Key

You need an active **PostHog account** with a project set up. During configuration, you will be asked for your **Project API Key**.

- If you don't have an account yet, sign up for free at [posthog.com](https://posthog.com).
- Once logged in, find your API key in your project settings — it starts with `phc_`.
- Keep this key handy before you begin installation.

---

## 4. Your PostHog Host URL

You also need to know the **URL of your PostHog instance**. This depends on how PostHog is set up:

| Setup Type | Host URL to Use |
|---|---|
| PostHog Cloud (US region) | `https://us.i.posthog.com` |
| PostHog Cloud (EU region) | `https://eu.i.posthog.com` |
| Self-hosted PostHog | Your own domain, e.g. `https://posthog.yourcompany.com` |

If you're unsure which applies to you, check the address bar when logged into PostHog — it will indicate whether you're on the US cloud, EU cloud, or a self-hosted instance.

---

## 5. A Package Manager

You need one of the following package managers installed to add the plugin to your project:

| Package Manager | Minimum Version | Notes |
|---|---|---|
| **pnpm** | Any current version | Recommended (the plugin itself uses pnpm `10.29.3`) |
| **npm** | Any current version | Fully compatible |
| **yarn** | Any current version | Fully compatible |

Most Node.js installations come with **npm** pre-installed. To check: run `npm --version`, `pnpm --version`, or `yarn --version` in your terminal.

---

## Quick Checklist

Before moving on to installation, confirm all of the following:

- [ ] Node.js `>=20.0.0` is installed
- [ ] OpenClaw `>=2026.2.0` is installed
- [ ] You have a PostHog account with a project created
- [ ] You have your PostHog Project API key (`phc_...`)
- [ ] You know your PostHog host URL
- [ ] You have pnpm, npm, or yarn available

Once every item is checked, you're ready to install the plugin.