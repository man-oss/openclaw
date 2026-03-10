# Enabling Privacy Mode in OpenClaw

> **Note:** OpenClaw's analytics pipeline uses a `diagnostics` configuration block to control what telemetry data is collected and emitted. The source code defines a `privacyMode` concept through the `diagnostics` settings — specifically through options that suppress prompt content from being included in trace and cache data. This guide covers the settings available to keep sensitive conversation content out of diagnostic output.

---

## What Is Privacy Mode?

OpenClaw includes a built-in diagnostics and tracing system that can record information about how the assistant is performing — things like model usage, token counts, message timing, and session state. By default, these diagnostics do **not** include your actual message content.

However, certain optional diagnostic features — such as cache tracing — can be configured to include message content, system prompts, or raw inputs. **Privacy mode** refers to the practice of deliberately keeping those content-capturing options disabled, so that no conversation text, user prompts, or AI responses are ever written to diagnostic output.

---

## What Data Is Sent (Diagnostics Events)

When diagnostics are enabled (`diagnostics.enabled: true`), the following types of events are tracked. **None of these include prompt text or AI responses by default:**

| Event Type | What It Contains |
|---|---|
| `model.usage` | Token counts (input, output, cache), cost in USD, duration in milliseconds, model name, provider name, session key |
| `message.processed` | Channel name, duration, outcome (completed/skipped/error), session key |
| `message.queued` | Channel, queue depth, session key |
| `session.state` | Session state transitions (idle/processing/waiting), queue depth |
| `webhook.received` / `webhook.processed` | Channel name, update type, duration |
| `diagnostic.heartbeat` | Aggregate webhook counts, active/waiting/queued session counts |

**At no point do these standard events include:** the text of your messages, the AI's responses, your system prompt, or any user-identifiable content from your conversations.

---

## What Gets Suppressed in Privacy Mode

The one place where prompt content *can* appear in diagnostic output is the **cache trace** feature (`diagnostics.cacheTrace`). This optional feature can log full prompt contents to a file for debugging LLM cache behavior.

When operating in privacy mode, you ensure that `cacheTrace` is either disabled or configured with all content options set to `false`:

| Setting | What It Controls |
|---|---|
| `diagnostics.cacheTrace.enabled` | Master switch — set to `false` to disable entirely |
| `diagnostics.cacheTrace.includeMessages` | Whether conversation messages are written to the trace file |
| `diagnostics.cacheTrace.includePrompt` | Whether the full prompt sent to the LLM is written |
| `diagnostics.cacheTrace.includeSystem` | Whether the system prompt is written |

---

## How to Enable Privacy Mode

Open your configuration file at `~/.openclaw/openclaw.json` and ensure the `diagnostics` section is configured as follows:

**Minimal privacy-safe configuration (diagnostics fully disabled):**

```json5
{
  // No diagnostics block needed — disabled by default
}
```

**If you need diagnostics for performance monitoring but want privacy mode:**

```json5
{
  diagnostics: {
    enabled: true,
    // cacheTrace is intentionally absent or explicitly disabled
    cacheTrace: {
      enabled: false,
      includeMessages: false,
      includePrompt: false,
      includeSystem: false,
    },
  },
}
```

**If you also use OpenTelemetry (OTEL) exports, privacy mode applies the same way** — OTEL traces cover timing and token counts, not message content:

```json5
{
  diagnostics: {
    enabled: true,
    otel: {
      enabled: true,
      endpoint: "https://your-collector:4318",
      // Spans contain latency and token data, not conversation text
    },
    cacheTrace: {
      enabled: false, // Keep this off in privacy mode
    },
  },
}
```

---

## When to Use Privacy Mode

Enable privacy mode in any of the following situations:

- **Regulated industries** — Healthcare (HIPAA), finance (SOC 2, PCI-DSS), legal, or government environments where conversation content must not be written to any log or trace file.
- **Personally Identifiable Information (PII) in prompts** — If users send names, addresses, IDs, health data, or financial information through the assistant.
- **Internal tooling policies** — Your organization's security policy prohibits logging AI inputs/outputs to local files or third-party telemetry endpoints.
- **Multi-user or group deployments** — When the assistant operates in shared channels (Slack, Discord, Teams) where multiple users' messages flow through the system.
- **Legal holds or data minimization requirements** — When you need to demonstrate that sensitive data was never persisted outside the conversation itself.

---

## How to Verify Privacy Mode Is Working

After applying your configuration, follow these steps to confirm that conversation content is absent from all diagnostic output:

**1. Restart the Gateway to apply the new config:**

```bash
openclaw gateway --port 18789
```

Or if running as a daemon:

```bash
openclaw gateway restart
```

**2. Check that cacheTrace is not producing files:**

The cache trace feature writes to a file path configured in `diagnostics.cacheTrace.filePath`. If `enabled: false`, no file will be created or written to. Confirm the file does not exist or is not growing:

```bash
# Replace with your configured path if set
ls ~/.openclaw/cache-trace.jsonl 2>/dev/null && echo "FILE EXISTS — check your config" || echo "No trace file — privacy mode active"
```

**3. Check diagnostic event content via the Control UI:**

Navigate to the Dashboard in the OpenClaw Control UI (served from the Gateway, typically at `http://127.0.0.1:18789`). The diagnostics panel displays emitted events. Confirm that no event payload shows message text, prompt content, or AI response strings — only token counts, model names, timing, and outcome codes.

**4. Run the doctor command to surface configuration issues:**

```bash
openclaw doctor
```

This checks for misconfigured or risky settings and will surface any diagnostic options that could expose sensitive data.

---

## Summary of Privacy-Safe Defaults

| Setting | Privacy-Safe Value | Notes |
|---|---|---|
| `diagnostics.enabled` | `false` (default) or `true` | Safe either way for content — only metadata is tracked |
| `diagnostics.cacheTrace.enabled` | `false` | **Must be `false` in privacy mode** |
| `diagnostics.cacheTrace.includeMessages` | `false` | Suppresses conversation turns |
| `diagnostics.cacheTrace.includePrompt` | `false` | Suppresses raw LLM input |
| `diagnostics.cacheTrace.includeSystem` | `false` | Suppresses system prompt |
| `diagnostics.otel.enabled` | Safe to enable | Spans contain timing/tokens, not content |

With `diagnostics.cacheTrace.enabled` set to `false` (or the entire `cacheTrace` block omitted), OpenClaw never writes prompt text or AI responses to any diagnostic output. Token counts, model names, latency, and event types continue to flow normally for operational monitoring.