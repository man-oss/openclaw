---

## What Is Anomaly Detection?

Netdata's anomaly detection watches every metric your system collects — CPU usage, memory, disk activity, network traffic, application metrics, and more — and uses a self-training model to understand each metric's normal behavior patterns. When a metric starts behaving unexpectedly, Netdata marks it as **anomalous** in real time.

This happens automatically, on your own machine, with no data sent to the cloud and no manual configuration required.

---

## How the ML Models Train Automatically

Netdata trains a separate machine learning model for **every individual metric** it collects. Training is fully automatic and requires no input from you.

### What happens under the hood (in plain terms):

- Every 3 hours, Netdata trains a new model for each metric, using the last 6 hours of that metric's history as a reference for "normal."
- Netdata keeps the **18 most recent models** for each metric — spanning roughly 54 hours of learned behavior.
- When new data arrives, it is checked against **all 18 models simultaneously**. A data point is only flagged as anomalous if **every single model agrees** it looks abnormal.

This consensus approach means Netdata essentially eliminates false alarms — approximately 99% of noise is filtered out. You only see anomalies that are genuinely unusual across multiple time frames.

### Model warm-up period

On a freshly installed system, the ML engine starts detecting anomalies within about 10 minutes. However, accuracy improves over time:

| Time since installation | What to expect |
|------------------------|----------------|
| 0–10 minutes | No anomaly detection yet — collecting initial data |
| 10+ minutes | Detection begins, with higher sensitivity (more false positives possible) |
| After 3 hours | First model rotation; accuracy improves noticeably |
| After 54 hours | Full set of 18 models established; best detection accuracy |

> **Tip:** During the first 48 hours after installation, you may see more anomaly flags than usual. This is normal — the system is learning your infrastructure's patterns.

---

## Viewing Anomaly Rates on the Dashboard

Once ML is running, anomaly information appears throughout the Netdata dashboard automatically.

### Anomaly ribbons on charts

Every chart in the dashboard shows a **thin colored overlay** (sometimes called an anomaly ribbon) that indicates how anomalous that metric was at any given moment. You don't have to do anything special — just look at any chart and the anomaly history is already visible.

### The Anomaly Detection section

Navigate to the **Anomaly Detection** section of your dashboard. You'll find dedicated charts that summarize ML activity across your whole system:

| Chart | What it shows |
|-------|---------------|
| **Anomaly Rate** | The percentage of all your metrics that are currently behaving abnormally |
| **Dimensions** | The raw count of individual metric dimensions flagged as anomalous |
| **Anomaly Detection** | A flag (0 or 1) that indicates when Netdata has declared a node-wide anomaly event |

### What does the anomaly rate mean?

- **0%** — Everything looks normal
- **1–5%** — A small number of metrics are behaving unusually; may warrant a look
- **10%+** — A significant portion of your system is behaving abnormally; likely worth investigating immediately

A **node-level anomaly event** is triggered when more than **1%** of all your metrics are simultaneously anomalous and remain so over a rolling 5-minute window. This threshold can be adjusted (see the tuning section below).

---

## Using Anomaly Advisor to Investigate Problems

The **Anomaly Advisor** is the most powerful tool for investigating incidents. It answers the question: *"What changed on my system during this period, and what was most unusual?"*

### How to open it

1. Open the Netdata dashboard for the affected node or in Netdata Cloud.
2. Click the **Anomalies** tab at the top of the dashboard.

### How to use it

1. **Highlight the time window** you want to investigate — click and drag across the timeline on any of the node anomaly charts to select the period when the issue occurred.
2. The scoring engine **analyzes every metric** collected during that window — potentially thousands of metrics — and ranks them by how anomalous they were.
3. **Review the ranked list** that appears. The metrics that changed the most from their normal behavior appear at the top.

> The root cause of most incidents appears within the **top 30–50 results** of this ranked list.

### Reading the two node anomaly charts

The Anomaly Advisor shows two charts side by side for your infrastructure:

| Chart | What it shows | Best used for |
|-------|---------------|---------------|
| **Percentage chart** | What fraction of each node's metrics were anomalous | Spotting small nodes that are very unhealthy |
| **Absolute count chart** | How many metrics were anomalous on each node | Spotting large nodes where many things changed |

These two views together reveal the "blast radius" of any incident — which nodes were affected, when each was impacted, and whether the issue spread sequentially (cascading failure) or hit multiple nodes at once.

### What Anomaly Advisor is best at

- Sudden changes and spikes
- Cascading failures that spread across multiple nodes
- "What just happened?" investigations after an alert fires
- Discovering hidden dependencies between parts of your infrastructure

### Limitations

- **Stopped services**: If a service stops collecting metrics, Anomaly Advisor cannot detect anomalies in it (no data = nothing to analyze)
- **Gradual degradation**: Very slow changes that happen over days may fall within the normal range of the trained models
- **New deployments**: During the first 54 hours after installing Netdata, anomaly history is limited

---

## Tuning ML Sensitivity and Disabling ML for Specific Metrics

Netdata's ML works well out of the box, but you can adjust its behavior if needed.

### Enabling or disabling ML entirely

ML is enabled by default when Netdata uses its standard database mode. To change this:

1. Open Netdata's main configuration file (typically `netdata.conf`).
2. Find the `[ml]` section.
3. Set `enabled` to:
   - `yes` — Always enable ML
   - `no` — Disable ML entirely
   - `auto` — Enable ML only when the standard database mode is active (default)
