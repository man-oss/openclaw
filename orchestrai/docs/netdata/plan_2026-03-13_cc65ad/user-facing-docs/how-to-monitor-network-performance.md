# How to Monitor Network Performance with Netdata

Netdata gives you instant, real-time visibility into everything happening on your network — from how much data each interface is sending and receiving, to which processes are consuming bandwidth, to whether connections are being dropped. This guide walks you through everything you need to monitor your network health and quickly diagnose connectivity problems.

---

## What Netdata Monitors Automatically

The moment Netdata is installed, it begins collecting network data without any setup required. Every network interface on your system is discovered and tracked continuously, updating every second.

### Bandwidth (Traffic In and Out)

For every network interface (for example, `eth0`, `ens3`, `wlan0`), Netdata shows:

- **Received (inbound)** — how much data is coming into the interface, measured in kilobits per second
- **Sent (outbound)** — how much data is leaving the interface, measured in kilobits per second

You can find this in your dashboard under the **Network Interfaces** section. Each interface gets its own chart showing inbound and outbound traffic overlaid so you can compare them at a glance.

### Packets

Beyond raw bandwidth, Netdata counts the individual packets moving through each interface:

- **Packets received** — the number of data packets arriving per second
- **Packets sent** — the number of data packets leaving per second

A sudden spike or drop in packet counts, even when bandwidth looks normal, can be an early warning sign of a problem.

### Errors

Netdata tracks transmission errors on each interface:

- **Receive errors** — packets that arrived corrupted or malformed
- **Transmit errors** — packets that could not be sent correctly

Errors often point to physical issues like a bad cable, a failing network card, or an overloaded switch.

### Drops

Dropped packets are different from errors — they are valid packets that were discarded because the system or interface could not process them fast enough:

- **Inbound drops** — packets received but thrown away before processing
- **Outbound drops** — packets that were ready to send but discarded before transmission

Even a small, steady rate of drops can cause noticeable slowness in applications and connections.

---

## Deep Network Monitoring with eBPF

For systems running Linux with a compatible kernel, Netdata includes eBPF-based monitoring that goes far deeper than standard interface statistics. eBPF lets Netdata observe what is happening inside the operating system's networking stack itself — with no slowdown to your system.

### TCP Connections

Netdata's eBPF monitoring tracks:

- **Active TCP connections opened** — how many outgoing connections your system initiates per second
- **Passive TCP connections** — how many incoming connections are accepted per second
- **TCP connection failures** — attempts to connect that were refused or timed out
- **TCP retransmissions** — packets that had to be sent again because the original was lost, a key indicator of network quality

You can find these charts in the **eBPF Network** section of your dashboard. A rising retransmission count is one of the clearest signs that your network path is unreliable.

### UDP Traffic

Netdata also monitors:

- **UDP packets sent** — the number of UDP datagrams sent per second
- **UDP packets received** — the number of UDP datagrams received per second
- **UDP receive errors** — UDP packets that arrived but could not be processed

UDP is used by DNS, video streaming, VoIP, and many other services. Errors here can explain audio/video quality problems or slow DNS lookups.

### TCP Socket State

Netdata can show you a live count of TCP sockets broken down by their current state, including how many connections are established, waiting to close, or in a half-open state. This is useful for diagnosing connection exhaustion — a situation where your server has run out of available sockets to accept new connections.

---

## Monitoring Network Latency

Latency measures how long it takes for data to travel from one point to another. Even when bandwidth looks fine, high latency causes slow page loads, laggy applications, and poor user experience.

### Ping-Based Latency Monitoring

Netdata includes a **ping collector** that continuously measures round-trip time (how long it takes to send a small test packet to a destination and receive a reply). You configure which hosts to monitor — for example, your gateway router, a DNS server, or a remote service — and Netdata charts the latency over time.

From your dashboard in the **Network** section, the ping charts show:

- **Average round-trip time** in milliseconds — lower is better; anything above 100ms to a local server is worth investigating
- **Minimum and maximum round-trip times** — a large gap between minimum and maximum indicates inconsistent ("jittery") connections
- **Packet loss percentage** — if ping packets start getting lost, it is a strong sign of network congestion or a failing link

### Traceroute Integration

For diagnosing *where* on the network a problem exists, Netdata supports integration with traceroute-style tools. This lets you see the path your traffic takes through the network and measure the latency at each hop — so you can tell whether slowness is happening inside your own network, at your internet provider, or somewhere further along the route.

