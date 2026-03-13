---

## Before You Begin

Netdata runs on **Linux, macOS, FreeBSD, and Windows**. The commands below require a terminal (command-line) window and an internet connection. Most installations finish in under 5 minutes.

> **What you'll have at the end:** A running Netdata agent automatically collecting hundreds of metrics from your system, and a live dashboard you can open in any web browser.

---

## Option 1 — One-Line Kickstart (Recommended for Linux)

The fastest way to install Netdata on any Linux system is a single command. Open your terminal and run:

```bash
wget -O /tmp/netdata-kickstart.sh https://get.netdata.cloud/kickstart.sh && sh /tmp/netdata-kickstart.sh
```

Or, if you prefer `curl`:

```bash
curl https://get.netdata.cloud/kickstart.sh > /tmp/netdata-kickstart.sh && sh /tmp/netdata-kickstart.sh
```

**What this does:**

- Detects your Linux distribution automatically
- Installs the best available package for your system (native package, static build, or compiled from source — whichever works best)
- Starts the Netdata service immediately
- Enables automatic updates by default
- Requires no extra configuration — monitoring begins right away

> **Privacy note:** The installer collects anonymous usage statistics to help improve Netdata. To opt out, add `--disable-telemetry` to the end of the command, or create the file `/etc/netdata/.opt-out-from-anonymous-statistics` and restart Netdata.

---

## Option 2 — Install via Netdata Cloud (Easiest Setup)

If you want your agent connected and visible from anywhere right away:

