# Data Privacy and Security Policies

## Overview

OpenClaw is a personal AI assistant that prioritizes user privacy and security through local-first architecture, explicit permission controls, and defense-in-depth security measures. This document outlines the security policies, data handling practices, and privacy protections implemented across the platform.

## Core Security Principles

### 1. Local-First Architecture

**Data Sovereignty**
- Gateway runs on user-controlled infrastructure (local machine, VPS, or private cloud)
- All session data, credentials, and workspace files stored locally in `~/.openclaw/`
- No telemetry or analytics collection by default
- User maintains complete control over data retention and deletion

**Credential Storage** (`apps/ios/Sources/Model/NodeAppModel.swift`)
- Credentials stored locally in `~/.openclaw/credentials` directory
- Channel authentication (WhatsApp, Telegram, etc.) persists locally
- API keys and tokens never transmitted to external services except target APIs
- iOS/macOS keychain integration for sensitive tokens via system secure storage

### 2. Network Security Architecture

**Gateway Communication**
- WebSocket control plane defaults to `loopback` binding (`127.0.0.1`)
- Remote access requires explicit configuration via Tailscale or SSH tunnels
- TLS/WSS enforced for all remote gateway connections
- Optional TLS certificate pinning for iOS/Android nodes

**Authentication Modes** (Reference: `gateway.auth.mode` configuration)
```typescript
// Token-based authentication (default for remote access)
gateway.auth.mode: "token"
gateway.auth.token: "<secure-random-token>"

// Password authentication (required for public Funnel exposure)
gateway.auth.mode: "password"
gateway.auth.password: "<strong-password>"

// Tailscale identity headers (for tailnet-only Serve)
gateway.tailscale.mode: "serve"
gateway.auth.allowTailscale: true
```

**Connection Security** (`NodeAppModel.swift:connectToGateway`)
- WebSocket session box with optional TLS pinning: `GatewayTLSPinningSession`
- Automatic reconnection with exponential backoff (0.5s to 8s)
- Health monitoring with 6-second timeout probes
- Background connection suspension to prevent socket leaks

## Data Collection and Storage Policies

### 1. Session Data Management

**Session Storage**
- Chat transcripts stored locally in `~/.openclaw/sessions/`
- Session keys derive from channel/agent context: `SessionKey.makeAgentSessionKey()`
- Automatic pruning based on `agents.defaults.sessionPruning` configuration
- No cross-session data leakage; isolated by `sessionKey`

**Workspace Isolation**
- Agent workspace root: `~/.openclaw/workspace`
- Per-agent sandboxes when `agents.defaults.sandbox.mode: "non-main"` enabled
- Docker-based isolation for untrusted group/channel sessions
- Host filesystem access restricted via allowlist/denylist policies

### 2. Media and Attachments

**Handling Policy**
- Images/audio/video processed locally before model API transmission
- Size caps enforced: `channels.<channel>.mediaMaxMb` (default varies by channel)
- Temporary files cleaned up after processing: `temp file lifecycle`
- Transcription hooks available for audio pre-processing

**iOS Media Security** (`NodeAppModel.swift:handleCameraInvoke`)
```swift
// Camera/screen recording with permission checks
- Requires explicit iOS TCC permissions (Camera, Screen Recording)
- Permission status checked before node.invoke execution
- Foreground-only restriction: background commands return BACKGROUND_UNAVAILABLE
- Base64 encoding for wire transmission (no disk persistence by default)
```

### 3. Location Data

**Privacy Controls** (`NodeAppModel.swift:handleLocationInvoke`)
```swift
// Location access tiers
- Off: No location access
- whenInUse: Foreground-only location (authorizedWhenInUse)
- always: Background location (authorizedAlways, requires explicit user opt-in)

// Precision control
- Precise: Full GPS coordinates (fullAccuracy)
- Balanced: Reduced precision (reducedAccuracy)
```

**Location Data Handling**
- Accuracy metadata included in payload (`isPrecise`, `accuracyMeters`)
- No persistent location history stored locally
- Background location requires `always` mode + `authorizedAlways` iOS status
- Rejected with `LOCATION_BACKGROUND_UNAVAILABLE` if misconfigured

## API Key and Credential Security

### 1. Model Provider Authentication

