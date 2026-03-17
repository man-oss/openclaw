# How to Configure and Manage Alerts in Netdata

Netdata automatically monitors your systems and fires alerts the moment something looks wrong — no manual setup required to get started. This guide teaches you how alerts work, how to customize them for your environment, and how to manage alert noise so you only hear about what truly matters.

---

## How Default Alerts Work

The moment Netdata starts collecting data from your system, it begins watching hundreds of metrics against a built-in library of pre-configured health rules. These cover areas like:

- **CPU, RAM, and disk usage** — warns before you run out of resources
- **Network activity** — detects packet drops, high utilization, and interface errors
- **Application health** — monitors databases, web servers, containers, and more
- **System events** — catches out-of-memory kills, swap exhaustion, and hardware anomalies

These built-in rules are called **stock alerts**. They use sensible defaults tuned for most environments and activate automatically when Netdata detects the relevant data source. You do not need to turn anything on.

### Alert States

Every alert in Netdata can be in one of these states:

| State | Meaning |
|---|---|
| **Clear** | Everything is normal — no action needed |
| **Warning** | Something is approaching a problem threshold — worth watching |
| **Critical** | A serious threshold has been crossed — action likely needed |

Netdata moves alerts between these states automatically as your metrics change, and sends you a notification each time the state changes.

---

## Viewing Active Alerts

### On the Local Dashboard

Open your Netdata dashboard in a browser (typically at `http://your-server:19999`). The **Alerts** section in the top navigation shows a count of active warnings and critical alerts. Clicking it takes you to a full list of firing alerts, each showing:

- The name of the alert and which metric it is watching
- The current value that triggered it
- When the alert started
- A short description of what it means

### In Netdata Cloud

If your nodes are connected to Netdata Cloud, navigate to the **Alerts** tab in the left sidebar. Here you can:

- See alerts across **all of your nodes** in one view, rather than node by node
- Filter by alert status, node, or time period
- Click into any alert to see its full history and the chart it is watching
- Acknowledge alerts to signal that your team is aware of the issue

---

## Customizing Alert Thresholds

The built-in thresholds may not be right for every environment. A server running a memory-hungry database should not warn at the same RAM percentage as a lightweight monitoring host. Netdata makes it straightforward to raise or lower these values.

### Where Alert Rules Live

Each alert rule is defined in a plain-text configuration file. Stock rules live in a read-only system folder; your customizations go into your **user configuration folder** (typically `/etc/netdata/health.d/`). Changes you make there survive Netdata upgrades.

To safely edit a built-in alert file, use the `edit-config` helper from your Netdata configuration directory:

```bash
sudo ./edit-config health.d/cpu.conf
```

This copies the stock file into your user folder and opens it for editing.

### Reading an Alert Rule

Here is a real example — the default CPU usage alert that comes with Netdata:

```
template: 10min_cpu_usage
      on: system.cpu
   class: Utilization
    type: System
  lookup: average -10m unaligned of user,system,softirq,irq,guest
   units: %
   every: 1m
    warn: $this > (($status >= $WARNING)  ? (75) : (85))
    crit: $this > (($status == $CRITICAL) ? (85) : (95))
   delay: down 15m multiplier 1.5 max 1h
 summary: CPU utilization
    info: Average cpu utilization for the last 10 minutes
      to: sysadmin
```

What each line does in plain language:

| Setting | What It Controls |
|---|---|
| `template` | The name of this alert rule. Using `template` means it applies to every matching chart automatically. |
| `on` | Which chart or metric to watch (`system.cpu` = overall CPU usage). |
| `lookup` | How to process the data — here, it takes the average of the last 10 minutes of CPU use. |
| `units` | The unit for the value being checked (percent). |
| `every` | How often to re-evaluate the rule (every 1 minute). |
| `warn` | The expression that triggers a Warning. The `? :` pattern creates a buffer zone so the alert does not flicker — CPU must drop below 75% to clear a warning, but must exceed 85% to first trigger one. |
| `crit` | Same idea for Critical — triggers at 95%, clears at 85%. |
| `delay` | Waits 15 minutes after recovery before clearing the alert, to avoid re-alerting on brief recoveries. |
| `repeat` | If defined, resends the notification at a set interval while the alert remains active. |
| `info` | A human-readable description shown in notifications and dashboards. |
| `to` | Which notification role receives the alert (e.g., `sysadmin`, `silent`). |

