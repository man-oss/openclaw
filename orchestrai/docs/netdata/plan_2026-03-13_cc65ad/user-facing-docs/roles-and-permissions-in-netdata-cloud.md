## Overview

Netdata Cloud uses **Role-Based Access Control (RBAC)** to let you decide exactly what each team member can see and do within your monitoring environment. By assigning the right role to each person, you can keep sensitive data secure, prevent accidental configuration changes, and give every team member access to exactly what they need.

Roles are assigned at the **Space level** (your overall monitoring environment), but some permissions — like which dashboards and nodes a person can see — are further controlled by **Room membership** (the focused monitoring groups within a Space).

---

## The Five Roles

### 👑 Administrator

**Best for:** Team leads, platform owners, or anyone who needs complete control.

Administrators have unrestricted access to everything in the Space. They can manage users, connect and remove nodes, configure alert notifications, handle billing, and delete or rename the Space itself. Admins automatically have access to every Room in the Space — they are never locked out.

### 🔧 Manager

**Best for:** Team managers or senior engineers who oversee infrastructure and teams, but shouldn't touch billing.

Managers can invite and remove users, create and delete Rooms, assign nodes to Rooms, and manage monitoring configurations. Like Admins, Managers can see and join any Room in the Space. They cannot access billing, change Space-level settings (name, description), or appoint Admins or Billing users — only Admins can do that.

> **Available on:** Homelab, Business, and Enterprise plans.

### 🔍 Troubleshooter

**Best for:** On-call engineers, SREs, or DevOps staff who actively investigate and fix problems.

Troubleshooters can view dashboards, explore metrics, create and manage their own dashboards, run read-only diagnostic functions, and set personal alert silencing rules. They **must be explicitly assigned to Rooms** — they cannot browse the full list of Rooms in the Space on their own. They cannot manage users, configure Space-wide notifications, or change any infrastructure settings.

> **Available on:** Homelab, Business, and Enterprise plans.

### 👁️ Observer

**Best for:** Stakeholders, customers, or anyone who needs read-only visibility into specific systems.

Observers can view dashboards and metrics data in the specific Rooms they've been added to. They can create and manage their own personal dashboards, run read-only diagnostic functions, and set personal notification preferences. They cannot make any changes to settings, configurations, or users. This role is ideal for giving a customer visibility into their own dedicated monitoring Room without exposing the rest of your infrastructure.

> **Available on:** Homelab, Business, and Enterprise plans.

### 💳 Billing User

**Best for:** Finance or procurement staff who manage payments but don't need monitoring access.

Billing users can view the current plan and usage, see invoices, manage payment methods, and update the billing email address. They have no access to monitoring data, dashboards, nodes, or user management. Only Admins can upgrade or change the subscription plan itself.

> **Available on:** Homelab, Business, and Enterprise plans.

---

## What Each Role Can Do: At a Glance

