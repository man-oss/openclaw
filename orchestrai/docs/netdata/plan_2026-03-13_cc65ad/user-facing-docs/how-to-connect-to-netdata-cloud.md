---

## What You'll Accomplish

By the end of this guide, you will:

- Have a Netdata Cloud account and a personal Space set up
- Have at least one agent connected and visible in the Cloud
- Know how to organize your nodes into Rooms
- Understand how to invite teammates and manage access
- Know where to find alerts, dashboards, and other Cloud features

---

## Before You Begin

Make sure you have:

- A computer or server where you want to install monitoring (Linux, macOS, Windows, or a container environment)
- An internet connection (outbound only — no inbound ports need to be opened)
- A few minutes of time

---

## Step 1: Create Your Netdata Cloud Account and Space

1. Open your web browser and go to **[app.netdata.cloud](https://app.netdata.cloud/)**.
2. Sign up for a free account using your email address, Google account, or GitHub account.
3. Once you log in, Netdata Cloud automatically creates a personal **Space** for you. Think of a Space as your team's home base — a central workspace where all your monitored systems and teammates live.

> **Good to know:** Most teams only ever need a single Space. You can always create additional Spaces later if you need to completely separate environments (such as different customers or business units).

---

## Step 2: Connect Your First Agent

A Netdata agent is the lightweight monitoring program that runs on your servers or devices and collects performance data. Connecting an agent to Netdata Cloud is called **claiming** the node.

### The Easiest Way — One Command

After logging in, Netdata Cloud shows you a ready-to-run connection command. You can find it in any of these three places:

- **Space Settings:** Click the ⚙️ (cogwheel) icon in the bottom-left corner → select **Nodes** → click the **"+"** button.
- **Nodes Tab:** Open the Nodes tab inside any Room → click **Add nodes**.
- **Integrations Page:** Visit the Integrations page, choose your operating system or container environment, and copy the provided command.

The command looks like this:

```bash
bash <(curl -Ss https://get.netdata.cloud/kickstart.sh) --claim-token YOUR_TOKEN --claim-rooms YOUR_ROOMS --claim-url https://app.netdata.cloud
```

Copy the exact command shown in your Cloud interface (it will have your personal token already filled in) and run it in a terminal on the machine you want to monitor.

**What this command does automatically:**
- Detects your operating system
- Installs the latest Netdata agent
- Securely connects the agent to your Cloud Space using your unique claim token
- Starts collecting and streaming metrics immediately — no extra configuration needed

### If Netdata Is Already Installed

If you already have a Netdata agent running on a system, you can connect it to Cloud without reinstalling. Use the same command from your Cloud interface — it will handle the connection step without disrupting your existing installation.

---

## Step 3: Verify Your Agent Appears in Netdata Cloud

Within a few seconds of running the connection command:

- Your node appears live in your Space
- Real-time charts begin streaming data immediately
- The System Overview dashboard populates automatically with CPU, memory, disk, and network metrics
- All metrics update with 1-second granularity

To confirm everything is working:

1. Navigate to the **Nodes** tab in your Space.
2. Look for the name of your server in the list — it should show a green "Live" status.
3. Click on the node name to open its full dashboard and see live data flowing.

If the node does not appear after a minute or two, double-check that the command ran without errors and that the machine can reach the internet.

---

## Step 4: Organize Nodes into Rooms

Rooms let you group your nodes in whatever way makes sense for your team. All nodes automatically appear in the **"All Nodes"** Room, so you always have a complete view. Creating additional Rooms helps you focus on specific parts of your infrastructure.

### Create a New Room

1. In the left sidebar of your Space, find the **Rooms** section.
2. Click the green **"+"** icon next to "Rooms."
3. Give the Room a name (for example: "Production Web Servers," "Databases," or "Europe Region").
4. Add nodes to the Room by selecting them from your node list.

### Room Organization Ideas

| Strategy | Examples |
|---|---|
| **By service type** | Web servers, databases, application servers |
| **By environment** | Production, staging, development |
| **By location** | US data center, EU cloud, on-premises |
| **By team** | DevOps team, SRE team, development team |

> **Remember:** Each node belongs to one Space, but you can add it to as many Rooms within that Space as you like. A database server could appear in both a "Databases" Room and a "Production" Room at the same time.

---

## Step 5: Explore Netdata Cloud Features

Once your nodes are connected and organized, you have access to a range of powerful Cloud features.

### War Room Overview (All Nodes View)

The **All Nodes** Room gives you a bird's-eye view of your entire infrastructure at once. From here you can:

- See the health status of every connected node at a glance
- Spot anomalies and active alerts across all your systems simultaneously
- Use **Composite Charts** that intelligently combine data from multiple nodes into a single, unified chart

### Alert Notifications

Netdata Cloud acts as a central dispatch point for all your monitoring alerts, sending notifications from one place regardless of how many agents you have. Alerts can be sent to:

- **Email**
- **Slack**
- **PagerDuty**
- **Microsoft Teams**
- **Netdata Mobile App** (paid plans)
- **Webhooks and dozens of other integrations**

To set up notifications, navigate to **Space Settings** → **Alerts & Notifications** and follow the steps for your preferred notification channel.

### Custom Dashboards

Navigate to the **Dashboards** tab to create and save your own custom views. You can:

- Pin the charts that matter most to your team
- Combine metrics from multiple nodes on a single dashboard
- Share dashboards with teammates so everyone is looking at the same data

### Metric Correlations and Anomaly Detection

- Click the correlation button on any chart to instantly find related metrics — useful when investigating the root cause of a problem.
- Purple ribbons on charts indicate anomaly rates detected by Netdata's built-in machine learning, which runs locally on every agent and learns your system's normal patterns automatically.

---

## Step 6: Invite Your Team and Manage Access

Collaboration is built into Netdata Cloud. To bring in teammates:

1. Click **"Invite Users"** in the Space's sidebar.
2. Enter your teammates' email addresses.
3. Assign each person a role based on what they need to do:

| Role | What They Can Do |
|---|---|
| **Admin** | Full control — manage Spaces, Rooms, users, and billing |
| **Manager** | Manage Rooms and users, but not billing |
| **Troubleshooter** | Monitor, analyze, and investigate — no settings changes |
| **Observer** | View-only access to specific Rooms |

> **Tip:** Invite your SRE, DevOps, and ITOps team members early and set clear roles. This way, everyone on the team has the right level of access from the start.

---

## Connecting More Agents

To connect additional servers, simply repeat Step 2 on each machine. Every new node will appear in your Space automatically. There is no limit to how many agents you can connect.

For large fleets of servers, the same one-line command works consistently across different Linux distributions, cloud environments, and container setups.

---

## How the Connection Works (No Technical Expertise Required)

When your agent connects to Netdata Cloud:

- **Your metric data never leaves your servers.** It stays stored locally on each machine.
- **Only lightweight metadata** (node names, metric names, alert states) is synchronized with the Cloud.
- **When you view a dashboard**, data flows directly from your agents to your browser — Netdata Cloud coordinates the connection without storing your actual metrics.
- **No VPN or firewall changes are needed** — agents connect outbound to the Cloud, so there are no inbound ports to open.

---

## Quick Reference: What Each Part Does

| Term | What It Means |
|---|---|
| **Space** | Your team's main workspace in Netdata Cloud — everything lives here |
| **Room** | A flexible group of nodes within your Space for focused monitoring |
| **Node** | Any server, device, or container running the Netdata agent |
| **Claiming** | The process of connecting a Netdata agent to your Cloud Space |
| **Claim Token** | Your unique, personal key used to authorize the connection |
| **ACLK** | The secure, encrypted link that the agent uses to communicate with Cloud |

---

## Next Steps

- **Add more nodes** — Run the connection command on every server you want to monitor.
- **Set up alert notifications** — Configure Slack, email, or PagerDuty so your team is notified automatically.
- **Create custom dashboards** — Build focused views for your most important services.
- **Explore AI features** — Use the Anomaly Advisor and AI Chat to investigate issues faster.
- **Try a Business plan** — Unlock unlimited AI reports, advanced role-based access, and mobile push notifications at [netdata.cloud/pricing](https://netdata.cloud/pricing).