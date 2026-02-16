# Plugin SDK API Reference

OpenClaw's Plugin SDK provides a comprehensive set of interfaces, types, and utilities for building provider plugins that extend the platform's messaging capabilities. This reference documents all public APIs available to plugin developers.

## Overview

**Location:** `src/plugin-sdk/`  
**Package Export:** `openclaw/plugin-sdk`

The SDK is exported as a standalone package entry point via `package.json`:

```json
"./plugin-sdk": {
  "types": "./dist/plugin-sdk/index.d.ts",
  "default": "./dist/plugin-sdk/index.js"
}
```

## Core SDK Exports

All public APIs are exported from `src/plugin-sdk/index.ts`, which serves as the main entry point for plugin developers.

---

## Type Definitions

### AccountId

**File:** `src/plugin-sdk/account-id.ts`

Brand type for account identifiers.

```typescript
export type AccountId = string & { readonly __brand: 'AccountId' };
```

**Usage:** Type-safe wrapper for account ID strings to prevent mixing with regular strings.

---

### AgentMediaPayload

**File:** `src/plugin-sdk/agent-media-payload.ts`

Defines media payloads that can be sent through agent communications.

```typescript
export interface AgentMediaPayload {
  type: 'image' | 'audio' | 'video' | 'file';
  url?: string;
  data?: Buffer | Uint8Array;
  mimeType?: string;
  filename?: string;
  caption?: string;
}
```

**Properties:**
- `type`: Media content type
- `url`: Optional remote URL for media
- `data`: Optional binary data buffer
- `mimeType`: MIME type identifier
- `filename`: Original or suggested filename
- `caption`: Optional text caption for media

**Common MIME Types:**
- Images: `image/png`, `image/jpeg`, `image/gif`, `image/webp`
- Audio: `audio/mpeg`, `audio/ogg`, `audio/wav`
- Video: `video/mp4`, `video/webm`
- Files: `application/pdf`, `application/zip`, etc.

---

### AllowFrom

**File:** `src/plugin-sdk/allow-from.ts`

Configuration for filtering allowed message sources.

```typescript
export interface AllowFromConfig {
  userIds?: string[];
  groupIds?: string[];
  patterns?: RegExp[];
}

export function createAllowFromFilter(config: AllowFromConfig): (senderId: string) => boolean;
```

**Usage Example:**

```typescript
const filter = createAllowFromFilter({
  userIds: ['user123', 'user456'],
  patterns: [/^admin-/]
});

if (filter(senderId)) {
  // Process message
}
```

---

### ProviderAuthResult

**File:** `src/plugin-sdk/provider-auth-result.ts`

Return type for provider authentication operations.

```typescript
export interface ProviderAuthSuccess {
  success: true;
  accountId: AccountId;
  credentials: Record<string, unknown>;
  displayName?: string;
  metadata?: Record<string, unknown>;
}

export interface ProviderAuthFailure {
  success: false;
  error: string;
  retryable?: boolean;
}

export type ProviderAuthResult = ProviderAuthSuccess | ProviderAuthFailure;
```

**Properties:**

**ProviderAuthSuccess:**
- `success`: Always `true`
- `accountId`: Unique account identifier
- `credentials`: Platform-specific auth tokens/credentials
- `displayName`: Human-readable account name
- `metadata`: Additional provider-specific data

**ProviderAuthFailure:**
- `success`: Always `false`
- `error`: Human-readable error message
- `retryable`: Whether authentication can be retried

**Usage Example:**

```typescript
async function authenticate(config: AuthConfig): Promise<ProviderAuthResult> {
  try {
    const session = await provider.login(config);
    return {
      success: true,
      accountId: session.userId as AccountId,
      credentials: { token: session.token },
      displayName: session.username
    };
  } catch (error) {
    return {
      success: false,
      error: error.message,
      retryable: error.code === 'NETWORK_ERROR'
    };
  }
}
```

---

