## What Is the ACLK?

The **Agent-Cloud Link (ACLK)** is the secure connection that links each Netdata Agent running on your servers to Netdata Cloud. It is the backbone that makes centralized monitoring possible — allowing you to view all your nodes, receive alerts, and run queries from the Netdata Cloud dashboard, regardless of where your servers are located.

Think of the ACLK as a secure, private tunnel that your Netdata Agent opens outward toward Netdata Cloud. Because the connection is **outbound-only** (initiated from your server, not from the cloud), you do not need to open any inbound firewall ports or expose your servers to the internet.

The ACLK activates automatically the moment you connect a node to your Netdata Cloud Space. No manual configuration is required under normal circumstances.

---

## How the ACLK Works

### Outbound-Only, Encrypted Connection

Your Netdata Agent establishes the connection to Netdata Cloud — the cloud never "calls into" your servers. This design means:

- **No open inbound ports are required** on your servers or firewall.
- **All traffic is encrypted** using industry-standard TLS/SSL, the same technology used by secure websites (HTTPS).
- The connection uses standard **port 443** (the same port as HTTPS web traffic), which is almost universally allowed through firewalls.

### Secure WebSocket Protocol

The ACLK uses an **encrypted WebSocket connection over port 443**. On top of this, it runs the MQTT messaging protocol, which is a lightweight, reliable protocol designed for maintaining persistent connections — ensuring your monitoring data and alerts are always flowing in real time.

### How Data Flows

```
Your Server (Agent) → [ACLK secure tunnel] → Netdata Cloud
Your Server (Agent) → [streaming] → Parent Agent → [ACLK] → Netdata Cloud
```

If you have a Parent agent (a central collection point for multiple child agents), the child agents stream their data to the Parent, and the Parent then maintains the single ACLK connection to Netdata Cloud on their behalf.

---

## Network Requirements

For the ACLK to connect successfully, your Netdata Agent needs outbound access to the following Netdata Cloud domains over port 443:

| Domain | Purpose |
|--------|---------|
| `app.netdata.cloud` | Main Netdata Cloud application |
| `api.netdata.cloud` | API and agent coordination |
| `mqtt.netdata.cloud` | Real-time messaging connection |

> **Important:** Always allowlist by **domain name**, not by IP address. Netdata Cloud uses CDN edge servers whose IP addresses vary by geographic region and can change without notice.

---

## What Data Travels Through the ACLK

The ACLK is designed with privacy in mind. Here is a clear breakdown of what does and does not pass through it:

### ✅ What IS Transmitted

- **Metadata**: Node names, hostnames, labels, and configuration information needed to display your infrastructure in Netdata Cloud.
- **Alert status and notifications**: The state of your health alerts (firing, cleared, etc.) so you receive notifications and see alert history in the cloud.
- **Metric queries**: When you view a chart or dashboard in Netdata Cloud, the cloud sends a query request through the ACLK, and your Agent responds with the data in real time.
- **Node context information**: The list of metrics and their descriptions, so Netdata Cloud knows what each node monitors.

### ❌ What Is NOT Transmitted or Stored

- **Your raw metrics and monitoring data are never stored in Netdata Cloud.** All historical data remains on your own servers.
- **Log data** is never sent to the cloud.
- When you view a chart in Netdata Cloud, the data you see is fetched live from your Agent on demand — it is not pulled from a cloud database.

> Your monitoring data belongs to you and stays within your infrastructure. Netdata Cloud stores only the minimal metadata needed to coordinate access and display your infrastructure overview.

---

## Checking Your ACLK Connection Status

### From the Command Line

Run the following command on any server running a Netdata Agent:

```bash
sudo netdatacli aclk-state
```

You will see output similar to this:

```
ACLK Available: Yes
ACLK Implementation: Next Generation
New Cloud Protocol Support: Yes
Claimed: Yes
Claimed Id: 53aa76c2-8af5-448f-849a-b16872cc4ba1
Online: Yes
Used Cloud Protocol: New
```

**What to look for:**
- **ACLK Available: Yes** — The ACLK feature is built into this Agent.
- **Claimed: Yes** — This Agent has been successfully connected to a Netdata Cloud Space.
- **Online: Yes** — The Agent is currently connected to Netdata Cloud. If this shows `No`, the Agent is disconnected.

### From a Web Browser

