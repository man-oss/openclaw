# OpenClaw Troubleshooting Guide

This guide helps you diagnose and resolve the most common issues you may encounter when setting up or running OpenClaw. Work through each section relevant to your problem before reaching out to the community.

---

## Quick First Step: Run the Doctor

Before diving into specific issues, run OpenClaw's built-in health checker:

```bash
openclaw doctor
```

This command automatically surfaces misconfigured settings, risky security policies, and common setup problems. Many issues can be resolved simply by reviewing the doctor's output and following its suggestions.

---

## Issue 1: The Assistant Is Not Responding on Any Channel

If you send a message and nothing happens, work through this checklist in order.

### 1.1 Is the Gateway Running?

The Gateway is the control plane that all channels connect through. Without it, nothing works.

**Check:** Open a terminal and verify the Gateway process is active. If you installed it as a daemon:

```bash
openclaw gateway --port 18789 --verbose
```

The `--verbose` flag will show you startup errors immediately. Look for connection errors or port conflicts in the output.

**Fix:** If the Gateway is not running, start it:

```bash
openclaw onboard --install-daemon
```

This installs the Gateway as a background service (launchd on macOS, systemd on Linux) that stays running automatically.

### 1.2 Is the Channel Token Configured?

Each messaging channel requires its own credential. Missing or incorrect tokens are the most common cause of silent failures.

**For Telegram:** Verify your bot token is set either as an environment variable or in your configuration file (`~/.openclaw/openclaw.json`):

```json5
{
  channels: {
    telegram: {
      botToken: "123456:ABCDEF",
    },
  },
}
```

**For Discord:** Verify your bot token:

```json5
{
  channels: {
    discord: {
      token: "1234abcd",
    },
  },
}
```

**For Slack:** Both `SLACK_BOT_TOKEN` and `SLACK_APP_TOKEN` must be set (or their equivalents under `channels.slack.botToken` and `channels.slack.appToken`).

**For WhatsApp:** Run the device-link flow if you haven't already:

```bash
openclaw channels login
```

### 1.3 Are You on the Allowlist?

OpenClaw defaults to a strict allowlist model. If your user ID is not on the allowed list, the assistant silently ignores your messages.

- **Direct messages (Telegram, WhatsApp, Signal, iMessage, Discord, Slack):** By default, unknown senders receive a pairing code and their message is not processed. You must approve the pairing:

  ```bash
  openclaw pairing approve <channel> <code>
  ```

- **To open access without pairing:** Set `dmPolicy="open"` and include `"*"` in the channel's `allowFrom` list in your configuration. Note: this is a security trade-off — review the [Security guide](https://docs.openclaw.ai/gateway/security) before doing this.

### 1.4 Check the Logs

Enable verbose logging to see exactly what the Gateway is receiving and rejecting:

```bash
openclaw gateway --verbose
```

