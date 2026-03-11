# Installing the PostHog OpenClaw Plugin

Get PostHog LLM Analytics up and running in your OpenClaw project in just a few minutes. Once installed, the plugin automatically captures LLM calls, tool executions, and conversation traces — sending them to your PostHog [LLM Analytics dashboard](https://posthog.com/docs/llm-analytics).

---

## Before You Begin

Make sure you have:

- An OpenClaw project (version 2026.2.0 or later)
- A PostHog account and your **Project API Key** (starts with `phc_`)
- Node.js 20 or later installed

---

## Step 1 — Install the Plugin

Open a terminal in your OpenClaw project directory and run:

```bash
openclaw plugins install @posthog/openclaw
```

This fetches the plugin from the npm registry and registers it with OpenClaw.

---

## Step 2 — Verify the Installation Succeeded

After the command finishes, confirm the plugin was installed by running OpenClaw with the `--list-plugins` flag (or check your plugins directory). You should see `PostHog LLM Analytics` listed as an available plugin.

If the install command completed without errors, the plugin is ready to be configured.

---

## Step 3 — Add the Plugin Configuration

Open your OpenClaw configuration file and add the PostHog plugin entry. Choose the format that matches your project:

### If you use `openclaw.json`

```jsonc
{
    "plugins": {
        "entries": {
            "posthog": {
                "enabled": true,
                "config": {
                    "apiKey": "phc_your_project_key",
                    "host": "https://us.i.posthog.com"
                }
            }
        }
    },
    "diagnostics": {
        "enabled": true
    }
}
```

### If you use `openclaw.yaml`

```yaml
plugins:
  entries:
    posthog:
      enabled: true
      config:
        apiKey: "phc_your_project_key"
        host: "https://us.i.posthog.com"

diagnostics:
  enabled: true
```

> **Important:** The configuration key must be exactly `"posthog"` — this matches the plugin's internal identifier and cannot be changed.

Replace `phc_your_project_key` with your actual PostHog Project API Key. You can find this in PostHog under **Project Settings → Project API Key**.

---

## Step 4 — Enable Diagnostics (Recommended)

Notice the `diagnostics: enabled: true` setting in the examples above. This is **strongly recommended** because it unlocks full trace-level analytics (`$ai_trace` events) in PostHog.

Without diagnostics enabled, you will still capture individual LLM generation events and tool call events — but you won't get the complete end-to-end trace that shows the full lifecycle of each user message.

Simply ensure your config includes:

```jsonc
"diagnostics": {
    "enabled": true
}
```

---

## Step 5 — Full Configuration (All Options)

For a complete setup with all available options, here is the full configuration skeleton:

```jsonc
{
    "plugins": {
        "entries": {
            "posthog": {
                "enabled": true,
                "config": {
                    "apiKey": "phc_your_project_key",
                    "host": "https://us.i.posthog.com",
                    "privacyMode": false,
                    "traceGrouping": "message",
                    "sessionWindowMinutes": 60
                }
            }
        }
    },
    "diagnostics": {
        "enabled": true
    }
}
```

| Setting | What it does | Default |
|---|---|---|
| **apiKey** | Your PostHog Project API Key — required | *(none)* |
| **host** | The URL of your PostHog instance | `https://us.i.posthog.com` |
| **privacyMode** | When turned on, message content and prompts are **not** sent to PostHog. Token counts, latency, and model info are always captured regardless. | `false` |
| **traceGrouping** | `"message"` creates one trace per conversation message. `"session"` groups an entire conversation into a single trace. | `"message"` |
| **sessionWindowMinutes** | How many minutes of inactivity before a new session is started | `60` |
| **enabled** | Quickly turn the plugin on or off without removing the configuration | `true` |

---

## Step 6 — Confirm the Plugin is Loaded

Start (or restart) your OpenClaw gateway:

```bash
openclaw gateway
```

Watch the startup output — you should see the PostHog plugin listed as loaded. Then trigger any LLM interaction through your OpenClaw project.

Within a few seconds, events will appear in your PostHog project. Navigate to **LLM Analytics → Traces** (at [us.posthog.com/llm-analytics/traces](https://us.posthog.com/llm-analytics/traces)) to see your first captured traces.

---

## What Happens Next

Once the plugin is active, PostHog automatically receives:

- **Every LLM call** — model used, token counts, cost, latency, and whether it succeeded
- **Every tool execution** — tool name, inputs, outputs, and duration
- **Every completed message cycle** — a full end-to-end trace (requires diagnostics enabled)

All of this appears in the PostHog LLM Analytics dashboard with no additional code changes required.

---

## Privacy Note

If your application handles sensitive user data, set `privacyMode: true` in your configuration. This ensures that the actual content of messages, prompts, and tool parameters is never sent to PostHog — only metadata like token counts, latency, model names, and error status.

---

## Troubleshooting

| Problem | Solution |
|---|---|
| Plugin not appearing after install | Restart your OpenClaw gateway after installation |
| No events in PostHog | Double-check your `apiKey` value and ensure it starts with `phc_` |
| Traces missing from LLM Analytics | Ensure `diagnostics.enabled` is set to `true` in your config |
| Configuration not picked up | Confirm the plugin entry key is exactly `"posthog"` (not the npm package name) |
| Connecting to a self-hosted PostHog | Set `host` to your own PostHog instance URL (e.g. `https://posthog.yourcompany.com`) |