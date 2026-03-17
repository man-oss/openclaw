# How to Collect Metrics with Plugins

Netdata automatically starts collecting data the moment it is installed. A built-in collection engine called **go.d.plugin** handles hundreds of services, databases, and infrastructure components — often without any setup required. This guide explains how that automatic detection works, how to browse and manage available collectors, and how to configure collection for specific services like MySQL or Nginx.

---

## How Auto-Detection Works

When Netdata starts, go.d.plugin tries to connect to well-known default locations for each service it knows about. For example, it will attempt to reach MySQL on `localhost:3306`, Nginx on `localhost:80`, Redis on `localhost:6379`, and so on.

If the service is running and accessible at its default address, Netdata begins collecting metrics immediately — no configuration needed.

**What gets detected automatically:**
- Services running on their default ports on the same machine
- Services already accessible without authentication (or with default credentials)
- Services that expose standard status endpoints (such as Nginx's `stub_status` or Apache's `mod_status`)

If your service is running on a non-standard port, requires credentials, or runs on a remote host, you will need to configure it manually (covered in the [Configuring a Collector](#configuring-a-collector-for-a-specific-service) section below).

---

## Browsing Available Collectors

Netdata's go.d.plugin includes collectors for a wide range of technologies, organized into the following categories:

| Category | Examples |
|---|---|
| **Databases** | MySQL, PostgreSQL, MongoDB, Redis, Cassandra, ClickHouse, CouchDB, Elasticsearch |
| **Web Servers & Proxies** | Apache, Nginx, Nginx Plus, HAProxy, Lighttpd, Traefik, Varnish, Squid |
| **Containers & VMs** | Docker, Kubernetes (Kubelet, Kube-proxy, cluster state), VMware vCenter |
| **Networking** | WireGuard, SNMP, DNS Query, NTP, CoreDNS, Unbound, Bind |
| **Message Queues** | RabbitMQ, ActiveMQ, NATS, Kafka (via Prometheus), Apache Pulsar |
| **Hardware & Sensors** | Nvidia GPU, Intel GPU, Hardware RAID (Adaptec, MegaCLI, HPE), S.M.A.R.T drives, NVMe, UPS |
| **Storage** | LVM, ZFS Pools, HDFS, Ceph |
| **Cloud & DevOps** | Consul, Puppet, Logstash, Fluentd |
| **Synthetic Testing** | HTTP endpoint checks, TCP port checks, Ping, Domain expiry, SSL certificate checks |
| **Applications** | PHP-FPM, Tomcat, Supervisor, systemd units, Fail2Ban, Pi-hole |

The complete list of collectors — over 100 in total — is maintained in Netdata's go.d plugin. Each collector can run multiple independent jobs, so you can monitor several instances of the same service (for example, two separate MySQL servers) simultaneously.

---

## Enabling or Disabling a Collector

By default, most collectors are enabled and will activate automatically if their target service is detected. You can explicitly enable or disable any collector in the main plugin configuration file.

### Step 1 — Open the plugin configuration file

Navigate to your Netdata configuration directory (usually `/etc/netdata`) and open `go.d.conf` for editing:

```bash
cd /etc/netdata
sudo ./edit-config go.d.conf
```

### Step 2 — Enable or disable a specific collector

Inside the file, find the `modules` section. Each collector can be turned on or off by setting it to `yes` or `no`:

```yaml
# Enable/disable the whole plugin
enabled: yes

# Default enable/disable for all collectors
default_run: yes

# Override individual collectors:
modules:
  mysql: yes
  nginx: yes
  example: no
```

- To **enable** a collector: add its name under `modules` and set it to `yes`
- To **disable** a collector: set it to `no`
- Lines beginning with `#` are comments and have no effect

### Step 3 — Restart Netdata

After saving the file, restart Netdata for the changes to take effect:

```bash
sudo systemctl restart netdata
```

---

## Configuring a Collector for a Specific Service

Each collector has its own configuration file located in the `go.d/` folder inside your Netdata configuration directory. These files follow a consistent YAML structure with global settings and one or more "jobs" (individual service instances to monitor).

### General configuration structure

Every collector configuration file looks like this:

```yaml
# How often to collect data (in seconds)
update_every: 1

# How many times to retry auto-detection before giving up
autodetection_retry: 0

# List of service instances to monitor
jobs:
  - name: local
    host: localhost
    port: 3306

  - name: production-db
    host: 192.168.1.50
    port: 3306
    user: netdata
    password: secret
```

Each `job` is a named instance. You can define as many jobs as you need.

### Example: Configuring MySQL

1. Open the MySQL collector configuration:

   ```bash
   cd /etc/netdata
   sudo ./edit-config go.d/mysql.conf
   ```

2. Add a job for your MySQL instance:

   ```yaml
   jobs:
     - name: local
       dsn: netdata@tcp(127.0.0.1:3306)/

     - name: production
       dsn: netdata:mypassword@tcp(192.168.1.10:3306)/
   ```

3. Restart Netdata:

   ```bash
   sudo systemctl restart netdata
   ```

### Example: Configuring Nginx

Nginx monitoring requires the `stub_status` module to be enabled in your Nginx configuration. Once enabled, configure the collector:

1. Open the Nginx collector configuration:

   ```bash
   cd /etc/netdata
   sudo ./edit-config go.d/nginx.conf
   ```

2. Add a job pointing to your Nginx status URL:

   ```yaml
   jobs:
     - name: local
       url: http://127.0.0.1/stub_status

     - name: remote-server
       url: http://192.168.1.20/stub_status
   ```

3. Restart Netdata.

### Tip: Auto-detection retry

If your service isn't running yet when Netdata starts, set `autodetection_retry` to a positive number of seconds. Netdata will keep retrying until the service becomes available:

```yaml
autodetection_retry: 60
```

---

## Verifying That a Collector Is Active

### Check the Netdata Dashboard

The quickest way to confirm a collector is working is to open the Netdata Dashboard in your browser (typically at `http://localhost:19999`). If a collector is active, its charts will appear under the relevant section — for example, MySQL metrics appear under the **MySQL** section, Nginx metrics appear under **Nginx**, and so on.

If charts for your service are missing, the collector is either disabled or failed to connect.

### Run the Plugin in Debug Mode

For a detailed look at what a specific collector is doing, run go.d.plugin in debug mode from the command line.

First, switch to the Netdata user:

```bash
sudo su -s /bin/bash netdata
```

Then run the plugin with the `-d` (debug) flag and specify the collector name with `-m`:

```bash
# Standard installation
/usr/libexec/netdata/plugins.d/go.d.plugin -d -m mysql

# Static/opt installation
/opt/netdata/usr/libexec/netdata/plugins.d/go.d.plugin -d -m nginx
```

The debug output will show:
- Whether the collector successfully connected to the service
- What data was collected
- Any errors or connection failures

This is the most reliable way to diagnose why a collector might not be running.

### Common reasons a collector might not be active

| Symptom | Likely cause |
|---|---|
| No charts in the dashboard | Collector disabled, or service not running |
| Charts appeared then disappeared | Service became unreachable |
| Debug shows "connection refused" | Wrong host/port in the job configuration |
| Debug shows "authentication failed" | Incorrect credentials in the configuration file |
| Collector not listed at all | The go.d plugin itself may not be running |

---

## Quick Reference

| Task | How to do it |
|---|---|
| See all available collectors | Review the table in the **Available Collectors** section above |
| Enable or disable a collector | Edit `go.d.conf`, set the module to `yes` or `no`, then restart Netdata |
| Configure a specific service | Edit the matching file in `go.d/<collector>.conf`, add jobs, then restart |
| Verify a collector is working | Open the Netdata Dashboard and look for the service's charts |
| Debug a collector | Run go.d.plugin with `-d -m <collector_name>` as the netdata user |
| Apply any configuration change | `sudo systemctl restart netdata` |