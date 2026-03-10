# Managing Session Windows in OpenClaw

## What Is a Session Window?

A **session window** is the stretch of time during which OpenClaw treats your conversation as one continuous interaction. Every message you send refreshes the window — the assistant remembers everything said so far and keeps building on the same context.

When you go quiet for long enough, the window **closes due to inactivity**. The next message you send opens a fresh session: the assistant starts without memory of the previous conversation, exactly as if you had typed `/new` or `/reset` yourself.

Think of it like a phone call: while you keep talking, the line stays open. Set the receiver down long enough and the call ends — pick it up again and you start from scratch.

---

## The Default Idle Timeout: 60 Minutes

Out of the box, OpenClaw does not apply an automatic idle reset unless you configure one. When you add an idle rule, the most common starting point is **60 minutes** of silence — a safe default that covers a typical focused work session without prematurely cutting off users who simply paused to think or stepped away briefly.

To turn on the default idle reset, add this to your `~/.openclaw/openclaw.json`:

```json5
{
  session: {
    reset: {
      mode: "idle",
      idleMinutes: 60,
    },
  },
}
```

With this in place, any gap in conversation longer than 60 minutes automatically closes the current session. The next message opens a clean one.

---

## When to Use a Shorter Window

Shorten the idle timeout when your users interact **frequently and briefly** — for example:

- A customer support bot that handles many short, distinct questions throughout the day
- A notification assistant where each alert should be treated as its own topic
- A high-traffic group chat where different people send unrelated messages in quick succession

A 5–15 minute window keeps each burst of activity isolated so cost tracking and conversation history stay accurate per-topic rather than bleeding across unrelated exchanges.

**Example — 10-minute idle reset:**

```json5
{
  session: {
    reset: {
      mode: "idle",
      idleMinutes: 10,
    },
  },
}
```

You can also tune idle timeouts differently for direct messages versus group conversations:

```json5
{
  session: {
    resetByType: {
      direct: {
        mode: "idle",
        idleMinutes: 30,
      },
      group: {
        mode: "idle",
        idleMinutes: 10,
      },
    },
  },
}
```

---

## When to Use a Longer Window

Lengthen the idle timeout when your users work **slowly, asynchronously, or across multiple sittings** — for example:

- A long-form writing assistant where someone composes over several hours
- A research assistant where users might spend 2–3 hours thinking between questions
- An async team tool on Slack or Discord where replies can come hours apart

A 120–240 minute window gives users the freedom to pause, come back, and pick up right where they left off without losing context.

**Example — 3-hour idle reset:**

```json5
{
  session: {
    reset: {
      mode: "idle",
      idleMinutes: 180,
    },
  },
}
```

For workflows that span an entire workday and should reset every morning regardless of activity, use a **daily reset** instead of an idle one:

```json5
{
  session: {
    reset: {
      mode: "daily",
      atHour: 6,
    },
  },
}
```

`atHour` is in 24-hour format (0–23). The above resets all sessions at 6:00 AM each day.

---

## Applying Different Windows Per Channel

If you run OpenClaw on multiple messaging surfaces that have very different interaction patterns, you can set a unique idle window for each channel:

```json5
{
  session: {
    resetByChannel: {
      whatsapp: {
        mode: "idle",
        idleMinutes: 30,
      },
      slack: {
        mode: "idle",
        idleMinutes: 120,
      },
      discord: {
        mode: "daily",
        atHour: 0,
      },
    },
  },
}
```

Channel keys match the channel names used elsewhere in your configuration: `whatsapp`, `telegram`, `slack`, `discord`, `signal`, `imessage`, `msteams`, `webchat`, and so on.

---

## How the Session Window Affects History and Context

The idle window directly controls how long your conversation history stays active. A wider window means:

- **More context available** — the assistant can reference things said hours ago
- **Larger context sent to the model** — this may increase token usage and cost
- **Fewer fresh starts** — less chance of the assistant "forgetting" your preferences mid-task

A narrower window means:

- **Cleaner per-task tracking** — each burst of interaction is isolated
- **Lower token usage per session** — shorter histories are cheaper to process
- **More frequent resets** — users may need to re-establish context after pauses

To keep context manageable on long sessions, combine an idle reset with session maintenance settings such as pruning old entries:

```json5
{
  session: {
    reset: {
      mode: "idle",
      idleMinutes: 120,
    },
    maintenance: {
      pruneAfter: "7d",
      maxEntries: 500,
    },
  },
}
```

---

## Quick Reference

| Use Case | Recommended Idle Window | Configuration |
|---|---|---|
| High-frequency support bot | 5–15 minutes | `idleMinutes: 10` |
| Standard personal assistant | 60 minutes | `idleMinutes: 60` |
| Long-form writing or research | 2–4 hours | `idleMinutes: 180` |
| Async team channel (Slack/Discord) | 2–6 hours | `idleMinutes: 240` |
| Daily-cycle workflow | Reset at a fixed hour | `mode: "daily", atHour: 6` |

---

## Resetting a Session Manually

You can always reset a session immediately without waiting for the idle timer — just send `/new` or `/reset` in any connected channel. This works in WhatsApp, Telegram, Slack, Discord, Google Chat, Microsoft Teams, and WebChat.

For more on session management commands, see the [Chat commands section](https://docs.openclaw.ai/start/getting-started) of the OpenClaw documentation.