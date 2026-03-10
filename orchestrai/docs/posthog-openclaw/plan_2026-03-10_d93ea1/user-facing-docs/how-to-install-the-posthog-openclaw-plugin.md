# Installing the PostHog Plugin for OpenClaw

The `@posthog/openclaw` plugin adds PostHog analytics integration to your OpenClaw assistant. This guide walks you through installing it, verifying the installation, and removing it if needed.

---

## Before You Begin

Make sure you have:
- OpenClaw already installed and running (`npm install -g openclaw@latest`)
- Node.js version 22 or higher
- An active internet connection to reach the npm registry

---

## Step 1: Install the Plugin

Open your terminal and run the following command:

```bash
openclaw plugins install @posthog/openclaw
```

This command does the following automatically:
- Downloads the `@posthog/openclaw` package from the npm registry
- Adds it to your OpenClaw plugins list
- Makes it available to your assistant without requiring a manual restart

> **Tip:** You can run this command from any directory — it works globally on your system.

---

## Step 2: Verify the Plugin Is Listed

After installation, confirm the plugin was added successfully by opening your OpenClaw configuration file. This file is located at:

```
~/.openclaw/openclaw.json
```

Look for a `plugins` section that includes `@posthog/openclaw`, similar to this:

```json
{
  "plugins": [
    "@posthog/openclaw"
  ]
}
```

If you see `@posthog/openclaw` listed there, the installation was successful and the plugin is ready to be enabled.

You can also check your installed plugins directly from the terminal:

```bash
openclaw plugins list
```

The output should show `@posthog/openclaw` along with its installed version number.

---

## Step 3: Confirm the Installed Version

To make sure the version installed matches what's available on the npm registry, run:

```bash
openclaw plugins list
```

Then compare the version shown against the latest version on npm:

```bash
npm view @posthog/openclaw version
```

Both version numbers should match. If they differ, you may be running an older version — re-run the install command to update:

```bash
openclaw plugins install @posthog/openclaw
```

---

## Alternative: Manual Installation via Package Configuration

If the `openclaw plugins install` command is unavailable or you prefer to manage dependencies manually, you can add the plugin by editing your OpenClaw configuration file directly.

**Option A — Add to your openclaw.json:**

Open `~/.openclaw/openclaw.json` and add the plugin to the plugins list:

```json
{
  "plugins": [
    "@posthog/openclaw"
  ]
}
```

Save the file, then restart your OpenClaw gateway for the change to take effect:

```bash
openclaw gateway --restart
```

**Option B — Install via npm/pnpm directly:**

If you are running OpenClaw from source, you can add the package using your package manager:

```bash
npm install @posthog/openclaw
# or
pnpm add @posthog/openclaw
```

Then add `@posthog/openclaw` to the `plugins` array in your `openclaw.json` as shown above.

---

## Step 4: Enable the Plugin

Having the plugin installed makes it available, but you may still need to enable it in your configuration. In `~/.openclaw/openclaw.json`, ensure the plugin entry is present and that no `disabled` flag is set:

```json
{
  "plugins": [
    "@posthog/openclaw"
  ]
}
```

Restart the gateway if you made manual edits:

```bash
openclaw gateway --restart
```

Once enabled, the PostHog plugin will begin tracking assistant usage events according to your PostHog project settings.

---

## Uninstalling the Plugin

If you need to remove the PostHog plugin, run:

```bash
openclaw plugins uninstall @posthog/openclaw
```

This removes `@posthog/openclaw` from your plugins list in `openclaw.json` and stops the plugin from loading. You can verify it has been removed by checking the plugins list again:

```bash
openclaw plugins list
```

The plugin should no longer appear in the output.

---

## Troubleshooting

| Problem | What to Try |
|---|---|
| Plugin doesn't appear after install | Check `~/.openclaw/openclaw.json` — ensure the `plugins` array exists and contains `@posthog/openclaw` |
| Install command not found | Make sure OpenClaw is installed globally: `npm install -g openclaw@latest` |
| Version mismatch | Re-run `openclaw plugins install @posthog/openclaw` to update to the latest version |
| Plugin not loading | Restart the gateway: `openclaw gateway --restart` |
| Gateway errors after install | Run `openclaw doctor` to surface any configuration issues |

---

## What's Next

With `@posthog/openclaw` installed and listed in your configuration, the plugin is ready to be enabled and configured with your PostHog project credentials. Refer to the [PostHog plugin documentation](https://docs.openclaw.ai) for details on setting your API key and configuring which events are captured.