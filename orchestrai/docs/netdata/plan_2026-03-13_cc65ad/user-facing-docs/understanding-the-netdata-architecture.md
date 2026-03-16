# Understanding the Netdata Architecture

Netdata is built around a simple but powerful idea: **keep your data where it belongs — on your own infrastructure** — while still giving you the visibility, speed, and scale you need to monitor everything. This guide explains the key building blocks of Netdata and how they work together, so you can make informed decisions about how to deploy and use it.

---

## The Big Picture

Netdata has three main components that work together:

| Component | What It Does |
|---|---|
| **Netdata Agent** | Runs on every machine you want to monitor. Collects metrics, stores them locally, runs machine learning, fires alerts, and serves dashboards. |
| **Netdata Cloud** | An optional web service that connects your agents together for multi-server views, user management, and remote access — without ever storing your metrics. |
| **Netdata UI** | The visual dashboard layer, included with every agent and also accessible through Netdata Cloud. |

---

## Inside the Netdata Agent: How Data Flows

Every Netdata Agent processes your metrics through a pipeline of nine steps, all happening in real time:

```
Collect → Store → Learn → Detect → Check → Stream → Archive → Query → Score
```

Here is what each step means for you:

1. **Collect** — The agent gathers metrics every second from your operating system, applications, containers, logs, network interfaces, hardware sensors, and hundreds of other sources. This happens automatically — no configuration needed for most systems.

2. **Store** — Collected metrics are saved to a high-efficiency time-series database running directly on your machine. Storage uses approximately 0.5 bytes per data point, and Netdata automatically manages three tiers of retention:
   - Every second (highest detail, recent data)
   - Every minute (medium detail, medium-term history)
   - Every hour (summary view, long-term history)

3. **Learn** — For every metric being tracked, the agent trains its own machine learning model based on that metric's recent behavior. This training happens at the edge — on your machine — with no data sent anywhere.

4. **Detect** — Using those trained models, the agent continuously evaluates whether current metric values look unusual. Anomalies are flagged automatically without you needing to define thresholds.

5. **Check** — Alert rules are evaluated against current metric values. Netdata includes hundreds of pre-configured alerts for common problems. When a condition is met, notifications are sent to your chosen channels (email, Slack, PagerDuty, and many others).

6. **Stream** — Metrics can be forwarded in real time to a Netdata Parent node (see the next section). This enables centralized storage, longer retention, and unified dashboards across many machines.

7. **Archive** — Optionally, metrics can be exported to external systems such as Prometheus, InfluxDB, Graphite, or OpenTSDB for integration with other tools.

8. **Query** — The agent exposes a built-in API so its dashboards — and any third-party tool you connect — can retrieve metrics on demand.

9. **Score** — A scoring engine finds patterns and correlations across metrics, helping you trace the root cause of a problem without manually comparing charts.

---

## Parent–Child Streaming: Scaling to Many Machines

For environments with more than a handful of servers, Netdata uses a **Parent–Child** model to centralize visibility without centralizing data collection.

### How it works

- A **Child** agent runs on each machine you want to monitor. It collects metrics locally every second and streams them in real time to a Parent.
- A **Parent** agent runs on a dedicated, more powerful machine. It receives metrics from many Child agents, stores them, runs alerts, and serves a unified dashboard covering all connected nodes.
- Parents can themselves stream to other Parents, allowing you to build multi-level hierarchies that scale to any size.

### Why this design matters

- **Your data stays in your infrastructure.** Nothing leaves your network unless you explicitly configure exports.
- **Child agents have zero overhead for long-term storage.** If you want, a Child can run entirely in memory and rely on the Parent for persistence.
- **You get a single pane of glass.** One Parent dashboard shows all your connected machines together.
- **Horizontal scaling is built in.** Add more Parents to handle more nodes, or use Netdata Cloud to unify multiple independent infrastructures into one logical view (see below).

### Typical topologies

| Scenario | Recommended Setup |
|---|---|
| Single server | One agent, local dashboard |
| Small team (2–20 servers) | One Parent, rest as Children |
| Large organization (hundreds of servers) | Multiple Parents, each serving a group of Children |
| Multi-region / multi-cloud | Multiple Parent clusters connected via Netdata Cloud |

---

## Netdata Cloud: Your Control Plane (Not Your Data Plane)