## Configuration Utilities

### ConfigPaths

**File:** `src/plugin-sdk/config-paths.ts`

Utilities for managing plugin configuration file locations.

```typescript
export interface ConfigPaths {
  getConfigDir(): string;
  getPluginConfigPath(pluginName: string): string;
  getPluginDataPath(pluginName: string): string;
  ensurePluginDirs(pluginName: string): Promise<void>;
}

export function createConfigPaths(baseDir?: string): ConfigPaths;
```

**Methods:**

- `getConfigDir()`: Returns base configuration directory
- `getPluginConfigPath(pluginName)`: Returns path to plugin's config file
- `getPluginDataPath(pluginName)`: Returns path to plugin's data directory
- `ensurePluginDirs(pluginName)`: Creates necessary directories for plugin

**Usage Example:**

```typescript
const paths = createConfigPaths();
await paths.ensurePluginDirs('my-provider');
const configPath = paths.getPluginConfigPath('my-provider');
// configPath: ~/.openclaw/plugins/my-provider/config.json
```

---

### WebhookPath

**File:** `src/plugin-sdk/webhook-path.ts`

Utilities for constructing webhook URLs and paths.

```typescript
export interface WebhookPathOptions {
  providerId: string;
  accountId: AccountId;
  endpoint?: string;
}

export function createWebhookPath(options: WebhookPathOptions): string;
export function parseWebhookPath(path: string): WebhookPathOptions | null;
```

**Usage Example:**

```typescript
const webhookPath = createWebhookPath({
  providerId: 'telegram',
  accountId: 'bot123' as AccountId,
  endpoint: 'callback'
});
// Returns: /webhooks/telegram/bot123/callback

const parsed = parseWebhookPath('/webhooks/telegram/bot123/callback');
// Returns: { providerId: 'telegram', accountId: 'bot123', endpoint: 'callback' }
```

---

## File System Utilities

### FileLock

**File:** `src/plugin-sdk/file-lock.ts`

Cross-process file locking for coordinating access to shared resources.

```typescript
export interface FileLockOptions {
  lockfilePath: string;
  retries?: number;
  retryDelay?: number;
  stale?: number;
}

export class FileLock {
  constructor(options: FileLockOptions);
  
  async acquire(): Promise<void>;
  async release(): Promise<void>;
  async withLock<T>(fn: () => Promise<T>): Promise<T>;
}
```

**Properties:**

- `lockfilePath`: Path to lockfile
- `retries`: Number of retry attempts (default: 10)
- `retryDelay`: Delay between retries in ms (default: 100)
- `stale`: Time in ms before lock considered stale (default: 10000)

**Methods:**

- `acquire()`: Acquire lock (throws if unavailable after retries)
- `release()`: Release lock
- `withLock(fn)`: Execute function with automatic lock management

**Usage Example:**

```typescript
const lock = new FileLock({
  lockfilePath: '/tmp/my-plugin.lock',
  retries: 5,
  retryDelay: 200
});

// Manual lock management
await lock.acquire();
try {
  // Critical section
  await updateSharedResource();
} finally {
  await lock.release();
}

// Automatic lock management
await lock.withLock(async () => {
  await updateSharedResource();
});
```

---

## Onboarding Utilities

### Onboarding

**File:** `src/plugin-sdk/onboarding.ts`

Helpers for provider onboarding flows.

```typescript
export interface OnboardingStep {
  id: string;
  title: string;
  description?: string;
  type: 'input' | 'select' | 'confirm' | 'oauth';
  required?: boolean;
  default?: unknown;
  options?: Array<{ label: string; value: string }>;
  validate?: (value: unknown) => boolean | string;
}

export interface OnboardingFlow {
  steps: OnboardingStep[];
  title: string;
  description?: string;
}

export function createOnboardingFlow(config: OnboardingFlow): OnboardingFlow;
```

**Step Types:**

