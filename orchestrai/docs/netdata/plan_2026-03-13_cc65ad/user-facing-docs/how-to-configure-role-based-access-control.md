---

## Understanding Spaces and Rooms

Before diving into roles, it helps to understand the two key building blocks of access in Netdata Cloud:

- **Space** — Your top-level environment. Think of it as your organization's home in Netdata Cloud. All nodes (the machines you monitor), team members, and settings live here.
- **Room** — An organizational group within a Space. You can create Rooms to separate your infrastructure by team, service, location, or any other grouping that makes sense for you. A single node can appear in multiple Rooms simultaneously.

Roles operate at the **Space level**, but some roles have restricted visibility that only extends to specific Rooms they've been assigned to.

---

## Available Roles and What They Can Do

Netdata Cloud offers five distinct roles. Each plan unlocks different roles — the **Community** plan only supports the Admin role, while **Homelab**, **Business**, and **Enterprise On-Prem** plans unlock all five.

### Admin
The most powerful role. Admins have full control over every aspect of the Space, including:
- Managing all users (inviting, removing, and changing roles)
- Connecting and removing nodes
- Creating and deleting Rooms
- Managing billing, plans, and payment methods
- Configuring notification settings for the entire Space
- Deleting the Space itself

> Assign this role only to trusted individuals who need complete oversight.

### Manager
A broad operational role for team leads and infrastructure managers. Managers can:
- Invite users to the Space and assign roles up to Manager level
- Create, rename, and delete Rooms
- Add or remove nodes from Rooms
- See all users and all Rooms across the Space
- Configure alert notification silencing rules

Managers **cannot** access billing or appoint Admins.

### Troubleshooter
Designed for engineers and on-call staff who need to actively investigate issues. Troubleshooters can:
- View monitoring data and dashboards in the Rooms they've been assigned to
- Run read-only diagnostic functions
- Create and edit their own dashboards
- View alert and audit events

Troubleshooters **must be explicitly added** to each Room they need access to. They cannot see Rooms or nodes they haven't been assigned.

