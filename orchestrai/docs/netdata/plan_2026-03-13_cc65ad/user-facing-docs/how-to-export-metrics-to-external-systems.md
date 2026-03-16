---

## What You Can Do

- Send metrics to **multiple destinations simultaneously**, each with its own settings
- Control **how often** metrics are exported per destination
- Choose **how values are calculated** (raw, averaged, or summed)
- **Filter** which machines and charts get exported
- Monitor whether exports are succeeding from within Netdata itself

---

## Supported Destinations

Netdata's exporting engine supports the following external systems out of the box:

| Destination | Best For |
|:---|:---|
| **Graphite** | Carbon/Graphite stacks, Grafana with Graphite backend |
| **OpenTSDB** | OpenTSDB via plain text or HTTP/HTTPS |
| **Prometheus Remote Write** | Cortex, Thanos, Mimir, Victoria Metrics, and any Prometheus-compatible backend |
| **JSON Databases** | Any database accepting JSON over TCP |
| **MongoDB** | Document-based storage |
| **AWS Kinesis** | Amazon Kinesis Data Streams |
| **Google Pub/Sub** | Google Cloud Pub/Sub messaging |
| **TimescaleDB** | PostgreSQL-based time-series storage |

> **Note:** When you first enable exporting, Netdata sends metrics starting from the moment the agent restarts — not historical data from before that point.

---

## Before You Begin

Make sure Netdata is already installed and running on your system. You will need to edit a configuration file called **exporting.conf**, which controls all export behavior.

To open this file for editing, run the following command from your Netdata configuration directory:

```bash
sudo /etc/netdata/edit-config exporting.conf
```

---

## Step 1: Turn On the Exporting Engine

The exporting engine is off by default. Find the `[exporting:global]` section at the top of `exporting.conf` and change `enabled = no` to `enabled = yes`:

```text
[exporting:global]
    enabled = yes
```

Save the file. This activates the engine but doesn't send data anywhere yet — you still need to configure at least one destination connector.

---

## Step 2: Add a Connector for Your Destination

Each destination you want to send metrics to needs its own section in `exporting.conf`. Copy the relevant example below, paste it into the file, and fill in your details.

### Graphite

```text
[graphite:my_graphite]
    enabled = yes
    destination = 10.0.0.5:2003
    data source = average
    prefix = netdata
    update every = 10
```

### OpenTSDB (HTTP)

```text
[opentsdb:http:my_opentsdb]
    enabled = yes
    destination = 10.0.0.5:4242
    data source = average
    update every = 10
```

### OpenTSDB (plain text)

```text
[opentsdb:my_opentsdb_telnet]
    enabled = yes
    destination = 10.0.0.5:4242
```

### Prometheus Remote Write

```text
[prometheus_remote_write:my_prometheus]
    enabled = yes
    destination = 10.0.0.5
    remote write URL path = /receive
    data source = average
    update every = 10
```

### MongoDB

```text
[mongodb:my_mongodb]
    enabled = yes
    destination = localhost
    database = netdata_metrics
    collection = metrics
```

### AWS Kinesis

```text
[kinesis:my_kinesis]
    enabled = yes
    destination = us-east-1
    stream name = netdata
    aws_access_key_id = YOUR_ACCESS_KEY
    aws_secret_access_key = YOUR_SECRET_KEY
```

### Google Pub/Sub

```text
[pubsub:my_pubsub]
    enabled = yes
    destination = pubsub.googleapis.com
    credentials file = /etc/netdata/pubsub_credentials.json
    project id = my_gcp_project
    topic id = netdata_metrics
```

**Tip:** Replace the section name (e.g., `my_graphite`, `my_prometheus`) with any descriptive name you like. You can add multiple sections of the same type to export to different servers — just use different names.

---

## Step 3: Choose How Values Are Exported

The `data source` setting controls what value is sent for each metric. Set it inside any connector section:

| Setting | What It Sends | Use When |
|:---|:---|:---|
| `as-collected` | Exact raw values, in the format the system originally produced them | You are an expert in the destination system and want to handle unit conversion yourself |
| `average` | The average value over the export interval, in Netdata's standard units | You want values that match what you see in Netdata's dashboards |
| `sum` | The total (sum) of values over the export interval | You want to track cumulative totals over time |

**Example:**

```text
data source = average
```

For most users, `average` is the simplest and most consistent choice.

---

## Step 4: Set the Export Frequency

The `update every` setting controls how often (in seconds) metrics are sent to that destination:

```text
update every = 10
```

- The default is **10 seconds**
- You can set different intervals for different destinations
- Setting different intervals across destinations helps prevent all connectors from running at the same time, which saves CPU

---

## Step 5: Filter Which Metrics Are Exported

By default, all metrics from all charts and all monitored machines are exported. You can narrow this down using two filters.

### Filter by machine (host)

```text
send hosts matching = localhost *
```

- `*` matches all hosts
- `!webserver*` excludes any host whose name starts with "webserver"
- Multiple patterns are separated by spaces
- Patterns are matched in order — the first match wins

**Example — export everything except staging machines:**

```text
send hosts matching = !*staging* *
```

### Filter by chart (metric group)

```text
send charts matching = *
```

