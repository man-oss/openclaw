---

## Supported Operating Systems

### Linux — Fully Supported (Recommended)

Netdata runs best on Linux. The following distributions are fully tested and receive the highest level of support, including official installation packages:

**Ubuntu**
- 26.04, 25.10, 24.04, 22.04 (64-bit x86, ARM 64-bit, ARMv7)

**Debian**
- 13.x, 12.x, 11.x (64-bit x86, 32-bit x86, ARMv7, ARM 64-bit)

**Red Hat Enterprise Linux (RHEL)**
- 9.x, 8.x (64-bit x86, ARM 64-bit)
- 7.x (64-bit x86)

**Alma Linux**
- 9.x, 8.x (64-bit x86, ARM 64-bit) — also supports Rocky Linux and other compatible RHEL derivatives

**Rocky Linux**
- 10.x, 9.x, 8.x (64-bit x86, ARM 64-bit)

**Oracle Linux**
- 10.x, 9.x, 8.x (64-bit x86, ARM 64-bit)

**Amazon Linux**
- 2023 and 2 (64-bit x86, ARM 64-bit)

**Fedora**
- 43, 42 (64-bit x86, ARM 64-bit)

**openSUSE**
- Tumbleweed, Leap 16.0, Leap 15.6 (64-bit x86, ARM 64-bit)

**CentOS**
- 7.x (64-bit x86)

**Alpine Linux**
- 3.23, 3.22 (used as the base for official Docker images)

> **Note:** Linux distributions often include their own older versions of Netdata in their software repositories. These packages may be outdated or missing features. We strongly recommend using Netdata's official installation method instead.

### Linux — Additionally Supported

The following Linux distributions are also supported, though not as rigorously tested:

- **Arch Linux** (latest) — official community packages are available and recommended
- **Manjaro Linux** (latest) — use the Arch Linux community packages
- **Alpine Linux Edge**

### Community-Supported Linux Distributions

These distributions work with Netdata but rely primarily on community contributions for support:

- **Clear Linux** (latest)
- **Gentoo** (latest)
- **Debian Sid** and **Fedora Rawhide** (development/unstable branches)

---

## macOS

Netdata can run on macOS with community-level support. **Homebrew** must be installed first to provide required dependencies.

| macOS Version | Notes |
|---|---|
| macOS 13 (Ventura) | Intel-based hardware only |
| macOS 12 (Monterey) | Intel-based hardware only |
| macOS 11 (Big Sur) | Intel-based hardware only |

> **Important:** macOS support currently works only on Intel-based Macs. Apple Silicon (M1/M2/M3) is not officially supported at this time.

---

## FreeBSD

| Version | How to Install |
|---|---|
| FreeBSD 13-STABLE | Via the FreeBSD Ports Tree (recommended) |

FreeBSD is community-supported. The FreeBSD Ports Tree is the recommended way to install Netdata on this platform.

---

## Windows