- `input`: Text input field
- `select`: Dropdown selection
- `confirm`: Yes/no confirmation
- `oauth`: OAuth authorization flow

**Usage Example:**

```typescript
const flow = createOnboardingFlow({
  title: 'Connect Telegram Bot',
  description: 'Configure your Telegram bot credentials',
  steps: [
    {
      id: 'bot_token',
      title: 'Bot Token',
      description: 'Enter your bot token from @BotFather',
      type: 'input',
      required: true,
      validate: (value) => {
        if (typeof value !== 'string') return 'Token must be a string';
        if (!value.match(/^\d+:[A-Za-z0-9_-]+$/)) {
          return 'Invalid bot token format';
        }
        return true;
      }
    },
    {
      id: 'enable_webhook',
      title: 'Enable Webhook',
      type: 'confirm',
      default: true
    }
  ]
});
```

---

## Status Helpers

**File:** `src/plugin-sdk/status-helpers.ts`

Utilities for creating standardized status responses.

```typescript
export type ConnectionStatus = 'connected' | 'disconnected' | 'connecting' | 'error';

export interface StatusResponse {
  status: ConnectionStatus;
  message?: string;
  details?: Record<string, unknown>;
  timestamp: number;
}

export function createStatusResponse(
  status: ConnectionStatus,
  message?: string,
  details?: Record<string, unknown>
): StatusResponse;

export function createErrorStatus(error: Error | string): StatusResponse;
export function createConnectedStatus(details?: Record<string, unknown>): StatusResponse;
export function createDisconnectedStatus(message?: string): StatusResponse;
```

**Usage Example:**

```typescript
// Success status
const status = createConnectedStatus({
  accountId: 'user123',
  username: 'mybot'
});

// Error status
try {
  await connect();
} catch (error) {
  return createErrorStatus(error);
}

// Custom status
const customStatus = createStatusResponse('connecting', 'Establishing WebSocket connection', {
  attempt: 2,
  maxAttempts: 5
});
```

---

## Text Processing

### TextChunking

**File:** `src/plugin-sdk/text-chunking.ts`

Utilities for splitting text into chunks that respect message size limits.

```typescript
export interface ChunkOptions {
  maxLength: number;
  preserveWords?: boolean;
  separator?: string;
  prefix?: string;
  suffix?: string;
}

export function chunkText(text: string, options: ChunkOptions): string[];
export function estimateChunks(text: string, maxLength: number): number;
```

**Options:**

- `maxLength`: Maximum characters per chunk (required)
- `preserveWords`: Avoid splitting words (default: true)
- `separator`: String to split on (default: ' ')
- `prefix`: Text to prepend to each chunk
- `suffix`: Text to append to each chunk

**Usage Example:**

```typescript
const longMessage = "Very long message content...";

const chunks = chunkText(longMessage, {
  maxLength: 4096,
  preserveWords: true,
  prefix: '[Part ',
  suffix: ']'
});

// Send each chunk
for (let i = 0; i < chunks.length; i++) {
  await sendMessage(`${chunks[i]} (${i + 1}/${chunks.length})`);
}

// Estimate chunks before processing
const estimatedCount = estimateChunks(longMessage, 4096);
console.log(`Will send approximately ${estimatedCount} messages`);
```

---

## Provider Plugin Interface

The main plugin interface that all providers must implement is defined in `src/plugin-sdk/index.ts`:

```typescript
export interface ProviderPlugin {
  // Plugin metadata
  readonly id: string;
  readonly name: string;
  readonly version: string;
  readonly description?: string;

  // Lifecycle methods
  initialize?(config: PluginConfig): Promise<void>;
  shutdown?(): Promise<void>;

  // Authentication
  authenticate(config: AuthConfig): Promise<ProviderAuthResult>;
  validateCredentials?(credentials: Record<string, unknown>): Promise<boolean>;

  // Connection management
  connect(accountId: AccountId): Promise<void>;
  disconnect(accountId: AccountId): Promise<void>;
  getStatus(accountId: AccountId): Promise<StatusResponse>;

  // Messaging
  sendMessage(accountId: AccountId, recipient: string, message: Message): Promise<void>;
  onMessage?(accountId: AccountId, handler: MessageHandler): void;

  // Optional capabilities
  supportsWebhooks?: boolean;
  setupWebhook?(accountId: AccountId, webhookUrl: string): Promise<void>;
  removeWebhook?(accountId: AccountId): Promise<void>;
}
```

