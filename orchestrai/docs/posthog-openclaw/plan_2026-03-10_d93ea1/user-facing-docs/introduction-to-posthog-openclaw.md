# Introduction to @posthog/openclaw

**@posthog/openclaw** is the official PostHog LLM Analytics plugin for OpenClaw. It automatically captures every AI interaction happening inside your OpenClaw assistant — model calls, tool executions, and full conversation traces — and sends them to your PostHog project as structured events that appear in the [PostHog LLM Analytics dashboard](https://posthog.com/docs/llm-analytics).

If you run OpenClaw and want to understand how your AI assistant is performing — how much it costs, how fast it responds, which tools it uses, and where errors happen — this plugin gives you that visibility without any manual instrumentation.

---

## What OpenClaw Is, and What This Plugin Adds

OpenClaw is a personal AI assistant that you run on your own devices and connects to messaging channels you already use (WhatsApp, Telegram, Slack, Discord, and more). It handles conversations, executes tools, and routes requests through AI models like Claude and GPT.

Out of the box, OpenClaw does not send usage data anywhere. The @posthog/openclaw plugin bridges OpenClaw with PostHog's analytics platform. Once installed, every time your assistant generates a response or calls a tool, the plugin captures the event details and forwards them to PostHog automatically. You get a full audit trail of your assistant's activity in a visual analytics dashboard — without writing any tracking code yourself.

---

## Events the Plugin Captures

The plugin sends three types of structured events to PostHog, each prefixed with `$ai_` to work with PostHog's purpose-built LLM Analytics dashboard.

### AI Generations (`$ai_generation`)

Captured every time OpenClaw makes a call to a language model. Each event records:

- **Which model and provider** was used (for example, `gpt-4o` from `openai`, or `claude-3` from `anthropic`)
- **How long the call took** (latency in seconds)
- **How many tokens** were used for input and output, including any cache reads or cache creation tokens
- **What it cost** in USD, broken down into input cost, output cost, and total
- **Why generation stopped** — whether the model finished normally, hit a length limit, made a tool call, or encountered an error
- **The input messages and output choices** (suppressed when Privacy Mode is on — see below)
- **Identifiers** for tracing: a trace ID, span ID, session ID, channel name, and agent ID

### Tool Execution Spans (`$ai_span`)

Captured every time OpenClaw's agent calls a tool (such as running a browser action, executing a skill, or querying a calendar). Each event records:

- **The tool's name**
- **How long it took** to execute
- **Whether it succeeded or failed**, with the error message if it failed
- **The input parameters and output result** (suppressed in Privacy Mode)
- **Trace and span identifiers** that link this tool call to the generation that triggered it

### Conversation Traces (`$ai_trace`)

Captured when a full message cycle completes — from the moment a user message arrives to when the assistant's reply is sent. Each event records:

- **Total duration** of the entire message cycle
- **Accumulated token counts** across all model calls in that cycle
- **Whether the cycle ended in an error**, with the error message
- **The channel** the conversation happened on (for example, `telegram` or `slack`)
- **Trace and session identifiers**

> **Note:** Trace events (`$ai_trace`) require `diagnostics.enabled: true` in your OpenClaw configuration. Without this setting, individual generation and tool events still appear, but the end-to-end trace summary is not captured.

---

## How Data Appears in PostHog

Once the plugin is active, events flow into your PostHog project in real time. Open the **LLM Analytics** section of your PostHog dashboard (found at [posthog.com/llm-analytics](https://us.posthog.com/llm-analytics/traces)) to see:

- A **Traces view** showing each complete conversation cycle, its duration, token usage, and error status
- **Generation-level detail** showing individual model calls nested within each trace, including cost breakdowns and latency
- **Tool span detail** showing which tools were called, in what order, and how long each took
- Filtering by **channel**, **model**, **provider**, **session**, or **agent**

The three event types form a hierarchy: a trace contains one or more generations, and each generation may contain one or more tool spans. PostHog's dashboard uses the shared trace and span identifiers to link them into a unified view.

---

## What You Need Before Installing

Before installing this plugin, make sure you have the following in place:

| Requirement | Details |
|---|---|
| **An active PostHog project** | You need a PostHog account and a project API key (starts with `phc_`). Sign up at [posthog.com](https://posthog.com) if you don't have one. |
| **OpenClaw installed** | The plugin requires OpenClaw version 2026.2.0 or later. Follow the [OpenClaw getting started guide](https://docs.openclaw.ai/start/getting-started) if you haven't installed it yet. |
| **Node.js 20 or later** | The plugin requires Node.js version 20.0.0 or higher (`>=20.0.0`). Note that OpenClaw itself recommends Node.js 22, which exceeds this minimum. |

---

## Privacy Mode

If you'd rather not send conversation content to PostHog — for example, if your assistant handles sensitive personal information — you can enable Privacy Mode by setting `privacyMode: true` in the plugin configuration. With Privacy Mode on:

- Message content, prompts, and tool parameters are **never sent** to PostHog
- Token counts, latency, model names, cost data, and error status are **always captured**

You retain full performance and cost visibility without any conversation content leaving your system.

---

## Is This Plugin Right for You?

This plugin is a good fit if you:

- Run OpenClaw as a personal or team AI assistant and want visibility into costs, performance, and errors
- Already use PostHog for product analytics and want your AI assistant's activity in the same platform
- Need to understand which AI models or tools are being used most, and how much they cost
- Want error tracking for failed AI generations or tool calls without building custom logging

It is **not** needed if you only want to use OpenClaw without observability tooling, or if you use a different analytics platform (the plugin is PostHog-specific).

---

## Next Step

Once you've confirmed you have an active PostHog project and OpenClaw installed, proceed to the **Installation** guide to add the plugin with a single command and connect it to your PostHog project API key.