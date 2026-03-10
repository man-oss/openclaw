# Key Concepts: LLM Events, Traces, and Sessions

OpenClaw tracks every interaction with the AI model as a series of structured events. Understanding what each event represents — and how they link together — lets you navigate the LLM Analytics dashboard and make sense of every row you see there.

---

## The Mental Model: Three Layers of Observation

Think of OpenClaw's analytics as three nested containers:

```
Session
 └── Conversation Trace (runId)
      ├── Generation (LLM call)
      └── Tool Execution (tool call)
```

- A **session** is the long-lived conversation between a user and the assistant on a given channel.
- A **run** is one complete agent loop — from the moment a user message arrives to the moment a reply is sent.
- Within each run, the agent may call the LLM one or more times (generations) and invoke tools between those calls.

---

## 1. What Is a Generation?

A **generation** is one round-trip call to an AI language model. Each time the agent sends a request to the model and receives a response, that is one generation.

OpenClaw fires two events for every generation:

### `llm_input` — Fires When a Request Is Sent to the Model

This event captures everything about what was sent to the model:

| Field | What It Tells You |
|---|---|
| `runId` | Which agent loop this call belongs to |
| `sessionId` | Which session (conversation) this belongs to |
| `provider` | The AI provider (e.g., `anthropic`, `openai`) |
| `model` | The exact model name used |
| `prompt` | The user's message that triggered this call |
| `systemPrompt` | The system instructions active for this call |
| `historyMessages` | Number of prior messages included for context |
| `imagesCount` | Number of images attached to the request |

### `llm_output` — Fires When the Model Responds

This event captures everything the model returned:

| Field | What It Tells You |
|---|---|
| `runId` | Links back to the same agent loop as the input |
| `sessionId` | Links back to the same session |
| `provider` | The AI provider that responded |
| `model` | The model that generated the response |
| `assistantTexts` | The text(s) the model produced |
| `usage.input` | Tokens consumed from your prompt |
| `usage.output` | Tokens generated in the response |
| `usage.cacheRead` | Tokens served from the provider's prompt cache |
| `usage.cacheWrite` | Tokens written into the provider's prompt cache |
| `usage.total` | Total tokens for this generation |

> **When do multiple generations appear in one run?** When the agent uses a tool, it sends the tool result back to the model and calls it again. Each of those model calls produces a new `llm_input`/`llm_output` pair — all sharing the same `runId`.

---

## 2. What Is a Tool Execution?

A **tool execution** is one invocation of a capability the agent uses to accomplish work — for example, running a bash command, taking a browser screenshot, sending a message to another session, or reading a file.

OpenClaw fires two events for every tool call:

### `before_tool_call` — Fires Just Before the Tool Runs

| Field | What It Tells You |
|---|---|
| `toolName` | Which tool was requested (e.g., `bash`, `browser_snapshot`) |
| `params` | The exact arguments the model passed to the tool |

The context also carries `agentId` and `sessionKey` so you can trace which agent issued the call.

### `after_tool_call` — Fires After the Tool Completes

| Field | What It Tells You |
|---|---|
| `toolName` | Which tool ran |
| `params` | The arguments that were used |
| `result` | What the tool returned to the agent |
| `error` | If the tool failed, the error message |
| `durationMs` | How long the tool took to complete, in milliseconds |

Tool executions do not carry a `runId` directly in the event payload; they are correlated to a run through the session context (`agentId` + `sessionKey`) and their position in time.

---

## 3. What Is a Conversation Trace?

A **conversation trace** (also called a **run**) is the complete lifecycle of one agent loop — from receiving a user message to delivering a reply. It bundles all the generations and tool executions that the agent needed to answer that one message.

Every `llm_input` and `llm_output` event carries a `runId` field. All events that share the same `runId` are part of the same trace. In your analytics dashboard, grouping by `runId` reconstructs the full reasoning chain for any single agent invocation:

```
runId: "abc-123"
  ├── llm_input   (prompt: "Search the web for X")
  ├── llm_output  (model decides to call browser tool)
  ├── before_tool_call  (tool: browser_snapshot)
  ├── after_tool_call   (result: page HTML)
  ├── llm_input   (tool result fed back to model)
  └── llm_output  (final answer produced)
```

The agent also fires `agent_end` when a run completes, which records:

| Field | What It Tells You |
|---|---|
| `success` | Whether the run completed without error |
| `error` | The error message if the run failed |
| `durationMs` | Total wall-clock time for the entire run |
| `messages` | The full message history at completion |

---