**Credential Rotation**
- OAuth profiles for Anthropic/OpenAI (Claude Pro/Max, ChatGPT)
- API key fallback via environment variables or config file
- Model failover: automatic fallback to secondary auth on 401/403
- No API keys logged; redacted from diagnostics

**Configuration Storage** (`.openclaw/openclaw.json`)
```json5
{
  "agent": {
    "model": "anthropic/claude-opus-4-6"
  },
  "anthropic": {
    "apiKey": "${ANTHROPIC_API_KEY}" // Env var preferred
  }
}
```

### 2. Channel Credentials

**Per-Channel Security**

**WhatsApp** (`channels.whatsapp`)
- Baileys multi-device session stored in `~/.openclaw/credentials/whatsapp-session.json`
- QR code authentication; no password storage
- Session encryption via libsignal protocol

**Telegram** (`channels.telegram`)
- Bot token stored in config or `TELEGRAM_BOT_TOKEN` env var
- Webhook secret for HTTPS webhook mode: `channels.telegram.webhookSecret`
- No user account credentials stored

**Discord** (`channels.discord`)
- Bot token in config or `DISCORD_BOT_TOKEN` env var
- Guild/channel IDs are non-sensitive; bot requires explicit invite

**Signal** (`channels.signal`)
- Requires signal-cli daemon with registered phone number
- Signal protocol encryption for message transmission
- No password or credentials in OpenClaw config

**BlueBubbles (iMessage)** (`channels.bluebubbles`)
- Password-protected connection to BlueBubbles server
- TLS enforced for server URL (`channels.bluebubbles.serverUrl`)
- Webhook authentication via path secret: `channels.bluebubbles.webhookPath`

### 3. Third-Party Integration Security

**Browser Control** (`browser.enabled`)
- Dedicated Chrome/Chromium profile isolated from user's main browser
- No cookie/session sharing with user's personal browsing
- Optional profile persistence for session continuity

**Webhook Authentication** (`automation/webhook`)
- Token-based authentication for inbound webhooks
- HTTPS required for production deployments
- Request signature verification for Gmail Pub/Sub

**Skills Registry (ClawHub)**
- Skills fetched over HTTPS from `clawhub.com`
- No automatic skill execution; install gating via user approval
- Workspace skills run with same sandbox policies as agent code

## Mobile App Security Controls

### 1. iOS Node Security (`apps/ios/Sources/Model/NodeAppModel.swift`)

**Permission Architecture**
```swift
// TCC (Transparency, Consent, and Control) integration
- Camera: AVCaptureDevice authorization (photo/video)
- Microphone: AVAudioSession (Voice Wake, Talk Mode)
- Location: CLLocationManager (whenInUse/always)
- Screen Recording: ReplayKit authorization
- Notifications: UNUserNotificationCenter authorization
- Contacts: CNContactStore
- Calendar: EKEventStore
- Reminders: EKEventStore (reminders)
- Motion: CMMotionActivityManager, CMPedometer
```

**Capability Routing** (`buildCapabilityRouter`)
- Commands whitelist: `location.get`, `camera.snap`, `camera.clip`, `screen.record`, `system.notify`, `chat.push`
- Background restrictions: canvas/camera/screen commands return `BACKGROUND_UNAVAILABLE` when app is backgrounded
- Permission errors: `CAMERA_DISABLED`, `LOCATION_PERMISSION_REQUIRED`, `NOT_AUTHORIZED: notifications`

**Voice Wake Privacy**
- On-device speech recognition (no cloud transmission of audio buffer)
- Keyword detection threshold configurable via `VoiceWakePreferences`
- Automatic suspension when backgrounded or Talk Mode active
- Microphone release coordination: `suspendForExternalAudioCapture()`

**Talk Mode Security**
- Push-to-talk with explicit start/stop: `talk.pttStart`, `talk.pttStop`, `talk.pttCancel`
- Session key routing: transcripts tagged with `mainSessionKey`
- VoiceWake suspended during Talk to prevent conflicts
- ElevenLabs API key transmitted over HTTPS only

### 2. Android Node Security (`docs/platforms/android`)

**Permission Model**
- Runtime permissions required for Camera, Microphone, Location
- Screen capture via MediaProjection API (requires user approval dialog)
- SMS optional; not required for core functionality

**Network Security**
- TLS 1.2+ enforced for gateway connections
- Certificate pinning available for production deployments
- Local network discovery via Bonjour/mDNS (optional)

