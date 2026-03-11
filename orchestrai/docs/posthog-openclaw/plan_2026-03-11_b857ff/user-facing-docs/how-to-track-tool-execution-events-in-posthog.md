# Tracking Tool Execution Events in PostHog

OpenClaw's plugin system fires events every time the AI agent uses a tool — before the tool runs and after it completes. By writing a small plugin that listens to those events, you can forward each tool call to PostHog and start seeing exactly which tools your agent uses, how often, how long they take, and whether they succeed or fail.

---

## What Are "Tool Executions"?

When you send the AI agent a message, it often needs to do things beyond just generating text — it might browse a website, run a shell command, read a file, or call a custom skill. Each of these actions is a **tool execution**: a discrete function call the AI decides to make during a run.

OpenClaw fires two events around every tool execution:

| Moment | What it tells you |
|--------|------------------|
| **Before the tool runs** | Which tool was chosen and what parameters were passed to it |
| **After the tool runs** | The result (or error), and exactly how long it took |

These two events together give you a complete picture of every tool invocation.

---

## The Events Available to Capture

### Before a Tool Runs — `before_tool_call`

Fires the moment the agent decides to call a tool, before execution begins.

| Field | Description |
|-------|-------------|
| `toolName` | The name of the tool being called (e.g., `bash`, `browser_navigate`, `read`) |
| `params` | The input parameters the agent passed to the tool |

Context also available: `agentId`, `sessionKey`.

### After a Tool Runs — `after_tool_call`

Fires once the tool has finished (successfully or not).

| Field | Description |
|-------|-------------|
| `toolName` | The name of the tool that was called |
| `params` | The input parameters that were used |
| `result` | The tool's output (omitted in privacy mode — see below) |
| `error` | Error message if the tool failed |
| `durationMs` | How long the tool took to run, in milliseconds |

Context also available: `agentId`, `sessionKey`.

The `after_tool_call` event is the most useful for PostHog dashboards, since it includes timing and outcome data alongside the tool name.

---

## How Tool Executions Relate to a Generation

Every tool execution happens **inside a generation run**. A single message from a user can trigger multiple tool calls in sequence as the agent works through a task. The `sessionKey` field (available in the event context) links each tool call back to the conversation session. The `agentId` field identifies which agent ran the tool.

When you send both `llm_output` events (for the overall AI response) and `after_tool_call` events to PostHog, you can correlate them in PostHog using `sessionKey` as the shared identifier — letting you see which tool calls happened within which generation.

---

## Capturing Tool Events in a Plugin

OpenClaw's plugin system lets you register a handler for `after_tool_call` (and optionally `before_tool_call`) that runs every time a tool is invoked. Here is a complete example plugin that sends tool execution data to PostHog:

```javascript
// posthog-tools-plugin.js
// Place in ~/.openclaw/workspace/skills/ or load via plugin config

export default {
  id: "posthog-tools-tracker",
  name: "PostHog Tool Tracker",

  register(api) {
    const posthogApiKey = "your_posthog_project_api_key";
    const posthogHost = "https://app.posthog.com"; // or your self-hosted URL

    api.on("after_tool_call", async (event, ctx) => {
      // event.toolName   — which tool ran
      // event.params     — inputs (omitted if privacyMode is on)
      // event.result     — output (omitted if privacyMode is on)
      // event.error      — error string if the tool failed
      // event.durationMs — execution time in milliseconds
      // ctx.sessionKey   — links this to the parent conversation
      // ctx.agentId      — which agent ran the tool

      await fetch(`${posthogHost}/capture/`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          api_key: posthogApiKey,
          event: "$ai_tool_call",
          distinct_id: ctx.agentId ?? "openclaw-agent",
          properties: {
            $ai_tool_name: event.toolName,
            $ai_input: event.params,
            $ai_output: event.result,
            $ai_error: event.error,
            $ai_latency: event.durationMs ? event.durationMs / 1000 : undefined,
            $ai_trace_id: ctx.sessionKey,
            success: !event.error,
          },
        }),
      });
    });
  },
};
```

> **Tip:** Use `$ai_trace_id` set to `ctx.sessionKey` so PostHog can group all tool calls from the same conversation together.

---

## Privacy Mode and What Gets Captured

When **privacy mode** is enabled in your OpenClaw configuration, the `result` field on `after_tool_call` events will be omitted before your plugin handler ever sees it. The `params` (inputs) may also be redacted depending on your privacy settings.

**In privacy mode:**
- `event.result` → not present (not sent to PostHog)
- `event.params` → may be redacted
- `event.toolName`, `event.durationMs`, `event.error` → always present

**With privacy mode off (default):**
- All fields are available, including full tool inputs and outputs

This means you can always track **which tools run** and **how long they take**, regardless of privacy mode. Full input/output content is only available when privacy mode is off.

---

## Viewing Tool Execution Data in PostHog

Once your plugin is running and events are flowing to PostHog, navigate to your PostHog project to explore the data.

### Find Tool Call Events

Go to the **Events** section and filter by event name `$ai_tool_call`. You will see a live stream of every tool execution from your agent.

### Useful Properties to Filter or Group By

| PostHog Property | What It Shows |
|-----------------|---------------|
| `$ai_tool_name` | The name of the tool that was called |
| `$ai_latency` | How long the tool took (in seconds) |
| `$ai_error` | Error message — filter for non-null to find failures |
| `$ai_trace_id` | Session identifier — group by this to see all tool calls in one conversation |
| `success` | `true` or `false` — quickly filter successful vs. failed calls |

### Recommended Insights to Build

**Tool usage frequency** — Create a "Trends" chart grouped by `$ai_tool_name` to see which tools your agent uses most.

**Tool failure rate** — Build a chart filtered to events where `success = false`, grouped by `$ai_tool_name`, to identify which tools fail most often.

**Tool latency** — Use a breakdown by `$ai_tool_name` with the average of `$ai_latency` to find slow tools.

**Per-session tool trace** — Filter events by a specific `$ai_trace_id` (session key) to replay exactly which tools an agent called during a single conversation, in order.

### Correlating with Generation Events

If you also capture `llm_output` events (from the `llm_output` hook), both generation events and tool call events will share the same `$ai_trace_id` / `sessionKey`. In PostHog you can filter all events by a specific session key to see the full timeline: when the AI generated text, when it called tools, what each tool returned, and how long everything took.

---

## Quick Reference

| Want to know… | Look at… |
|---------------|----------|
| Which tools ran in a session | Filter `$ai_tool_call` events by `$ai_trace_id` |
| Which tool is used most | Group `$ai_tool_call` by `$ai_tool_name` in Trends |
| Which tools are slowest | Average `$ai_latency` grouped by `$ai_tool_name` |
| Which tools fail most | Filter `success = false`, group by `$ai_tool_name` |
| What inputs a tool received | Check `$ai_input` on a specific event |
| Full conversation trace | Filter by `$ai_trace_id` = your session key |