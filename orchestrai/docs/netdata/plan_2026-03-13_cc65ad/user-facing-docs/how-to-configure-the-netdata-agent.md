---

# How to Configure the Netdata Agent

Netdata works out of the box with sensible defaults, but you can customize nearly every aspect of its behavior — from how often it collects data, to which services it monitors, to how much history it stores. This guide walks you through everything you need to know to tailor Netdata to your environment.

---

## Overview: Where Configuration Lives

All Netdata configuration files are stored in a single directory called the **Netdata config directory**. On most Linux systems, this is located at:

```
/etc/netdata/
```

On some systems (such as those using the static installer), it may instead be at:

```
/opt/netdata/etc/netdata/
```

> **Not sure which location applies to you?** Open your browser and go to `http://YOUR-SERVER-IP:19999/netdata.conf`. Look for the line that starts with `# config directory =` — the value shown is your config directory.

Inside this directory, you will find:

- **`netdata.conf`** — the main configuration file that controls global behavior
- **Additional `.conf` files** — settings for specific plugins and data collectors
- **`edit-config`** — a helper script for safely editing configuration files

---

## The Main Configuration File: `netdata.conf`

The file `netdata.conf` is the central place to control how the Netdata Agent behaves. It is organized into **sections**, each starting with a name in square brackets (for example, `[global]` or `[ml]`). Within each section, settings are written as `key = value` pairs.

### Key Settings You Can Adjust

#### How Often Data Is Collected (Update Frequency)

By default, Netdata collects metrics **every second**, giving you real-time visibility into your system. If you want to reduce the load on your server — especially on lower-powered machines — you can tell Netdata to collect less frequently.

In `netdata.conf`, under the `[global]` section:

```
[global]
    update every = 1
```

Changing `1` to `2` means Netdata collects every 2 seconds; `5` means every 5 seconds, and so on. This significantly reduces CPU usage and the number of disk writes.

#### How Metrics Are Stored (Memory Mode)

Netdata supports different modes for storing collected metrics:

| Mode | What It Does | Best For |
|---|---|---|
| **dbengine** (default) | Stores data on disk with smart compression; supports long history | Most production systems |
| **ram** | Stores data only in memory; no disk writes at all | Child nodes streaming to a Parent, IoT devices |
| **alloc** | Similar to RAM mode | Lightweight temporary agents |

To switch to RAM mode (eliminating all disk writes for metrics):

```
[db]
    mode = ram
```

This is particularly useful for **Child nodes** in a Parent-Child setup, since those nodes stream all their data to a central Parent and don't need to store it locally.

#### How Long History Is Kept (Retention)

By controlling retention, you decide how far back you can look at your metrics. Longer history uses more disk space and memory; shorter history saves resources.

Retention is configured in the `[db]` section of `netdata.conf`. Refer to the database configuration settings to set the number of tiers and their respective sizes to match your storage and memory budget.

---

## How to Edit Configuration Files

### The Recommended Way: `edit-config`

Netdata provides a helper script called `edit-config` that ensures you always edit a properly structured configuration file. It automatically creates a local copy if one doesn't exist, copies in the latest defaults, and opens your preferred text editor.

**To edit the main configuration file:**

1. Open a terminal and navigate to your Netdata config directory:

   ```bash
   cd /etc/netdata 2>/dev/null || cd /opt/netdata/etc/netdata
   ```

2. Run the edit script for `netdata.conf`:

   ```bash
   sudo ./edit-config netdata.conf
   ```

3. Your system's default text editor will open the file. Make your changes and save.

> Always use `edit-config` rather than editing files directly. It handles safe copying of default templates and ensures your changes are applied in the right place.

### Alternative: Download the Running Configuration

If you want to start from the exact settings currently active on your agent:

```bash
cd /etc/netdata 2>/dev/null || cd /opt/netdata/etc/netdata
curl -ksSLo /tmp/netdata.conf.new http://localhost:19999/netdata.conf && sudo mv -i /tmp/netdata.conf.new netdata.conf
```

This is useful for backing up your current configuration or replicating it across multiple servers.

---

## Configuring Individual Plugins and Collectors

Beyond the main `netdata.conf` file, each data-collection plugin and collector has its own configuration file in the config directory. For example:

- **Go-based collectors** (databases, web servers, cloud services) each have their own configuration under the config directory
- You can enable, disable, or fine-tune each collector independently

### Enabling or Disabling a Collector

