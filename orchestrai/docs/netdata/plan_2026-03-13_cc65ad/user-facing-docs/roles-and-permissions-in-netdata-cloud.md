## Overview

Netdata Cloud uses a **Role-Based Access Control (RBAC)** system to help you manage who can see, change, or manage different parts of your monitoring setup. By assigning the right role to each team member, you can make sure everyone has exactly the access they need — nothing more, nothing less.

Roles apply at the **Space level** (your overall monitoring environment) and determine which **Rooms** (groups of nodes) a person can access within that Space.

---

## The Five Available Roles

### 👑 Administrator
Administrators have complete control over everything in a Space. This role is intended for the people responsible for setting up and maintaining the entire monitoring environment.

**Administrators can:**
- Manage all Space settings (name, description, preferences)
- Connect and remove nodes from the Space
- Invite, remove, and assign roles to all users — including appointing other Administrators
- Create, delete, and configure all Rooms
- Set up, edit, and delete notification integrations
- Manage billing, update plans, and handle payment methods
- Use all diagnostic tools and run any type of function on nodes
- Access every Room in the Space without needing an invitation

---

### 🗂️ Manager
Managers handle day-to-day team and infrastructure organization. They can do most of what an Administrator can, except billing and top-level Space settings.

**Managers can:**
- See and join any Room in the Space
- Create, delete, and configure Rooms
- Add or remove nodes from Rooms
- Invite users to the Space and assign roles (Manager, Troubleshooter, or Observer)
- Remove users from the Space
- Create and manage alert silencing rules
- Add and edit node configurations (Dynamic Configuration Manager)
- Run any function on nodes, including sensitive operations

**Managers cannot:**
- Delete the Space or change Space-level settings (name, slug, etc.)
- Connect or permanently remove nodes from the Space
- Appoint or remove Administrators or Billing users
- Access billing or subscription settings

---

### 🔍 Troubleshooter
Troubleshooters are focused on actively investigating issues. They need to be assigned to specific Rooms to access them — they cannot freely browse all Rooms in the Space.

**Troubleshooters can:**
- View all data in their assigned Rooms
- Create new dashboards and edit or delete their own dashboards
- View and run read-only diagnostic functions on nodes
- See alert and topology events, including audit logs
- See alert notification silencing rules
- Manage their own personal notification preferences
- Add and delete bookmarks

**Troubleshooters cannot:**
- Join Rooms they haven't been assigned to
- Create or manage Rooms
- Invite or manage other users
- Set up or modify Space-wide notification integrations
- Create alert silencing rules at the Space level
- Run sensitive or write-level functions on nodes
- Access billing or node/Space configuration settings

---

### 👁️ Observer
Observers have read-only access within the specific Rooms they've been assigned to. This role is ideal for stakeholders, customers, or anyone who needs to view monitoring data without being able to change anything.

**Observers can:**
- View all dashboards and charts in their assigned Rooms
- Create and manage their own personal dashboards
- See alert and topology events
- Run read-only diagnostic functions
- View bookmarks and visited nodes
- Manage their own personal notification preferences

**Observers cannot:**
- Edit or delete dashboards created by other users
- Join or see Rooms they haven't been assigned to
- Invite or manage any users
- Create, configure, or delete Rooms
- Add bookmarks (they can only view them)
- Access any administrative, configuration, or billing settings

> 💡 **Tip:** The Observer role is perfect for giving customers a view into their own dedicated monitoring Room without exposing the rest of your infrastructure.

---

### 💳 Billing User
The Billing role is a specialized, finance-focused role with no access to monitoring data. It is designed for finance or procurement team members who manage subscriptions without needing to see any infrastructure metrics.

**Billing users can:**
- View current plan and usage details
- View and download invoices
- Manage payment methods
- Update the billing email address
- Manage their own personal notification preferences

**Billing users cannot:**
- Access any Rooms, dashboards, or monitoring data
- Manage users or nodes
- Update or cancel the subscription plan (only Administrators can do this)
- Access any Space or Room settings

---

## Plan Availability

Not all roles are available on every Netdata Cloud plan:

| Role             | Community | Homelab | Business | Enterprise On-Prem |
|:-----------------|:---------:|:-------:|:--------:|:------------------:|
| **Administrator**| ✅        | ✅      | ✅       | ✅                 |
| **Manager**      | —         | ✅      | ✅       | ✅                 |
| **Troubleshooter**| —        | ✅      | ✅       | ✅                 |
| **Observer**     | —         | ✅      | ✅       | ✅                 |
| **Billing**      | —         | ✅      | ✅       | ✅                 |

On the **Community plan**, only the Administrator role is available. Upgrading to a paid plan unlocks the full RBAC model.

---

## Space-Level vs. Room-Level Access

Understanding the two levels of access helps you set up the right structure for your team.

### Space Level
A Space is your top-level monitoring environment. Space-level permissions control things like:
- Who can invite and remove team members
- Who can connect or delete nodes
- Who can change Space settings and manage billing
- Who can set up notification channels

