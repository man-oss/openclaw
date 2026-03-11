# Protecting Sensitive Conversations with Privacy Mode

OpenClaw includes optional analytics to help you understand how your AI assistant is performing — things like how fast it responds, which model you're using, and how many tokens each conversation uses. Privacy Mode gives you a simple way to keep the actual words of your conversations completely private, while still benefiting from these performance insights.

## What Is Privacy Mode?

When OpenClaw sends usage data to its analytics service (PostHog), it can include two types of information:

- **Content** — the actual text of your messages sent to the AI, and the AI's responses back to you
- **Metadata** — anonymous operational details like which AI model was used, how long a response took, how many tokens were consumed, and estimated costs

**Privacy Mode stops content from ever leaving your system.** When enabled, your prompts and the AI's responses stay entirely on your own device. Only the anonymous metadata is reported — no one reading the analytics data can see what you or the AI actually said.

## What Data Is Still Collected in Privacy Mode?

Even with Privacy Mode turned on, the following non-sensitive metadata continues to be sent, so you can still monitor your assistant's health and costs:

| Data Point | Example |
|---|---|
| AI model used | `anthropic/claude-opus-4-6` |
| Input token count | `1,450 tokens` |
| Output token count | `320 tokens` |
| Cache token counts | Cache reads/writes |
| Response time | `2,340 ms` |
| Estimated cost | `$0.04` |
| Session identifiers | Anonymous session IDs |

**What is never sent with Privacy Mode on:**
- The text of your messages or instructions to the AI
- The AI's response text
- Any other message content

## Who Should Use Privacy Mode?

Privacy Mode is strongly recommended for teams and individuals in these situations:

- **Healthcare** — conversations that involve patient information, symptoms, or medical records
- **Finance** — prompts containing account details, financial analysis, or client data
- **Legal** — privileged communications, case details, or confidential client matters
- **Enterprise with PII** — any business workflow where prompts might contain names, email addresses, employee data, or other personally identifiable information
- **Regulated industries** — organizations subject to HIPAA, GDPR, SOC 2, or similar compliance requirements where third-party data sharing must be minimized

If your AI assistant helps with tasks where the actual conversation text is sensitive — even occasionally — turning on Privacy Mode is the safe default.

## How to Enable Privacy Mode

Privacy Mode is turned off by default. To enable it, add a single setting to your OpenClaw configuration file.

**Step 1: Open your configuration file**

Your configuration file is located at `~/.openclaw/openclaw.json`. Open it in any text editor.

**Step 2: Add the `privacyMode` setting**

Add `privacyMode: true` to your configuration. Here is an example of what a complete configuration with Privacy Mode looks like:

```json5
{
  agent: {
    model: "anthropic/claude-opus-4-6",
  },
  privacyMode: true,
}
```

**Step 3: Restart the Gateway**

For the change to take effect, restart the Gateway. You can do this by sending the `/restart` command in any connected chat, or by running the following in your terminal:

```bash
openclaw gateway --port 18789
```

If you are running the Gateway as a background service, restart it using your system's service manager, or use the macOS menu bar app's restart option.

## Verifying Privacy Mode Is Active

After enabling Privacy Mode, you can confirm it is working correctly by checking your PostHog analytics dashboard:

1. Open your PostHog project and navigate to the Events section
2. Look at recent events triggered by OpenClaw (typically labeled as model usage or session events)
3. Inspect the event properties — you should see fields like `model`, `inputTokens`, `outputTokens`, `durationMs`, and `costUsd`
4. Confirm that there are **no** fields containing prompt text, message content, or response text

If you see any message content in the event properties, double-check that:
- You saved the configuration file correctly with `privacyMode: true`
- The Gateway was fully restarted after the change (not just reloaded)
- You are looking at events created *after* the restart

## Quick Reference

| Setting | Value | Behavior |
|---|---|---|
| `privacyMode` not set | (default off) | All data including message content is sent to analytics |
| `privacyMode: false` | Off | Same as default — content is included in analytics |
| `privacyMode: true` | **On** | Message content is stripped; only metadata is sent |

---

For more configuration options, see the [full configuration reference](https://docs.openclaw.ai/gateway/configuration). For general security guidance on running OpenClaw safely, see the [Security guide](https://docs.openclaw.ai/gateway/security).