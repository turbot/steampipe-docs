---
title: Using Steampipe with Azure Cloud Shell
sidebar_label: Azure Cloud Shell
---

# Using Steampipe in Azure Cloud Shell


Azure Cloud Shell is an interactive browser-based shell experience with pre-configured tools to manage and develop your Azure resources. It is assigned per user account and gets securely authenticated automatically with each session. This lets you get started querying your Azure resources in Steampipe effortlessly.


## About the Azure Cloud Shell

The [Azure Cloud Shell](https://shell.azure.com/) is available to all azure users. Azure imposes certain [limitations](https://learn.microsoft.com/en-us/azure/cloud-shell/limitations) and  requires An Azure file share to be mounted, for which your subscription must be able to set up storage resources to access Cloud Shell. Since it creates resources you may incur a cost based only on the Azure Files share used to persist your data. The permissions are set as regular users without sudo access which does not allow installation outside your $Home directory. An inactive session gets terminated after 20 minutes. All Steampipe commands will start with `./`.


<screenshot of shell>

## Installing Steampipe in Azure Cloud Shell

To install Steampipe, copy and run this command.

```bash
curl -s -L https://github.com/turbot/steampipe/releases/latest/download/steampipe_linux_amd64.tar.gz | tar -xzvf -
```
To install the Azure plugin, copy and run this command.
```
./steampipe plugin install azure
```
steampipe
./steampipe plugin install azure

Installed plugin: azure@latest v0.31.0
Documentation:    https://hub.steampipe.io/plugins/turbot/azure

rahul [ ~ ]$ ./steampipe query
Welcome to Steampipe v0.16.3
For more information, type .help
>

```

## Run your first query

To launch Steampipe in query mode, type `./steampipe query`.

```bash
./steampipe query
```

Steampipe prints a welcome message and a prompt.

```
Welcome to Steampipe v0.16.3
For more information, type .help
>
```

To list the information on the currently active Azure Subscription, enter this query.
```sql
select
  id,
  subscription_id,
  display_name,
  tenant_id,
  state,
  authorization_source,
  subscription_policies
from
  azure_subscription;
```

To list and view the information about your Azure storage accounts, you can run:

```sql
select
  name,
  sku_name,
  sku_tier,
  primary_location,
  secondary_location
from
  azure_storage_account;
```
<screenshot of output>

To see the full set of columns for any table, along with examples of their use, visit the [Steampipe Hub](https://hub.steampipe.io). For storage accounts, visit [azure_storage_account](https://hub.steampipe.io/plugins/turbot/azure/tables/azure_storage_account). For quick reference you can autocomplete table names directly in the shell.

<screenshot for auto-complete>

You main find that the first time you open Cloud Shell to run a query, a dialog box will appear prompting you to select the subscription to create the required resources.

<Screenshot of the create dialog box>

