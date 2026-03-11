# Configuring the PostHog LLM Analytics Plugin

This guide walks you through every setting available for the PostHog plugin in OpenClaw, so you can connect it to your PostHog account and tailor its behavior to your needs.

---

## Step 1: Find Your Configuration File

OpenClaw stores its settings in one of two files, located in your OpenClaw configuration folder (typically `~/.openclaw/`):

- `openclaw.json` — JSON format
- `openclaw.yaml` — YAML format

Open whichever file your setup uses. If neither exists yet, create `openclaw.json` in that folder.

---

## Step 2: Add the Plugin Entry

Paste the following block into your configuration file, then fill in your own values:

**openclaw.json**
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

> **Important:** The section name must be exactly `"posthog"` — this is the identifier the plugin looks for. Do not rename it to the package name or anything else.

---

## Step 3: Configure Each Option

### `apiKey` *(required)*

Your PostHog project API key. This is the only required setting — the plugin will not start without it.

- **Type:** Text string
- **Default:** None — you must provide this
- **Where to find it:** In PostHog, go to **Project Settings → Project API Key**. It starts with `phc_`.

```jsonc
"apiKey": "phc_abc123yourkeyhere"
```

> **Tip:** To avoid storing your key directly in the file, see [Using Environment Variables](#using-environment-variables-for-your-api-key) below.

---

### `host`

The web address of the PostHog instance you want to send data to.

- **Type:** Text (a URL)
- **Default:** `https://us.i.posthog.com`

| Deployment | Value to use |
|---|---|
| PostHog Cloud — US region | `https://us.i.posthog.com` |
| PostHog Cloud — EU region | `https://eu.i.posthog.com` |
| Self-hosted PostHog | Your own instance URL, e.g. `https://posthog.yourcompany.com` |

**Example — EU Cloud:**
```jsonc
"host": "https://eu.i.posthog.com"
```

**Example — Self-hosted:**
```jsonc
"host": "https://posthog.yourcompany.com"
```

---

### `privacyMode`

Controls whether the actual content of messages and tool calls is sent to PostHog.

- **Type:** `true` or `false`
- **Default:** `false` (content is sent)

| Setting | What happens |
|---|---|
| `false` | Full message content, prompts, and tool parameters are captured |
| `true` | Content is redacted — only token counts, timing, model names, and error status are sent |

Use `true` if you handle sensitive data (personal information, confidential prompts, etc.) and do not want that content leaving your environment.

```jsonc
"privacyMode": true
```

---

### `traceGrouping`

Determines how individual LLM calls are grouped together into traces in your PostHog dashboard.

- **Type:** One of two text values: `"message"` or `"session"`
- **Default:** `"message"`

| Value | Behavior |
|---|---|
| `"message"` | Each message exchange is its own trace. Best for seeing per-request detail. |
| `"session"` | All exchanges in a conversation are grouped into a single trace. Best for seeing the full arc of a conversation. |

```jsonc
"traceGrouping": "session"
```

---

### `sessionWindowMinutes`

How many minutes of inactivity must pass before a new session is started. Applies regardless of which `traceGrouping` mode you choose.

- **Type:** Number
- **Default:** `60`

For example, if a user stops chatting for longer than this number of minutes and then sends another message, it will be treated as a new session.

```jsonc
"sessionWindowMinutes": 30
```

---

### `enabled`

Turns the entire plugin on or off without removing your configuration.

- **Type:** `true` or `false`
- **Default:** `true`

Set this to `false` to temporarily stop sending data to PostHog while keeping all your other settings in place.

```jsonc
"enabled": false
```

---

## Deployment-Specific Examples

### PostHog Cloud — US Region (Default)

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
    "diagnostics": { "enabled": true }
}
```

### PostHog Cloud — EU Region

```jsonc
{
    "plugins": {
        "entries": {
            "posthog": {
                "enabled": true,
                "config": {
                    "apiKey": "phc_your_project_key",
                    "host": "https://eu.i.posthog.com"
                }
            }
        }
    },
    "diagnostics": { "enabled": true }
}
```

### Self-Hosted PostHog

```jsonc
{
    "plugins": {
        "entries": {
            "posthog": {
                "enabled": true,
                "config": {
                    "apiKey": "phc_your_project_key",
                    "host": "https://posthog.yourcompany.com"
                }
            }
        }
    },
    "diagnostics": { "enabled": true }
}
```

---

## Enabling Full Trace Capture

To capture complete conversation trace events (the `$ai_trace` event type, which summarizes an entire message cycle), you must also enable diagnostics at the top level of your config:

```jsonc
"diagnostics": {
    "enabled": true
}
```

Without this, individual generation and tool call events will still be captured, but the summarized trace-level events will not appear in PostHog.

---

## Using Environment Variables for Your API Key

Storing your API key directly in a config file can be a security risk, especially if the file is shared or version-controlled. OpenClaw supports environment variable substitution so you can keep your key out of the file.

Set the environment variable before starting OpenClaw:

```bash
export POSTHOG_API_KEY="phc_your_project_key"
```

Then reference it in your config:

```jsonc
"apiKey": "${POSTHOG_API_KEY}"
```

This way, the key lives in your environment and is never written to disk in plain text.

---

## Quick Reference: All Options

| Option | Required | Default | What it controls |
|---|---|---|---|
| `apiKey` | ✅ Yes | — | Your PostHog project API key |
| `host` | No | `https://us.i.posthog.com` | Which PostHog instance receives your data |
| `privacyMode` | No | `false` | Whether message content is sent or redacted |
| `traceGrouping` | No | `"message"` | How LLM calls are grouped into traces |
| `sessionWindowMinutes` | No | `60` | Inactivity timeout before a new session starts |
| `enabled` | No | `true` | Master on/off switch for the plugin |

---

## Common Mistakes to Avoid

- **Wrong entry name:** The config block must be named `"posthog"`, not `"@posthog/openclaw"` or any other variation.
- **Missing `apiKey`:** This is the only required field. Omitting it will prevent the plugin from starting.
- **No `diagnostics` block:** Forgetting `"diagnostics": { "enabled": true }` means conversation-level trace summaries will not be captured in PostHog.
- **Wrong host for EU:** If your PostHog account is on the EU Cloud and you leave `host` at the default, your data will be sent to the wrong region. Explicitly set `"host": "https://eu.i.posthog.com"`.
- **Self-hosted URL with trailing slash:** Make sure your self-hosted URL does not have a trailing slash (e.g., use `https://posthog.yourcompany.com`, not `https://posthog.yourcompany.com/`).