# How to Use the Netdata Dashboard

Netdata gives you a live, interactive window into your entire infrastructure — every server, container, and service — updated every second. This guide walks you through the main sections of the dashboard so you can navigate confidently, investigate problems quickly, and build views that fit your team's needs.

---

## Getting Your Bearings: The Dashboard at a Glance

When you open Netdata, you land in a **Room** — a workspace that groups a set of nodes (your servers, VMs, or containers) together. Every section of the dashboard is accessible from the navigation tabs along the top or side of the screen.

The five main areas you'll use every day are:

| Section | What It's For |
|---|---|
| **Home** | A real-time summary of your entire infrastructure's health |
| **Nodes** | A live list of every node with status, alerts, and quick actions |
| **Metrics** | Thousands of real-time charts organized by system area |
| **Alerts** | All current warning and critical conditions across your fleet |
| **Dashboards** | Custom views you build and save for your team |

---

## The Home Tab: Your Infrastructure at a Glance

The **Home** tab is the first thing you see when you enter a Room. Think of it as your command center — it gives you an instant read on whether your infrastructure is healthy without needing to click into individual servers.

### What You'll See

- **Total Nodes** — How many servers are being monitored, broken down into **Live** (online and streaming data), **Stale** (recently disconnected but with historical data), and **Offline** (fully disconnected).
- **Active Alerts** — A donut chart showing how many alerts are currently firing, split between **Critical** (red) and **Warning** (yellow). At a glance, you can tell if something needs urgent attention.
- **Nodes Map** — An interactive hexagonal map where each hexagon represents one of your servers. Hover over any hexagon to see details. The color of each hexagon can reflect its status or connection stability. You can also classify the nodes by operating system, cloud provider, cloud region, instance type, or custom labels you've assigned.
- **Nodes with the Most Alerts (Last 24 Hours)** — A bar chart ranking your most problematic servers by alert count over the past day.
- **Top Alerts (Last 24 Hours)** — A sortable table of the most frequently triggered alerts, showing how many times each fired and for how long. This is great for spotting recurring problems that may need a permanent fix.
- **Space Metrics** — A quick count of total metrics available, charts being visualized, and alerts configured across your whole setup.
- **Data Retention Per Node** — A chart showing how much historical data each server holds, so you know how far back in time you can investigate.

> **Tip:** Check the Home tab first whenever you start your day or respond to an incident. The alert trends and nodes map tell you immediately whether your infrastructure is in good shape.

---

## The Nodes Tab: Your Full Fleet in One View

Navigate to the **Nodes** tab to see a detailed, live list of every server in your Room. This is where you go when you want to find a specific server, check its health, or jump into its individual dashboard.

### Reading the Nodes List

Each row in the Nodes tab represents one server. You can see:

- Its current **status** (Live, Stale, or Offline)
- Any **active alerts** on that server
- Whether **Machine Learning** anomaly detection is running on it
- Quick actions like opening the server's full dashboard or creating an alert silence rule

### Filtering Your Nodes

Use the right-hand sidebar to narrow down which servers you see:

- **By host labels** — If you've tagged your servers (for example, `environment=production` or `team=backend`), you can filter to show only those.
- **By node status** — Show only Live, Stale, or Offline nodes.
- **By Netdata version** — Useful when managing an upgrade rollout.
- **By name** — Type in the search bar to find a specific server instantly.

You can also sort the entire list by **status** or **alert count**, and choose which metric charts appear as quick-reference columns next to each server name.

> **Tip:** All filters and column choices on the Nodes tab are saved and shared with everyone in the Room, so your team always sees a consistent view.

---

## The Metrics Tab: Exploring Live Charts

The **Metrics** tab is where you dig into the actual data — thousands of charts organized into logical sections like CPU, Memory, Disk, Network, and any applications running on your servers (databases, web servers, containers, and more).

### How the Charts Are Organized

