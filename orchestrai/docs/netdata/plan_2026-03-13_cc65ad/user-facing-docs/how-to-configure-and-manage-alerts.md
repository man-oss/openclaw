---

## Understanding How Default Alerts Work

Netdata automatically loads a library of built-in alerts that cover the most common warning scenarios across your infrastructure. These alerts are ready to go without any configuration.

**Where default alerts come from:** Netdata ships with a collection of pre-configured alert files stored in `/usr/lib/netdata/conf.d/health.d/`. These files cover areas like CPU usage, disk space, memory, network interfaces, database performance, container health, and many more. Every time Netdata starts, it reads these files and begins monitoring your system against their defined thresholds.

**Two types of alerts:** Netdata uses two building blocks:

| Type | What it does |
|------|--------------|
| **Alert** | Monitors one specific chart or instance (e.g., a single disk) |
| **Template** | Automatically monitors *all* instances of a given type (e.g., every disk on your system) |

Templates are the reason Netdata can alert on a brand-new disk the moment it appears — no extra setup required.

**Alert states:** Every alert moves through the following states:

| State | What it means |
|-------|---------------|
| **Clear** | Everything is normal |
| **Warning** | Something needs attention |
| **Critical** | Urgent action required |
| **Undefined** | Data couldn't be retrieved |

**Important:** Default alert files are replaced during Netdata upgrades. Any changes you want to keep must be made in your own configuration files (in `/etc/netdata/health.d/`), which are never overwritten during upgrades.

---

## Anatomy of an Alert Configuration

Every alert — whether built-in or custom — follows the same structure. Here is a real example from Netdata's built-in CPU alert:

```
template: 10min_cpu_usage
      on: system.cpu
   class: Utilization
    type: System
component: CPU
  lookup: average -10m unaligned of user,system,softirq,irq,guest
   units: %
   every: 1m
    warn: $this > (($status >= $WARNING)  ? (75) : (85))
    crit: $this > (($status == $CRITICAL) ? (85) : (95))
   delay: down 15m multiplier 1.5 max 1h
 summary: CPU utilization
    info: Average cpu utilization for the last 10 minutes (excluding iowait, nice and steal)
      to: sysadmin
```

Here is what each key line does:

### `alarm` / `template` — The Name
This is the first line of every alert and defines whether it applies to one chart (`alarm`) or all charts of a given type (`template`). Names can only contain letters, numbers, periods (`.`), and underscores (`_`).

### `on` — What to Watch
Tells Netdata which metric to monitor. For **alerts**, use the exact chart name (like `system.cpu`). For **templates**, use the chart's context (like `disk.space`), which makes the alert apply to every disk automatically.

> **Tip:** To find a chart's name, look at the chart title on your dashboard. To find its context, hover over the date on any chart — the tooltip shows something like `proc:/proc/diskstats, disk.io`. The part after the comma (`disk.io`) is the context.

### `lookup` — How to Read the Data
Defines what data to pull from Netdata's database and how to process it before comparing to thresholds.

**Example:** `lookup: average -10m unaligned of user,system,softirq,irq,guest`

This reads the last 10 minutes of data across the listed CPU dimensions and calculates the average.

Common lookup methods include `average`, `min`, `max`, and `sum`. The result of the lookup is always available as `$this`.

### `every` — How Often to Check
Sets the check frequency. For example, `every: 1m` checks the metric once per minute. Supported units: `s` (seconds), `m` (minutes), `h` (hours), `d` (days).

### `warn` and `crit` — The Thresholds
These expressions define when an alert becomes a warning or critical. They evaluate to true or false.

**Simple example:**
```
warn: $this > 80
crit: $this > 95
```

**With hysteresis (recommended):** The conditional pattern `(($status >= $WARNING) ? (lower) : (higher))` creates a "sticky" threshold that prevents constant flapping when a value hovers near the trigger point:
```
warn: $this > (($status >= $WARNING)  ? (75) : (85))
crit: $this > (($status == $CRITICAL) ? (85) : (95))
```

This means: alert triggers at 85%, but won't clear until the value drops below 75%. This prevents repeated notifications when a metric fluctuates around the threshold.

### `delay` — Slowing Down Notifications
Controls how long Netdata waits before sending a notification when an alert state changes. This prevents notification floods during transient spikes.

**Example:** `delay: down 15m multiplier 1.5 max 1h`