### Plugin Metadata

Required identification properties:

- `id`: Unique plugin identifier (e.g., 'telegram', 'whatsapp')
- `name`: Human-readable name
- `version`: Semantic version string
- `description`: Optional plugin description

### Lifecycle Methods

**`initialize(config: PluginConfig): Promise<void>`** *(optional)*

Called once when the plugin is loaded. Use for one-time setup.

```typescript
async initialize(config: PluginConfig): Promise<void> {
  this.config = config;
  this.httpClient = createHttpClient(config.proxy);
  await this.loadCache();
}
```

**`shutdown(): Promise<void>`** *(optional)*

Called when the plugin is being unloaded. Clean up resources.

```typescript
async shutdown(): Promise<void> {
  await this.saveCache();
  this.httpClient.destroy();
  this.activeConnections.clear();
}
```

### Authentication Methods

**`authenticate(config: AuthConfig): Promise<ProviderAuthResult>`** *(required)*

Authenticate a new account with the provider.

```typescript
async authenticate(config: AuthConfig): Promise<ProviderAuthResult> {
  try {
    const session = await this.provider.login({
      token: config.token,
      apiUrl: config.apiUrl
    });
    
    return {
      success: true,
      accountId: session.userId as AccountId,
      credentials: {
        token: session.token,
        refreshToken: session.refreshToken
      },
      displayName: session.username
    };
  } catch (error) {
    return {
      success: false,
      error: error.message,
      retryable: error.code === 'RATE_LIMIT'
    };
  }
}
```

**`validateCredentials(credentials: Record<string, unknown>): Promise<boolean>`** *(optional)*

Validate stored credentials are still valid.

```typescript
async validateCredentials(credentials: Record<string, unknown>): Promise<boolean> {
  try {
    await this.provider.testAuth(credentials.token);
    return true;
  } catch {
    return false;
  }
}
```

### Connection Management

**`connect(accountId: AccountId): Promise<void>`** *(required)*

Establish connection for an authenticated account.

```typescript
async connect(accountId: AccountId): Promise<void> {
  const credentials = await this.getStoredCredentials(accountId);
  const connection = await this.provider.createConnection(credentials);
  
  connection.on('message', (msg) => this.handleIncoming(accountId, msg));
  connection.on('error', (err) => this.handleError(accountId, err));
  
  this.connections.set(accountId, connection);
}
```

**`disconnect(accountId: AccountId): Promise<void>`** *(required)*

Close connection for an account.

```typescript
async disconnect(accountId: AccountId): Promise<void> {
  const connection = this.connections.get(accountId);
  if (connection) {
    await connection.close();
    this.connections.delete(accountId);
  }
}
```

**`getStatus(accountId: AccountId): Promise<StatusResponse>`** *(required)*

Return current connection status.

```typescript
async getStatus(accountId: AccountId): Promise<StatusResponse> {
  const connection = this.connections.get(accountId);
  if (!connection) {
    return createDisconnectedStatus();
  }
  
  if (connection.isReady()) {
    return createConnectedStatus({
      uptime: connection.getUptime(),
      messageCount: connection.getMessageCount()
    });
  }
  
  return createStatusResponse('connecting', 'Establishing connection');
}
```

### Messaging Methods

**`sendMessage(accountId: AccountId, recipient: string, message: Message): Promise<void>`** *(required)*

Send a message through the provider.