### 3. macOS Node Security (`docs/platforms/macos`)

**System Permissions**
- Full Disk Access not required (restricted to `~/.openclaw` and workspace)
- Screen Recording permission for `system.run` with `needsScreenRecording: true`
- Accessibility permission not used

**Elevated Bash Access**
- Per-session toggle: `/elevated on|off` command
- Requires explicit allowlist: user must be in `allowFrom` and `elevated` enabled
- Gateway persists toggle via `sessions.patch` (not permanent across restarts)
- Audit log for elevated command execution

## Network Security and Communication Encryption

### 1. Transport Encryption

**Local Connections**
- WebSocket (`ws://`) for loopback-only gateway (no TLS overhead)
- TLS not required for `127.0.0.1` binding (local threat model assumes trusted host)

**Remote Connections**
- WSS (WebSocket Secure) required for remote gateway access
- TLS 1.2+ enforced; TLS 1.3 preferred
- Certificate validation via system trust store or custom pinning

**Tailscale Integration** (`gateway.tailscale.mode`)
```typescript
// Serve: Tailnet-only HTTPS (uses Tailscale identity headers)
gateway.tailscale.mode: "serve"
gateway.bind: "loopback" // Enforced
gateway.auth.allowTailscale: true

// Funnel: Public HTTPS (requires password auth)
gateway.tailscale.mode: "funnel"
gateway.bind: "loopback" // Enforced
gateway.auth.mode: "password"
gateway.auth.password: "<strong-password>"
```

**SSH Tunnels** (Alternative to Tailscale)
- Port forwarding: `ssh -L 18789:localhost:18789 user@remote-host`
- Authenticated via SSH keys (no gateway password required for localhost binding)
- End-to-end encryption via SSH protocol

### 2. Message Encryption

**Channel-Level Encryption**
- Signal: End-to-end encryption via Signal Protocol
- WhatsApp: End-to-end encryption via Baileys/libsignal
- Telegram: Optional secret chats (not supported by bot API)
- Discord/Slack: TLS in transit; not end-to-end encrypted

**Gateway-to-Node Encryption**
- WebSocket messages encrypted via TLS when WSS enabled
- Payload encryption not implemented (relies on transport security)
- Node pairing requires token exchange over encrypted channel

## Third-Party Integration Security

### 1. Model Provider APIs

**Data Transmission**
- Messages sent over HTTPS to Anthropic/OpenAI APIs
- No message content logged by OpenClaw (model provider logs per their ToS)
- Context pruning: sessions truncated based on token limits
- No training opt-out control; governed by provider's data usage policies

**Rate Limiting and Quotas**
- Retry with exponential backoff (0.5s to 8s)
- Failover to alternate models on rate limit (429) or quota exceeded
- No persistent queue; messages may be dropped on repeated failures

### 2. Channel Platform APIs

**WhatsApp (Baileys)**
- Multi-device protocol: encrypted with libsignal
- Session replication disabled; single device per account
- No message history sync from WhatsApp servers

**Telegram Bot API**
- Bot token authentication over HTTPS
- Webhook mode: TLS enforced via `channels.telegram.webhookUrl`
- No access to user's personal messages (bot scope only)

**Discord Gateway**
- Bot token authentication
- WebSocket connection for event streaming (Discord Gateway v10)
- Privileged intents not required (MESSAGE_CONTENT intent optional)

**Slack Bolt**
- Socket Mode: WSS connection authenticated with App Token
- Event API: Webhook with signature verification (`x-slack-signature`)
- No access to private channels unless bot explicitly added

### 3. Browser Automation Security

**Chromium Profile Isolation** (`browser.enabled`)
- Dedicated user data directory: `~/.openclaw/browser-profile/`
- No access to user's default Chrome/Firefox profiles
- Cookies/localStorage isolated per agent workspace

**Snapshot Security**
- Screenshots base64-encoded; no disk persistence by default
- Optional upload to model provider for vision tasks
- Size limits: `maxWidth` parameter to reduce payload size

## DM Access and Pairing Security

### 1. Default DM Policy

**Pairing Mode (Recommended)** (`dmPolicy="pairing"`)
```typescript
// Applies to: Telegram, WhatsApp, Signal, iMessage, Discord, Slack
channels.telegram.dmPolicy: "pairing"
channels.discord.dmPolicy: "pairing"
channels.slack.dmPolicy: "pairing"
```