**Example — export only system-level metrics:**

```text
send charts matching = system.*
```

**Example — export everything except disk I/O:**

```text
send charts matching = !disk* *
```

---

## Step 6: Send Human-Readable Names

By default, Netdata uses short system IDs for metric names. To send friendlier names instead:

```text
send names instead of ids = yes
```

This makes it easier to read and query your metrics in the destination system.

---

## Step 7: Include Labels (Optional)

Labels add extra context to each metric, such as operating system, architecture, or any custom tags you have assigned to a host.

```text
send configured labels = yes
send automatic labels = yes
```

- **Configured labels** are custom labels you've set in `netdata.conf` under `[host labels]`
- **Automatic labels** are system-detected tags like `_os_name` and `_architecture`

---

## Step 8: Restart Netdata

After saving your changes to `exporting.conf`, restart the Netdata agent for the settings to take effect:

```bash
sudo systemctl restart netdata
```

Or, on systems without systemd:

```bash
sudo service netdata restart
```

Metrics will begin flowing to your destination within seconds of the restart.

---

## Using the Prometheus Remote Write Exporter

The Prometheus remote write connector sends metrics to any platform that supports the Prometheus remote write protocol — including Cortex, Thanos, Mimir, and Victoria Metrics.

**Minimal configuration:**

```text
[prometheus_remote_write:my_remote_write]
    enabled = yes
    destination = my-remote-write-host
    remote write URL path = /receive
```

**With authentication:**

```text
[prometheus_remote_write:my_remote_write]
    enabled = yes
    destination = my-remote-write-host
    remote write URL path = /receive
    username = my_username
    password = my_password
    data source = average
    update every = 10
    send names instead of ids = yes
    send charts matching = *
```

**For HTTPS endpoints**, use the `prometheus_remote_write:https` connector type:

```text
[prometheus_remote_write:https:my_remote_write]
    enabled = yes
    destination = my-secure-host:443
    remote write URL path = /api/v1/write
    username = my_username
    password = my_password
```

---

## Verifying Metrics Are Arriving

### Check the Netdata monitoring charts

Netdata tracks the health of its own exporting engine. Navigate to the **Netdata Monitoring** section of your Netdata dashboard to find these charts:

| Chart | What It Shows |
|:---|:---|
| **Buffered metrics** | How many metrics are queued for sending |
| **Exporting data size** | How much data (in KB) is being prepared |
| **Exporting operations** | How many send operations have been performed |
| **Exporting thread CPU usage** | How much CPU the export process is using |

### Built-in alerts

Netdata automatically triggers alerts if exporting is not working properly:

| Alert | Triggered When |
|:---|:---|
| **exporting_last_buffering** | Too many seconds have passed since the last successful buffer write |
| **exporting_metrics_sent** | The percentage of successfully sent metrics drops too low |
| **exporting_metrics_lost** | Metrics are being dropped due to repeated connection failures |

If you see these alerts firing, check that your destination server is reachable from the Netdata host and that the `destination` address in your connector section is correct.

### Check directly in the destination system

- **Graphite / Grafana:** Open the Graphite web UI or Grafana and browse for metrics starting with your configured `prefix` (default: `netdata`)
- **OpenTSDB:** Query for metrics starting with your prefix using the OpenTSDB HTTP API or UI
- **Prometheus Remote Write targets:** Check your Prometheus-compatible backend (e.g., Cortex, Thanos) for incoming series labeled with the Netdata host name
- **MongoDB:** Query your configured database and collection for recent documents
- **AWS Kinesis:** Check your Kinesis stream for records in the AWS console

---

## Complete Example: Exporting to Graphite and Prometheus Simultaneously

You can run multiple connectors at the same time. Here is a complete `exporting.conf` example that sends data to both Graphite and a Prometheus remote write endpoint:

```text
[exporting:global]
    enabled = yes

[graphite:production_graphite]
    enabled = yes
    destination = 10.0.0.10:2003
    data source = average
    prefix = netdata
    update every = 10
    send names instead of ids = yes
    send charts matching = *
    send hosts matching = *

[prometheus_remote_write:https:production_prometheus]
    enabled = yes
    destination = prometheus.mycompany.com:443
    remote write URL path = /api/v1/write
    username = netdata
    password = secret
    data source = average
    update every = 15
    send names instead of ids = yes
    send charts matching = system.* disk.* net.*
    send hosts matching = *
```

In this example:
- Graphite receives all metrics every 10 seconds
- The Prometheus endpoint receives only system, disk, and network metrics every 15 seconds, over HTTPS with authentication
- The different `update every` values (10 vs. 15) prevent both connectors from processing at the same time

---

## Troubleshooting

| Problem | What to Check |
|:---|:---|
| No data appears in the destination | Verify `enabled = yes` is set in both `[exporting:global]` and your connector section, and that Netdata was restarted |
| Connection refused errors | Confirm the destination host and port are correct and reachable from the Netdata host |
| Only some metrics appear | Review your `send charts matching` and `send hosts matching` filters |
| High CPU usage | Set different `update every` values across connectors to stagger their processing |
| Metrics stop arriving after a network outage | Adjust `buffer on failures` to a higher number to retain more metrics during temporary outages |