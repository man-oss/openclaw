# How to Use Service Discovery in Netdata

## Overview

Netdata's Service Discovery feature automatically finds and monitors services running in your environment — whether they are running directly on a host, inside Docker containers, or across a Kubernetes cluster. Instead of manually telling Netdata about every service, Service Discovery continuously scans your environment, detects what is running, and begins collecting metrics automatically.

This guide explains how Service Discovery works, what environments it supports, and how you can customize its behavior to suit your setup.

---

## What Service Discovery Does and Why It Matters

When you run Netdata in a dynamic environment — where containers start and stop, new Kubernetes pods come online, or services change — manually configuring each one is impractical. Service Discovery solves this by:

- **Automatically detecting** services and endpoints as they appear or disappear
- **Continuously updating** monitoring configuration without requiring manual restarts
- **Removing stale targets** when services shut down, keeping your monitoring clean and accurate
- **Applying the right monitoring rules** to each discovered service based on what type it is

For example, if a new Redis container starts on your host, Service Discovery will detect it, recognize it as a Redis instance, and automatically begin collecting the appropriate metrics — all without any manual steps from you.

---

## How Service Discovery Works: The Discoverer and Target Model

Netdata's Service Discovery is built around two simple concepts: **Discoverers** and **Targets**.

### Discoverers

A **Discoverer** is a scanner that watches a specific part of your environment for services. Each discoverer runs continuously in the background and reports back whenever something changes — a new service appears, an existing one changes, or one disappears.

Netdata comes with discoverers built for three environments:

| Discovery Type | What It Scans |
|---------------|---------------|
| **File-based** | Configuration files you place in Netdata's configuration directories |
| **Kubernetes** | Pods, services, and endpoints in your Kubernetes cluster |
| **Docker** | Running containers on the local Docker host |

Each discoverer produces results and sends them onward to be processed by Netdata's monitoring pipeline.

### Targets and Target Groups

When a discoverer finds a service, it creates a **Target** — a representation of that service. Each target has:

- A **unique identity** so Netdata can tell targets apart even if details change
- **Tags** that describe what kind of service it is (for example: `web`, `database`, `redis`)
- A **provider** label that identifies which discoverer found it (e.g., `kubernetes`, `docker`, `file`)
- A **source** identifier that pinpoints exactly where in the environment the target came from

Targets are grouped into **Target Groups** — collections of related targets that come from the same source. For instance, all the containers from a specific Docker network might form one target group.

---

## Supported Discovery Environments

### File-Based Discovery

File-based discovery reads configuration files that you place in Netdata's configuration directories. This is the most direct way to tell Netdata about specific services — you write a configuration file describing a service and its monitoring rules, and Netdata picks it up automatically.

**When to use it:** Ideal for services running directly on a host (not in containers), or when you want to manually define monitoring for specific endpoints.

Netdata watches the configuration directories continuously. If you add, modify, or remove a file, the change takes effect without restarting Netdata.

### Kubernetes Discovery

Kubernetes discovery connects to the Kubernetes API and watches for pods, services, and endpoints across your cluster. It automatically:

- Detects new pods as they are scheduled
- Monitors pod labels and annotations to determine what kind of service is running
- Removes monitoring when pods terminate

**When to use it:** Any Kubernetes environment. This is the recommended approach for containerized workloads on Kubernetes.

### Docker Discovery

Docker discovery monitors the Docker daemon on the local machine. It detects running containers and collects details like container names, image names, and labels to identify what each container is running.

**When to use it:** When running services in Docker on a single host or small cluster without Kubernetes.

---

## Understanding Tags: Scoping and Classifying Services

**Tags** are labels that Netdata attaches to each discovered target. They play a central role in determining which monitoring rules apply to which services.

### How Tags Work

Tags are simple words like `web`, `redis`, `docker`, `kubernetes`, or `prod`. A target can have multiple tags. When Netdata's monitoring rules evaluate a discovered target, they use these tags to decide:

- **Should this target be monitored?** (Does it have the right tags?)
- **Which monitoring template should apply?** (Which tags match this rule?)

### Tag Operations

Tags support two operations:

