# What Is the @posthog/openclaw Plugin — and Who Is It For?

## Overview

**OpenClaw** is a personal AI assistant you run on your own devices. It connects to the messaging apps you already use — WhatsApp, Telegram, Slack, Discord, Google Chat, Signal, iMessage, Microsoft Teams, and more — and acts as a single, always-on AI companion across all of them.

The `@posthog/openclaw` plugin bridges OpenClaw with **PostHog**, a product analytics platform. Once connected, every AI interaction happening inside OpenClaw — every response the assistant generates, every tool it runs, every back-and-forth conversation — is automatically captured and sent to PostHog as structured analytics events. Those events then power PostHog's **LLM Analytics dashboard**, giving you a live window into how your AI assistant is performing.

---

## What the Plugin Does

When you add the PostHog plugin to your OpenClaw setup, it silently observes the assistant's activity and records it in PostHog using a standard set of AI-specific event types (known internally as `$ai_*` events). Here is what gets tracked:

| What Happens in OpenClaw | What Gets Recorded in PostHog |
|---|---|
| The assistant generates a reply | An LLM generation event, including the model used and response details |
| The assistant runs a tool (browser, calendar, etc.) | A tool execution event with timing and outcome |
| A multi-turn conversation unfolds | A full conversation trace linking all turns together |

These events flow automatically — you do not have to add tracking code to your conversations or configure anything per-message.

---

## What You Can See in PostHog's LLM Analytics Dashboard

After the plugin is active and events are flowing, PostHog's **LLM Analytics dashboard** gives you answers to questions like:

- **How often is the assistant being used?** See total conversations and message volume over time.
- **Which AI models are being called most?** Compare usage across Claude, GPT, and any other models you have configured.
- **How long do responses take?** Spot slowdowns or latency spikes in your assistant's replies.
- **Are there errors or failures?** Identify when the assistant fails to respond or a tool execution goes wrong.
- **What does a full conversation look like?** Drill into individual traces to replay exactly what the assistant saw and did.

This kind of visibility — knowing not just *that* your assistant responded, but *how well* and *how often* — is what the PostHog team calls **LLM observability**.

---

## Who This Plugin Is For

The `@posthog/openclaw` plugin is designed for people who want more than just a working AI assistant — they want to *understand* it.

**This plugin is a great fit if you:**

- Run OpenClaw personally or for a small team and want to track usage patterns over time
- Are experimenting with different AI models and want data to help you choose the best one
- Want to catch problems early — like the assistant failing on certain types of requests — before they become habits
- Care about cost awareness: knowing how many AI calls are being made helps you stay on top of usage
- Want a real dashboard rather than digging through log files

**You probably do not need this plugin if** you are a casual user who just wants the assistant to answer messages and has no interest in analytics or performance tracking.

---

## How the Pieces Fit Together

The plugin sits between OpenClaw and PostHog, acting as a bridge:

```
You send a message
        │
        ▼
  OpenClaw Gateway          ← your personal AI assistant runtime
  (processes your request,
   calls the AI model,
   runs tools)
        │
        ▼
  @posthog/openclaw plugin  ← captures what just happened
        │
        ▼
  PostHog API               ← receives structured $ai_* events
        │
        ▼
  LLM Analytics Dashboard   ← where you see charts, traces, and insights
```

**OpenClaw** is the assistant itself — the brains, the channel connections, the tools.
**posthog-node** is PostHog's standard JavaScript library for sending events to PostHog.
**@posthog/openclaw** is the thin layer that knows how to translate OpenClaw's internal activity into the `$ai_*` event format that PostHog's LLM Analytics dashboard understands.

Without the plugin, OpenClaw works perfectly — you just have no visibility into what it is doing over time. With the plugin, every interaction becomes a data point you can learn from.

---

## The Value in Plain Terms

Running an AI assistant without observability is a little like driving without a dashboard — things work until they do not, and you only find out after the fact. The `@posthog/openclaw` plugin gives you that dashboard: a clear, real-time view of your assistant's activity, health, and patterns, all inside the PostHog interface you may already use for your other products.

If you want to go beyond "it works" and start asking "how well does it work, and how can I improve it?" — this plugin is where you start.