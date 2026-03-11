# How to Enable Privacy Mode

Privacy mode lets you use PostHog LLM Analytics without sending any message content, prompts, or AI responses to PostHog. This is ideal for teams handling sensitive conversations, operating in regulated industries, or working toward GDPR and data compliance goals.

---

## What Privacy Mode Does

When privacy mode is turned on, the PostHog plugin **stops sending the actual content** of your AI interactions. This includes:

- The messages and prompts sent to your AI model (inputs)
- The responses and generated text returned by the model (outputs)
- The parameters passed into tool calls
- The results returned from tool executions

Think of it as a content blackout — PostHog still knows that an AI interaction happened and how it performed, but it never sees what was said.

---

## What Is Still Sent to PostHog

Even with privacy mode enabled, PostHog continues to receive all **performance and operational data**:

| What Gets Sent | Description |
|---|---|
| **Model name** | Which AI model was used (e.g. `gpt-4o`, `claude-3`) |
| **Provider** | Which AI provider was used (e.g. `openai`, `anthropic`) |
| **Latency** | How long each request took, in seconds |
| **Token counts** | Input tokens, output tokens, and cache tokens |
| **Cost data** | Estimated cost in USD per request |
| **Stop reason** | Why the generation ended (e.g. `stop`, `length`, `error`) |
| **Error status** | Whether a request failed, and the error message |
| **Session & trace IDs** | Identifiers for grouping related interactions |
| **Channel & agent info** | Which channel (e.g. Telegram, Slack) and agent handled the request |

This means your LLM Analytics dashboard continues to show usage trends, costs, latency, and error rates — just without any of the actual conversation content.

---

## How to Enable Privacy Mode

Open your OpenClaw configuration file (`openclaw.json` or `openclaw.yaml`) and set `privacyMode` to `true` inside the PostHog plugin settings:

```jsonc
{
    "plugins": {
        "entries": {
            "posthog": {
                "enabled": true,
                "config": {
                    "apiKey": "phc_your_project_key",
                    "host": "https://us.i.posthog.com",
                    "privacyMode": true
                }
            }
        }
    }
}
```

That's all that's required. Privacy mode is off (`false`) by default, so you must explicitly set it to `true` to activate it.

After saving the file, restart your OpenClaw gateway for the change to take effect.

---

## When to Use Privacy Mode

Privacy mode is recommended in the following situations:

- **GDPR or data residency compliance** — You need to ensure that personal data in user messages never leaves your infrastructure or reaches a third-party analytics service.
- **Sensitive or confidential prompts** — Your AI workflows handle legally privileged, medical, financial, or otherwise sensitive information.
- **Regulated industries** — Healthcare, legal, finance, or government contexts where logging message content creates compliance risk.
- **Internal trust policies** — Your organization has policies prohibiting third-party storage of employee or customer conversations.

---

## Trade-offs to Consider

Enabling privacy mode is a deliberate trade-off between privacy protection and observability depth.

| | Privacy Mode OFF (default) | Privacy Mode ON |
|---|---|---|
| **Prompt & response content** | ✅ Sent to PostHog | 🚫 Not sent |
| **Tool inputs & outputs** | ✅ Sent to PostHog | 🚫 Not sent |
| **Token counts & costs** | ✅ Sent | ✅ Sent |
| **Latency & performance** | ✅ Sent | ✅ Sent |
| **Error details** | ✅ Sent | ✅ Sent |
| **Model & provider info** | ✅ Sent | ✅ Sent |
| **Full conversation replay** | ✅ Available in PostHog | 🚫 Not available |
| **Prompt debugging** | ✅ Available | 🚫 Not available |

With privacy mode on, you retain full visibility into **how** your AI is performing (speed, cost, reliability) but lose the ability to inspect **what** it is processing. Teams that need to debug prompt quality or trace specific conversation flows should consider keeping privacy mode off in development environments while enabling it in production.

---

## Quick Reference

| Setting | Value | Effect |
|---|---|---|
| `privacyMode: false` | Default | Full content captured and sent to PostHog |
| `privacyMode: true` | Opt-in | Content redacted; only metrics and metadata sent |