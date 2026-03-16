# How to Configure Alert Notifications in Netdata

Netdata can send you notifications the moment something goes wrong on your systems — before users notice an issue. This guide walks you through setting up alert notifications so you receive them in the tools your team already uses.

---

## Overview: Two Ways to Receive Notifications

Netdata offers two independent notification methods. You can use one or both:

| Method | Best For |
|--------|----------|
| **Netdata Cloud** | Centralized notifications from all your connected nodes in one place |
| **Netdata Agent** | Notifications sent directly from each individual machine, even without internet |

---

## Part 1: Setting Up Notifications via Netdata Cloud

Netdata Cloud collects alert data from all your connected nodes and delivers notifications through a wide range of integrations. This is the easiest way to get started.

### Supported Cloud Notification Channels

| Integration | Type |
|---|---|
| Netdata Mobile App | Personal push notifications |
| Slack | Team messaging |
| Discord | Community/team messaging |
| Microsoft Teams | Enterprise team messaging |
| PagerDuty | On-call incident management |
| Opsgenie | Alert management |
| Mattermost | Open-source team messaging |
| RocketChat | Self-hosted team messaging |
| Amazon SNS | AWS notification service |
| Telegram | Messaging app |
| Splunk | Data platform |
| Splunk VictorOps | On-call management |
| ilert | Incident management |
| ServiceNow | IT service management |
| Webhook | Any custom HTTP endpoint |

> **Note:** Most Cloud integrations require your Space to be on a **paid plan**. The Netdata Mobile App is available on all plans.

### How to Add a Cloud Notification Integration

1. Click the **Space settings** cog icon (located above your profile icon in Netdata Cloud)
2. Click the **Alerts & Notifications** tab
3. Click the **+ Add configuration** button
4. Select the integration you want to add
5. Fill in the required details in the form that appears, then save

Every integration form asks you for two categories of information:

- **Notification settings** — Give the configuration a name, select which Rooms should trigger notifications, and choose which notification types (Warning, Critical, Clear) you want to receive
- **Integration configuration** — Provide the credentials or connection details specific to each service (see channel-specific instructions below)

---

## Part 2: Configuring Specific Cloud Channels

### Slack

**Before you start:** You need a Slack app with Incoming Webhooks enabled on your workspace.

**In Slack:**
1. Go to your Slack app settings and navigate to **Incoming Webhooks**
2. Turn on **Activate Incoming Webhooks**
3. Click **Add New Webhook to Workspace** and select the channel for notifications
4. Copy the generated Webhook URL

**In Netdata Cloud:**
- Paste the **Webhook URL** into the integration form

---

### Discord

**In Discord:**
1. Open your server's **Settings** → **Integrations**
2. Click **Create Webhook** (or **View Webhooks** to manage existing ones)
3. Set a name and select the channel that will receive notifications
4. Copy the **Webhook URL**

**In Netdata Cloud:**
- Paste the **Webhook URL** and select your channel type (standard or Forum)

---

### PagerDuty

> Requires a paid Netdata Cloud plan.

**In PagerDuty:**
1. Create a new service in your Services directory
2. On the third step of service creation, choose **Events API V2** as the integration type
3. After the service is created, copy both the **Integration Key** and **Integration URL (Alert Events)** from the service configuration page

**In Netdata Cloud:**
- Enter the **Integration Key** and **Integration URL**

---

### Opsgenie

> Requires a paid Netdata Cloud plan.

**In Opsgenie:**
1. Go to your team's **Integrations** tab and click **Add integration**
2. Choose **API** from the available integrations
3. Copy the **API Key**

**In Netdata Cloud:**
- Paste the **API Key**

---

### Microsoft Teams

> Requires a paid Netdata Cloud plan and a Microsoft Teams Essentials subscription or higher.

**In Microsoft Teams:**
1. Hover over the desired channel name, click the three-dots icon, and select **Workflows**
2. Choose **Post to a channel when a webhook request is received**
3. Name the workflow (e.g., "Netdata Alerts"), select your team and channel, then click **Add workflow**
4. Copy the generated **Workflow Webhook URL**

**In Netdata Cloud:**
- Paste the **Microsoft Teams Incoming Webhook URL**

---

### Telegram

> Requires a paid Netdata Cloud plan.