Netdata Cloud is a web-based service available at [app.netdata.cloud](https://app.netdata.cloud). It is **completely optional**, but it adds powerful capabilities on top of your local agent deployment.

### What Netdata Cloud does

- Gives you a single sign-on portal to see all your nodes from anywhere, without opening firewall rules or VPN connections
- Provides multi-node dashboards that let you compare metrics across your entire fleet
- Manages user access with role-based permissions and team spaces
- Lets you configure alerts and data collection settings centrally, pushing changes out to agents
- Offers a free community tier for personal use

### What Netdata Cloud does NOT do

> **Your metric data never passes through Netdata Cloud.**

This is a fundamental design principle. When you view a chart in Netdata Cloud, the dashboard retrieves metric data directly from the agent running on your machine — Netdata Cloud only acts as a coordination layer. It handles authentication, routing your browser to the right agent, and managing your settings, but your actual monitoring data stays on your infrastructure at all times.

---

## ACLK: How Agents Securely Talk to Netdata Cloud

When you connect an agent to Netdata Cloud, it establishes a secure outbound connection called the **Agent–Cloud Link (ACLK)**.

Here is what you need to know about it:

- The agent initiates the connection outbound — you do not need to open any inbound ports or change your firewall rules.
- The connection is encrypted end-to-end.
- ACLK is used for control messages: authentication, routing, configuration changes, and alert notifications. It is not a data channel.
- When Netdata Cloud needs to display your metrics, it uses ACLK to instruct your browser to connect directly to your agent for the actual data.
- If the ACLK connection is interrupted, your agent continues to work normally — local monitoring, alerts, and dashboards are unaffected.

This design means Netdata Cloud acts as a secure switchboard, not a data warehouse.

---

## The Plugin System: Where Data Collection Happens

Netdata's breadth of monitoring coverage — over 800 integrations — comes from a flexible plugin system. Plugins are independent programs that collect metrics from specific sources and feed them into the agent.

### Types of plugins

| Plugin Type | What It Covers | Key Characteristics |
|---|---|---|
| **Go plugins** | The majority of modern integrations — databases, web servers, message queues, cloud services, and more | Fast, low-overhead, actively developed; includes auto-discovery to find services automatically |
| **Python plugins** | A large library of legacy and community integrations | Easy to customize and extend |
| **Bash plugins** | Simple shell-based collectors for quick custom checks | Minimal dependencies, easy to write |
| **External / native plugins** | Deep OS-level metrics — system resources, network connections, hardware sensors, eBPF tracing | Highest performance; some require elevated permissions for kernel-level access |

### Auto-discovery

The Go plugin layer includes a discovery engine that automatically scans your machine for running services. When it finds something it knows how to monitor (for example, a PostgreSQL database or an Nginx web server), it starts collecting metrics immediately — no manual configuration required. If a service disappears and reappears (common in containerized environments), the agent handles this gracefully.

### Custom integrations

If you need to monitor something Netdata does not cover out of the box, you can write your own plugin in any language. As long as it outputs metrics in the expected format, the agent will collect and display them alongside everything else. Netdata also supports the OpenMetrics format, meaning any Prometheus-compatible exporter can feed data directly into Netdata.

---

## Putting It All Together: Deployment Models

Here is how the architecture plays out in practice depending on your needs:

### Standalone (simplest)
One agent on one machine. Access the dashboard directly on that machine. No streaming, no cloud connection needed. Good for personal projects or evaluating Netdata.

### Self-hosted centralized
Multiple agents (Children) stream to one or more Parent agents you manage. All data stays in your data center or private network. Access dashboards through any Parent agent. Best for teams that want full control with no external dependencies.

### Cloud-connected distributed
Agents connect to Netdata Cloud via ACLK. Netdata Cloud provides the entry point and unified view; your machines serve their own data. Good for remote access and multi-team environments without routing all traffic through a central server.

### Hybrid
Large organizations often combine all three: Children stream to regional Parents for local performance, Parents are connected to Netdata Cloud for cross-region visibility and central user management.

---

## Key Takeaways

- **Every agent is self-sufficient.** It collects, stores, analyzes, and visualizes data entirely on its own.
- **Streaming is how you scale.** Parent–Child relationships let you centralize dashboards and storage without changing how collection works.
- **Netdata Cloud is a control plane, not a data store.** Your metrics never leave your infrastructure.
- **ACLK keeps cloud connectivity simple and secure.** One outbound connection, no inbound ports required.
- **Plugins are how Netdata knows about everything.** Go, Python, Bash, and native plugins cover over 800 services, and you can add your own.

For next steps, explore the [Netdata documentation at learn.netdata.cloud](https://learn.netdata.cloud) for detailed setup guides, streaming configuration, and integration-specific instructions.