```typescript
async sendMessage(
  accountId: AccountId,
  recipient: string,
  message: Message
): Promise<void> {
  const connection = this.connections.get(accountId);
  if (!connection) {
    throw new Error('Not connected');
  }
  
  if (message.media) {
    await connection.sendMedia(recipient, message.media, message.text);
  } else {
    await connection.sendText(recipient, message.text);
  }
}
```

**`onMessage(accountId: AccountId, handler: MessageHandler): void`** *(optional)*

Register handler for incoming messages.

```typescript
onMessage(accountId: AccountId, handler: MessageHandler): void {
  const handlers = this.messageHandlers.get(accountId) || [];
  handlers.push(handler);
  this.messageHandlers.set(accountId, handlers);
}
```

### Webhook Support

**`supportsWebhooks: boolean`** *(optional)*

Indicates if provider supports webhook-based message delivery.

```typescript
readonly supportsWebhooks = true;
```

**`setupWebhook(accountId: AccountId, webhookUrl: string): Promise<void>`** *(optional)*

Configure webhook for the account.

```typescript
async setupWebhook(accountId: AccountId, webhookUrl: string): Promise<void> {
  const credentials = await this.getStoredCredentials(accountId);
  await this.provider.setWebhook({
    url: webhookUrl,
    token: credentials.token
  });
}
```

**`removeWebhook(accountId: AccountId): Promise<void>`** *(optional)*

Remove webhook configuration.

```typescript
async removeWebhook(accountId: AccountId): Promise<void> {
  const credentials = await this.getStoredCredentials(accountId);
  await this.provider.deleteWebhook(credentials.token);
}
```

---

## Type Reference

### PluginConfig

```typescript
interface PluginConfig {
  dataDir: string;
  configDir: string;
  logLevel?: 'debug' | 'info' | 'warn' | 'error';
  proxy?: ProxyConfig;
  [key: string]: unknown;
}
```

### AuthConfig

```typescript
interface AuthConfig {
  [key: string]: unknown;
}
```

### Message

```typescript
interface Message {
  text?: string;
  media?: AgentMediaPayload | AgentMediaPayload[];
  metadata?: Record<string, unknown>;
}
```

### MessageHandler

```typescript
type MessageHandler = (message: IncomingMessage) => void | Promise<void>;

interface IncomingMessage {
  id: string;
  sender: string;
  text?: string;
  media?: AgentMediaPayload[];
  timestamp: number;
  metadata?: Record<string, unknown>;
}
```

---

## Complete Plugin Example

```typescript
import {
  AccountId,
  ProviderPlugin,
  ProviderAuthResult,
  StatusResponse,
  AgentMediaPayload,
  createConnectedStatus,
  createErrorStatus,
  createDisconnectedStatus,
  FileLock,
  chunkText
} from 'openclaw/plugin-sdk';

export class MyProviderPlugin implements ProviderPlugin {
  readonly id = 'my-provider';
  readonly name = 'My Provider';
  readonly version = '1.0.0';
  readonly supportsWebhooks = true;

  private connections = new Map();
  private fileLock: FileLock;

  async initialize(config: PluginConfig): Promise<void> {
    this.fileLock = new FileLock({
      lockfilePath: `${config.dataDir}/my-provider.lock`
    });
  }

  async authenticate(config: AuthConfig): Promise<ProviderAuthResult> {
    try {
      const session = await externalAPI.login(config.apiKey);
      return {
        success: true,
        accountId: session.userId as AccountId,
        credentials: { token: session.token },
        displayName: session.displayName
      };
    } catch (error) {
      return {
        success: false,
        error: error.message
      };
    }
  }

  async connect(accountId: AccountId): Promise<void> {
    const credentials = await this.loadCredentials(accountId);
    const conn = await externalAPI.connect(credentials);
    this.connections.set(accountId, conn);
  }

  async disconnect(accountId: AccountId): Promise<void> {
    const conn = this.connections.get(accountId);
    if (conn) {
      await conn.close();
      this.connections.delete(accountId);
    }
  }

  async getStatus(accountId: AccountId): Promise<StatusResponse> {
    const conn = this.connections.get(accountId);
    return conn?.isConnected() 
      ? createConnectedStatus() 
      : createDisconnectedStatus();
  }

  async sendMessage(
    accountId: AccountId,
    recipient: string,
    message: Message
  ): Promise<void> {
    const conn = this.connections.get(accountId);
    if (!conn) throw new Error('Not connected');

    // Chunk long messages
    if (message.text && message.text.length > 4096) {
      const chunks = chunkText(message.text, { maxLength: 4096 });
      for (const chunk of chunks) {
        await conn.sendText(recipient, chunk);
      }
    } else {
      await conn.sendText(recipient, message.text);
    }
  }

  async setupWebhook(accountId: AccountId, webhookUrl: string): Promise<void> {
    await this.fileLock.withLock(async () => {
      await externalAPI.setWebhook(accountId, webhookUrl);
    });
  }
}
```

