# Capturing LLM Generations, Tool Executions, and Traces in OpenClaw

OpenClaw provides a built-in plugin hook system that automatically fires events at every meaningful moment in the AI assistant's lifecycle — when messages arrive, when the LLM is called, when tools run, and when sessions begin or end. You can attach listeners to any of these events without modifying OpenClaw's core code.

---

## How Event Capture Works

OpenClaw's Gateway acts as the central control plane for all AI activity. As the agent processes messages, every significant action emits a **lifecycle event** through the plugin hook system. Plugins register handlers for the events they care about, and OpenClaw calls those handlers automatically — in parallel for observation-only events, and sequentially for events that can modify behavior.

To capture events, you write a plugin that calls `api.on(hookName, handler)` for each event type you want to observe. The hook runner manages priority ordering and error isolation — a failed handler does not break the agent loop.

---

## Enabling Event Capture: The Plugin Hook System

Before any events reach your plugin, the plugin must be loaded by OpenClaw. Add your plugin to `~/.openclaw/openclaw.json`:

```json5
{
  agent: {
    model: "anthropic/claude-opus-4-6",
  },
  plugins: [
    {
      path: "./my-analytics-plugin",
    },
  ],
}
```

A minimal plugin that begins observing events looks like this:

```js
// my-analytics-plugin/index.js
export default function (api) {
  // Register handlers for each event type you want to capture
  api.on("llm_output", (event, ctx) => {
    console.log("LLM generation captured:", event.model, event.usage);
  });

  api.on("after_tool_call", (event, ctx) => {
    console.log("Tool executed:", event.toolName, event.durationMs + "ms");
  });
}
```

---

## The Three Core Event Categories

### 1. LLM Generation Events

These events fire every time OpenClaw sends a request to an AI model and receives a response.

**`llm_input`** — fires immediately before the LLM call is made.

| Property | Description |
|---|---|
| `runId` | Unique identifier for this LLM call |
| `sessionId` | The session this call belongs to |
| `provider` | The model provider (e.g., `anthropic`, `openai`) |
| `model` | The model name (e.g., `claude-opus-4-6`) |
| `systemPrompt` | The system prompt sent to the model |
| `prompt` | The current user message |
| `historyMessages` | All prior messages in the conversation |
| `imagesCount` | Number of images included in this call |

**`llm_output`** — fires after the LLM has responded.

| Property | Description |
|---|---|
| `runId` | Matches the corresponding `llm_input` runId |
| `sessionId` | The session this response belongs to |
| `provider` | The model provider |
| `model` | The model that responded |
| `assistantTexts` | Array of text blocks in the response |
| `lastAssistant` | The full raw assistant message object |
| `usage.input` | Input token count |
| `usage.output` | Output token count |
| `usage.cacheRead` | Cache-read token count (Anthropic prompt caching) |
| `usage.cacheWrite` | Cache-write token count |
| `usage.total` | Total token count |

**Example — logging token usage per generation:**

```js
api.on("llm_output", (event, ctx) => {
  console.log({
    model: event.model,
    session: event.sessionId,
    inputTokens: event.usage?.input,
    outputTokens: event.usage?.output,
    agent: ctx.agentId,
  });
});
```

---

### 2. Tool Execution Events

These events fire around every tool call the AI agent makes — including built-in tools like `bash`, `browser`, and `canvas`, as well as any custom skill tools.

**`before_tool_call`** — fires before the tool runs. Handlers can inspect or modify parameters, or block the call entirely.

| Property | Description |
|---|---|
| `toolName` | The name of the tool being called |
| `params` | The parameters the agent passed to the tool |

**Context (`ctx`) properties:**

| Property | Description |
|---|---|
| `agentId` | Which agent is invoking the tool |
| `sessionKey` | The session key |
| `toolName` | The tool name (same as in event) |

**`after_tool_call`** — fires after the tool completes.

| Property | Description |
|---|---|
| `toolName` | The name of the tool that ran |
| `params` | The parameters that were used |
| `result` | The tool's return value |
| `error` | Error message if the tool failed |
| `durationMs` | How long the tool took to execute, in milliseconds |

**Example — recording tool execution latency:**

```js
api.on("after_tool_call", (event, ctx) => {
  console.log({
    tool: event.toolName,
    success: !event.error,
    latencyMs: event.durationMs,
    agent: ctx.agentId,
    session: ctx.sessionKey,
  });
});
```

---

### 3. Trace Events (Sessions and Agent Runs)

