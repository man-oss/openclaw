## What Is the ACLK?

The **Agent-Cloud Link (ACLK)** is the secure connection that bridges your Netdata Agent — running on your server, VM, or container — with Netdata Cloud. It is what allows you to view your infrastructure's data in the Netdata Cloud dashboard, receive alerts, and collaborate with your team, all from a single place.

Think of the ACLK as a private, encrypted tunnel that your agent opens outward toward the cloud. Your servers never need to be publicly exposed or accept incoming connections — the agent always initiates the connection, keeping your infrastructure safe.

Key characteristics of the ACLK:

- **Outbound-only**: Your agent reaches out to Netdata Cloud — Netdata Cloud never connects inward to your machines.
- **Always encrypted**: All communication is secured using TLS/SSL encryption from end to end.
- **Automatically activated**: The ACLK turns on automatically as soon as you connect a node to your Netdata Cloud Space — no manual setup required.
- **No open firewall ports needed**: Since the connection is outbound, you do not need to open any inbound ports on your firewall.

---

## Network Requirements

For the ACLK to work, each agent needs outbound internet access to Netdata Cloud. The connection uses standard **HTTPS/WebSocket (WSS) on port 443**, which is open on virtually all corporate and home networks.

### Domains Your Agents Must Be Able to Reach

Your network or firewall must allow outbound traffic to the following domains:

| Domain | Purpose |
|---|---|
| `app.netdata.cloud` | Netdata Cloud main application |
| `api.netdata.cloud` | API communication |
| `mqtt.netdata.cloud` | Real-time messaging over WebSocket |

> **Important:** Always allowlist by **domain name**, not by IP address. Netdata Cloud uses CDN edge servers, and IP addresses can change at any time and vary by geographic region.

---

## What Data Travels Through the ACLK?

The ACLK is designed with privacy at its core. Here is a clear breakdown of what is and is not transmitted:

### ✅ What IS Transmitted
- **Metadata** needed to identify and organize your nodes (node names, statuses, capabilities)
- **Alert and notification data** so Netdata Cloud can display and route your alerts
- **Query requests and responses** when you interact with charts and dashboards in Netdata Cloud (the data is fetched on-demand from your agent, not stored in the cloud)
- **Context information** about what metrics your agent is collecting

### ❌ What Is NOT Transmitted
- **Raw metric values or time-series data** — your metrics are never stored in Netdata Cloud
- **Log files or application data**
- **Sensitive system information** beyond what is needed for display and coordination

> Your monitoring data stays within your own infrastructure. Netdata Cloud stores only the minimal metadata required for coordination and access control.

---

## Checking the ACLK Connection Status

If you want to confirm that your agent is successfully connected to Netdata Cloud, you have two options.

### Option 1: Using the Web Interface

Open a browser and go to:

```
http://YOUR-NODE-IP:19999/api/v3/info
```

Replace `YOUR-NODE-IP` with the IP address or hostname of your agent. Look for the `cloud` section in the response — it shows the current connection status and any issues.

### Option 2: Using the Command Line

Run the following command on the machine where your agent is installed:

```bash
sudo netdatacli aclk-state
```

A successful, healthy connection looks like this:

```
ACLK Available: Yes
ACLK Implementation: Next Generation
New Cloud Protocol Support: Yes
Claimed: Yes
Claimed Id: 53aa76c2-8af5-448f-849a-b16872cc4ba1
Online: Yes
Used Cloud Protocol: New
```

If `Online` shows `No`, your agent is not connected. Use the troubleshooting steps below to resolve the issue.

---

## Troubleshooting Connection Problems

### Check the Agent Logs

If your node is not connecting, check the agent's log file and search for entries containing `CLAIM`. These entries describe what happened during the connection attempt and why it may have failed.

### Common Issues and Solutions

| Problem | What to Do |
|---|---|
| Agent installed via an unsupported package manager | Reinstall Netdata using the official installation method from the Netdata documentation |
| Insufficient permissions when running the setup script | Re-run the setup with root privileges, or as the same user that runs the Netdata Agent |
| Old Linux distribution (Ubuntu 14.04, Debian 8, CentOS 6) with outdated security libraries | Reinstall using a Netdata static build, which includes an up-to-date security library |
| Firewall blocking outbound traffic | Ensure port 443 is open and the three Netdata Cloud domains are allowlisted |

---

## Connecting Through a Proxy

If your environment restricts direct outbound internet access, you can route the ACLK connection through a proxy server. Netdata supports **HTTP proxies**, **SOCKS5 proxies**, and **SOCKS5H proxies**.

### How to Configure a Proxy

You can set a proxy when connecting your agent to Netdata Cloud. This is done through your agent's claim configuration file or via environment variables.

**Using the configuration file** (located at `/etc/netdata/claim.conf`):

```
[global]
   proxy = http://username:password@myproxy:8080
```

**Supported proxy formats:**

| Format | Description |
|---|---|
| *(empty or `none`)* | No proxy — connect directly to the internet |
| `env` | Use the `http_proxy` environment variable (this is the default behavior) |
| `http://[user:pass@]host:port` | Connect through an HTTP proxy |
| `socks5://[user:pass@]host:port` | Connect through a SOCKS5 proxy (DNS resolved on your agent) |
| `socks5h://[user:pass@]host:port` | Connect through a SOCKS5 proxy (DNS resolved on the proxy server) |

### Proxy Security

Even when routing through a proxy, **your data remains end-to-end encrypted**. Here is how:

1. Your agent connects to the proxy server.
2. The agent asks the proxy to create a direct TCP tunnel to Netdata Cloud.
3. The proxy passes raw traffic without reading it.
4. Your agent then establishes a full TLS/SSL encrypted connection directly with Netdata Cloud through that tunnel.

The proxy only ever sees encrypted data — it cannot read your monitoring information.

---

## Managing Your Cloud Connection

### Reconnecting an Agent

If you need to disconnect and reconnect an agent (for example, to move it to a different Space), you can remove the connection credentials by deleting the agent's cloud configuration directory, then restarting the agent.

**On Linux:**
```bash
cd /var/lib/netdata
sudo rm -rf cloud.d/
```

After restarting the agent, it will re-connect automatically if a valid `claim.conf` or claiming environment variables are present.

**On Docker:** Stop and remove the container, delete the `cloud.d/` directory and the agent's unique ID file from the data volume, then re-run the agent with the new connection token.

### Regenerating Your Connection Token

If your Space's connection (claiming) token is ever compromised, an Administrator of your Space can generate a new one from the Netdata Cloud dashboard. Once regenerated, the previous token is immediately invalidated.

**Steps:**
1. Go to any screen in Netdata Cloud that shows the node connection command (such as Space or Room settings → Nodes, or the Nodes tab → Add nodes).
2. Click **"Regenerate token"**.
3. Use the new token for any future agent connections.

> Only Space **Administrators** can regenerate the connection token.

---

## Summary

| Topic | Key Point |
|---|---|
| Connection direction | Outbound only — your agents initiate the connection |
| Port used | 443 (standard HTTPS/WebSocket) |
| Encryption | End-to-end TLS/SSL, including through proxies |
| Metric storage in cloud | None — all metric data stays on your infrastructure |
| Configuration required | None by default — ACLK activates automatically when you connect a node |
| Proxy support | HTTP, SOCKS5, and SOCKS5H proxies are all supported |