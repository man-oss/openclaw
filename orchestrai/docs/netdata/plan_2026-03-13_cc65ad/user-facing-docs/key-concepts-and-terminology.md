---

## 1. Nodes: Agents, Parents, and Children

### What Is a Node?

A **node** is any computer, server, container, or device that has Netdata installed and running on it. Nodes are the fundamental units you monitor in Netdata.

### The Netdata Agent

The **Netdata Agent** (often just called the "Agent") is the core monitoring software you install on a node. It continuously collects thousands of metrics from the system it runs on — every second, automatically, with no manual setup. Every node in your infrastructure runs an Agent.

### Parents and Children

Netdata supports a streaming hierarchy where Agents can send their data to other Agents:

- A **Child** is a node that streams its metric data to another node in real time.
- A **Parent** is a node that receives metric data streamed from one or more Children.

A single node can be a Child to one Parent while simultaneously acting as a Parent to other Children — allowing you to build multi-level hierarchies that match your infrastructure's shape.

**Why does this matter?** Parents let you:
- View metrics from many machines in one central place
- Keep data for longer periods than a small edge device might allow
- Manage alerts from a single location
- Keep working even when a Child node goes temporarily offline (the Parent still holds historical data)

### Node States in Netdata Cloud

When you view your nodes in Netdata Cloud, each node shows a connection status:

| State | What It Means |
|-------|--------------|
| **Live** | The node is actively connected and streaming fresh metrics right now |
| **Stale** | The node stopped streaming to its Parent, but the Parent is still online and holds the node's historical data |
| **Offline** | The node is disconnected and no data is available |
| **Unseen** | The node was added to your account but has never connected |

---

## 2. Metrics, Dimensions, Charts, and Families

### Metrics

A **metric** is a single, measurable value about your system captured at a specific point in time — for example, CPU usage percentage, the number of bytes received on a network interface, or the amount of free memory. Netdata collects metrics every second.

Metrics are stored in a high-efficiency database with multiple **tiers** of resolution:
- **Tier 0** — per-second detail (most recent data)
- **Tier 1** — per-minute averages (older data)
- **Tier 2** — per-hour averages (archival data)

Netdata automatically selects the right tier depending on how far back in time you're looking, so you always see a smooth, appropriately detailed view.

### Dimensions

A **dimension** is one specific value shown on a chart. Charts often display several dimensions at once. For example, a CPU chart might show separate dimensions for `user`, `system`, `idle`, and `iowait` — all on the same graph, so you can see how they relate to each other.

### Charts

A **chart** is a visual representation of one or more dimensions over time. Netdata auto-generates charts for everything it monitors — you don't need to build them yourself. Charts are interactive: you can zoom, pan, highlight time ranges, and drill down into the data.

Each chart has a **context** — a machine-readable label that groups charts of the same type together. For example, all charts tracking disk I/O operations share the same context, regardless of which disk or which machine they come from. This makes it easy to compare similar resources across your infrastructure.

### Families

A **family** represents a single instance of a hardware or software resource that needs to be shown separately from similar instances. For example, if your server has three network interfaces (`eth0`, `eth1`, `eth2`), each interface is its own family. Families let you drill down to a specific disk, network interface, database instance, or container within a broader category.

---

## 3. Collectors, Plugins, and Modules

### Collectors

A **collector** is the general term for anything in Netdata that gathers metric data from a source. "Collector" is intentionally broad — it covers all the different ways Netdata fetches data, whether that source is the Linux kernel, a running application, a network device, a cloud API, or a log file.

Netdata ships with over 800 collectors, which auto-detect running services and start collecting without any configuration on your part.

### Plugins

**Plugins** are the programs that run alongside the main Netdata process and feed it data. There are two kinds:

- **Internal plugins** are built directly into the Netdata Agent. They read data from the operating system itself (such as `/proc` and `/sys` on Linux) and run as lightweight threads inside the Agent. These handle the most fundamental system metrics — CPU, memory, disk, network, and so on.

- **External plugins** run as separate, independent programs that communicate with the Agent. This design lets Netdata monitor a huge variety of applications (web servers, databases, message queues, etc.) without loading all that code into the core process.

### Modules and Orchestrators

Within external plugins, **modules** are the individual pieces of logic that know how to talk to a specific application or service — for example, one module handles nginx, another handles PostgreSQL, another handles Redis.

An **orchestrator** is a plugin that manages and runs multiple modules. Instead of launching a separate process for each application, an orchestrator bundles related modules together and runs them efficiently as a group. This keeps resource usage low even when you're monitoring dozens of different services.

**In plain terms:**
- A **plugin** is the runner.
- A **module** is the recipe for one specific data source.
- An **orchestrator** is a supervisor that manages multiple recipes at once.
- A **collector** is the umbrella word for all of the above.

---

## 4. Spaces and Rooms in Netdata Cloud

