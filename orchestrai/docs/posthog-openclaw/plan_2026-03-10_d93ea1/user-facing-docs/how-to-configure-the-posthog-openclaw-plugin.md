# Configuring the PostHog OpenClaw Plugin

This guide walks you through every setting available in the PostHog OpenClaw plugin, with complete examples in both JSON and YAML formats so you can get up and running quickly.

---

## Step 1 — Install the Plugin

Before configuring anything, install the plugin by running this command in your terminal:

```bash
openclaw plugins install @posthog/openclaw
```

---

## Step 2 — Where to Add the Configuration

Open your OpenClaw configuration file. This is either:

- **`openclaw.json`** — if you prefer JSON format
- **`openclaw.yaml`** — if you prefer YAML format

You will add the PostHog plugin settings inside the `plugins` → `entries` section of that file. The entry key **must** be exactly `"posthog"` — this name is fixed and cannot be changed.

---

## Step 3 — Required Setting

There is only **one required setting** you must provide:

| Setting | What it is | Format |
|---|---|---|
| `apiKey` | Your PostHog project API key | Starts with `phc_`, e.g. `phc_abc123...` |

You can find your API key in your PostHog project settings. It always begins with `phc_`. If this setting is missing, the plugin will fail to start and report a validation error (see [Validation & Errors](#validation--errors) below).

---

## Step 4 — Optional Settings

All other settings are optional. If you leave them out, the defaults shown below are used automatically.

| Setting | Type | Default | What it controls |
|---|---|---|---|
| `host` | Text (URL) | `https://us.i.posthog.com` | The address of your PostHog instance. Change this if you use a self-hosted PostHog or the EU cloud (`https://eu.i.posthog.com`). |
| `privacyMode` | true / false | `false` | When set to `true`, the actual text of messages, prompts, and tool inputs/outputs is **not** sent to PostHog. Token counts, timing, model names, and error info are always captured regardless. |
| `traceGrouping` | `"message"` or `"session"` | `"message"` | Controls how AI interactions are grouped together. `"message"` creates one trace per individual message. `"session"` groups an entire conversation into a single trace, splitting when the session window expires. |
| `sessionWindowMinutes` | Number | `60` | How many minutes of inactivity must pass before a new session is started. Applies to both trace grouping modes. |
| `enabled` | true / false | `true` | Turns the plugin on or off without removing it from your configuration. |

---

## Complete Configuration Examples

### JSON Format (`openclaw.json`)

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

### YAML Format (`openclaw.yaml`)

```yaml
plugins:
  entries:
    posthog:
      enabled: true
      config:
        apiKey: "phc_your_project_key"
        host: "https://us.i.posthog.com"
        privacyMode: false
        traceGrouping: "message"
        sessionWindowMinutes: 60

diagnostics:
  enabled: true
```

### Minimal Configuration (required fields only)

If you are happy with all the defaults, you only need to provide the `apiKey`:

**JSON:**
```json
{
    "plugins": {
        "entries": {
            "posthog": {
                "config": {
                    "apiKey": "phc_your_project_key"
                }
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
      config:
        apiKey: "phc_your_project_key"
```

### Privacy-First Configuration

If you want analytics without sending any conversation content to PostHog:

**JSON:**
```json
{
    "plugins": {
        "entries": {
            "posthog": {
                "config": {
                    "apiKey": "phc_your_project_key",
                    "privacyMode": true
                }
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
      config:
        apiKey: "phc_your_project_key"
        privacyMode: true
```

### Session-Level Trace Grouping

If you want an entire conversation grouped as one trace (useful for chatbot-style apps):

**JSON:**
```json
{
    "plugins": {
        "entries": {
            "posthog": {
                "config": {
                    "apiKey": "phc_your_project_key",
                    "traceGrouping": "session",
                    "sessionWindowMinutes": 30
                }
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
      config:
        apiKey: "phc_your_project_key"
        traceGrouping: "session"
        sessionWindowMinutes: 30
```

---

## Enabling Full Trace Capture

To capture complete conversation-level trace events (which summarize an entire message cycle including total tokens and duration), you must also enable the `diagnostics` section in your OpenClaw config:

```json
{
    "diagnostics": {
        "enabled": true
    }
}
```

Without this, individual AI generation events and tool call events are still captured — but the overall conversation trace summary is not.

---

## Validation & Errors

When OpenClaw starts up, it validates your plugin configuration against a built-in schema. Here is what happens when something is wrong:

### Missing `apiKey`

If you leave out the required `apiKey` field, OpenClaw will refuse to start the plugin and report a validation error similar to:

```
Plugin "posthog" configuration is invalid: "apiKey" is required
```

**Fix:** Make sure you have `"apiKey": "phc_..."` inside the `config` block.

### Wrong entry key name

If you name your entry anything other than `"posthog"` (for example `"posthog-openclaw"` or `"ph"`), the plugin will not be recognized.

**Fix:** The key in `plugins.entries` must be exactly `"posthog"`.

### Unrecognized settings

The plugin does not accept any settings beyond the ones listed above. Adding an unrecognized field (for example `"debug": true`) will trigger a validation error:

```
Plugin "posthog" configuration is invalid: additional properties are not allowed
```

**Fix:** Remove any fields not listed in the Options table above.

### Checklist before saving

- [ ] `apiKey` is present and starts with `phc_`
- [ ] The entry key is exactly `"posthog"`
- [ ] `traceGrouping` is either `"message"` or `"session"` (not any other value)
- [ ] `sessionWindowMinutes` is a number, not a string
- [ ] `privacyMode` and `enabled` are `true` or `false`, not strings like `"true"`
- [ ] `diagnostics.enabled` is set to `true` if you want full trace summaries