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

## Creating Aggregators

Once you've created 2 or more of a connection for a given plugin (say AWS), it's often simpler to [aggregate](managing/connections#querying-multiple-connections) these connections together as if they were a single connection.

When you add a connection to a workspace in Steampipe Cloud, we will suggest creating an aggregator if you don't have an aggregator for that plugin type, and you are adding the 2nd or greater connection of that plugin type.

In the below screenshot we're adding a second `Net` connection to the workspace named `all_net`. By default Steampipe Cloud will suggest creating an aggregator that targets all `Net` connections in the workspace.

This will mean that as more `Net` connections are added to the workspace, they will automatically be included in the `all_net` aggregator.

<img src="/images/docs/cloud/cloud-connections-create-aggregator.png" width="400pt"/>
<br />

If you don't want to include all connections, you can match using wildcards. In the below screenshot we've added `net*`, which will match all connections that start with `net`. We also allow you to choose from the existing connections in the workspace to target specific ones.  

<img src="/images/docs/cloud/cloud-connections-match-aggregator.png" width="400pt"/>
<br />

To access the aggregators, navigate to your workspace and go to **Settings** > **Connections**. You will see a list of connections and aggregators for the workspace. Click on an aggregator to view it. The **Connections** tab will list the connections that are currently included in the aggregator. You can change the matching rules of the aggregator by clicking **Manage connections** and entering your desired connections. We will give you an indication of how many connections have been matched by the proposed config. Once happy, click **Update**'

<img src="/images/docs/cloud/cloud-connections-edit-aggregator.png" width="400pt"/>
<br />