# Plugin and Extension Architecture

## Overview

OpenClaw implements a flexible plugin and extension system that allows developers to extend the platform's capabilities through modular components. The architecture consists of three main layers: core plugin infrastructure, provider plugins, and extensions/skills that implement specific functionality.

**Key Components:**
- **Plugin System** (`src/plugins/`): Core infrastructure for plugin discovery, loading, and lifecycle management
- **Plugin SDK** (`src/plugin-sdk/`): Development interfaces and utilities for plugin authors
- **Skills** (`skills/`): Modular capabilities that extend agent functionality
- **Extensions** (`extensions/`): Platform integrations and provider implementations

## Plugin System Architecture

### Core Plugin Types

OpenClaw supports multiple plugin types defined in `src/plugins/types.ts`:

```typescript
// Core plugin interface from types.ts
export interface Plugin {
  manifest: PluginManifest;
  hooks?: PluginHooks;
  providers?: PluginProviders;
  tools?: PluginTools;
  slots?: PluginSlots;
}

export interface PluginManifest {
  id: string;
  name: string;
  version: string;
  description?: string;
  main?: string;
  runtime?: PluginRuntime;
  dependencies?: Record<string, string>;
}
```

**Plugin Types:**
1. **Provider Plugins**: LLM providers, gateway providers, authentication providers
2. **Skill Plugins**: Agent capabilities (tools, integrations, commands)
3. **Extension Plugins**: Platform extensions (chat platforms, memory systems)

### Plugin Discovery and Loading

The plugin system uses a multi-source discovery mechanism implemented in `src/plugins/discovery.ts`:

```typescript
// Discovery sources
export async function discoverPlugins(
  options: DiscoverOptions = {}
): Promise<PluginSource[]> {
  const sources: PluginSource[] = [];
  
  // 1. Bundled plugins (built-in)
  sources.push(...await discoverBundledPlugins());
  
  // 2. Installed plugins from plugin directory
  sources.push(...await discoverInstalledPlugins());
  
  // 3. Local development plugins
  if (options.includeLocal) {
    sources.push(...await discoverLocalPlugins());
  }
  
  return sources;
}
```

**Discovery Process:**
1. **Bundled Discovery** (`src/plugins/bundled-dir.ts`): Scans built-in plugins
2. **Installed Discovery**: Searches plugin installation directory
3. **Local Discovery**: Finds plugins in development mode
4. **HTTP Registry** (`src/plugins/http-registry.ts`): Remote plugin catalog

### Plugin Loader

The loader (`src/plugins/loader.ts`) handles plugin instantiation and initialization:

```typescript
export class PluginLoader {
  async loadPlugin(source: PluginSource): Promise<LoadedPlugin> {
    // 1. Validate manifest
    const manifest = await this.loadManifest(source);
    validateManifest(manifest);
    
    // 2. Load module based on runtime
    const module = await this.loadModule(source, manifest);
    
    // 3. Initialize plugin
    const plugin = await this.initializePlugin(module, manifest);
    
    // 4. Register hooks and providers
    await this.registerPlugin(plugin);
    
    return plugin;
  }
  
  private async loadModule(source: PluginSource, manifest: PluginManifest) {
    switch (manifest.runtime) {
      case 'typescript':
      case 'javascript':
        return await import(source.path);
      case 'executable':
        return this.loadExecutablePlugin(source);
      default:
        throw new Error(`Unsupported runtime: ${manifest.runtime}`);
    }
  }
}
```

**Loading Steps:**
1. Manifest validation against schema (`src/plugins/manifest.ts`)
2. Runtime-specific module loading
3. Plugin initialization with context
4. Hook and provider registration

### Plugin Registry

The registry (`src/plugins/registry.ts`) maintains plugin state and provides access:

```typescript
export class PluginRegistry {
  private plugins = new Map<string, LoadedPlugin>();
  private manifests = new Map<string, PluginManifest>();
  
  register(plugin: LoadedPlugin): void {
    this.plugins.set(plugin.manifest.id, plugin);
    this.manifests.set(plugin.manifest.id, plugin.manifest);
    this.emit('plugin:registered', plugin);
  }
  
  get(id: string): LoadedPlugin | undefined {
    return this.plugins.get(id);
  }
  
  list(): LoadedPlugin[] {
    return Array.from(this.plugins.values());
  }
  
  async enable(id: string): Promise<void> {
    const plugin = this.get(id);
    if (!plugin) throw new Error(`Plugin not found: ${id}`);
    
    await this.runHook(plugin, 'onEnable');
    plugin.enabled = true;
    this.emit('plugin:enabled', plugin);
  }
  
  async disable(id: string): Promise<void> {
    const plugin = this.get(id);
    if (!plugin) throw new Error(`Plugin not found: ${id}`);
    
    await this.runHook(plugin, 'onDisable');
    plugin.enabled = false;
    this.emit('plugin:disabled', plugin);
  }
}
```

## Plugin Lifecycle

### Lifecycle Phases

Plugins progress through defined lifecycle phases managed by the plugin system:

```typescript
// From types.ts
export type PluginState = 
  | 'discovered'
  | 'loading'
  | 'loaded'
  | 'initializing'
  | 'ready'
  | 'enabled'
  | 'disabled'
  | 'error'
  | 'unloading';

export interface PluginHooks {
  onLoad?(): Promise<void> | void;
  onEnable?(): Promise<void> | void;
  onDisable?(): Promise<void> | void;
  onUnload?(): Promise<void> | void;
  onInstall?(): Promise<void> | void;
  onUninstall?(): Promise<void> | void;
}
```

**Lifecycle Flow:**

1. **Discovery**: Plugin source identified
2. **Loading**: Manifest read, module loaded
3. **Initialization**: `onLoad()` hook called
4. **Ready**: Plugin available for enablement
5. **Enabled**: `onEnable()` hook called, plugin active
6. **Disabled**: `onDisable()` hook called, plugin inactive
7. **Unloading**: `onUnload()` hook called, cleanup

### Hook System

The hook system (`src/plugins/hooks.ts`) provides extension points throughout the application lifecycle:

```typescript
export interface HookDefinitions {
  // Session lifecycle
  'session:start': (context: SessionContext) => void;
  'session:end': (context: SessionContext) => void;
  
  // Message lifecycle
  'message:received': (message: Message) => void | Message;
  'message:sent': (message: Message) => void | Message;
  
  // LLM lifecycle
  'llm:before': (request: LLMRequest) => void | LLMRequest;
  'llm:after': (response: LLMResponse) => void | LLMResponse;
  
  // Tool execution
  'tool:before': (call: ToolCall) => void | ToolCall;
  'tool:after': (result: ToolResult) => void | ToolResult;
  
  // Compaction
  'compaction:before': (messages: Message[]) => void | Message[];
  'compaction:after': (result: CompactionResult) => void;
  
  // Gateway
  'gateway:message': (message: GatewayMessage) => void | GatewayMessage;
}

export class HookRunner {
  private hooks = new Map<string, HookHandler[]>();
  
  register<T extends keyof HookDefinitions>(
    event: T,
    handler: HookDefinitions[T]
  ): void {
    const handlers = this.hooks.get(event) || [];
    handlers.push(handler);
    this.hooks.set(event, handlers);
  }
  
  async run<T extends keyof HookDefinitions>(
    event: T,
    data: Parameters<HookDefinitions[T]>[0]
  ): Promise<ReturnType<HookDefinitions[T]>> {
    const handlers = this.hooks.get(event) || [];
    let result = data;
    
    for (const handler of handlers) {
      const newResult = await handler(result);
      if (newResult !== undefined) {
        result = newResult;
      }
    }
    
    return result;
  }
}
```