### Adjusting a Threshold

To change the CPU warning from 85% to 75%, edit the `warn` and `crit` lines:

```
warn: $this > (($status >= $WARNING)  ? (60) : (75))
crit: $this > (($status == $CRITICAL) ? (75) : (85))
```

Save the file, then apply your change without restarting Netdata:

```bash
sudo netdatacli reload-health
```

---

## Creating a Custom Alert

You can write new alerts for any metric Netdata collects. Here is a step-by-step example that monitors RAM usage and warns when it climbs above 80%.

### Step 1 — Create a new configuration file

From your Netdata configuration directory:

```bash
sudo touch health.d/ram-usage.conf
sudo ./edit-config health.d/ram-usage.conf
```

### Step 2 — Write the alert rule

Paste this into the file:

```
alarm: ram_usage
   on: system.ram
lookup: average -1m percentage of used
 units: %
 every: 1m
  warn: $this > 80
  crit: $this > 90
  info: The percentage of RAM being used by the system.
```

**What each part does:**

- `alarm: ram_usage` — Names this alert. Using `alarm` (rather than `template`) means it targets the specific chart named `system.ram` on this node.
- `on: system.ram` — The chart to watch. You can find chart names by hovering over any chart in the dashboard and looking at the tooltip.
- `lookup: average -1m percentage of used` — Look back 1 minute, calculate the average, express it as a percentage of the "used" portion.
- `every: 1m` — Evaluate this rule every minute.
- `warn: $this > 80` — Fire a warning when RAM is above 80%.
- `crit: $this > 90` — Escalate to critical above 90%.
- `info` — This text appears in your notifications and on the dashboard.

### Step 3 — Apply and verify

```bash
sudo netdatacli reload-health
```

Navigate to the Alerts section on your dashboard or in Netdata Cloud. Your new `ram_usage` alert will appear there once it has been evaluated.

### Using Templates to Cover All Instances at Once

If you want one rule to apply to **every disk**, **every network interface**, or every instance of any repeated metric, use `template` instead of `alarm`, and reference the metric's context rather than a specific chart name.

```
template: disk_space_warning
      on: disk.space
  lookup: max -1m percentage of avail
   every: 1m
    warn: $this < 20
    crit: $this < 10
    info: Available disk space is running low.
```

This single rule automatically creates an alert for every mounted disk on your system.

---

## Customizing Built-in Alerts (Overrides)

You do not need to modify stock files to customize their behavior — you can override them by creating a rule with the **same name** in your user configuration folder.

### Raise Thresholds for All Instances

To increase the CPU steal threshold for all machines, create a file in `/etc/netdata/health.d/` with the same alert name:

```
template: 20min_steal_cpu
      on: system.cpu
  lookup: average -20m unaligned of steal
   units: %
   every: 5m
    warn: $this > (($status >= $WARNING) ? (10) : (20))
```

Netdata processes your user configurations first, so this version wins. The stock definition is skipped.

### Override for One Specific Instance

To keep stock thresholds for most disks but use different thresholds for `/mnt/data`:

```
alarm: disk_space_usage
   on: disk_space._mnt_data
  lookup: max -1m percentage of avail
    warn: $this < 5
    crit: $this < 2
```

The specific chart ID (`disk_space._mnt_data`) means this rule only applies to that one mount point.

---

## Silencing Alerts and Managing Alert Noise

### Silence Notifications for One Alert

If you want Netdata to keep checking a metric but stop sending you notifications for it, change the `to:` line in that alert's configuration to `silent`:

```
to: silent
```

Reload health configuration to apply. The alert still appears on the dashboard but generates no notifications.

### Disable Specific Alerts Entirely

Open `/etc/netdata/netdata.conf` and find (or create) the `[health]` section. Use the `enabled alarms` setting with exclusion patterns:

```ini
[health]
    enabled alarms = !oom_kill *
```

This loads all alerts **except** `oom_kill`. You can list multiple exclusions:

```ini
enabled alarms = !oom_kill !disk_space_usage *
```

### Temporarily Disable All Alerts (Maintenance Mode)

In `/etc/netdata/netdata.conf`:

```ini
[health]
    enabled = no
```

Restart Netdata to apply. Remember to re-enable and restart when maintenance is done.

### Prevent Alert Noise During Recovery

The `delay` setting stops Netdata from notifying you the moment an alert clears, preventing a storm of "OK" messages after a brief incident:

```
delay: down 15m multiplier 1.5 max 1h
```

This waits 15 minutes after recovery before clearing the alert, and multiplies that delay if the alert keeps changing state.

### Reduce Repeated Notifications

The `repeat` setting controls how often Netdata re-notifies you while an alert remains active:

```
repeat: warning 2m critical 30s
```

This sends a reminder every 2 minutes for warnings, and every 30 seconds for critical alerts — or set `repeat: off` to stop repeating entirely.

---

## Using the Visual Alert Configuration Manager

If you prefer not to edit configuration files manually, Netdata Cloud includes an **Alerts Configuration Manager** — a visual wizard that guides you through setting up alerts.

To access it:
1. Navigate to any chart in the Netdata Cloud dashboard
2. Click the alert icon on the chart
3. Select **Add Alert**
4. Choose an alert detection type:
   - **Standard** — triggers when a metric crosses a fixed value
   - **Metric Variance** — triggers based on how much a metric fluctuates
   - **Anomaly Rate** — triggers when Netdata's machine learning detects unusual behavior
5. Set your warning and critical thresholds, check interval, notification delay, and recipients
6. Name the alert and add a description
7. Submit — Netdata pushes the configuration to your selected nodes

> **Note:** The Alerts Configuration Manager requires an active Netdata subscription.

---

## Tips for Reducing Alert Noise

| Problem | Solution |
|---|---|
| Alert fires and clears repeatedly (flapping) | Add a hysteresis buffer using the `? :` pattern in `warn`/`crit`. Require the value to recover further than where it triggered. |
| Too many notifications when a problem persists | Use `repeat: off` or set a longer repeat interval |
| Alert triggers on expected spikes | Increase the `lookup` window (e.g., `-5m` instead of `-1m`) so the alert reflects an average, not an instant spike |
| Irrelevant alerts for your workload | Disable with `enabled alarms = !alert_name *` in `netdata.conf`, or override with higher thresholds |
| Need silence during scheduled maintenance | Use the Netdata health management API to temporarily disable alerts without changing files |

---

## Quick Reference

### Alert Configuration Cheat Sheet

```
# To create an alert:
alarm: my_alert_name          ← starts the rule (one specific chart)
template: my_alert_name       ← starts the rule (all matching charts)
      on: chart.name          ← which metric to watch
  lookup: average -5m of used ← how to query the data
   every: 1m                  ← how often to evaluate
    warn: $this > 80          ← warning condition
    crit: $this > 95          ← critical condition
   delay: down 5m             ← wait before clearing
  repeat: warning 5m          ← how often to re-notify
      to: sysadmin            ← who gets notified (or: silent)
    info: What this alert means ← shown in notifications
```

### Common Commands

```bash
# Edit a built-in alert file safely
sudo ./edit-config health.d/cpu.conf

# Apply changes without restarting Netdata
sudo netdatacli reload-health

# Check what variables are available for a chart
http://your-server:19999/api/v1/alarm_variables?chart=system.cpu

# See all current alerts and their values
http://your-server:19999/api/v1/alarms?all
```