4. Restart the Netdata service for the change to take effect.

### Excluding specific charts or metrics from ML

If certain charts generate noisy or irrelevant anomalies (for example, a metric that intentionally fluctuates wildly), you can exclude them from ML training entirely.

In the `[ml]` section of `netdata.conf`, use the `charts to skip from training` setting:

```
charts to skip from training = my-noisy-chart.* another-chart
```

By default, Netdata's own internal monitoring charts (`netdata.*`) are already excluded.

### Adjusting anomaly sensitivity

Two settings control how sensitive anomaly detection is:

| Setting | What it does | Default | How to adjust |
|---------|-------------|---------|---------------|
| **Dimension anomaly score threshold** | How far a value must deviate before one model flags it as anomalous | `0.99` (top 1% of deviations) | Lower value = more sensitive; higher = less sensitive |
| **Host anomaly rate threshold** | What percentage of your metrics must be anomalous to trigger a node-level anomaly event | `1.0%` | Lower value = triggers more easily; higher = only triggers for widespread problems |

### Suppressing repeated anomalies

If a metric is in a persistent anomalous state (for example, a known outage), Netdata can suppress repeated anomaly flags for it to reduce noise. The suppression window defaults to **15 minutes**, with a trigger threshold of **450 anomaly events** within that window.

### Balancing performance vs. accuracy (resource-constrained systems)

ML is designed to be very lightweight (roughly 1–2% of a single CPU core under normal conditions), but you can reduce its footprint further on low-resource machines:

| Setting | Default | Lighter alternative | Effect |
|---------|---------|---------------------|--------|
| `random sampling ratio` | `0.2` (20% of data) | `0.1` | Halves training data used; reduces CPU at slight accuracy cost |
| `number of models per dimension` | `18` | `6` | Uses fewer models; reduces memory while keeping consensus approach |
| `train every` | Every 3 hours | Every 6 hours | Retrains less frequently; reduces CPU at cost of slower adaptation |

---

## Understanding Training Windows and Retraining Behavior

### How the 18-model system works

Rather than training one large model on two days of data, Netdata keeps 18 smaller models, each trained on a 6-hour slice of your metric history, spaced 3 hours apart. This is more efficient and smarter:

| Benefit | Explanation |
|---------|-------------|
| **Faster adaptation** | When your system's behavior changes permanently (e.g., you upgrade a service), the newest models start learning the new pattern within 3 hours |
| **Slower forgetting** | The full consensus of 18 models takes 54 hours to completely adapt to a new pattern, preventing sudden changes from immediately hiding themselves |
| **Low CPU usage** | Training on 6-hour windows uses ~90% less computation than training on the full 54-hour history |
| **No CPU spikes** | Retraining is spread evenly across each 3-hour window, not done all at once |

### When Netdata pauses ML training

Netdata's ML engine is designed to be a "good citizen" — it automatically pauses training to protect your system's primary functions:

- When the dashboard is under heavy query load (so your charts stay fast and responsive)
- When a child node is reconnecting and streaming data to a parent (prioritizing metric replication)
- During any resource contention

Training resumes automatically once conditions improve.

### How models are stored and retained

- Trained models are saved to disk so they survive Netdata restarts — you won't lose your anomaly history when you restart the service.
- Old models are automatically deleted after **7 days** (configurable).
- Anomaly history is stored embedded within your regular metric data, so it has the **same retention period as your metrics** — no extra storage is needed.

### Model inheritance in parent-child setups

If you run multiple Netdata agents streaming data to a parent, child agents send their **pre-computed ML results** to the parent along with metric data. The parent does not need to recompute ML — it receives ready-to-use anomaly information, making the system efficient even at scale.

---

## Quick Reference: Key ML Settings

| Setting | Default | What it controls |
|---------|---------|-----------------|
| `enabled` | `auto` | Whether ML runs at all |
| `maximum num samples to train` | `21600` (6 hours) | How much history each model trains on |
| `minimum num samples to train` | `900` (15 minutes) | Minimum data required before training begins |
| `train every` | `3h` | How often new models are created |
| `number of models per dimension` | `18` | How many models are kept per metric (~54h coverage) |
| `dimension anomaly score threshold` | `0.99` | Sensitivity of individual metric anomaly scoring |
| `host anomaly rate threshold` | `1.0` (1%) | % of anomalous metrics required for a node anomaly event |
| `anomaly detection grouping duration` | `5m` | Rolling window for calculating anomaly rates |
| `charts to skip from training` | `netdata.*` | Metrics excluded from ML |
| `delete models older than` | `7d` | How long model files are retained |

---

## Getting the Most Out of Anomaly Detection

**For day-to-day monitoring:**
- Glance at anomaly ribbons on charts whenever investigating a potential issue — they show you whether the metric was already behaving oddly before you noticed.
- Check the Node Anomaly Rate chart to see if issues are isolated to one metric or widespread across your system.

**For incident response:**
- Open the Anomaly Advisor tab immediately when an alert fires. Highlight the 10–30 minutes before the alert triggered to see what changed first.
- The ranked metric list will typically surface the root cause within the top 30–50 results, saving you from manually checking hundreds of charts.

**For proactive monitoring:**
- Set up alerts on the Node Anomaly Rate chart (available through Netdata's standard alerting system) to be notified whenever your node's overall anomaly rate spikes — even before a specific alert triggers.
- After deploying a new service or configuration change, watch the Anomaly Advisor for the first few hours to see if the change introduces unexpected behavior in related systems.