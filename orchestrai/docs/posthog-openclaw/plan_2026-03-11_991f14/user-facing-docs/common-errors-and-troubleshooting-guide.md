# Troubleshooting Guide: PostHog OpenClaw Plugin

Use this guide to diagnose and fix the most common issues you may encounter when using the PostHog analytics plugin for OpenClaw.

---

## Issue 1: The Plugin Is Not Loading

### Symptom
OpenClaw starts without any errors, but no PostHog events appear — and the plugin doesn't seem to be active at all.

### Possible Causes & Fixes

**The config file is in the wrong place or has the wrong name**

OpenClaw looks for your configuration in a file named `openclaw.json` or `openclaw.yaml`. Make sure:
- The file is saved in the right location (typically `~/.openclaw/openclaw.json` for user-level config)
- The filename is spelled exactly as shown — no extra spaces, wrong capitalisation, or missing extension

**The plugin entry key is wrong**

The plugin section in your config file must use the exact key `"posthog"` — not `@posthog/openclaw` or any other variation:

```jsonc
{
    "plugins": {
        "entries": {
            "posthog": {          ✅ Correct — must be exactly "posthog"
                "enabled": true,
                "config": { ... }
            }
        }
    }
}
```

Using any other key name means the plugin will not be recognised, even if it is installed correctly.

**JSON or YAML syntax error in your config file**

A single missing comma, bracket, or quote can prevent the entire config file from loading. Common mistakes in JSON:
- Trailing comma after the last item in a list or object (e.g. `"privacyMode": false,` followed by `}`)
- Missing quotes around keys or string values
- Mismatched curly braces `{}` or square brackets `[]`

