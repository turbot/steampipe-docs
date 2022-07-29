---
title:  Connections
sidebar_label: Connections
---

# Managing Connections

A Steampipe [Connection](managing/connections) represents a set of tables for a single data source. Each connection is represented as a distinct Postgres schema.  In order to query data, you'll need at least one connection.  

Connections are defined at the user account or organization level, and they can be shared by multiple workspaces within the account or organization. 


## Creating Connections

Connections can be created or deleted from the **Connections** tab for your user account or organization.  To add a connection, click **New Connection**, then choose one of the plugins from the list.  Enter the required settings for the plugin.  Use the **Test Connection** button to verify your credentials, then click **Create**. 

After the connection is created, you may associate it with a workspace.   Click **Add to Workspace** if you wish to add it to a workspace now, or **Skip** if you don't want to add it to a workspace at this time. Note that the wizard only prompts to add it to a single workspace, but you can attach your connection to additional workspaces at any time.


## Deleting Connections

To permanently delete a connection, navigate to the the **Connections** tab for your user account or organization.  From the list, click the connection that you wish to delete.  From the properties page for the connection, go to the **Settings** tab and click **Delete Connection**.  You will be prompted to confirm deletion; enter the connection name and click **Delete**


## Adding Connections to Workspaces

Once a connection is created, you must add it to any workspaces that you wish to use the connection.  

You can add and remove connections from the **Settings** tab for your workspace.  Navigate to your workspace, go to the **Settings** tab, then click **Connections** from the menu on the left to see a list the connections that are currently attached to the workspace.  Click the **Add Connection** button to add a connection to your workspace.  To remove the connection from a workspace, click the options menu (sometimes called the 'hamburger' or 'three dots' button) to the right of the connection, select **Remove** from the menu.


Alternatively, you can attach connections to your workspace from the **Connections** tab for your user account or organization.  Navigate to your user account or organization, and click **Connections**.  You will see a list of connections.  Click on a connection in the list to view it.  The **Workspaces** tab will list the workspaces that are currently using the connection.  You can attach the connection to another workspace with the **Add to Workspace** button.  To remove the connection from a workspace, click the options menu (sometimes called the 'hamburger' or 'three dots' button) to the right of the workspace, select **Remove** from the menu.
