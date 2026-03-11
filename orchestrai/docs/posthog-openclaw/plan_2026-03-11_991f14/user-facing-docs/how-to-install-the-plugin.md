# How to Install the PostHog OpenClaw Plugin

This guide walks you through everything you need to install, verify, update, and remove the PostHog LLM Analytics plugin for OpenClaw — no technical background required.

---

## Before You Begin

Make sure your computer meets the following requirement:

- **Node.js version 20 or higher** must be installed. If you're unsure which version you have, open a terminal and type `node --version`. If the number shown is below 20, update Node.js before continuing.
- **OpenClaw version 2026.2.0 or higher** must already be set up on your system. The PostHog plugin requires this minimum version of OpenClaw to work correctly.

---

## Step 1: Install the Plugin

Open a terminal and run the following command:

```bash
openclaw plugins install @posthog/openclaw
```

That's it! OpenClaw will download and install the PostHog LLM Analytics plugin automatically.

---

## Step 2: Verify the Installation

After installing, confirm the plugin was set up correctly by checking which version is now installed:

```bash
openclaw plugins list
```

Look for `@posthog/openclaw` in the output. The current release is **version 0.2.0**. If you see it listed, the installation was successful.

---

## Step 3: Update the Plugin

To update the plugin to the latest available version, run:

```bash
openclaw plugins update @posthog/openclaw
```

After updating, run `openclaw plugins list` again to confirm the new version is shown.

---

## Step 4: Uninstall the Plugin

If you no longer need the plugin, you can remove it with:

```bash
openclaw plugins uninstall @posthog/openclaw
```

This cleanly removes the plugin from your OpenClaw setup.

---

## Troubleshooting Common Issues

### ❌ "Peer dependency conflict" error

This error means the version of OpenClaw you have installed is too old. The PostHog plugin requires **OpenClaw version 2026.2.0 or newer**.

**Fix:** Update OpenClaw to the latest version, then try installing the plugin again.

---

### ❌ "Unsupported Node.js version" or similar Node error

The plugin requires **Node.js 20 or higher**. If you see errors related to Node, your current version is likely too old.

**Fix:**
1. Visit [nodejs.org](https://nodejs.org) and download the latest LTS version (20 or above).
2. Install it, then re-run the plugin install command.

---

### ❌ Plugin installs but nothing works

If the plugin appears installed but doesn't seem to do anything, check the following:

- Make sure you've added the plugin configuration to your `openclaw.json` or `openclaw.yaml` file with `"enabled": true`.
- Make sure `"diagnostics": { "enabled": true }` is also present in your config — this is required for full trace capture to work.
- Confirm that the config entry key is exactly `"posthog"` (not the package name).

See the [Configuration Guide](#) for full setup instructions.

---

## Summary

| Task | Command |
|---|---|
| Install the plugin | `openclaw plugins install @posthog/openclaw` |
| Check installed version | `openclaw plugins list` |
| Update to latest version | `openclaw plugins update @posthog/openclaw` |
| Remove the plugin | `openclaw plugins uninstall @posthog/openclaw` |

---

**Need help?** Report issues at the [PostHog OpenClaw GitHub Issues page](https://github.com/PostHog/posthog-openclaw/issues).