---

## Viewing Per-Process Network Usage

One of the most useful features for diagnosing network issues is being able to see exactly which application or service is responsible for network activity. Netdata tracks network usage broken down by individual process.

### Accessing the Processes View

Navigate to the **Processes** section in your Netdata dashboard. Here you will find charts showing, for each running process:

- **Bytes sent** — how much data the process is sending per second
- **Bytes received** — how much data the process is receiving per second

This makes it immediately obvious if, for example, a backup job is consuming all available bandwidth, a database is generating unexpected outbound traffic, or a specific application is producing connection errors.

### Using the "Netdata Functions" Live View

For an even more interactive experience, Netdata offers a live **Processes** function that shows a real-time table of all running processes and their resource usage — similar to the `top` command but richer and browser-based. You can access this from the **Functions** area of your dashboard. Sort by network activity to instantly see which processes are the heaviest network users at that exact moment.

---

## Setting Alerts for Network Issues

Netdata comes with built-in alerts for the most important network warning signs, and you can add your own to match your specific needs.

### Built-In Network Alerts

Netdata includes pre-configured alerts that will notify you when:

- **Interface errors spike** — a sudden increase in transmit or receive errors triggers a warning
- **Packet drops occur** — any sustained rate of dropped packets generates an alert
- **TCP retransmissions are high** — elevated retransmission rates indicate a degraded network path
- **Network interface goes down** — if a monitored interface stops reporting traffic, Netdata can alert you

These alerts are active as soon as Netdata is installed, with no configuration needed.

### Creating a Bandwidth Threshold Alert

To be notified when bandwidth exceeds a limit — for example, if an interface starts using more than 800 Mbps on a 1 Gbps link — you can create a custom alert through the Netdata dashboard:

1. Open the Netdata dashboard and navigate to **Alerts** in the top menu
2. Select **Manage Alerts**, then choose to add a new alert
3. Select the network chart you want to monitor (for example, the outbound traffic chart for `eth0`)
4. Set your threshold value and choose whether to trigger a **Warning** or **Critical** alert
5. Choose how you want to be notified — options include email, Slack, PagerDuty, and many others

### Creating a Packet Loss Alert

For ping-based monitoring, you can set up an alert that fires when packet loss to a critical host exceeds a threshold:

1. Navigate to **Alerts** in the dashboard
2. Add a new alert targeting the ping packet loss chart for the host you are monitoring
3. Set a threshold — for example, alert if packet loss exceeds 1% (warning) or 5% (critical)
4. Save and activate the alert

Once configured, you will receive a notification the moment your network starts dropping packets to that destination.

---

## Diagnosing Connectivity Problems

When something goes wrong with the network, here is how to use Netdata to find the cause quickly:

| Symptom | Where to Look in Netdata | What to Check |
|---|---|---|
| Applications are slow | Network Interfaces charts | High bandwidth usage, packet drops |
| Connections keep dropping | eBPF TCP charts | TCP retransmissions, connection failures |
| DNS lookups are slow | eBPF UDP charts | UDP receive errors, packet drops |
| Unexpected traffic | Processes view | Which process is sending/receiving |
| Intermittent slowness | Ping latency charts | Jitter (gap between min and max latency) |
| Server not accepting new connections | TCP socket state charts | Sockets stuck in TIME_WAIT or connection backlog full |

### Tips for Effective Network Troubleshooting

- **Use the time selector** to jump back to the exact moment a problem was reported — Netdata stores historical data so you can investigate issues after the fact
- **Compare multiple charts together** by pinning them — you can correlate a bandwidth spike with a specific process or a TCP error spike with application complaints
- **Check all interfaces** — problems sometimes appear on a secondary or virtual interface (like a VPN tunnel) that you might not think to check first
- **Look at multiple metrics together** — bandwidth alone does not tell the whole story; always check errors and drops alongside it

---

## Summary

Netdata gives you a complete picture of network health without requiring any manual setup or configuration. From the moment it is running, you get per-interface bandwidth, packet, error, and drop data refreshed every second. Add eBPF monitoring for deep TCP/UDP insights, use the ping integration to measure latency to critical destinations, view per-process network usage to identify bandwidth hogs, and set alerts so you are notified before small problems become outages. All of this is available through a single, browser-based dashboard — giving you everything you need to keep your network healthy and diagnose problems quickly when they arise.