**Available Hooks:**
- **Session Hooks**: `session:start`, `session:end`
- **Message Hooks**: `message:received`, `message:sent`
- **LLM Hooks**: `llm:before`, `llm:after`
- **Tool Hooks**: `tool:before`, `tool:after`
- **Compaction Hooks**: `compaction:before`, `compaction:after`
- **Gateway Hooks**: `gateway:message`

### Hook Registration

Plugins register hooks during initialization (`src/plugins/loader.ts`):

```typescript
private async registerPluginHooks(plugin: LoadedPlugin): Promise<void> {
  if (!plugin.hooks) return;
  
  const runner = getGlobalHookRunner();
  
  for (const [event, handler] of Object.entries(plugin.hooks)) {
    if (typeof handler === 'function') {
      runner.register(event, handler.bind(plugin));
    }
  }
}
```

## Provider Plugin Architecture

### Provider Types

Provider plugins implement platform capabilities through standardized interfaces (`src/plugins/providers.ts`):

```typescript
export interface PluginProviders {
  llm?: LLMProvider[];
  gateway?: GatewayProvider[];
  auth?: AuthProvider[];
  memory?: MemoryProvider[];
}

// LLM Provider Interface
export interface LLMProvider {
  id: string;
  name: string;
  chat(request: ChatRequest): Promise<ChatResponse>;
  streamChat?(request: ChatRequest): AsyncGenerator<ChatChunk>;
  listModels?(): Promise<Model[]>;
}

// Gateway Provider Interface
export interface GatewayProvider {
  id: string;
  name: string;
  initialize(): Promise<void>;
  sendMessage(message: OutboundMessage): Promise<void>;
  onMessage(handler: MessageHandler): void;
}

// Auth Provider Interface
export interface AuthProvider {
  id: string;
  name: string;
  authenticate(credentials: Credentials): Promise<AuthResult>;
  refresh?(token: RefreshToken): Promise<AuthResult>;
  validate?(token: Token): Promise<boolean>;
}
```

**Provider Categories:**

1. **LLM Providers**: Language model integrations (OpenAI, Anthropic, local models)
2. **Gateway Providers**: Chat platform connectors (Slack, Discord, Telegram)
3. **Auth Providers**: Authentication mechanisms (OAuth, API keys, portal auth)
4. **Memory Providers**: Long-term memory systems (LanceDB, vector stores)

### Provider Registration

Providers register through the plugin manifest and are made available to the core system:

```typescript
// From manifest.ts
export interface PluginManifest {
  id: string;
  name: string;
  version: string;
  providers?: {
    llm?: string[];      // IDs of LLM providers
    gateway?: string[];  // IDs of gateway providers
    auth?: string[];     // IDs of auth providers
    memory?: string[];   // IDs of memory providers
  };
}

// Provider registration in loader
private async registerProviders(plugin: LoadedPlugin): Promise<void> {
  if (!plugin.providers) return;
  
  const registry = getProviderRegistry();
  
  if (plugin.providers.llm) {
    for (const provider of plugin.providers.llm) {
      registry.registerLLM(provider);
    }
  }
  
  if (plugin.providers.gateway) {
    for (const provider of plugin.providers.gateway) {
      registry.registerGateway(provider);
    }
  }
  
  // Similar for auth and memory providers
}
```

### Provider Implementation Example

Auth providers demonstrate the provider pattern (reference `extensions/google-gemini-cli-auth/`):

```typescript
import { definePlugin } from '@openclaw/plugin-sdk';

export default definePlugin({
  manifest: {
    id: 'google-gemini-cli-auth',
    name: 'Google Gemini CLI Auth',
    version: '1.0.0',
    description: 'CLI-based authentication for Google Gemini'
  },
  
  providers: {
    auth: [{
      id: 'gemini-cli',
      name: 'Gemini CLI Auth',
      
      async authenticate(credentials) {
        // 1. Launch CLI auth flow
        const authUrl = await getAuthUrl();
        
        // 2. Open browser for user consent
        await openBrowser(authUrl);
        
        // 3. Wait for callback with token
        const token = await waitForCallback();
        
        // 4. Return auth result
        return {
          success: true,
          token,
          expiresIn: 3600
        };
      },
      
      async refresh(token) {
        // Refresh token logic
        const newToken = await refreshToken(token);
        return {
          success: true,
          token: newToken,
          expiresIn: 3600
        };
      }
    }]
  }
});
```

