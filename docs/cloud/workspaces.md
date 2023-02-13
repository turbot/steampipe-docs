---
title:  Workspaces
sidebar_label: Workspaces
---

# Managing Workspaces

## Overview
A **Workspace** provides a bounded context for managing, operating, and securing Steampipe resources.  A  workspace comprises a single Steampipe database instance as well as a directory of mod resources such as queries, benchmarks, and controls.  Workspaces allow you to separate your Steampipe instances for security, operational, or organizational purposes.  

The Steampipe Workspace DB instance is hosted in Steampipe Cloud, and available via a public Postgres endpoint.  You can query the workspace from the Steampipe Cloud web console, run queries or controls from a remote Steampipe CLI instance, or connect to your workspace from many third-party tools.


## Creating Workspaces
You can create workspaces from the **Workspaces** tab for your user account or organization.  From the **Workspaces** tab, click **New Workspace**.  Note that if the **New Workspace** button is disabled, you have likely reached a limit for your plan.  

Each workspace must have a **handle**.  The workspace handle is a friendly identifier for your workspace, and must be unique across your workspaces.  You can change the handle later, but note that the DNS name for your workspace includes the handle. If you change the handle, your workspace's DNS name will also change. Enter a handle for your workspace and click **Create Workspace**.

If you have no connections defined, you will be prompted to create one. In order to query data, you'll need at least one connection.  Click one of the plugins from the list.  Enter the required settings for the plugin.  You can verify your credentials using the **Test Connection** button, and then click **Create**. 

You will be prompted to add a connection to the workspace that you just created. Click **Add to Workspace** if you would like to add a connection to your workspace at this time.


## Managing Workspace Connections
You can add and remove connections from the **Settings** tab for your workspace.  Navigate to your workspace, go to the **Settings** tab, then click **Connections** from the menu on the left to see a list the connections that are currently attached to the workspace.  Click the **Add Connection** button to add a connection to your workspace.  To remove the connection from a workspace, click the options menu (sometimes called the 'hamburger' or 'three dots' button) to the right of the connection, select **Remove** from the menu.


Alternatively, you can attach connections to your workspace from the **Connections** tab for your user account or organization.  Navigate to your user account or organization, and click **Connections**.  You will see a list of connections.  Click on a connection in the list to view it.  The **Workspaces** tab will list the workspaces that are currently using the connection.  You can attach the connection to another workspace with the **Add to Workspace** button.  To remove the connection from a workspace, click the options menu (sometimes called the 'hamburger' or 'three dots' button) to the right of the workspace, select **Remove** from the menu.



## Managing Users
Workspaces in an organization can be shared with other members of your organization.  Your personal workspace cannot be shared.

You can add and remove workspace users from the **People** tab on your workspace page.  To add a user to your workspace, click **Add Member**.  Enter an email address or the user handle of an existing user and select a role for the user:

| Role | Description
|-|-
| **Reader**    | Has full read access to the workspace.
| **Operator**  | Has full read access to the workspace and can manage snapshots.
| **Owner**     | Has full administrative access to the workspace, aside from adding connections to the workspace which is reserved for org owners.


Click **Add**.  The user will receive an email invitation to join the organization.  

To remove a user from the organization, select the options menu button (hamburger) to the right of the user and click **Remove**.

## Deleting Workspaces
You can delete a workspace from its **Settings** tab.  From the **Workspaces** tab for your user account or organization, click on the workspace you wish to delete.  On the workspace page, go to the **Settings** tab, select **Advanced** from the menu on the left, and click **Delete workspace**.  You will be prompted to confirm deletion; enter the workspace name and click **Delete**.


## Workspace Maintenance
Your workspace may be updated and rebooted during the weekly maintenance window, Sundays 2:00am - 5:00am EST/EDT.  This window is not currently configurable.  

During maintenance, your workspaces will be updated to the latest Steampipe version and the latest plugin versions.  At this time, you cannot opt out of the weekly update.

