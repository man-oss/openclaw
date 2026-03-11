# Key Concepts: LLM Events, Traces, and Sessions

When you use PostHog LLM Analytics with OpenClaw, your AI activity is automatically organized into a structured data model made up of three building blocks: **events**, **traces**, and **sessions**. Understanding how these fit together will help you make sense of the data you see in your PostHog dashboard.

---

## The Three Types of Events

Every time your AI agent does something meaningful, the plugin records it as one of three event types, each prefixed with `$ai_` in PostHog.

### 1. Generations (`$ai_generation`)

A **generation** is a single, complete interaction with a large language model (LLM) — the moment your agent sends a prompt and receives a response. Think of it as one "turn" with the AI.

Every generation event captures:

- **Which model and provider was used** — for example, `gpt-4o` from `openai`, or `claude-3` from `anthropic`
- **How long it took** — the full request duration in seconds
- **Token usage** — how many input and output tokens were consumed, including any cache activity
- **Cost** — the total USD cost, broken down into input and output costs
- **Why it stopped** — whether the model finished naturally (`stop`), hit a length limit (`length`), handed off to a tool (`tool_calls`), or encountered an error (`error`)
- **The conversation content** — the messages sent in and the responses received (hidden when Privacy Mode is on)
- **Error details** — whether something went wrong and what the error was

Each generation belongs to a trace and a session, so you can always see it in context.

---

### 2. Tool Executions (`$ai_span`)

A **tool execution** (recorded as an `$ai_span` event) captures what happens when your AI agent calls an external tool — for example, searching the web, running a calculation, or querying a database.

Every tool execution event captures:

- **The tool's name** — so you know exactly which capability was invoked
- **How long it took** — the execution duration in seconds
- **Input and output** — what parameters were passed in and what the tool returned (hidden when Privacy Mode is on)
- **Error details** — whether the tool call failed and why
- **Its place in the hierarchy** — a parent generation ID links it back to the LLM call that triggered it

Tool events appear nested under their parent generation in the PostHog trace view, giving you a complete picture of the agent's decision-making process.

---

### 3. Trace Summaries (`$ai_trace`)

A **trace summary** (recorded as an `$ai_trace` event) is a rolled-up view of an entire message cycle — from when a user sends a message to when the agent finishes responding. It is the "headline" for a group of related generations and tool calls.

Every trace summary captures:

- **Total duration** — the end-to-end time for the full response cycle
- **Accumulated token counts** — the sum of all input and output tokens across every generation in the trace
- **Error status** — whether anything went wrong during the cycle
- **Channel information** — which platform the conversation happened on (e.g., `telegram`, `slack`)

> **Note:** Trace summary events only appear in PostHog if diagnostics are enabled in your OpenClaw configuration.

---

## Traces — Grouping Related LLM Calls

A **trace** is a collection of related events that belong to the same logical conversation flow. If your agent calls an LLM three times and uses two tools to answer a single user message, all five events share the same **Trace ID** (`$ai_trace_id`) and appear together as one trace in PostHog.

Traces give you a hierarchical, end-to-end view of what your agent did — you can drill into any individual generation or tool call within it.

### How Traces Are Grouped

The plugin supports two trace grouping modes, which you control with the `traceGrouping` setting:

| Mode | Behavior |
|---|---|
| **`message`** (default) | One trace per message run. Each user message gets its own trace, identified by its unique run ID. |
| **`session`** | All generations within the same session window are grouped into a single trace. Useful if you want one trace to represent an entire conversation. |

---

## Sessions — Time-Bounded Windows of Activity

A **session** represents a continuous window of user activity. It is the broadest grouping in the data model — a session can contain many traces (and many generations within those traces).

Sessions are time-bounded: if a user is inactive for longer than the configured inactivity window, their next interaction starts a new session. The length of this window is controlled by the `sessionWindowMinutes` setting, which defaults to **60 minutes**.

Every generation and trace summary carries a **Session ID** (`$ai_session_id`), so you can always filter your PostHog dashboard by session to see everything a particular user did in one sitting.

---

## How Run IDs and Session IDs Relate to Traces and Sessions

Two identifiers tie everything together:

| Identifier | What it represents | How it's used |
|---|---|---|
| **Run ID** | A unique ID for a single message processing run (one user message → one agent response cycle) | In `message` trace grouping mode, the Run ID becomes the Trace ID. Every generation and tool call in that run shares it. |
| **Session ID** | A unique ID for the current session window | Attached to every generation and trace summary event. Used to group all activity within an inactivity window. In `session` trace grouping mode, the Session ID also becomes the Trace ID, so the entire session appears as one trace. |

In short: the Run ID scopes a single message cycle; the Session ID scopes a period of user activity. Depending on your `traceGrouping` setting, one or the other becomes the anchor for how events are grouped into traces in PostHog.

---

## How These Events Appear in PostHog

Once data is flowing, you can explore it in PostHog under the **LLM Analytics** section. Here is what you will find:

- **Traces view** — lists each trace with its total latency, token counts, cost, and error status at a glance
- **Trace detail** — click any trace to expand it into a timeline of all its generations and tool executions, in the order they occurred
- **Sessions** — filter or group by Session ID to see everything a user did during a single activity window
- **Filtering by channel or agent** — use the `$ai_channel` and `$ai_agent_id` properties to narrow down to specific platforms or agent identities
- **Privacy Mode redaction** — if Privacy Mode is enabled, the content fields (`$ai_input`, `$ai_output_choices`, `$ai_input_state`, `$ai_output_state`) will appear as redacted, while all metrics (tokens, latency, cost, error status) remain visible

---

## Quick Reference: The Data Model at a Glance

```
Session  (time-bounded window of user activity)
└── Trace  (one message cycle, or the whole session depending on your setting)
    ├── $ai_generation  (one LLM call)
    │   └── $ai_span    (tool call triggered by that LLM call)
    ├── $ai_generation  (another LLM call in the same cycle)
    └── $ai_trace       (summary rolled up at the end of the cycle)
```

Every event at every level carries both a `$ai_trace_id` and a `$ai_session_id`, so PostHog can display them together or let you filter to exactly the scope you care about.