**Behavior**
- Unknown senders receive a pairing code: 4-6 character alphanumeric
- Message content ignored until pairing approved
- Pairing approval: `openclaw pairing approve <channel> <code>`
- Approved senders added to allowlist: `~/.openclaw/pairings.json`

**Open Mode (Risky)** (`dmPolicy="open"`)
- Requires explicit opt-in: `dmPolicy="open"` + `allowFrom: ["*"]`
- All DMs processed without pairing
- **Security warning**: Treat inbound DMs as untrusted input; prompt injection risk
- `openclaw doctor` flags open DM policies as risky

### 2. Allowlist Controls

**Per-Channel Allowlists**
```typescript
channels.telegram.allowFrom: ["+1234567890", "username"]
channels.discord.allowFrom: ["discord-user-id"]
channels.slack.allowFrom: ["slack-user-id"]
```

**Group Allowlists**
```typescript
// Group-level access control
channels.telegram.groups: {
  "*": { requireMention: true }, // All groups, mention-only
  "group-id": { requireMention: false } // Specific group, always respond
}
```

**Wildcards**
- `"*"` in `allowFrom`: Allows all users (requires explicit `dmPolicy="open"`)
- `"*"` in `groups`: Allows all groups (with per-group rules)

### 3. Audit and Monitoring

**Diagnostic Logging** (`GatewayDiagnostics`)
- Connection events: `operator gateway connected`, `gateway disconnected`
- Health check failures: logged with reason
- No message content logged by default
- Enable verbose logging: `openclaw gateway --verbose`

**Doctor Command** (`openclaw doctor`)
- Scans for risky DM policies: open DMs without allowlists
- Validates credential files: checks for missing or expired tokens
- Permission checks: iOS TCC status, macOS sandbox config
- Output: warnings for security misconfigurations

## Compliance and Privacy Protections

### 1. GDPR Considerations

**User Rights**
- **Right to Access**: Session data in `~/.openclaw/sessions/` (plaintext JSON)
- **Right to Erasure**: `rm -rf ~/.openclaw/sessions/<session-key>` or `openclaw session delete`
- **Right to Portability**: Session export via `openclaw session export`
- **Right to Rectification**: Manual edit of session files or `openclaw session patch`

**Data Minimization**
- Only message content, timestamps, and metadata stored
- No PII collected beyond what's in message content
- Session pruning reduces data retention: `agents.defaults.sessionPruning.maxMessages`

### 2. Third-Party Processor Disclosure

**Model Providers**
- Anthropic: Messages transmitted for inference (see Anthropic Commercial Terms)
- OpenAI: Messages transmitted for inference (see OpenAI API ToS)
- User controls: Model selection, prompt engineering, session pruning

**Channel Platforms**
- WhatsApp: E2E encrypted; Meta processes metadata
- Telegram: Bot API; Telegram processes message routing
- Discord: Gateway API; Discord processes all message content
- Slack: Event API; Slack processes all message content

**Infrastructure Providers** (Optional)
- Tailscale: Coordination server for Serve/Funnel (user traffic not logged)
- SSH: No third-party provider (direct host-to-host)

### 3. Data Retention Policies

**Default Retention**
- Session data: Indefinite (until manual deletion or pruning)
- Credentials: Indefinite (until revoked or reset)
- Logs: No persistence by default (stdout only)

**Configurable Pruning** (`agents.defaults.sessionPruning`)
```typescript
sessionPruning: {
  maxMessages: 1000, // Per-session limit
  maxAge: "30d", // Time-based pruning
  strategy: "sliding" // sliding | fixed
}
```

**Media Cleanup**
- Temporary files removed after processing
- Base64-encoded media not persisted to disk (transmitted in-memory)

## Security Incident Response

### 1. Credential Compromise

**Immediate Actions**
1. Revoke compromised credentials:
   - WhatsApp: Unlink device via phone app
   - Telegram: Revoke bot token via @BotFather
   - Discord: Regenerate bot token in Developer Portal
2. Rotate gateway authentication: `gateway.auth.token` or `gateway.auth.password`
3. Review session logs for unauthorized access

**Preventive Measures**
- Use token-based auth instead of passwords
- Restrict gateway binding to loopback unless remote access required
- Enable Tailscale Serve (tailnet-only) instead of Funnel (public)

### 2. Unauthorized Access Detection