Netdata supports Windows for monitoring purposes. Visit the [Windows installation guide](https://learn.netdata.cloud/docs/netdata-agent/installation/windows) for setup instructions.

On Windows, you can monitor system resources (CPU, memory, storage, network), processes, hardware sensors, Windows Event Logs, ETW (Event Tracing for Windows), Hyper-V virtual machines, and packaged applications.

---

## Containers and Kubernetes

### Docker

Netdata runs as a Docker container and is officially supported on **Docker version 19.03 or newer**.

Official Docker images are available for:
- 64-bit x86 (amd64)
- ARMv7 (32-bit ARM)
- ARM 64-bit (aarch64)

### Kubernetes

Netdata supports Kubernetes deployments. See the [Kubernetes setup guide](https://learn.netdata.cloud/docs/installation/install-on-specific-environments/kubernetes) for detailed instructions.

---

## Hardware Requirements

Netdata is one of the most resource-efficient monitoring tools available. Below are the hardware requirements based on your monitoring needs.

### Minimum Requirements (Single Server, Light Usage)

| Resource | Minimum |
|---|---|
| CPU | Any modern single-core processor |
| RAM | ~100 MB (with ML and alerts disabled, ephemeral storage) |
| Disk Space | Minimal (can run entirely in RAM or stream to a parent node) |

### Typical Requirements (Single Server, Full Features)

| Resource | Usage |
|---|---|
| CPU | ~3–5% of a single core with machine learning enabled |
| RAM | ~150–200 MB |
| Disk Space | ~4 GB total (3 GB for metrics + metadata and databases) |
| Disk I/O | Very low — approximately 5 KB/s writes |

> Netdata flushes data to disk roughly every 17 minutes, spreading I/O evenly so there are no constant write spikes.

### Production Server (With Active Workloads)

| Resource | Typical Usage |
|---|---|
| CPU | 5%–20% of a single core |
| RAM | 250–350 MB |
| Disk Space | ~4 GB (3 GB metrics + metadata) |
| Disk I/O | ~10 KB/s reads and writes |

### Data Retention and Disk Space

Netdata stores data across three resolution tiers by default, with a total default limit of **3 GB** for metrics:

| Tier | Resolution | Default Retention |
|---|---|---|
| Tier 0 | Per-second | Up to 14 days (within 1 GB) |
| Tier 1 | Per-minute | Up to 3 months (within 1 GB) |
| Tier 2 | Per-hour | Up to 2 years (within 1 GB) |

Retention limits are fully adjustable. More disk space means longer retention automatically — no manual configuration needed.

### Scaling to Many Servers (Parent Node)

When using Netdata to aggregate data from many machines into a central "Parent" node, hardware needs scale with the number of metrics:

- Parent nodes can handle **millions of metrics per second** with appropriate hardware
- Netdata Cloud can be used alongside Parents for virtually unlimited horizontal scaling

---

## Network Requirements

### Port Used by Netdata

By default, the Netdata dashboard is accessible on **port 19999** (TCP). Once installed, you can open a browser and visit:

```
http://your-server-address:19999
```

If you want to allow access to the dashboard from other computers on your network, ensure **port 19999 is open** in your firewall settings for inbound TCP connections.

### Connecting to Netdata Cloud (Optional)

If you choose to connect your Netdata installation to **Netdata Cloud** for remote access and multi-server dashboards, your server needs outbound internet access to reach Netdata's cloud services. No inbound ports need to be opened for Cloud connectivity — all communication is initiated outbound from your server.

Netdata Cloud connection is entirely optional. Your monitoring data always stays on your own servers.

### Streaming Between Servers (Parent-Child Setup)

If you set up multiple Netdata installations where child nodes stream data to a Parent node, the child nodes need outbound network access to the Parent on whatever port you configure (default: **19999** TCP).

---

## Required System Permissions

### Running Netdata

Netdata creates a dedicated system user account (typically called `netdata`) during installation. This account runs the Netdata service and does not require administrator (root) privileges for normal operation.

However, **root or sudo access is required during the initial installation** to set up the service and configure system access.

### What Netdata Accesses on Your System

To collect metrics, the Netdata service needs read access to system information. This is handled automatically during installation. Specifically, Netdata reads from standard operating system interfaces to gather data about CPU, memory, disk, network, and running processes.

Some advanced monitoring features (such as eBPF-based network connection tracking on Linux) require elevated kernel-level access, which is configured automatically during installation.

---

## Processor Architecture Support

Netdata provides ready-to-install packages and static (self-contained) builds for the following processor types:

| Architecture | Description |
|---|---|
| x86_64 / amd64 | Standard 64-bit Intel/AMD desktop and server processors |
| AArch64 / arm64 | 64-bit ARM (including Raspberry Pi 4+, AWS Graviton, Apple Silicon via Linux) |
| ARMv7 | 32-bit ARM (older Raspberry Pi models, embedded devices) |
| ARMv6 | Older ARM devices |
| i386 | 32-bit x86 (Debian only) |

---

## What Is NOT Yet Supported

- **Apple Silicon (M1/M2/M3) Macs** running macOS natively — only Intel Macs are supported for macOS
- **NixOS** — not officially supported (NixOS maintainers provide their own community packages)
- **eBPF features and IPMI hardware sensor monitoring** are not available when using the self-contained static installer

---

## Quick Compatibility Checklist

Use this checklist before installing:

- [ ] My operating system is listed as a supported platform above
- [ ] My server has at least 150–200 MB of available RAM
- [ ] My server has at least 5 GB of free disk space (for metrics storage and system overhead)
- [ ] Port 19999 is available (or I'm prepared to use a different port)
- [ ] I have root/administrator access for the initial installation
- [ ] If connecting to Netdata Cloud: my server has outbound internet access

If all boxes are checked, you're ready to [install Netdata](https://learn.netdata.cloud/docs/installing/one-line-installer-for-all-linux-systems).