# System Architecture Overview

## Overview

OpenClaw is a personal AI assistant system built on a distributed, modular architecture that separates concerns between message routing (Gateway), AI agent execution, multi-channel integration, and device-specific capabilities. The system is designed to run locally on user devices while supporting remote deployments and multi-device coordination.

## High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                     Messaging Channels                           │
│  WhatsApp │ Telegram │ Slack │ Discord │ Signal │ iMessage ...  │
└────────────────────────┬────────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────────┐
│                    Gateway (Control Plane)                       │
│                   ws://127.0.0.1:18789                          │
│  ┌─────────────┬──────────────┬──────────────┬────────────┐   │
│  │  Channel    │   Session    │    Tool      │   Cron     │   │
│  │  Router     │   Manager    │   Registry   │  Scheduler │   │
│  └─────────────┴──────────────┴──────────────┴────────────┘   │
└────────────────────────┬────────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────────┐
│                      Agent Runtime                               │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  Pi Agent (RPC Mode)                                      │  │
│  │  • Tool execution                                         │  │
│  │  • Streaming responses                                    │  │
│  │  • Session context management                            │  │
│  └──────────────────────────────────────────────────────────┘  │
└────────────────────────┬────────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────────┐
│                  Device Nodes & Tools                            │
│  ┌─────────────┬──────────────┬──────────────┬────────────┐   │
│  │  macOS      │   iOS        │   Android    │  Browser   │   │
│  │  Node       │   Node       │   Node       │  Control   │   │
│  └─────────────┴──────────────┴──────────────┴────────────┘   │
└─────────────────────────────────────────────────────────────────┘
```

## Core Components

### 1. Gateway (Control Plane)

**Location:** `src/gateway/`

The Gateway is the central control plane that manages all communication, routing, and coordination. It runs as a WebSocket server (default port 18789) bound to localhost.

**Key Responsibilities:**
- WebSocket server for real-time bidirectional communication
- Channel message routing and protocol adaptation
- Session lifecycle management and state persistence
- Tool registry and execution coordination
- Cron job scheduling and webhook handling
- Discovery and pairing for remote connections

**Entry Point:** `src/entry.ts`
```typescript
// Gateway initialization from src/entry.ts
export async function startGateway(options: GatewayOptions) {
  const gateway = new Gateway({
    port: options.port || 18789,
    bind: options.bind || 'loopback',
    // ... configuration
  });
  
  await gateway.start();
  return gateway;
}
```

**Architecture Details:**
- Single-threaded Node.js process with async event loop
- Persistent WebSocket connections for clients and nodes
- File-based configuration at `~/.openclaw/openclaw.json`
- State stored in `~/.openclaw/` (sessions, credentials, workspaces)

### 2. Agent System

**Location:** `src/agents/`

The agent system handles AI model interactions and tool execution via an RPC adapter pattern.

**Pi Agent Runtime:**
- Uses `pi-mono` library for model abstraction
- Supports multiple providers: Anthropic (Claude), OpenAI (GPT)
- Streaming tool execution with block streaming
- Context window management and token counting

**Agent Configuration:**
```typescript
// From src/agents/
interface AgentConfig {
  model: string;              // e.g., "anthropic/claude-opus-4-6"
  workspace: string;          // Default: ~/.openclaw/workspace
  sandbox?: SandboxConfig;    // Optional Docker isolation
  tools?: string[];           // Allowed tool list
}
```

**Session Management:**
- `main` session for direct 1:1 chats
- Isolated sessions per group/channel
- Per-session configuration (model, thinking level, elevation)
- Session pruning and compaction

### 3. Channel Architecture

**Location:** `src/channels/`

Channels provide protocol adapters for different messaging platforms. Each channel implements a common interface for message ingestion and delivery.

**Supported Channels:**
- **WhatsApp** (`src/whatsapp/`): Baileys protocol library, QR pairing
- **Telegram** (`src/telegram/`): grammY bot framework, webhook support
- **Slack** (`src/slack/`): Bolt framework, Socket Mode
- **Discord** (`src/discord/`): discord.js, slash commands, DM pairing
- **Google Chat** (`src/channels/googlechat.ts`): Chat API integration
- **Signal** (`src/signal/`): signal-cli wrapper
- **BlueBubbles** (`src/channels/bluebubbles.ts`): iMessage via BlueBubbles server
- **iMessage Legacy** (`src/imessage/`): Direct macOS Messages.app integration
- **Microsoft Teams** (`src/channels/msteams.ts`): Bot Framework
- **WebChat** (`src/web/`): Gateway WebSocket client

**Channel Interface Pattern:**
```typescript
// Common pattern across channels
interface Channel {
  start(): Promise<void>;
  stop(): Promise<void>;
  sendMessage(recipient: string, content: MessageContent): Promise<void>;
  onMessage(handler: MessageHandler): void;
}
```

**Message Flow:**
1. Channel receives raw message from platform
2. Channel adapter normalizes to internal format
3. Gateway routes to appropriate session
4. Agent processes and generates response
5. Gateway routes response back through channel
6. Channel adapter converts to platform format

### 4. Plugin and Extension System

**Location:** `src/plugin-sdk/`, `src/plugins/`

OpenClaw supports dynamic plugin loading for extending functionality.

**Plugin SDK:**
- TypeScript-based plugin interface at `src/plugin-sdk/`
- Extension API exposed via `src/extensionAPI.ts`
- Plugins can register tools, hooks, and commands

**Plugin Types:**
- **Bundled**: Shipped with OpenClaw core
- **Managed**: Installed via ClawHub registry
- **Workspace**: Local skills in `~/.openclaw/workspace/skills/`

**Skills System:**
- Skills are markdown-based tools with `SKILL.md` descriptor
- Installed to `~/.openclaw/workspace/skills/<skill>/`
- Auto-injected into agent context via `TOOLS.md`

**Tool Registry:**
```typescript
// Tool registration pattern
interface Tool {
  name: string;
  description: string;
  parameters: JSONSchema;
  execute(params: any): Promise<any>;
}

