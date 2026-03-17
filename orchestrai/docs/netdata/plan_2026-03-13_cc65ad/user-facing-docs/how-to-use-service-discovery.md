# How to Use Service Discovery in Netdata

## Overview

Netdata's service discovery feature automatically finds the services, containers, and applications running in your environment — so you don't have to manually tell Netdata what to monitor. As soon as a new service appears (or disappears), Netdata detects the change and adjusts its monitoring accordingly, in real time.

This guide explains how service discovery works, what types of environments it supports, and how you can customize it to fit your infrastructure.

---

## What Service Discovery Does

When Netdata starts, it begins scanning your environment for services to monitor. This process is continuous — Netdata watches for new services appearing and old ones going away, keeping your monitoring up to date without any manual intervention.

Here's what happens automatically:

- **Detection**: Netdata identifies running services, containers, or pods
- **Classification**: Each discovered service is labeled with descriptive tags (e.g., "web server", "database", "container")
- **Configuration**: Netdata generates the right monitoring configuration for each service based on matching rules
- **Live updates**: As your environment changes, monitoring adapts in real time

---

## How Discovery Is Organized: Targets and Target Groups

Netdata organizes everything it discovers using a two-level structure:

### Targets
A **target** is a single monitorable item — for example, one running container, one Kubernetes pod, or one network port. Every target has:

- **A unique identity** — a stable ID that lets Netdata track it even when it restarts
- **A fingerprint** — a hash value that detects when the target's properties change
- **Tags** — descriptive labels that describe what kind of service this is (see the [Tags](#using-tags-to-classify-services) section below)

### Target Groups
A **target group** is a collection of related targets that all come from the same discovery source. For example, all containers on a Docker host form one target group, or all pods in a Kubernetes namespace form another.

Each target group has a **provider** (what found it) and a **source** (where it came from). This lets Netdata manage discoveries from multiple sources independently.

---

## Supported Discovery Methods

Netdata supports three main ways to discover services:

### 1. Kubernetes Discovery
In Kubernetes environments, Netdata watches the Kubernetes API for pods, services, and other resources. It reads pod labels and annotations to classify what each workload is running.

**What it discovers automatically:**
- All pods across namespaces
- Pod labels and annotations (used for matching rules)
- Container names and images within pods

### 2. Docker Discovery
On hosts running Docker, Netdata monitors the Docker daemon directly to detect running containers.

**What it discovers automatically:**
- Running containers
- Container labels
- Exposed ports and network settings

### 3. File-Based Discovery
For traditional (non-containerized) environments, Netdata can discover services by scanning for configuration files or by reading target definitions from files on disk.

This is useful for:
- Bare-metal hosts running services directly
- Custom or non-standard setups
- Providing static lists of services to monitor

---

## Using Tags to Classify Services

Tags are the key mechanism Netdata uses to decide *how* to monitor something once it's discovered. Every discovered target carries a set of tags — words that describe what it is.

**How tags work:**

- Tags are simple words or key=value pairs (for example: `web`, `nginx`, `port=80`, `env=production`)
- Tags are **additive by default** — you can keep layering more specific tags on top of general ones
- A tag starting with a `-` (dash) **removes** that label (for example: `-web` would remove the `web` tag)

**Example tag flow:**

1. A Docker container is discovered → it gets a base tag: `container`
2. A matching rule sees the image is `nginx` → adds `web` and `nginx` tags
3. Another rule checks the port → adds `port=80`
4. The final tag set `{container, web, nginx, port=80}` is used to select the right monitoring module

Tags let you write precise rules: "monitor everything tagged `web` and `nginx` using the Nginx module."

---

## Discovery Pipelines and Configuration Files

Netdata's discovery system works through **pipelines**. Each pipeline is defined by a configuration file and has two main parts:

### 1. The Discoverer
Specifies *where* to find services — Kubernetes, Docker, or files. There is exactly one discoverer per pipeline.

### 2. Service Rules
Specifies *what to do* with discovered targets. Each rule has:
- **`id`** — a name for the rule (for logging and diagnostics)
- **`match`** — an expression that selects which targets this rule applies to (based on tags and properties)
- **`config_template`** (optional) — a template that generates the monitoring configuration for matching targets

---

## Example Pipeline Configuration

Here is what a typical discovery configuration file looks like:

```yaml
name: my-docker-services

discoverer:
  docker: {}

services:
  - id: nginx-containers
    match: '{{ eq .Image "nginx" }}'
    config_template: |
      url: http://{{ .Address }}/stub_status

  - id: redis-containers
    match: '{{ eq .Image "redis" }}'
    config_template: |
      address: {{ .Address }}
```

**What this does:**
- Uses Docker discovery to find all running containers
- If a container is running the `nginx` image, monitors its stub status endpoint
- If a container is running the `redis` image, monitors it as a Redis instance

---

## How Configuration Files Are Loaded

Netdata automatically watches a configuration directory for discovery pipeline files. You can:

- **Add a new file** → Netdata picks it up and starts a new discovery pipeline
- **Edit an existing file** → Netdata updates the pipeline with the new settings
- **Delete or empty a file** → Netdata removes that pipeline and stops monitoring those targets

Pipelines can also be temporarily disabled by adding `disabled: true` to the configuration file:

```yaml
name: my-pipeline
disabled: true
discoverer:
  docker: {}
```

---

## Priority Between Configuration Sources

When multiple configuration files define the same pipeline, Netdata applies a priority system:

| Source Type | Priority |
|-------------|----------|
| User-defined configurations | Highest |
| Stock (built-in) configurations | Lower |

A higher-priority configuration always wins. If a user-defined file conflicts with a built-in default, the user's version takes effect. If the same pipeline is already running and the new configuration has equal or lower priority, the running version is kept for stability.

---

## Managing Discovery Through the Netdata Interface

Beyond configuration files, Netdata exposes discovery settings through its dynamic configuration system, accessible from the Netdata UI. From there you can:

- **View** all active discovery pipelines
- **Enable or disable** individual pipelines without editing files
- **Update** pipeline settings interactively
- **Test** a pipeline configuration before applying it

When a new pipeline is discovered from a configuration file, Netdata may wait briefly (up to 5 seconds) for you to confirm whether to enable or disable it — giving you a chance to review before monitoring begins.

---

## Quick Reference: Key Concepts

| Concept | What It Means |
|---|---|
| **Target** | A single discovered service or container |
| **Target Group** | A collection of targets from the same source |
| **Discoverer** | The mechanism that finds targets (Kubernetes, Docker, or file) |
| **Tags** | Labels on a target used to select monitoring rules |
| **Pipeline** | A configuration combining one discoverer with service rules |
| **Service Rule** | A match expression + configuration template applied to targets |

---

## Tips for Customizing Discovery

- **Narrow down what gets monitored** by writing specific `match` expressions using container image names, labels, or port numbers
- **Remove unwanted tags** using the `-tagname` prefix to prevent false matches
- **Use multiple pipelines** to organize different environments (for example, one pipeline for Kubernetes, another for Docker)
- **Disable built-in pipelines** by creating a user configuration file with `disabled: true` if a default pipeline doesn't suit your environment
- **Combine tag layers** to build precise, readable matching rules — start broad (detect all containers) and get more specific (detect only `nginx` containers on port 80)