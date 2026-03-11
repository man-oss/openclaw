# Conversation Trace Capture & Session Replay

OpenClaw automatically records the full activity of every AI conversation session — every incoming message, agent response, tool invocation, and state change. This built-in trace capture lets you review, replay, and debug any conversation your assistant has handled.

---

## What a Conversation Trace Includes

Every time OpenClaw processes a message, it captures a complete record of that interaction. A single conversation trace contains:

| What's Captured | What It Tells You |
|---|---|
| **Incoming message** | The exact text received from the user, the channel it came from (WhatsApp, Telegram, Slack, etc.), and when it arrived |
| **Queue state** | How long the message waited before the agent started working on it |
| **Agent run attempts** | Each time the agent started processing, including the unique run ID and attempt number |
| **Tool calls** | Every tool the agent invoked (browser, bash, canvas, sessions, etc.) during that response |
| **Session state transitions** | Whether the session moved from idle → processing → idle, or got stuck |
| **Errors and outcomes** | Whether the response completed successfully, was skipped, or failed with an error |
| **Timing information** | Duration of each processing step in milliseconds |

---

## How Sessions Are Tracked

OpenClaw tracks conversations using two identifiers:

- **Session ID** — A unique identifier for each conversation thread (e.g., one-on-one chat with you on WhatsApp, a Slack channel, a Discord DM)
- **Run ID** — A unique identifier for each individual agent processing cycle within a session

### One Run vs. One Session

A single back-and-forth message exchange produces **one run** (one processing cycle with its own run ID). A full conversation — many messages over time — is a **single session** (one session ID, many run IDs).

When replaying a conversation, you can look at:
- **Individual runs** to see exactly what the agent did for one specific message
- **The full session history** to see the entire conversation flow from start to finish

---

## Viewing the Session Transcript

The quickest way to replay a conversation is through the built-in session tools:

### From the Chat Interface

Send `/status` in any conversation window to see the current session's model, token usage, and cost snapshot.

### From the Control Panel

1. Open the Gateway Control UI in your browser (by default at `http://127.0.0.1:18789`)
2. Navigate to the **Dashboard** section
3. Find the session you want to inspect — sessions are listed by channel and conversation ID
4. Click a session to view its full message history and activity log

### From the Command Line

Use the `sessions_history` tool via the agent to fetch a transcript of any active session:

```
Ask your assistant: "Show me the transcript for session [session name]"
```

Or use the CLI directly:

```bash
openclaw agent --message "Use sessions_history to show me the last 20 messages from the main session"
```

This returns the full sequence of messages exchanged in that session, in order.

---

## Understanding the Diagnostic Activity Log

Beyond the message transcript, OpenClaw maintains a live diagnostic trace of every session. This is especially useful for debugging unexpected agent behavior.

### How to Enable Debug Logging

Start the gateway with verbose output to see the full trace as it happens:

```bash
openclaw gateway --port 18789 --verbose
```

With verbose mode active, the console shows a real-time stream of:

```
webhook received: channel=telegram type=message chatId=12345
message queued: sessionId=main sessionKey=telegram/12345 source=telegram queueDepth=1
session state: sessionId=main prev=idle new=processing reason="message received"
run attempt: sessionId=main runId=abc-123 attempt=1
message processed: channel=telegram outcome=completed duration=4231ms
session state: sessionId=main prev=processing new=idle
```

Each line shows the exact moment an event occurred, making it straightforward to follow the conversation flow step by step.

### Reading a Stuck Session

If the agent stops responding mid-conversation, OpenClaw's heartbeat check fires every 30 seconds and will flag sessions that have been in the `processing` state for more than 2 minutes:

```
stuck session: sessionId=main state=processing age=145s queueDepth=1
```

This tells you:
- **Which session** is stuck (by session ID)
- **How long** it has been processing (age in seconds)
- **How many messages** are waiting behind it (queue depth)

---

## Replaying a Conversation to Debug Agent Behavior

Follow this workflow when you need to understand why the agent responded unexpectedly:

### Step 1 — Identify the Session

Run `openclaw doctor` to surface any sessions flagged with errors or unusual activity. Note the session ID of the conversation you want to investigate.

### Step 2 — Retrieve the Full Transcript

Ask the assistant or use the Control UI to pull the session history. Review the sequence of messages to confirm what the user sent and what the agent replied.

### Step 3 — Check the Diagnostic Log

Look for the run attempt that corresponds to the message in question. The run ID links the message to the specific processing cycle. Check whether the run:
- Completed (`outcome=completed`)
- Was skipped (`outcome=skipped`) with a reason (e.g., the message was filtered, the session was paused)
- Failed (`outcome=error`) with an error description

### Step 4 — Look at Tool Usage

If the agent used tools during the suspicious exchange, enable verbose logging and re-run the conversation. The tool calls appear inline in the processing trace, showing you exactly what the agent attempted to do and in what order.

### Step 5 — Check Session State Transitions

Verify that the session moved cleanly from `processing` back to `idle`. If it remained in `processing`, the agent likely timed out or hit an unhandled error during tool execution.

---

## Session Pruning and Retention

OpenClaw keeps up to **2,000 active session records** in memory at one time. Sessions that have been idle (no activity) for more than **30 minutes** are automatically pruned. This means:

- Traces for very old conversations may no longer be in the live diagnostic view
- The persistent session transcript (the actual message history) is stored separately and is not affected by pruning
- If you need to debug a conversation from hours or days ago, use `sessions_history` to retrieve the stored transcript rather than the live diagnostic log

---

## Common Debugging Scenarios

| Symptom | What to Look For |
|---|---|
| Agent didn't reply to a message | Check `outcome=skipped` in the diagnostic log and look at the `reason` field — it may have been filtered by your allowlist settings |
| Agent gave a wrong or partial answer | Look for `run attempt` entries with `attempt=2` or higher — the agent may have retried after an error |
| Agent is frozen, no response | Look for `stuck session` warnings; check if a tool call is hanging (browser or bash commands can block) |
| Agent replied to the wrong person in a group | Check the `sessionKey` in the diagnostic log — each group conversation has its own session key |
| Response was very slow | Compare the `message queued` timestamp to `message processed` duration; high queue depth means earlier messages were still being processed |

---

## Related Features

- **[Session management](/concepts/session)** — How OpenClaw creates and routes sessions per channel and conversation
- **[Doctor tool](/gateway/doctor)** — Automated health checks that surface stuck sessions and misconfigured settings
- **[Logging guide](/logging)** — How to configure log levels and output destinations
- **[Control UI](/web/control-ui)** — Browser-based dashboard for inspecting sessions visually