## Plugin SDK

### SDK Core

The Plugin SDK (`src/plugin-sdk/index.ts`) provides utilities and interfaces for plugin development:

```typescript
// Plugin definition helper
export function definePlugin(config: PluginConfig): Plugin {
  return {
    manifest: config.manifest,
    hooks: config.hooks,
    providers: config.providers,
    tools: config.tools,
    slots: config.slots
  };
}

// Configuration management
export function getConfig<T = any>(path: string): T {
  return getConfigValue(path);
}

export function setConfig(path: string, value: any): void {
  setConfigValue(path, value);
}

// File locking utilities
export class FileLock {
  constructor(private path: string) {}
  
  async acquire(): Promise<void> {
    // Acquire exclusive file lock
  }
  
  async release(): Promise<void> {
    // Release file lock
  }
  
  async withLock<T>(fn: () => Promise<T>): Promise<T> {
    await this.acquire();
    try {
      return await fn();
    } finally {
      await this.release();
    }
  }
}
```

**SDK Modules:**
- **Configuration**: `config-paths.ts` - Config file location and access
- **File Locking**: `file-lock.ts` - Concurrent access control
- **Status Helpers**: `status-helpers.ts` - Plugin status management
- **Onboarding**: `onboarding.ts` - User setup flows
- **Text Chunking**: `text-chunking.ts` - Text processing utilities
- **Webhook/HTTP**: `webhook-path.ts`, `http-path.ts` - HTTP utilities

### Plugin Configuration

Plugins manage configuration through the config system:

```typescript
// From plugin-sdk/config-paths.ts
export function getPluginConfigPath(pluginId: string): string {
  return path.join(getConfigDir(), 'plugins', pluginId);
}

export function getPluginDataPath(pluginId: string): string {
  return path.join(getDataDir(), 'plugins', pluginId);
}

// Usage in plugin
import { getConfig, setConfig } from '@openclaw/plugin-sdk';

// Read plugin config
const apiKey = getConfig('plugins.my-plugin.apiKey');

// Write plugin config
setConfig('plugins.my-plugin.apiKey', 'new-key');
```

### Tools and Slots

Plugins can register tools (agent capabilities) and slots (UI extension points):

```typescript
// From types.ts
export interface PluginTools {
  [toolName: string]: ToolDefinition;
}

export interface ToolDefinition {
  description: string;
  parameters: JSONSchema;
  execute(params: any, context: ToolContext): Promise<ToolResult>;
}

export interface PluginSlots {
  [slotName: string]: SlotComponent;
}

// Tool registration
export default definePlugin({
  tools: {
    searchWeb: {
      description: 'Search the web for information',
      parameters: {
        type: 'object',
        properties: {
          query: { type: 'string', description: 'Search query' }
        },
        required: ['query']
      },
      async execute(params, context) {
        const results = await performSearch(params.query);
        return { results };
      }
    }
  }
});
```

## Plugin Installation and Management

### Installation Process

The installation system (`src/plugins/install.ts`) handles plugin installation from various sources:

```typescript
export async function installPlugin(
  source: string,
  options: InstallOptions = {}
): Promise<InstallResult> {
  // 1. Resolve plugin source
  const resolved = await resolvePluginSource(source);
  
  // 2. Download/copy plugin
  const tempPath = await downloadPlugin(resolved);
  
  // 3. Validate plugin
  await validatePlugin(tempPath);
  
  // 4. Install to plugin directory
  const installPath = await installToDirectory(tempPath);
  
  // 5. Run onInstall hook
  const plugin = await loadPlugin(installPath);
  await plugin.hooks?.onInstall?.();
  
  // 6. Update plugin registry
  await updatePluginRegistry(plugin);
  
  return {
    success: true,
    pluginId: plugin.manifest.id,
    path: installPath
  };
}
```