Open your browser and go to `http://YOUR-SERVER-IP:19999/api/v3/info` (replace `YOUR-SERVER-IP` with your server's address). Find the `cloud` section in the result — it shows the current connection state and any error information.

---

## Understanding Node Connection States

Once connected, Netdata Cloud displays each node with one of these states:

| State | What It Means |
|-------|--------------|
| **Live** | The node is connected and sending real-time data |
| **Stale** | The node has disconnected, but a Parent agent still has its historical data queryable |
| **Offline** | The node is disconnected and no data is accessible |
| **Unseen** | The node was added to your Space but has never successfully connected |

**How quickly does a disconnection appear?**

- If a node shuts down gracefully: Netdata Cloud detects it **immediately**.
- If a node crashes or loses network: Detection takes approximately **60 seconds** (based on connection keep-alive checks).
- The Netdata Cloud dashboard typically reflects state changes within **1–2 minutes**.

---

## Setting Up a Proxy for Restricted Networks

If your servers cannot connect directly to the internet, you can route the ACLK connection through a proxy server. This is common in corporate environments or secured data centers.

### Supported Proxy Types

| Type | Format |
|------|--------|
| HTTP proxy | `http://host:port` or `http://username:password@host:port` |
| SOCKS5 proxy | `socks5://host:port` or `socks5://username:password@host:port` |
| SOCKS5H proxy (remote DNS) | `socks5h://host:port` |

> **SOCKS5 vs SOCKS5H:** Use `socks5://` if your Agent server can resolve DNS itself. Use `socks5h://` if you want the proxy to handle DNS resolution (useful when the Agent cannot reach external DNS).

### How to Configure a Proxy

**Option 1 – Configuration File (Recommended)**

Create or edit the file at `/etc/netdata/claim.conf` and add your proxy under the `[global]` section:

```ini
[global]
   url = https://app.netdata.cloud
   token = YOUR_SPACE_TOKEN
   proxy = http://username:password@myproxy.company.com:8080
```

After saving, either restart the Netdata Agent or run:
```bash
sudo netdatacli reload-claiming-state
```

**Option 2 – Environment Variables (Container/CI Deployments)**

Set the following environment variable before starting the Agent:

| Variable | Description |
|----------|-------------|
| `NETDATA_CLAIM_PROXY` | The full proxy URL (e.g., `http://proxy.company.com:3128`) |

**Option 3 – System Proxy Environment Variable**

By default, the Agent also respects the system-level `http_proxy` environment variable. To use it, make sure the `proxy` setting in `claim.conf` is set to `env` (which is the default).

### Security Note on Proxies

Even when using a proxy, your data remains end-to-end encrypted. Here is why:

1. The Agent connects to the proxy using a plain TCP connection.
2. The Agent then asks the proxy to open a secure tunnel to Netdata Cloud (using HTTP CONNECT or SOCKS5 tunneling).
3. Through that tunnel, the Agent establishes a full TLS/SSL encrypted session directly with Netdata Cloud.
4. The proxy only sees encrypted traffic — it cannot read your monitoring data.

---

## Troubleshooting ACLK Connection Problems

### Quick Diagnostic Checklist

If a node shows as **Offline** or **Unseen** in Netdata Cloud, work through these steps:

1. **Confirm the Agent is running**
   ```bash
   systemctl status netdata
   ```

2. **Check ACLK status**
   ```bash
   sudo netdatacli aclk-state
   ```
   Look at the **Online** and **Claimed** fields.

3. **Test outbound connectivity to Netdata Cloud**
   From the server, try:
   ```bash
   curl -v https://app.netdata.cloud
   ```
   If this fails, the issue is a network or firewall restriction.

4. **Check Agent logs for ACLK messages**
   ```bash
   journalctl -u netdata MESSAGE_ID=acb33cb9-5778-476b-aac7-02eb7e4e151d
   ```
   Or search broadly:
   ```bash
   journalctl -u netdata | grep -i aclk
   ```

5. **Check the browser API endpoint**
   Open `http://YOUR-SERVER:19999/api/v3/info` and inspect the `cloud` section for error details.

### Common Problems and Solutions

| Problem | Likely Cause | Solution |
|---------|-------------|----------|
| Node shows **Unseen** | Agent never reached Netdata Cloud | Verify outbound access to `app.netdata.cloud`, `api.netdata.cloud`, and `mqtt.netdata.cloud` on port 443 |
| Node shows **Offline** unexpectedly | Network interruption or Agent stopped | Restart the Agent; check network and firewall rules |
| Connection works, but keeps dropping | Proxy not configured; firewall blocking WebSocket | Configure proxy settings if behind a firewall; ensure port 443 WebSocket traffic is not blocked |
| Claiming failed (unsupported installation) | Agent installed via unsupported package manager | Reinstall Netdata using the official installation method |
| Cannot connect on older OS (Ubuntu 14.04, Debian 8, CentOS 6) | Outdated OpenSSL version | Reinstall Netdata using the static build package, which includes an up-to-date OpenSSL |

---

## Reconnecting or Resetting the ACLK Connection

### Reconnecting a Linux Agent

If you need to remove an Agent from your Space and reconnect it (for example, to move it to a different Space), delete its stored credentials and restart:

```bash
cd /var/lib/netdata
sudo rm -rf cloud.d/
sudo systemctl restart netdata
```

> If your Agent has a `claim.conf` file or environment variables configured, it will automatically reconnect using those settings when restarted.

### Regenerating Your Space's Claim Token

If your claim token may have been compromised, you can generate a new one. Only Space Administrators can do this.

1. In Netdata Cloud, navigate to the screen that shows the node connection command (Space Settings → Nodes, or the Nodes tab, or the Integrations page).
2. Click **"Regenerate token"**.
3. Your old token is immediately invalidated. Any new Agents must use the new token to connect.

---

## Summary

| Topic | Key Point |
|-------|-----------|
| **Connection direction** | Outbound only — your Agent connects to the cloud, not the other way around |
| **Port used** | 443 (standard HTTPS port) |
| **Protocol** | MQTT over encrypted WebSocket (WSS) |
| **Data stored in cloud** | Metadata and alert state only — no raw metrics |
| **Your data location** | Always on your own servers |
| **Proxy support** | HTTP, SOCKS5, and SOCKS5H proxies supported |
| **Encryption** | End-to-end TLS/SSL even through proxies |
| **Connection check** | Run `sudo netdatacli aclk-state` on the Agent server |