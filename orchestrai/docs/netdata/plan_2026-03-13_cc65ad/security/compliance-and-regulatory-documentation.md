# Netdata Compliance and Regulatory Documentation

**Repository:** `netdata/netdata` | **Document Type:** Security — Compliance  
**Authoritative Sources:** [`README.md`](https://github.com/netdata/netdata/blob/master/README.md), [`LICENSE`](https://github.com/netdata/netdata/blob/master/LICENSE), [`REDISTRIBUTED.md`](https://github.com/netdata/netdata/blob/master/REDISTRIBUTED.md)

---

## Table of Contents

1. [Executive Summary](#1-executive-summary)
2. [Open Source License Compliance](#2-open-source-license-compliance)
3. [Data Residency and Sovereignty](#3-data-residency-and-sovereignty)
4. [GDPR Considerations](#4-gdpr-considerations)
5. [SOC 2 Relevance](#5-soc-2-relevance)
6. [CII Best Practices Compliance](#6-cii-best-practices-compliance)
7. [Anonymous Telemetry and Opt-Out](#7-anonymous-telemetry-and-opt-out)
8. [Compliance Controls Summary Matrix](#8-compliance-controls-summary-matrix)
9. [Compliance Officer Recommendations](#9-compliance-officer-recommendations)

---

## 1. Executive Summary

Netdata is an open-source, real-time infrastructure monitoring platform governed by a three-component architecture, each with distinct licensing and compliance implications:

| Component | License | Compliance Scope |
|---|---|---|
| **Netdata Agent** | GPL-3.0-or-later | Open-source license obligations; data stays on-premises |
| **Netdata Cloud** | Proprietary (closed-source) | GDPR, SOC 2, data residency, user account data |
| **Netdata UI** | NCUL1 (closed-source, free to use) | Third-party component license obligations |

The fundamental architectural principle relevant to compliance is stated explicitly in the README: **"Your data stays in your infrastructure."** Netdata Cloud adds remote access and enterprise features but does **not** centralize metric storage. This distinction drives most compliance determinations documented herein.

---

## 2. Open Source License Compliance

### 2.1 Netdata Agent: GPL-3.0-or-later

The Netdata Agent (the core monitoring engine) is licensed under the **GNU General Public License version 3 or later (GPL-3.0-or-later)**. This is confirmed in the README ecosystem table:

> **Netdata Agent** — [GPL v3+](https://www.gnu.org/licenses/gpl-3.0)  
> License file: [`LICENSE`](https://github.com/netdata/netdata/blob/master/LICENSE)

**Key GPL-3.0 obligations for organizations:**

| Obligation | Description | Applicability |
|---|---|---|
| **Source Availability** | If you distribute a modified Netdata Agent binary, you must make the corresponding source code available | Applies if you redistribute Netdata (e.g., as part of a product) |
| **Copyleft** | Derivative works that are distributed must also be licensed under GPL-3.0-or-later | Applies to modifications distributed externally |
| **License Notice** | Copies must carry GPL-3.0 notices and the original copyright statements | Applies to all distribution |
| **No Additional Restrictions** | You may not impose further restrictions on recipients' rights | Applies if you redistribute |
| **Internal Use** | Using the Netdata Agent internally (not distributing) requires no source disclosure | Most enterprise deployments fall here — no disclosure obligation |

**Practical guidance:** Organizations deploying Netdata Agent internally for infrastructure monitoring have **no source-disclosure obligation** under GPL-3.0. The copyleft obligation is triggered only upon external distribution of modified binaries.

### 2.2 Redistributed Dependencies

The Netdata Agent redistributes third-party open-source libraries and tools. Their licenses are catalogued at:

- **[`REDISTRIBUTED.md`](https://github.com/netdata/netdata/blob/master/REDISTRIBUTED.md)** — Full inventory of redistributed components and their respective licenses.

Compliance officers conducting software composition analysis (SCA) should treat `REDISTRIBUTED.md` as the authoritative SBOM reference for the Agent binary. Organizations with strict license-approval policies (e.g., prohibiting LGPL, Apache 2.0, MIT, BSD) should review this file before deployment.

### 2.3 Netdata UI License

The Netdata UI is **closed-source** but free to use with the Netdata Agent and Cloud. It is delivered via CDN and governed by the [NCUL1 license](https://app.netdata.cloud/LICENSE.txt). Third-party open-source components integrated into the UI are listed at:

- [Netdata UI Third-Party Licenses](https://app.netdata.cloud/3D_PARTY_LICENSES.txt)

The UI is not distributed with the Agent source — it is delivered separately via CDN — so GPL copyleft does not extend to it.

### 2.4 Netdata Cloud License

Netdata Cloud is **closed-source, proprietary software** with free and paid tiers. It is not subject to open-source license obligations from the consumer's perspective. Organizations using Netdata Cloud as a SaaS service are governed by Netdata's Terms of Service and Privacy Policy (see [learn.netdata.cloud](https://learn.netdata.cloud)).

### 2.5 CNCF Membership and License Governance

Netdata is a member of the **Cloud Native Computing Foundation (CNCF)** and appears in the [CNCF Landscape](https://landscape.cncf.io/?item=observability-and-analysis--observability--netdata). CNCF membership requires projects to comply with CNCF IP Policy, which mandates Apache 2.0 for new CNCF-originated code — this does not override Netdata Agent's GPL-3.0 license for existing code but signals governance maturity.

---

## 3. Data Residency and Sovereignty

### 3.1 Architectural Principle: Distributed, Not Centralized

The README states the core architectural guarantee explicitly:

> **"Secure & Distributed – You can keep your data local with no central collection needed."**  
> **"Edge-Based – Processing at your premises. Distributes code instead of centralizing data."**

And in the Cloud section:

> **"No metric storage centralization"** (Netdata Cloud feature description)  
> **"Netdata Cloud is optional. Your data stays in your infrastructure."**

### 3.2 Netdata Agent (Agent-Local Deployment)

When the Netdata Agent runs without Netdata Cloud connectivity, **all metric data remains entirely local to the host**:

| Data Category | Storage Location | Retention Control |
|---|---|---|
| **Raw metrics (Tier 0)** | Local agent host disk | Controlled by `dbengine` configuration |
| **Per-minute roll-ups (Tier 1)** | Local agent host disk | Configurable retention |
| **Per-hour roll-ups (Tier 2)** | Local agent host disk | Configurable retention |
| **ML models** | Trained at the edge (agent host) | Local only |
| **Alert state** | Local agent | Local only |

Disk writes are flushed every 17 minutes using direct I/O with ZSTD compression. Agents can also operate in `alloc` or `ram` mode with **no disk writes at all**.

### 3.3 Parent-Child Streaming (On-Premises Centralization)

Organizations requiring centralized monitoring without cloud involvement can deploy **Netdata Parents** — on-premises metric aggregation nodes. Streaming configuration is documented at the [Streaming Configuration Reference](https://learn.netdata.cloud/docs/streaming/streaming-configuration-reference). Data flows only within the organization's own infrastructure.

### 3.4 Netdata Cloud: What Is and Is Not Transmitted

When agents are connected to Netdata Cloud, the README is explicit:

> **Netdata Cloud** — "No metric storage centralization"

| Data Category | Transmitted to Cloud? | Notes |
|---|---|---|
| **Raw metric time-series** | ❌ No | Stored on agent/parent only |
| **Dashboard metadata & queries** | ✅ Yes (in-flight, for rendering) | Metrics are queried from the agent and returned through the Cloud tunnel |
| **Alert notifications** | ✅ Yes | Centralized alert management feature |
| **Node metadata** (hostnames, labels) | ✅ Yes | Required for node registration and topology |
| **User account data** | ✅ Yes | Email, SSO identity, RBAC assignments |
| **UI configuration** | ✅ Yes | Dashboard customizations, alert configs |

### 3.5 Data Residency for Regulated Industries

Organizations subject to data sovereignty requirements (e.g., EU data protection law, US federal data localization, financial sector regulations) should note:

- **Agent-only deployment**: Complete data sovereignty — no data leaves the organization's infrastructure.
- **Parent-only deployment**: Full control over centralization geography.
- **Netdata Cloud deployment**: Node metadata and user account data is processed by Netdata's cloud infrastructure. Organizations should contact Netdata for current cloud region options (the README demo sites reference Frankfurt, New York, Atlanta, San Francisco, Toronto, Singapore, and Bangalore regions, indicating multi-region infrastructure).

**Recommendation for regulated industries:** Deploy Netdata Agent (and Netdata Parents for centralization) without Netdata Cloud connectivity to achieve full data residency compliance.

---

## 4. GDPR Considerations

### 4.1 Scope of GDPR Applicability

GDPR applies to the processing of **personal data** of EU residents. Infrastructure metrics (CPU usage, disk I/O, network throughput) are generally **not personal data** under GDPR Article 4, as they describe machine behavior rather than individuals. However, GDPR considerations arise in two specific contexts:

| Context | GDPR Relevance | Risk Level |
|---|---|---|
| **Per-process metrics** that could be linked to individual users | Potentially personal data if user-attributable | Medium |
| **Netdata Cloud user accounts** (name, email, login identity) | Personal data of Netdata Cloud users | Applies |
| **Log monitoring** (systemd-journal, Windows Event Log) | May contain personal data in log entries | Depends on log content |
| **Anonymous telemetry** from the agent | Anonymized; not personal data per Netdata | Low |

### 4.2 Netdata Cloud User Data Processing

Netdata Cloud collects and processes user account information (email addresses, SSO identity data, RBAC role assignments) to provide remote access, user management, and collaboration features. As a SaaS provider processing EU user data, Netdata acts as a **data processor** when handling account data on behalf of organizations, and as a **data controller** for its own account management.

**GDPR obligations for organizations using Netdata Cloud:**
- Verify Netdata's Data Processing Agreement (DPA) is in place (consult [Netdata's Privacy Policy](https://www.netdata.cloud/privacy))
- Confirm the legal basis for transmitting node metadata (legitimate interest or contract performance)
- Review Netdata's sub-processor list for Cloud infrastructure providers

### 4.3 Agent-Only Deployments and GDPR

Organizations deploying the Netdata Agent without Cloud connectivity are the **data controller** for all metric data collected. Key considerations:

- Metrics stored locally are under the organization's own data governance policies
- Log monitoring integrations (systemd-journal, Windows ETW) may capture log entries containing personal data — organizations must apply appropriate access controls and retention policies
- Netdata's built-in RBAC controls (requiring Netdata Cloud for management) and TLS-based inter-agent communication reduce exposure risk

### 4.4 Anonymous Telemetry

The Netdata Agent collects anonymous telemetry to improve the product. The README states:

> *"No private data is collected."*

Opt-out is provided via two mechanisms:
1. Pass `--disable-telemetry` to the installer script
2. Create `/etc/netdata/.opt-out-from-anonymous-statistics` and restart Netdata

This opt-out mechanism supports GDPR's privacy-by-design principle and allows organizations to eliminate any telemetry data flow.

---

## 5. SOC 2 Relevance

### 5.1 Overview

SOC 2 (Service Organization Control 2) is a framework for evaluating service organizations' controls over Security, Availability, Processing Integrity, Confidentiality, and Privacy (Trust Service Criteria). Its relevance depends on the deployment model:

### 5.2 Agent-Only Deployments

When Netdata is deployed as a self-hosted agent with no Cloud connectivity, **SOC 2 compliance is the organization's own responsibility**. Netdata as an open-source tool does not itself require SOC 2 attestation in this model. The agent's design characteristics that support customer SOC 2 programs include:

| SOC 2 Criteria | Netdata Agent Capability |
|---|---|
| **Security (CC6)** | TLS-encrypted inter-agent streaming; role-based local access; no metric data leaves the perimeter |
| **Availability (A1)** | Self-hosted; no dependency on third-party SaaS availability; agent-local storage survives network outages |
| **Processing Integrity (PI1)** | Per-second metric accuracy; ML anomaly detection provides processing integrity monitoring |
| **Confidentiality (C1)** | Data stored locally; encryption in transit; no third-party metric exposure |
| **Privacy (P)** | Anonymous telemetry opt-out; no personal data collection by default |

### 5.3 Netdata Cloud and SOC 2

Organizations using **Netdata Cloud** as part of their monitoring stack must evaluate Netdata's own SOC 2 posture. Compliance officers should:

1. Request Netdata's current SOC 2 Type II report (if available) from Netdata's sales/compliance team
2. Review Netdata's [Security Design documentation](https://learn.netdata.cloud/docs/security-and-privacy-design) referenced in the README FAQ
3. Include Netdata Cloud in the organization's vendor risk management process

The README confirms that Netdata Cloud adds:
- User management and RBAC
- SSO integration
- Centralized alert management
- Role-based access control

These features are directly relevant to SOC 2 CC6 (Logical Access) controls and should be evaluated in vendor assessments.

### 5.4 Using Netdata in SOC 2 Audits

Netdata itself can serve as a **monitoring control** supporting SOC 2 compliance programs:

- **CC7 (System Operations)**: Real-time anomaly detection and alerting provides evidence of continuous system monitoring
- **CC7.2 (Monitoring of System Components)**: 800+ built-in integrations provide broad infrastructure visibility
- **A1 (Availability)**: Netdata's alerting on system resource exhaustion supports availability monitoring commitments

---

## 6. CII Best Practices Compliance

### 6.1 Badge Status

The Netdata project holds a **CII Best Practices badge** from the Linux Foundation's OpenSSF (Open Source Security Foundation), confirmed by the badge displayed in `README.md`:

```
[![CII Best Practices](https://bestpractices.coreinfrastructure.org/projects/2231/badge)](https://bestpractices.coreinfrastructure.org/projects/2231)
```

**Project ID:** 2231  
**Badge URL:** https://bestpractices.coreinfrastructure.org/projects/2231

The README FAQ also references this directly:

> *"Netdata follows [OpenSSF best practices](https://bestpractices.coreinfrastructure.org/en/projects/2231), has a security-first design, and is regularly audited by the community."*

### 6.2 What the Badge Attests

The CII Best Practices badge (passing level) certifies that the project meets criteria across:

| Category | Criteria Examples |
|---|---|
| **Basics** | Publicly known license, project website, bug reporting process |
| **Change Control** | Version control (Git/GitHub), unique version numbering |
| **Reporting** | Vulnerability reporting process (`github.com/netdata/netdata/security`) |
| **Quality** | Working build system, automated test suite, CI |
| **Security** | Uses TLS/HTTPS, no known unpatched vulnerabilities |
| **Analysis** | Static analysis applied (Coverity Scan confirmed by README badge) |

### 6.3 Coverity Static Analysis

The README also displays a **Coverity Scan badge**:

```
[![Coverity Scan](https://img.shields.io/coverity/scan/netdata)](https://scan.coverity.com/projects/netdata-netdata?tab=overview)
```

Coverity Scan provides automated static analysis for defects and security vulnerabilities in C/C++ code. This is relevant for compliance programs that require evidence of SAST (Static Application Security Testing) in the software development lifecycle.

### 6.4 CodeQL Analysis

The presence of `.github/codeql/` in the repository structure confirms that **GitHub CodeQL** analysis is also configured, providing an additional layer of automated security analysis integrated into CI/CD workflows.

### 6.5 Dependabot Configuration

`.github/dependabot.yml` confirms that **GitHub Dependabot** is configured for automated dependency vulnerability scanning and update PRs, supporting SBOM currency and supply chain security.

---

## 7. Anonymous Telemetry and Opt-Out

### 7.1 What Is Collected

The Netdata Agent collects anonymous telemetry described in the README as:

> *"Anonymous telemetry helps improve the product... Telemetry helps us understand usage, not track users. No private data is collected."*

### 7.2 Opt-Out Mechanisms

Two opt-out mechanisms are provided:

**Method 1: Installer flag**
```bash
bash <(curl -Ss https://my-netdata.io/kickstart.sh) --disable-telemetry
```

**Method 2: File-based opt-out (post-install)**
```bash
touch /etc/netdata/.opt-out-from-anonymous-statistics
systemctl restart netdata
```

### 7.3 Compliance Implications

| Regulation | Consideration |
|---|---|
| **GDPR** | Opt-out mechanism satisfies privacy-by-design; telemetry is anonymized and non-personal |
| **CCPA** | Organizations may opt out on behalf of systems they control |
| **HIPAA** | Healthcare organizations should apply opt-out as a precaution; metric telemetry does not include PHI |
| **FedRAMP** | Government deployments should opt out to prevent any outbound telemetry to non-authorized systems |

---

## 8. Compliance Controls Summary Matrix

| Compliance Area | Agent-Only | Agent + Parents | Agent + Cloud | Key Reference |
|---|---|---|---|---|
| **GPL-3.0 License** | ✅ Internal use, no obligation | ✅ Internal use, no obligation | ✅ Agent GPL; Cloud proprietary | `LICENSE`, `REDISTRIBUTED.md` |
| **Data Residency** | ✅ 100% local | ✅ 100% on-premises | ⚠️ Node metadata in Cloud | README architecture description |
| **GDPR (metrics)** | ✅ Organization controls all data | ✅ Organization controls all data | ⚠️ Review Netdata DPA | Netdata Privacy Policy |
| **GDPR (user data)** | ✅ No user accounts | ✅ No user accounts | ⚠️ Cloud user account data | Netdata Privacy Policy |
| **Anonymous Telemetry** | ⚠️ Opt-out available | ⚠️ Opt-out available | ⚠️ Opt-out available | README FAQ |
| **SOC 2 (as tool)** | ✅ Supports CC6, CC7, A1 | ✅ Supports CC6, CC7, A1 | ✅ + RBAC, SSO controls | README Cloud features |
| **SOC 2 (vendor)** | N/A (self-hosted) | N/A (self-hosted) | ⚠️ Request Netdata SOC 2 report | Netdata compliance team |
| **CII Best Practices** | ✅ Badge held (Project #2231) | ✅ Same | ✅ Same | README badge |
| **SAST (Coverity)** | ✅ Active | ✅ Active | ✅ Active | README badge, scan.coverity.com |
| **SAST (CodeQL)** | ✅ Configured | ✅ Configured | ✅ Configured | `.github/codeql/` |
| **Dependency Scanning** | ✅ Dependabot configured | ✅ Same | ✅ Same | `.github/dependabot.yml` |

**Legend:** ✅ = Low compliance risk / fully supported | ⚠️ = Requires assessment or action

---

## 9. Compliance Officer Recommendations

### For Highly Regulated Industries (Healthcare, Finance, Government)

1. **Deploy Agent-Only**: Use Netdata Agent without Netdata Cloud connectivity to achieve full data sovereignty. All metric data remains on-premises.
2. **Use Netdata Parents for Centralization**: On-premises Parent nodes provide centralized dashboards and longer retention without any data leaving the organization's network.
3. **Opt Out of Telemetry**: Create `/etc/netdata/.opt-out-from-anonymous-statistics` on all agent hosts.
4. **Review `REDISTRIBUTED.md`**: Conduct software composition analysis (SCA) against the redistributed dependency inventory before approving deployment.

### For Organizations Using Netdata Cloud

1. **Request DPA**: Obtain a Data Processing Agreement from Netdata before processing EU personal data through Cloud accounts.
2. **Request SOC 2 Report**: Ask Netdata's compliance team for their current SOC 2 Type II attestation report.
3. **Review Sub-Processors**: Request Netdata's sub-processor list to evaluate cloud infrastructure providers.
4. **RBAC Configuration**: Use Netdata Cloud's role-based access control to enforce least-privilege access to monitoring dashboards.

### For Software License Compliance

1. **No Distribution Obligation for Internal Use**: GPL-3.0 copyleft does not apply to internal deployments. No source code disclosure is required when running Netdata on your own infrastructure.
2. **Audit Before Redistribution**: If including Netdata Agent in a product you distribute, review GPL-3.0 obligations and the `REDISTRIBUTED.md` dependency inventory.
3. **UI License Check**: Verify that use of the Netdata UI complies with the [NCUL1 license](https://app.netdata.cloud/LICENSE.txt) for your specific use case.

### CII Best Practices as Procurement Evidence

The CII Best Practices badge (Project #2231) and Coverity Scan badge provide verifiable evidence of open-source security maturity. These can be cited in:
- Vendor risk assessments for Netdata as a tool
- Security architecture review board submissions
- Procurement justifications requiring evidence of secure SDLC practices

---

**Document Sources:**
- `README.md` — License declarations, architecture descriptions, telemetry opt-out, CII/Coverity badges
- `docs/` directory listing — Confirms `docs/security-and-privacy-design/` exists as a dedicated security documentation section
- `.github/dependabot.yml` — Dependency scanning configuration
- `.github/codeql/` — CodeQL SAST configuration
- External: https://bestpractices.coreinfrastructure.org/projects/2231
- External: https://scan.coverity.com/projects/netdata-netdata
- External: https://learn.netdata.cloud/docs/security-and-privacy-design