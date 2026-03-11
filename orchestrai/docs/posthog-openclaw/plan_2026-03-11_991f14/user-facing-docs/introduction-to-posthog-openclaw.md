# Introduction to PostHog OpenClaw

## What Is This Plugin?

**@posthog/openclaw** is a plugin that connects [OpenClaw](https://github.com/openclaw/openclaw) — an AI agent gateway — to [PostHog's LLM Analytics dashboard](https://posthog.com/docs/llm-analytics). Once installed, it automatically tracks every AI interaction happening through your OpenClaw gateway and sends that data to PostHog, where you can explore it through a purpose-built analytics dashboard.

In short: if you run AI agents or chatbots through OpenClaw and want to understand how they're performing, this plugin does the heavy lifting so you don't have to.

---

## Who Is This For?

This plugin is built for teams and developers who:

- Use OpenClaw as their AI agent or LLM gateway
- Want visibility into how their AI features are performing — which models are being called, how fast they respond, how much they cost, and whether they're failing
- Need to track full conversation flows across multiple messages and tool calls
- Want to use PostHog's LLM Analytics dashboard without writing custom tracking code

If you're already using OpenClaw to route LLM traffic, this plugin gives you instant observability with minimal setup.

---

## What Does It Capture?

The plugin automatically records three types of events every time your AI agents run:

### Every AI Model Call
Whenever OpenClaw makes a call to a language model (like GPT-4o or Claude), the plugin records a detailed snapshot of that interaction, including:

- **Which model and provider** was used (e.g., OpenAI, Anthropic)
- **How long it took** to respond
- **How many tokens** were used for input and output
- **What it cost** in USD — broken down by input and output
- **Why it stopped** (finished naturally, hit a length limit, triggered a tool, or errored)
- **What was sent and received** — the actual prompts and responses (can be disabled for privacy)
- **Session and trace identifiers** for linking events together

### Every Tool Execution
When an AI agent calls an external tool (like searching the web, running a calculation, or querying a database), the plugin captures:

- **The tool's name**
- **How long it took** to run
- **What inputs were passed** to the tool
- **What the tool returned**
- **Whether it succeeded or failed**
- **How it connects** to the parent AI model call that triggered it

### Full Conversation Traces
When a complete message cycle finishes — from the user sending a message to the agent fully responding — the plugin captures a rolled-up trace that includes:

- **Total time** for the entire interaction
- **Combined token usage** across all model calls in the trace
- **Success or failure** of the overall cycle
- **Which channel** the conversation happened on (e.g., Telegram, Slack)

---

## The LLM Analytics Dashboard

All of this data flows directly into PostHog's [LLM Analytics dashboard](https://us.posthog.com/llm-analytics/traces). This built-in dashboard is designed specifically for AI observability and lets you:

- **Browse individual traces** to see the full chain of model calls and tool executions for any given user interaction
- **Monitor costs** across models and providers over time
- **Track error rates and latency** to catch performance regressions
- **Analyze token usage** to optimize prompts and reduce spend
- **Compare models** to understand the trade-offs between different providers

You don't need to build any dashboards yourself — PostHog provides this out of the box, and the plugin feeds it the right data automatically.

---

## Privacy Controls

If your application handles sensitive information, you can enable **Privacy Mode**. When turned on, the actual content of prompts, responses, and tool parameters is never sent to PostHog. You still get all the operational metrics — token counts, latency, costs, error rates, model names — just without the message content. This makes it possible to use LLM Analytics even in privacy-sensitive or regulated environments.

---

## This Plugin vs. Manual Instrumentation

PostHog supports tracking LLM events from any application, but doing so manually means writing custom code to capture each event, calculate costs, measure latency, and structure everything in the right format.

This plugin handles all of that automatically for anyone already using OpenClaw:

| Approach | Setup Effort | Coverage | Maintenance |
|---|---|---|---|
| **This plugin** | Install one command, add config | Automatic — every call, tool, and trace | Maintained by PostHog |
| **Manual PostHog instrumentation** | Write custom tracking code for every event | Only what you explicitly track | Your team maintains it |

If you're using OpenClaw, this plugin is the faster and more complete path to LLM observability. If you're not using OpenClaw, you would instrument PostHog's `$ai_*` events directly from your application code.

---

## Next Steps

Ready to get started? The plugin installs with a single command and requires only your PostHog project API key to begin capturing data:

```bash
openclaw plugins install @posthog/openclaw
```

Continue to the **Installation & Configuration** guide to connect the plugin to your PostHog project and start seeing your AI agent activity in the LLM Analytics dashboard.