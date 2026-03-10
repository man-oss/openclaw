# Understanding Trace Grouping Modes

> **Note:** The OpenClaw repository (`man-oss/openclaw`) does not implement a `traceGrouping` setting, `sessionWindowMinutes` parameter, or PostHog dashboard integration in its current codebase. The concepts described in the original task scope — `message` mode, `session` mode, and `sessionWindowMinutes` — could not be verified in any source file in this repository. The documentation below accurately reflects what the OpenClaw session and event model actually provides, so you can make an informed decision about how your conversations and activity are organized.

---

## How OpenClaw Organizes Your Conversations

OpenClaw groups your interactions using a **session model**. Every conversation you have — whether through WhatsApp, Telegram, Slack, Discord, or any other connected channel — belongs to a named session. Understanding how sessions work helps you predict how your history is stored and how the assistant keeps context.

---

## The Main Session

When you send a direct message to your OpenClaw assistant, that conversation belongs to your **main** session. The main session is the primary, persistent space for one-on-one interactions with the assistant. It accumulates context over time, so the assistant can refer back to things you said earlier.

- **Best for:** Personal, ongoing conversations where you want the assistant to remember what you discussed before.
- **Context is preserved** across separate messages as long as you haven't reset the session.

---

## Group and Channel Sessions

When OpenClaw is active in a group chat (a Slack channel, a Discord server, a WhatsApp group, etc.), each group gets its **own isolated session**. This keeps group conversations separate from your personal main session and from each other.

- **Best for:** Team channels, topic-specific groups, or any scenario where different audiences should not share context.
- Group sessions are identified by the channel and group identifier, so two different groups never share the same conversation history.

---

## Resetting a Session (Starting Fresh)

At any time you can clear the conversation context and start over by sending the `/new` or `/reset` command in your chat. This wipes the current session's memory so the assistant treats the next message as a brand-new conversation.

```
/new
```

or

```
/reset
```

This is useful when:
- You're switching topics and don't want old context to interfere.
- A conversation has grown very long and you want a clean slate.
- You're handing a channel over to a new topic or team.

---

## Compacting a Long Session

Rather than resetting entirely, you can use `/compact` to ask the assistant to summarize what has been discussed so far. The full transcript is replaced with a condensed summary, freeing up space while preserving the key points.

```
/compact
```

---

## How Context Is Kept Across Messages

Within a session, every message you send and every reply the assistant gives are stored in order. The assistant reads this history each time it responds, which is how it maintains the thread of your conversation. The longer a session runs, the more history it accumulates.

When a session grows too large to process efficiently, OpenClaw's **session pruning** system automatically trims older messages to keep things running smoothly. You can also trigger this manually with `/compact`.

---

## Choosing the Right Approach for Your Use Case

| Scenario | Recommended Approach |
|---|---|
| Single, focused question (no follow-up needed) | Use `/new` before and after to keep each interaction isolated |
| Ongoing personal assistant conversations | Stay in the main session; let context accumulate naturally |
| Team group chats on different topics | Use separate group channels — each gets its own isolated session automatically |
| Very long projects where history gets unwieldy | Use `/compact` periodically to summarize without losing important context |
| Starting a completely new topic | Use `/reset` to clear context and begin fresh |

---

## Viewing Session Status

Send `/status` in any conversation to see a snapshot of the current session, including the model in use, token count, and cost information when available.

```
/status
```

---

## Further Reading

- [Session model concepts](https://docs.openclaw.ai/concepts/session) — deep dive into how sessions are structured
- [Session pruning](https://docs.openclaw.ai/concepts/session-pruning) — how OpenClaw manages long conversation histories automatically
- [Groups](https://docs.openclaw.ai/concepts/groups) — rules for how group chats are handled
- [Full configuration reference](https://docs.openclaw.ai/gateway/configuration) — all available settings