| Parameter | What it does |
|-----------|--------------|
| `up U` | Wait before notifying on a state increase (e.g., Clear → Warning) |
| `down D` | Wait before notifying on a state decrease (e.g., Critical → Warning) |
| `multiplier M` | If the alert changes state again during the delay, multiply the wait time |
| `max X` | The maximum total delay allowed |

### `repeat` — Ongoing Reminders
Tells Netdata how often to re-send notifications while an alert stays in a warning or critical state.

**Example:** `repeat: warning 120s critical 10s`

This re-notifies every 2 minutes during a warning, and every 10 seconds during a critical event.

### `info` and `summary`
- **`summary`** — A short title that appears in dashboards and notifications (e.g., `CPU utilization`)
- **`info`** — A longer explanation of what the alert monitors, shown in notification messages

### `to` — Who Gets Notified
Specifies which role (or roles) receives notifications when this alert fires. The default is `sysadmin`. Set to `silent` to stop all notifications for this alert while keeping monitoring active.

---

## Creating a Custom Alert

You can write your own alerts for any metric Netdata collects. The safest approach is to create a new file in `/etc/netdata/health.d/` — files here are never overwritten by upgrades.

### Step-by-Step: Monitor RAM Usage

**Step 1:** Open a terminal on your server and create a new alert file:
```bash
sudo touch health.d/ram-usage.conf
sudo ./edit-config health.d/ram-usage.conf
```
(Run this from your Netdata config directory — typically `/etc/netdata`.)

**Step 2:** Add your alert definition:
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

**What each line means:**
| Line | Purpose | This example |
|------|---------|--------------|
| `alarm: ram_usage` | Name this alert | `ram_usage` |
| `on: system.ram` | Watch the RAM chart | `system.ram` |
| `lookup` | Get the 1-minute average of the "used" dimension, as a percentage | Last minute, average, percentage |
| `every: 1m` | Check every minute | 1 minute |
| `warn: $this > 80` | Alert if RAM usage exceeds 80% | 80% |
| `crit: $this > 90` | Critical if RAM usage exceeds 90% | 90% |
| `info` | Description shown in notifications | Plain text |

**Step 3:** Apply the changes without restarting Netdata:
```bash
sudo netdatacli reload-health
```

Your new alert will appear in the dashboard within seconds.

### Alert for All Disks (Using a Template)

Templates are powerful because they automatically apply to every matching instance. This example watches all your disks at once:

```
template: disk_full_percent
      on: disk.space
    calc: $used * 100 / ($avail + $used)
   every: 1m
    warn: $this > 80
    crit: $this > 95
  repeat: warning 120s critical 10s
    info: Disk space usage percentage.
```

Because this uses `template` and `on: disk.space` (a context, not a specific chart), it automatically monitors every disk — including any you add in the future.

---

## Adjusting Thresholds and Customizing Built-In Alerts

Netdata's default thresholds are designed for general use. You may need to raise or lower them to match your specific environment.

### The Safe Way: Override Without Editing Stock Files

Create a file in `/etc/netdata/health.d/` with an alert of the **same name** as the stock alert. Netdata processes user files first, so your version takes priority.

**Example: Raise the CPU usage warning threshold**

The built-in alert triggers a warning at 85% CPU. To change it to 75%:

1. Create your override file:
   ```bash
   sudo ./edit-config health.d/my-overrides.conf
   ```

2. Copy the alert structure and adjust the thresholds:
   ```
   template: 10min_cpu_usage
         on: system.cpu
     lookup: average -10m unaligned of user,system,softirq,irq,guest
      units: %
      every: 1m
       warn: $this > (($status >= $WARNING)  ? (60) : (75))
       crit: $this > (($status == $CRITICAL) ? (75) : (85))
   ```

3. Reload:
   ```bash
   sudo netdatacli reload-health
   ```

> **Note:** Your override must be a complete alert definition — include all fields like `lookup`, `warn`, `crit`, etc. Omitting a field means that field uses its default value, not the stock value.

### Override for One Specific Instance

If you want different thresholds for just one disk (say `/mnt/data`) while keeping defaults for everything else, use an `alarm` (not a `template`) targeting that specific chart:

```
alarm: disk_space_usage
   on: disk_space._mnt_data
lookup: max -1m percentage of avail
  warn: $this < 5
  crit: $this < 2
```

The chart name for a mount point follows the pattern `disk_space.` followed by the path with slashes replaced by underscores.

### Override Per Environment

You can apply different thresholds to different groups of servers using host labels:

```
# Stricter thresholds for production
template: 10min_cpu_usage
      on: system.cpu
host labels: environment=production
    warn: $this > 70

# Relaxed thresholds for development
template: 10min_cpu_usage
      on: system.cpu
host labels: environment=development
    warn: $this > 90
```

---

## Silencing Alerts for Maintenance

When you are performing planned maintenance or know that certain alerts are not relevant, you have several options to quiet them.

### Option 1: Silence Notifications for One Alert (Keep Monitoring)
Change the `to:` line in the alert's configuration to `silent`. The alert still appears in the dashboard but sends no messages to anyone:
```
to: silent
```
Then reload: `sudo netdatacli reload-health`

### Option 2: Disable Specific Alerts Completely
In your main configuration file (`/etc/netdata/netdata.conf`), use the `enabled alarms` setting in the `[health]` section:

```ini
[health]
    enabled alarms = !oom_kill !20min_steal_cpu *
```

The `!` prefix excludes an alert. The `*` at the end means "keep everything else." After editing, restart Netdata.

### Option 3: Disable All Alerts (Maintenance Mode)
In `/etc/netdata/netdata.conf`, under `[health]`:
```ini
[health]
    enabled = no
```
Restart Netdata to apply. This turns off all health monitoring until you re-enable it.

### Option 4: Temporary Silencing Without Config Changes
The Netdata health management API allows you to temporarily disable alerts or suppress notifications without touching any files or restarting. This is ideal for short maintenance windows. Changes made through the API are not permanent and do not survive a restart.

---

## Viewing and Acknowledging Active Alerts

### On the Local Dashboard
The Netdata local dashboard (accessible at `http://your-server:19999`) shows all currently active alerts. Look for the alarm bell icon or the **Alerts** section. Each active alert displays:
- Its name and the chart it is monitoring
- Current status (Warning or Critical)
- The current metric value that triggered it
- The description from the `info` line

### On Netdata Cloud
If your agents are connected to Netdata Cloud, you can view alerts across your entire infrastructure from a single place:

1. Navigate to the **Alerts** page from the main menu
2. See all active warnings and critical alerts across every connected node
3. Filter by node, alert name, severity, or time period
4. Click any alert to drill into the chart and see the full history of the metric

### Using the Alerts Configuration Manager (Visual UI)
For users who prefer not to write configuration files, Netdata Cloud includes a visual **Alerts Configuration Manager** that walks you through creating alerts with a point-and-click interface:

1. Navigate to any chart on the Metrics page
2. Click the alert icon on the chart
3. Select **Add Alert**
4. Set your thresholds, check interval, notification delay, and who to notify
5. Click **Submit** to deploy the alert to your nodes

The Configuration Manager supports three alert detection styles:

| Style | Best for |
|-------|----------|
| **Standard** | Simple threshold-based alerts (metric exceeds a value) |
| **Metric Variance** | Detecting unusual variation in a metric over time |
| **Anomaly Rate** | Using Netdata's built-in machine learning to flag unusual behavior |

> **Note:** The Alerts Configuration Manager requires an active Netdata subscription.

---

## Verifying Your Alert Configuration

After creating or modifying an alert, confirm it is working correctly:

**Check all active alerts via the API:**
```
http://your-server:19999/api/v1/alarms?all
```

**Check available variables for a chart:**
```
http://your-server:19999/api/v1/alarm_variables?chart=system.cpu
```

Replace `system.cpu` with whichever chart your alert monitors. This shows every variable you can use in your `warn`, `crit`, and `calc` lines.

**Verify which config file is active:**
After reloading, look at the `source` field in the API response for your alert — it confirms whether Netdata is using your override file or the stock definition.

---

## Quick Reference: Common Alert Tasks

| Goal | What to do |
|------|------------|
| Create a new custom alert | Add a `.conf` file in `/etc/netdata/health.d/` and reload |
| Change a built-in alert's thresholds | Create an override with the same alert name in `/etc/netdata/health.d/` |
| Stop notifications for one alert | Set `to: silent` in the alert config and reload |
| Disable one specific alert | Add `!alert_name` to `enabled alarms` in `netdata.conf` |
| Disable all alerts temporarily | Set `enabled = no` in the `[health]` section of `netdata.conf` |
| Apply changes without restarting | Run `sudo netdatacli reload-health` |
| View all active alerts | Visit the Alerts page on your dashboard or Netdata Cloud |
| Create an alert across all nodes | Use the Alerts Configuration Manager in Netdata Cloud |