# Tracking LLM Generation Events in PostHog

> **Note:** OpenClaw does not include a built-in PostHog integration in its current codebase. This guide explains how OpenClaw captures LLM generation data through its plugin hook system, and how you can connect that data to PostHog's LLM Analytics dashboard using a custom plugin.

---

## What Is a "Generation"?

In OpenClaw, a **generation** refers to a single, complete round-trip to an AI model — starting from the moment your message is sent to the model, through the full response being returned. Every time the assistant calls a model (such as Claude or GPT), that counts as one generation.

Each generation captures:

- **The input** — the messages and system prompt sent to the model
- **The output** — the model's full response
- **Metadata** — which model was used, how many tokens were consumed, and how long the call took

---

## How OpenClaw Captures Generation Data

OpenClaw fires two plugin hooks around every model call. These hooks give you structured access to all generation data automatically — no manual instrumentation needed.

### The Two Generation Hooks

| Hook | When It Fires | What It Contains |
|---|---|---|
| `llm_input` | Before the model is called | The exact request payload: messages, system prompt, model name, parameters |
| `llm_output` | After the model responds | The full response: content, token usage (input + output), finish reason, latency |

Both hooks run in parallel (fire-and-forget), meaning they do not block the assistant's response.

---

## Data Available in Each Generation

### From the `llm_input` hook
- **Model identifier** — e.g., `anthropic/claude-opus-4-6` or `openai/gpt-4o`
- **System prompt** — the instructions sent to the model
- **Conversation messages** — the full message history included in the call
- **Session ID** — which conversation session triggered this generation
- **Agent context** — workspace and routing information

### From the `llm_output` hook
- **Response content** — the text the model returned
- **Token counts** — input tokens consumed and output tokens generated
- **Finish reason** — why the model stopped (e.g., end of turn, tool call)
- **Latency** — derived from timestamps around the call
- **Model used** — confirmed model identifier from the response

> **Cost tracking:** OpenClaw does not calculate cost natively. If you want cost data in PostHog, you can compute it in your plugin using published token pricing for each model.

---

## Sending Generation Data to PostHog

To send generation events to PostHog, create a plugin that listens to the `llm_output` hook and calls PostHog's `$ai_generation` event.

### Step 1: Create a Plugin

In your OpenClaw workspace skills directory (`~/.openclaw/workspace/skills/`), create a new skill folder containing a plugin that uses both hooks:

```javascript
// Example plugin handler for llm_output
export async function onLlmOutput(event, ctx) {
  const { response, usage } = event;

  await posthog.capture({
    distinctId: ctx.sessionId,
    event: '$ai_generation',
    properties: {
      $ai_model: ctx.model,
      $ai_input_tokens: usage?.inputTokens,
      $ai_output_tokens: usage?.outputTokens,
      $ai_latency: event.latencyMs,
      $ai_trace_id: ctx.sessionId,
    }
  });
}
```

### Step 2: Register the Hook

In your plugin manifest, register for the `llm_output` hook:

```json
{
  "hooks": [
    { "hookName": "llm_output", "handler": "onLlmOutput" },
    { "hookName": "llm_input",  "handler": "onLlmInput" }
  ]
}
```

---

## Viewing Generation Events in PostHog

Once your plugin is sending events, you can explore them in PostHog:

1. **Open your PostHog project** and navigate to the **LLM Analytics** section (found under **Products** in the left sidebar).
2. **Select the Generations tab** — this shows a timeline of all `$ai_generation` events captured from your OpenClaw assistant.
3. Each row represents one model call and shows the model name, token usage, latency, and timestamp.

### Key Metrics Available

| Metric | Description |
|---|---|
| Total generations | Number of model calls over a time period |
| Average latency | How long model calls take on average |
| Token usage | Input and output tokens consumed |
| Generations by model | Breakdown across different models |
| Generations by user/session | Usage per conversation or user |

---

## Filtering and Segmenting Generations

In the PostHog LLM Analytics dashboard, use the **filter bar** to narrow down generations:

- **Filter by model** — select `$ai_model` and choose a specific model (e.g., only Claude calls, or only GPT-4o calls)
- **Filter by session** — use `$ai_trace_id` (mapped to `sessionId` in the example above) to see all generations from a single conversation
- **Filter by user** — if you pass a user identifier as `distinctId`, you can view all generations for a specific person
- **Add custom properties** — pass any extra data from the `ctx` object (such as channel name, agent workspace, or session type) as additional PostHog properties to enable custom segmentation

To create a **custom segment**, click **Add filter** in the dashboard and select any property you included in your `$ai_generation` event.

---

## Privacy Mode: What Data Is Omitted

OpenClaw supports a `privacyMode` setting. When privacy mode is enabled on your gateway, the following data **should be excluded** from what you forward to PostHog:

| Data Type | With Privacy Mode |
|---|---|
| Message content (prompts) | ❌ Do not forward |
| Response content | ❌ Do not forward |
| System prompt text | ❌ Do not forward |
| Model identifier | ✅ Safe to forward |
| Token counts | ✅ Safe to forward |
| Latency | ✅ Safe to forward |
| Session ID (opaque) | ✅ Safe to forward |

In your plugin, check the gateway configuration for privacy mode before including message content in the PostHog event payload. Only forward aggregate metadata (model, tokens, latency) when privacy mode is active.

---

## Quick Reference: Standard `$ai_generation` Fields

These are the standard PostHog LLM Analytics fields to use when building your plugin:

| PostHog Property | OpenClaw Source | Description |
|---|---|---|
| `$ai_model` | `ctx.model` | Model identifier |
| `$ai_input_tokens` | `event.usage.inputTokens` | Tokens in the prompt |
| `$ai_output_tokens` | `event.usage.outputTokens` | Tokens in the response |
| `$ai_latency` | Computed from hook timing | Response time in seconds |
| `$ai_trace_id` | `ctx.sessionId` | Links generations to a session |
| `$ai_base_url` | Provider endpoint | API base URL (optional) |

---

## Further Reading

- [OpenClaw Plugin SDK](https://docs.openclaw.ai/tools/skills) — how to build and install custom plugins
- [Usage Tracking](https://docs.openclaw.ai/concepts/usage-tracking) — OpenClaw's built-in token and cost tracking
- [PostHog LLM Analytics](https://posthog.com/docs/ai-engineering/llm-observability) — PostHog's official LLM observability documentation
- [Gateway Configuration](https://docs.openclaw.ai/gateway/configuration) — full list of gateway settings including privacy options