gateway.tools.register(tool);
```

## Data Flow Patterns

### Message Ingestion Flow

```
Channel Platform
    │
    ├─► Channel Adapter (protocol translation)
    │
    ├─► Gateway Router (session matching)
    │
    ├─► Session Queue (rate limiting)
    │
    ├─► Agent Runtime (RPC invocation)
    │
    ├─► Tool Execution (bash, browser, nodes, etc.)
    │
    ├─► Response Generation (streaming)
    │
    ├─► Gateway Router (channel lookup)
    │
    ├─► Channel Adapter (protocol translation)
    │
    └─► Channel Platform (delivery)
```

### Tool Execution Flow

```
Agent Request
    │
    ├─► Tool Router (gateway.tools.execute)
    │
    ├─► Permission Check (allowlist/denylist)
    │
    ├─► Sandbox Decision (main vs. non-main session)
    │
    ├─► Execution Environment
    │   ├─► Host (main session)
    │   ├─► Docker (sandbox mode)
    │   └─► Node (device-specific)
    │
    ├─► Result Capture (stdout/stderr/files)
    │
    └─► Response Stream (back to agent)
```

### Session Coordination

```
Inbound Message
    │
    ├─► Channel ID + Sender + Thread
    │
    ├─► Session Lookup/Create
    │   ├─► main (1:1 chats)
    │   ├─► group:<id> (group chats)
    │   └─► channel:<channel>:<id> (channel-specific)
    │
    ├─► Activation Check
    │   ├─► mention (require @mention in groups)
    │   └─► always (process all messages)
    │
    ├─► Queue Management
    │   ├─► serial (one at a time)
    │   └─► concurrent (parallel processing)
    │
    └─► Agent Dispatch
```

## Mobile App Integration

### iOS Node

**Location:** `apps/ios/`

iOS app acts as a device node, exposing device capabilities to the Gateway.

**Architecture:**
- Swift/SwiftUI native app
- Bonjour discovery for local Gateway
- WebSocket client for Gateway communication
- Node registration with capability advertisement

**Exposed Capabilities:**
- **Canvas**: Render agent-driven UI via `canvas.*` commands
- **Camera**: Capture photos/videos via `camera.snap`, `camera.clip`
- **Location**: GPS via `location.get`
- **Voice Wake**: Always-on voice trigger forwarding
- **Screen Recording**: Screen capture via `screen.record`

**Communication Pattern:**
```swift
// Node registration
gateway.send(.nodeRegister(NodeCapabilities(
    id: deviceId,
    capabilities: ["canvas", "camera", "location", "voice"]
)))

