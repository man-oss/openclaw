---

## Getting Started: The API Base URL

Every Netdata Agent hosts its own API. By default, the Agent listens on port **19999**, so the base URL for any request is:

```
http://<your-agent-address>:19999/api/v1/
```

Replace `<your-agent-address>` with the hostname or IP address of the machine running Netdata. For a local installation, this is simply:

```
http://localhost:19999/api/v1/
```

A second-generation API (v2) is also available at:

```
http://localhost:19999/api/v2/
```

You can also explore the API interactively through the **[Swagger UI](https://learn.netdata.cloud/api)**, which lets you test every endpoint directly in your browser.

---

## Authentication

### Agent API (v1 and v2)

By default, many Netdata Agent API endpoints allow **anonymous access** — no credentials are required for read-only metric and alert data. This makes it straightforward to query metrics from within a private network.

If your Netdata Agent has been claimed to Netdata Cloud and bearer-token protection is enabled, you will need to include a token in your requests:

```
Authorization: Bearer <your-token>
```

### Netdata Cloud API

To use the Netdata Cloud API (for accessing data across multiple nodes), you need a personal API token:

1. Log in to [Netdata Cloud](https://app.netdata.cloud) and open your account **Settings**.
2. In the **API Tokens** section, click **+** to create a new token.
3. Select the **`scope:all`** scope to allow full access, or choose a narrower scope for specific use cases.
4. Copy and save the token immediately — it is shown only once.

Include the token in every Cloud API request:

```bash
curl -X GET "https://app.netdata.cloud/api/v2/spaces" \
  -H "Authorization: Bearer <your-token>"
```

> **Important:** Your token is sensitive. Store it securely and never expose it in public code or logs.

---

## Key API v1 Endpoints

All examples below use `http://localhost:19999` as the base address. Adjust accordingly for remote agents.

### List All Charts — `/api/v1/charts`

Returns a complete list of every metric chart (data source) the Agent is currently collecting, along with metadata such as chart title, units, type, and available dimensions.

```bash
curl "http://localhost:19999/api/v1/charts"
```

**What you get back:**
- A JSON object containing every active chart
- For each chart: its unique ID, friendly title, measurement units, chart type, update frequency, and the names of all dimensions (individual metrics) it tracks

Use this endpoint first to discover what metrics are available before querying specific data.

---

### Get Metric Data — `/api/v1/data`

Retrieves the actual time-series values for a specific chart. This is the primary endpoint for pulling metric readings into your own systems.

```bash
curl "http://localhost:19999/api/v1/data?chart=system.cpu"
```

#### Filtering by Time Range

You can specify a time window using Unix timestamps (seconds since January 1, 1970):

| Parameter | Description | Example |
|-----------|-------------|---------|
| `after` | Start of the time range | `after=1700000000` |
| `before` | End of the time range | `before=1700003600` |

To request the last hour of CPU data:

```bash
curl "http://localhost:19999/api/v1/data?chart=system.cpu&after=-3600&before=0"
```

> **Tip:** Negative values for `after` mean "N seconds ago from now." Using `after=-3600` means "starting 1 hour ago."

#### Selecting Specific Dimensions

If a chart tracks multiple metrics (for example, CPU has dimensions like `user`, `system`, `iowait`), you can request only the ones you need:

```bash
curl "http://localhost:19999/api/v1/data?chart=system.cpu&dimensions=user|system"
```

Separate multiple dimension names with a pipe character (`|`).

#### Controlling Data Aggregation and Points

| Parameter | Description | Example |
|-----------|-------------|---------|
| `points` | Number of data points to return | `points=60` |
| `group` | How to aggregate data within each point | `group=average` |
| `gtime` | Grouping time in seconds | `gtime=60` |

Available aggregation methods for `group`:
- `average` — the mean value (default)
- `sum` — total of all values
- `min` — lowest value in the window
- `max` — highest value in the window

**Example — 60 averaged data points over the last hour:**

```bash
curl "http://localhost:19999/api/v1/data?chart=system.cpu&after=-3600&before=0&points=60&group=average"
```

#### Choosing the Response Format

Add a `format` parameter to control the output structure:

| Format | Description |
|--------|-------------|
| `json` | Standard JSON (default) |
| `jsonp` | JSON with a callback wrapper |
| `csv` | Comma-separated values |
| `tsv` | Tab-separated values |
| `html` | Simple HTML table |

```bash
curl "http://localhost:19999/api/v1/data?chart=system.cpu&format=csv"
```

---

### Get Alert Status — `/api/v1/alarms`

Returns the current state of all alerts (also called alarms) configured on the Agent. This is the fastest way to programmatically check whether anything on the monitored node is in a warning or critical state.

```bash
curl "http://localhost:19999/api/v1/alarms"
```

**What you get back:**

Each alert entry includes:
- **`status`** — current state: `CLEAR`, `WARNING`, or `CRITICAL`
- **`name`** — the alert name
- **`chart`** — which chart the alert monitors
- **`value`** — the current metric value that triggered the alert
- **`units`** — measurement units
- **`info`** — a human-readable description of what the alert means
- **`last_status_change`** — when the alert last changed state

**Filter to active alerts only** (warnings and criticals):

```bash
curl "http://localhost:19999/api/v1/alarms?active=true"
```

**Related alert endpoints:**

| Endpoint | What it does |
|----------|--------------|
| `/api/v1/alarms` | Current state of all alerts |
| `/api/v1/alarms_values` | Current numeric values of all alerts |
| `/api/v1/alarm_log` | Historical log of alert state transitions |
| `/api/v1/alarm_count` | Total count of active alerts by severity |

---

### Get Agent Information — `/api/v1/info`

Returns general information about the Netdata Agent itself — useful for identifying a node and confirming it is reachable.

```bash
curl "http://localhost:19999/api/v1/info"
```

**What you get back:**
- Agent version number
- Hostname
- Operating system details
- Number of charts and dimensions currently being collected
- Memory mode and database engine status
- Whether the agent is connected to Netdata Cloud

---

### Get a Single Chart's Metadata — `/api/v1/chart`

Retrieves detailed metadata for one specific chart, including all its dimensions and configuration details.

```bash
curl "http://localhost:19999/api/v1/chart?chart=system.cpu"
```

---

## Retrieving Alert Status Programmatically

A common use case is polling the alerts endpoint to detect problems automatically. Here is a practical example using `curl` and standard command-line tools to check for any critical alerts:

```bash
curl -s "http://localhost:19999/api/v1/alarms?active=true" | \
  python3 -c "
import json, sys
data = json.load(sys.stdin)
for name, alert in data.get('alarms', {}).items():
    status = alert.get('status', '')
    if status in ('WARNING', 'CRITICAL'):
        print(f\"{status}: {name} — {alert.get('info', '')}\")
"
```

This pattern works well for:
- Automated health checks in deployment pipelines
- Feeding alert data into ticketing or incident management systems
- Custom dashboards that need real-time alert counts

---

## API v2: What's New and Different

API v2 (`/api/v2/`) is a more powerful version designed for **multi-node** environments where a single Netdata parent node aggregates data from many child nodes.

### Key Differences from v1

| Capability | API v1 | API v2 |
|------------|--------|--------|
| Scope | Single node | Multiple nodes simultaneously |
| Alert endpoint | `/api/v1/alarms` | `/api/v2/alerts` |
| Data endpoint | `/api/v1/data` | `/api/v2/data` |
| Metadata endpoint | `/api/v1/charts` | `/api/v2/contexts` |
| Full-text search | Not available | `/api/v2/q` |
| Node listing | Not available | `/api/v2/nodes` |
| Alert transitions | Not available | `/api/v2/alert_transitions` |
| Agent info | `/api/v1/info` | `/api/v2/info` (enhanced) |

### API v2 Highlights

- **`/api/v2/data`** — Query metrics across multiple nodes in a single request, with more advanced filtering and grouping options.
- **`/api/v2/alerts`** — Retrieve alert states across all connected nodes at once, rather than querying each node individually.
- **`/api/v2/contexts`** — Browse available metric types (contexts) across all nodes, replacing the per-node `/api/v1/charts`.
- **`/api/v2/q`** — Full-text search across all available metrics and contexts — helpful when you don't know the exact chart name.
- **`/api/v2/nodes`** — List all nodes visible to this agent, along with their connection status and basic metadata.
- **`/api/v2/alert_transitions`** — Review the history of how alert states have changed over time across all nodes.

### When to Use v2

Use API v2 when:
- You have a **Netdata parent** collecting data from multiple child nodes and want to query all of them together.
- You need to search for metrics without knowing exact chart names.
- You need historical alert transition data across your entire infrastructure.

Use API v1 when:
- You are querying a **standalone Netdata Agent** on a single machine.
- You need maximum compatibility with older integrations.

---

## Practical Examples

### Check if a Node is Up
```bash
curl -s "http://localhost:19999/api/v1/info" | python3 -c "import json,sys; d=json.load(sys.stdin); print('Up:', d.get('version','unknown'))"
```

### Get Current CPU Usage (Last 10 Seconds)
```bash
curl -s "http://localhost:19999/api/v1/data?chart=system.cpu&after=-10&before=0&points=1&group=average"
```

### List All Available Charts
```bash
curl -s "http://localhost:19999/api/v1/charts" | python3 -c "import json,sys; charts=json.load(sys.stdin)['charts']; [print(k) for k in sorted(charts.keys())]"
```

### Get All Active Alerts
```bash
curl -s "http://localhost:19999/api/v1/alarms?active=true"
```

### Export Last Hour of Network Traffic as CSV
```bash
curl "http://localhost:19999/api/v1/data?chart=system.net&after=-3600&before=0&format=csv" > network_traffic.csv
```

---

## Interactive API Explorer

The easiest way to discover all available parameters and try requests before writing any automation is the **Swagger UI**:

- **[Interactive Explorer](https://learn.netdata.cloud/api)** — Browse and test every API v1 and v2 endpoint
- **[Cloud API Explorer](https://app.netdata.cloud/api/docs/)** — Browse and test Netdata Cloud API endpoints

The interactive explorer shows all available parameters, their valid values, and lets you run live requests against your own agent directly from the browser.