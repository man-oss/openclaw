---

## What You Can Monitor

Netdata supports several types of log sources, all accessible from the same **Logs** tab in the dashboard:

| Log Source | What It Covers |
|---|---|
| **systemd Journal** | All Linux system logs — kernel messages, service output, audit records, syslog, and more |
| **Windows Event Logs** | Windows Event Log (WEL) channels, including Event Tracing for Windows (ETW) |
| **OpenTelemetry Logs** | Application logs ingested via the OpenTelemetry (OTLP) protocol |

Netdata automatically discovers all available log sources on your system — no manual setup is needed to start seeing logs.

---

## Getting Started: Requirements

Before you can view logs in Netdata, make sure you have:

- **Netdata Agent version 1.44 or newer** installed on your system
- A **free Netdata Cloud account** — this is required to unlock the Logs tab and related features
- A standard Netdata installation (package, source, or Debian-based Docker container)

> **Note:** The Logs tab is not available on Alpine-based Docker containers or static Netdata builds. Use Debian-based containers if you are running Netdata in Docker.

---

## Opening the Logs Tab

1. Log in to [Netdata Cloud](https://app.netdata.cloud) or open your local Netdata dashboard.
2. Select the node (server) you want to inspect from the left-hand navigation or the Nodes page.
3. Click the **Logs** tab at the top of the dashboard.

The Logs tab opens with a live view of your system's log entries, organized by time with the most recent entries at the top.

---

## Understanding the Logs View

Once you're on the Logs tab, you'll see several key areas:

### Timeline / Histogram
At the top, a visual bar chart shows how many log entries occurred over time. You can:
- **Click and drag** to zoom into a specific time window
- **Pan left or right** to move through time
- **Click a bar** to jump directly to that period's log entries

The histogram can break down log frequency by any field — for example, showing how many `error`-level vs. `warning`-level messages appeared over the past hour.

### Log Entry Table
The main table lists individual log entries in time order. Each row shows key details like the timestamp, priority level (color-coded), and message text. You can:
- **Scroll** through entries
- **Click any row** to see the full details of that log entry in a side panel
- **Customize columns** using the ⚙️ icon above the table to choose which fields to display

### Entry Detail Panel
Clicking a log entry opens a side panel showing every field attached to that entry — including the service that logged it, the user ID, the machine name, and any other structured data. Field values can be copied directly from this panel.

---

## Choosing a Log Source

By default, Netdata merges all available log sources into one unified view. To focus on a specific source:

1. Look for the **Sources** filter in the sidebar.
2. Select the source you want — for example:
   - **system** — kernel and core system messages
   - **user** — logs from individual user sessions
   - **remote** — logs received from other servers in your infrastructure
   - A specific **namespace** if you use isolated log streams per service

> **Tip:** Selecting a specific source before searching or filtering significantly improves performance, especially on busy systems.

---

## Searching and Filtering Logs

Netdata gives you powerful tools to find exactly what you're looking for.

### Full-Text Search
Type any word or phrase into the search bar to search across all log fields at once.

| Search Pattern | What It Does |
|---|---|
| `error` | Finds any entry containing the word "error" |
| `a*b` | Wildcard — matches "acb", "a_long_b", etc. |
| `error\|warning` | Finds entries containing "error" OR "warning" |
| `!systemd\|*` | Excludes entries containing "systemd" |

### Field Filters
The left sidebar shows available filter fields (such as **Priority**, **Service**, **Hostname**, and more). Each filter value shows a live count of how many matching entries exist in your current time window.

- **Click a value** to filter to only those entries
- **Select multiple values** for an OR filter (e.g., show both `error` and `critical` entries)
- Filters update instantly — no need to press a search button

### Time Range Selection
Use the time picker at the top of the page to narrow your view to a specific period — such as the last 15 minutes, the last 24 hours, or a custom date and time range. This is especially useful when investigating an incident at a known time.

---

## Watching Logs in Real Time

Click the **▶️ Play** button at the top of the dashboard to enter **Play mode**. In this mode:

- New log entries appear automatically as they arrive — similar to watching a live feed
- The view continuously updates without needing to refresh the page
- This works for both individual servers and centralized log servers

Click the **⏸ Pause** button to stop the live feed and examine a specific moment in time.

---

## Correlating Logs with Metrics

One of Netdata's most powerful capabilities is the ability to look at logs and performance metrics together. When you notice a spike in CPU usage, memory, or network traffic on a metrics chart, you can immediately switch to the Logs tab and explore what was happening on the system at the exact same time.

The time controls are shared across the entire dashboard — so if you zoom in to a 5-minute window on a metrics chart, the Logs tab will show you only the log entries from that same 5-minute window.

This makes it straightforward to answer questions like:
- "Which service was writing errors when CPU spiked at 2:34 AM?"
- "What was logged right before the application crashed?"
- "Did any authentication failures occur during the outage window?"

---

## Monitoring Logs Across Multiple Servers

If you manage several servers, Netdata can collect and display logs from all of them in one place using a **log centralization server**. When configured, the Logs tab shows a unified view of logs from your entire infrastructure, with the ability to filter by individual host.

Two setup approaches are available:

- **Nodes push logs** to a central server (passive mode)
- **Central server pulls logs** from each node (active mode)

Both approaches use tools already built into modern Linux systems (`systemd-journal-remote`). Once centralized, install Netdata on the central server to explore all logs from a single dashboard.

---

## Setting Up Alerts Based on Log Activity

While Netdata's built-in alerting is primarily metric-based, you can use the log histogram and filters to identify patterns that correlate with problems — and then use Netdata's alert system to notify you when related metrics cross thresholds.

For example:
- Set an alert on **service restart counts** (a metric Netdata tracks) when you notice frequent "service failed" log entries
- Use the **Alerts tab** to configure notifications when error rates or specific system states are detected

> For pattern-based log alerting, use the **full-text search** and **field filters** to isolate the log signature you care about, then monitor the corresponding metric in Netdata's Alerts configuration.

---

## Tips for Better Performance

If the Logs tab feels slow, try these steps:

- **Select a specific source** instead of querying all sources at once
- **Narrow the time range** — shorter windows load much faster
- **Apply filters** before browsing — reduces the amount of data Netdata needs to scan
- **Limit the number of rows** displayed in the table

Netdata's log engine is designed to handle very large datasets. It can evaluate up to 1,000,000 log entries per query and is typically 25–30x faster than running equivalent `journalctl` commands manually.

---

## Frequently Asked Questions

**Do my logs get sent to Netdata Cloud?**
No. Log data flows directly between your Netdata Agent and your web browser. Netdata Cloud only handles authentication — your log content is never stored in the cloud.

**Can I view logs from a parent Netdata node?**
Yes. If your nodes report to a Netdata parent, the Logs tab is accessible for all child nodes from the parent's dashboard.

**What if I don't see any log sources?**
Make sure your system has journal files in `/var/log/journal` (for persistent logs) or `/run/log/journal` (for in-memory logs). If logs aren't persisting across reboots, you may need to enable persistent storage in your system's journal settings.

**Can I use the Logs tab alongside Loki or other log tools?**
Yes. Netdata reads logs directly from your system without requiring any changes to your existing log pipeline. It can complement tools like Loki by providing fast, zero-configuration access to systemd journal fields that other tools may not index.