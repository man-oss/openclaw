---

## What Are Netdata Integrations?

Integrations are ready-made connections between Netdata and the tools, services, and systems you already run. Instead of building monitoring from scratch, you simply enable the integration for your technology and Netdata automatically starts collecting data, building dashboards, and running anomaly detection — no query language or manual dashboard setup required.

Netdata organizes integrations into four main types:

| Integration Type | What It Does |
|---|---|
| **Data Collectors** | Gather metrics from your systems, applications, and services |
| **Exporters** | Send Netdata metrics to external time-series databases (e.g., Prometheus, InfluxDB) |
| **Notification Agents** | Deliver alerts to your team via Slack, PagerDuty, email, and 20+ other platforms |
| **Authentication Providers** | Connect Netdata Cloud login to your organization's identity provider (e.g., Okta, OIDC) |

---

## Browsing Available Integrations

The complete, searchable catalog of all Netdata integrations is available at **[integrations.netdata.cloud](https://integrations.netdata.cloud)**. You can browse and filter by category without needing to install anything first.

### Integration Categories

Integrations are organized into logical groups to help you find what you need quickly:

**Data Collection**
- Databases
- Web Servers and Proxies
- Containers and VMs
- Operating Systems
- Networking
- Cloud and DevOps
- Hardware and Sensors
- Applications
- Storage and Filesystems
- Synthetic Testing (uptime and connectivity checks)

**Logs**
Monitoring and querying logs from your infrastructure.

**Exporters**
Sending your Netdata metrics to external tools like Prometheus, Graphite, InfluxDB, and OpenTSDB.

**Notifications**
Routing alerts to platforms such as Slack, PagerDuty, email, and webhooks.

**Authentication**
Connecting cloud login to your organization's identity provider.

---

## Understanding Integration Types

### Data Collectors
Collectors are the heart of Netdata's integrations library. Each collector monitors a specific application or system component — for example, there are dedicated collectors for MySQL, PostgreSQL, Redis, Nginx, Apache, Kubernetes, Docker, and hundreds more.

Key things to know about collectors:
- **Many collectors work automatically** — once Netdata detects a running service on your system, the relevant collector activates without any extra steps.
- **Some collectors need credentials** — for protected applications like databases, you provide connection details so Netdata can access performance data.
- **Each collector comes with pre-built dashboards and alerts** — as soon as it starts collecting, you get visualizations and hundreds of pre-configured alert rules right away.
- **Collectors run per-second** — data is refreshed every second, giving you real-time visibility into what's happening right now.

### Exporters
If you already use a time-series database like Prometheus, InfluxDB, Graphite, or OpenTSDB, exporters let you forward Netdata's collected metrics to those systems. This means Netdata enhances your existing observability stack rather than replacing it.

### Notification Agents
When Netdata detects a problem and fires an alert, notification integrations determine where that alert goes. Supported destinations include:
- **Messaging platforms**: Slack, Microsoft Teams, Discord, Telegram
- **Incident management**: PagerDuty, Opsgenie, VictorOps
- **Email**: Standard SMTP email delivery
- **Custom webhooks**: Send alerts to any endpoint you control

There are two notification paths:
- **Agent Dispatched Notifications** — alerts sent directly from the Netdata Agent running on your server
- **Centralized Cloud Notifications** — alerts routed through Netdata Cloud, giving your whole team a single unified alert stream

### Authentication Providers
For teams using Netdata Cloud, authentication integrations connect your organization's existing login system (such as Okta or any OIDC-compatible provider) so your colleagues can sign in with their existing company credentials.

---

## Finding the Right Integration for Your Stack

1. **Visit [integrations.netdata.cloud](https://integrations.netdata.cloud)** and use the search bar or browse by category.
2. **Click on any integration** to open its dedicated page, which includes:
   - A description of what the integration monitors or does
   - Prerequisites (e.g., minimum software versions)
   - Step-by-step setup instructions
   - A list of every metric collected and every alert included
3. **Check the "Deploy" section** of the catalog if you're looking for guidance on installing Netdata itself on a specific operating system, container environment, or provisioning system (such as Ansible or Chef).

---

## Enabling a Data Collector

Most collectors are bundled with Netdata and activate automatically. Here is the general process:

### Step 1 — Install Netdata on Your System
Netdata must be running on the same machine (or network-accessible location) as the service you want to monitor. Follow the installation guide at **[netdata.cloud](https://www.netdata.cloud)** for your operating system.

### Step 2 — Let Auto-Discovery Run
After installation, Netdata scans for running services. If it finds a supported application — a web server, database, cache, and so on — it automatically activates the matching collector. Check your dashboard to see if metrics are already appearing.

### Step 3 — Configure Credentials (If Required)
For protected services such as databases, Netdata needs access credentials. Each integration's page on **integrations.netdata.cloud** provides exact instructions for your specific technology, including what permissions to grant and where to enter connection details.

### Step 4 — Verify Collection
Once configured, navigate to your Netdata dashboard. You should see a new section populated with charts for the service you just connected. If data isn't appearing, the integration page includes a troubleshooting section to help diagnose common issues.

---

## Setting Up Notification Integrations

To receive alerts when something goes wrong:

1. Go to your **Netdata Cloud** account and open **Alert Notifications** settings (accessible from your Space settings).
2. Select the notification channel you want to add (Slack, PagerDuty, email, webhook, etc.).
3. Follow the on-screen steps to connect your account — this typically involves generating an API key or webhook URL in the destination service and pasting it into Netdata.
4. Choose which alert severity levels trigger notifications and which Spaces or nodes they apply to.

For agent-level notifications (sent directly from a server without going through Netdata Cloud), each integration page provides the configuration details for your chosen platform.

---

## Setting Up Exporter Integrations

To forward metrics to an external database:

1. Find your target system (Prometheus, InfluxDB, Graphite, etc.) in the **Exporters** section of **integrations.netdata.cloud**.
2. Follow the setup instructions on that integration's page to configure the connection on your Netdata Agent.
3. Netdata will begin streaming metrics to your external system alongside its normal local storage — your existing dashboards and tooling continue working without interruption.

---

## Requesting or Contributing a New Integration

If Netdata doesn't yet support a technology you use, there are two paths:

### Request an Integration
Open a feature request on the **[Netdata GitHub repository](https://github.com/netdata/netdata/issues)**. Describe the technology you want monitored and how it exposes performance data. The Netdata team and community actively review these requests.

### Contribute an Integration
Netdata is open source and welcomes community contributions. If you want to build a new collector, notification channel, or exporter, the **Developer and Contributor Corner** section of the Netdata documentation walks you through the process. New integrations follow a standard format with defined schemas and templates that guide you from start to finish.

The community's contributions are how the library has grown to 800+ integrations, and every new addition benefits the entire Netdata user base.

---

## Tips for Getting the Most from Integrations

- **Start with auto-discovery**: Install Netdata and let it detect what's running first — you may find most of your stack is already covered without any manual configuration.
- **Check the alerts that come with each integration**: Every data collector ships with pre-configured alerts tuned to that specific technology. Review them so you know what conditions will trigger a notification.
- **Use Netdata Cloud for a unified view**: When you have integrations running on multiple servers, Netdata Cloud brings all of their data into a single dashboard so you can monitor your entire infrastructure in one place.
- **Combine with anomaly detection**: Because Netdata runs machine learning on every collected metric automatically, enabling a new integration immediately gives you anomaly detection for that technology — no additional setup required.

---

## Further Reading

- **[integrations.netdata.cloud](https://integrations.netdata.cloud)** — Full integration catalog
- **[netdata.cloud](https://www.netdata.cloud)** — Installation guides and product documentation
- **[GitHub repository](https://github.com/netdata/netdata)** — Source code, issue tracker, and contribution guides