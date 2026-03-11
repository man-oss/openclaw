# Understanding How OpenClaw Configuration Works Together

OpenClaw is configured through a single file — `~/.openclaw/openclaw.json` — that controls everything from which AI model you use to which messaging channels are active, how the Gateway is exposed, and how security rules are applied. This page explains every major configuration area, how the settings relate to each other, and how to compose the right configuration for your specific needs.

---

## The Configuration File

All settings live in `~/.openclaw/openclaw.json`. You never need to restart the Gateway manually after most changes — the onboarding wizard (`openclaw onboard`) writes and updates this file for you, and you can also edit it directly.

The minimal valid configuration is just a model choice:

```json5
{
  agent: {
    model: "anthropic/claude-opus-4-6",
  },
}
```

Everything else has sensible defaults, so you only need to add what you want to change.

---

## Configuration Areas at a Glance

OpenClaw's configuration is organized into distinct areas. Each area controls a specific aspect of the assistant, and many areas interact with each other.

| Area | What It Controls |
|---|---|
| `agent` | Which AI model is used, workspace location, tool permissions, sandbox behavior |
| `agents` | Per-agent overrides and the `defaults` that apply to all agents |
| `gateway` | How the Gateway server runs — port, network binding, authentication, Tailscale |
| `channels` | Individual messaging channel connections (WhatsApp, Telegram, Slack, Discord, etc.) |
| `browser` | Whether the built-in browser tool is available and how it appears |
| `commands` | Which slash commands are enabled and how they behave |

---

## Agent & Model Settings

The `agent` section (or `agents.defaults`) is where you pick your AI model and configure the assistant's behavior.

**Selecting a model:**

```json5
{
  agent: {
    model: "anthropic/claude-opus-4-6",
  },
}
```

Models are specified as `provider/model-name`. Supported providers include Anthropic (Claude) and OpenAI (GPT/Codex). The model you choose affects the quality, speed, and cost of every response. Claude Opus is recommended for long conversations and resistance to manipulation.

**Workspace location:**

The assistant's workspace — where it stores files, skills, and its persona — defaults to `~/.openclaw/workspace`. You can point it elsewhere:

```json5
{
  agents: {
    defaults: {
      workspace: "/path/to/your/workspace",
    },
  },
}
```

**How the model setting interacts with channels:** Every channel (WhatsApp, Telegram, etc.) routes messages through the same agent and model unless you configure per-agent routing. The model setting is a global default that every conversation uses unless overridden.

---

## Gateway Settings

The `gateway` section controls the control-plane server that all clients connect to.

**Port and binding:**

```json5
{
  gateway: {
    port: 18789,
    bind: "loopback",
  },
}
```

By default the Gateway binds only to your local machine (`loopback`). This means nothing outside your computer can reach it directly — you need Tailscale or an SSH tunnel for remote access.

**Tailscale exposure:**

```json5
{
  gateway: {
    tailscale: {
      mode: "serve",
    },
  },
}
```

| Mode | Who can reach the Gateway |
|---|---|
| `off` (default) | Local machine only |
| `serve` | Anyone on your Tailscale network (tailnet) |
| `funnel` | The public internet (requires password auth) |

**Critical interaction — binding and Tailscale must agree:** When Tailscale `serve` or `funnel` is active, the `bind` setting must remain `loopback`. OpenClaw enforces this automatically. If you try to set `bind` to anything other than `loopback` while Tailscale is active, the Gateway will refuse to start.

**Authentication:**

```json5
{
  gateway: {
    auth: {
      mode: "password",
      password: "your-secret-password",
    },
  },
}
```

- When Tailscale `serve` is active, Tailscale identity headers authenticate you by default — no password needed unless you explicitly set `allowTailscale: false`.
- When Tailscale `funnel` is active (public internet), a password is **required**. The Gateway will not start in funnel mode without one.

---

## Channel Settings

Each messaging channel has its own sub-section under `channels`. You only need to configure the channels you actually want to use.

### Access Control: allowFrom

Every channel supports an `allowFrom` list. Only the phone numbers, usernames, or IDs you add here can interact with the assistant.

```json5
{
  channels: {
    whatsapp: {
      allowFrom: ["+1234567890", "+9876543210"],
    },
  },
}
```

Add `"*"` to allow anyone — but only do this intentionally and in combination with other safeguards.

### DM Pairing Policy

Channels like Telegram, Discord, and WhatsApp default to `dmPolicy: "pairing"`. Unknown senders receive a short pairing code; they can't talk to the assistant until you approve them with `openclaw pairing approve <channel> <code>`.

To allow anyone without pairing, set `dmPolicy: "open"` **and** include `"*"` in `allowFrom`. Both changes are required — one alone is not enough.

**Why both settings interact:** The pairing policy acts as a gatekeeper for unknown contacts, while `allowFrom` is the final allowlist check. If you set `dmPolicy: "open"` but keep a restricted `allowFrom` list, new contacts are still blocked. Conversely, setting `allowFrom: ["*"]` while leaving `dmPolicy: "pairing"` still requires unknown senders to go through the pairing flow.

### Group Access

For channels that support groups, configure which groups the assistant participates in:

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

If `groups` is set, it acts as a group allowlist — the assistant only responds in listed groups. Include `"*"` to allow all groups. The `requireMention` option means the assistant only responds when directly @mentioned, which is recommended for busy group chats.