**Installation Sources:**
- **HTTP Registry**: `@org/plugin-name` or URL
- **Local Path**: `file:///path/to/plugin`
- **Git Repository**: `git+https://github.com/user/plugin`
- **npm Package**: `npm:package-name`

### Plugin Commands

CLI commands for plugin management (`src/plugins/commands.ts`):

```typescript
// List installed plugins
export async function listPlugins(): Promise<PluginInfo[]> {
  const registry = getPluginRegistry();
  return registry.list().map(plugin => ({
    id: plugin.manifest.id,
    name: plugin.manifest.name,
    version: plugin.manifest.version,
    enabled: plugin.enabled,
    state: plugin.state
  }));
}

// Enable/disable plugin
export async function enablePlugin(id: string): Promise<void> {
  const registry = getPluginRegistry();
  await registry.enable(id);
}

export async function disablePlugin(id: string): Promise<void> {
  const registry = getPluginRegistry();
  await registry.disable(id);
}

// Install plugin
export async function installPlugin(source: string): Promise<void> {
  await install(source);
}

// Uninstall plugin
export async function uninstallPlugin(id: string): Promise<void> {
  await uninstall(id);
}

// Update plugin
export async function updatePlugin(id: string): Promise<void> {
  await update(id);
}
```

### Plugin Configuration State

Configuration persistence (`src/plugins/config-state.ts`):

```typescript
export class PluginConfigState {
  private configPath: string;
  private state: PluginState = {};
  
  async load(): Promise<void> {
    const data = await fs.readFile(this.configPath, 'utf-8');
    this.state = JSON.parse(data);
  }
  
  async save(): Promise<void> {
    await fs.writeFile(
      this.configPath,
      JSON.stringify(this.state, null, 2)
    );
  }
  
  getPluginState(id: string): PluginStateData | undefined {
    return this.state[id];
  }
  
  setPluginState(id: string, state: PluginStateData): void {
    this.state[id] = state;
  }
  
  async enablePlugin(id: string): Promise<void> {
    this.state[id] = { ...this.state[id], enabled: true };
    await this.save();
  }
  
  async disablePlugin(id: string): Promise<void> {
    this.state[id] = { ...this.state[id], enabled: false };
    await this.save();
  }
}
```

## Skills Architecture

### Skills Overview

Skills are specialized plugins that add agent capabilities. Each skill in `skills/` implements specific functionality through tools and hooks.

**Skill Categories:**
- **Productivity**: Notes (Apple Notes, Obsidian, Notion), Tasks (Apple Reminders, Things)
- **Communication**: Messaging (iMessage, BlueBubbles), Email (Himalaya)
- **Development**: GitHub, Coding Agent, Canvas
- **Media**: Spotify, Sonos, Camera Capture
- **Smart Home**: OpenHue, IoT Control
- **AI Services**: OpenAI (Whisper, DALL-E), Gemini

### Skill Structure

Standard skill structure (reference `skills/github/`):

```
skills/github/
├── claw.json          # Skill manifest
├── src/
│   ├── index.ts       # Main entry point
│   ├── tools/         # Tool implementations
│   │   ├── list-repos.ts
│   │   ├── create-issue.ts
│   │   └── search-code.ts
│   ├── auth.ts        # Authentication logic
│   └── api.ts         # API client
├── README.md
└── package.json
```

**Manifest Example** (`claw.json`):

```json
{
  "id": "github",
  "name": "GitHub",
  "version": "1.0.0",
  "description": "GitHub integration for repository and issue management",
  "main": "dist/index.js",
  "runtime": "typescript",
  "tools": [
    "listRepositories",
    "createIssue",
    "searchCode",
    "getPullRequest"
  ],
  "permissions": [
    "network",
    "config:github"
  ]
}
```

