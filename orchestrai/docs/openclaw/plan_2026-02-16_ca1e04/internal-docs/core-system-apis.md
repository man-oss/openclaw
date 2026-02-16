# Core System APIs

## Overview

OpenClaw's core system APIs provide internal interfaces for agent management, model configuration, authentication, and gateway communication. These APIs are designed for advanced customization and extension of the OpenClaw system.

## Agent Management APIs

### Agent Paths (`src/agents/agent-paths.ts`)

Manages file system paths for agent-specific data and configuration.

```typescript
export function getAgentDir(agentId: string): string
export function getAgentConfigPath(agentId: string): string
export function getAgentStatePath(agentId: string): string
```

**Usage:**
```typescript
import { getAgentDir, getAgentConfigPath } from './agents/agent-paths';

const agentDir = getAgentDir('my-agent');
const configPath = getAgentConfigPath('my-agent');
```

### Agent Scope (`src/agents/agent-scope.ts`)

Determines file access scope for agents based on configuration.

```typescript
export interface AgentScopeResult {
  allowed: boolean;
  reason?: string;
  scope: 'workspace' | 'agent-dir' | 'unrestricted';
}

export function checkAgentFileAccess(
  agentId: string,
  filePath: string,
  workspaceRoot: string
): AgentScopeResult
```

**Key Functions:**
- `checkAgentFileAccess()` - Validates if agent can access a file path
- `getAgentWorkspaceScope()` - Returns workspace boundaries for agent
- `isPathInAgentDir()` - Checks if path is within agent directory

### Agent Context (`src/agents/context.ts`)

Provides runtime context information for agent execution.

```typescript
export interface AgentContext {
  agentId: string;
  workspaceRoot: string;
  agentDir: string;
  sessionId?: string;
  channelId?: string;
}

export function createAgentContext(agentId: string): AgentContext
export function getContextValue<T>(ctx: AgentContext, key: string): T | undefined
```

## Model Selection and Configuration APIs

### Model Selection (`src/agents/model-selection.ts`)

Handles model selection logic with fallback support.

```typescript
export interface ModelSelectionResult {
  model: string;
  provider: string;
  authProfile?: string;
  fallbackAttempted: boolean;
}

export async function selectModel(
  preferredModel?: string,
  context?: AgentContext
): Promise<ModelSelectionResult>
```

**Features:**
- Automatic fallback to available models
- Provider-specific model resolution
- Integration with auth profiles

### Model Catalog (`src/agents/model-catalog.ts`)

Maintains registry of available models and their capabilities.

```typescript
export interface ModelInfo {
  id: string;
  provider: string;
  contextWindow: number;
  supportsTools: boolean;
  supportsVision: boolean;
}

export function getModelInfo(modelId: string): ModelInfo | undefined
export function listAvailableModels(provider?: string): ModelInfo[]
```

### Model Authentication (`src/agents/model-auth.ts`)

Manages authentication for model providers.

```typescript
export interface ModelAuthConfig {
  provider: string;
  apiKey?: string;
  authProfile?: string;
  baseUrl?: string;
}

export async function getModelAuth(
  provider: string,
  profileHint?: string
): Promise<ModelAuthConfig>
```

**Provider Support:**
- Anthropic (Claude)
- OpenAI (GPT models)
- OpenRouter
- Google Gemini
- AWS Bedrock
- HuggingFace
- Local models (vLLM, Ollama)

### Model Fallback (`src/agents/model-fallback.ts`)

Implements automatic fallback when primary model fails.

```typescript
export interface FallbackConfig {
  maxAttempts: number;
  fallbackOrder: string[];
  excludeProviders?: string[];
}

export async function attemptModelFallback(
  error: Error,
  context: AgentContext,
  config: FallbackConfig
): Promise<ModelSelectionResult | null>
```

## Authentication Profile APIs

### Profile Management (`src/agents/auth-profiles.ts`)

Core authentication profile storage and retrieval.