**Setting up your Telegram bot:**
1. Open Telegram and message [@BotFather](https://t.me/BotFather) with the `/newbot` command, then follow the prompts to create a bot. Save the **Bot Token** you receive.
2. **Important:** Start a conversation with your new bot, or invite it to the group where you want to receive notifications.
3. To find your **Chat ID**, message [@myidbot](https://t.me/myidbot) with `/getid` (for personal chat) or `/getgroupid` (for a group)
4. Optionally, to find a **Topic ID** within a group: post a message to the topic, right-click it, select **Copy Message Link** — the topic ID is the second number in the URL (format: `https://t.me/c/XXXXXXXXXX/YY/ZZ`, where `YY` is the topic ID)

**In Netdata Cloud:**
- Enter the **Bot Token**, **Chat ID**, and optionally the **Topic ID**

---

### Amazon SNS

> Requires a paid Netdata Cloud plan and an AWS account.

**In AWS:**
1. Open the AWS SNS console and click **Create topic**
2. Choose the **Standard** type and provide a name
3. In the **Access policy** section, set **Publishers** to **Only the specified AWS accounts** and enter Netdata's AWS account ID: **123269920060**
4. Copy the **Topic ARN** after creation

**In Netdata Cloud:**
- Paste the **Topic ARN**

---

### Mattermost

> Requires a paid Netdata Cloud plan.

**In Mattermost:**
1. Go to **Product menu** → **Integrations** → **Incoming Webhook**
2. Click **Add Incoming Webhook**, provide a name and description, and select the notification channel
3. Copy the generated Webhook URL (format: `https://your-mattermost-server.com/hooks/xxx-generatedkey-xxx`)

**In Netdata Cloud:**
- Paste the **Webhook URL**

---

### ServiceNow

> Requires a paid Netdata Cloud plan and the **Event Management** plugin enabled on your ServiceNow instance.

**In ServiceNow:**
1. Confirm the **Event Management** plugin is activated
2. Go to **System Security** → **Users** and create a dedicated integration user (or use an existing one)
3. Assign the `evt_mgmt_admin` role to that user and set a password

**In Netdata Cloud:**
- Enter your **Instance URL** (e.g., `https://my-instance.service-now.com/`), **Username**, and **Password**

---

### Generic Webhook

> Requires a paid Netdata Cloud plan. Your endpoint must accept HTTPS connections.

**In Netdata Cloud:**
- Enter the **Webhook URL** (HTTPS required)
- Optionally add **Extra headers** as key-value pairs
- Choose an **Authentication Mechanism**:
  - **Mutual TLS** *(recommended)* — Netdata presents a client certificate your server can verify. No credentials needed in Netdata.
  - **Basic** — Provide a username and password
  - **Bearer Token** — Provide a token string

**To verify the connection:**
- Click the **Test** button to send a test notification to your endpoint
- Copy the **Token** from the payload your endpoint receives and paste it into the Verification field

---

### Netdata Mobile App

**Getting started:**
1. Download the Netdata Mobile App from the [Google Play Store](https://play.google.com/store/apps/details?id=cloud.netdata.android) or [Apple App Store](https://apps.apple.com/in/app/netdata-mobile/id6474659622)
2. Open the app and sign in using one of these methods:
   - **Email address:** Enter the email for your Netdata Cloud account and click the verification link sent to your phone
   - **QR Code:** In Netdata Cloud, navigate to **Profile Picture → Settings → Notifications → Mobile App Notifications → Show QR Code**, then scan it in the app
3. After linking, enable the **Mobile App Notifications** toggle in that same settings panel

---

## Part 3: Understanding Alert Severity Levels

All notification integrations let you filter which severity levels trigger a notification. Netdata uses three levels:

| Severity | Meaning | Suggested Response |
|---|---|---|
| **CLEAR** | The metric has returned to normal | No action needed — informational only |
| **WARNING** | Something needs your attention | Investigate when convenient |
| **CRITICAL** | Serious problem requiring immediate action | Respond right away |

**Tip:** Route different severities to different channels. For example, send **WARNING** alerts to a Slack channel for awareness, and **CRITICAL** alerts to PagerDuty to wake someone up.

---

## Part 4: Routing Alerts to the Right Teams

When configuring any Cloud notification integration, you can control exactly who gets notified and when:

- **Rooms:** Select specific Rooms (logical groups of nodes in Netdata Cloud) so each integration only receives alerts relevant to its audience. For example, your database team's Rooms can route to their own Slack channel.
- **Notification types:** Choose whether an integration receives **Warning**, **Critical**, **Clear** (recovery), or all three.
- **Configuration name:** Give each integration a clear name (e.g., "Critical Alerts → PagerDuty" or "All Alerts → #ops-channel") to stay organized as your setup grows.

---

## Part 5: Testing Your Notifications

After saving a Cloud notification integration, always test it before relying on it in production:

1. In the **Alerts & Notifications** settings, find your saved integration
2. Click the **Test** button to send a sample notification
3. Verify the notification arrives in your destination channel
4. For webhook integrations, also complete the **Verification** step by entering the token from the test payload

If a test notification does not arrive, double-check:
- The webhook URL, API key, or token you entered is correct and has not expired
- Your destination service's incoming webhook or integration is active
- For paid-plan integrations, confirm your Space is on an eligible plan

---

## Part 6: Agent-Based Notifications (Advanced)

If your nodes cannot connect to Netdata Cloud, or you want notifications sent directly from each machine, the Netdata Agent supports its own notification system. The Agent can deliver notifications via **Email, Slack, PagerDuty, Telegram, Opsgenie, Twilio**, and more — independently of Netdata Cloud.

Agent notifications are configured on each server through the Agent's health notification settings. This method gives you full control at the individual node level and works even in air-gapped environments.

> For detailed Agent notification setup, refer to the [Agent Notifications documentation](https://learn.netdata.cloud/docs/alerts-&-notifications/notifications/agent-dispatched-notifications).

---

## Preventing Alert Fatigue

Netdata includes several features to avoid overwhelming you with notifications:

| Feature | How It Helps |
|---|---|
| **Intelligent default thresholds** | Pre-configured thresholds based on real-world experience to minimize false positives |
| **Hysteresis protection** | Prevents repeated notifications when a metric fluctuates back and forth around a threshold |
| **Notification delays** | Short delays ensure brief transient spikes don't trigger unnecessary alerts |
| **Role-based routing** | Send alerts only to the team responsible for each service area |

---

## Quick Reference: Which Method Should I Use?

| Situation | Recommended Approach |
|---|---|
| You manage many nodes and want one central place for all alerts | Netdata Cloud |
| You want the simplest possible setup | Netdata Cloud |
| Your nodes have no internet access | Netdata Agent |
| You need per-node fine-grained control | Netdata Agent |
| You want both flexibility and centralized visibility | Use both together |