### Skill Tool Implementation

Tools follow a standard pattern:

```typescript
// skills/github/src/tools/list-repos.ts
import { definePlugin } from '@openclaw/plugin-sdk';

export default definePlugin({
  tools: {
    listRepositories: {
      description: 'List GitHub repositories for a user or organization',
      parameters: {
        type: 'object',
        properties: {
          owner: {
            type: 'string',
            description: 'GitHub username or organization'
          },
          type: {
            type: 'string',
            enum: ['all', 'owner', 'member'],
            default: 'owner'
          }
        },
        required: ['owner']
      },
      
      async execute(params, context) {
        const { owner, type = 'owner' } = params;
        
        // 1. Get GitHub token from config
        const token = getConfig('plugins.github.token');
        
        // 2. Call GitHub API
        const repos = await fetchRepositories(owner, type, token);
        
        // 3. Return formatted results
        return {
          repositories: repos.map(repo => ({
            name: repo.name,
            fullName: repo.full_name,
            description: repo.description,
            stars: repo.stargazers_count,
            url: repo.html_url
          }))
        };
      }
    }
  }
});
```

## Extensions Architecture

### Extensions Overview

Extensions provide platform integrations and infrastructure capabilities. Located in `extensions/`, they typically implement gateway providers or system-level functionality.

**Extension Categories:**
- **Chat Platforms**: Slack, Discord, Telegram, WhatsApp, Matrix
- **Voice/Video**: Voice Call, Talk Voice
- **Enterprise**: Microsoft Teams, Google Chat, Mattermost
- **Memory Systems**: Memory Core, LanceDB Integration
- **Auth Providers**: Google Gemini CLI Auth, Minimax Portal Auth
- **Utilities**: Device Pair, Diagnostics (OpenTelemetry)

### Extension Structure

Standard extension structure (reference `extensions/slack/`):

```
extensions/slack/
├── claw.json          # Extension manifest
├── src/
│   ├── index.ts       # Main entry point
│   ├── gateway.ts     # Gateway provider implementation
│   ├── auth.ts        # OAuth flow
│   ├── events.ts      # Event handlers
│   └── api.ts         # Slack API client
├── README.md
└── package.json
```

### Gateway Provider Implementation

Gateway extensions implement the `GatewayProvider` interface:

```typescript
// extensions/slack/src/gateway.ts
import { definePlugin } from '@openclaw/plugin-sdk';

export default definePlugin({
  manifest: {
    id: 'slack',
    name: 'Slack',
    version: '1.0.0',
    description: 'Slack gateway integration'
  },
  
  providers: {
    gateway: [{
      id: 'slack',
      name: 'Slack',
      
      async initialize() {
        // 1. Load configuration
        const token = getConfig('plugins.slack.botToken');
        
        // 2. Initialize Slack client
        this.client = new SlackClient(token);
        
        // 3. Connect to events API
        await this.client.connect();
        
        // 4. Register event handlers
        this.client.on('message', this.handleMessage.bind(this));
      },
      
      async sendMessage(message: OutboundMessage) {
        await this.client.sendMessage({
          channel: message.channelId,
          text: message.text,
          attachments: message.attachments
        });
      },
      
      onMessage(handler: MessageHandler) {
        this.messageHandler = handler;
      },
      
      private async handleMessage(event: SlackMessageEvent) {
        // Convert Slack message to internal format
        const message = {
          id: event.ts,
          text: event.text,
          userId: event.user,
          channelId: event.channel,
          timestamp: new Date(parseFloat(event.ts) * 1000)
        };
        
        // Pass to registered handler
        if (this.messageHandler) {
          await this.messageHandler(message);
        }
      }
    }]
  },
  
  hooks: {
    async onEnable() {
      // Initialize gateway when enabled
      await this.providers.gateway[0].initialize();
    },
    
    async onDisable() {
      // Cleanup when disabled
      await this.client?.disconnect();
    }
  }
});
```

### Memory Provider Extensions

