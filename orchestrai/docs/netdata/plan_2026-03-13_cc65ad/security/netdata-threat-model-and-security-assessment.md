---

## Table of Contents

1. [Scope and Architecture Overview](#1-scope-and-architecture-overview)
2. [Trust Boundaries](#2-trust-boundaries)
3. [Data in Transit: Flows and Protections](#3-data-in-transit-flows-and-protections)
4. [ACLK Threat Model](#4-aclk-threat-model)
5. [Agent API Access Control Threats](#5-agent-api-access-control-threats)
6. [Supply Chain Risks: Plugin Execution Model](#6-supply-chain-risks-plugin-execution-model)
7. [Threat Summary Matrix (STRIDE)](#7-threat-summary-matrix-stride)
8. [Recommended Mitigations by Deployment Tier](#8-recommended-mitigations-by-deployment-tier)

---

## 1. Scope and Architecture Overview

Netdata is a real-time infrastructure monitoring system comprising four principal components that interact across well-defined boundaries. The codebase reveals the following runtime components (verified in `src/`):

| Component | Code Location | Role |
|---|---|---|
| **Netdata Agent (daemon)** | `src/daemon/`, `src/database/`, `src/health/` | Collects, stores, and serves metrics on the monitored host |
| **External Plugins** | `src/plugins.d/`, `src/collectors/`, `src/go/` | Collect raw data from OS, applications, and services; communicate with the daemon via stdin/stdout pipes |
| **Streaming / Parent Node** | `src/streaming/` | Receives streamed metrics from child agents over TLS-protected TCP |
| **ACLK (Agent-Cloud Link)** | `src/aclk/` | Outbound MQTT-over-WebSocket-over-TLS connection to Netdata Cloud |
| **Web API / Dashboard Server** | `src/web/server/`, `src/web/api/` | HTTP/HTTPS endpoint for dashboards, API queries, and Functions calls |
| **Netdata Cloud** | External SaaS (AWS) | Aggregates metadata; does **not** store raw metrics |
| **End-User Browser** | External | Connects to Cloud or directly to Agent API |
| **Registry** | `src/registry/` | Tracks user-to-agent relationships using browser cookies |

---

## 2. Trust Boundaries

Trust boundaries define where enforcement of authentication and authorization must occur. The following boundaries are derived from code-level analysis.

### 2.1 Boundary Map

```
┌─────────────────────────────────────────────────────────────────────┐
│  MONITORED HOST (Trust Zone A — Highest)                            │
│                                                                     │
│  ┌──────────────┐  stdin/stdout  ┌──────────────────────────────┐  │
│  │ External     │◄──────────────►│  Netdata Daemon (netdata)    │  │
│  │ Plugins      │  in-memory pipe│  src/daemon/                 │  │
│  │ (setuid ok)  │                │  src/database/               │  │
│  └──────────────┘                └────────────┬─────────────────┘  │
└────────────────────────────────────────────────│────────────────────┘
                           ┌────────────────────┘
            ┌──────────────▼──────────────────────────────────┐
            │  NETWORK BOUNDARY (Trust Zone B)                │
            │                                                  │
            │  ┌──────────────┐    ┌────────────────────────┐ │
            │  │ Web API      │    │ Streaming Connection   │ │
            │  │ HTTP/HTTPS   │    │ API key + optional TLS │ │
            │  │ src/web/     │    │ src/streaming/         │ │
            │  └──────┬───────┘    └────────────┬───────────┘ │
            │         │                         │             │
            └─────────│─────────────────────────│─────────────┘
                      │                         │
         ┌────────────▼───────┐    ┌────────────▼────────────┐
         │  END-USER BROWSER  │    │  PARENT NETDATA NODE    │
         │  (Trust Zone D)    │    │  (Trust Zone B-ext)     │
         │  Untrusted         │    │  API-key authenticated  │
         └────────────────────┘    └─────────────────────────┘
                       ┌────────────────────────────┐
                       │  ACLK → NETDATA CLOUD       │
                       │  MQTT/WSS/TLS + Claim Token │
                       │  src/aclk/                  │
                       │  (Trust Zone C — External)  │
                       └────────────────────────────┘
```

### 2.2 Trust Zone Definitions

| Zone | Boundary | What is Trusted | What is Not Trusted |
|---|---|---|---|
| **A — Agent Host** | OS process boundary | Daemon process, plugin pipes | Plugin output content (parsed, not executed blindly) |
| **B — Local Network / Streaming** | TCP connection with API key | Agents with valid streaming API keys and optional TLS | Unauthenticated connections; unencrypted traffic without explicit TLS config |
| **C — Netdata Cloud** | ACLK claim + public-key cryptography + TLS | Cloud control plane for orchestrating queries | Cloud's ability to inject arbitrary code; Cloud cannot push executables |
| **D — End-User Browser** | OAuth / JWT (Cloud); unauthenticated (direct agent) | Authenticated Cloud users with RBAC roles | All direct agent API callers unless ACLs or proxy authentication is in place |

### 2.3 Claim Token and Cloud Registration

Node registration is handled in `src/claim/`. The claiming process establishes mutual authentication for the ACLK channel. Before claiming, the ACLK is **not activated** (`src/aclk/README.md`: *"Activates only after you connect a node to your Space"*). This is a material security control: an unclaimed agent does not initiate any outbound cloud connection.

---

## 3. Data in Transit: Flows and Protections

### 3.1 Data Flow Inventory

| Flow | Channel | Data Types | Encryption | Authentication |
|---|---|---|---|---|
| Plugin → Daemon | In-memory stdin/stdout pipe | Raw counters, metric values, chart definitions, host labels | N/A (in-process) | OS process isolation; pipe is not accessible outside daemon |
| Agent → Streaming Parent | TCP (port configurable) | Processed metric values, chart metadata, alert states, replication data | **Optional TLS** (must be explicitly configured) | API key (pre-shared secret in `stream.conf`) |
| Agent → ACLK → Cloud | MQTT over WebSocket over TLS port 443 | Metric metadata, alert configurations, minimal system metadata (hostname, OS, kernel version, cloud instance type) | **Mandatory TLS** | Public/private key pair established during claim; JWT for Cloud-side sessions |
| Agent Web API → Browser | HTTP or HTTPS | Metric time-series, chart metadata, alert state, function results | **Optional TLS** (default: HTTP, no auth) | None by default; ACLs by IP; reverse proxy auth recommended |
| Cloud → Browser | HTTPS | Aggregated dashboard views, alert notifications, metadata | **Mandatory TLS** | OAuth (Google/GitHub) or short-lived email token; JWT session |
| Agent → Exporting Connectors | Varies per connector (`src/exporting/`) | Metric values | Connector-specific | Connector-specific credentials |
| Registry → Browser | HTTP/HTTPS | Machine GUIDs, hostnames, user cookie | TLS if configured | Browser cookie (no server-side auth) |

### 3.2 What Netdata Cloud Stores (Verified in `docs/security-and-privacy-design/netdata-cloud-security.md`)

Netdata Cloud explicitly stores **no raw metrics**. The verified metadata stored is:

| Metadata Field | Source API Endpoint |
|---|---|
| Hostname | `/api/v1/info` |
| Metric context names and metadata | `/api/v1/contexts` |
| Alert configurations | `/api/v1/alarms` |
| Email address (user identity) | Account registration |
| IP addresses | Web proxy access logs |

All metadata is stored on AWS infrastructure, with a copy pushed to Google BigQuery for analytics.

### 3.3 Streaming Protection Gap

The streaming channel (`src/streaming/`) uses a pre-shared API key but **TLS is optional and not enforced by default**. On untrusted networks (e.g., multi-tenant environments, cross-datacenter links), metrics and chart metadata travel in plaintext unless the operator explicitly configures TLS in `stream.conf`. This represents a confidentiality risk for metric data traversing untrusted infrastructure.

**Risk:** An attacker with network access can passively capture all streamed metrics and infer system state (CPU usage spikes, memory pressure, service availability patterns) without authentication.

---

## 4. ACLK Threat Model

### 4.1 ACLK Architecture (from `src/aclk/`)

The ACLK subsystem consists of the following key source files:

| File | Role |
|---|---|
| `aclk.c` (48 KB) | Main ACLK loop, connection lifecycle management |
| `aclk_otp.c` (31 KB) | One-time provisioning and claim token exchange |
| `aclk_query.c` / `aclk_query_queue.c` | Cloud-originated query handling and queuing |
| `aclk_rx_msgs.c` (17 KB) | Processing inbound messages from Cloud |
| `aclk_tx_msgs.c` (8 KB) | Sending outbound messages to Cloud |
| `https_client.c` (35 KB) | TLS HTTPS client used for OTP/provisioning |
| `mqtt_websockets/` | MQTT-over-WebSocket transport layer |
| `aclk_proxy.c` (7 KB) | HTTP/SOCKS proxy support for ACLK channel |

The ACLK connection is **outbound only** from the agent's perspective. Required domains for allowlisting: `app.netdata.cloud`, `api.netdata.cloud`, `mqtt.netdata.cloud` (port 443).

### 4.2 Threat Scenarios: Attacker With Cloud Access

The following scenarios assess what an adversary who has compromised a Netdata Cloud account or the Cloud infrastructure itself could do.

#### T-ACLK-1: Unauthorized Dashboard Access (Account Compromise)

**Threat:** Attacker obtains a Cloud user's credentials (phishing, credential stuffing).  
**Capability:** Access to all dashboards, metric metadata, and alert configurations for all nodes in the compromised Space.  
**Impact:** Intelligence gathering — attacker can observe system performance patterns, scheduled maintenance windows (visible from metric gaps), software versions (via `_os_version`, `_kernel_version` labels), and infrastructure topology.  
**Limitation:** Raw metrics are not stored in Cloud. Historical data requires querying agents via ACLK. If the agent is offline, no data retrieval is possible.  
**Mitigation:** SSO with MFA (custom SSO available per contract); principle of least privilege using Netdata Cloud roles (admin/member with different RBAC rights).

#### T-ACLK-2: Malicious Cloud → Agent Command Injection

**Threat:** Attacker with Cloud infrastructure access (or a compromised `mqtt.netdata.cloud`) attempts to send malicious commands to agents via the ACLK channel.  
**Capability:** Cloud can send query requests to agents via `aclk_query.c` and `aclk_rx_msgs.c`. These are routed to the internal Web API or Functions system.  
**Limitation:** The ACLK message protocol (Protobuf/gRPC schemas in `src/aclk/aclk-schemas/` and `src/aclk/schema-wrappers/`) constrains what operations can be requested. The agent only executes predefined API queries and registered plugin Functions — **it does not accept executable code or shell commands via ACLK**.  
**Impact (if Cloud is fully compromised):** Attacker can trigger any registered Function with `any` or `member` access level, retrieve metric data, read alert configurations. Cannot install software, write files, or execute arbitrary system commands.  
**Residual Risk:** Functions registered by plugins with access level `any` can be invoked by anyone with Cloud access without further authentication. Functions with access level `admin` require Cloud-side RBAC enforcement.  
**Mitigation:** Review all plugin-registered Functions (`FUNCTION` commands in `src/plugins.d/README.md`) and ensure sensitive functions are registered with `admin` access level.

#### T-ACLK-3: MQTT Broker Man-in-the-Middle

**Threat:** Attacker intercepts or impersonates `mqtt.netdata.cloud`.  
**Capability:** Without successful TLS certificate validation bypass, this attack fails. The ACLK uses mandatory TLS with server certificate verification via `https_client.c`.  
**Mitigation (existing):** TLS is mandatory; IP-based allowlisting is explicitly discouraged in favor of domain allowlisting because Cloud uses CDN-distributed edge nodes that change IPs. Certificate pinning is not documented as implemented.  
**Residual Risk:** If a CA in the system trust store is compromised, a rogue certificate could enable MITM. Certificate pinning would mitigate this but is not confirmed present.

#### T-ACLK-4: Claiming Token Theft

**Threat:** The claim token (`src/claim/`) is stolen during provisioning.  
**Capability:** An attacker with the claim token before it is consumed could associate the agent with an attacker-controlled Space.  
**Mitigation:** The claim process uses one-time provisioning via `aclk_otp.c`. Tokens are short-lived. Once claimed, the agent uses its established public/private key pair for ongoing authentication, not the original claim token.

#### T-ACLK-5: Metadata Inference Attack

**Threat:** Netdata Cloud or an attacker who has read access to Cloud metadata can infer sensitive infrastructure details.  
**Capability:** The metadata stored includes `_cloud_provider_type`, `_cloud_instance_type`, `_cloud_instance_region`, `_os_name`, `_os_version`, `_kernel_version`, `_virtualization`, `_container`, `_is_k8s_node`. These fields are defined as special HOST_LABEL keys in `src/plugins.d/README.md` and transmitted to Cloud.  
**Impact:** Reveals cloud provider, instance class, geographic region, OS, and kernel version — sufficient to identify applicable CVEs and target unpatched systems.  
**Mitigation:** Restrict the Space to trusted administrators only; use Cloud RBAC to limit who can view node metadata; evaluate whether Cloud connectivity is required for air-gapped deployments.

---

## 5. Agent API Access Control Threats

### 5.1 Default Authentication Posture

As stated in `docs/security-and-privacy-design/netdata-agent-security.md`:

> **Direct Agent Access** — Typically unauthenticated, relies on LAN isolation or firewall policies.

The web server code lives in `src/web/server/` and exposes API endpoints at `src/web/api/`. **By default, the Netdata Agent HTTP API requires no authentication.**

### 5.2 Threat Scenarios: Unauthenticated API Access

#### T-API-1: Metric Exfiltration

**Threat:** Any network-reachable host can query `/api/v1/data`, `/api/v1/allmetrics`, `/api/v1/contexts`.  
**Data Exposed:** All collected metric time-series, chart dimensions, and context names.  
**Impact:** An attacker inside the same network segment can build a detailed performance profile of all monitored hosts.  
**Mitigation:** Configure IP-based ACLs in `netdata.conf` (`[web]` section); place agent behind an authenticating reverse proxy (nginx, Apache with `auth_basic` or OAuth2 proxy); restrict the listening interface to `localhost` if only local dashboard access is needed.

#### T-API-2: Function Invocation

**Threat:** Functions registered by plugins (e.g., `apps.plugin` process list, `go.d.plugin` module data) are invocable via `/api/v1/function`.  
**Key Risk:** Functions registered with `access = any` (per `src/plugins.d/README.md`) are accessible to unauthenticated callers. The `FUNCTION` protocol allows plugins to return live process lists, active connections, and other sensitive runtime data.  
**Impact:** Unauthenticated attacker can invoke process list functions to enumerate running processes, users, and services on the monitored host.  
**Example:** `apps.plugin` and `go.d.plugin` both register Functions exposed through this endpoint.  
**Mitigation:** Register sensitive functions with `member` or `admin` access; deploy an authenticating reverse proxy for all external-facing agents.

#### T-API-3: Registry Poisoning

**Threat:** The registry (`src/registry/`) uses a browser cookie to track which agents a user has visited. It stores machine GUIDs and hostnames.  
**Impact:** If the registry endpoint is unauthenticated and accessible, an attacker can enumerate hostnames and machine GUIDs for all agents that have registered with this registry server.  
**Mitigation:** Disable the registry on publicly accessible agents; use only a centralized private registry behind authentication.

#### T-API-4: Dynamic Configuration (DynCfg) Exposure

**Threat:** The `CONFIG` protocol (`src/plugins.d/README.md`) allows plugins to expose configuration management endpoints accessible via the Functions API.  
**Capability:** An authenticated (or unauthenticated if `access = any`) user can read (`get`) or modify (`update`, `add`, `remove`) dynamic plugin configurations.  
**Impact:** Attacker could disable collectors, change collection targets, or inject configurations causing the agent to query attacker-controlled endpoints.  
**Mitigation:** DynCfg `view permissions` and `edit permissions` are bitmaps enforced by the Netdata permission system; set them to non-zero values to require authenticated admin access.

#### T-API-5: WebSocket / RTC Upgrade Abuse

The web server includes `src/web/websocket/` and `src/web/rtc/` directories, indicating WebSocket and real-time communication capabilities.  
**Threat:** If WebSocket upgrade endpoints are unauthenticated, a persistent connection could allow an attacker to monitor all live metric streaming for extended periods without triggering rate limits designed for HTTP requests.  
**Mitigation:** Apply the same ACL and reverse proxy authentication controls to WebSocket endpoints as to HTTP API endpoints.

---

## 6. Supply Chain Risks: Plugin Execution Model

### 6.1 Plugin Execution Architecture (from `src/plugins.d/`)

The `plugins.d` system (`src/plugins.d/plugins_d.c`, `pluginsd_parser.c`) executes external programs as child processes and communicates via stdin/stdout pipes. Key security properties documented in `src/plugins.d/README.md`:

> "The communication between the external plugin and Netdata is **unidirectional** (from the plugin to Netdata), so that Netdata cannot manipulate an external plugin running with escalated privileges."

Plugins communicate via a defined text protocol. The daemon parses only recognized keywords: `CHART`, `DIMENSION`, `BEGIN`, `SET`, `END`, `FUNCTION`, `CONFIG`, `HOST_DEFINE`, etc. Unrecognized output causes the plugin to be disabled.

### 6.2 Plugin Privilege Model

| Plugin | Language | Privilege Escalation | Risk Level |
|---|---|---|---|
| `apps.plugin` | C | `setuid` (reads `/proc`) | Medium — accesses full process tree |
| `ebpf.plugin` | C | Requires root or `CAP_SYS_ADMIN` | High — kernel-level access |
| `freeipmi.plugin` | C | Escalated (IPMI hardware access) | Medium |
| `nfacct.plugin` | C | Requires `CAP_NET_ADMIN` | Medium — network subsystem |
| `go.d.plugin` | Go | User-level | Low |
| `python.d.plugin` | Python | User-level | Low–Medium (scripted) |
| `charts.d.plugin` | Bash | User-level | Medium (shell scripting) |

Plugins with `setuid` or elevated capabilities are documented as performing **only predefined collection tasks** and keeping raw data inside their local process. They do not accept inbound commands from the daemon.

### 6.3 Supply Chain Threat Scenarios

#### T-SC-1: Malicious Plugin Installation

**Threat:** An attacker with write access to `/usr/libexec/netdata/plugins.d/` installs a malicious binary.  
**Trigger:** Netdata automatically scans this directory every 60 seconds (`check for new plugins every = 60` in `netdata.conf`) and starts new discovered plugins.  
**Impact:** Malicious plugin runs as the `netdata` user (or elevated if compiled with `setuid`), can exfiltrate data or establish persistence under the guise of a monitoring process. The auto-start behavior (`enable running new plugins = yes` by default) makes this a reliable persistence vector.  
**Mitigation:**  
  - Set `enable running new plugins = no` and explicitly whitelist plugins.  
  - Monitor the plugins directory for new or modified files (file integrity monitoring).  
  - Ensure strict write permissions on `/usr/libexec/netdata/plugins.d/`.

#### T-SC-2: Compromised Plugin Binary (Package Supply Chain)

**Threat:** A compromised version of `go.d.plugin` or `python.d.plugin` is delivered via the official Netdata package repository or via a distribution package manager.  
**Impact:** Since `go.d.plugin` collects from hundreds of data sources (databases, web servers, message queues, cloud APIs), a compromised version could exfiltrate credentials, connection strings, or sensitive endpoint data that plugins observe.  
**Mitigation:** Verify package signatures (`.deb`/`.rpm` GPG signatures); use Netdata's official installation scripts which verify checksums; monitor plugin processes with EDR solutions; use read-only container filesystems where applicable.

#### T-SC-3: Plugin Receiving Arbitrary Commands (FUNCTION Abuse)

**Threat:** While the communication is documented as primarily unidirectional, the daemon **does** send commands to plugin stdin: `FUNCTION`, `FUNCTION_PAYLOAD`, `FUNCTION_CANCEL`, `FUNCTION_PROGRESS` (per `src/plugins.d/README.md`). A malicious actor who can invoke a Function via the API can cause the daemon to forward that call to the plugin.  
**Impact:** The function parameters are passed through to the plugin. If the plugin does not properly validate and sanitize function parameters, this could result in injection vulnerabilities within the plugin's execution context.  
**Mitigation:** Plugins must validate all parameters received via `FUNCTION` calls; the daemon's role is routing, not sanitization.

#### T-SC-4: python.d.plugin and charts.d.plugin Module Trust

**Threat:** Python and Bash plugin modules are loaded dynamically. A malicious or vulnerable module added under the respective plugin directories could execute arbitrary code in the plugin's runtime context.  
**Impact:** Python and Bash are interpreted; a compromised module file could perform arbitrary operations in the `netdata` user context.  
**Mitigation:** Apply file integrity monitoring to module directories; restrict write access; review custom modules before deployment.

#### T-SC-5: Dependency Vulnerabilities in Go and Rust Crates

The repository includes `src/go/` (Go dependencies) and `src/crates/` (Rust dependencies). A `.github/dependabot.yml` is present, indicating automated dependency update monitoring.  
**Threat:** CVEs in transitive dependencies of `go.d.plugin` or Rust-based collectors could be exploited if a data source sends crafted responses.  
**Mitigation:** Dependabot is configured; ensure PRs from Dependabot are reviewed and merged promptly; conduct periodic SBOM reviews of Go and Rust dependency trees.

---

## 7. Threat Summary Matrix (STRIDE)

| Threat ID | Category | Component | Spoofing | Tampering | Repudiation | Info Disclosure | DoS | Elevation |
|---|---|---|:---:|:---:|:---:|:---:|:---:|:---:|
| T-ACLK-1 | ACLK | Cloud Account | ✓ | | | ✓ | | |
| T-ACLK-2 | ACLK | Cloud→Agent | | ✓ | | | | ✓ |
| T-ACLK-3 | ACLK | MQTT Transport | ✓ | ✓ | | ✓ | | |
| T-ACLK-4 | ACLK | Claim Token | ✓ | | | | | |
| T-ACLK-5 | ACLK | Metadata | | | | ✓ | | |
| T-API-1 | Web API | HTTP Endpoint | | | ✓ | ✓ | | |
| T-API-2 | Web API | Functions | | | ✓ | ✓ | | ✓ |
| T-API-3 | Web API | Registry | | | | ✓ | | |
| T-API-4 | Web API | DynCfg | | ✓ | ✓ | | | |
| T-API-5 | Web API | WebSocket | | | | ✓ | ✓ | |
| T-SC-1 | Supply Chain | Plugin Dir | | ✓ | | ✓ | | ✓ |
| T-SC-2 | Supply Chain | Package | | ✓ | | ✓ | | ✓ |
| T-SC-3 | Supply Chain | FUNCTION Proto | | ✓ | | | | ✓ |
| T-SC-4 | Supply Chain | Python/Bash | | ✓ | | | | ✓ |
| T-SC-5 | Supply Chain | Dependencies | | ✓ | | ✓ | ✓ | |

**Severity Ratings:**

| Threat ID | Likelihood (Default Config) | Impact | Overall |
|---|---|---|---|
| T-API-1 | High (unauthenticated by default) | Medium | **HIGH** |
| T-API-2 | High | High | **HIGH** |
| T-SC-1 | Medium (requires write access) | Critical | **HIGH** |
| T-ACLK-2 | Low (requires Cloud compromise) | High | **MEDIUM** |
| T-ACLK-5 | High | Medium | **MEDIUM** |
| T-SC-2 | Low | High | **MEDIUM** |
| T-API-4 | Medium | High | **MEDIUM** |
| T-ACLK-1 | Medium | Medium | **MEDIUM** |
| T-ACLK-3 | Low (TLS enforced) | High | **LOW–MEDIUM** |
| T-API-3 | Medium | Low | **LOW** |
| T-ACLK-4 | Low | Medium | **LOW** |

---

## 8. Recommended Mitigations by Deployment Tier

### 8.1 All Deployments (Baseline)

1. **Restrict Agent API listening interface**: Configure `bind to = 127.0.0.1` in `netdata.conf` `[web]` section unless external dashboard access is required.
2. **Enable ACLs**: Use `allow connections from` and `allow dashboard from` in `netdata.conf` to restrict API access by IP CIDR.
3. **Disable new plugin auto-discovery**: Set `enable running new plugins = no` and whitelist each plugin explicitly in `netdata.conf` `[plugins]`.
4. **File integrity monitoring**: Monitor `/usr/libexec/netdata/plugins.d/` and Python/Bash module directories for unauthorized modifications.
5. **Enable TLS for Streaming**: If streaming metrics between agents crosses any untrusted network segment, configure TLS in `stream.conf` on both sender and receiver.

### 8.2 Internet-Exposed or Multi-Tenant Deployments

6. **Authenticating reverse proxy**: Place Netdata Agent behind nginx, Caddy, or Apache with `auth_basic`, OAuth2 proxy, or mTLS to enforce authentication for all API and dashboard access. This is the primary documented mitigation for T-API-1 and T-API-2.
7. **Disable Registry on public-facing agents**: Set `[registry] enabled = no` unless a private centralized registry is required.
8. **Review Function access levels**: Audit all registered plugin Functions for access level `any` and determine whether `member` or `admin` is more appropriate for each.
9. **DynCfg permission hardening**: Ensure `view permissions` and `edit permissions` bitmaps in CONFIG definitions require authenticated admin access.

### 8.3 High-Security / Regulated Environments

10. **Disable ACLK for air-gapped deployments**: If Cloud connectivity is not required, do not claim nodes. An unclaimed agent does not activate the ACLK (`src/aclk/README.md`).
11. **Netdata Cloud RBAC**: Use role-based access control within Cloud spaces; grant minimum necessary roles (admin vs. member distinction provides access to different Function levels).
12. **Custom SSO with MFA**: Available per enterprise contract to mitigate T-ACLK-1.
13. **SBOM and dependency auditing**: Periodically review Go module dependency tree in `src/go/` and Rust crates in `src/crates/` against known CVE databases.
14. **`ebpf.plugin` privilege review**: Evaluate whether `ebpf.plugin` (requires `CAP_SYS_ADMIN` or root) is necessary; disable it in `netdata.conf` if kernel-level metrics are not required, as it represents the highest privilege boundary in the plugin execution model.
15. **Network segmentation**: Isolate streaming network segments (child-to-parent) from production application networks. Streaming API keys are long-lived pre-shared secrets and their compromise enables full metric access to a Parent node.

---

## Appendix A: Key Source Files for Auditors

| File | Security Relevance |
|---|---|
| `src/aclk/aclk.c` | ACLK connection lifecycle, reconnection logic |
| `src/aclk/aclk_otp.c` | Claim token provisioning, key exchange |
| `src/aclk/aclk_rx_msgs.c` | Inbound Cloud message handling — review for injection risks |
| `src/aclk/aclk_query.c` | Cloud-originated query dispatch — maps to agent API calls |
| `src/plugins.d/pluginsd_parser.c` | Plugin protocol parser — critical for T-SC-3 analysis |
| `src/plugins.d/pluginsd_functions.c` | Function invocation dispatch — review access level enforcement |
| `src/web/server/` | HTTP server — ACL and TLS configuration |
| `src/streaming/` | Streaming authentication and TLS logic |
| `src/claim/` | Node claiming and ACLK credential establishment |
| `src/registry/` | Browser registry — hostname and GUID storage |
| `docs/security-and-privacy-design/netdata-agent-security.md` | Official agent security design document |
| `docs/security-and-privacy-design/netdata-cloud-security.md` | Official Cloud security design document |

## Appendix B: Compliance Posture

Per `docs/security-and-privacy-design/`:

| Standard | Posture |
|---|---|
| **PCI DSS** | Agent supports PCI Level 1 compliance environments; raw data never transmitted |
| **