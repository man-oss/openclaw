# Netdata Threat Model and Security Assessment

**Repository:** `man-oss/netdata` (tracking upstream `netdata/netdata`)
**Source References:** `docs/security-and-privacy-design/netdata-agent-security.md`, `docs/security-and-privacy-design/netdata-cloud-security.md`, `src/aclk/README.md`, `src/aclk/aclk.c`, `src/plugins.d/README.md`, `src/plugins.d/pluginsd_functions.c`
**Audience:** Security engineers, compliance auditors, and threat modelers

---

## Table of Contents

1. [Architecture Overview and Trust Boundary Map](#1-architecture-overview-and-trust-boundary-map)
2. [Trust Boundaries](#2-trust-boundaries)
3. [Data in Transit: Flows, Channels, and Protections](#3-data-in-transit-flows-channels-and-protections)
4. [ACLK Threat Model](#4-aclk-threat-model)
5. [Agent Access Control Threats](#5-agent-access-control-threats)
6. [Supply Chain Risks: Plugin Execution Model](#6-supply-chain-risks-plugin-execution-model)
7. [Cross-Cutting Security Controls](#7-cross-cutting-security-controls)
8. [Threat Summary Table (STRIDE)](#8-threat-summary-table-stride)
9. [Auditor Checklist](#9-auditor-checklist)

---

## 1. Architecture Overview and Trust Boundary Map

Netdata operates as a distributed observability system with four principal zones of trust. Understanding where each zone begins and ends is the foundation of this threat model.

```
┌─────────────────────────────────────────────────────────────────────────┐
│  ZONE 1: AGENT HOST (Highest Trust)                                     │
│  ┌──────────────────┐    stdin/stdout pipe    ┌──────────────────────┐  │
│  │  External Plugin │ ──────────────────────► │  Netdata Daemon (C)  │  │
│  │  (C/Go/Python/   │  (unidirectional only)  │  netdata process     │  │
│  │   Bash/any lang) │                         │  - DB engine         │  │
│  └──────────────────┘                         │  - Health engine     │  │
│                                               │  - Web server        │  │
│                                               │  - Streaming out     │  │
│                                               │  - ACLK thread       │  │
│                                               └──────────────────────┘  │
└────────────────────────────────┬────────────────────────────────────────┘
                                 │  TB-1: Agent Host ↔ Parent Node
                                 │  Streaming: API key + optional TLS
                                 ▼
┌─────────────────────────────────────────────────────────────────────────┐
│  ZONE 2: PARENT NODE / OBSERVABILITY CENTRALIZATION POINT               │
│  (Another Netdata agent acting as aggregator)                           │
│  Receives: metrics, metadata, alert states from child agents            │
│  Exposes:  consolidated local Web API                                   │
└────────────────────────────────┬────────────────────────────────────────┘
                                 │  TB-2: Agent(s) ↔ Netdata Cloud
                                 │  ACLK: MQTT/WSS/TLS port 443
                                 ▼
┌─────────────────────────────────────────────────────────────────────────┐
│  ZONE 3: NETDATA CLOUD (External, SaaS)                                 │
│  AWS-hosted microservices; stores only metadata, never raw metrics      │
│  Authentication: JWT tokens at TLS termination; no passwords stored     │
└────────────────────────────────┬────────────────────────────────────────┘
                                 │  TB-3: Netdata Cloud ↔ End User Browser
                                 │  HTTPS/WSS (TLS enforced)
                                 ▼
┌─────────────────────────────────────────────────────────────────────────┐
│  ZONE 4: END USER BROWSER                                               │
│  Consumes dashboard served from cloud or directly from agent Web API    │
│  Authentication: Email via OAuth (Google/GitHub) or short-lived tokens  │
└─────────────────────────────────────────────────────────────────────────┘
```

**Key architectural property:** Metric data never crosses TB-2 at rest. The ACLK channel carries only processed metrics transiently and essential metadata persistently. This is codified in `docs/security-and-privacy-design/netdata-cloud-security.md`: *"We do not store any metrics or logs in Netdata Cloud."*

---

## 2. Trust Boundaries

### TB-0: Plugin Process ↔ Netdata Daemon (Intra-host)

**Source:** `src/plugins.d/README.md` — *"The communication between the external plugin and Netdata is unidirectional (from the plugin to Netdata), so that Netdata cannot manipulate an external plugin running with escalated privileges."*

| Property | Detail |
|---|---|
| Transport | Ephemeral in-memory `stdin/stdout` pipes |
| Direction | Strictly unidirectional: plugin → daemon |
| Protocol | Text-based line-oriented `plugins.d` protocol (CHART, DIMENSION, SET, BEGIN, END, FUNCTION, CONFIG keywords) |
| Authentication | None (process-level trust via OS PID namespace) |
| Privilege model | Plugin may run setuid/escalated; daemon runs as unprivileged `netdata` user |
| Daemon-to-plugin | Limited: FUNCTION call commands sent to plugin `stdin` (e.g., `FUNCTION`, `FUNCTION_PAYLOAD`, `FUNCTION_CANCEL`, `FUNCTION_PROGRESS`) |

**Trust implication:** The daemon implicitly trusts any process launched from `NETDATA_PLUGINS_DIR` or `NETDATA_USER_PLUGINS_DIRS`. There is no code-signing or integrity check on plugin binaries at the OS level beyond filesystem permissions.

---

### TB-1: Child Agent ↔ Parent Agent (Streaming)

**Source:** `docs/security-and-privacy-design/netdata-agent-security.md`

| Property | Detail |
|---|---|
| Transport | TCP (plain or TLS-wrapped) |
| Port | Configurable; default 19999 |
| Authentication | Shared **API key** (pre-shared secret) |
| Encryption | Optional TLS — **not enforced by default** |
| Data carried | Processed metrics, chart definitions, alert states, host labels |

**Trust implication:** A child agent that presents a valid API key is accepted as fully trusted by the parent. There is no per-metric authorization—all metrics from a claimed child are accepted.

---

### TB-2: Netdata Agent ↔ Netdata Cloud (ACLK)

**Source:** `src/aclk/README.md`, `src/aclk/aclk.c`, `src/aclk/aclk_otp.c`

| Property | Detail |
|---|---|
| Transport | MQTT over WebSocket over TLS (WSS) |
| Port | 443 (outbound only from agent) |
| Endpoints | `app.netdata.cloud`, `api.netdata.cloud`, `mqtt.netdata.cloud` |
| Authentication | Public/private key cryptography; keys provisioned during node claiming (`src/claim/`) |
| Activation | Only active after node is claimed to a Space |
| Direction | Outbound only (agent initiates; cloud cannot directly dial into agent) |

**Trust implication:** Netdata Cloud holds a trusted position: it can send query and function-call commands downstream to agents via the ACLK channel. A compromised Netdata Cloud service could issue `FUNCTION` commands to agents. This is the most critical trust boundary in the system.

---

### TB-3: Netdata Cloud ↔ End User Browser

| Property | Detail |
|---|---|
| Transport | HTTPS / WSS (TLS enforced) |
| Authentication | JWT tokens issued after OAuth login (Google, GitHub) or short-lived email tokens |
| Authorization | Role-based (admin, member, viewer) scopes enforced in cloud microservices |
| Credential storage | No passwords stored anywhere; no credentials at rest |

---

### TB-4: End User Browser ↔ Agent Web API (Direct Access)

**Source:** `docs/security-and-privacy-design/netdata-agent-security.md` — *"Direct Agent Access: Typically unauthenticated, relies on LAN isolation or firewall policies."*

| Property | Detail |
|---|---|
| Transport | HTTP (default) or HTTPS if TLS configured |
| Port | 19999 (default) |
| Authentication | **None by default** |
| Mitigation options | IP-based ACLs in `netdata.conf`, reverse proxy authentication |

This is the highest-risk surface for network-exposed deployments.

---

## 3. Data in Transit: Flows, Channels, and Protections

### 3.1 Complete Data Flow Inventory

| Flow | Source | Destination | Channel | Data Type | Encryption | Authentication |
|---|---|---|---|---|---|---|
| F-1 | External Plugin | Netdata Daemon | `stdin/stdout` pipe | Raw → processed metrics | N/A (IPC) | OS process trust |
| F-2 | Netdata Daemon | Local TSDB | Filesystem I/O | Time-series metric data | None (disk-level encrypt at OS) | OS file permissions |
| F-3 | Netdata Daemon | Streaming Parent | TCP socket | Processed metrics, alerts, host metadata | Optional TLS | API key |
| F-4 | Netdata Daemon | Netdata Cloud | ACLK (MQTT/WSS) | Processed metrics (transient), metadata (persistent), alert states | TLS mandatory | Public/private key |
| F-5 | Netdata Cloud | User Browser | HTTPS/WSS | Aggregated metadata, alert configs, dashboard data | TLS mandatory | JWT (OAuth) |
| F-6 | User Browser | Agent Web API | HTTP/HTTPS | Query requests; metric responses | Optional TLS | None by default |
| F-7 | Netdata Cloud | Netdata Agent | ACLK (reverse direction) | Function call requests, query routing | TLS mandatory | Cloud-to-agent claim token |
| F-8 | Netdata Daemon | External TSDB | HTTPS/protocol | Exported metrics | Connector-dependent | Connector-dependent |

### 3.2 What Metadata is Stored by Netdata Cloud

From `docs/security-and-privacy-design/netdata-cloud-security.md`, the following endpoints' data is stored persistently in AWS (and copied to Google BigQuery for analytics):

| Metadata Stored | Source Endpoint |
|---|---|
| Hostname | `/api/v1/info` |
| Metric metadata (chart names, context names, dimension names) | `/api/v1/contexts` |
| Alert configuration (rules, thresholds) | `/api/v1/alarms` |
| User email address | Account registration |
| IP address | Web proxy access logs |

**Critically, raw metric values are NOT stored.** They flow through the ACLK transiently for live dashboard rendering and are discarded.

### 3.3 What Raw Data Never Leaves the Agent

From `docs/security-and-privacy-design/netdata-agent-security.md`:

> "When plugins collect data from databases or logs, only **processed metrics** are: Stored in Netdata databases / Sent to upstream Netdata servers / Archived to external time-series databases. Raw data remains local and is never transmitted."

This means:
- Database query results (e.g., MySQL slow queries) → only aggregated metric counts transmitted, not query text
- Log file contents → only derived metric values transmitted, not log lines
- Process command lines → only resource usage metrics transmitted, not argv values

---

## 4. ACLK Threat Model

### 4.1 ACLK Architecture (Code-Level)

The ACLK implementation spans multiple source files:
- `src/aclk/aclk.c` — main connection management and message dispatch (48 KB)
- `src/aclk/aclk_otp.c` — OTP/token-based authentication and claiming (30 KB)
- `src/aclk/aclk_rx_msgs.c` — inbound message handling from cloud (16 KB)
- `src/aclk/aclk_tx_msgs.c` — outbound message transmission to cloud (7 KB)
- `src/aclk/aclk_query.c` — query processing from cloud-originated requests (8 KB)
- `src/aclk/https_client.c` — TLS HTTPS client used for provisioning (34 KB)
- `src/aclk/mqtt_websockets/` — MQTT-over-WebSocket transport layer

The ACLK connection is **outbound-only** and activated only after a node is claimed. It uses `mqtt.netdata.cloud:443` via WSS.

### 4.2 What a Compromised Netdata Cloud Could Do

Because Netdata Cloud sits at TB-2 and can send messages back to agents via the ACLK (`aclk_rx_msgs.c`), a fully compromised Netdata Cloud (or a cloud-side MITM) represents a significant threat. The following attack scenarios are enumerated:

| Threat ID | Scenario | Impact | Mitigating Control |
|---|---|---|---|
| ACLK-T1 | **Function call injection**: Cloud sends crafted `FUNCTION` commands to agents via ACLK, causing plugins to execute arbitrary plugin-defined functions | Data exfiltration via function responses; unintended state changes in monitored systems | Functions are predefined and registered by the plugin itself; plugins cannot be instructed to execute OS commands directly via functions |
| ACLK-T2 | **Metadata poisoning**: Cloud injects false chart/metric metadata responses into browser dashboards | Operator misjudgment; false alerts | Agents sign or originate all real metric data; cloud merely aggregates metadata it received from agents |
| ACLK-T3 | **Alert suppression**: Cloud withholds or modifies alert notification routing | Silent failures in production systems | Agents evaluate health alerts locally; cloud only carries notification metadata |
| ACLK-T4 | **Configuration change injection via DynCfg**: Cloud routes `config` function calls to plugins, modifying dynamic configurations | Plugin behavior changes; data collection redirection | DynCfg commands require the plugin to have registered `CONFIG` support and accept the `edit permissions` bitmap |
| ACLK-T5 | **Node unclaiming**: Revocation of the agent's cloud token | Loss of cloud-based monitoring visibility | ACLK simply deactivates; local monitoring continues unaffected |
| ACLK-T6 | **Replay of ACLK messages**: An attacker captures and replays ACLK MQTT messages | Duplicate function calls; stale dashboard data | MQTT QoS and ACLK transaction IDs (seen in `pluginsd_functions.c` — `transaction_id`) prevent naive replay |
| ACLK-T7 | **MitM of ACLK TLS connection**: Attacker intercepts the WSS connection to `mqtt.netdata.cloud` | Full visibility into metadata; injection of cloud→agent commands | TLS with server certificate validation; domain allowlisting recommended (`app.netdata.cloud`, `api.netdata.cloud`, `mqtt.netdata.cloud`) |

### 4.3 ACLK Access Control for Functions

From `src/plugins.d/README.md`, function registrations include explicit access controls:

```
FUNCTION [GLOBAL] "name and parameters" timeout "help" "tags" "access" priority version
```

The `"access"` field accepts:
- `any` — callable by any user, **including unauthenticated users**
- `member` — requires authenticated Netdata Cloud membership
- `admin` — requires authenticated administrator role

**Threat implication:** Functions registered with `access = any` via the ACLK path could be invoked by cloud-side logic without user authentication context. Auditors must review all `FUNCTION` registrations in deployed plugins for their `access` level.

### 4.4 Inbound Message Types (ACLK RX)

The file `src/aclk/aclk_rx_msgs.c` (16 KB) handles cloud-to-agent inbound messages. These represent the attack surface for any cloud-side compromise:
- Node connection/disconnection acknowledgments
- Alert status updates
- Query routing requests (for live dashboard data)
- Function invocation forwarding

### 4.5 ACLK Absence Scenario

If ACLK is not configured (unclaimed agent), **no outbound cloud connection exists**. The attack surface of TB-2 is entirely eliminated. For air-gapped environments, disabling cloud claiming removes this boundary entirely.

---

## 5. Agent Access Control Threats

### 5.1 Unauthenticated Web API

**Source:** `docs/security-and-privacy-design/netdata-agent-security.md`

> *"Direct Agent Access: Typically unauthenticated, relies on LAN isolation or firewall policies."*

The Netdata Web API (served from `src/web/api/` and `src/web/server/`) listens on port 19999 by default and requires no authentication unless explicitly configured.

#### Exposed API Surface

The following endpoints represent the unauthenticated attack surface (`src/web/api/` directory):

| Endpoint Pattern | Data Exposed | Risk Level |
|---|---|---|
| `/api/v1/info` | Hostname, OS version, kernel version, architecture, cloud provider, virtualization type | **HIGH** — system fingerprinting |
| `/api/v1/contexts` | All metric names, chart names, plugin names, module names | **HIGH** — infrastructure mapping |
| `/api/v1/alarms` | Alert names, thresholds, notification configurations | **MEDIUM** — security configuration disclosure |
| `/api/v1/data` | Time-series metric values for any chart | **MEDIUM** — operational intelligence |
| `/api/v1/functions` | List of all registered plugin functions | **MEDIUM** — capability enumeration |
| `/api/v1/function` | Execute a registered function (subject to `access` ACL) | **HIGH** — may expose sensitive operational data |

#### Threat Scenarios: Unauthenticated API

| Threat ID | Scenario | Impact | Mitigation |
|---|---|---|---|
| API-T1 | **Reconnaissance**: Attacker queries `/api/v1/info` to fingerprint the host (OS, kernel, CPU count, cloud provider, region) | Enables targeted exploitation of known CVEs | IP-based ACLs in `netdata.conf`; firewall rules blocking port 19999 |
| API-T2 | **Infrastructure mapping**: Attacker enumerates `/api/v1/contexts` to discover all monitored services, databases, and applications | Reveals running services (MySQL, Redis, etc.) without authentication | Bind to localhost only in `netdata.conf` (`bind to = 127.0.0.1`) |
| API-T3 | **Function invocation**: An `access = any` function is invoked without credentials | Data exfiltration (e.g., process list, open files) | Audit all plugin function `access` levels; prefer `member` or `admin` |
| API-T4 | **Alert rule disclosure**: `/api/v1/alarms` reveals threshold values and notification targets | Attacker learns normal vs. abnormal thresholds to stay below detection | Restrict API to authenticated proxy |
| API-T5 | **DDoS via API flooding**: Attacker sends high-volume requests to the API server | Resource exhaustion on the monitored host | Fixed thread count (configured max threads); the Web API server is in `src/web/server/` |
| API-T6 | **Streaming key exposure**: If a streaming API key is logged or visible in responses | Child agents can be spoofed | Keys are in config files only; not returned via API |

### 5.2 Access Control Configuration

The agent provides these configurable controls in `netdata.conf`:

```ini
[web]
    bind to = *                    # THREAT: default binds to all interfaces
    # bind to = 127.0.0.1          # Recommended for single-host deployments

[web]
    allow connections from = *     # THREAT: allows all source IPs
    allow management from = localhost  # Management API restricted by default

[streaming]
    api key = <UUID>               # Pre-shared key for agent-to-agent streaming
```

**Default security posture:** Netdata's default configuration exposes the Web API on all network interfaces without authentication. This is intentional for monitoring use cases within trusted LAN segments, but is a significant risk if the host is network-accessible.

### 5.3 Registry Threat Surface

The `src/registry/` component maintains a user-facing registry mapping browser cookies to known Netdata instances. **Source: `docs/security-and-privacy-design/netdata-agent-security.md`** — cookies identify users across Netdata instances.

| Threat | Detail |
|---|---|
| Registry enumeration | Registry may disclose hostnames of other Netdata agents a browser has visited |
| Cookie theft | Session cookie allows impersonating a user across all their Netdata instances |
| Mitigation | Registry can be pointed to a central server or disabled; cookies are first-party only |

---

## 6. Supply Chain Risks: Plugin Execution Model

### 6.1 Plugin Trust Model

**Source:** `src/plugins.d/README.md`

Netdata's plugin system is designed for extensibility but introduces meaningful supply chain risks:

> *"External data collection plugins may be written in any computer language."*
> *"External data collection plugins may use O/S capabilities or `setuid` to run with escalated privileges."*

Plugins are discovered and auto-launched from two directories:
- `NETDATA_PLUGINS_DIR` (stock plugins, typically `/usr/libexec/netdata/plugins.d/`)
- `NETDATA_USER_PLUGINS_DIRS` (user-supplied plugins)

The daemon scans for new plugins every `check for new plugins every` seconds (default configurable in `[plugins]` section of `netdata.conf`). **Any executable placed in these directories will be automatically launched.**

### 6.2 Plugin Inventory

The following external plugins ship with Netdata and each represents a supply chain component:

| Plugin | Language | Privileges Required | Risk Surface |
|---|---|---|---|
| `apps.plugin` | C | Elevated (process tree access) | Full process enumeration; sees all user processes |
| `ebpf.plugin` | C | Root/CAP_SYS_ADMIN | Kernel-level access via eBPF; highest privilege level |
| `freeipmi.plugin` | C | Elevated (IPMI access) | Hardware sensor access; physical infrastructure data |
| `go.d.plugin` | Go | Standard | Connects to 3rd-party APIs; broad network access |
| `python.d.plugin` | Python | Standard | Orchestrator for Python modules; broad ecosystem |
| `charts.d.plugin` | Bash | Standard | Shell-based; susceptible to shell injection if misconfigured |
| `cups.plugin` | C | Standard | CUPS API access |
| `nfacct.plugin` | C | NET_ADMIN capability | Netfilter access; firewall rule visibility |
| `perf.plugin` | C | Elevated (PMU access) | CPU performance counter access |

### 6.3 Supply Chain Threat Scenarios

| Threat ID | Scenario | Impact | Mitigating Control |
|---|---|---|---|
| SC-T1 | **Malicious plugin binary**: Attacker replaces a plugin binary in `NETDATA_PLUGINS_DIR` (e.g., via package manager compromise) | Full host compromise at the plugin's privilege level | Package signature verification; filesystem integrity monitoring on plugin directories |
| SC-T2 | **Malicious user plugin**: A third-party plugin installed to `NETDATA_USER_PLUGINS_DIRS` contains backdoor code | Data exfiltration; privilege escalation via setuid wrapper | Audit all plugins in user plugin directories; restrict write access to these directories |
| SC-T3 | **Plugin orchestrator abuse** (`python.d`, `charts.d`): A malicious module is dropped into the orchestrator's module directory | Code execution under orchestrator's runtime | Module directories should have root ownership; restrict write access |
| SC-T4 | **setuid plugin privilege escalation**: A vulnerability in `apps.plugin` or `ebpf.plugin` is exploited | Root compromise of the monitored host | Keep plugins patched; use Linux security modules (AppArmor/SELinux) to confine plugin capabilities |
| SC-T5 | **Protocol injection via plugin output**: A plugin is tricked into outputting crafted `FUNCTION` or `HOST_DEFINE` lines | Rogue virtual hosts added to Netdata; false metric data | Netdata's parser (`pluginsd_parser.c`, 60 KB) validates protocol syntax, but semantic validation depends on plugin correctness |
| SC-T6 | **Dependency compromise**: The `go.d.plugin` (Go) or Python modules depend on third-party libraries that are compromised | Supply chain attack affecting monitoring infrastructure | Dependency auditing; `go.sum` and Python requirements pinning; GitHub Dependabot is configured (`.github/dependabot.yml`) |
| SC-T7 | **eBPF program compromise**: `ebpf.plugin` loads eBPF programs into the kernel | Kernel-level arbitrary code execution | eBPF verifier provides some protection; kernel version requirements limit scope |

### 6.4 Plugin Communication Security (Code-Level)

From `src/plugins.d/README.md`, the unidirectional communication design is a deliberate security control:

> *"The communication between the external plugin and Netdata is unidirectional (from the plugin to Netdata), so that Netdata cannot manipulate an external plugin running with escalated privileges."*

The exception is the **Functions** feature, where Netdata does send commands back to the plugin's `stdin`:
```
FUNCTION transaction_id timeout "name and parameters" "user permissions value" "source of request"
```

This bidirectional channel (for functions only) means:
1. A plugin with `setuid` escalated privileges **can receive commands from the daemon**
2. The daemon (running as unprivileged `netdata`) acts as an intermediary between user requests and elevated plugin functions
3. Function permissions (`any`, `member`, `admin`) gate who can trigger this

**Critical control:** The `"user permissions value"` field in the `FUNCTION` command sent to the plugin encodes the ACL context, allowing the plugin to enforce its own authorization.

### 6.5 Dependabot and CI Security

The repository includes `.github/dependabot.yml` for automated dependency updates and `.github/codeql/` for CodeQL static analysis, indicating automated supply chain monitoring for known vulnerabilities in dependencies.

---

## 7. Cross-Cutting Security Controls

### 7.1 Defense Against Common Attack Classes

**Source:** `docs/security-and-privacy-design/netdata-agent-security.md`

| Attack Class | Defense Mechanism | Code Location |
|---|---|---|
| SQL Injection | "No UI data passed back to database-accessing plugins" — plugins are read-only collectors | `src/plugins.d/` — unidirectional pipe design |
| DDoS (API flood) | Fixed thread counts; automatic memory management | `src/web/server/` |
| Memory exhaustion | System Resource Starvation defense: nice priority; early termination in OS-OOM events | `src/daemon/` |
| Command injection | Plugin stdin only receives structured FUNCTION commands, not shell strings | `src/plugins.d/pluginsd_functions.c` |
| Replay attacks | MQTT transaction IDs; ACLK connection state tracking | `src/aclk/aclk_query_queue.h` |

### 7.2 Privilege Separation Architecture

```
netdata daemon        → runs as unprivileged 'netdata' user
apps.plugin           → runs with elevated privileges (setuid or cap)
ebpf.plugin           → requires CAP_SYS_ADMIN or root
freeipmi.plugin       → requires IPMI device access
charts.d.plugin       → runs as 'netdata' user (bash scripts)
go.d.plugin           → runs as 'netdata' user
python.d.plugin       → runs as 'netdata' user
```

Escalated-privilege plugins perform only predefined collection tasks and keep raw data inside the local process per the documented design.

### 7.3 Compliance Controls

| Standard | Relevant Control |
|---|---|
| PCI DSS Level 1 | Raw data locality (no cardholder data transmitted); audit logs; TLS on all external connections |
| HIPAA | PHI never flows through metrics pipeline; metadata only; access controls configurable |
| GDPR/CCPA | Cloud stores only email and IP; 90-day deletion cycle; self-service account deletion |
| SOC 2 Type 2 | Netdata Cloud holds SOC 2 Type 1 and Type 2 attestations |

---

## 8. Threat Summary Table (STRIDE)

| ID | Threat | Category | Zone | Likelihood | Impact | Overall Risk |
|---|---|---|---|---|---|---|
| ACLK-T1 | Function call injection via compromised cloud | Tampering / Elevation | TB-2 | Low | High | **Medium** |
| ACLK-T2 | Metadata poisoning by cloud MitM | Tampering | TB-2 | Low | Medium | **Low** |
| ACLK-T3 | Alert suppression by cloud | Denial of Service | TB-2 | Low | High | **Medium** |
| ACLK-T4 | DynCfg injection changing plugin behavior | Tampering | TB-2 | Low | High | **Medium** |
| ACLK-T7 | TLS MitM on ACLK WSS connection | Information Disclosure | TB-2 | Low | High | **Medium** |
| API-T1 | System fingerprinting via unauthenticated `/api/v1/info` | Information Disclosure | TB-4 | **High** | High | **HIGH** |
| API-T2 | Infrastructure mapping via `/api/v1/contexts` | Information Disclosure | TB-4 | **High** | High | **HIGH** |
| API-T3 | Invocation of `access=any` functions without credentials | Elevation of Privilege | TB-4 | **High** | High | **HIGH** |
| API-T5 | API flooding / resource exhaustion | Denial of Service | TB-4 | Medium | Medium | **Medium** |
| SC-T1 | Malicious plugin binary via package compromise | Tampering | Zone 1 | Low | Critical | **HIGH** |
| SC-T2 | Malicious user-installed plugin | Tampering / Elevation | Zone 1 | Medium | Critical | **HIGH** |
| SC-T4 | Vulnerability exploitation in setuid plugin | Elevation of Privilege | Zone 1 | Low | Critical | **Medium** |
| SC-T6 | Third-party dependency compromise (Go/Python) | Tampering | Zone 1 | Low | High | **Medium** |
| SC-T7 | eBPF program compromise leading to kernel execution | Elevation of Privilege | Zone 1 | Very Low | Critical | **Medium** |

---

## 9. Auditor Checklist

### Network Exposure
- [ ] **Verify port 19999 is NOT exposed to untrusted networks.** Run `ss -tlnp | grep 19999` on every Netdata agent.
- [ ] **Confirm `bind to` in `netdata.conf` is not `*` (all interfaces)** if the host has public network interfaces.
- [ ] **Verify TLS is configured** for the Web API if direct browser access is required: `[web] → ssl key file` and `ssl certificate file` must be set.
- [ ] **Confirm streaming connections use TLS**: `[stream]` section must have `ssl skip certificate verification = no`.

### ACL