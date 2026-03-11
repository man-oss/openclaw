## Overview

The PostHog plugin for OpenClaw acts as an invisible observer sitting inside the OpenClaw AI gateway. Every time OpenClaw processes a message — whether that involves calling a language model, running a tool, or completing a full conversation turn — the plugin automatically captures structured data about that activity and sends it to your PostHog project. You get full visibility into your AI system's behavior without changing anything about how your agents or users interact with OpenClaw.

---

## How OpenClaw's Plugin System Works

OpenClaw has a built-in plugin system that lets extensions register themselves and respond to events happening inside the gateway. Plugins are described by a manifest file (`openclaw.plugin.json`) that tells OpenClaw the plugin's identity, what configuration options it accepts, and how to connect it to the rest of the system.

When you add the PostHog plugin to your OpenClaw configuration, OpenClaw reads this manifest, validates your settings (like your API key and host URL), and loads the plugin as a background service that runs alongside the gateway. The plugin then "wires itself in" to the gateway's internal event system — meaning it starts listening for activity without you having to do anything else.

---

## The Three Lifecycle Moments the Plugin Listens To

The plugin hooks into three specific moments in OpenClaw's activity lifecycle:

### 1. When an LLM Call Begins (`llm_input`)
The moment OpenClaw is about to send a prompt to a language model, the plugin records the starting timestamp, the model being used, the provider (e.g. OpenAI, Anthropic), the conversation history, and identifiers linking this call to the broader session and trace. This is how the plugin knows *how long* a call takes — it notes the start time here and calculates the duration when the response comes back.

### 2. When an LLM Response Arrives (`llm_output`)
Once the language model responds, the plugin collects the output, token counts, cost information, and stop reason (whether the model finished naturally, hit a length limit, decided to call a tool, or errored). It then fires a **`$ai_generation`** event to PostHog containing all of this data. This is the primary event you'll see in the PostHog LLM Analytics dashboard for every AI call.

### 3. When a Tool Finishes (`after_tool_call`)
OpenClaw agents can call tools (like web search, database lookups, or custom functions). After each tool completes, the plugin captures a **`$ai_span`** event containing the tool's name, its inputs, its output, how long it took, and whether it errored. These spans are linked back to the LLM generation that triggered them via a parent-child relationship, so you can see the full execution tree in PostHog.

---

## The Diagnostic Event: Capturing Full Message Traces

Beyond individual LLM calls and tool executions, the plugin also listens for a higher-level signal: the moment a complete message cycle finishes (a `message.processed` diagnostic event from OpenClaw). When this fires, the plugin sends a **`$ai_trace`** event to PostHog that summarizes the entire user message round-trip — total latency, accumulated token counts across all LLM calls in the cycle, and whether anything went wrong.

> **Important:** This summary-level event only fires if you have `diagnostics.enabled: true` set in your OpenClaw configuration. Without it, you will still see individual `$ai_generation` and `$ai_span` events, but the rolled-up trace summary will be missing. If you notice gaps in the Traces view of the PostHog LLM Analytics dashboard, check this setting first.

---

## How Events Are Sent to PostHog

The plugin uses the official **posthog-node** library as its delivery mechanism. When the plugin starts up alongside the gateway, it opens a persistent connection to PostHog using your API key. Rather than sending each event individually the moment it happens, the plugin **batches events together** and flushes them in two situations:

- **Every 20 events** are accumulated (the batch is flushed automatically)
- **Every 10 seconds**, regardless of how many events are waiting

This batching approach is efficient and resilient — your PostHog dashboard isn't flooded with individual HTTP calls for every token counted, and brief network hiccups don't result in dropped data. When the OpenClaw gateway shuts down gracefully, the plugin also flushes any remaining events before closing.

---

## The PostHog Host Setting: Cloud vs. Self-Hosted

The `host` setting in your configuration tells the plugin *where* your PostHog instance lives. This matters because PostHog can be used in two ways:

