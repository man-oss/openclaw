# How to Configure Trace Grouping

When your AI assistant handles conversations, every LLM call, tool use, and response gets recorded as a **trace** in your PostHog LLM Analytics dashboard. A trace is a complete record of one unit of AI activity — capturing the model used, tokens consumed, cost, latency, and the full back-and-forth between the user and the AI.

**Trace grouping** controls how those individual AI calls are bundled together into traces. Choosing the right grouping mode means your PostHog dashboard reflects how your users actually experience your app, making it far easier to spot problems, measure costs, and understand conversations.

---

## The Two Grouping Modes

### Message Mode (Default)

**Setting:** `"traceGrouping": "message"`

In message mode, every single message cycle — one user message and the AI's complete response to it — becomes its own separate trace. Each trace has a unique ID tied to that specific message run.

**Best for:**
- Chatbots or assistants that handle self-contained, one-shot questions (e.g., "What's the weather today?")
- Workflows where each request is independent and unrelated to previous ones
- Use cases where you want to measure the cost and performance of individual interactions in isolation

**What you'll see in PostHog:** Each row in the LLM Analytics Traces view represents one user message and its AI response. You can quickly compare latency and token usage across individual requests.

---

### Session Mode

**Setting:** `"traceGrouping": "session"`

In session mode, all AI activity within a rolling time window is grouped into a single trace. Instead of one trace per message, you get one trace covering the entire conversation — as long as the user keeps interacting within the session window.

**Best for:**
- Multi-turn chatbots where the AI remembers context across messages (e.g., "What's the weather?" → "And what about tomorrow?" → "Should I bring an umbrella?")
- Conversational agents where understanding the full dialogue is more useful than examining each message in isolation
- Use cases where you want to track total cost, tokens, and latency for an entire conversation

**What you'll see in PostHog:** Each row in the LLM Analytics Traces view represents a full conversation. Aggregated token counts and costs reflect the entire session, giving you a holistic view of each user's experience.

---

## Switching Between Modes

Open your `openclaw.json` (or `openclaw.yaml`) configuration file and update the `traceGrouping` setting inside your PostHog plugin configuration:

**To use message mode:**
```jsonc
{
    "plugins": {
        "entries": {
            "posthog": {
                "enabled": true,
                "config": {
                    "apiKey": "phc_your_project_key",
                    "host": "https://us.i.posthog.com",
                    "traceGrouping": "message"
                }
            }
        }
    }
}
```

**To use session mode:**
```jsonc
{
    "plugins": {
        "entries": {
            "posthog": {
                "enabled": true,
                "config": {
                    "apiKey": "phc_your_project_key",
                    "host": "https://us.i.posthog.com",
                    "traceGrouping": "session",
                    "sessionWindowMinutes": 60
                }
            }
        }
    }
}
```

Restart your OpenClaw gateway after saving changes for the new setting to take effect.

---

## Controlling the Session Window

Whether you use message mode or session mode, a **session window** determines when a period of inactivity is long enough to start a fresh session. The default is **60 minutes**.

| Setting | Type | Default | What it does |
|---|---|---|---|
| `sessionWindowMinutes` | number | `60` | Minutes of inactivity before a new session begins |

**Example:** With `"sessionWindowMinutes": 30`, if a user stops chatting for 30 minutes and then sends a new message, that message starts a brand-new trace — even in session mode.

To change the window, add or update `sessionWindowMinutes` in your plugin config:

```jsonc
"config": {
    "apiKey": "phc_your_project_key",
    "traceGrouping": "session",
    "sessionWindowMinutes": 30
}
```

Shorter windows create more traces with tighter scope. Longer windows group more activity together into fewer, broader traces.

---

## Quick Reference: Which Mode Should I Use?

| My application looks like… | Recommended mode |
|---|---|
| A Q&A bot where each question stands alone | `message` |
| A customer support chat with back-and-forth dialogue | `session` |
| A one-click AI feature (summarize, translate, generate) | `message` |
| A virtual assistant that remembers earlier parts of the conversation | `session` |
| I want to measure cost per individual request | `message` |
| I want to measure cost per full conversation | `session` |

---

## Important: Enable Diagnostics for Full Trace Capture

For complete trace-level summaries (including aggregated token counts and total latency per trace) to appear in PostHog, diagnostics must be turned on in your OpenClaw configuration:

```jsonc
{
    "diagnostics": {
        "enabled": true
    }
}
```

Without this, individual AI generation and tool call events are still captured, but the rolled-up trace summary event will be missing from your dashboard.