---

## What Are Netdata Integrations?

An integration is a ready-made connection between Netdata and a specific technology or service. Instead of building monitoring from scratch, you simply enable the relevant integration and Netdata starts collecting, displaying, and alerting on data right away.

Netdata organizes integrations into four main types:

| Type | What It Does |
|------|-------------|
| **Collectors** | Gather metrics from your systems, applications, and services |
| **Exporters** | Send your collected metrics to external storage or analytics tools |
| **Notification Agents** | Deliver alerts to messaging and incident management platforms |
| **Authentication** | Connect Netdata Cloud sign-in to your identity provider |

---

## Browsing Available Integrations

### The Integrations Catalog

The easiest way to explore all available integrations is to visit **[integrations.netdata.cloud](https://integrations.netdata.cloud)**. This searchable catalog lists every integration Netdata supports, organized by category.

You can also browse integrations directly from the **Integrations** section inside the Netdata Cloud dashboard.

### Integration Categories

Integrations are organized into the following main categories, making it easy to find what you need:

**Data Collection (Collectors)**
- **Databases** — MySQL, PostgreSQL, MongoDB, Redis, and many more
- **Web Servers and Proxies** — Nginx, Apache, HAProxy, Traefik, and others
- **Containers and VMs** — Docker, Kubernetes, LXC, and similar platforms
- **Operating Systems** — Linux, Windows, macOS system metrics
- **Networking** — Network interfaces, firewall stats, DNS, and more
- **Cloud and DevOps** — AWS, GCP, Azure, CI/CD tools, and cloud services
- **Hardware and Sensors** — CPU, memory, disk, temperature, and power sensors
- **Applications** — Business and productivity applications
- **Storage and Filesystems** — Disk usage, RAID, NFS, and storage systems
- **Synthetic Testing** — HTTP checks, port probes, and uptime monitors
- **Logs** — Log monitoring across your infrastructure

**Exporters**
Send your metrics data to external systems such as Prometheus, Graphite, InfluxDB, or other time-series databases for long-term storage or integration with other dashboards.

**Notifications**
- **Agent Dispatched Notifications** — Alerts sent directly from your Netdata agent (e.g., email, PagerDuty, Slack, Teams, Opsgenie, Telegram, and many more)
- **Centralized Cloud Notifications** — Alerts managed and delivered through Netdata Cloud

**Deploy Integrations**
Step-by-step guidance for installing Netdata on various platforms, including operating systems, Docker and Kubernetes, and provisioning tools like Ansible.

---

## Understanding Integration Types in Detail

### Collectors
Collectors are the heart of Netdata's monitoring capabilities. They connect to a service or read system data and pull metrics at regular intervals — by default, every second. Most collectors work automatically: as soon as Netdata detects that a supported service is running (for example, Nginx or MySQL), it starts collecting data with zero manual configuration.

**Key things to know:**
- Many collectors are **auto-detected** — Netdata finds and monitors your services automatically upon startup
- Each collector page in the catalog describes exactly what metrics are collected and what pre-built alerts come with it
- Some collectors require minimal setup, such as providing a username and password for a database

### Exporters
Exporters let you send a copy of your metrics to another system. This is useful if your organization already uses a tool like Prometheus, Graphite, OpenTSDB, or InfluxDB and wants Netdata's high-resolution data there too. Enabling an exporter does not affect normal Netdata monitoring — it runs alongside it.

### Notification Agents
When Netdata detects a problem — such as high CPU usage or a service going down — it fires an alert. Notification integrations determine *where* that alert goes. Supported destinations include:

- **Slack** and **Microsoft Teams** for team chat
- **PagerDuty** and **Opsgenie** for on-call incident management
- **Email** for direct delivery
- **Telegram**, **Discord**, **Twilio (SMS)**, and many others

---

## Enabling an Integration for Your Technology Stack

### Step 1: Find the Right Integration

1. Go to **[integrations.netdata.cloud](https://integrations.netdata.cloud)** or open the **Integrations** page in Netdata Cloud.
2. Search by name (e.g., "PostgreSQL", "Nginx", "Slack") or browse by category.
3. Click on an integration to open its detail page.

### Step 2: Read the Integration Page

Each integration page tells you:
- **What it monitors** — a list of all metrics and charts you'll get
- **Prerequisites** — anything your service needs to have enabled (e.g., a stats endpoint, a read-only database user)
- **How to enable it** — step-by-step setup instructions
- **Built-in alerts** — which alert conditions come pre-configured

### Step 3: Enable Auto-Detection (Most Common Path)

For the majority of data collection integrations, **no action is needed**. When Netdata starts, it automatically scans your system for running services it recognizes. If it finds Nginx running, it monitors Nginx. If it finds Redis, it monitors Redis.

To confirm auto-detection worked:
1. Open your Netdata dashboard.
2. Navigate to the **Overview** or **Nodes** section.
3. Look for charts named after your service — if they appear, the integration is active.

### Step 4: Manual Setup (When Required)

Some integrations need a small amount of configuration — for example, telling Netdata the address of a remote database or providing credentials. The integration's detail page provides exact instructions. Generally, you will:

1. Open the relevant settings on your Netdata agent.
2. Add or edit the configuration for that specific integration.
3. Restart or reload Netdata to apply the changes.

The integration page always specifies the exact settings to change and what values to use.

---

## Integration-Specific Configuration Options

Each integration has its own set of options tailored to that technology. Common configuration options you'll encounter include:

| Option Type | Examples |
|-------------|---------|
| **Connection settings** | Host address, port number, socket path |
| **Authentication** | Username, password, API key, or token |
| **Collection interval** | How frequently metrics are gathered |
| **Filtering** | Which databases, instances, or endpoints to include or exclude |
| **TLS/SSL settings** | Certificate paths for secure connections |

Always refer to the specific integration's page on the catalog for its full list of options and default values. Each page explains what every option does in plain language.

---

## Notification Setup: Getting Alerts to the Right Place

To set up a notification integration:

1. Go to your **Netdata Cloud** account and navigate to **Alerts & Notifications** settings.
2. Select the notification service you want to use (e.g., Slack, PagerDuty, Email).
3. Follow the on-screen steps — you'll typically need to provide a webhook URL or API key from the target service.
4. Choose which alert severity levels trigger a notification (e.g., Critical only, or Warning and Critical).
5. Save your settings. Netdata will send a test notification so you can confirm it's working.

---

## Exporter Setup: Sending Metrics Elsewhere

To send your metrics to an external system:

1. Open the **Integrations** catalog and browse the **Exporters** section.
2. Select the exporter for your target system (e.g., Prometheus, Graphite, InfluxDB).
3. Follow the integration page's instructions to enable the exporter on your Netdata agent.
4. Provide the destination address and any authentication details required by the external system.
5. Verify the connection by checking that data appears in your external tool.

---

## Requesting or Contributing a New Integration

### Don't See What You Need?

If a technology you use isn't in the catalog yet, you have two options:

**Request an integration**
Open a feature request on the [Netdata GitHub repository](https://github.com/netdata/netdata/issues). Describe what you'd like monitored and why. The Netdata team reviews community requests regularly and prioritizes based on demand.

**Contribute an integration**
Netdata is open source and welcomes community contributions. The repository includes templates and schemas that define the standard format for integration metadata. If you're comfortable building a collector or integration, the [developer and contributor corner](https://github.com/netdata/netdata/tree/master/docs/developer-and-contributor-corner) in the documentation explains the process, and the `integrations/` directory in the repository contains all the tooling needed to build and validate a new integration.

---

## Tips for Getting the Most from Integrations

- **Start with auto-detection** — install Netdata and check what it discovered automatically before configuring anything manually.
- **Check the built-in alerts** — every integration comes with carefully tuned alert thresholds so you get meaningful warnings without noise.
- **Use the catalog search** — if you're looking for a specific tool, searching by name on the integrations catalog is the fastest way to find it.
- **Layer your integrations** — use collectors to gather data, notification agents to route alerts, and exporters if you need long-term metric storage outside Netdata.
- **Revisit after upgrades** — new integrations are added frequently. Check the catalog after updating Netdata to discover newly supported technologies.