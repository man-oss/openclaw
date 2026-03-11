# Configuration Concepts: PostHog LLM Analytics Plugin for OpenClaw

This reference guide explains every configuration option available in the PostHog LLM Analytics plugin and how they interact. Use it to design the ideal setup for your environment — whether you need maximum privacy, full observability, or something in between.

---

## All Configuration Options at a Glance

| Option | Type | Default | Required |
|---|---|---|---|
| `apiKey` | Text | _(none)_ | **Yes** |
| `host` | Text | `https://us.i.posthog.com` | No |
| `privacyMode` | True/False | `false` | No |
| `traceGrouping` | `"message"` or `"session"` | `"message"` | No |
| `sessionWindowMinutes` | Number | `60` | No |
| `enabled` | True/False | `true` | No |

---

## Option Details

### `apiKey` — Your PostHog Project Key
**Type:** Text string  
**Default:** _(required — no default)_

This is the only mandatory setting. You can find your project API key in your PostHog project settings. It looks like `phc_xxxxxxxxxxxxxxxx`. Without this, the plugin cannot send any data to PostHog.

**Where to get it:** Log in to PostHog → Project Settings → Project API Key.

---

### `host` — Your PostHog Instance Address
**Type:** Text string  
**Default:** `https://us.i.posthog.com`

This tells the plugin where to send your analytics data. If you use PostHog's standard US cloud, you don't need to change this. Change it if you:

- Use PostHog's **EU cloud** (set to `https://eu.i.posthog.com`)
- Host your **own self-managed PostHog instance** (set to your instance's URL)

---

### `privacyMode` — Control What Content Is Sent
**Type:** True/False  
**Default:** `false`

This is the most impactful privacy control in the plugin. When turned on, the plugin **never sends the actual text** of any conversation, prompt, or tool parameter to PostHog.

#### What changes with Privacy Mode on vs. off

| Data Type | Privacy Mode OFF | Privacy Mode ON |
|---|---|---|
| AI model name (e.g. `gpt-4o`) | ✅ Sent | ✅ Sent |
| AI provider (e.g. `openai`) | ✅ Sent | ✅ Sent |
| Token counts (input/output) | ✅ Sent | ✅ Sent |
| Cost estimates (USD) | ✅ Sent | ✅ Sent |
| Response latency | ✅ Sent | ✅ Sent |
| Error status and messages | ✅ Sent | ✅ Sent |
| Stop reason | ✅ Sent | ✅ Sent |
| **LLM input messages / prompts** | ✅ Sent | 🚫 Redacted |
| **LLM output / response text** | ✅ Sent | 🚫 Redacted |
| **Tool call input parameters** | ✅ Sent | 🚫 Redacted |
| **Tool call output results** | ✅ Sent | 🚫 Redacted |

In short: with Privacy Mode on, you still get complete performance, cost, and reliability metrics — you just won't be able to inspect the actual words your users typed or that the model generated.

> **When to use it:** Any production environment where user conversations may contain sensitive, regulated, or personally identifiable information (PII).

---

### `traceGrouping` — How Conversations Are Organized
**Type:** Choice: `"message"` or `"session"`  
**Default:** `"message"`

This setting controls how the plugin groups LLM activity into "traces" — the hierarchical view you see in your PostHog LLM Analytics dashboard. Think of a trace as a folder that bundles related AI calls together.

#### `"message"` mode (default)

Each individual user message that flows through OpenClaw gets its own trace. If a single message triggers multiple AI calls (e.g., a chain of reasoning steps or parallel tool calls), they all appear together under that one message's trace.

- **Best for:** Chatbots and assistants where you want to analyze the cost, latency, and quality of responding to each message independently.
- **Result in PostHog:** One trace per message processed.

#### `"session"` mode

All AI activity from an entire conversation session is grouped into a single trace. A new trace is only started when the user has been inactive for longer than the `sessionWindowMinutes` timeout.

- **Best for:** Workflows or agents where you want to understand the full end-to-end cost and behavior of an entire user session, not just individual messages.
- **Result in PostHog:** One trace per session (or session window).

> **Important:** To see `$ai_trace` events in your PostHog dashboard (the summary events that cap off each trace), you must also set `diagnostics.enabled: true` in your OpenClaw configuration. Without this, generation and span events are still captured, but the trace-level summary is not.

---

### `sessionWindowMinutes` — Inactivity Timeout for Sessions
**Type:** Number  
**Default:** `60` (one hour)

This setting defines how many minutes of inactivity must pass before the plugin considers a session "over" and starts a new one. It applies regardless of which `traceGrouping` mode you use, but its visible effect differs:

#### Effect in `"message"` mode
A new session ID is assigned after the inactivity window expires. This means token totals, costs, and other session-level metrics reset, and subsequent messages are treated as a fresh session even from the same user.

#### Effect in `"session"` mode
This timeout directly controls **when a trace ends and a new one begins**. If a user sends a message, goes quiet for longer than `sessionWindowMinutes`, then sends another message, the second message starts an entirely new trace in PostHog. Shorten this value for fast-paced interactions (e.g., 15–30 minutes); lengthen it for workflows where users may pause for extended periods.

#### Choosing the right value

| Use Case | Suggested Value |
|---|---|
| Real-time chat support | 15–30 minutes |
| General-purpose assistant | 60 minutes (default) |
| Long-running research tasks | 120–240 minutes |
| Batch / overnight workflows | 480+ minutes |

---

### `enabled` — Turn the Plugin On or Off
**Type:** True/False  
**Default:** `true`

This master switch lets you completely disable the plugin without removing its configuration. When set to `false`, no events are sent to PostHog at all.

#### Primary use case: environment-specific toggling

The most common reason to use this setting is to prevent development or test traffic from polluting your PostHog analytics. You can maintain separate OpenClaw configuration files per environment:

**Development** (`openclaw.json` in dev):
```jsonc
"posthog": {
    "enabled": false,
    "config": { "apiKey": "phc_..." }
}
```

**Production** (`openclaw.json` in prod):
```jsonc
"posthog": {
    "enabled": true,
    "config": { "apiKey": "phc_..." }
}
```

This way, the same plugin configuration can be committed to your project and toggled at the environment level without touching the rest of the settings.

---

## How the Settings Work Together

The six options aren't fully independent — some combinations have meaningful interactions. Here are the key relationships to keep in mind:

### Privacy Mode + Trace Grouping
Privacy Mode and Trace Grouping are independent of each other. You can use `privacyMode: true` with either `"message"` or `"session"` grouping. Privacy Mode only affects *what content* appears in each event; Trace Grouping only affects *how events are organized* into traces.

### Trace Grouping + Session Window
These two settings are tightly linked. The session window determines when a "session" resets in both modes, but it has a much more visible effect in `"session"` mode where it directly controls trace boundaries. In `"message"` mode, the session window is more of a background bookkeeping detail.

### Enabled + Everything Else
When `enabled` is `false`, all other settings are irrelevant — no processing or sending occurs. You can leave your `apiKey`, `privacyMode`, and other values configured; they'll simply be ignored until you flip `enabled` back to `true`.

---

## Common Configuration Combinations

### High-Privacy Enterprise Setup
Use this when your users share sensitive information and your organization has strict data governance requirements.

```jsonc
{
    "posthog": {
        "enabled": true,
        "config": {
            "apiKey": "phc_your_project_key",
            "host": "https://eu.i.posthog.com",
            "privacyMode": true,
            "traceGrouping": "message",
            "sessionWindowMinutes": 30
        }
    }
}
```

**What this gives you:** Full performance and cost metrics (tokens, latency, cost, errors) with zero conversation content sent to PostHog. Data routes to the EU PostHog region. Each message is tracked independently for granular cost attribution.

---

### Full-Detail Debugging Setup
Use this during development or when investigating quality issues in a controlled environment where content inspection is acceptable.

```jsonc
{
    "posthog": {
        "enabled": true,
        "config": {
            "apiKey": "phc_your_project_key",
            "host": "https://us.i.posthog.com",
            "privacyMode": false,
            "traceGrouping": "session",
            "sessionWindowMinutes": 120
        }
    }
}
```

**What this gives you:** Full content visibility — every prompt, response, and tool call is captured. Session mode groups an entire back-and-forth conversation into one trace, making it easy to replay and audit the full flow. The 2-hour window accommodates longer debugging sessions without splitting traces prematurely.

> Remember to also set `diagnostics.enabled: true` in your OpenClaw config to capture trace-level summary events.

---

### Cost Monitoring Without Content (Mid-Size Production)
Use this for a production assistant where you trust the platform but want to minimize data exposure while keeping detailed cost and performance dashboards.

```jsonc
{
    "posthog": {
        "enabled": true,
        "config": {
            "apiKey": "phc_your_project_key",
            "host": "https://us.i.posthog.com",
            "privacyMode": true,
            "traceGrouping": "session",
            "sessionWindowMinutes": 60
        }
    }
}
```

**What this gives you:** Session-level cost rollups (total tokens and USD across a full conversation) without storing any text content. Ideal for dashboards that track spending per user or channel without a compliance review.

---

### Development / Staging — Fully Disabled
Use this to prevent test runs from appearing in your production PostHog project.

```jsonc
{
    "posthog": {
        "enabled": false,
        "config": {
            "apiKey": "phc_your_project_key"
        }
    }
}
```

**What this gives you:** A safe no-op state. The plugin is installed and configured but sends nothing. Switch `enabled` to `true` when you're ready to start capturing data.

---

## Quick Decision Guide

| Your Situation | Recommended Settings |
|---|---|
| Users share PII or sensitive data | `privacyMode: true` |
| You want to inspect prompts and responses | `privacyMode: false` |
| You need per-message cost breakdown | `traceGrouping: "message"` |
| You need full-conversation cost rollup | `traceGrouping: "session"` |
| Fast-paced real-time chat | `sessionWindowMinutes: 15–30` |
| Long-running or async workflows | `sessionWindowMinutes: 120+` |
| Development / test environment | `enabled: false` |
| Self-hosted or EU PostHog | Set `host` to your instance URL |
| Want trace summary events in PostHog | Also set `diagnostics.enabled: true` in OpenClaw |