```typescript
export interface AuthProfile {
  id: string;
  provider: string;
  apiKey?: string;
  createdAt: number;
  lastUsed?: number;
  lastGood?: number;
  failureCount?: number;
}

export async function ensureAuthProfileStore(): Promise<void>
export async function getAuthProfile(id: string): Promise<AuthProfile | undefined>
export async function saveAuthProfile(profile: AuthProfile): Promise<void>
export async function markAuthProfileFailure(id: string): Promise<void>
```

### Authentication Health (`src/agents/auth-health.ts`)

Monitors authentication status and validates credentials.

```typescript
export interface AuthHealthStatus {
  provider: string;
  healthy: boolean;
  lastChecked: number;
  error?: string;
}

export async function checkAuthHealth(
  provider: string,
  authConfig: ModelAuthConfig
): Promise<AuthHealthStatus>
```

**Health Checks:**
- API key validity
- Rate limit status
- Service availability
- Credential expiration

### Profile Resolution (`src/agents/auth-profiles.*.ts`)

Handles profile ordering and selection logic.

**Key Functions:**
- `resolveAuthProfileOrder()` - Determines profile priority
- `selectBestAuthProfile()` - Chooses optimal profile for request
- `rotateProfiles()` - Implements round-robin selection

**Selection Strategy:**
```typescript
// Profiles are ordered by:
// 1. Last successful use (lastGood)
// 2. Lowest failure count
// 3. Most recently used
// 4. Creation time
```

## Configuration Management APIs

### Configuration I/O (`src/config/io.ts`)

Handles reading and writing configuration files.

```typescript
export interface ConfigLoadResult {
  config: OpenClawConfig;
  path: string;
  warnings: string[];
}

export async function loadConfig(
  configPath?: string
): Promise<ConfigLoadResult>

export async function writeConfig(
  config: OpenClawConfig,
  path: string
): Promise<void>
```

**Features:**
- YAML/JSON support
- Environment variable substitution
- Schema validation
- Migration support

### Configuration Schema (`src/config/schema.ts`)

Defines configuration structure and validation.

```typescript
import { z } from 'zod';

export const OpenClawConfigSchema = z.object({
  agents: z.record(z.object({
    model: z.string().optional(),
    provider: z.string().optional(),
    // ... additional fields
  })),
  auth: z.object({
    profiles: z.array(z.object({
      id: z.string(),
      provider: z.string(),
      // ... additional fields
    }))
  }),
  // ... additional sections
});

export type OpenClawConfig = z.infer<typeof OpenClawConfigSchema>;
```

### Configuration Paths (`src/config/config-paths.ts`)

Manages configuration file locations.

```typescript
export function getDefaultConfigPath(): string
export function getConfigDir(): string
export function resolveConfigPath(hint?: string): string
```

**Path Resolution:**
```typescript
// Priority order:
// 1. --config CLI flag
// 2. OPENCLAW_CONFIG environment variable
// 3. ./openclaw.yaml
// 4. ~/.openclaw/config.yaml
// 5. /etc/openclaw/config.yaml (Linux)
```

### Environment Variable Substitution (`src/config/env-substitution.ts`)

Expands environment variables in configuration.

```typescript
export function substituteEnvVars(
  value: string,
  env?: Record<string, string>
): string

export function processConfigEnvVars(
  config: OpenClawConfig
): OpenClawConfig
```

**Syntax Support:**
```yaml
# Direct reference
api_key: ${ANTHROPIC_API_KEY}

# With default value
api_key: ${ANTHROPIC_API_KEY:-default-value}

# Nested references
base_url: ${API_HOST:-localhost}:${API_PORT:-8080}
```

### Configuration Merging (`src/config/merge-config.ts`)

Combines multiple configuration sources.

```typescript
export function mergeConfigs(
  base: OpenClawConfig,
  override: Partial<OpenClawConfig>
): OpenClawConfig
```

**Merge Strategy:**
- Deep merge for objects
- Array replacement (not merge)
- Undefined values ignored
- Null values clear fields

## Gateway Communication APIs

