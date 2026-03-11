# Understanding Your Data: Traces, Sessions, and Events in OpenClaw

When you look at your OpenClaw activity data — whether in the Control UI dashboard, usage reports, or diagnostic feeds — you'll encounter a handful of recurring concepts. This guide explains exactly what each one means so you can interpret your data with confidence.

---

## The Core Idea: A Session Is a Conversation

In OpenClaw, a **session** is a single, continuous conversation thread between you and the assistant. Every message you send on WhatsApp, Telegram, Slack, Discord, or any other connected channel belongs to a session.

- Your personal chat with the assistant lives in the **`main` session**.
- Group chats each get their own isolated session.
- Sub-agents spawned via `sessions_spawn` also receive their own session, tracked separately.

Sessions are identified by a **session ID** — a unique string that ties all the activity in that conversation together. Session IDs appear in usage summaries, transcript files, and diagnostic events, letting you trace any piece of activity back to the conversation it came from.

---

## What Is a Run?

Within a session, each time the assistant processes a message from start to finish — calling the AI model, potentially invoking tools, and producing a reply — that complete cycle is called a **run**.

Each run is assigned a **run ID** (`runId`). The run ID is what lets OpenClaw tie together everything that happened in response to a single incoming message:

- The AI generation (the call to the language model)
- Any tool calls the assistant made during that generation
- The final reply sent back to you

You'll see `runId` appear in diagnostic stream events (for example, `run.attempt` events) so you can correlate model usage with the specific message that triggered it.

---

## What Is a Trace?

A **trace** is a logical grouping of AI activity. Think of it as the unit you analyze when you want to understand what the assistant did in response to something.

OpenClaw ties together model usage, tool calls, and timing information under a common trace context. When you look at a usage report and see how many tokens were consumed or how long a response took, that data is aggregated at the run/trace level — everything that happened in response to one message, grouped together.

Traces let you answer questions like:
- How many tokens did this one reply cost?
- How long did the assistant take to respond?
- Which tools did it use while generating this reply?

---

## The Event Stream: What Gets Recorded

OpenClaw records activity as a stream of structured events. Understanding these event types lets you make sense of any log or diagnostic output.

### Model Usage Events

Recorded every time the assistant calls an AI model. Each event captures:

| What it records | What it tells you |
|---|---|
| `provider` | Which AI service was used (e.g., Anthropic, OpenAI) |
| `model` | The specific model version |
| `usage.input` / `usage.output` | Token counts for the prompt and reply |
| `usage.cacheRead` / `usage.cacheWrite` | Tokens served from or written to cache |
| `durationMs` | How long the model call took |
| `costUsd` | Estimated cost in USD |
| `sessionId` / `sessionKey` | Which conversation this belongs to |

### Message Events

Recorded as messages flow through the system:

- **Message queued** — a new message arrived and is waiting to be processed
- **Message processed** — the assistant finished handling a message; includes the outcome (`completed`, `skipped`, or `error`) and how long it took

### Session State Events

Recorded whenever a session changes state:

- **`idle`** — no active processing
- **`processing`** — the assistant is actively generating a response
- **`waiting`** — paused, for example waiting for a tool result

If a session appears stuck in `processing` for too long, a `session.stuck` event is emitted automatically, which you can use to diagnose hangs.

### Run Attempt Events

Recorded at the start of each run, with the `runId` and attempt number. If a run is retried (for example after a model failover), each attempt gets its own event, all sharing the same `runId`.

---

## How Session IDs, Run IDs Connect

Here is how these identifiers relate:

```
Session (one conversation)
  └── Run (one message → one full assistant response)
        ├── run.attempt event  (with runId + sessionId)
        ├── model.usage event  (with runId + sessionId + tokens + cost)
        └── tool calls         (linked by the same runId)
```

- A **session** can contain many **runs** (one per message you send).
- A **run** groups all the activity for a single response.
- All events within a run share the same `sessionId` and `runId`, so you can filter by either to see just what you need.

---

## Reading Usage Summaries

When you open the usage dashboard or request a usage summary, you're seeing this data aggregated:

- **Daily totals** — token counts and costs rolled up by calendar day, across all sessions and runs in that day.
- **Per-session summaries** — for a single session: total tokens, total cost, first and last activity timestamps, how many messages were exchanged, which tools were used and how often, and latency statistics (average, p95, min, and max response time).
- **Per-model breakdowns** — if you use multiple AI providers or models, usage is tracked separately for each so you can see exactly where your tokens are going.

---

## Latency: How Response Time Is Measured

OpenClaw measures response latency as the time from when a user message arrives to when the assistant's reply is complete. This is captured in `durationMs` on model usage events (when the model itself reports it) or estimated from timestamps otherwise.

Latency statistics in session summaries include:

- **Average** response time
- **p95** response time (95% of responses were faster than this)
- **Min / Max** — fastest and slowest responses observed

Extremely long gaps (over 12 hours) are excluded from latency calculations to avoid skewing averages with idle periods.

---

## Diagnostic Events vs. Usage Logs

OpenClaw records data in two complementary ways:

| Type | Where it lives | What it's for |
|---|---|---|
| **Transcript / usage logs** | Files stored per-session on disk | Long-term record; used for usage summaries and cost reports |
| **Diagnostic event stream** | Real-time in-memory stream | Live monitoring; visible in the Control UI activity feed |

The diagnostic stream is available when you enable diagnostics in your configuration (`diagnostics.enabled: true`). It gives you a live view of exactly what the system is doing, event by event, in real time.

---

## Quick Reference: Key Terms

| Term | What it means |
|---|---|
| **Session** | A single conversation thread (e.g., your WhatsApp chat with the assistant) |
| **Session ID** | The unique identifier for a session |
| **Run** | One complete request-response cycle within a session |
| **Run ID** | The unique identifier for a run; groups all events for one response |
| **Model usage event** | Recorded every time the AI model is called; includes tokens and cost |
| **Session state** | Whether the session is idle, processing, or waiting |
| **Transcript file** | The on-disk log of all messages in a session, stored as JSONL |
| **Diagnostic stream** | The real-time event feed for live monitoring |