---

## Plugin Registration

Plugins are registered by exporting from the plugin module:

```typescript
// my-provider-plugin/index.ts
import { MyProviderPlugin } from './plugin';

export default new MyProviderPlugin();
```

---

## Package Configuration

To make your plugin discoverable, configure `package.json`:

```json
{
  "name": "@openclaw/provider-myprovider",
  "version": "1.0.0",
  "main": "dist/index.js",
  "types": "dist/index.d.ts",
  "keywords": ["openclaw-plugin", "openclaw-provider"],
  "dependencies": {
    "openclaw": "^2026.2.16"
  }
}
```

---

## Testing Plugins

Use the SDK's test utilities:

```typescript
import { test, expect } from 'vitest';
import plugin from './index';

test('authentication', async () => {
  const result = await plugin.authenticate({
    apiKey: 'test-key'
  });
  
  expect(result.success).toBe(true);
  if (result.success) {
    expect(result.accountId).toBeDefined();
  }
});

test('message sending', async () => {
  const accountId = 'test-account' as AccountId;
  await plugin.connect(accountId);
  
  await plugin.sendMessage(accountId, 'recipient', {
    text: 'Hello, world!'
  });
  
  const status = await plugin.getStatus(accountId);
  expect(status.status).toBe('connected');
});
```

---

## Error Handling

All async methods should handle errors appropriately:

```typescript
async sendMessage(accountId: AccountId, recipient: string, message: Message): Promise<void> {
  try {
    const conn = this.connections.get(accountId);
    if (!conn) {
      throw new Error(`No connection found for account: ${accountId}`);
    }
    
    await conn.send(recipient, message);
  } catch (error) {
    // Log error
    this.logger.error('Failed to send message', { error, accountId, recipient });
    
    // Re-throw with context
    throw new Error(`Failed to send message to ${recipient}: ${error.message}`);
  }
}
```

---

## Best Practices

1. **Use TypeScript**: All SDK types are defined in TypeScript for type safety
2. **Handle Disconnections**: Implement reconnection logic in `connect()`
3. **Respect Rate Limits**: Use delays and queuing for API calls
4. **Validate Input**: Check parameters before calling external APIs
5. **Clean Up Resources**: Implement `shutdown()` to prevent leaks
6. **Use File Locks**: Coordinate access to shared files with `FileLock`
7. **Chunk Messages**: Split long messages using `chunkText()`
8. **Status Helpers**: Use provided status helper functions for consistency
9. **Error Context**: Include relevant context in error messages
10. **Test Coverage**: Write tests for all plugin methods

---

## Version Compatibility

This SDK reference is for OpenClaw version `2026.2.16`. Check the plugin SDK version compatibility:

```typescript
import { version } from 'openclaw/plugin-sdk';
console.log(`SDK Version: ${version}`);
```

Required Node.js version: `>=22.12.0`