// Tool invocation from Gateway
gateway.on(.nodeInvoke) { request in
    let result = executeLocal(request.tool, request.params)
    gateway.send(.nodeResult(request.id, result))
}
```

### Android Node

**Location:** `apps/android/`

Similar architecture to iOS with Android-specific implementations.

**Capabilities:**
- Canvas rendering via Jetpack Compose
- Camera access via CameraX
- Location via FusedLocationProviderClient
- Screen recording via MediaProjection
- Optional SMS access

**Pairing Flow:**
1. Android app discovers Gateway via mDNS/Bonjour
2. User initiates pairing in app
3. Gateway generates pairing code
4. User confirms code in CLI: `openclaw pairing approve android <code>`
5. Gateway persists approved device to allowlist
6. Node establishes authenticated WebSocket connection

### macOS App

**Location:** `apps/macos/`

The macOS app serves dual roles: companion app and device node.

**Menu Bar Component:**
- Gateway health monitoring
- Quick actions (start/stop/restart)
- WebChat popup window
- Voice Wake UI with PTT overlay
- Remote gateway connection manager

**Node Mode:**
- Exposes macOS-specific tools: `system.run`, `system.notify`
- Canvas host for A2UI rendering
- Camera and screen recording access
- Requires TCC permissions (screen recording, camera, microphone)

**Permission Enforcement:**
```typescript
// From node execution
if (command.needsScreenRecording && !hasScreenRecordingPermission()) {
    throw new Error('PERMISSION_MISSING: Screen Recording required');
}
```

## Gateway Communication Protocol

### WebSocket Protocol

The Gateway uses a JSON-RPC-style protocol over WebSocket.

**Message Format:**
```typescript
interface GatewayMessage {
  id?: string;              // Request ID for RPC
  type: string;             // Message type
  payload: any;             // Type-specific payload
}
```

**Core Message Types:**

**Client → Gateway:**
- `node.register`: Register device node with capabilities
- `node.invoke`: Execute tool on registered node
- `session.create`: Create new session
- `session.send`: Send message to session
- `channel.send`: Send to specific channel
- `gateway.status`: Request Gateway status

**Gateway → Client:**
- `node.registered`: Node registration confirmation
- `node.result`: Tool execution result
- `session.message`: Incoming message from session
- `gateway.event`: System event notification
- `gateway.status`: Status response

### Discovery and Pairing

**Bonjour/mDNS Discovery:**
- Gateway advertises `_openclaw._tcp` service
- Clients discover via mDNS queries
- Service TXT records include:
  - `version`: Gateway version
  - `auth`: Required auth mode (none/password/token)
  - `capabilities`: Comma-separated capability list

**Pairing Flow:**
```typescript
// Gateway generates pairing code
const code = generatePairingCode(); // e.g., "ABC123"
storePendingPairing(channel, code, expiresAt);

// Client submits code
gateway.emit('pairing.request', { channel, code });

// Admin approves via CLI
// openclaw pairing approve <channel> <code>
gateway.emit('pairing.approve', { channel, code });

