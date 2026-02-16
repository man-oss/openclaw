# Understanding OpenClaw Architecture - Gateway, Agents, and Channels

OpenClaw is built around a distributed architecture that connects your AI assistant across all your messaging platforms and devices. At its heart is a WebSocket-based control plane that coordinates everything from chat messages to device capabilities.

## The Three Core Components

### Gateway: Your Personal Control Plane

The Gateway is the central hub that runs on your own hardware—whether that's your laptop, a home server, or a cloud instance. Think of it as the brain that keeps everything connected and coordinated.

When you start OpenClaw, the Gateway:
- Opens a WebSocket server (by default on port 18789)
- Manages all your active conversations across different platforms
- Routes messages between channels and your AI assistant
- Coordinates device capabilities like taking photos or recording screens
- Tracks which conversations are active and where they should be delivered

The Gateway stays running in the background and automatically reconnects if your network drops. You can access its web dashboard to monitor active sessions, check system health, and manage settings.

### Agents: The AI Personalities

An Agent is an instance of your AI assistant with its own memory, personality, and context. You can have multiple agents running simultaneously, each handling different types of conversations or tasks.

Each agent:
- Maintains separate conversation histories
- Can be configured with different AI models and behaviors
- Handles incoming messages and generates responses
- Decides when to use tools like web browsing or running commands
- Manages its own thinking level and verbosity settings

For example, you might configure one agent for casual chat on WhatsApp, another for work-related queries on Slack, and a third for automated monitoring tasks.

### Channels: Your Communication Bridges

Channels connect the Gateway to your messaging platforms. Each channel adapter translates between OpenClaw's internal format and the specific protocol of a messaging service.

OpenClaw supports channels for:
- **WhatsApp** - Direct messages and group chats via the Baileys protocol
- **Telegram** - Bot-based integration with full group support
- **Slack** - Workspace integration with thread support
- **Discord** - Server and DM handling with role-based access
- **Google Chat** - Workspace messaging
- **Signal** - End-to-end encrypted messaging
- **iMessage** - MacOS native messaging or BlueBubbles server
- **Microsoft Teams** - Enterprise messaging
- **Matrix, Zalo, IRC, and more** - Via extension modules

Each channel maintains its own connection to its service and forwards messages to the Gateway for processing.

## How Components Work Together

### The Message Flow

When someone sends you a message:

1. **Channel receives** - Your WhatsApp channel adapter gets the incoming message
2. **Gateway routes** - The Gateway determines which agent should handle it based on your routing rules
3. **Agent processes** - The agent considers the conversation context, available tools, and your instructions
4. **Agent responds** - The agent generates a response, possibly using tools like web search or code execution
5. **Channel delivers** - The response goes back through WhatsApp to the original sender

This happens in seconds, and the same flow works across all channels simultaneously.

### Session Management

OpenClaw organizes conversations into sessions. Each session has:
- A unique key that identifies the conversation
- An active agent assigned to handle it
- A message history maintained for context
- Settings like thinking level and model selection

The "main" session handles your direct 1-on-1 chats, while group conversations each get their own isolated session. This prevents context from bleeding between different conversations.

### Multi-Agent Routing

You can configure different agents to handle different channels or even specific contacts. For example:

- Route your personal WhatsApp to Agent A (casual, friendly tone)
- Route work Slack to Agent B (professional, concise responses)
- Route monitoring alerts to Agent C (automated handling with escalation rules)

The Gateway automatically directs incoming messages to the right agent based on your configuration.

## The Device Node System

OpenClaw extends beyond messaging with a device node architecture that connects mobile and desktop apps to the Gateway.

### How Nodes Connect

A node is any device that connects to the Gateway and offers capabilities beyond messaging:

**iOS/Android Nodes** provide:
- Camera access for taking photos or videos
- Screen recording
- Location services
- Canvas display for visual interfaces
- Device notifications and system integration

**macOS Nodes** add:
- Local command execution
- Screen control
- Voice wake word detection
- Push-to-talk integration

Nodes connect to the Gateway as clients and register their available capabilities. When an agent needs to take a photo or show a visual interface, the Gateway routes the request to the appropriate node.

