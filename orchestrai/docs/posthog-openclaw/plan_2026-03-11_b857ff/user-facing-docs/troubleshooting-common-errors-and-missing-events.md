# Troubleshooting Common Issues with OpenClaw

This guide helps you diagnose and resolve the most common problems users encounter with OpenClaw. Work through each section that matches your situation.

---

## Quick First Step: Run the Doctor

Before digging into specific issues, run the built-in diagnostic tool from your terminal:

```bash
openclaw doctor
```

This command checks your installation, configuration, and channel setup, and surfaces risky or misconfigured settings automatically. It's the fastest way to catch obvious problems.

---

## Problem 1: The Assistant Isn't Responding to Messages

If you send a message through WhatsApp, Telegram, Slack, Discord, or another channel and get no response, work through this checklist:

### Check 1: Is the Gateway running?

OpenClaw requires the Gateway to be running at all times. If you installed it as a daemon, verify it's active:

```bash
openclaw gateway --port 18789 --verbose
```

The `--verbose` flag shows detailed startup logs so you can spot any startup errors immediately.

### Check 2: Is the channel configured correctly?

Each channel requires specific credentials in your configuration file (`~/.openclaw/openclaw.json`). Check the relevant section:

- **Telegram** — Requires `channels.telegram.botToken` (or the `TELEGRAM_BOT_TOKEN` environment variable)
- **Discord** — Requires `channels.discord.token` (or the `DISCORD_BOT_TOKEN` environment variable)
- **Slack** — Requires both `channels.slack.botToken` and `channels.slack.appToken`
- **WhatsApp** — Requires completing the device-link flow via `openclaw channels login`
- **BlueBubbles (iMessage)** — Requires `channels.bluebubbles.serverUrl`, `channels.bluebubbles.password`, and a `channels.bluebubbles.webhookPath`

A missing or incorrect token is one of the most common reasons messages are silently ignored.

### Check 3: Is the sender allowed?

OpenClaw has a DM pairing system enabled by default. If an unknown person messages your assistant, they receive a short pairing code and their message is **not** processed until you approve them.

- Approve a pending sender: `openclaw pairing approve <channel> <code>`
- To skip pairing entirely and allow all senders, set `dmPolicy="open"` and add `"*"` to `allowFrom` in your channel configuration — but only do this intentionally, as it opens the assistant to anyone.

If messages from a specific person are being ignored, they may be waiting for pairing approval.

### Check 4: Is a group allowlist blocking the message?

If you have `channels.whatsapp.groups`, `channels.telegram.groups`, or similar set, those act as **allowlists** — only listed groups (or groups matching `"*"`) are processed. A group not on the list is silently skipped.

To allow all groups, include `"*"` in the groups configuration.

---

## Problem 2: The Assistant Responds but Message Content Seems Filtered or Stripped