| Action | Admin | Manager | Troubleshooter | Observer | Billing |
|--------|:-----:|:-------:|:--------------:|:--------:|:-------:|
| View dashboards and metrics | ✅ | ✅ | ✅ | ✅ | — |
| Create dashboards | ✅ | ✅ | ✅ | ✅ | — |
| Edit dashboards (others') | ✅ | ✅ | ✅ | — | — |
| Run diagnostic functions | ✅ | ✅ | ✅ (read-only) | ✅ (read-only) | — |
| Invite users to the Space | ✅ | ✅ | — | — | — |
| Remove users from the Space | ✅ | ✅ | — | — | — |
| Assign roles (Admin/Billing) | ✅ | — | — | — | — |
| Assign roles (Manager/Troubleshooter/Observer) | ✅ | ✅ | — | — | — |
| Create and delete Rooms | ✅ | ✅ | — | — | — |
| Add nodes to Rooms | ✅ | ✅ | — | — | — |
| Connect/remove nodes from Space | ✅ | — | — | — | — |
| Configure Space-wide alert notifications | ✅ | — | — | — | — |
| Add/edit alert silencing rules (Space-wide) | ✅ | ✅ | — | — | — |
| Set personal notification preferences | ✅ | ✅ | ✅ | ✅ | ✅ |
| Manage monitoring configurations | ✅ | ✅ | — | — | — |
| View plan and billing details | ✅ | — | — | — | ✅ |
| Update subscription plan | ✅ | — | — | — | — |
| Manage payment methods and invoices | ✅ | — | — | — | ✅ |
| Rename or delete the Space | ✅ | — | — | — | — |

---

## Space-Level vs. Room-Level Permissions

Understanding the two layers of access helps you set up the right controls for your team.

### Space-Level Access
Your **Space** is the top-level environment that contains all your nodes, Rooms, and team members. Space-level permissions govern actions that affect the entire monitoring environment — such as inviting users, managing billing, connecting nodes, and configuring global alert notifications.

- **Admins and Managers** can see the full list of Rooms in a Space and join any of them freely.
- **Troubleshooters and Observers** can only see and access the Rooms they have been explicitly added to.

### Room-Level Access
**Rooms** are focused groups of nodes within your Space. They allow you to give specific team members targeted visibility — for example, a database team only seeing database servers, or a customer only seeing their own infrastructure.

- Admins and Managers control who gets added to which Rooms.
- Troubleshooters and Observers are confined to the Rooms they are assigned to — they cannot discover or join other Rooms on their own.
- All Rooms are visible to Admins and Managers, regardless of assignment.

> 💡 **Tip:** Use Rooms to give customers or third-party contractors Observer access to a dedicated Room without revealing the rest of your infrastructure.

---

## How to Assign and Change Roles

### Inviting a New Team Member

1. In your Space, open the left sidebar and look for the **"Invite Users"** option.
2. Enter the person's email address.
3. Choose which **Rooms** they should have access to.
4. Select their **role** (Admin, Manager, Troubleshooter, Observer, or Billing).
5. Send the invitation.

The invited person will receive an email and can join the Space once they accept.

### Changing an Existing Member's Role

1. Go to your **Space settings** (click the ⚙️ icon in the lower-left corner of the sidebar).
2. Navigate to the **Users** section.
3. Find the team member whose role you want to change.
4. Select a new role from the available options.

> **Who can change roles?**
> - Only **Admins** can assign or change the Admin and Billing roles.
> - **Admins and Managers** can assign or change the Manager, Troubleshooter, and Observer roles.

### Adding a User to a Room

1. Open the Room you want to manage.
2. Click the ⚙️ icon next to the Room name.
3. Go to the **Room access** settings.
4. Add existing Space members to the Room.

---

## Roles and Alert Management

Your role directly controls what you can do with alerts and notifications:

| Alert Action | Admin | Manager | Troubleshooter | Observer | Billing |
|---|:---:|:---:|:---:|:---:|:---:|
| View all alert notifications configured for the Space | ✅ | ✅ | ✅ | ✅ | — |
| Add / edit / delete Space-wide notification methods | ✅ | — | — | — | — |
| Enable / disable Space-wide notification methods | ✅ | — | — | — | — |
| Create Space-wide alert silencing rules | ✅ | ✅ | — | — | — |
| Edit / delete Space-wide alert silencing rules | ✅ | ✅ | — | — | — |
| View Space-wide alert silencing rules | ✅ | ✅ | ✅ | — | — |
| Set personal alert silencing rules | ✅ | ✅ | ✅ | ✅ | — |

**Key points:**
- Only **Admins** can set up or change the notification channels (email, Slack, PagerDuty, etc.) used to deliver alerts across the whole Space.
- **Admins and Managers** can create Space-wide silencing rules — for example, to suppress alerts during a planned maintenance window.
- **Troubleshooters and Observers** can manage their own personal notification preferences, but cannot affect Space-wide alert routing.

---

## Roles and Configuration Changes

Netdata's **Dynamic Configuration Manager** lets you change monitoring settings (such as enabling or disabling data collectors and alert rules) directly from the Cloud interface. Role permissions for this feature are:

| Configuration Action | Admin | Manager | Troubleshooter | Observer | Billing |
|---|:---:|:---:|:---:|:---:|:---:|
| View all configurable items | ✅ | ✅ | ✅ | ✅ | ✅ |
| Enable / disable items | ✅ | ✅ | — | — | — |
| Add / update / remove configurations | ✅ | ✅ | — | — | — |
| Test configurations | ✅ | ✅ | — | — | — |

> **Note:** Making configuration changes requires a paid Netdata Cloud subscription. All roles can view configuration items on any plan, but only Admins and Managers on paid plans can make changes.

---

## Plan Availability

Some roles are only available on paid plans:

| Role | Community (Free) | Homelab | Business | Enterprise |
|------|:---:|:---:|:---:|:---:|
| Administrator | ✅ | ✅ | ✅ | ✅ |
| Manager | — | ✅ | ✅ | ✅ |
| Troubleshooter | — | ✅ | ✅ | ✅ |
| Observer | — | ✅ | ✅ | ✅ |
| Billing | — | ✅ | ✅ | ✅ |

On the free Community plan, all members have Administrator-level access. Upgrading to a paid plan unlocks the full set of roles so you can apply the principle of least privilege across your team.

---

## Recommended Role Assignments by Team Type

| Team Member | Recommended Role | Reason |
|---|---|---|
| Platform/Infrastructure owner | **Administrator** | Needs full control over nodes, users, and billing |
| Engineering team lead | **Manager** | Oversees team and infrastructure without billing access |
| On-call / SRE engineer | **Troubleshooter** | Needs to investigate issues and run diagnostics |
| Read-only stakeholder or auditor | **Observer** | Can monitor dashboards without risk of changes |
| Finance / procurement contact | **Billing** | Handles invoices and payments only |
| External customer | **Observer** (in a dedicated Room) | Scoped visibility to their own infrastructure only |