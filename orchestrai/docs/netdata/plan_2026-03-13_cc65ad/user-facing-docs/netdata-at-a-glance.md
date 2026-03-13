# Netdata at a Glance

## What Is Netdata?

Netdata is a free, open-source monitoring platform that gives you instant, real-time visibility into everything happening across your infrastructure. Think of it as **X-ray vision for your servers, applications, and systems** — every metric, updated every single second, with no complex setup required.

Whether you're managing one server or thousands, Netdata shows you exactly what's happening right now, alerts you before problems escalate, and helps you find the root cause of issues fast.

---

## The Problem Netdata Solves

Traditional monitoring tools often suffer from the same painful limitations: they collect data too infrequently (every minute or longer), require complex manual configuration, charge you per metric or per host, and still leave you guessing when something goes wrong.

Netdata was built from the ground up to fix all of that. It captures data **every second**, automatically discovers everything running on your systems without you lifting a finger, and gives you rich, interactive dashboards the moment it starts — no query languages to learn, no dashboards to build from scratch.

---

## Who Is Netdata For?

Netdata is designed for anyone responsible for keeping systems healthy and performant:

- **System Administrators** who need to monitor servers, storage, and networking at a glance
- **DevOps Engineers** who want deep visibility into containers, Kubernetes clusters, and CI/CD pipelines
- **Site Reliability Engineers (SREs)** who need fast incident detection and root cause analysis
- **Developers** who want to monitor their applications and services in real time
- **Small teams and startups** who need enterprise-grade monitoring without enterprise-grade cost or complexity

Netdata is trusted by major organizations including Amazon, Google, IBM, Intel, Netflix, and Facebook, as well as universities, government agencies, and thousands of independent developers worldwide.

---

## What Makes Netdata Different

### ⚡ Per-Second Granularity — Every Metric, Every Second
Most monitoring tools sample data every 30 seconds or every minute. By the time a spike shows up, the moment has passed. Netdata collects and displays metrics **every single second**, so you see exactly what happened, when it happened — not a blurry average.

### 🔧 Zero Configuration — Works Right Out of the Box
Install Netdata and it automatically discovers and begins monitoring everything on your system: CPU, memory, disks, network interfaces, running services, containers, databases, web servers, and hundreds of popular applications. There's nothing to manually configure to get started.

### 🤖 ML-Powered Anomaly Detection — Built-In Intelligence
Netdata trains machine learning models for **every individual metric** directly on your own system. It learns what "normal" looks like for your specific environment and flags anomalies automatically — no manual threshold-setting required, and no shared or generic models. Your data never needs to leave your infrastructure for this to work.

### 💡 Instant, Interactive Dashboards — No Query Language Needed
Dashboards are generated automatically. You can slice, filter, zoom, and explore your data visually without ever writing a query. Everything is clickable and interactive from the moment Netdata starts.

### 🔒 Your Data Stays With You
Netdata processes everything at the edge — on your own systems. There is no central data collection, no metric sampling, and no aggregation that causes data loss. Your metrics are stored on your infrastructure, in full resolution.

### 🌱 Lightweight and Efficient
Even with per-second collection and machine learning running, Netdata uses approximately 5% CPU and 150 MB of RAM on typical production systems. It is independently recognized as the most energy-efficient monitoring tool for Docker-based systems (per a University of Amsterdam research study).

---

## What You Can Monitor

Netdata monitors a broad range of systems and technologies out of the box, across Linux, macOS, FreeBSD, and Windows:

| Category | Examples |
|---|---|
| **System Resources** | CPU, memory, shared system resources |
| **Storage** | Disks, mount points, filesystems, RAID arrays |
| **Networking** | Network interfaces, protocols, firewalls |
| **Hardware & Sensors** | Fans, temperatures, GPUs, power, voltage |
| **Processes** | Resource usage, performance, out-of-memory events |
| **Containers** | Docker, containerd, LXC/LXD, Kubernetes |
| **Virtual Machines** | KVM, QEMU, Proxmox, Hyper-V |
| **Logs** | System journals, Windows Event Log, ETW |
| **Applications** | nginx, Apache, PostgreSQL, Redis, MongoDB, and hundreds more |
| **Cloud Infrastructure** | AWS, GCP, Azure, and other cloud providers |
| **Synthetic Checks** | API availability, TCP ports, ping, SSL certificate expiry |
| **Custom Applications** | OpenMetrics, StatsD, and OpenTelemetry (coming soon) |

