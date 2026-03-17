# Understanding the Netdata Architecture

Netdata is built around a simple idea: monitoring data should stay close to where it's generated, not be shipped to a central location. This guide explains how all the pieces fit together so you can confidently choose the right setup for your environment.

---

## The Big Picture

Netdata is made up of three main building blocks that work together:

| Building Block | What It Does |
|---|---|
| **Netdata Agent** | Runs on each of your servers or devices, collects metrics, stores them locally, and makes them available |
| **Netdata Cloud** | An optional online service that connects your agents, adds team management features, and provides a unified view — without ever storing your raw metrics |
| **Netdata UI** | The visual dashboard you use to explore charts, alerts, and data — delivered free and accessible from your browser |

You can use the Agent completely on its own, add Parent nodes for central collection, and optionally connect to Netdata Cloud for remote access and team features. Each layer adds capability without removing your control over your data.

---

## How the Netdata Agent Works: The Data Pipeline

Every Netdata Agent runs a continuous, nine-step pipeline on your machine:

```
Collect → Store → Learn → Detect → Check → Stream → Archive → Query → Score
```

Here is what happens at each step:

1. **Collect** — Plugins and integrations gather measurements from your operating system, hardware, containers, applications, and services every second.

2. **Store** — Those measurements are saved to a high-efficiency, tiered time-series database directly on your machine. Nothing leaves your server at this stage.

3. **Learn** — The Agent quietly trains machine learning models for each individual metric, based on how that metric normally behaves over time.

4. **Detect** — The trained models are used to flag unusual patterns automatically — no manual threshold-setting required.

5. **Check** — Every metric is evaluated against pre-built or custom alert rules. When a threshold is crossed, an alert fires.

