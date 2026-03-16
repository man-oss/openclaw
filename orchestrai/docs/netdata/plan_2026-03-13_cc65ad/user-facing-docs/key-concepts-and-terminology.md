---

## The Netdata Ecosystem: Three Core Pieces

Before diving into individual terms, it helps to understand the three building blocks of Netdata:

| Piece | What It Is |
|---|---|
| **Netdata Agent** | Software you install on a server, computer, or device to collect and display monitoring data |
| **Netdata Cloud** | An optional web application that brings all your monitored systems into one central view |
| **Netdata UI** | The visual dashboards and charts — included with both the Agent and Cloud |

---

## 1. Agents, Parents, and Children — The Streaming Hierarchy

### Agent (Netdata Agent)
The **Agent** is the core monitoring software you install on any machine you want to monitor. Once running, it automatically starts collecting data from that system — no manual setup required. Each Agent has its own built-in dashboard that you can view directly from a web browser.

Agents run on physical servers, virtual machines, containers, cloud instances, and even small IoT devices.

### Parent
A **Parent** is a Netdata Agent that has been set up to *receive* monitoring data from other Agents. Instead of only watching its own machine, a Parent also accepts and stores data that other Agents send to it.

Parents are useful when you want:
- A single place to see data from many machines at once
- Longer data storage (the Parent can keep data that individual machines would have discarded)
- Centralized alert management across your infrastructure

### Child
A **Child** is a Netdata Agent that streams its data to a Parent in real time. The Child still collects data from its own machine, but it forwards that data to the Parent so it can be stored and viewed centrally.

### How They Fit Together

```
Child A  ──┐
Child B  ──┼──▶  Parent  ──▶  Netdata Cloud
Child C  ──┘
```

A Child can stream to a Parent, and that Parent can itself stream to another Parent — creating a chain. This lets you scale from a handful of machines up to thousands without any central bottleneck.

> **Good to know:** Using a Parent is optional. Every Agent works perfectly as a standalone monitor. You only need a Parent if you want centralized storage, dashboards, or longer data retention.

### Node
The word **node** is the general term for any machine being monitored by Netdata — whether it's acting as an Agent, a Parent, or a Child. When you see "node" in the interface or documentation, it means a monitored system.

#### Node States
In Netdata Cloud, every node has a visible status:

| State | Meaning |
|---|---|
| **Live** | The node is actively sending data right now |
| **Stale** | The node stopped streaming, but a Parent still has its historical data |
| **Offline** | The node is disconnected and no data is available |
| **Unseen** | The node was added to your account but has never connected |

---

## 2. Metrics, Dimensions, Charts, and Families

### Metric
A **metric** is a single, specific measurement that Netdata tracks over time — for example, the percentage of CPU being used, the number of bytes sent over a network interface, or the temperature of a disk. Netdata collects metrics every second by default.

### Dimension
A **dimension** is one line or value shown inside a chart. Many charts display multiple dimensions at once. For example, a network chart might show two dimensions: *received* traffic and *sent* traffic. Each dimension is a separate data series within the same chart.

### Chart
A **chart** is a visual graph that shows one or more dimensions over time. Netdata auto-generates charts for everything it monitors — you never have to build them manually. Each chart has a name, a unit of measurement, and a history of values you can scroll and zoom through.

### Context
A **context** is how Netdata groups and identifies charts of the same type. For example, all "CPU usage" charts across different machines share the same context. This makes it easy to compare the same kind of metric across many nodes.

### Family
A **family** is a way of grouping charts that belong to the same hardware or software instance. For example, if your server has four disks, each disk gets its own family (disk 1, disk 2, disk 3, disk 4). All charts related to "disk 1" share the same family, keeping them neatly organized in the dashboard.

### Tiers (Data Retention)
Netdata stores your data at different levels of detail depending on how old it is:

| Tier | Resolution |
|---|---|
| **Tier 0** | Every second (full detail, most recent data) |
| **Tier 1** | Every minute (medium detail) |
| **Tier 2** | Every hour (summary, long-term history) |

When you zoom out to view weeks or months of data, Netdata automatically uses the appropriate tier. You get the right level of detail without having to think about it.

---

## 3. Collectors, Plugins, and Modules

### Collector
A **collector** is the general term for anything in Netdata that gathers data from a source. If Netdata is measuring it, a collector is doing the work. Netdata ships with 800+ collectors covering operating systems, applications, databases, network devices, cloud services, and more. Most collectors start automatically when Netdata detects the relevant service on your machine.

### Plugin
A **plugin** is the program that runs collectors. Think of a plugin as the engine, and collectors as the individual workers inside that engine. Netdata has several types of plugins:

- **Internal plugins** — Built directly into the Netdata Agent. These handle core system metrics (like CPU, memory, and disk) and run as part of the main Netdata process.
- **External plugins** — Separate programs that run alongside the Agent and communicate with it. These handle metrics from external services like web servers, databases, and APIs.

### Module
A **module** is a specific, self-contained collector managed by a plugin. One plugin can contain many modules — for example, a single "Go plugin" manages modules for nginx, PostgreSQL, Redis, MongoDB, and hundreds more. Each module is responsible for one type of data source.

### Orchestrator
An **orchestrator** is a special type of external plugin that manages multiple modules at once. Instead of each module running as its own separate program, the orchestrator runs them all together efficiently.

