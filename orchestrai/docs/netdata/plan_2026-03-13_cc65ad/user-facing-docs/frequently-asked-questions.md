# Netdata — Frequently Asked Questions

Find quick answers to the most common questions about Netdata below.

---

## Is Netdata free?

**Yes — the core of Netdata is completely free and open source.**

Netdata is made up of three parts:

- **Netdata Agent** — The heart of Netdata. It collects metrics, stores them, detects anomalies, fires alerts, and displays dashboards. It is fully open source (licensed under GPLv3+) and always free to use.
- **Netdata UI** — The dashboard and visualization layer. It is free to use and is included with every standard Netdata installation.
- **Netdata Cloud** — An optional online service that adds extra features on top of the free Agent. It has a **free community tier** as well as paid plans.

**What does Netdata Cloud's paid plan add?**

The free tier of Netdata Cloud gives you remote access, multi-node views, and more. Paid plans build on top of that with features like advanced user management, role-based access control (RBAC), centralized alert management, and horizontal scaling across large, complex infrastructures.

You can run Netdata entirely without a Netdata Cloud account — everything you need to monitor a single server or a group of servers is available for free.

---

## Does Netdata store my data in the cloud?

**No. Your metrics never leave your own infrastructure.**

Netdata follows an "edge-based" design: all data is collected, stored, and processed directly on your own machines. Netdata Cloud acts as a **control plane** — it lets you see and interact with your data remotely — but it does **not** receive or store your raw metric data.

This means:
- Your monitoring data stays on your servers.
- There is no central cloud database holding your metrics.
- Even when you use Netdata Cloud, the data you see in the browser is streamed directly from your own Netdata Agents.

This approach is sometimes described as "distributing code instead of centralizing data."

---

## How long does Netdata keep my historical data?

**As long as your disk space allows.**

Netdata uses a smart, tiered storage system that automatically keeps data at different levels of detail:

| Tier | Detail Level |
|------|-------------|
| Tier 0 | Every single second (highest detail) |
| Tier 1 | Every minute |
| Tier 2 | Every hour (longest reach) |

When you zoom in on a chart, Netdata automatically shows you the finest-resolution data available. When you zoom out to view weeks or months, it seamlessly switches to the lower-resolution tiers.

Storage is highly efficient — Netdata uses approximately **0.5 bytes per data sample** — so you can typically keep a long history without needing a large disk. You can also set up a "Parent" node with more disk space to centralize and extend the retention for all your servers.

---

## Can Netdata replace Prometheus and Grafana?

**Yes, for most use cases — and it requires far less setup.**

Prometheus and Grafana are powerful tools, but they require you to manually configure scrapers, write queries, and build your own dashboards. Netdata gives you everything out of the box:

| What you need | With Prometheus + Grafana | With Netdata |
|---|---|---|
| Data collection | Configure scrapers manually | Automatic — detects everything |
| Dashboards | Build from scratch | Pre-built and auto-generated |
| Anomaly detection | Requires extra tooling | Built in, per metric |
| Alerts | Configure separately | Hundreds of pre-built alerts included |
| Query language | Must learn PromQL | Not required |

**Does Netdata work alongside Prometheus?**

Absolutely. If you are already using Prometheus and Grafana, Netdata can run alongside them and complement them with real-time, per-second visibility and built-in ML. Netdata can also **export** its metrics to Prometheus, InfluxDB, Graphite, OpenTSDB, and other systems, so it fits easily into existing setups.

For a detailed side-by-side comparison, see the [Netdata vs. Prometheus comparison](https://www.netdata.cloud/blog/netdata-vs-prometheus-2025/).

---

## How do I upgrade Netdata?

Netdata is designed to be easy to keep up to date. The recommended approach depends on how you installed it:

- **One-line installer (most common):** Re-run the same installation command you used originally. The installer detects your existing setup and upgrades it in place.
- **Package manager (apt, yum, etc.):** Use your system's standard update command (for example, `sudo apt upgrade netdata` on Debian/Ubuntu systems).
- **Docker:** Pull the latest image from Docker Hub (`docker pull netdata/netdata`) and restart your container.
- **Kubernetes:** Update the Helm chart or manifest to the latest version.

After upgrading, Netdata restarts automatically and continues monitoring without any reconfiguration needed. Your stored metrics history and custom settings are preserved.

You can always find the latest release version on the [Netdata GitHub releases page](https://github.com/netdata/netdata/releases/latest).

---

## How is Netdata different from other monitoring tools?

Netdata was built from the ground up to solve problems that other monitoring tools struggle with. Here is what makes it stand out:

### Everything works immediately — zero configuration
Netdata automatically discovers and starts monitoring your system, containers, applications, and services the moment it is installed. There is no need to write configuration files, define what to collect, or build dashboards.

### Per-second data — always
Most monitoring tools collect data every 15, 30, or 60 seconds. Netdata collects **every single second**. This means you can see exactly what happened during a 3-second spike that other tools would miss entirely.

### Machine learning built in — for free
Netdata trains its own AI models for every single metric on your system, right on your own hardware. It automatically flags unusual behavior without you having to set thresholds or rules. This is included in the free, open-source version.

### Efficient enough to run on any system
A 2023 study by the University of Amsterdam found Netdata to be the most energy-efficient monitoring tool for Docker-based systems. Even with per-second collection and ML running, it typically uses around 5% CPU and 150 MB of RAM — less than almost any comparable tool.

### Your data stays with you
Unlike commercial SaaS monitoring tools, Netdata stores all metrics on your own infrastructure. There is no sampling, no aggregation, and no data sent to a third-party cloud. You get full-resolution data indefinitely.

### Works with what you already have
Netdata supports over **800 integrations** — databases, web servers, containers, cloud platforms, hardware sensors, and more. It can run alongside tools like Nagios, Zabbix, Prometheus, and Grafana rather than replacing them.

### Used by the world's largest organizations
Companies including Amazon, Google, Facebook, Netflix, IBM, Intel, and Samsung, as well as universities and government organizations worldwide, rely on Netdata for infrastructure monitoring.

---

## More questions?

- 📖 **Full documentation:** [learn.netdata.cloud](https://learn.netdata.cloud)
- 💬 **Community forum:** [community.netdata.cloud](https://community.netdata.cloud)
- 🗨️ **Chat with the community:** [Discord](https://discord.com/invite/2mEmfW735j)
- 🔍 **Try a live demo:** [app.netdata.cloud](https://app.netdata.cloud/spaces/netdata-demo)