Memory extensions implement long-term storage (`extensions/memory-lancedb/`):

```typescript
export default definePlugin({
  manifest: {
    id: 'memory-lancedb',
    name: 'LanceDB Memory',
    version: '1.0.0'
  },
  
  providers: {
    memory: [{
      id: 'lancedb',
      name: 'LanceDB',
      
      async initialize() {
        this.db = await lancedb.connect(getPluginDataPath('memory-lancedb'));
        this.table = await this.db.openTable('memories');
      },
      
      async store(memory: Memory) {
        // 1. Generate embedding
        const embedding = await generateEmbedding(memory.content);
        
        // 2. Store in LanceDB
        await this.table.add({
          id: memory.id,
          content: memory.content,
          embedding,
          timestamp: memory.timestamp,
          metadata: memory.metadata
        });
      },
      
      async search(query: string, limit = 10) {
        // 1. Generate query embedding
        const queryEmbedding = await generateEmbedding(query);
        
        // 2. Vector search
        const results = await this.table
          .search(queryEmbedding)
          .limit(limit)
          .execute();
        
        return results.map(r => ({
          id: r.id,
          content: r.content,
          similarity: r.score,
          metadata: r.metadata
        }));
      }
    }]
  }
});
```

## Plugin Development Patterns

### Standard Plugin Template

```typescript
import { definePlugin, getConfig, setConfig } from '@openclaw/plugin-sdk';

export default definePlugin({
  manifest: {
    id: 'my-plugin',
    name: 'My Plugin',
    version: '1.0.0',
    description: 'Plugin description',
    runtime: 'typescript'
  },
  
  hooks: {
    async onLoad() {
      // Initialize plugin resources
    },
    
    async onEnable() {
      // Activate plugin functionality
    },
    
    async onDisable() {
      // Deactivate and cleanup
    },
    
    async onUnload() {
      // Release all resources
    }
  },
  
  tools: {
    myTool: {
      description: 'Tool description',
      parameters: {
        type: 'object',
        properties: {
          param: { type: 'string' }
        }
      },
      async execute(params, context) {
        // Tool implementation
        return { result: 'success' };
      }
    }
  },
  
  providers: {
    // Provider implementations
  }
});
```

### Configuration Management

```typescript
// Reading configuration
const config = getConfig('plugins.my-plugin');
const apiKey = getConfig('plugins.my-plugin.apiKey');

// Writing configuration
setConfig('plugins.my-plugin.apiKey', 'new-key');
setConfig('plugins.my-plugin.settings', {
  enabled: true,
  timeout: 5000
});

// Using file locks for concurrent access
import { FileLock } from '@openclaw/plugin-sdk';

const lock = new FileLock(getPluginConfigPath('my-plugin'));
await lock.withLock(async () => {
  const config = getConfig('plugins.my-plugin');
  config.counter++;
  setConfig('plugins.my-plugin', config);
});
```

### Error Handling

```typescript
export default definePlugin({
  tools: {
    riskyOperation: {
      description: 'Operation that might fail',
      parameters: { type: 'object' },
      
      async execute(params, context) {
        try {
          const result = await performOperation();
          return { success: true, result };
        } catch (error) {
          // Log error
          context.logger.error('Operation failed', error);
          
          // Return error to agent
          return {
            success: false,
            error: error.message,
            code: 'OPERATION_FAILED'
          };
        }
      }
    }
  }
});
```

### Async Hooks

```typescript
export default definePlugin({
  hooks: {
    async 'message:received'(message) {
      // Transform incoming message
      if (message.text.includes('translate:')) {
        const translated = await translateMessage(message.text);
        return { ...message, text: translated };
      }
      return message;
    },
    
    async 'tool:before'(call) {
      // Add logging before tool execution
      console.log(`Executing tool: ${call.name}`);
      return call;
    },
    
    async 'tool:after'(result) {
      // Process tool results
      if (result.error) {
        await logError(result.error);
      }
      return result;
    }
  }