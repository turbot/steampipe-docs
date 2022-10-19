---
title: Using Steampipe in Azure Cloud Shell
sidebar_label: Azure Cloud Shell
---

# Using Steampipe in Azure Cloud Shell


[Azure Cloud Shell](https://shell.azure.com/) is a browser-based shell preloaded with tools to create and manage your Azure resources. Because the cloud shell includes the CLI and launches with your credentials, you can quickly install Steampipe along with the [Azure plugin](https://hub.steampipe.io/plugins/turbot/azure) and then instantly query your Azure resources.


## About the Azure Cloud Shell

The Cloud Shell is free to all Azure users. It comes with a few [limitations](https://learn.microsoft.com/en-us/azure/cloud-shell/limitations). For example, it will use an existing resource group but must be able to create storage accounts and file shares. You may incur a cost for the file share that persists your data. Also, since you are not a user with permission to `sudo` and cannot modify files or directories outside your home directory, we will install Steampipe there and refer to it as `./steampipe`. Finally, be aware that Azure will shut down your session if inactive for 20 minutes.

To start the shell, look for its icon on the top navigation bar of the Azure portal.

<div style={{"marginBottom":"2em","borderWidth":"thin", "borderStyle":"solid", "borderColor":"lightgray", "padding":"20px", "width":"90%"}}>
<img src="/images/docs/cloudshells/azure_cloudshell_console_screenshot.png" />
</div>

When you launch the shell for the first time, you will see this dialog box.

<div style={{"marginBottom":"2em","borderWidth":"thin", "borderStyle":"solid", "borderColor":"lightgray", "padding":"20px", "width":"90%"}}>
<img src="/images/docs/cloudshells/azure_prompt_to_create_storage_account.png" />
</div>

Click `Create storage` to continue.
## Installing Steampipe in Azure Cloud Shell

To install Steampipe, copy and run this command.

```bash
curl -s -L https://github.com/turbot/steampipe/releases/latest/download/steampipe_linux_amd64.tar.gz | tar -xzvf -
```
To install the Azure plugin, copy and run this command.
```
./steampipe plugin install azure
```

Your output should look like this:

```
Installed plugin: azure@latest v0.31.0
Documentation:    https://hub.steampipe.io/plugins/turbot/azure
```
## Run your first query
To launch Steampipe in query mode, do this:
```bash
./steampipe query
```

Steampipe prints a welcome message and a prompt.

```
Welcome to Steampipe v0.16.3
For more information, type .help
>
```

Let's query the [azure_subscription](https://hub.steampipe.io/plugins/turbot/azure/tables/azure_subscription) table.

```
> select
  subscription_id,
  display_name,
  state,
  authorization_source,
  subscription_policies
from
  azure_subscription;
+--------------------------------------+--------------+---------+----------------------+-----------------------+
| subscription_id                      | display_name | state   | authorization_source | subscription_policies |
+--------------------------------------+--------------+---------+----------------------+-----------------------+
| 3510aexd-53Qb-496d-8f30-53x9616fc6c1 | Stacy AAA    | Enabled | RoleBased            | {}                    |
+--------------------------------------+--------------+---------+----------------------+-----------------------+
```

That's it! You didn't have to read Azure API docs, or install an [API client library](https://learn.microsoft.com/en-us/azure/data-explorer/kusto/api/client-libraries), or learn how to use that client to make API calls and unpack JSON responses. Steampipe did all that for you. It works the same way for every Azure table. And because you can use SQL to join across Azure tables, it's easy to reason over your entire Azure infrastructure.

To see the full set of columns for any table, along with examples of their use, visit the [Steampipe Hub](https://hub.steampipe.io/plugins/turbot/azure/tables). For quick reference you can autocomplete table names directly in the shell.

<div style={{"marginBottom":"2em","borderWidth":"thin", "borderStyle":"solid", "borderColor":"lightgray", "padding":"20px", "width":"90%"}}>
<img src="/images/docs/cloudshells/azure_cloudshell_autocomplete.png" />
</div>

If you haven't used SQL lately, see our [handy guide](https://steampipe.io/docs/sql/steampipe-sql) for writing Steampipe queries.