// Client receives approval
gateway.emit('pairing.approved', { channel, token });
```

## Extension Architecture

### Tool System

**Tool Definition:**
```typescript
// From src/plugin-sdk/
interface ToolDefinition {
  name: string;
  description: string;
  parameters: TypeBoxSchema;
  execute(params: any, context: ToolContext): Promise<ToolResult>;
}
```

**Built-in Tool Categories:**

**Execution Tools:**
- `bash`: Execute shell commands (host or sandbox)
- `process`: Long-running process management

**Filesystem Tools:**
- `read`: Read file contents
- `write`: Write file contents
- `edit`: Search/replace file editing

**Browser Tools:**
- `browser.navigate`: Navigate to URL
- `browser.action`: Perform page actions
- `browser.snapshot`: Capture page state

**Canvas Tools:**
- `canvas.push`: Update canvas UI
- `canvas.reset`: Clear canvas
- `canvas.eval`: Evaluate JS in canvas

**Node Tools:**
- `camera.snap`: Capture photo
- `camera.clip`: Record video
- `screen.record`: Capture screen
- `location.get`: Get GPS coordinates

**Session Tools:**
- `sessions_list`: List active sessions
- `sessions_history`: Get session transcript
- `sessions_send`: Message another session

### Hooks and Events

**Hook Registration:**
```typescript
// Plugin can register hooks
gateway.hooks.register('message.incoming', async (message) => {
    // Pre-process message
    return modifiedMessage;
});
```

**Available Hooks:**
- `message.incoming`: Pre-process inbound messages
- `message.outgoing`: Post-process responses
- `tool.pre_execute`: Before tool execution
- `tool.post_execute`: After tool execution
- `session.create`: On session creation
- `session.destroy`: On session cleanup

### Cron and Automation

**Location:** `src/cron/`

**Cron Job Definition:**
```typescript
interface CronJob {
  schedule: string;          // Cron expression
  command: string;           // Tool to execute
  params?: any;              // Tool parameters
  session?: string;          // Target session
}
```

**Configuration:**
```json5
{
  "cron": {
    "jobs": [
      {
        "schedule": "0 9 * * *",
        "command": "sessions_send",
        "params": {
          "sessionId": "main",
          "message": "Good morning! Daily briefing time."
        }
      }
    ]
  }
}
```

## Security Architecture

### DM Access Control

**Default Policy:** `dmPolicy: "pairing"` for public channels

**Policy Modes:**
- `pairing`: Require pairing code for unknown senders
- `allowlist`: Allow only explicitly listed users
- `open`: Accept all DMs (requires `"*"` in allowlist)

**Implementation:**
```typescript
// From channel handlers
if (config.dmPolicy === 'pairing' && !isAllowed(sender)) {
    const code = generatePairingCode();
    await channel.send(sender, `Pairing required: ${code}`);
    return; // Block message processing
}
```

### Sandbox Execution

**Configuration:**
```json5
{
  "agents": {
    "defaults": {
      "sandbox": {
        "mode": "non-main",      // Sandbox non-main sessions
        "allowTools": [
          "bash", "read", "write", "sessions_list"
        ],
        "denyTools": [
          "browser", "system.run", "nodes.*"
        ]
      }
    }
  }
}
```

**Sandbox Implementation:**
- Per-session Docker containers for `non-main` sessions
- Isolated filesystem with workspace mount
- Network restrictions
- Tool filtering before execution

### Permission Model

**Host Permissions (macOS):**
- TCC permissions required for device tools
- `system.run` requires explicit elevation toggle
- Elevation state tracked per-session
- Toggle via `/elevated on|off` command

**Tool Allowlists:**
- Global allowlist in agent config
- Per-session override capability
- Sandbox mode enforces additional restrictions

## Configuration System

**Location:** `src/config/`

**Primary Config File:** `~/.openclaw/openclaw.json`

**Schema Validation:**
- TypeBox schemas for configuration validation at `src/types/`
- Runtime validation on config load
- Migration system for version upgrades

**Key Configuration Sections:**

```json5
{
  "gateway": {
    "port": 18789,
    "bind": "loopback",
    "tailscale": {
      "mode": "off" | "serve" | "funnel"
    },
    "auth": {
      "mode": "none" | "password" | "token",
      "password": "...",
      "allowTailscale": true
    }
  },
  "agents": {
    "defaults": {
      "model": "anthropic/claude-opus-4-6",
      "workspace": "~/.openclaw/workspace",
      "sandbox": { /* ... */ }
    }
  },
  "channels": {
    "whatsapp": { /* ... */ },
    "telegram": { /* ... */ },
    "discord": { /* ... */ }
  }
}
```

## Runtime Environment

### Process Management

**Daemon Mode:**
- launchd (macOS): `~/Library/LaunchAgents/ai.openclaw.gateway.plist`
- systemd (Linux): `~/.config/systemd/user/openclaw-gateway.service`
- Auto-restart on crash
- Logging to `~/.openclaw/logs/`

**CLI Interface:**
```bash
# Gateway management
openclaw gateway --port 18789 --verbose
openclaw gateway --stop
openclaw gateway --restart

# Agent invocation
openclaw agent --message "Hello" --thinking high

