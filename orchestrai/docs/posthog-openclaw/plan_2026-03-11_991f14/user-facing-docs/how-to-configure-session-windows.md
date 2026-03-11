## What Is a Session Window?

A **session window** defines how long PostHog OpenClaw waits for new activity before considering a conversation finished. Specifically, it is a period of **inactivity** measured in minutes. Every time your AI agent completes an LLM call, a timer resets. If no further activity occurs before that timer runs out, the next interaction starts a brand-new session.

This is a **rolling window** — it is not a fixed clock-hour. Each LLM response your agent produces refreshes the timer, so a long but continuous conversation is counted as a single session throughout its entire duration.

Session windows control two important things in your PostHog analytics:
- **Session IDs** — which interactions are grouped together under the same session identifier
- **Trace grouping** — when using session-level tracing, how long a single trace stays open to accumulate all the AI calls within it

---

## The `sessionWindowMinutes` Setting

| Setting | Type | Default |
|---|---|---|
| `sessionWindowMinutes` | number | `60` |

The value represents the **number of minutes of inactivity** that must pass before a new session begins. The default is **60 minutes** — if your agent receives no LLM activity for an hour, the next request starts a fresh session.

This setting applies to **both trace grouping modes** (`"message"` and `"session"`).

---

## How to Change the Session Window

Open your `openclaw.json` (or `openclaw.yaml`) and set `sessionWindowMinutes` inside the PostHog plugin config:

```jsonc
{
    "plugins": {
        "entries": {
            "posthog": {
                "enabled": true,
                "config": {
                    "apiKey": "phc_your_project_key",
                    "host": "https://us.i.posthog.com",
                    "traceGrouping": "message",
                    "sessionWindowMinutes": 30
                }
            }
        }
    }
}
```

Change `30` to whatever value best matches your application's natural usage patterns (see recommendations below). Restart your OpenClaw gateway after saving the file for the change to take effect.

---

## Choosing the Right Window for Your Application

There is no single correct value. Think about how your users actually interact with your AI agent:

### Short windows (5–20 minutes)
**Best for:** Real-time interactive tools, live chat assistants, customer support bots.

Users expect quick back-and-forth. A gap of more than a few minutes likely means the user has left or moved on to a new topic. Shorter windows give you more granular session counts and make your retention metrics reflect actual engagement bursts.

**Example:**
```jsonc
"sessionWindowMinutes": 10
```

### Medium windows (30–60 minutes)
**Best for:** General-purpose chatbots, productivity assistants, coding helpers.

Users may pause to think, read, or switch tabs before continuing the same task. The default of 60 minutes works well here, and 30 minutes is a reasonable tighter option.

**Example:**
```jsonc
"sessionWindowMinutes": 60
```

### Long windows (120+ minutes)
**Best for:** Batch processors, document analysis tools, research assistants, workflows where a single "job" may involve many LLM calls spread over hours.

A long job should not be split into many tiny sessions just because there was a pause mid-process. A larger window keeps the entire job grouped together.

**Example:**
```jsonc
"sessionWindowMinutes": 180
```

---

## How It Interacts with Trace Grouping Modes

Your `traceGrouping` setting determines how LLM calls are grouped into traces in PostHog. `sessionWindowMinutes` affects both modes, but in different ways:

### `"message"` mode (default)
Each individual message turn gets its own trace. The session window still controls the **session ID** — meaning all turns within the active window share the same session identifier, so you can see them as part of the same visit in PostHog's LLM Analytics dashboard.

### `"session"` mode
All LLM calls within the session window are grouped into a **single trace**. The window actively controls when a trace closes and a new one opens. If a user sends ten messages within a 60-minute window, you see one trace covering all of them. If they come back 61 minutes later, a new trace begins.

---

## What Happens to Active Sessions When You Change the Value

Changing `sessionWindowMinutes` takes effect the next time your gateway starts. Sessions that were already in progress at restart time are not retroactively closed — the new window length is applied to all activity going forward from that point.

- **Shortening the window** means sessions that previously would have stayed open will now expire sooner for any new activity.
- **Lengthening the window** means interactions that previously would have been split across sessions may now be combined into one.

Historical data already sent to PostHog is not affected — only new events captured after the restart will reflect the new window.

---

## Impact on PostHog Analytics

Getting the session window right directly improves the accuracy of your LLM Analytics metrics:

| Metric | Effect of too-short a window | Effect of too-long a window |
|---|---|---|
| **Session count** | Artificially inflated — one conversation appears as many sessions | Artificially deflated — unrelated conversations merged into one |
| **Session duration** | Appears shorter than actual usage | Appears longer than actual usage |
| **User retention** | May look like more returning users than reality | May undercount return visits |
| **Trace token totals** (session mode) | Tokens spread across many small traces | Tokens correctly accumulated per job or conversation |

A well-tuned `sessionWindowMinutes` means your PostHog dashboards reflect how users actually experience your product, giving you reliable data to act on.