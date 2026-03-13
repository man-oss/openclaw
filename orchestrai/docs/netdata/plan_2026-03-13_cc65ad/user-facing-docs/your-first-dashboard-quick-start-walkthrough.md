# Your First Dashboard — Quick Start Walkthrough

Welcome to Netdata! This guide walks you through opening your dashboard for the first time, understanding what you see, and finding the data that matters most to you. By the end, you'll feel confident exploring your system's health in real time.

---

## Before You Begin

Make sure Netdata is installed on your system. If you haven't installed it yet, visit the [Netdata installation page](https://learn.netdata.cloud/docs/installing/one-line-installer-for-all-linux-systems) for step-by-step instructions for Linux, macOS, Windows, FreeBSD, and Docker.

---

## Step 1: Open the Dashboard

Once Netdata is installed and running, opening the dashboard is as simple as visiting a web address in your browser.

**On the same machine where Netdata is installed:**

Open any web browser and go to:
```
http://localhost:19999
```

**On a different machine on your network:**

Replace `localhost` with the hostname or IP address of the machine running Netdata:
```
http://YOUR-MACHINE-ADDRESS:19999
```

> **No login required.** The local dashboard is immediately accessible — no account or password needed to get started.

You should see a live, colorful dashboard that's already populating with data. Everything you see is updating every second automatically.

