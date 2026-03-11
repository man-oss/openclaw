# Configuring the PostHog Plugin for Your Environment

This guide walks you through setting up the PostHog analytics plugin in OpenClaw. By the end, you'll have a working configuration file that is safe to check into version control.

---

## What You Need Before You Start

- A PostHog account (either [PostHog Cloud](https://posthog.com) or a self-hosted instance)
- Your PostHog **Project API Key** (found in your PostHog project settings under **Project → API Keys**)
- An existing OpenClaw installation with the `~/.openclaw/` directory created

---

## Step 1: Find or Create Your Configuration File

OpenClaw stores all settings in a single configuration file located at:

```
~/.openclaw/openclaw.json
```

If this file doesn't exist yet, create it. You can also use `openclaw.yaml` instead — both formats are fully supported and work identically. Choose whichever feels more comfortable.

---

## Step 2: Add the PostHog Plugin Configuration Block

Open your configuration file and add a `plugins` section. Inside it, add an `entries` block with a `posthog` key.

### JSON format (`openclaw.json`)

```json
{
  "plugins": {
    "entries": {
      "posthog": {
        "apiKey": "phc_YourProjectApiKeyHere",
        "host": "https://app.posthog.com"
      }
    }
  }
}
```

### YAML format (`openclaw.yaml`)

```yaml
plugins:
  entries:
    posthog:
      apiKey: "phc_YourProjectApiKeyHere"
      host: "https://app.posthog.com"
```

Both examples above are complete and valid starting points. Paste the one matching your chosen format, then fill in your own values.

---

## Step 3: Set Your API Key

The `apiKey` field is **required**. This is your PostHog Project API Key — it starts with `phc_` and is unique to your project.

**Where to find it:**
1. Log in to your PostHog account
2. Go to **Project Settings**
3. Look for the **Project API Key** section
4. Copy the key (it starts with `phc_`)

Paste it as the value for `apiKey` in your configuration file.

> ⚠️ **Important:** Do not commit your raw API key to a public repository. See [Step 5](#step-5-keep-your-api-key-safe-with-environment-variables) below for the safe approach.

---

## Step 4: Set the Host for Your PostHog Instance

The `host` field tells OpenClaw where your PostHog instance lives. Use the value that matches your setup:

| Setup | Value to use |
|---|---|
| **PostHog Cloud (US)** — default | `https://app.posthog.com` |
| **PostHog Cloud (EU)** | `https://eu.posthog.com` |
| **Self-hosted PostHog** | Your own URL, e.g. `https://posthog.yourcompany.com` |

If you are on PostHog Cloud US and using the default, you can omit the `host` field entirely — it defaults to `https://app.posthog.com`.

### Example: EU Cloud

**JSON:**
```json
{
  "plugins": {
    "entries": {
      "posthog": {
        "apiKey": "phc_YourProjectApiKeyHere",
        "host": "https://eu.posthog.com"
      }
    }
  }
}
```

**YAML:**
```yaml
plugins:
  entries:
    posthog:
      apiKey: "phc_YourProjectApiKeyHere"
      host: "https://eu.posthog.com"
```

### Example: Self-Hosted

**JSON:**
```json
{
  "plugins": {
    "entries": {
      "posthog": {
        "apiKey": "phc_YourProjectApiKeyHere",
        "host": "https://posthog.yourcompany.com"
      }
    }
  }
}
```

**YAML:**
```yaml
plugins:
  entries:
    posthog:
      apiKey: "phc_YourProjectApiKeyHere"
      host: "https://posthog.yourcompany.com"
```

---

## Step 5: Keep Your API Key Safe with Environment Variables

Rather than writing your API key directly into the configuration file, you can reference an environment variable. This means you can safely check in your configuration file without exposing your credentials.

**How it works:** Set an environment variable on your machine (or server), then reference it in your config using the `$VARIABLE_NAME` syntax.

### Setting the environment variable

In your terminal (or your server's environment settings):

```bash
export POSTHOG_API_KEY="phc_YourProjectApiKeyHere"
```

To make this permanent, add the line above to your shell profile file (such as `~/.zshrc`, `~/.bashrc`, or `~/.profile`), then restart your terminal.

### Referencing it in JSON

```json
{
  "plugins": {
    "entries": {
      "posthog": {
        "apiKey": "$POSTHOG_API_KEY",
        "host": "https://app.posthog.com"
      }
    }
  }
}
```

### Referencing it in YAML

```yaml
plugins:
  entries:
    posthog:
      apiKey: "$POSTHOG_API_KEY"
      host: "https://app.posthog.com"
```

With this approach, your configuration file contains no real secrets and is safe to add to version control.

---

## Complete Working Examples

### Minimal configuration (PostHog Cloud US, using environment variable)

**JSON (`~/.openclaw/openclaw.json`):**
```json
{
  "agent": {
    "model": "anthropic/claude-opus-4-6"
  },
  "plugins": {
    "entries": {
      "posthog": {
        "apiKey": "$POSTHOG_API_KEY"
      }
    }
  }
}
```

**YAML (`~/.openclaw/openclaw.yaml`):**
```yaml
agent:
  model: "anthropic/claude-opus-4-6"

plugins:
  entries:
    posthog:
      apiKey: "$POSTHOG_API_KEY"
```

### Full configuration (self-hosted, all fields explicit)

**JSON:**
```json
{
  "agent": {
    "model": "anthropic/claude-opus-4-6"
  },
  "plugins": {
    "entries": {
      "posthog": {
        "apiKey": "$POSTHOG_API_KEY",
        "host": "https://posthog.yourcompany.com"
      }
    }
  }
}
```

**YAML:**
```yaml
agent:
  model: "anthropic/claude-opus-4-6"

plugins:
  entries:
    posthog:
      apiKey: "$POSTHOG_API_KEY"
      host: "https://posthog.yourcompany.com"
```

---

## Verifying Your Configuration

After saving your configuration file, restart the OpenClaw Gateway so it picks up the new settings. You can check for any issues by running:

```
openclaw doctor
```

This command inspects your full setup and will flag anything that looks misconfigured. If PostHog is connecting successfully, events from your OpenClaw sessions will begin appearing in your PostHog project dashboard shortly after startup.

---

## Quick Reference

| Field | Required | Description |
|---|---|---|
| `plugins.entries.posthog.apiKey` | ✅ Yes | Your PostHog Project API Key (starts with `phc_`) |
| `plugins.entries.posthog.host` | ❌ No | PostHog instance URL. Defaults to `https://app.posthog.com` |

**Safe to commit?** Yes — as long as you use an environment variable for `apiKey` instead of the raw key value.