**Indicators**
- Unexpected gateway connections: Check `openclaw gateway` logs
- Unknown messages in session history
- Unusual API usage costs (model provider dashboards)

**Response**
1. Disconnect gateway: `openclaw gateway stop`
2. Review allowlists: `~/.openclaw/openclaw.json`
3. Audit pairings: `~/.openclaw/pairings.json`
4. Reset authentication tokens

### 3. Vulnerability Disclosure

**Reporting**
- Security issues: Report via GitHub Security Advisories
- Non-security bugs: GitHub Issues
- Response timeline: Best-effort (no SLA for community edition)

**Update Policy**
- Check for updates: `openclaw update --check`
- Apply updates: `openclaw update --channel stable`
- Review changelog: [CHANGELOG.md](https://github.com/openclaw/openclaw/blob/main/CHANGELOG.md)

## Security Best Practices

### 1. Deployment Recommendations

**Local Deployment (Highest Security)**
- Gateway bound to loopback only: `gateway.bind: "loopback"`
- No remote access configured
- Physical device security (full disk encryption, screen lock)

**Remote Deployment (Balanced Security)**
- Gateway on trusted VPS/private cloud
- Tailscale Serve (tailnet-only) for remote access
- Strong password/token authentication: `gateway.auth.password: "<32-char-random>"`
- Firewall rules: Block direct internet access to gateway port

**Public Deployment (Discouraged)**
- Tailscale Funnel only (avoid exposing raw WebSocket port)
- Mandatory password authentication: `gateway.auth.mode: "password"`
- Rate limiting at proxy layer (nginx/Caddy)
- Monitor for abuse: `openclaw doctor --verbose`

### 2. Configuration Hardening

**Minimal Privilege**
```typescript
// Sandbox non-main sessions (groups/channels)
agents.defaults.sandbox.mode: "non-main"
agents.defaults.sandbox.allowTools: ["bash", "read", "write"]
agents.defaults.sandbox.denyTools: ["browser", "system", "nodes"]
```

**DM Restrictions**
```typescript
// Require pairing for all channels
channels.telegram.dmPolicy: "pairing"
channels.discord.dmPolicy: "pairing"
channels.slack.dmPolicy: "pairing"

// Explicit allowlists
channels.telegram.allowFrom: ["+1234567890"]
channels.discord.allowFrom: ["trusted-user-id"]
```

**Group Gating**
```typescript
// Mention-only in groups
channels.telegram.groups: {
  "*": { requireMention: true }
}
channels.discord.guilds: {
  "*": { requireMention: true }
}
```

### 3. Operational Security

**Key Rotation**
- Rotate gateway auth tokens quarterly: `gateway.auth.token: "<new-random>"`
- Rotate channel credentials on suspected compromise
- Update Tailscale auth keys annually

**Access Auditing**
- Review pairing approvals monthly: `openclaw pairing list`
- Check session activity: `openclaw session list`
- Monitor gateway logs for connection anomalies

**Dependency Updates**
- Update OpenClaw: `openclaw update --channel stable`
- Update Node.js: Ensure Node ≥22 for security patches
- Update OS: Apply system updates regularly (iOS, macOS, Linux)

## Summary

OpenClaw's security model prioritizes user control, local-first data handling, and defense-in-depth protections. Key security controls include:

1. **Local Data Storage**: All credentials, sessions, and workspace files stored on user-controlled infrastructure
2. **Transport Encryption**: TLS/WSS for remote connections; optional certificate pinning
3. **Permission Gating**: iOS TCC integration, macOS sandbox policies, explicit DM pairing
4. **Credential Isolation**: Per-channel authentication, API key rotation, no plaintext secrets in logs
5. **Audit and Monitoring**: Doctor command for misconfiguration detection, diagnostic logging, session export

**Users are responsible for:**
- Physical device security (encryption, screen lock)
- Gateway authentication strength (use long random tokens)
- Allowlist management (review and prune regularly)
- Prompt engineering to prevent injection attacks
- Model provider API key protection

**OpenClaw does not:**
- Collect telemetry or analytics
- Store data on third-party servers (except model inference APIs)
- Implement end-to-end encryption beyond channel protocols
- Provide SLA or formal security support for community edition

For production deployments, review the [Security Guide](https://docs.openclaw.ai/gateway/security) and run `openclaw doctor` to validate configuration.