---

## Security and Sandbox Settings

Security settings determine what the assistant can do on your system. The defaults are designed for a single trusted user (`main` session), but can be tightened for group or multi-user scenarios.

**Sandbox mode for non-main sessions:**

```json5
{
  agents: {
    defaults: {
      sandbox: {
        mode: "non-main",
      },
    },
  },
}
```

With `mode: "non-main"`, conversations from group chats and channels other than your personal `main` session run inside per-session Docker containers. The assistant's bash access is then isolated — it can't affect your host system from those conversations.

**How sandbox interacts with channels:** If you have a public Telegram bot (`allowFrom: ["*"]`, `dmPolicy: "open"`), you almost certainly want `sandbox.mode: "non-main"` to prevent strangers from running arbitrary commands on your machine.

---

## Browser Tool

The browser tool is optional and disabled by default.

```json5
{
  browser: {
    enabled: true,
    color: "#FF4500",
  },
}
```

When enabled, the assistant can control a dedicated Chrome/Chromium browser. The `color` setting changes the browser's theme color so you can visually distinguish the OpenClaw browser from your personal browser.

**Interaction with sandbox:** When sandbox mode is active for non-main sessions, `browser` is in the default denylist. Group chat participants cannot use browser control even if the tool is globally enabled.

---

## Common Configuration Combinations

### Minimal Personal Assistant (Single User, Local Only)

The simplest setup: one model, one or two channels, no remote access.

```json5
{
  agent: {
    model: "anthropic/claude-opus-4-6",
  },
  channels: {
    telegram: {
      botToken: "your-bot-token",
      allowFrom: ["your-telegram-id"],
    },
  },
}
```

Everything runs locally. Only you can talk to the assistant. No sandbox needed because you're the only user.

---

### Remote Access Setup (Tailscale)

For accessing the assistant from other devices on your Tailscale network — for example, from your phone or a remote Mac.

```json5
{
  gateway: {
    bind: "loopback",
    tailscale: {
      mode: "serve",
    },
  },
  agent: {
    model: "anthropic/claude-opus-4-6",
  },
  channels: {
    telegram: {
      botToken: "your-bot-token",
      allowFrom: ["your-telegram-id"],
    },
  },
}
```

The Gateway stays bound to `loopback` (required when Tailscale is active). Tailscale provides secure, identity-verified access to the Gateway dashboard from any of your devices.

---

### Multi-Channel Public Bot with Security Hardening

For running a bot that multiple people can use (for example, a family or small team setup), with sandboxing for safety.

```json5
{
  agent: {
    model: "anthropic/claude-opus-4-6",
  },
  agents: {
    defaults: {
      sandbox: {
        mode: "non-main",
      },
    },
  },
  channels: {
    telegram: {
      botToken: "your-bot-token",
      dmPolicy: "pairing",
      allowFrom: ["user1-id", "user2-id"],
    },
    discord: {
      token: "your-discord-token",
      dmPolicy: "pairing",
      allowFrom: ["user1-id", "user2-id"],
    },
  },
}
```

New users must go through the pairing flow before the assistant will respond to them. Non-main conversations run in Docker sandboxes, so no one can use the assistant to run commands on your host machine.

---

### Full-Featured Power User Setup

For a single trusted user who wants every capability: browser control, voice, remote access, and full model capability.

```json5
{
  agent: {
    model: "anthropic/claude-opus-4-6",
  },
  gateway: {
    bind: "loopback",
    tailscale: {
      mode: "serve",
    },
  },
  browser: {
    enabled: true,
    color: "#FF4500",
  },
  channels: {
    whatsapp: {
      allowFrom: ["your-number"],
    },
    telegram: {
      botToken: "your-bot-token",
      allowFrom: ["your-telegram-id"],
    },
  },
}
```

Everything is unlocked. Because only your own IDs are in `allowFrom` and Tailscale restricts remote access to your devices, the open capabilities don't create security risk.

---

## Key Interactions Summary

Understanding how settings affect each other prevents unexpected behavior:

| If you set… | Then you also need… | Why |
|---|---|---|
| Tailscale `mode: "serve"` or `"funnel"` | `bind: "loopback"` | OpenClaw enforces this; mismatched settings block startup |
| Tailscale `mode: "funnel"` | `auth.mode: "password"` | Funnel exposes the Gateway to the public internet; a password is mandatory |
| `dmPolicy: "open"` | `allowFrom: ["*"]` or specific IDs | Policy and allowlist are checked independently; both must be permissive to allow open access |
| `allowFrom: ["*"]` on a public channel | `sandbox.mode: "non-main"` | Allowing strangers without sandboxing gives them bash access to your machine |
| `browser.enabled: true` | Awareness of sandbox denylist | Browser is blocked in sandboxed sessions by default; enable per-agent if needed |
| Multiple channels with different audiences | Per-channel `allowFrom` lists | Each channel enforces its own allowlist independently |

---

## Getting Help

- Run `openclaw doctor` to surface misconfigured or risky settings automatically.
- The full configuration reference with every available key is at [docs.openclaw.ai/gateway/configuration](https://docs.openclaw.ai/gateway/configuration).
- For guided setup, run `openclaw onboard` — the wizard writes the configuration for you and explains each choice as it goes.