# How to Install the PostHog OpenClaw Plugin

This guide walks you through every step of adding the PostHog plugin to your OpenClaw setup — from the first install to upgrading and removing it later.

---

## Before You Begin

Make sure you have OpenClaw installed and running. You'll need:

- **OpenClaw** already set up on your machine (Node 22 or newer)
- Access to your terminal (macOS, Linux, or Windows via WSL2)
- An active internet connection

If you haven't installed OpenClaw yet, start with the [Getting Started guide](https://docs.openclaw.ai/start/getting-started).

---

## Method 1: Install Using the OpenClaw CLI (Recommended)

The fastest and easiest way to add the PostHog plugin is with a single command in your terminal.

**Open your terminal and run:**

```bash
openclaw plugins install @posthog/openclaw
```

That's it. OpenClaw will download the plugin, register it automatically, and make it available immediately. No manual configuration needed.

---

## Method 2: Manual Installation

If you prefer to manage plugins yourself — or if you're working in an environment without internet access during setup — you can install the plugin manually.

### Step 1 — Add the Plugin Package

Install the PostHog plugin package using your preferred package manager:

```bash
# Using npm
npm install @posthog/openclaw

# Using pnpm
pnpm add @posthog/openclaw
```

### Step 2 — Register the Plugin in Your Settings

Open your OpenClaw settings file (located at `~/.openclaw/openclaw.json`) and add the plugin to the plugins list:

```json5
{
  plugins: [
    "@posthog/openclaw"
  ]
}
```

If you already have other settings in the file, add the `plugins` section alongside them. Save the file when done.

### Step 3 — Restart OpenClaw

For the plugin to load, restart your OpenClaw gateway:

```bash
openclaw gateway --port 18789
```

Or, if you're running it as a background service, restart the daemon:

```bash
openclaw restart
```

---

## Verifying the Installation

After installing, confirm the plugin is active by checking your plugin registry:

```bash
openclaw plugins list
```

You should see `@posthog/openclaw` in the output, along with its version number and status. If it appears as **active**, the installation was successful.

You can also run the built-in health check to surface any configuration issues:

```bash
openclaw doctor
```

The doctor command will flag any problems with your plugin setup and suggest fixes.

---

## Upgrading the Plugin

To update the PostHog plugin to the latest version, run:

```bash
openclaw plugins install @posthog/openclaw
```

This command installs the newest available version, replacing the old one. You can also update all your plugins at once by upgrading OpenClaw itself:

```bash
npm install -g openclaw@latest
# or
pnpm add -g openclaw@latest
```

After upgrading, restart your gateway to apply the changes. See the [Updating guide](https://docs.openclaw.ai/install/updating) for more details.

---

## Uninstalling the Plugin

To cleanly remove the PostHog plugin:

```bash
openclaw plugins uninstall @posthog/openclaw
```

This removes the plugin from your registry. If you installed manually, you can also remove the package:

```bash
# Using npm
npm uninstall @posthog/openclaw

# Using pnpm
pnpm remove @posthog/openclaw
```

Then remove the `@posthog/openclaw` entry from the `plugins` list in your `~/.openclaw/openclaw.json` file and restart OpenClaw.

---

## Troubleshooting

| Problem | What to Try |
|---|---|
| Plugin doesn't appear after install | Run `openclaw doctor` to check for errors |
| Command not found | Make sure OpenClaw is installed globally (`npm install -g openclaw@latest`) |
| Plugin shows as inactive | Restart the gateway and run `openclaw plugins list` again |
| Install fails with a network error | Check your internet connection, then retry the install command |

For more help, visit the [Troubleshooting guide](https://docs.openclaw.ai/channels/troubleshooting) or join the [OpenClaw Discord community](https://discord.gg/clawd).