Charts are grouped by **section** (for example, "CPU," "Memory," "Disk I/O," "Network Interfaces"). At the top of each section, you'll see summary charts that give you an overview before you scroll into the detail.

### Navigating Between Sections

On the right-hand side of the Metrics tab, a **Chart Navigation Menu** lets you:

- **Jump to any section** without scrolling — just click the section name.
- **View active alerts** for the Room without leaving the Metrics tab.
- **Check the Anomaly Rate (AR%)** for each section — clicking the `AR%` button shows you how anomalous the metrics in that section are, helping you focus your attention where something unusual is happening.

### Drilling Into a Single Server

From almost anywhere in the dashboard, clicking a server's name takes you to its **single-node dashboard** — the same charts as the Metrics tab, but showing only that one server. This is ideal when you've identified a problem machine and want to investigate it in isolation.

---

## Time Controls: Looking Back in Time

Netdata shows live data by default, updating every second. But you can pause, rewind, or jump to any specific time period to investigate past events.

### Play, Pause, and Force Play

In the top bar of the dashboard, you'll find three playback controls:

| Mode | What It Does |
|---|---|
| **Play** | Charts update in real time while the dashboard is in the foreground |
| **Pause** | Charts stop updating — happens automatically when your mouse is on a chart, or manually when you click Pause |
| **Force Play** | Charts keep updating even if you switch to another browser tab — perfect for watching metrics on a background screen or TV |

### Jumping to a Specific Time Period

Click the **timeframe selector** near the top-right corner of the dashboard to choose what period you want to view:

- **Quick presets:** Last 5 minutes, 15 minutes, 30 minutes, 1 hour, 2 hours, 6 hours, 12 hours, 1 day, 2 days, or 7 days — one click and all charts update together.
- **Custom interval:** Type a number and choose minutes, hours, days, or months for precise control.
- **Calendar picker:** Click a start date and end date on the calendar to view any multi-day window.

Click **Apply** to update all charts to your chosen window. Click **Clear** to return to the live, real-time view.

> **Important:** The further back in time you look, the less granular the data becomes. At the default live view, each data point represents one second. When viewing 6 hours of history, each data point represents an average across a longer window. You can only look as far back as your server's storage allows — typically 1–3 days by default, though this can be extended.

### Changing Your Timezone

Open the timeframe selector and use the **timezone control** to switch all timestamps in the dashboard to any timezone — useful for distributed teams or when correlating events across regions.

---

## Filtering and Grouping Metrics

When you're monitoring many servers at once, the ability to focus on a subset is essential. Netdata gives you several ways to slice and dice what you see.

### The Node Filter

A **node filter** appears on every view (except single-node dashboards). Use it to:

- **Show only specific servers** — type a server name in the search bar to find it instantly.
- **Filter by group** — choose to see only Live, Stale, or Offline nodes.

When you select one or more nodes, all charts on the page update to show only data from those servers. The number of selected nodes appears in the Nodes bar.

### Filtering by Label, Status, or Version

From the right-hand sidebar on the **Metrics** tab and **Nodes** tab, you can filter charts and node lists by:

- **Host labels** — Any tags you've applied to your servers (e.g., `cloud_region=us-east-1`, `team=payments`).
- **Node status** — Live or Offline.
- **Netdata version** — Helpful when managing a fleet with mixed software versions.

### Grouping Charts by Node or Dimension

When a chart shows data from multiple servers, you can control how that data is grouped and aggregated. For example, instead of seeing one combined CPU line for all your web servers, you can split it to see each server's CPU individually — or group by label to see production vs. staging side-by-side.

---

## The Alerts Tab: Managing What's Wrong Right Now

The **Alerts** tab gives you a complete list of everything currently firing across your infrastructure.

### Reading the Raised Alerts Table

Each row shows:

- **Alert Name** — What the alert is about (click it for full details).
- **Status** — Warning or Critical.
- **Class** — The type of problem, such as Latency or Utilization.
- **Type & Component** — Which system area and component is affected (e.g., CPU, Disk, Web Server).
- **Node Name** — Which server triggered it.
- **Silencing Rule** — Whether notifications for this alert have been muted.

Click any column header to sort. Use the gear icon to show or hide columns.

### Filtering Alerts

Use the right-hand sidebar to narrow down alerts by:

- Status (Warning or Critical)
- Alert class (Latency, Utilization, etc.)
- System type and component
- Notification role (e.g., Sysadmin, Webmaster)
- Host labels (e.g., only production servers)
- Specific nodes

### Viewing Alert Details

Click any alert name to open its detail page, which shows:

- When the alert was triggered
- A plain-English description of what it means
- A **chart snapshot** showing exactly what the metric looked like when the alert fired
- The full configuration of the alert
- A link to jump directly to the relevant chart for live investigation

From the detail page, you can also **run Metric Correlations** to find other metrics that changed at the same time — great for tracing the root cause.

### Silencing Alerts

If an alert is expected (for example, during a planned maintenance window), click the **Actions** column on any alert row and create a silencing rule. This stops notifications from going out without disabling the underlying monitoring.

---

## Metrics Correlations: Finding the Root Cause Faster

**Metrics Correlations** is one of Netdata's most powerful features. When something goes wrong, it automatically scans every metric across your infrastructure and shows you which ones changed at the same time — helping you move from "something is broken" to "here's what caused it" in minutes.

### When to Use It

Use Metrics Correlations whenever you notice an unusual spike, dip, or pattern in any chart and want to know what else was happening at the same time.

### How to Run a Correlation

1. Go to the **Metrics** tab (or a single-node dashboard).
2. Click the **Metric Correlations** button in the top-right corner.
3. On any chart, click and drag to **highlight a time window** that covers the anomaly. The window must be at least 15 seconds wide.
4. A panel appears showing your selected window and the comparison baseline (the same duration just before your selection, used as the "normal" reference).
5. Click **Find Correlations**.

Netdata evaluates every available metric and returns a filtered dashboard showing only the charts that changed most significantly between your highlighted window and the baseline.

6. If the results need refinement, select a different time window and click **Find Correlations** again.

### Combining with Anomaly Detection

For even faster root cause analysis, combine Metrics Correlations with Netdata's built-in anomaly detection:

1. Notice an anomaly spike (often visible as the `AR%` indicator turning red in the Chart Navigation Menu).
2. Highlight that time period on any chart.
3. In the Metric Correlations panel, change the **Data Type** from `Metrics` to `Anomaly Rate`.
4. Click **Find Correlations**.

The results now show you which metrics had the highest anomaly rates during that window — not just which ones changed, but which ones were behaving unusually for their own historical patterns.

### Tuning the Results

| Setting | Options | When to Use |
|---|---|---|
| **Method** | KS2 or Volume | Use **KS2** for complex distribution changes (e.g., latency spikes). Use **Volume** for metrics that were flat and then spiked (e.g., network traffic turning on). |
| **Aggregation** | Average, Median, Min, Max, Stddev | Change from Average if you want to surface extreme values rather than typical ones. |
| **Data Type** | Metrics or Anomaly Rate | Use **Anomaly Rate** when investigating unusual behavior rather than raw value changes. |

> **Tip:** When you run correlations across many servers at once, group the results by node first. If only a few servers stand out, filter to just those servers and run correlations again for sharper results.

### Understanding the Results

| Anomaly Rate | Correlation Strength | What It Likely Means |
|---|---|---|
| High | Strong | A significant issue is actively affecting system behavior |
| High | Weak | A possible edge case or intermittent problem |
| Low | Strong | A notable but expected change in system behavior |
| Low | Weak | Normal system operation |

---

## The Dashboards Tab: Building Custom Views

