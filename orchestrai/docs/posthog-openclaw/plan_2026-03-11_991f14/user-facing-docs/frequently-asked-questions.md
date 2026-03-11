# Frequently Asked Questions

## General

### What does this plugin do?

The PostHog OpenClaw plugin automatically tracks your AI assistant's activity — every LLM call, tool execution, and conversation — and sends that data to your PostHog project. This gives you a ready-made analytics dashboard showing how your AI is performing, how much it costs, and how users are interacting with it.

---

### Does the plugin work with a self-hosted PostHog instance?

Yes. By default the plugin sends data to PostHog's US cloud (`https://us.i.posthog.com`), but you can point it at any PostHog instance — including self-hosted ones — by setting the **Host** option in your configuration:

```jsonc
"host": "https://your-posthog.example.com"
```

Simply replace the value with the URL of your own PostHog installation.

---

### What LLM providers and models are supported?

The plugin works with **any provider and model that OpenClaw supports**. It does not have its own allowlist of providers or models — it reads the provider name and model name directly from each LLM call (for example `openai` / `gpt-4o`, or `anthropic` / `claude-3`) and records them automatically. If OpenClaw can call it, this plugin can track it.

---

### Can I use the plugin without enabling diagnostics?

Yes, partially. Most events — individual LLM calls (`$ai_generation`) and tool executions (`$ai_span`) — are captured regardless of your diagnostics setting.

However, **conversation-level trace summaries** (`$ai_trace`) require diagnostics to be turned on in your OpenClaw config:

```jsonc
"diagnostics": {
    "enabled": true
}
```

If diagnostics are off, you will still see per-call and per-tool data in PostHog, but you won't get the rolled-up trace view that shows the full cost and duration of an entire message cycle.

---

### Is there any performance overhead from the plugin?

The plugin is designed to be lightweight. It listens to events that OpenClaw already emits internally (LLM input/output, tool calls, message completion) and sends data to PostHog asynchronously in the background. Your AI assistant's response times are not blocked by analytics delivery.

---

### Does the plugin work in serverless or edge environments?

The plugin requires **Node.js version 20 or higher**. It is built as a standard Node.js ESM package and relies on the OpenClaw gateway process, which itself runs as a persistent Node.js server. Because of this, it is not designed for serverless functions or edge runtimes (such as Cloudflare Workers or AWS Lambda). It is intended to run alongside a long-lived OpenClaw gateway instance.

---

### Will my users' messages and prompts be stored in PostHog?

By default, yes — the content of LLM inputs and outputs is included in the events sent to PostHog so you can inspect conversations in your dashboard.

If you do not want message content sent to PostHog, turn on **Privacy Mode**:

```jsonc
"privacyMode": true
```

With Privacy Mode enabled, all prompt text, message content, and tool parameters are stripped before any data leaves your server. Only non-content metadata — token counts, latency, model name, provider, cost, and error status — is sent to PostHog.

---

## Viewing Your Data

### How do I see my data in the PostHog LLM Analytics dashboard?

Once the plugin is installed and configured:

1. Open your PostHog project in a browser.
2. Navigate to the **LLM Analytics** section (available at the **Traces** page within LLM Analytics).
3. Send a message through your OpenClaw-powered assistant.
4. Events will appear in PostHog within seconds.

The dashboard shows individual LLM generations, tool calls, and full conversation traces — including token usage, cost breakdowns, latency, and any errors.

---

### What data appears in the dashboard?

Every LLM call produces a record that includes:

- **Model and provider** (e.g. GPT-4o from OpenAI)
- **Latency** — how long the call took
- **Token counts** — input and output tokens
- **Cost** — input cost, output cost, and total in USD
- **Stop reason** — whether the model stopped normally, hit a length limit, called a tool, or errored
- **Session and trace identifiers** — for grouping conversations

Tool calls include the tool name, how long it ran, and whether it succeeded or failed.

Conversation traces (when diagnostics are enabled) roll up all of the above into a single summary per message cycle.

---

### What is the difference between "message" and "session" trace grouping?

This is controlled by the **Trace Grouping** setting in your config:

- **`message`** (default): Each individual message exchange gets its own trace. This makes it easy to analyze one question-and-answer at a time.
- **`session`**: All LLM calls that happen within a session window (default: 60 minutes of inactivity) are grouped into a single trace. This is useful if you want to see the total cost and flow of an entire conversation.

You can adjust the inactivity window with the **Session Window Minutes** setting (default is `60` minutes).

---

## Setup & Configuration

### What is the minimum required configuration?

The only required setting is your **PostHog project API key**:

```jsonc
{
    "plugins": {
        "entries": {
            "posthog": {
                "enabled": true,
                "config": {
                    "apiKey": "phc_your_project_key"
                }
            }
        }
    }
}
```

Everything else has a sensible default and is optional.

---

### How do I install the plugin?

Run the following command in your terminal:

```bash
openclaw plugins install @posthog/openclaw
```

Then add the `posthog` entry to your OpenClaw configuration file (`openclaw.json` or `openclaw.yaml`) with your PostHog API key.

---

### Where do I find my PostHog API key?

Your project API key (it starts with `phc_`) is found in your PostHog project settings under **Project API Key**. Use this as the value for `apiKey` in the plugin configuration.

---

### Can I temporarily disable the plugin without removing it?

Yes. Set `"enabled": false` in the plugin's config entry:

```jsonc
"posthog": {
    "enabled": false,
    "config": { ... }
}
```

Set it back to `true` to resume tracking.