These events let you reconstruct a complete trace of an agent's activity from start to finish.

**Session lifecycle:**

| Event | When it fires | Key properties |
|---|---|---|
| `session_start` | When a new conversation session begins | `sessionId`, `resumedFrom` (if resumed) |
| `session_end` | When a session concludes | `sessionId`, `messageCount`, `durationMs` |

**Agent run lifecycle:**

| Event | When it fires | Key properties |
|---|---|---|
| `before_agent_start` | Before the agent begins processing a message | `prompt`, `messages` |
| `agent_end` | After the agent finishes its response | `messages`, `success`, `error`, `durationMs` |

**Message lifecycle:**

| Event | When it fires | Key properties |
|---|---|---|
| `message_received` | When an inbound message arrives from any channel | `from`, `content`, `timestamp` |
| `message_sending` | Before a reply is sent back to the user | `to`, `content` |
| `message_sent` | After the reply has been delivered | `to`, `content`, `success`, `error` |

**Context (`ctx`) properties available on agent events:**

| Property | Description |
|---|---|
| `agentId` | The agent handling this request |
| `sessionKey` | Stable key for the conversation |
| `sessionId` | ID for this specific session |
| `workspaceDir` | The agent's workspace directory |
| `messageProvider` | The channel the message came from |

**Example — tracing a full agent run:**

```js
api.on("session_start", (event, ctx) => {
  console.log(`[TRACE START] session=${event.sessionId}`);
});

api.on("agent_end", (event, ctx) => {
  console.log({
    event: "agent_end",
    session: ctx.sessionId,
    success: event.success,
    durationMs: event.durationMs,
    messageCount: event.messages?.length,
    error: event.error,
  });
});

api.on("session_end", (event, ctx) => {
  console.log(`[TRACE END] session=${event.sessionId}, messages=${event.messageCount}`);
});
```

---

## Complete Event Reference

| Hook Name | Fires When | Returns |
|---|---|---|
| `before_agent_start` | Before agent processes a message | Can inject system prompt context |
| `llm_input` | Before each LLM API call | Observation only |
| `llm_output` | After each LLM API response | Observation only |
| `agent_end` | After agent finishes responding | Observation only |
| `before_compaction` | Before session context is summarized | Observation only |
| `after_compaction` | After session context is summarized | Observation only |
| `before_reset` | Before `/new` or `/reset` clears a session | Observation only |
| `message_received` | When an inbound message arrives | Observation only |
| `message_sending` | Before a reply is sent | Can modify or cancel the message |
| `message_sent` | After a reply is delivered | Observation only |
| `before_tool_call` | Before a tool runs | Can modify params or block the call |
| `after_tool_call` | After a tool finishes | Observation only |
| `tool_result_persist` | When a tool result is written to the session | Can transform the stored message |
| `session_start` | When a session begins | Observation only |
| `session_end` | When a session ends | Observation only |
| `gateway_start` | When the Gateway process starts | Observation only |
| `gateway_stop` | When the Gateway process stops | Observation only |

---

## Hook Execution Behavior

Understanding how hooks run helps you design reliable capture logic:

- **Parallel (fire-and-forget):** Observation-only hooks (`llm_input`, `llm_output`, `after_tool_call`, `agent_end`, `message_received`, `message_sent`, `session_start`, `session_end`, `gateway_start`, `gateway_stop`) run all registered handlers simultaneously. A slow handler does not block the agent.
- **Sequential (modifying):** Hooks that can change behavior (`before_agent_start`, `message_sending`, `before_tool_call`) run handlers one at a time in priority order, passing results forward.
- **Error isolation:** By default, a handler that throws an error is caught and logged — it does not crash the agent or stop other handlers from running.
- **Priority ordering:** When registering a hook, pass `{ priority: N }` (higher numbers run first) to control handler execution order when multiple plugins listen to the same event.

```js
// Run this handler before any lower-priority handlers
api.on("before_tool_call", handler, { priority: 10 });
```

---

## Verifying Events Are Flowing

Once your plugin is installed and the Gateway is running, you can verify events are being received by checking your handler output. Start the Gateway in verbose mode to see plugin activity:

```bash
openclaw gateway --verbose
```

You should see log lines from the hook runner as events fire, and your handler's `console.log` output will appear in the Gateway process log. To check which hooks are active, use the doctor command:

```bash
openclaw doctor
```

For a persistent audit trail, write events to a local file or forward them to any analytics backend inside your handler — the hook system imposes no requirements on what you do with the data you receive.