> 💡 **Want to explore before installing?** Visit one of the live demo sites to see a real Netdata dashboard in action: [Frankfurt](https://frankfurt.netdata.rocks) · [New York](https://newyork.netdata.rocks) · [Singapore](https://singapore.netdata.rocks)

---

## Step 2: Get Your Bearings — The Main Sections

The Netdata dashboard is organized into several main areas, accessible from the navigation menu. Here's what each one does:

### 🏠 Overview
This is your home base. The **Overview** page shows a high-level summary of your system's health at a glance — CPU usage, memory, disk activity, network traffic, and more. Everything here updates in real time, once per second.

This is a great starting point to quickly check whether anything looks unusual.

### 🖥️ Nodes
The **Nodes** section shows all the machines being monitored. If you're just starting out with a single machine, you'll see one entry here — your own system. As you add more machines, they all appear in this list, giving you a central place to jump between them.

### 🔔 Alerts
The **Alerts** section shows any warnings or critical issues Netdata has detected. Netdata comes with hundreds of pre-configured alert rules that automatically watch for common problems — high CPU load, low disk space, network errors, and more. When something needs your attention, it shows up here with a description of what's happening and how severe it is.

If everything is running smoothly, this section will be clear.

### 📊 Dashboards
The **Dashboards** section is where you can view and (with a Netdata Cloud account) create and save custom views. Pre-built dashboards group related metrics together, making it easy to focus on a specific area like system resources, containers, or a particular application.

---

## Step 3: Understanding the Charts You See

When you first open the Overview page, you'll be greeted by dozens of live charts. Here's how to make sense of them:

### Everything Is Auto-Discovered
Netdata scans your system automatically the moment it starts. It detects your operating system, running services, hardware, containers, and applications — then immediately begins collecting data for all of them. **You don't have to configure anything** to start seeing metrics.

For example, if you're running nginx, PostgreSQL, Docker, or Redis, Netdata will find them and show dedicated charts for each one — with no setup required. Netdata supports over 800 integrations out of the box.

### What a Chart Shows You
Each chart on the dashboard represents one area of your system. Here's what you'll notice:

- **The chart title** tells you what is being measured (e.g., "CPU Usage," "Disk Read/Write," "Network Traffic").
- **The colored lines or areas** are individual measurements within that category (called *dimensions*). For example, a CPU chart might show user processes, system processes, and idle time as separate colored layers.
- **The time axis** runs left to right, with the most recent data on the right. By default, you're looking at the last few minutes, but you can scroll back in time.
- **The values shown** update automatically — what you see is what's happening right now, with a one-second refresh rate.

### Moving Through Time
- **Scroll your mouse wheel** over any chart to zoom in or out on the time window.
- **Click and drag** on a chart to select a specific time range and zoom into that period.
- All charts on the page are synchronized — when you zoom in on one, the rest follow automatically.

### The Anomaly Indicator (AR)
You may notice an **"AR"** toggle on charts. This stands for *Anomaly Rate*. When enabled, it overlays a shaded area showing when Netdata's built-in machine learning detected that a metric was behaving unusually compared to its normal pattern. You don't need to set this up — Netdata trains itself automatically.

---

## Step 4: Finding a Specific Metric or Service

With hundreds of charts available, here are the best ways to navigate to what you're looking for.

### Use the Left-Side Menu
The left-hand navigation panel organizes all metrics into categories such as:
- **System** — CPU, memory, load, processes
- **Disks** — read/write rates, utilization per disk
- **Network** — traffic per interface, errors, packets
- **Applications** — resource usage grouped by application
- **Services** — if you're running systemd, each service appears here
- **Containers** — Docker, LXC, and Kubernetes workloads

Click any category to jump straight to those charts.

### Use the Search Bar
At the top of the dashboard, type the name of what you're looking for — for example, `nginx`, `disk`, `memory`, or `postgres`. The dashboard will filter and highlight the relevant charts instantly.

### Example: Finding CPU Usage
1. Look in the left menu under **System**.
2. Click on **CPU** to jump to the CPU section.
3. You'll see charts for total CPU usage, per-core usage, and CPU time spent on different types of tasks.

### Example: Finding a Running Service or Application
1. Look in the left menu under **Applications** or **Services**.
2. Find the name of your application (e.g., `nginx`, `mysql`, `redis`).
3. Click it to see memory, CPU, disk, and network usage specific to that service.

---

## Step 5: Connect to Netdata Cloud (Optional but Recommended)

The local dashboard at `http://localhost:19999` is fully functional on its own. However, connecting your agent to **Netdata Cloud** unlocks several powerful features — and the free tier is available to everyone.

### Why Connect to Netdata Cloud?

| Feature | Local Dashboard | With Netdata Cloud |
|---|---|---|
| Real-time charts | ✅ | ✅ |
| Access from anywhere | ❌ | ✅ |
| Monitor multiple machines in one view | ❌ | ✅ |
| Save custom dashboards | ❌ | ✅ |
| Centralized alerts across all nodes | ❌ | ✅ |
| Role-based access for teams | ❌ | ✅ |

> **Your data stays on your machine.** Netdata Cloud provides the interface and management layer, but your metrics are never sent to or stored in the cloud.

### How to Connect

1. **Create a free account** at [app.netdata.cloud](https://app.netdata.cloud/sign-in).
2. Once logged in, click **"Connect Nodes"** or look for the option to add a new node.
3. Netdata Cloud will display a short command to run on your machine. Copy it and paste it into your terminal.
4. Within seconds, your node will appear in your Netdata Cloud space.

You can connect as many nodes as you like. Once connected, all your machines appear together in the **Nodes** section of Netdata Cloud, and you can view their charts side by side or get a combined overview.

---

## What to Explore Next

Now that you're oriented, here are some great next steps:

- **Check the Alerts section** to see if anything on your system needs attention right now.
- **Scroll through the Overview page** to get a feel for your system's normal behavior — the baseline you'll compare against when something goes wrong.
- **Zoom into a time range** on any chart by clicking and dragging to investigate a past event.
- **Try the Anomaly Rate (AR) toggle** on a chart to see if your machine learning models have flagged anything unusual.
- **Explore the full documentation** at [learn.netdata.cloud](https://learn.netdata.cloud) for guides on alerts, custom dashboards, and advanced configuration.

---

## Troubleshooting: Dashboard Won't Load?

| Problem | What to Try |
|---|---|
| Browser shows "This site can't be reached" | Confirm Netdata is running; try restarting it with `sudo systemctl restart netdata` |
| Dashboard loads but shows no data | Wait 30–60 seconds for initial data collection to complete |
| Accessing from another machine fails | Check that port 19999 is not blocked by a firewall |
| Want access from outside your local network | Connect to Netdata Cloud (Step 5 above) for secure remote access |

---

You're all set! Netdata's dashboard gives you instant, deep visibility into everything happening on your system — with no configuration required to get started. The more you explore, the more you'll discover about the health and performance of your infrastructure.