Full logging documentation is available at [docs.openclaw.ai/logging](https://docs.openclaw.ai/logging).

---

## Issue 2: Model Errors — Authentication and API Key Problems

### 2.1 Anthropic or OpenAI Key Rejected

OpenClaw supports two AI providers: **Anthropic** (Claude) and **OpenAI** (ChatGPT/Codex). If model calls are failing, verify your configuration.

**Minimal working configuration:**

```json5
{
  agent: {
    model: "anthropic/claude-opus-4-6",
  },
}
```

### 2.2 OAuth vs. API Key

OpenClaw supports both OAuth subscriptions (Anthropic Pro/Max, ChatGPT) and direct API keys. If you're using OAuth, the authentication flow happens during `openclaw onboard`. If credentials are missing or expired, re-run the onboarding wizard:

```bash
openclaw onboard
```

The wizard will prompt you to re-authenticate with your provider.

### 2.3 Model Failover

If a model is unavailable or returns auth errors, OpenClaw can automatically fall back to an alternative. Review your model failover settings in the [Model failover documentation](https://docs.openclaw.ai/concepts/model-failover).

---

## Issue 3: Installation Conflicts and Node Version Errors

### 3.1 Node Version Too Old

OpenClaw requires **Node 22.12.0 or newer**. Running an older version produces cryptic errors during startup.

**Check your version:**

```bash
node --version
```

If the output is below `v22.12.0`, upgrade Node before proceeding. We recommend using a version manager like `nvm` or `fnm`.

### 3.2 Package Manager Compatibility

OpenClaw works with `npm`, `pnpm`, or `bun`. However, if you are installing from source (for development), `pnpm` is strongly preferred:

```bash
pnpm install
pnpm build
```

Using `npm install` from source may produce peer dependency warnings or missing build artifacts.

### 3.3 Peer Dependency Conflicts

OpenClaw has two optional peer dependencies that are **not installed automatically**:

| Package | Version | When you need it |
|---|---|---|
| `@napi-rs/canvas` | `^0.1.89` | Canvas rendering features |
| `node-llama-cpp` | `3.15.1` | Local LLM inference |

If you see peer dependency errors mentioning these packages, either install the specific version listed in `package.json`, or ignore the warning if you do not use those features.

**Important:** `node-llama-cpp` requires **exactly version `3.15.1`**. Installing a different version will cause conflicts. If you previously installed a different version, remove it and install the exact version:

```bash
npm install node-llama-cpp@3.15.1
```

### 3.4 Switching Release Channels

If you are on the `dev` or `beta` channel and experiencing instability, switch back to the stable release:

```bash
openclaw update --channel stable
```

Available channels:
- **stable** — tagged releases, recommended for most users
- **beta** — prerelease builds (`npm install -g openclaw@beta`)
- **dev** — moving head of `main` (`npm install -g openclaw@dev`)

---

## Issue 4: Messages Arriving With Missing Content

### 4.1 Group Messages Not Being Processed

If messages in group chats are arriving but being ignored:

- **Mention gating:** By default, the assistant may require an @-mention in group chats. Check the `requireMention` setting for your channel:

  ```json5
  {
    channels: {
      telegram: {
        groups: {
          "*": {
            requireMention: true,
          },
        },
      },
    },
  }
  ```

  Set `requireMention: false` to respond to all group messages without requiring a mention.

- **Group allowlist:** If `channels.<channel>.groups` is set, it acts as a strict allowlist. Include `"*"` to allow all groups, or list specific group IDs.

- **Activation mode:** In groups, you can toggle activation with the chat command `/activation mention|always`.

### 4.2 Media Not Being Processed

If images, audio, or video attachments are being ignored:

- There are file size limits on media. Large files above the configured cap are silently dropped.
- For Discord, check the `channels.discord.mediaMaxMb` setting.
- Refer to the [Media pipeline documentation](https://docs.openclaw.ai/nodes/images) for size caps and supported formats.

---

## Issue 5: Session and Conversation Behavior Problems

### 5.1 The Assistant "Forgets" Previous Messages Too Quickly

OpenClaw manages session context automatically. If the context window fills up, older messages are pruned. To manually compact the context and free up space while preserving a summary:

Send the chat command: `/compact`

For a fresh start with no history: `/new` or `/reset`

### 5.2 Unexpected Session Boundaries in Group Chats

Each group chat has its own isolated session. If the assistant seems to be responding as if it's in a different conversation:

- **Check session routing:** The Gateway routes messages to sessions based on channel, account, and peer. Group messages always go to an isolated session separate from your direct message session (`main`).

- **Check activation mode:** Send `/status` in the group to see which session and model is active.

- **Reset if needed:** Send `/new` in the problematic group chat to start a fresh session for that group.

### 5.3 The Assistant Is Not Responding in a Group (But Works in DMs)

This is almost always a configuration issue:

1. The group is not on the allowlist — add the group ID or `"*"` to `channels.<channel>.groups`
2. The message doesn't include a mention — toggle activation with `/activation always`
3. The `dmPolicy` is set incorrectly — run `openclaw doctor` to check for risky policy configurations

---

## Issue 6: macOS Permission Errors

If node features (camera, screen recording, notifications) fail on macOS:

### 6.1 `PERMISSION_MISSING` Error

This error appears when a node capability requires a macOS TCC permission that has not been granted.

- **Screen recording:** Required for `system.run` with screen content and `screen.record`. Grant screen recording permission to the OpenClaw app in **System Settings → Privacy & Security → Screen Recording**.
- **Notifications:** Grant notification permission in **System Settings → Notifications**.
- **Camera:** Grant camera permission for camera snap/clip features.

### 6.2 Signed Builds Required

On macOS, permissions do not persist across rebuilds unless the app is signed. If you are building from source and permissions keep resetting, refer to the macOS permissions documentation at `docs/mac/permissions.md` in the repository.

---

## Issue 7: WhatsApp Connection Drops

WhatsApp uses the Baileys library and a QR-code device link. If the connection drops repeatedly:

1. **Re-link the device:** Run `openclaw channels login` and scan the QR code again.
2. **Credentials location:** WhatsApp credentials are stored in `~/.openclaw/credentials`. If this directory is corrupted or missing, delete it and re-link.
3. **Only one active session:** WhatsApp does not allow multiple active sessions from the same number. Ensure no other WhatsApp Web sessions are active.

---

## Issue 8: Gateway Startup Failures

### 8.1 Port Already in Use

The Gateway defaults to port `18789`. If another process is using that port:

```bash
openclaw gateway --port 18790
```

Choose any available port and update any client configurations to match.

### 8.2 Tailscale Configuration Conflicts

If you use Tailscale Serve or Funnel and the Gateway fails to start:

- `gateway.bind` **must** be set to `loopback` when Tailscale is enabled — OpenClaw enforces this.
- Funnel mode **requires** `gateway.auth.mode: "password"` to be set before it will start.
- If you see Tailscale-related errors, set `gateway.tailscale.mode: "off"` temporarily to confirm the Gateway starts without Tailscale, then re-enable and configure auth.

### 8.3 Gateway Lock

If a previous Gateway instance didn't shut down cleanly, a lock file may prevent restart. Run:

```bash
openclaw doctor
```

The doctor detects stale locks and offers to clean them up. More details: [Gateway lock documentation](https://docs.openclaw.ai/gateway/gateway-lock).

---

## Issue 9: Browser Control Not Working

Browser control requires explicit opt-in in your configuration:

```json5
{
  browser: {
    enabled: true,
    color: "#FF4500",
  },
}
```

On Linux, browser control requires additional dependencies. See the [Linux browser troubleshooting guide](https://docs.openclaw.ai/tools/browser-linux-troubleshooting).

---

## Still Stuck?

1. **Run `openclaw doctor`** — surfaces the most common configuration and security issues automatically.
2. **Check the logs** — start the Gateway with `--verbose` to see detailed output.
3. **Review the full troubleshooting guide** at [docs.openclaw.ai/channels/troubleshooting](https://docs.openclaw.ai/channels/troubleshooting).
4. **Ask the community** — join the [Discord server](https://discord.gg/clawd) for real-time help from other users and maintainers.
5. **Browse existing issues** — search [GitHub Issues](https://github.com/openclaw/openclaw/issues) to see if your problem has a known fix or workaround.