### In Plain Terms
Think of it like a company:
- The **plugin** is a department
- **Modules** are the individual employees in that department
- Each employee (**module**) monitors one specific thing
- A **collector** is the general word for any of these workers

---

## 4. Spaces and Rooms — Organizing in Netdata Cloud

These two terms are specific to **Netdata Cloud**, the optional web application. You won't see them when using only the local Agent dashboard.

### Space
A **Space** is the top-level container in Netdata Cloud. It represents your entire organization or team. When you create a Netdata Cloud account, you get a Space. Everyone you invite and every node you connect belongs to your Space.

Think of a Space as your company's account — it holds everything and everyone together.

Key things you manage at the Space level:
- Team members and their access levels (who can see what)
- Billing and subscription plan
- All the nodes connected to your organization

### Room
A **Room** is a way to organize nodes within your Space into logical groups. You can create as many Rooms as you need, and a node can appear in multiple Rooms.

For example, you might create:
- A "Production Servers" Room
- A "Database Servers" Room
- A "Europe Region" Room

Each Room has its own dashboard showing only the nodes you've added to it, making it easy to focus on a specific part of your infrastructure without being distracted by everything else.

> **Quick comparison:** A Space is your whole organization. Rooms are teams or projects within that organization.

---

## 5. Health Monitoring: Alerts, Alarms, Transitions, and Silencing

### Alert (formerly Alarm)
An **alert** is a rule that watches a specific metric and triggers a notification when something looks wrong. For example: "notify me when CPU usage stays above 90% for more than 5 minutes."

Netdata comes with hundreds of pre-built alerts covering common problem scenarios. You can also create your own. You may see the older term **alarm** used in some places — it means the same thing as alert.

### Alert States
Every alert is always in one of these states:

| State | Meaning |
|---|---|
| **Clear** | Everything is normal; the metric is within acceptable range |
| **Warning** | Something unusual is happening; worth investigating |
| **Critical** | A serious problem has been detected; immediate attention recommended |

### Alert Transition
An **alert transition** is the moment an alert changes from one state to another — for example, moving from *Clear* to *Warning*, or from *Warning* to *Critical*. Each transition is recorded and can trigger a notification.

When you look at alert history, you're seeing a log of all transitions: when conditions changed and in which direction.

### Alert Notification
An **alert notification** is the message Netdata sends when an alert transitions to a new state. Netdata can send notifications through many channels, including email, Slack, Telegram, PagerDuty, Discord, Microsoft Teams, and more.

### Silencing (Alert Silencing)
**Silencing** lets you temporarily stop notifications for specific alerts or nodes without disabling the alert itself. The alert still monitors the metric and changes state — you just won't receive notifications about it during the silenced period.

This is useful for planned maintenance windows, when you know a server will be restarting or undergoing work and you don't want to receive a flood of false-alarm notifications.

### Flood Protection
**Flood protection** is an automatic safeguard in Netdata Cloud. If a node generates too many alert state changes in a short period (which can happen when a system is cycling between unstable states), Netdata Cloud temporarily pauses notifications for that node to prevent your team from being overwhelmed.

### Health Configuration
**Health configuration** refers to the alert rules themselves — the definitions of what to watch, what thresholds trigger a warning or critical state, and where to send notifications. These can be managed through the Netdata Cloud interface or directly on your Agent.

---

## Quick-Reference Glossary

| Term | Short Definition |
|---|---|
| **Agent** | Netdata software installed on a machine to collect metrics |
| **Alert / Alarm** | A rule that watches a metric and notifies you when it crosses a threshold |
| **Alert Transition** | A change in an alert's state (e.g., Clear → Warning) |
| **Child** | An Agent that streams its data to a Parent |
| **Chart** | A visual graph showing one or more metrics over time |
| **Collector** | Anything in Netdata that gathers data from a source |
| **Context** | A grouping identifier for the same type of chart across nodes |
| **Dimension** | A single data series shown within a chart |
| **Family** | A group of charts belonging to the same hardware/software instance |
| **Flood Protection** | Automatic pause of notifications when a node fires too many alerts rapidly |
| **Metric** | A single measurement tracked over time (e.g., CPU %, bytes sent) |
| **Module** | A specific collector managed by a plugin |
| **Node** | Any monitored machine in Netdata |
| **Orchestrator** | A plugin that manages multiple modules together |
| **Parent** | An Agent that receives and stores data streamed by Children |
| **Plugin** | The program that runs one or more collectors |
| **Room** | A group of nodes within a Netdata Cloud Space |
| **Silencing** | Temporarily pausing alert notifications without disabling the alert |
| **Space** | The top-level organizational container in Netdata Cloud |
| **Stale** | A node state where historical data exists but live streaming has stopped |
| **Tier** | A data retention layer with a specific time resolution |

---

## Where to Go Next

- **Explore your data:** Open the Netdata dashboard to see charts, dimensions, and families in action
- **Set up alerts:** Visit the Alerts section in Netdata Cloud to review and customize alert rules
- **Organize your infrastructure:** Use Spaces and Rooms in Netdata Cloud to group your nodes
- **Learn more:** Visit [Netdata Learn](https://learn.netdata.cloud) for full documentation and guides