### Agent via Gateway (`src/commands/agent-via-gateway.ts`)

Routes agent requests through gateway service.

```typescript
export interface GatewayRequest {
  agentId: string;
  method: string;
  params: Record<string, unknown>;
  sessionId?: string;
}

export interface GatewayResponse {
  success: boolean;
  data?: unknown;
  error?: string;
}

export async function sendToGateway(
  request: GatewayRequest,
  config: GatewayConfig
): Promise<GatewayResponse>
```

**Configuration:**
```typescript
interface GatewayConfig {
  url: string;
  apiKey?: string;
  timeout?: number;
  retries?: number;
}
```

### Gateway Authentication (`src/commands/configure.gateway-auth.ts`)

Manages gateway authentication tokens.

```typescript
export interface GatewayAuthToken {
  token: string;
  expiresAt: number;
  scope: string[];
}

export async function getGatewayAuth(): Promise<GatewayAuthToken>
export async function refreshGatewayAuth(): Promise<GatewayAuthToken>
export async function revokeGatewayAuth(): Promise<void>
```

### Gateway Status (`src/commands/gateway-status.ts`)

Monitors gateway health and connectivity.

```typescript
export interface GatewayStatus {
  connected: boolean;
  version: string;
  uptime: number;
  activeAgents: number;
  queueDepth: number;
}

export async function getGatewayStatus(): Promise<GatewayStatus>
```

**Status Checks:**
- Connection health
- Version compatibility
- Service availability
- Performance metrics

### Gateway Presence (`src/commands/gateway-presence.ts`)

Manages agent presence in gateway network.

```typescript
export interface PresenceInfo {
  agentId: string;
  status: 'online' | 'busy' | 'offline';
  lastSeen: number;
  metadata?: Record<string, unknown>;
}

export async function updatePresence(
  agentId: string,
  status: PresenceInfo['status']
): Promise<void>

export async function getPresence(agentId: string): Promise<PresenceInfo>
```

## Advanced APIs

### Command Execution (`src/commands/agent.ts`)

Executes commands within agent context.

```typescript
export interface CommandOptions {
  agentId: string;
  command: string;
  args: string[];
  cwd?: string;
  env?: Record<string, string>;
  timeout?: number;
}

export interface CommandResult {
  exitCode: number;
  stdout: string;
  stderr: string;
  timedOut: boolean;
}

export async function executeCommand(
  options: CommandOptions
): Promise<CommandResult>
```

### Bash Tools Integration (`src/agents/bash-tools.*.ts`)

Provides shell command execution with safety controls.

**Key APIs:**
```typescript
// Execute shell command
export async function execBash(
  command: string,
  options: ExecOptions
): Promise<ExecResult>

// Process management
export interface ProcessHandle {
  pid: number;
  kill(): Promise<void>;
  poll(): Promise<ProcessStatus>;
}

export async function startBackgroundProcess(
  command: string
): Promise<ProcessHandle>
```

**Safety Features:**
- Command whitelisting
- Timeout enforcement
- Output size limits
- Directory restrictions

### Apply Patch (`src/agents/apply-patch.ts`)

Applies unified diff patches to files.

```typescript
export interface PatchResult {
  success: boolean;
  appliedHunks: number;
  totalHunks: number;
  failedHunks: Array<{
    hunk: number;
    reason: string;
  }>;
}

export async function applyPatch(
  filePath: string,
  patchContent: string,
  options?: PatchOptions
): Promise<PatchResult>
```

**Patch Options:**
```typescript
interface PatchOptions {
  dryRun?: boolean;
  createBackup?: boolean;
  fuzzyMatch?: boolean;
  maxFuzz?: number;
}
```

### Memory Search (`src/agents/memory-search.ts`)

Provides semantic search over agent memory.

```typescript
export interface MemorySearchOptions {
  query: string;
  limit?: number;
  threshold?: number;
  agentId?: string;
}

export interface MemorySearchResult {
  content: string;
  score: number;
  timestamp: number;
  metadata?: Record<string, unknown>;
}

export async function searchMemory(
  options: MemorySearchOptions
): Promise<MemorySearchResult[]>
```

