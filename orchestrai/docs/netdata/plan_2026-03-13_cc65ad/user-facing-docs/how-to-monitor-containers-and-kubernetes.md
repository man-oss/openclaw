---

## Before You Begin

Make sure you have:
- Docker installed (for the Docker section), or a running Kubernetes cluster with `kubectl` access (for Kubernetes)
- Helm 3 installed (for the Kubernetes Helm chart deployment)
- Access to Netdata Cloud (optional, but recommended for centralized dashboards)

---

## Part 1: Running Netdata as a Docker Container

Netdata's official Docker image (`netdata/netdata`) gives you the same depth of monitoring as a native installation. Because Docker containers are isolated from the host, the container needs specific access permissions and host-path mounts to see your full system.

### Option A: Quick Start with `docker run`

Paste and run this command in your terminal:

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

Once the container starts, open your browser and go to **`http://YOUR-SERVER-IP:19999`** to see the Netdata dashboard.

### Option B: Docker Compose

Create a file called `docker-compose.yml` with the following content, then run `docker-compose up -d` in the same directory:

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

### Option C: Docker Swarm (Monitor Every Node Automatically)

For Docker Swarm clusters, Netdata can run as a **global service** — meaning it automatically deploys on every node in your Swarm, current and future. Use the following config:

```yaml
version: '3'
services:
  netdata:
    image: netdata/netdata:stable
    pid: host
    network_mode: host
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
      - /etc/hostname:/etc/hostname:ro
      - /var/log:/host/var/log:ro
      - /var/run/docker.sock:/var/run/docker.sock:ro
      - /run/dbus:/run/dbus:ro
    deploy:
      mode: global
      restart_policy:
        condition: on-failure

volumes:
  netdataconfig:
  netdatalib:
  netdatacache:
```

### Choosing a Docker Image Tag

| Tag | What it gives you |
|---|---|
| `stable` | Latest stable release — recommended for production |
| `edge` | Latest nightly build — most recent features |
| `latest` | Most recently published build (could be stable or nightly) |
| `vX.Y.Z` | A specific version, e.g. `v1.40.0` |

### What Netdata Monitors in Docker

When given the mounts and permissions above, Netdata can see:
- **CPU, memory, disk, and network** usage of each container individually
- **Docker Engine** health and performance (via the Docker socket)
- **Host system** resources (CPU, RAM, disk I/O, network interfaces)
- **Running services** inside containers — databases, web servers, and more
- **Per-user and per-group** resource usage on the host

> **Running without root (rootless Docker)?** Netdata works in rootless mode but with reduced visibility. Container network interface monitoring, disk I/O tracking per process, and systemd journal access are unavailable in this mode.

### Changing the Container's Hostname

The hostname shown in your dashboard and Netdata Cloud reflects the container name by default, not your server name. To fix this, add `--hostname=your-server-name` to the `docker run` command, or add `hostname: your-server-name` under the `netdata:` service in your Compose file.

### Modifying Netdata's Configuration Inside Docker

To change any Netdata settings, attach to the running container:

```bash
docker exec -it netdata bash
cd /etc/netdata
./edit-config netdata.conf
```

Then restart the container to apply changes: `docker restart netdata`.

---

## Part 2: Deploying Netdata on Kubernetes with Helm

For Kubernetes environments, the recommended approach is Netdata's official **Helm chart**, which deploys Netdata as a **DaemonSet** — one Netdata instance (called a "child") runs on every node, collecting metrics, while a central "parent" pod aggregates and stores them.

### Step 1: Add the Netdata Helm Repository

```bash
helm repo add netdata https://netdata.github.io/helmchart/
helm repo update
```

### Step 2: Install Netdata on Your Cluster

**For a fresh installation:**

```bash
helm install netdata netdata/netdata \
  --set image.tag=stable
```

**To connect to Netdata Cloud** (so you can view all your Kubernetes metrics in one place), add your claiming credentials:

```bash
helm install netdata netdata/netdata \
  --set image.tag=stable \
  --set parent.claiming.enabled="true" \
  --set parent.claiming.token=YOUR_CLAIM_TOKEN \
  --set parent.claiming.rooms=YOUR_ROOM_ID \
  --set child.claiming.enabled="true" \
  --set child.claiming.token=YOUR_CLAIM_TOKEN \
  --set child.claiming.rooms=YOUR_ROOM_ID
```

Your claim token and room ID are available in your Netdata Cloud Space — click the **"Add Nodes"** button on the Nodes page.

### Step 3: Upgrading an Existing Cluster

If Netdata is already installed and you want to change settings, create or edit an `override.yaml` file and apply it:

```yaml
image:
  tag: stable

restarter:
  enabled: true

parent:
  claiming:
    enabled: true
    token: YOUR_CLAIM_TOKEN
    rooms: YOUR_ROOM_ID

child:
  claiming:
    enabled: true
    token: YOUR_CLAIM_TOKEN
    rooms: YOUR_ROOM_ID
```

Then run:

```bash
helm upgrade -f override.yaml netdata netdata/netdata
```

### How the Kubernetes Deployment Works

| Component | Role |
|---|---|
| **Child pods (DaemonSet)** | Run on every Kubernetes node, collecting per-node and per-pod metrics |
| **Parent pod** | Aggregates metrics from all child nodes into a single view |
| **Restarter** | Watches for configuration changes and automatically restarts child pods to apply them |