**Netdata Cloud** is the optional web platform that connects your nodes so you can monitor your entire infrastructure from one place, from anywhere. Your data never leaves your own machines — Netdata Cloud provides the interface and coordination layer, not a central data store.

### Spaces

A **Space** is the top-level container in Netdata Cloud. Think of it as your organization's account or workspace. A Space holds all of your team's nodes, members, and settings in one place.

- You can invite teammates and assign them different access levels (roles).
- Large organizations can use multiple Spaces to separate different teams or environments (for example, "Production" vs. "Development").
- Every Space has its own user management and billing tier.

### Rooms

A **Room** is a focused group of nodes within a Space, with its own shared dashboard. Rooms help you organize nodes logically — for example, by environment, by region, by team, or by application.

- When you connect a node to Netdata Cloud, it appears in your Space's **All Nodes** room by default.
- You can create custom Rooms and place nodes into them to get targeted dashboards and alerts for just that group.
- Rooms provide a unified, real-time overview of all the nodes they contain, showing charts and alerts across every node at once.

**Simple analogy:** A Space is your company's building; Rooms are the different offices or teams inside it.

---

## 5. Health Monitoring: Alerts, Alarms, Transitions, and Silencing

### Alerts (formerly Alarms)

An **alert** (previously called an "alarm") is a rule that watches a metric and notifies you when something looks wrong. For example, an alert might trigger when CPU usage stays above 90% for more than a minute, or when available disk space drops below 10%.

Netdata ships with hundreds of pre-configured alerts covering the most common failure scenarios. You can also create your own alerts or adjust the built-in ones to match your specific needs.

Alerts have three severity levels:
- **Clear** — everything is normal
- **Warning** — something worth paying attention to
- **Critical** — something that likely needs immediate action

### Alert Entity Types

When looking at alert configurations, you'll see two types:

- An **alarm** entity is attached to a specific, individual chart. It watches one exact thing (for example, the CPU on a particular server).
- A **template** entity applies the same rule to every chart that shares a given context. For example, one template can automatically create a disk-space alert for every disk on every server, without you having to write separate rules for each one.

### Alert Transitions

An **alert transition** is a recorded change in an alert's state — for example, moving from *Clear* to *Warning*, or from *Warning* to *Critical*, or back to *Clear*. Each transition is logged with a timestamp, allowing you to trace exactly when a problem started, how it evolved, and when it was resolved.

In Netdata Cloud, alert transitions feed the notification system, so the right people are informed at the right time.

### Silencing Alerts

**Silencing** lets you temporarily mute alerts so that notifications are not sent — useful during planned maintenance, deployments, or known incidents when you don't want to be flooded with expected warnings.

When an alert is silenced, it still continues to evaluate the metric and records state changes — it simply doesn't send notifications while the silence is active.

**Flood Protection** is a related automatic safety mechanism: if a node fires an unusually high number of alerts in a short period (for example, rapidly flipping between states), Netdata Cloud automatically suppresses notifications for that node temporarily. This prevents alert storms from overwhelming your team's communication channels.

---

## Quick-Reference Glossary

| Term | Short Definition |
|------|-----------------|
| **Agent** | The Netdata monitoring software installed on a node |
| **Alert / Alarm** | A rule that watches a metric and notifies you when a threshold is crossed |
| **Alert Transition** | A recorded change in an alert's state (e.g., Clear → Warning) |
| **Child** | A node that streams its metrics to a Parent |
| **Chart** | An interactive graph showing one or more dimensions over time |
| **Collector** | Any Netdata mechanism that gathers metric data from a source |
| **Context** | A label that groups charts of the same type across different nodes |
| **Dimension** | A single data series shown on a chart |
| **External Plugin** | A plugin that runs as a separate process and talks to the Agent |
| **Family** | A specific instance of a resource (e.g., one network interface or one disk) |
| **Flood Protection** | Automatic suppression of notifications when a node fires too many alerts |
| **Internal Plugin** | A plugin built into the Agent that reads OS-level data |
| **Metric** | A single measurable value captured over time |
| **Module** | The logic inside an orchestrator that handles one specific data source |
| **Node** | Any device running the Netdata Agent |
| **Orchestrator** | A plugin that manages and runs multiple modules together |
| **Parent** | A node that receives streamed metrics from Children |
| **Plugin** | A program (internal or external) that feeds metric data into the Agent |
| **Room** | A group of nodes in Netdata Cloud sharing a common dashboard |
| **Silencing** | Temporarily muting alert notifications without disabling the alert rule |
| **Space** | The top-level organizational container in Netdata Cloud |
| **Stale (node)** | A node that stopped streaming, but whose data is available via a Parent |
| **Template** | An alert rule that applies automatically to all charts of a given context |
| **Tier** | A database storage layer with a specific time resolution (per-second, per-minute, per-hour) |