To disable a collector you don't need, use `edit-config` to open its specific configuration file and set `enabled = no`. Only active collectors consume resources — ones that are disabled (or that have nothing to monitor) shut down automatically and use no CPU or memory.

### Adjusting Collection Frequency per Collector

Individual collectors can be given their own update interval, overriding the global setting. This lets you collect critical metrics every second while less important services are checked every 10 or 30 seconds.

---

## Turning Off Machine Learning (ML)

Netdata includes built-in anomaly detection powered by machine learning. While powerful, it uses additional CPU. If you are running Netdata on a constrained system — or if you have a Parent-Child setup where the Parent handles ML centrally — you can turn it off on individual agents.

In `netdata.conf`:

```
[ml]
    enabled = no
```

The recommended approach is:
- **Keep ML enabled on Parent nodes** (they have full data and more resources)
- **Disable ML on Child nodes** (focus them on collecting and streaming data)

---

## Dynamic Configuration: Making Changes Through the Dashboard

If you have a **Netdata Cloud paid subscription**, you can configure collectors and alerts directly through the web interface — no command-line editing required. This is called the **Dynamic Configuration Manager**.

### What You Can Do

- Create, edit, and test collector settings through guided forms
- Set up and adjust alert rules by clicking directly on any chart
- Deploy configuration changes to multiple servers simultaneously with one click
- Validate settings before applying them, preventing errors

### How to Access It

You can reach the Dynamic Configuration Manager in several ways:

1. **From any chart** — Click the bell (alert) icon at the top of a chart to create or edit an alert for that metric
2. **From the Alerts tab** — Browse existing alerts, click one, and adjust its thresholds or conditions
3. **From the Integrations section** — Browse available collectors, find the one you want (such as MySQL or Redis), and click **Configure**
4. **From Space Settings** — Go to the Configurations section to view and manage all collector and alert configurations across your infrastructure

> Changes made through Dynamic Configuration are tracked separately from file-based configurations. Only configurations created through the Dynamic Configuration Manager can be removed through the UI; configurations that come from files on your server must be managed by editing those files.

---

## Applying Your Changes

### When a Restart Is Required

Most changes to `netdata.conf` and collector configuration files require a full restart of the Netdata Agent to take effect.

| Platform | Restart Command |
|---|---|
| Linux (systemd) | `sudo systemctl restart netdata` |
| Linux (non-systemd) | `sudo service netdata restart` |
| Windows (PowerShell) | `Restart-Service Netdata` |
| Windows (GUI) | Task Manager → Services tab → Netdata → Restart |

> **Note:** Restarting the agent causes a brief gap in your collected metrics while it reinitializes. This is normal and expected.

### Reloading Alerts Without a Restart

If you only changed **alert rules** (health configuration files), you do not need to restart the agent — which means no gaps in your metrics data. Instead, use:

```bash
sudo netdatacli reload-health
```

This command tells the running agent to reload its health configuration immediately, with no interruption to data collection.

---

## Quick Reference: Common Configuration Tasks

| Goal | What to Change | How |
|---|---|---|
| Collect metrics every 2 seconds instead of 1 | `update every = 2` in `[global]` section | `sudo ./edit-config netdata.conf` |
| Store metrics in memory only (no disk writes) | `mode = ram` in `[db]` section | `sudo ./edit-config netdata.conf` |
| Disable machine learning | `enabled = no` in `[ml]` section | `sudo ./edit-config netdata.conf` |
| Turn off a specific collector | Set `enabled = no` in that collector's config file | `sudo ./edit-config <collector>.conf` |
| Configure a service collector (e.g., MySQL) | Edit the collector's own config file | `sudo ./edit-config go.d/mysql.conf` |
| Reload alert rules without restarting | Run the reload command | `sudo netdatacli reload-health` |
| Configure via web UI (Cloud subscription) | Use the Dynamic Configuration Manager | Dashboard → Integrations or Alerts tab |

---

## Tips for Getting Started

1. **Start with `netdata.conf`** — Open it with `sudo ./edit-config netdata.conf` from your config directory. Every setting has a comment explaining what it does.
2. **Only change what you need** — Netdata's defaults are well-tuned for most environments. Focus on the settings that matter for your situation.
3. **On resource-constrained systems**, the biggest wins come from: increasing the update interval, switching child nodes to RAM mode, and disabling machine learning.
4. **Verify your config directory location** by visiting `http://YOUR-SERVER:19999/netdata.conf` in your browser if you're unsure.
5. **Always restart after making changes** (unless you only changed alert rules, in which case use `netdatacli reload-health`).