1. Go to [app.netdata.cloud](https://app.netdata.cloud/) and sign in (free account required).
2. Open your Space and click the **"Connect Nodes"** prompt.
3. Select your platform — the exact install command for your system will appear.
4. Copy and paste that command into your terminal and run it.

Your node will appear live in Netdata Cloud as soon as installation finishes.

---

## Option 3 — Package Manager Installation

If you prefer managing software through your system's package manager, use the commands below.

### Ubuntu & Debian (apt)

```bash
# Add the Netdata repository and install
wget -O /tmp/netdata-kickstart.sh https://get.netdata.cloud/kickstart.sh && \
  sh /tmp/netdata-kickstart.sh --native-only
```

This uses the official Netdata repository for `apt`-based systems and installs the native `.deb` package.

### CentOS, RHEL, AlmaLinux, Rocky Linux (yum / dnf)

```bash
wget -O /tmp/netdata-kickstart.sh https://get.netdata.cloud/kickstart.sh && \
  sh /tmp/netdata-kickstart.sh --native-only
```

This adds the official Netdata `.rpm` repository and installs using `yum` or `dnf`, whichever is available on your system.

### openSUSE (zypper)

```bash
wget -O /tmp/netdata-kickstart.sh https://get.netdata.cloud/kickstart.sh && \
  sh /tmp/netdata-kickstart.sh --native-only
```

The kickstart script detects openSUSE and uses `zypper` to install from the official Netdata repository.

> **Tip:** The `--native-only` flag tells the installer to use your system's package manager exclusively, rather than falling back to a static binary or source build.

---

## Option 4 — Docker Container

Running Netdata in a Docker container is ideal for containerized environments or when you prefer not to install software directly on the host.

### Using `docker run`

Run this single command in your terminal:

```bash
docker run -d --name=netdata \
  --pid=host \
  --network=host \
  -v netdataconfig:/etc/netdata \
  -v netdatalib:/var/lib/netdata \
  -v netdatacache:/var/cache/netdata \
  -v /:/host/root:ro,rslave \
  -v /etc/passwd:/host/etc/passwd:ro \
  -v /etc/group:/host/etc/group:ro \
  -v /etc/localtime:/etc/localtime:ro \
  -v /proc:/host/proc:ro \
  -v /sys:/host/sys:ro \
  -v /etc/os-release:/host/etc/os-release:ro \
  -v /var/log:/host/var/log:ro \
  -v /var/run/docker.sock:/var/run/docker.sock:ro \
  -v /run/dbus:/run/dbus:ro \
  --restart unless-stopped \
  --cap-add SYS_PTRACE \
  --cap-add SYS_ADMIN \
  --security-opt apparmor=unconfined \
  netdata/netdata
```

### Using Docker Compose

Create a file named `docker-compose.yml` with the following content, then run `docker-compose up -d` in the same folder:

```yaml
version: '3'
services:
  netdata:
    image: netdata/netdata
    container_name: netdata
    pid: host
    network_mode: host
    restart: unless-stopped
    cap_add:
      - SYS_PTRACE
      - SYS_ADMIN
    security_opt:
      - apparmor:unconfined
    volumes:
      - netdataconfig:/etc/netdata
      - netdatalib:/var/lib/netdata
      - netdatacache:/var/cache/netdata
      - /:/host/root:ro,rslave
      - /etc/passwd:/host/etc/passwd:ro
      - /etc/group:/host/etc/group:ro
      - /etc/localtime:/etc/localtime:ro
      - /proc:/host/proc:ro
      - /sys:/host/sys:ro
      - /etc/os-release:/host/etc/os-release:ro
      - /var/log:/host/var/log:ro
      - /var/run/docker.sock:/var/run/docker.sock:ro
      - /run/dbus:/run/dbus:ro

volumes:
  netdataconfig:
  netdatalib:
  netdatacache:
```

**Available image versions:**

| Tag | What it installs |
|---|---|
| `netdata/netdata` (no tag) | Latest available build |
| `netdata/netdata:stable` | Most recent stable release |
| `netdata/netdata:edge` | Latest nightly build |
| `netdata/netdata:vX.Y.Z` | A specific version (e.g., `v2.1.0`) |

> **Note:** For full monitoring of all host resources, containers, and network interfaces, the full volume and privilege configuration shown above is needed. A reduced set of capabilities can be used for [rootless Docker](https://docs.docker.com/engine/security/rootless/) environments, but some metrics will be unavailable.

---

## Option 5 — Other Platforms

Netdata supports several other environments. Follow the dedicated guide for your platform:

| Platform | Guide |
|---|---|
| **macOS** | [macOS Installation](https://learn.netdata.cloud/docs/installing/macos) |
| **FreeBSD** | [FreeBSD Installation](https://learn.netdata.cloud/docs/installing/freebsd) |
| **Windows** | [Windows Installation](https://learn.netdata.cloud/docs/netdata-agent/installation/windows) |
| **Kubernetes** | [Kubernetes Setup](https://learn.netdata.cloud/docs/installation/install-on-specific-environments/kubernetes) |
| **Ansible** | Automate deployment across many servers |
| **AWS / Azure / GCP** | Cloud-specific deployment guides available at [Netdata Learn](https://learn.netdata.cloud) |

---

## Option 6 — Build from Source (Advanced)

Building from source gives you complete control over the installation and is useful in environments without internet access or when running on uncommon hardware.

**General steps:**

1. Clone or download the Netdata source code from [github.com/netdata/netdata](https://github.com/netdata/netdata).
2. Install the required build tools for your operating system (the kickstart script can install these automatically using the `--prepare-only` flag).
3. Run the build process from the source directory.
4. Start the Netdata service once the build completes.

> **Recommendation:** For most users, the kickstart script (Option 1) is strongly preferred. It handles all dependencies and configuration automatically. Build from source only when necessary.

---

## Step 5 — Verify Your Installation and Open the Dashboard

Once installation is complete (regardless of which method you used), check that Netdata is running:

```bash
systemctl status netdata
```

You should see output showing the service as **active (running)**.

### Open the Dashboard

Open any web browser on the same machine and go to:

```
http://localhost:19999
```

If you're accessing from another computer on the same network, replace `localhost` with the IP address or hostname of the machine where Netdata is installed:

```
http://YOUR-SERVER-IP:19999
```

You will see the Netdata dashboard with live charts already populating with data from your system — no additional setup required.

---

## What You'll See on the Dashboard

The dashboard starts collecting and displaying data immediately after installation:

- **System Overview** — CPU, memory, disk, and network usage at a glance
- **Per-Second Charts** — All metrics update every second in real time
- **Automatic Alerts** — Hundreds of pre-configured health alerts are already active
- **Application Monitoring** — Any services running on your system (databases, web servers, etc.) are automatically detected and shown

---

## Troubleshooting

**Dashboard isn't loading?**
- Make sure port `19999` is not blocked by a firewall. On Linux with `firewalld`, run: `firewall-cmd --add-port=19999/tcp --permanent && firewall-cmd --reload`
- With `ufw`, run: `ufw allow 19999`

**Netdata service isn't running?**
- Try restarting it: `systemctl restart netdata`
- Check logs for errors: `journalctl -u netdata --since "5 minutes ago"`

**Installed in Docker and can't reach the dashboard?**
- The recommended Docker setup uses `--network=host`, which means the dashboard is at `http://localhost:19999` on the host machine directly.

---

## Next Steps

Now that your agent is running, here's what to explore next:

- **Connect to Netdata Cloud** — Sign in at [app.netdata.cloud](https://app.netdata.cloud) to access your dashboard from anywhere, set up alerts, and monitor multiple servers from one place. Netdata Cloud is free and optional — your data always stays on your own infrastructure.
- **Set up alert notifications** — Send alerts to Slack, email, PagerDuty, Discord, Microsoft Teams, and more.
- **Monitor more services** — Browse the 800+ available integrations at [Netdata Learn](https://learn.netdata.cloud/docs/data-collection/).
- **Add more servers** — Repeat the installation on any additional machine you want to monitor.

> **Full documentation:** [learn.netdata.cloud](https://learn.netdata.cloud)