While Netdata automatically generates dashboards for every metric, you can also create **custom dashboards** that bring together exactly the charts your team cares about — across any number of servers, organized the way you want.

### Creating a New Dashboard

1. Click the **Dashboards** tab in any Room.
2. Click the **+** button.
3. Enter a name for your dashboard and click **+ Add**.

### Adding Charts

Click **Add Chart** at the top right of your new dashboard.

| Step | What to Do |
|---|---|
| **Choose a source** | Select "All Nodes" or pick a specific server. |
| **Choose a metric** | Browse or search for the metric you want (e.g., CPU usage, database query time). A preview appears immediately. |
| **Configure the chart** | Choose how data is grouped (by node, by service, by label), which servers or instances to include, which dimensions to show, and how values are aggregated over time. |
| **Set the chart type** | Switch between line, area, bar, or other chart types using the title bar. |
| **Select dimensions** | Choose which specific data lines (dimensions) to display and arrange their order. |

Click **Add Chart** to place it on the dashboard.

### Adding Text Cards

Click **Add Text** to insert a text block anywhere on the dashboard. Use text cards to:

- Label sections of the dashboard for your team.
- Add notes explaining what a chart shows or what thresholds to watch for.
- Document the purpose of the dashboard.

Click the **T** icon inside the text editor to switch between font sizes.

### Arranging Your Layout

- **Move elements** — Click and hold the drag handle at the top-right of any chart or text card, then drag it to a new position.
- **Resize elements** — Click and drag from the bottom-right corner of any element to make it larger or smaller.
- Elements automatically snap to the grid when you release them.

> **Always click Save** after making any changes. If two people edit the same dashboard simultaneously, the second person to save will be asked whether to overwrite or reload.

### Managing Charts on Your Dashboard

Right-click the three-dot menu on any chart to:

- **Go to Chart** — Jump to that chart in the full Metrics tab for deeper investigation.
- **Rename** the chart to something more meaningful for your team.
- **Remove** the chart from the dashboard.

### Sharing Dashboards on a TV or Wallboard

Use **TV Mode** to display a dashboard on a large screen without requiring anyone to be logged in:

1. Open the dashboard you want to display.
2. Click the **TV Mode** button (next to the Save button).
3. Copy the generated URL and open it on your display device.

The URL includes an embedded access token that handles authentication automatically, and preserves the time range you had selected. TV Mode is ideal for operations centers, team screens, or any shared display where you want continuous metric visibility.

> **Security note:** TV Mode URLs contain authentication tokens. Treat them like passwords — only share with trusted people, and revoke tokens in **User Settings > API Tokens** when they're no longer needed.

---

## Quick Reference: Tips for Everyday Use

| Task | Where to Go |
|---|---|
| Check overall infrastructure health | Home tab |
| Find a specific server | Nodes tab → search by name |
| Investigate a specific metric | Metrics tab → scroll to section or use Navigation Menu |
| See what's broken right now | Alerts tab → Raised Alerts |
| Investigate why something broke | Metrics tab → Metric Correlations |
| Watch metrics update in the background | Set playback to **Force Play** |
| Look at data from last week | Timeframe selector → 7 days |
| Share a dashboard with your team | Dashboards tab → TV Mode or invite team members to the Room |
| Focus on one server | Click its name anywhere in the UI to open its single-node dashboard |
| Spot anomalous sections at a glance | Metrics tab → check `AR%` in the Chart Navigation Menu |

---

## What's Next

Once you're comfortable navigating the dashboard, explore these related features:

- **Anomaly Advisor** — A dedicated view that scores all metrics by how anomalous they were during any time window, surfacing the most likely culprits automatically.
- **Events Feed** — A timeline of infrastructure changes, alert state transitions, and other notable events.
- **Logs Tab** — Search and explore system and application logs directly inside the dashboard.
- **Alert Configuration** — Review, tune, or create new alerts from the Alerts tab without touching any configuration files.