**Administrators and Managers** have broad Space-level visibility — they can see all Rooms and all nodes in the Space.

### Room Level
Rooms are groups of nodes within your Space. Room-level access determines:
- Which nodes and dashboards a user can see
- Whether a user can create or modify dashboards in that Room
- Which diagnostic tools a user can run against nodes in that Room

**Troubleshooters and Observers** must be explicitly added to each Room they need to access. They cannot see or join Rooms on their own.

---

## How to Assign and Change Roles

### Inviting a New Team Member

1. Open your Space in Netdata Cloud.
2. Click **Invite Users** in the Space's sidebar.
3. Enter the person's email address.
4. Select the **Role** you want to assign from the dropdown.
5. Optionally, select which **Rooms** they should be added to (required for Troubleshooters and Observers).
6. Send the invitation.

> Only **Administrators** and **Managers** can invite users to a Space.

### Changing an Existing User's Role

1. Go to your Space settings by clicking the ⚙️ icon in the lower-left corner.
2. Navigate to the **Users** or **Members** section.
3. Find the team member whose role you want to change.
4. Select a new role from the available options.

> Only **Administrators** can appoint other Administrators or Billing users. Managers can assign the Manager, Troubleshooter, and Observer roles.

### Adding a User to a Room

1. Open the Room you want to manage.
2. Click the ⚙️ icon next to the Room name.
3. Navigate to the access or members section.
4. Add the user from your Space's member list.

> Only **Administrators** and **Managers** can add or remove users from Rooms.

---

## Roles and Alert Management

Your role directly controls what you can do with alerts and notifications:

| Alert Action                               | Admin | Manager | Troubleshooter | Observer | Billing |
|:-------------------------------------------|:-----:|:-------:|:--------------:|:--------:|:-------:|
| **View alert & notification configurations** | ✅  | ✅      | ✅             | ✅       | —       |
| **Set up new notification integrations**   | ✅    | —       | —              | —        | —       |
| **Edit or delete notification integrations**| ✅   | —       | —              | —        | —       |
| **Create Space-wide alert silencing rules**| ✅    | ✅      | —              | —        | —       |
| **Manage/edit Space silencing rules**      | ✅    | ✅      | —              | —        | —       |
| **View Space silencing rules**             | ✅    | ✅      | ✅             | —        | —       |
| **Manage personal silencing rules**        | ✅    | ✅      | ✅             | ✅       | —       |
| **Manage personal notification settings**  | ✅    | ✅      | ✅             | ✅       | ✅      |

**Key points:**
- Only **Administrators** can create, edit, or delete the notification integrations that route alerts to tools like Slack, PagerDuty, or email.
- **Administrators and Managers** can create silencing rules that suppress alert notifications across the entire Space — useful for scheduled maintenance windows.
- **Troubleshooters and Observers** can set up personal silencing rules to manage their own alert noise, but cannot affect Space-wide notifications.
- All roles (except Billing) can see existing notification configurations, so everyone knows what alerts are active.

---

## Roles and Configuration Changes

Your role also controls access to the **Dynamic Configuration Manager** — the tool used to adjust how Netdata agents collect and process data:

| Configuration Action               | Admin | Manager | Troubleshooter | Observer | Billing |
|:-----------------------------------|:-----:|:-------:|:--------------:|:--------:|:-------:|
| **View all configurable items**    | ✅    | ✅      | ✅             | ✅       | ✅      |
| **Enable or disable items**        | ✅    | ✅      | —              | —        | —       |
| **Add new configurations**         | ✅    | ✅      | —              | —        | —       |
| **Update configurations**          | ✅    | ✅      | —              | —        | —       |
| **Remove configurations**          | ✅    | ✅      | —              | —        | —       |
| **Test configurations**            | ✅    | ✅      | —              | —        | —       |

> **Note:** A paid Netdata Cloud subscription is required for all configuration actions. On the free Community plan, users can only view the list of configurable items — they cannot make changes through the Dynamic Configuration Manager.

---

## Recommended Role Assignments by Team Type

| Team Member Type                            | Recommended Role    |
|:--------------------------------------------|:--------------------|
| DevOps / Platform Engineering lead          | Administrator       |
| SRE team lead or infrastructure manager     | Administrator or Manager |
| On-call engineers and SREs                  | Troubleshooter      |
| Developers needing visibility into services | Observer            |
| External stakeholders or customers          | Observer (in a dedicated Room) |
| Finance or procurement contacts             | Billing             |

---

## Quick Tips for Setting Up Access Controls

- **Start with the least privilege**: Assign the most restrictive role that still allows a person to do their job, then expand access as needed.
- **Use Rooms to scope access**: Create dedicated Rooms for different teams or services, then add Troubleshooters and Observers only to the Rooms relevant to them.
- **One Administrator minimum**: Always keep at least one active Administrator in your Space to avoid being locked out of critical settings.
- **Separate billing from operations**: Use the Billing role for finance team members so they never have access to your monitoring infrastructure.
- **Review access regularly**: Periodically check the Users list in your Space settings to make sure access levels are still appropriate as your team changes.