### The Bridge Protocol

Nodes communicate with the Gateway using a structured RPC protocol over WebSocket:

1. Node connects and authenticates
2. Node advertises its capabilities (camera, location, screen, etc.)
3. Gateway can invoke node capabilities with parameters
4. Node executes the request and returns results

This keeps the architecture flexible—you can add new device types without changing the core Gateway.

## Data Flow Architecture

### Upstream: Channel to Gateway to Agent

```
Message arrives → Channel adapter decodes → Gateway routes to session → 
Agent processes → Agent may invoke tools → Agent generates response
```

### Downstream: Agent to Gateway to Channel

```
Agent completes → Gateway routes to channel → Channel adapter encodes → 
Message delivers to platform → User sees response
```

### Tool Invocation Flow

When an agent needs to use a tool:

```
Agent decides to use browser → Gateway checks permissions → 
Gateway invokes browser tool → Tool executes and returns result → 
Agent receives result → Agent continues processing
```

Tools run on the Gateway host by default. For device-specific actions like taking photos, the Gateway forwards the request to the appropriate node.

## Why This Architecture Matters

### You Control Your Data

Because the Gateway runs on your infrastructure, all message processing happens on systems you control. Your conversations never pass through third-party AI services beyond the model API calls you explicitly configure.

### Everything Stays Connected

The persistent WebSocket connections mean your assistant is always reachable across all channels. If your phone loses connection, your desktop node can still respond. If the Gateway restarts, channels automatically reconnect.

### Scale From Simple to Complex

Start with a single agent handling WhatsApp messages. Add more channels as needed. Deploy multiple agents with specialized roles. Run the Gateway on a home server and connect mobile nodes remotely. The architecture supports both simple personal setups and complex multi-agent systems.

### Remote Gateway Flexibility

You can run the Gateway on a dedicated Linux server and connect to it from your laptop or phone. The Gateway handles compute-intensive tasks like AI inference and web browsing, while lightweight node clients run on your devices for local actions. Access the Gateway's web dashboard through Tailscale for secure remote management.

## Extension System: Skills and Custom Channels

OpenClaw's extension system adds capabilities beyond the core:

### Skills

Skills are packaged tools that agents can discover and use. The `skills/` directory contains dozens of pre-built skills like:
- Note-taking integrations (Obsidian, Notion, Apple Notes)
- Smart home control (Philips Hue, Sonos)
- Development tools (GitHub integration, code analysis)
- Media handling (video frame extraction, image generation)

Skills are automatically discovered and can be installed through the ClawHub registry.

### Channel Extensions

The `extensions/` directory contains additional channel adapters that aren't part of the core build:
- Alternative messaging platforms (Matrix, Mattermost, LINE)
- Voice call integration
- Authentication helpers for specific AI services
- Memory systems for long-term context

Extensions follow the same channel protocol as core integrations, making them first-class citizens in the routing system.

## Security and Isolation

### Pairing and Access Control

By default, unknown contacts must complete a pairing flow before the agent will respond. This prevents strangers from using your assistant without permission.

Each channel maintains an allowlist of approved contacts. The Gateway can require authentication tokens or passwords for web dashboard access.

### Sandbox Mode for Groups

When running in group channels or public spaces, you can enable sandbox mode to isolate tool execution. This runs commands in Docker containers instead of directly on your host, limiting what the agent can access.

The permission system lets you control which tools are available in different contexts—full access for your personal chats, restricted access for group channels.

## Real-World Connection Flow

Here's what happens when you set up OpenClaw:

1. **Start the Gateway** - Run `openclaw gateway` on your computer or server
2. **Connect channels** - Link WhatsApp, Telegram, or other platforms through the onboarding wizard
3. **Pair devices** - Connect your iPhone or Android app to add device capabilities
4. **Configure agents** - Set personality, model selection, and routing rules
5. **Start chatting** - Send a message on any connected channel and get responses powered by your AI

The Gateway maintains all connections, the agent processes your messages with full context, and channels deliver responses back to you—all coordinated through the WebSocket control plane.

This architecture makes OpenClaw both powerful and flexible while keeping you in control of how and where your AI assistant runs.