# Channel operations
openclaw message send --to +1234567890 --message "Hi"
openclaw channels login
```

### State Persistence

**Directory Structure:**
```
~/.openclaw/
├── openclaw.json           # Main configuration
├── credentials/            # Channel auth tokens
│   ├── whatsapp/
│   ├── telegram/
│   └── discord/
├── workspace/              # Agent workspace
│   ├── AGENTS.md          # Agent system prompt
│   ├── SOUL.md            # Assistant personality
│   ├── TOOLS.md           # Tool documentation
│   └── skills/            # Installed skills
├── sessions/              # Session state
│   └── <session-id>.json
├── logs/                  # Gateway logs
└── tmp/                   # Temporary files
```

## Deployment Patterns

### Local Deployment (Default)

- Gateway runs on localhost:18789
- Channels connect via local WebSocket
- Nodes discover via Bonjour on LAN
- No external exposure

### Remote Gateway (Linux Server)

- Gateway runs on VPS/cloud instance
- Clients connect via Tailscale Serve/Funnel or SSH tunnels
- Device nodes pair remotely
- Host executes tools, nodes handle device-specific actions

**Tailscale Serve:**
```json5
{
  "gateway": {
    "bind": "loopback",
    "tailscale": {
      "mode": "serve",              // Tailnet-only
      "resetOnExit": true
    },
    "auth": {
      "mode": "token",              // Optional password
      "allowTailscale": true        // Use Tailscale identity
    }
  }
}
```

**Tailscale Funnel (Public):**
```json5
{
  "gateway": {
    "bind": "loopback",
    "tailscale": {
      "mode": "funnel"              // Public HTTPS
    },
    "auth": {
      "mode": "password",           // Required for funnel
      "password": "secure-password"
    }
  }
}
```

### SSH Tunnel Access

```bash
# Local machine
ssh -L 18789:localhost:18789 user@remote-host

# macOS app connects to localhost:18789 (tunneled)
```

## Component Relationships

```
┌─────────────────────────────────────────────────────────────┐
│ Directory Structure → Component Mapping                      │
├─────────────────────────────────────────────────────────────┤
│ src/gateway/      → Gateway Control Plane                    │
│ src/agents/       → Pi Agent Runtime                         │
│ src/channels/     → Channel Adapters (WhatsApp, etc.)       │
│ src/plugins/      → Plugin System Core                       │
│ src/plugin-sdk/   → Plugin Development API                   │
│ src/browser/      → Browser Control Tool                     │
│ src/canvas-host/  → Canvas A2UI Host                         │
│ src/node-host/    → Node Management                          │
│ src/cron/         → Cron Scheduler                           │
│ src/sessions/     → Session Manager                          │
│ src/web/          → WebChat + Control UI                     │
│ src/cli/          → CLI Interface                            │
│ apps/macos/       → macOS Companion App                      │
│ apps/ios/         → iOS Device Node                          │
│ apps/android/     → Android Device Node                      │
│ packages/         → Standalone Packages (clawdbot, moltbot)  │
└─────────────────────────────────────────────────────────────┘
```

## Performance Characteristics

**Gateway:**
- Single-threaded Node.js event loop
- Concurrent WebSocket connections: 100+ typical
- Message latency: <10ms local routing
- Memory: ~200MB base + session context

**Agent:**
- Streaming responses for low perceived latency
- Token counting for context window management
- Session pruning at configurable thresholds
- Model failover on rate limits

**Channels:**
- Async message handling per channel
- Rate limiting per platform API limits
- Retry logic with exponential backoff
- Chunking for large responses (platform-specific)

## Extensibility Points

1. **Custom Channels**: Implement channel interface in `src/channels/`
2. **Custom Tools**: Register via plugin SDK
3. **Custom Skills**: Markdown skills in workspace
4. **Hooks**: Event-driven pre/post processing
5. **Cron Jobs**: Scheduled automation
6. **Webhooks**: External trigger endpoints
7. **Custom Nodes**: Device capability extensions

## References

- Gateway Protocol: `src/gateway/protocol.ts`
- Tool Registry: `src/gateway/tools.ts`
- Session Manager: `src/sessions/manager.ts`
- Channel Base: `src/channels/base.ts`
- Plugin SDK: `src/plugin-sdk/index.ts`
- Extension API: `src/extensionAPI.ts`
- Entry Point: `src/entry.ts`
- Runtime: `src/runtime.ts`
- Globals: `src/globals.ts`