### Observer
A view-only role, ideal for stakeholders, customers, or anyone who should see data but never change anything. Observers can:
- View monitoring data and dashboards in their assigned Rooms
- See alert and topology events
- Run read-only functions
- Create and edit their own dashboards (but not others')

Observers **cannot** make any configuration changes. Like Troubleshooters, they only see Rooms they've been assigned to.

> This role is particularly useful for giving customers visibility into their own dedicated monitoring Rooms without exposing the rest of your infrastructure.

### Billing
A specialized role for finance or operations staff who manage subscriptions and payments but have no need to view monitoring data. Billing users can:
- View plan and billing details
- See invoices
- Manage payment methods
- Update the billing email address

Billing users **cannot** access any monitoring data, Rooms, or node information.

---

## Role Availability by Plan

| Role              | Community | Homelab | Business | Enterprise On-Prem |
|:------------------|:---------:|:-------:|:--------:|:------------------:|
| **Admin**         | ✅        | ✅      | ✅       | ✅                 |
| **Manager**       | —         | ✅      | ✅       | ✅                 |
| **Troubleshooter**| —         | ✅      | ✅       | ✅                 |
| **Observer**      | —         | ✅      | ✅       | ✅                 |
| **Billing**       | —         | ✅      | ✅       | ✅                 |

---

## Inviting Users and Assigning Roles

Only **Admins** and **Managers** can invite new users to a Space.

**To invite someone:**

1. Open your Space in Netdata Cloud.
2. In the left sidebar, click **Invite Users**.
3. Enter the person's email address.
4. Select the appropriate role from the role dropdown.
5. Optionally, assign them to specific Rooms at the same time.
6. Send the invitation.

The invited person will receive an email. Once they accept, they'll appear as an active member of your Space with the role you selected.

> **Tip:** Invite all relevant team members — SRE, DevOps, ITOps — at once and assign roles according to their responsibilities. You can always adjust roles later.

---

## Adding Users to Specific Rooms

For **Troubleshooter** and **Observer** roles, being a member of the Space is not enough — they also need to be added to each Room they should have access to.

**To add a user to a Room:**

1. Navigate to the Room you want to grant access to.
2. Click the ⚙️ (settings) icon next to the Room name.
3. Go to the **Room members** or access settings section.
4. Search for and add the user from the list of Space members.

**Admins** and **Managers** can see and join any Room in the Space freely — they don't need to be explicitly added.

---

## Changing a User's Role

Only **Admins** can appoint other Admins or Billing users. Both **Admins** and **Managers** can assign or change the Manager, Troubleshooter, and Observer roles.

**To change someone's role:**

1. Go to your Space settings by clicking the ⚙️ icon in the lower-left corner of the sidebar.
2. Navigate to the **Users** or **Team members** section.
3. Find the user whose role you want to change.
4. Select a new role from the role options next to their name.

The change takes effect immediately.

---

## Removing a User's Access

Both **Admins** and **Managers** can remove users from the Space. Only **Admins** can appoint or remove other Admins.

**To remove a user from the Space:**

1. Go to your Space settings (⚙️ in the lower-left sidebar).
2. Open the **Users** section.
3. Find the user you want to remove.
4. Select the option to remove or delete them from the Space.

**To remove a user from a specific Room only** (without removing them from the Space entirely):

1. Open the Room's settings by clicking ⚙️ next to the Room name.
2. Find the user in the Room members list.
3. Remove them from the Room.

**To cancel a pending invitation** (before the person has accepted):

1. Go to Space settings → **Users**.
2. Find the pending invitation in the list.
3. Select **Delete invitation**.

---

## Space-Level vs. Room-Level Access

Understanding the difference between these two levels of access is essential for controlling what your team can see:

| | **Space-Level Access** | **Room-Level Access** |
|---|---|---|
| **Who has it automatically** | Admins and Managers | Admins and Managers |
| **Who needs explicit assignment** | Everyone (via invite) | Troubleshooters and Observers |
| **What it unlocks** | Membership in the Space, visibility of all Rooms and nodes (for Admin/Manager) | Visibility of monitoring data within that specific Room only |
| **Best for** | Broad operational roles | Scoped, need-to-know access |

Troubleshooters and Observers work entirely within the boundaries of their assigned Rooms. If a Troubleshooter hasn't been added to a Room, they simply won't see it or any of its nodes.

---

## Best Practices for Securing Team Access

**Apply the principle of least privilege.** Give each person the minimum role they need to do their job. Start with Observer or Troubleshooter for most team members, and only elevate to Manager or Admin when genuinely required.

**Limit the number of Admins.** Too many Admins increases the risk of accidental or unauthorized changes to billing, nodes, and Space settings. Aim for 2–3 trusted Admins per Space.

**Use Rooms to scope sensitive access.** If certain nodes contain sensitive data (production databases, security systems), create dedicated Rooms for them and only assign users who genuinely need visibility.

**Separate billing from operations.** Use the dedicated **Billing** role for finance staff so they can manage payments without having any access to your monitoring infrastructure.

**Use Observer for external stakeholders.** When customers or non-technical stakeholders need to view monitoring data, assign them as Observers in a dedicated Room. They'll see only what you've put in that Room.

**Review access regularly.** When team members change roles, leave your organization, or shift responsibilities, promptly update or revoke their Netdata Cloud access. Use the Space settings Users section to audit who has access and at what level.

**Keep Managers informed.** Managers can invite and remove users and manage Rooms, but they cannot appoint Admins or touch billing. This makes the Manager role a safe choice for team leads who need operational authority without full administrative risk.

---

## Quick Role Selection Guide

| If the person needs to… | Assign this role |
|:---|:---|
| Full control — billing, users, nodes, all settings | **Admin** |
| Manage team members and Rooms but not billing | **Manager** |
| Actively troubleshoot and run diagnostics | **Troubleshooter** |
| View monitoring data only, no changes | **Observer** |
| Handle invoices and payments only | **Billing** |