### Anthropic Payload Logging (`src/agents/anthropic-payload-log.ts`)

Logs API requests/responses for debugging.

```typescript
export interface PayloadLogEntry {
  timestamp: number;
  direction: 'request' | 'response';
  model: string;
  tokens?: {
    input: number;
    output: number;
  };
  payload: unknown;
}

export function logPayload(entry: PayloadLogEntry): void
export function getPayloadLog(agentId: string): PayloadLogEntry[]
```

## CLI Command APIs

### Agent Commands (`src/commands/agents.*.ts`)

Command-line interface for agent management.

**Available Commands:**
```typescript
// Add new agent
export async function addAgent(
  agentId: string,
  options: AddAgentOptions
): Promise<void>

// Delete agent
export async function deleteAgent(agentId: string): Promise<void>

// List agents
export async function listAgents(): Promise<AgentInfo[]>

// Configure agent identity
export async function setAgentIdentity(
  agentId: string,
  identity: IdentityConfig
): Promise<void>
```

### Channel Commands (`src/commands/channels.*.ts`)

Manages communication channels for agents.

```typescript
// Add channel configuration
export async function addChannel(
  channelType: string,
  config: ChannelConfig
): Promise<void>

// Get channel status
export async function getChannelStatus(): Promise<ChannelStatus[]>
```

**Supported Channels:**
- Discord
- Slack
- Telegram
- IRC
- Signal
- WhatsApp
- MS Teams
- Google Chat

### Configuration Commands (`src/commands/configure.*.ts`)

Interactive configuration utilities.

```typescript
// Run configuration wizard
export async function runConfigWizard(): Promise<void>

// Configure gateway
export async function configureGateway(): Promise<void>

// Configure daemon
export async function configureDaemon(): Promise<void>
```

## Error Handling

### Failover Error (`src/agents/failover-error.ts`)

Specialized error for model failover scenarios.

```typescript
export class FailoverError extends Error {
  constructor(
    message: string,
    public provider: string,
    public originalError: Error,
    public attemptNumber: number
  ) {
    super(message);
    this.name = 'FailoverError';
  }
}

export function isRetryableError(error: Error): boolean
export function shouldFailover(error: FailoverError): boolean
```

**Retryable Conditions:**
- Rate limit errors (429)
- Server errors (5xx)
- Network timeouts
- Authentication expiry

## Integration Examples

### Custom Agent with Model Selection

```typescript
import { selectModel } from './agents/model-selection';
import { createAgentContext } from './agents/context';
import { getModelAuth } from './agents/model-auth';

async function createCustomAgent(agentId: string) {
  const context = createAgentContext(agentId);
  
  // Select best available model
  const modelResult = await selectModel('claude-3-5-sonnet-20241022', context);
  
  // Get authentication
  const auth = await getModelAuth(modelResult.provider);
  
  // Initialize agent with selected model
  return {
    agentId,
    model: modelResult.model,
    provider: modelResult.provider,
    auth,
    context
  };
}
```

### Gateway Communication

```typescript
import { sendToGateway } from './commands/agent-via-gateway';
import { getGatewayAuth } from './commands/configure.gateway-auth';

async function invokeRemoteAgent(agentId: string, prompt: string) {
  // Get authentication token
  const auth = await getGatewayAuth();
  
  // Send request through gateway
  const response = await sendToGateway({
    agentId,
    method: 'execute',
    params: { prompt }
  }, {
    url: 'https://gateway.example.com',
    apiKey: auth.token
  });
  
  return response.data;
}
```

### Configuration Management

```typescript
import { loadConfig, writeConfig } from './config/io';
import { mergeConfigs } from './config/merge-config';

async function updateAgentConfig(agentId: string, updates: Partial<AgentConfig>) {
  // Load existing config
  const { config } = await loadConfig();
  
  // Merge updates
  const updatedConfig = mergeConfigs(config, {
    agents: {
      [agentId]: updates
    }
  });
  
  // Save config
  await writeConfig(updatedConfig, config.path);
}
```