With over **800 integrations**, Netdata covers virtually every technology in a modern infrastructure stack.

---

## Core Feature Areas

### 📊 Metrics Collection
Netdata automatically discovers and collects metrics from your systems and applications the moment it starts. It handles everything from low-level hardware sensors to high-level application performance indicators, all at one-second resolution.

### 🔔 Alerting and Notifications
Netdata ships with hundreds of pre-configured alert rules covering common failure scenarios. When something goes wrong, it notifies you through your preferred channel — including email, Slack, Telegram, PagerDuty, Discord, Microsoft Teams, and more. Alerts can be evaluated locally on each system, with no cloud dependency required.

### 📈 Dashboards and Visualizations
Every monitored system gets a fully interactive dashboard automatically. You can explore trends, compare time ranges, zoom into specific events, and investigate anomalies — all without writing a single query. Custom dashboards can be created and saved in Netdata Cloud.

### 📋 Log Management
Netdata integrates directly with system log facilities (like the Linux systemd journal and Windows Event Log) and visualizes log data alongside your metrics, so you can correlate what you see in your charts with what was happening in your application logs at the same time.

### 🧠 Anomaly Detection and Scoring
Netdata's machine learning engine trains on each metric's historical behavior and automatically highlights unusual activity. An anomaly score is calculated continuously for every metric, and you can use the anomaly rate toggle in any dashboard to instantly spot which areas of your system are behaving unexpectedly.

---

## How Netdata Is Structured

Netdata has three main parts that work together:

### The Netdata Agent
This is the core of everything. You install one Agent on each system you want to monitor. The Agent handles all data collection, storage, machine learning, alerting, and visualization for that system. It runs efficiently in the background with minimal impact on your workload. The Agent is fully open-source and works completely standalone — no internet connection or cloud account required.

### Parent Nodes (Streaming)
Agents can stream their data to a designated **Parent** node in real time. This allows you to:
- Create a central view of multiple systems in one place
- Store data with longer retention than individual systems might allow
- Manage alerts centrally across your infrastructure
- Continue monitoring child nodes even if they go offline temporarily

This Parent-Child relationship scales naturally — a Parent can receive data from many child Agents, and Parents can themselves stream to other Parents.

### Netdata Cloud
Netdata Cloud is a free (with optional paid tiers) web service that connects your Agents together into a unified view you can access from anywhere. It adds:

- **Remote access** from any browser, with secure sign-in
- **Multi-node dashboards** showing your entire infrastructure side by side
- **Role-based access control** so teams can collaborate safely
- **Centralized alert management** across all your nodes
- **Scalability** to merge many independent environments into a single logical view

> **Important:** Netdata Cloud does **not** store your metrics. Your data stays on your own infrastructure at all times. The Cloud only facilitates access and coordination — it never receives a copy of your metric data.

---

## How It All Comes Together

Here's the simple mental model:

1. **Install the Agent** on any system you want to monitor — it immediately starts collecting data and showing you a live dashboard.
2. **Set up Parents** if you want centralized views, longer data retention, or unified alerting across multiple systems.
3. **Connect to Netdata Cloud** (optional) if you want remote access, team collaboration, or a single pane of glass across your entire infrastructure — without giving up data sovereignty.

You can start with just one Agent and scale up over time. Netdata is designed to grow with you — from a single Raspberry Pi to a global multi-cloud environment with millions of metrics per second.

---

## Try It Now

- 🌐 **Live Demo:** See real monitoring data at [frankfurt.netdata.rocks](https://frankfurt.netdata.rocks), [newyork.netdata.rocks](https://newyork.netdata.rocks), and other regional demo sites
- 📖 **Full Documentation:** [learn.netdata.cloud](https://learn.netdata.cloud)
- 💬 **Community:** [community.netdata.cloud](https://community.netdata.cloud) · [Discord](https://discord.com/invite/2mEmfW735j) · [GitHub Discussions](https://github.com/netdata/netdata/discussions)
- ☁️ **Netdata Cloud:** [app.netdata.cloud](https://app.netdata.cloud) — free tier available