## 4. The Difference Between a `runId` and a Session

| | `runId` | Session (`sessionId`) |
|---|---|---|
| **Scope** | One agent invocation (one user message → one reply) | The entire lifetime of a conversation |
| **Lifetime** | Seconds to minutes | Minutes to hours or days |
| **Resets when** | A new message arrives | The user runs `/new` or `/reset`, or a new session starts |
| **Appears in** | `llm_input`, `llm_output` events | `llm_input`, `llm_output`, `session_start`, `session_end` events |
| **Use for** | Reconstructing a single reasoning trace | Measuring conversation length, token spend per user |

**In plain terms:** a session is like a notebook; each page in the notebook is a run. Many runs can happen inside one session. When a user says "What's the weather?" and then five minutes later asks "What about tomorrow?", those are two different `runId` values inside the same `sessionId`.

Sessions have their own lifecycle events:

- **`session_start`** — fires when a session is created or resumed. Carries `sessionId` and, if resuming, the `resumedFrom` identifier.
- **`session_end`** — fires when a session closes. Carries `sessionId`, `messageCount` (total messages exchanged), and `durationMs` (how long the session lasted).

---

## 5. How All Events Relate and Appear in the Dashboard

Here is a complete picture of how a single user message flows through the event system:

```
User sends a message
  │
  ├─► session_start          (if this is the first message)
  │     sessionId: "sess-456"
  │
  ├─► before_agent_start     (system prompt context assembled)
  │
  ├─► llm_input              runId: "run-789", sessionId: "sess-456"
  │     provider: "anthropic", model: "claude-opus-4-6"
  │     tokens in: 1,200
  │
  ├─► llm_output             runId: "run-789", sessionId: "sess-456"
  │     usage.output: 45 tokens
  │     (model requests a tool call)
  │
  ├─► before_tool_call       toolName: "bash", params: {command: "ls -la"}
  ├─► after_tool_call        toolName: "bash", durationMs: 312, result: "..."
  │
  ├─► llm_input              runId: "run-789"  ← same run, second generation
  ├─► llm_output             runId: "run-789"  ← final answer
  │
  └─► agent_end              success: true, durationMs: 4200
```

### Reading This in the LLM Analytics Dashboard

When you open the LLM Analytics section, you will see rows of events. Here is what each column means:

- **Event name** — the hook that fired (`llm_input`, `llm_output`, `after_tool_call`, etc.)
- **`runId`** — filter or group by this to see everything that happened during one user-message cycle
- **`sessionId`** — filter or group by this to see the full conversation history across many runs
- **`provider` / `model`** — which AI service and model handled each generation
- **`usage.*`** — token counts per generation (use these to understand your API costs)
- **`durationMs`** — on `after_tool_call` and `agent_end`, how long that step took

### Common Dashboard Queries

| Question | How to answer it |
|---|---|
| "Why did this reply take so long?" | Filter by `runId`, sort by timestamp, look at `durationMs` on each `after_tool_call` |
| "How many tokens did this conversation use?" | Filter by `sessionId`, sum `usage.total` across all `llm_output` events |
| "Which tool caused an error?" | Filter `after_tool_call` events where `error` is not empty |
| "How many model calls does an average run take?" | Group `llm_output` events by `runId`, count rows per group |
| "Which model am I using most?" | Group `llm_output` events by `model`, count |

---

## Quick-Reference: All Event Types

| Event | When It Fires | Key Fields |
|---|---|---|
| `session_start` | Conversation begins or resumes | `sessionId`, `resumedFrom` |
| `session_end` | Conversation closes | `sessionId`, `messageCount`, `durationMs` |
| `before_agent_start` | Agent loop begins, before first LLM call | `prompt`, `messages` |
| `llm_input` | Request sent to AI model | `runId`, `sessionId`, `provider`, `model`, `usage` fields |
| `llm_output` | Response received from AI model | `runId`, `sessionId`, `provider`, `model`, `assistantTexts`, `usage.*` |
| `before_tool_call` | Tool about to be invoked | `toolName`, `params` |
| `after_tool_call` | Tool finished | `toolName`, `params`, `result`, `error`, `durationMs` |
| `agent_end` | Full run complete | `success`, `error`, `durationMs`, `messages` |
| `before_compaction` | Session history about to be summarized | `messageCount`, `tokenCount` |
| `after_compaction` | Session history summarization done | `messageCount`, `compactedCount` |
| `before_reset` | `/new` or `/reset` about to clear session | `sessionFile`, `messages`, `reason` |