Use a free online JSON validator (such as [jsonlint.com](https://jsonlint.com)) to check your config file for errors before restarting OpenClaw.

---

## Issue 2: Events Are Not Appearing in PostHog

### Symptom
The plugin appears to load, but no events show up in your PostHog LLM Analytics dashboard.

### Possible Causes & Fixes

**Wrong or missing API key**

Your `apiKey` value must be your PostHog **project** API key, which begins with `phc_`. You can find it in your PostHog project settings under **Project API Key**.

```jsonc
"config": {
    "apiKey": "phc_your_project_key",   ✅ Starts with "phc_"
    ...
}
```

Double-check that:
- You haven't accidentally used a Personal API key (which starts with `phx_`)
- There are no extra spaces or characters around the key
- The key belongs to the correct PostHog project

**Wrong host URL**

If your organisation uses a self-hosted PostHog instance or the EU cloud, the default host (`https://us.i.posthog.com`) will not work. Update the `host` setting to match your instance:

| PostHog Region / Setup | Host Value |
|---|---|
| US Cloud (default) | `https://us.i.posthog.com` |
| EU Cloud | `https://eu.i.posthog.com` |
| Self-hosted | Your own PostHog URL, e.g. `https://posthog.yourcompany.com` |

```jsonc
"config": {
    "apiKey": "phc_your_project_key",
    "host": "https://eu.i.posthog.com",   ← Change this to match your setup
    ...
}
```

**Network or firewall blocking outbound requests**

The plugin sends data directly to your PostHog instance over HTTPS. If your server has a firewall or outbound proxy, make sure the PostHog host URL is on the allow-list. You can test basic connectivity by opening the host URL in a browser — you should see a PostHog-related response, not a connection error.

**The plugin is disabled**

Check that `enabled` is not set to `false` in your config:

```jsonc
"posthog": {
    "enabled": true,    ← Make sure this is true (or remove the line entirely — true is the default)
    ...
}
```

---

## Issue 3: Trace Events Are Missing (No `$ai_trace` Data)

### Symptom
Individual generation and tool events appear in PostHog, but you see no trace-level data (no overall latency, total token counts, or trace summaries).

### Cause & Fix

**Diagnostics are not enabled in OpenClaw**

Trace events (`$ai_trace`) are only captured when OpenClaw's built-in diagnostics feature is turned on. This is a separate setting at the top level of your config file — it is not part of the plugin's own configuration:

```jsonc
{
    "plugins": { ... },
    "diagnostics": {
        "enabled": true     ← This line is required for trace events
    }
}
```

Without this, message cycle completion events are never emitted, so trace summaries cannot be created.

---

## Issue 4: Trace Data Is Incomplete or Generations Are Not Grouped Together

### Symptom
Events appear in PostHog, but generations from the same conversation appear as separate, unrelated events instead of being grouped into a trace.

### Possible Causes & Fixes

**`runId` is not being set**

When using `"message"` trace grouping mode (the default), each conversation turn must have a consistent `runId` so that all the related generations can be linked together. If `runId` is not set, events cannot be correctly grouped into a trace.

Confirm that your OpenClaw configuration and any custom workflows are passing a `runId` through correctly.

**The session window is too short**

If you are using `"session"` trace grouping mode, all activity within the same session window is grouped into one trace. If the `sessionWindowMinutes` value is set too low, a new session may be started before the conversation is complete, splitting the trace.

The default is 60 minutes. If your conversations can span longer periods of inactivity, increase this value:

```jsonc
"config": {
    ...
    "traceGrouping": "session",
    "sessionWindowMinutes": 120    ← Increase if sessions are being split unexpectedly
}
```

**Understanding the two grouping modes**

| Mode | How Traces Are Grouped | Best For |
|---|---|---|
| `"message"` (default) | One trace per `runId` | Request/response workflows with a clear run identifier |
| `"session"` | All activity within the session window grouped together | Conversational flows where activity spans multiple turns |

---

## Issue 5: Events Arriving With No Content (Privacy Mode Accidentally Enabled)

### Symptom
Events appear in PostHog, but the input messages, output text, and tool parameters are all blank or missing. Token counts, model names, and error flags are still visible.

### Cause & Fix

**`privacyMode` is set to `true`**

When privacy mode is enabled, the plugin intentionally strips all message content — including prompts, responses, and tool inputs/outputs — before sending data to PostHog. This is by design and is not a bug, but it can happen accidentally if the setting was left on from testing.

To restore full event content, set `privacyMode` to `false` in your config:

```jsonc
"config": {
    "apiKey": "phc_your_project_key",
    "host": "https://us.i.posthog.com",
    "privacyMode": false    ← Change from true to false
}
```

After saving the change, restart OpenClaw. New events will include full content. Note that **previously captured events with no content cannot be recovered** — privacy mode permanently excludes that data before it is sent.

> **Note:** If you are intentionally using privacy mode for compliance reasons, this is the expected behaviour. Token counts, latency, model information, costs, and error status are always captured regardless of this setting.

---

## Quick Diagnostic Checklist

Run through this checklist when something isn't working:

- [ ] Config file is named `openclaw.json` or `openclaw.yaml` and is in the correct location
- [ ] The plugin entry key in the config is exactly `"posthog"` (not the npm package name)
- [ ] Config file has valid JSON or YAML syntax (no trailing commas, mismatched brackets)
- [ ] `apiKey` starts with `phc_` and belongs to the correct PostHog project
- [ ] `host` matches your PostHog region (US, EU, or self-hosted)
- [ ] `enabled` is `true` (or not set — it defaults to `true`)
- [ ] `diagnostics.enabled` is `true` at the top level of your config (required for trace events)
- [ ] `privacyMode` is `false` if you expect to see message content in PostHog
- [ ] `sessionWindowMinutes` is long enough for your conversation patterns
- [ ] Outbound HTTPS traffic to your PostHog host is not blocked by a firewall

---

## Still Stuck?

If you have worked through this guide and events are still not appearing, check the OpenClaw gateway logs for any error messages when the plugin initialises. You can also verify your setup by running a quick test using the OpenClaw WebChat interface at `http://127.0.0.1:18789/__openclaw__/canvas/` and watching whether events appear in PostHog's [LLM Analytics](https://us.posthog.com/llm-analytics/traces) section after sending a message.