- **PostHog Cloud (US):** The default — `https://us.i.posthog.com`. If you signed up at posthog.com and your data region is the United States, this works out of the box.
- **PostHog Cloud (EU):** Use `https://eu.i.posthog.com` if your PostHog account is on the EU data region.
- **Self-Hosted PostHog:** If your organization runs its own PostHog instance (for data residency or compliance reasons), set `host` to your own PostHog URL, for example `https://posthog.yourcompany.com`.

If the host is set incorrectly, events will fail to reach PostHog silently — you won't see errors in your agents or chats, but the LLM Analytics dashboard will show no data. Always confirm the host matches where you log in to view your PostHog project.

---

## What "Diagnostics Enabled" Does and Why It Matters

OpenClaw has a built-in diagnostics system that tracks the full lifecycle of each message — from the moment a user sends something to the moment a final response is delivered. This system emits a `message.processed` signal at the end of every successful or failed message cycle.

The PostHog plugin listens for that signal to produce the **`$ai_trace`** event — the high-level summary that ties together all the individual LLM calls and tool executions from a single user message into one record.

**With `diagnostics.enabled: true`:**
- You get `$ai_generation` events (one per LLM call) ✓
- You get `$ai_span` events (one per tool call) ✓
- You get `$ai_trace` events (one per completed message cycle) ✓
- The Traces view in PostHog shows complete, hierarchical trees ✓

**Without `diagnostics.enabled: true`:**
- You get `$ai_generation` events ✓
- You get `$ai_span` events ✓
- `$ai_trace` events are **not captured** ✗
- The Traces view in PostHog will be empty or incomplete ✗

---

## How Traces and Sessions Are Organized

To make events useful in PostHog's dashboards, the plugin groups them into **traces** and **sessions**:

- A **trace** is a collection of all events belonging to one message cycle. Every `$ai_generation` and `$ai_span` from processing a single user message shares the same trace ID, making it easy to see the full picture of what happened.

- A **session** tracks a user's ongoing conversation. The session ID connects multiple message cycles from the same user over time.

You control how traces are grouped via the `traceGrouping` setting:

| Setting | Behavior |
|---|---|
| `"message"` (default) | Each user message gets its own trace. Best for seeing per-message costs and latency. |
| `"session"` | All messages in an active conversation share one trace. Best for seeing the full conversation arc. |

Sessions automatically expire after a period of inactivity — by default 60 minutes — controlled by the `sessionWindowMinutes` setting. After the timeout, the next message from that user starts a fresh session.

---

## The Complete Data Flow, Step by Step

Here is what happens between a user sending a message and that activity appearing in your PostHog dashboard:

1. **User sends a message** to an OpenClaw-powered agent (via chat, API, or a connected channel like Telegram or Slack).
2. **OpenClaw processes the message**, routing it to the appropriate agent and starting a message cycle.
3. **The plugin catches `llm_input`** — it records the start time, assigns trace and span IDs, and saves the prompt (unless Privacy Mode is on).
4. **The LLM responds** — the plugin catches `llm_output`, calculates latency and cost, and immediately queues a `$ai_generation` event for PostHog.
5. **If the agent calls any tools**, the plugin catches each `after_tool_call` and queues a `$ai_span` event linked to the parent generation.
6. **Steps 3–5 may repeat** if the agent makes multiple LLM calls (e.g. in a multi-step reasoning loop) — all events share the same trace ID.
7. **OpenClaw emits `message.processed`** (if diagnostics are enabled) — the plugin queues a `$ai_trace` event summarizing the entire cycle.
8. **The posthog-node library batches and flushes** the queued events to your PostHog instance (up to every 20 events or every 10 seconds).
9. **Events appear in PostHog** under LLM Analytics → Traces, where you can explore latency, costs, token usage, and errors.

---

## Privacy Mode: Controlling What Gets Sent

If your application handles sensitive user content, you can enable `privacyMode: true`. When active, the plugin **still captures all operational metrics** — latency, token counts, model names, costs, error status — but strips out the actual text content: prompts, conversation messages, model outputs, and tool parameters/results are replaced with redacted placeholders before being sent to PostHog. This lets you monitor system health and performance without sending user data to a third-party analytics service.