If the assistant receives messages but its replies seem to lack context about what was sent (for example, it doesn't "see" text, links, or media you sent), check the following:

### Privacy and content filtering

OpenClaw does not have a built-in global "privacy mode" toggle, but certain channels strip or limit content by default. Verify:

- **Media size caps**: Large images, audio, or video may be silently dropped. Check `channels.<channel>.mediaMaxMb` in your configuration to increase the limit.
- **Group activation mode**: In groups, the assistant only responds when mentioned by default (`/activation mention`). Switch to `/activation always` if you want it to process all messages.
- **Channel-specific formatting**: Some channels (like Discord) have specific message chunking rules. If very long messages appear cut off, this is expected behavior.

### Check verbose mode

Enable verbose output to see exactly what the assistant is receiving:

```
/verbose on
```

Send this command directly in the chat. The assistant will then include diagnostic information in its responses, making it easier to see whether content is arriving correctly.

---

## Problem 3: Sessions or Conversation History Acting Unexpectedly

If the assistant seems to forget previous messages, or groups separate conversations together incorrectly, check these settings.

### Conversation context is reset

If the assistant acts like every message is a fresh conversation, the session may have been reset. Use `/status` to check the current session state, including token count and model. If tokens show as very low or zero for an ongoing conversation, the session was likely reset.

To manually reset a session: `/new` or `/reset`
To compact (summarize) a long session without losing all context: `/compact`

### Groups sharing context they shouldn't

OpenClaw creates isolated sessions for group conversations. If you're routing multiple channels or accounts to separate agents, verify your routing configuration in `~/.openclaw/openclaw.json`. Each agent (workspace) maintains its own session state — sessions from one workspace don't bleed into another.

### Main session vs. channel sessions

The `main` session is used for your direct personal chats. Group chats and other channels use separate, isolated sessions. If you're seeing unexpected context mixing, confirm that messages are arriving on the channel you expect (use `/status` to check).

---

## Problem 4: The Gateway Fails to Start

If running `openclaw gateway` produces an error or the process exits immediately:

### Port already in use

The default port is `18789`. If something else is using it, start the Gateway on a different port:

```bash
openclaw gateway --port 18790
```

### Configuration file errors

OpenClaw uses JSON5 format (`~/.openclaw/openclaw.json`). JSON5 allows comments and trailing commas, but syntax errors will prevent startup. If the Gateway exits with a config error, open the file and check for:

- Unclosed brackets or braces
- Missing commas between items
- Mismatched quotes

### Node.js version too old

OpenClaw requires **Node.js version 22 or higher** (specifically `>=22.12.0`). Run the following to check your version:

```bash
node --version
```

If it shows a version below 22, update Node.js before proceeding. The installation will not work correctly on older versions.

### Lock file conflict

If a previous Gateway process crashed, it may have left a lock file that prevents restart. Run:

```bash
openclaw doctor
```

The doctor command detects and can clear stale lock files.

---

## Problem 5: The `openclaw` Command Is Not Found

If your terminal says `command not found: openclaw` after installation:

### Global installation

Install OpenClaw globally with npm or pnpm:

```bash
npm install -g openclaw@latest
# or
pnpm add -g openclaw@latest
```

After installation, open a new terminal window and try again. Some shells require reloading to pick up new global commands.

### Running from source

If you cloned the repository instead of installing globally, use:

```bash
pnpm openclaw <command>
```

from inside the project directory. This runs TypeScript directly without needing a global install.

---

## Problem 6: Channels Connect but the AI Model Doesn't Respond

If messages are received and the assistant acknowledges them but produces no AI response:

### Model credentials missing

Check that your model credentials are configured. The minimum required configuration:

```json5
{
  agent: {
    model: "anthropic/claude-opus-4-6",
  },
}
```

Anthropic and OpenAI require OAuth login or API keys. Run the onboarding wizard if you haven't completed this step:

```bash
openclaw onboard
```

### Model failover

If your primary model is unavailable (for example, rate limited or over quota), OpenClaw can fall back to alternative models. See the [Model failover guide](https://docs.openclaw.ai/concepts/model-failover) for configuration details.

### Thinking level

Some models (Claude Opus, GPT-5.2, Codex) support an extended thinking mode. If responses feel incomplete or the assistant seems to be stopping early, check the thinking level:

```
/think high
```

Available levels: `off`, `minimal`, `low`, `medium`, `high`, `xhigh`

---

## Problem 7: macOS/iOS/Android Permissions Errors

If device-specific features (camera, screen recording, notifications, voice) fail:

### `PERMISSION_MISSING` error

This means the required macOS permission has not been granted. For example, `system.run` with `needsScreenRecording: true` requires the Screen Recording permission to be enabled in **System Settings → Privacy & Security → Screen Recording** for the OpenClaw app.

### Elevated access

Some operations require elevated (host-level) permissions. Use `/elevated on` in your session to enable it — this only works if elevated access is configured and you are allowlisted. Use `/elevated off` to return to standard access.

---

## Getting More Help

- **Run diagnostics**: `openclaw doctor` — checks installation, config, DM policies, and common misconfigurations
- **View logs**: Check the logging output for detailed error messages. See the [Logging guide](https://docs.openclaw.ai/logging) for log file locations
- **Full troubleshooting reference**: [docs.openclaw.ai/channels/troubleshooting](https://docs.openclaw.ai/channels/troubleshooting)
- **Community support**: [Discord server](https://discord.gg/clawd) — active community and maintainer support
- **Issue tracker**: [github.com/openclaw/openclaw/issues](https://github.com/openclaw/openclaw/issues)

---

## Summary Checklist

| Symptom | First thing to check |
|---|---|
| No response from assistant | Is the Gateway running? Is the sender approved via pairing? |
| Messages ignored in a group | Is the group in the allowlist? Is activation mode set to `always`? |
| Content missing from messages | Check media size caps and verbose mode |
| Gateway won't start | Node.js ≥ 22? Config file syntax? Port conflict? |
| Command not found | Run `npm install -g openclaw@latest` and open a new terminal |
| AI not responding | Model credentials configured? Run `openclaw onboard` |
| Device features failing | macOS permissions granted in System Settings? |