- **Adding a tag** — simply write the tag name (e.g., `redis`)
- **Removing a tag** — prefix with a dash (e.g., `-redis`)

This allows you to layer tag adjustments as targets pass through classification rules, narrowing down or expanding which monitoring configurations apply.

### Tag Rules

Tag names must start with a letter and can contain letters, numbers, and the characters `=`, `_`, and `.`. For example: `web`, `db`, `env=prod`, `tier.frontend` are all valid tags.

---

## How Configuration Files Work

Each service discovery setup is driven by a **configuration file** (in YAML format) that you place in Netdata's configuration directory. The file defines:

1. **A name** for this discovery pipeline (must be unique)
2. **Which discoverer to use** (`file`, `k8s`, or `docker`)
3. **Service rules** that describe how to match discovered targets and what monitoring to apply

### Basic Configuration Structure

```yaml
name: my-redis-monitoring
discoverer:
  docker: {}
services:
  - id: redis-containers
    match: '{{ eq .Image "redis" }}'
    config_template: |
      # monitoring configuration for this service
```

### Key Fields

| Field | Purpose |
|-------|---------|
| `name` | A unique name for this discovery pipeline |
| `discoverer` | Which discovery method to use and its settings |
| `services` | Rules that match targets and assign monitoring configurations |
| `disabled` | Set to `true` to temporarily turn off this pipeline |

### Service Rules

Each entry in the `services` list has:

- **`id`** — A label for this rule (used in logs and diagnostics)
- **`match`** — A condition that determines which discovered targets this rule applies to (uses Go template expressions against the target's properties)
- **`config_template`** — (Optional) The monitoring configuration to apply when a target matches

If a target matches a rule's `match` expression, Netdata applies the associated `config_template` to begin monitoring that service.

### Multiple Configuration Files

You can have as many configuration files as you need. Netdata processes them all in parallel. If two files define a pipeline with the same name, Netdata resolves the conflict using a priority system based on where the file came from (built-in defaults have lower priority than files you create yourself — your custom configurations always win).

---

## Managing Discovery Pipelines

### Enabling and Disabling Pipelines

You can disable a specific pipeline without deleting its configuration file by adding `disabled: true` to the file:

```yaml
name: my-service
disabled: true
discoverer:
  docker: {}
services:
  - id: my-rule
    match: '{{ eq .Name "myapp" }}'
```

Removing the `disabled` field (or setting it to `false`) re-enables the pipeline. Netdata picks up the change automatically.

### Live Updates

Netdata watches your configuration directories continuously. You do not need to restart Netdata when you:

- Add a new configuration file
- Edit an existing configuration file
- Delete a configuration file

Changes take effect within seconds.

---

## Practical Tips

### Start with the Right Discoverer

Choose the discoverer that matches your environment:
- Running services directly on a Linux host? Use **file-based** discovery or rely on Netdata's built-in auto-detection.
- Using Docker on a single machine? Use the **docker** discoverer.
- Running Kubernetes? Use the **kubernetes** (k8s) discoverer.

### Use Tags to Filter Precisely

If Netdata is picking up services you don't want to monitor, use tag-based filtering in your service rules. For example, you can write a `match` expression that only applies to containers with a specific Docker label, a certain image name, or a specific Kubernetes namespace.

### One Pipeline Per Concern

Keep configuration files focused. Rather than one large file with dozens of rules, create separate files for different service types (one for databases, one for web servers, etc.). This makes troubleshooting easier and allows you to enable or disable monitoring categories independently.

### Check the Netdata Dashboard

After making changes to discovery configurations, navigate to the **Netdata Dashboard** and look at the **Collected Metrics** section to confirm new services are appearing. If a service doesn't show up, check that:

1. The discoverer type matches your environment
2. The `match` expression in your service rule correctly evaluates against the target's properties
3. The pipeline is not marked as `disabled`

---

## Summary

Netdata's Service Discovery removes the manual work of configuring monitoring for dynamic environments. By combining continuously running discoverers (for files, Docker, and Kubernetes), a flexible tagging system, and YAML-based configuration files, it automatically finds your services and begins monitoring them. You stay in control through configuration files that let you customize which services are monitored, how they are identified, and which monitoring rules apply — all without restarting Netdata.