### Authentication Profile Rotation

```typescript
import { getAuthProfile, markAuthProfileFailure } from './agents/auth-profiles';
import { attemptModelFallback } from './agents/model-fallback';

async function executeWithFallback(provider: string, operation: () => Promise<any>) {
  const profile = await getAuthProfile(`${provider}-primary`);
  
  try {
    return await operation();
  } catch (error) {
    // Mark profile as failed
    await markAuthProfileFailure(profile.id);
    
    // Attempt fallback
    const fallbackResult = await attemptModelFallback(error, context, {
      maxAttempts: 3,
      fallbackOrder: ['openrouter', 'openai', 'local']
    });
    
    if (fallbackResult) {
      return await operation();
    }
    
    throw error;
  }
}
```

## Performance Considerations

### Caching

The system implements caching at multiple levels:

1. **Configuration Cache** (`src/config/cache-utils.ts`)
   - In-memory config caching
   - Automatic invalidation on file changes

2. **Model Catalog Cache** 
   - Provider model lists cached
   - Periodic refresh

3. **Auth Profile Cache**
   - Profile data cached after validation
   - Invalidated on failure

### Concurrency

Agent execution supports concurrent operations:

```typescript
// From src/config/defaults.ts
const DEFAULT_AGENT_CONCURRENCY = 4; // Max concurrent agents

// Per-agent concurrency settings
interface AgentLimits {
  maxConcurrentRequests: number;
  requestQueueSize: number;
  rateLimitPerMinute: number;
}
```

## Security Considerations

### API Key Storage

- API keys stored in encrypted format
- Access controlled by file permissions
- Optional OS keychain integration

### Command Execution

- Sandboxed execution environment
- Directory traversal prevention
- Command whitelist enforcement
- Resource limits (CPU, memory, time)

### Network Communication

- TLS required for gateway connections
- Token-based authentication
- Request signing for integrity
- Rate limiting protection

## Debugging and Diagnostics

### Doctor Command (`src/commands/doctor.*.ts`)

Comprehensive system diagnostics:

```typescript
// Run system health check
export async function runDoctor(): Promise<DiagnosticReport>

// Individual checks
export async function checkAuth(): Promise<AuthStatus>
export async function checkConfig(): Promise<ConfigStatus>
export async function checkGateway(): Promise<GatewayStatus>
export async function checkSandbox(): Promise<SandboxStatus>
```

### Payload Logging

Enable detailed API logging:

```typescript
// Enable logging
process.env.OPENCLAW_LOG_PAYLOADS = '1';

// View logs
import { getPayloadLog } from './agents/anthropic-payload-log';
const logs = getPayloadLog('my-agent');
```

## Extension Points

### Custom Model Providers

Implement custom provider support:

```typescript
interface ModelProvider {
  name: string;
  authenticate(config: AuthConfig): Promise<AuthResult>;
  listModels(): Promise<ModelInfo[]>;
  createClient(auth: AuthResult): ModelClient;
}

// Register custom provider
registerProvider(myCustomProvider);
```

### Custom Tools

Add custom tool implementations:

```typescript
interface Tool {
  name: string;
  description: string;
  schema: ToolSchema;
  execute(params: ToolParams): Promise<ToolResult>;
}

// Register tool
registerTool(myCustomTool);
```

## API Stability

### Stable APIs (v1.0+)
- Core agent management functions
- Configuration I/O
- Model selection
- Authentication profiles

### Beta APIs
- Gateway communication
- Memory search
- Advanced bash tools

### Experimental APIs
- Custom providers
- Plugin system
- Advanced hooks

## Additional Resources

- Configuration Schema: `src/config/schema.ts`
- Type Definitions: `src/config/types.*.ts`
- Test Examples: `src/**/*.test.ts`
- E2E Tests: `src/**/*.e2e.test.ts`