6. **Stream** — Metrics can be forwarded in real time to a designated Parent node (see [Parent-Child topology](#the-parent-child-topology-scaling-across-many-servers) below).

7. **Archive** — Optionally, metrics can be sent to external systems like Prometheus, InfluxDB, Graphite, or others you already use.

8. **Query** — A built-in API makes all collected data available to the dashboard and any tools you connect.

9. **Score** — A scoring engine finds patterns and correlations across metrics, powering features like anomaly detection and root cause analysis.

All nine steps happen on your own infrastructure. Your raw metric data never leaves your servers unless you explicitly configure it to do so.

---

## Data Retention: Three Tiers, One Seamless View

The Agent stores your metrics at three levels of detail, automatically:

| Tier | Resolution | Ideal For |
|---|---|---|
| **Tier 0** | Every second | Investigating problems happening right now |
| **Tier 1** | Every minute | Trends over hours and days |
| **Tier 2** | Every hour | Long-term patterns over weeks and months |

When you zoom in on a chart, the dashboard automatically uses the most detailed tier available. Zoom out, and it switches to lower-resolution data — all seamlessly, with no action needed from you. The only limit to how long you can keep data is the storage space on your machine.

---

## The Parent-Child Topology: Scaling Across Many Servers

When you monitor more than a handful of machines, you can organize your Agents into a **Parent-Child** hierarchy. This is how Netdata scales from a few servers to many thousands.

### How It Works

```
Child Agent (Server A)  ──┐
Child Agent (Server B)  ──┤──► Parent Node ──► (Optional) Netdata Cloud
Child Agent (Server C)  ──┘
```

- **Child Agents** run on every server you want to monitor. They collect, store, and process metrics locally, then stream a copy to the Parent in real time.
- **Parent Nodes** are simply Netdata Agents that have been designated to receive streams from other agents. They aggregate metrics from all their children, give you one central dashboard to view everything, and can hold longer-term data retention than individual children.
- **Multiple levels** are possible — a Parent can itself stream to another Parent, letting you build hierarchies that match your organization's network topology.

### What This Gives You

- **One dashboard** to see all your servers, without logging into each machine individually.
- **Longer retention** — the Parent holds historical data, while Agents can run lean with shorter local retention or even no local storage.
- **Resilience** — Child Agents continue monitoring and storing data locally even if the connection to the Parent is temporarily lost, and they catch up automatically when reconnected.
- **Alert centralization** — configure alerts in one place on the Parent rather than on every individual server.

This entire streaming happens directly between your own machines, over your own network, with no third-party involvement.

---

## Netdata Cloud: Your Control Plane, Not Your Data Plane

Netdata Cloud is an optional online service at [app.netdata.cloud](https://app.netdata.cloud). It is important to understand what it does — and what it does *not* do.

### What Netdata Cloud Does

- Gives you access to your dashboards from any browser, anywhere, without opening firewall ports on each server.
- Provides a unified view across all your nodes and even multiple separate infrastructures.
- Manages team access through user accounts and role-based permissions.
- Lets you configure alerts and data collection settings centrally and push them to your Agents.
- Offers a free tier and paid plans for enterprise features.

### What Netdata Cloud Does NOT Do

> **Your raw metric data never passes through Netdata Cloud.**

When you view a chart in Netdata Cloud, your browser is actually receiving the data directly from your Agent, via a secure connection. Netdata Cloud coordinates that connection but does not store or process your metrics. This is a fundamental design principle — not just a policy.

This means:

- Your data stays on your infrastructure at all times.
- You retain full control and full resolution of every metric.
- There is no per-metric cost based on how much you collect.
- You can disconnect from Netdata Cloud at any time and your local monitoring continues unaffected.

---

## ACLK: How Agents Securely Connect to Netdata Cloud

When you choose to connect an Agent to Netdata Cloud, the connection is made through the **Agent-Cloud Link (ACLK)** — a secure, outbound-only connection from your Agent to Netdata Cloud.

### Key Properties of ACLK

- **Outbound only**: Your Agent initiates the connection to Netdata Cloud. No inbound ports need to be opened on your firewall or network.
- **Encrypted**: All communication over ACLK is encrypted in transit.
- **Control messages only**: The ACLK carries commands, configuration, and connection-brokering information — not your actual metrics data.
- **Optional**: If you do not connect to Netdata Cloud, ACLK is simply not used. Your Agent operates entirely on its local network.

Think of ACLK as a secure telephone line between your Agent and Netdata Cloud — it lets the two talk to each other and coordinate, while your actual metric data travels through a separate, direct connection between your browser and your server.

---

## The Plugin System: How Netdata Collects Everything

Netdata's ability to monitor hundreds of different technologies comes from its plugin architecture. Instead of one monolithic collector, Netdata uses a family of plugins — each specialized for different types of data sources.

### Plugin Families

| Plugin Type | What It Monitors | How It Works |
|---|---|---|
| **Go plugins** | Modern applications and services (databases, web servers, cloud services, and many more) | High-performance collectors built into the main Netdata package, auto-discovering services as they appear |
| **Python plugins** | A wide range of applications and custom integrations | Interpreted scripts that communicate with Netdata through a defined protocol |
| **Bash plugins (Shell scripts)** | Simple checks, custom scripts, and lightweight integrations | Shell-based collectors that are easy to write and customize |
| **External plugins** | Anything else — hardware, proprietary systems, custom applications | Any program in any language that follows Netdata's plugin communication protocol |

### Auto-Discovery

A key feature of the plugin system is that it is largely automatic. When Netdata starts (and continuously while it is running), it scans your system to find what services and applications are present. If it detects a running database, web server, container, or other supported technology, it automatically begins collecting metrics from it — no manual configuration needed in most cases.

This discovery continues while Netdata is running, so when you start a new container or install a new service, Netdata typically begins monitoring it within seconds.

### What Plugins Can Monitor

Through its plugin system, Netdata covers:

- **System resources**: CPU, memory, disk, network interfaces, and hardware sensors
- **Containers and orchestration**: Docker, containerd, Kubernetes, LXC/LXD
- **Databases**: PostgreSQL, MySQL, MongoDB, Redis, and many more
- **Web servers and proxies**: nginx, Apache, HAProxy, and others
- **Cloud provider infrastructure**: AWS, GCP, Azure services
- **Custom metrics**: Via OpenMetrics (Prometheus-compatible), StatsD, and custom integrations
- **Logs**: System journal and Windows Event Logs, processed and visualized directly
- **Synthetic checks**: HTTP endpoint testing, TCP port checks, SSL certificate expiry, and ping

---

## Deployment Models: Choosing What Works for You

Based on the architecture above, you can deploy Netdata in several ways depending on your needs:

### Single Node (Standalone)
Install one Agent on a server and access its dashboard directly. Everything runs locally. Ideal for getting started, monitoring a single machine, or air-gapped environments.

### Multi-Node with Parents
Install Agents on all your servers and designate one or more powerful machines as Parent nodes. Agents stream to the Parents, giving you a central dashboard and longer data retention — all within your own network.

### Connected to Netdata Cloud
Connect your Agents (or your Parents) to Netdata Cloud. You gain remote access from anywhere, team collaboration, role-based access control, and cross-infrastructure dashboards. Your data still lives on your machines.

### All Three Together
The most complete setup: Agents on every server, streaming to Parents for local centralization, with Netdata Cloud providing remote access and team management on top.

---

## Summary

| Concept | Key Takeaway |
|---|---|
| **Agent pipeline** | Collect → Store → Learn → Detect → Check → Stream → Archive → Query → Score — all on your machine |
| **Tiered storage** | Three resolution tiers, automatically used based on how far you zoom out |
| **Parent-Child topology** | Agents stream to Parent nodes for scalable, centralized monitoring within your network |
| **Netdata Cloud** | Controls and connects — never stores your metric data |
| **ACLK** | Secure, outbound-only link for Agent-to-Cloud communication; no inbound firewall changes needed |
| **Plugin system** | Go, Python, bash, and external plugins auto-discover and monitor hundreds of technologies |

For full documentation, guides, and configuration references, visit [Netdata Learn](https://learn.netdata.cloud).