This means when you navigate to your Netdata dashboard or Netdata Cloud, you see every node, every pod, and all namespaces — all in one place.

---

## Part 3: Auto-Discovery of Pods, Services, and Namespaces

One of Netdata's most powerful Kubernetes features is **automatic discovery**. As soon as Netdata deploys on your cluster, it begins watching the Kubernetes API for pods, services, and namespaces — no manual configuration needed.

### What Gets Discovered Automatically

- **Every running pod** across all namespaces, with per-pod CPU, memory, network I/O, and disk usage
- **Services and endpoints** — Netdata identifies which services are running (e.g., an nginx pod, a Redis service) and begins collecting application-specific metrics
- **Namespaces** — metrics are automatically tagged and grouped by namespace so you can filter and compare across teams or environments
- **New pods and services** — as workloads scale up or new deployments roll out, Netdata picks them up automatically within seconds

The service discovery engine continuously watches the Kubernetes API and updates its monitoring configuration dynamically — so you never need to restart Netdata or edit config files when your cluster changes.

### Viewing Your Kubernetes Metrics

After deployment, navigate to the **Infrastructure** section of your Netdata dashboard (or in Netdata Cloud, open your Space and select the Kubernetes nodes). You will see:

- A **node-by-node breakdown** of resource usage across your cluster
- **Per-pod metrics** grouped by namespace and workload
- **Service-level charts** for databases, web servers, message queues, and other discovered applications
- **Network flows** between pods and services

---

## Part 4: Monitoring Kubernetes Control Plane Components

Netdata monitors the health of the Kubernetes control plane — the components that keep your cluster running — alongside your workloads.

### What the Control Plane Monitoring Covers

| Component | Metrics Available |
|---|---|
| **API Server** | Request rates, error rates, latency, active connections |
| **etcd** | Leader elections, database size, commit durations, disk performance |
| **Controller Manager** | Work queue depths, reconcile loops, error rates |
| **Scheduler** | Scheduling latency, queue depth, bind errors |
| **Kubelet** | Pod creation rates, garbage collection, cgroup manager performance |
| **kube-proxy** | Rules sync duration, network latency |

These metrics are collected by scraping the Prometheus-format endpoints that each control plane component exposes. Netdata's service discovery automatically finds these endpoints when the Helm chart is deployed with the appropriate permissions.

### Verifying Control Plane Monitoring is Active

After installation, navigate to the **Kubernetes** section of your dashboard. If you see charts labeled with `apiserver`, `etcd`, `scheduler`, or `controller-manager`, control plane monitoring is working. If those sections are missing, check that Netdata's child pods have network access to the control plane endpoint addresses.

---

## Part 5: Using Labels and Annotations to Control Pod Monitoring

You can tell Netdata exactly which pods to monitor — and how — by adding standard Kubernetes **labels** and **annotations** directly to your workload definitions. This gives you fine-grained control without touching Netdata's configuration files.

### Opting a Pod Out of Monitoring

To exclude a specific pod from being monitored by Netdata, add this annotation to the pod's metadata:

```yaml
annotations:
  netdata/discovery: "false"
```

### Providing Hints to Improve Application Detection

When Netdata discovers a pod, it tries to identify what application is running by examining port numbers and process names. You can help it make the right choice — or override it — with annotations:

```yaml
annotations:
  netdata/role: "mysql"   # Tell Netdata this pod is a MySQL database
```

### Filtering by Namespace

If you want Netdata to only monitor pods in specific namespaces (for example, in a multi-tenant cluster), this is configurable at the Helm chart level using namespace selectors in your `override.yaml`.

### How Labels Flow into Your Dashboard

Every metric Netdata collects from a Kubernetes pod is automatically tagged with:
- The **pod name**
- The **namespace**
- The **node** the pod runs on
- The **workload type** (Deployment, DaemonSet, StatefulSet, etc.)

This means you can filter any chart in Netdata by label — for example, viewing memory usage only for pods in the `production` namespace, or comparing CPU usage across all replicas of a particular Deployment.

---

## Connecting to Netdata Cloud

For the best experience managing a Kubernetes cluster, connect your Netdata deployment to **Netdata Cloud**. This gives you:

- A **single dashboard** showing all nodes, pods, and services across your entire cluster
- **Centralized alerting** — get notified when any pod or node crosses a threshold
- **Cross-node metric correlation** — compare metrics across nodes to find the root cause of issues
- **Historical data** stored and accessible from anywhere

To connect, include your claim token and room ID when running `helm install` or `helm upgrade` as shown in Part 2 above. The values are found by clicking **"Add Nodes"** in your Netdata Cloud Space.

---

## Troubleshooting

| Problem | What to Check |
|---|---|
| Dashboard shows container names instead of hostnames | Add `--hostname=your-hostname` to your `docker run` command or `hostname:` in your Compose file |
| Missing disk or network charts | Ensure the `/proc`, `/sys`, and host root (`/`) volumes are mounted correctly |
| Kubernetes pods not appearing | Check that child pods are running on all nodes with `kubectl get pods -n netdata -o wide` |
| Control plane metrics missing | Verify network access between Netdata pods and the control plane endpoints |
| Some Docker features unavailable | If running in rootless Docker mode, certain privileged metrics (container networking, process I/O) are unavailable by design |
| Container appears unhealthy | By default Netdata's health check queries the `/api/v1/info` endpoint — if your web server is disabled, set the `NETDATA_HEALTHCHECK_TARGET=cli` environment variable |