# Install and Configure posthog-openclaw in 5 Minutes

Get OpenClaw connected to PostHog so you can see your first AI analytics event in under 5 minutes. By the end of this guide, you will have the PostHog plugin running and real `$ai_*` events appearing in your PostHog LLM Analytics dashboard.

---

## Before You Begin

Make sure you have the following ready:

- **OpenClaw installed** — Node.js 22 or higher, with OpenClaw installed globally (`npm install -g openclaw@latest`)
- **A PostHog account** — Sign up free at [posthog.com](https://posthog.com) if you don't have one
- **Your PostHog API key** — Found in your PostHog project settings under **Project API Key**
- **Your PostHog host** — Usually `https://app.posthog.com` (or your self-hosted URL)

---

## Step 1 — Install the PostHog Plugin

Open your terminal and run:

```bash
openclaw plugins install @posthog/openclaw
```

OpenClaw will download and register the plugin. You will see a confirmation message once it finishes.

---

## Step 2 — Add the Plugin Configuration

Open your OpenClaw configuration file and add the PostHog plugin block. You can use either JSON or YAML format — pick whichever you prefer.

### Minimum Required Configuration

This is the smallest config that gets events flowing. You only need your API key and host.

**openclaw.json**
```json
{
  "agent": {
    "model": "anthropic/claude-opus-4-6"
  },
  "plugins": {
    "posthog": {
      "apiKey": "phc_YOUR_PROJECT_API_KEY",
      "host": "https://app.posthog.com"
    }
  }
}
```

**openclaw.yaml**
```yaml
agent:
  model: "anthropic/claude-opus-4-6"

plugins:
  posthog:
    apiKey: "phc_YOUR_PROJECT_API_KEY"
    host: "https://app.posthog.com"
```

Replace `phc_YOUR_PROJECT_API_KEY` with the actual key from your PostHog project settings.

### Full Configuration (All Options)

Use this expanded version to unlock all available tracking features:

**openclaw.json**
```json
{
  "agent": {
    "model": "anthropic/claude-opus-4-6"
  },
  "plugins": {
    "posthog": {
      "apiKey": "phc_YOUR_PROJECT_API_KEY",
      "host": "https://app.posthog.com",
      "enabled": true,
      "trackModelUsage": true,
      "trackLatency": true,
      "trackErrors": true
    }
  },
  "diagnostics": {
    "enabled": true
  }
}
```

**openclaw.yaml**
```yaml
agent:
  model: "anthropic/claude-opus-4-6"

plugins:
  posthog:
    apiKey: "phc_YOUR_PROJECT_API_KEY"
    host: "https://app.posthog.com"
    enabled: true
    trackModelUsage: true
    trackLatency: true
    trackErrors: true

diagnostics:
  enabled: true
```

---

## Step 3 — Enable Diagnostics

Diagnostics lets OpenClaw surface plugin health and event delivery status. Add the `diagnostics` block to your config as shown in the full example above:

**In openclaw.json:**
```json
{
  "diagnostics": {
    "enabled": true
  }
}
```

**In openclaw.yaml:**
```yaml
diagnostics:
  enabled: true
```

This ensures you can quickly spot any connection issues between OpenClaw and PostHog.

---

## Step 4 — Start OpenClaw and Verify the Plugin is Active

Start the OpenClaw gateway:

```bash
openclaw gateway --verbose
```

The `--verbose` flag prints detailed startup output. Look for a line confirming the PostHog plugin has loaded, similar to:

```
[plugins] @posthog/openclaw — loaded ✓
```

To do a quick health check at any time, run:

```bash
openclaw doctor
```

This scans your configuration and active plugins, and will flag any issues with the PostHog connection.

---

## Step 5 — Trigger Your First Event

Send a message through OpenClaw to generate AI activity:

```bash
openclaw agent --message "Hello, world!"
```

This causes OpenClaw to call your configured AI model, which triggers the plugin to send `$ai_*` events to PostHog.

---

## Step 6 — Confirm Events Are Arriving in PostHog

1. Log in to [app.posthog.com](https://app.posthog.com) (or your self-hosted instance)
2. Navigate to the **LLM Analytics** dashboard from the left-hand sidebar
3. Look for incoming events prefixed with `$ai_` — for example, `$ai_generation` or `$ai_span`
4. You should see your first event within a few seconds of sending the message in Step 5

If you don't see events after 30 seconds, check:
- Your `apiKey` is correct and copied in full from PostHog project settings
- Your `host` URL matches exactly (no trailing slash)
- Run `openclaw doctor` to check for any reported plugin errors

---

## Quick Reference

| Configuration field | Required | Description |
|---|---|---|
| `plugins.posthog.apiKey` | ✅ Yes | Your PostHog project API key (`phc_...`) |
| `plugins.posthog.host` | ✅ Yes | PostHog instance URL |
| `plugins.posthog.enabled` | Optional | Set to `false` to pause tracking without removing config |
| `plugins.posthog.trackModelUsage` | Optional | Tracks which models are used and token counts |
| `plugins.posthog.trackLatency` | Optional | Tracks response time per request |
| `plugins.posthog.trackErrors` | Optional | Sends error events when model calls fail |
| `diagnostics.enabled` | Optional | Enables plugin health reporting in logs |

---

## What Happens Next

Once events are flowing, the PostHog LLM Analytics dashboard lets you:

- **Monitor model usage** — see which AI models are used most often
- **Track costs** — understand token consumption over time
- **Measure latency** — spot slow responses and performance regressions
- **Debug errors** — receive alerts when AI calls fail

For more on OpenClaw configuration, visit [docs.openclaw.ai/gateway/configuration](https://docs.openclaw.ai/gateway/configuration).