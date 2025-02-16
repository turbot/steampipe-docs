---
title: Using Steampipe in Google Cloud Shell
sidebar_label: Google Cloud Shell
---

# Using Steampipe in Google Cloud Shell

Google Cloud Shell is a web-based environment preloaded with tools for managing Google Cloud.
Because Google's cloud shell includes the CLI and launches with your credentials, you can quickly install Steampipe along with the GCP plugin and then instantly query your cloud resources.


## About the Google Cloud Shell
The [Google Cloud Shell](https://cloud.google.com/shell) is free to all Google Cloud customers. Because it's a free resource, Google imposes a few [limits on the service](https://cloud.google.com/shell/docs/quotas-limits). You can only use 50 hours of Google Cloud Shell each week. Additionally, the home directory of your cloud shell is deleted if you don't use your Cloud Shell for 120 days. An inactive Cloud Shell is shut down after one hour, and an active session can run at most for 12 hours.

When the Google Cloud Shell terminates, only files inside the home directory are preserved. For that reason we want to install the Steampipe binary in the local directory and not in `/usr/local/bin`. For this reason all Steampipe commands will start with `./`.

To get started with the Google Cloud Shell, go to the [Google Cloud Console](https://console.cloud.google.com/). Select a Google Project that has billing enabled, then click on the Cloud Shell icon in the upper right.

<div style={{"marginBottom":"2em","borderWidth":"thin", "borderStyle":"solid", "borderColor":"lightgray", "padding":"20px", "width":"90%"}}>
<img alt="Google Cloud Screenshot showing project selection and location of the Google Cloud Shell icon" src="/cloudshells/GCP_Cloud_Shell.png" />
</div>

## Installing Steampipe in Google Cloud Shell

To install Steampipe, copy and run this command.
```bash
curl -s -L https://github.com/turbot/steampipe/releases/latest/download/steampipe_linux_amd64.tar.gz | tar -xzf -
```

To install the GCP plugin, copy and run this command.
```bash
./steampipe plugin install gcp
```

Your output should look something like:
```bash

Installed plugin: gcp@latest v0.27.0
Documentation:    https://hub.steampipe.io/plugins/turbot/gcp

```

## Run your first query

To run a query, type:
```bash
./steampipe query
```

Let's query the [gcp_project](https://hub.steampipe.io/plugins/turbot/gcp/tables/gcp_project) table.

```sql
select
  name,
  project_id,
  project_number,
  lifecycle_state,
  create_time
from
  gcp_project;
```

You may find that the first time you run a query, a dialog box will prompt you to authorize Cloud Shell to use you credentials. Click "Authorize".

<div style={{"marginBottom":"2em","borderWidth":"thin", "borderStyle":"solid", "borderColor":"lightgray", "padding":"20px", "width":"90%"}}>
<img alt="Screenshot of Google prompting a user to Authorize Cloud Shell" src="/cloudshells/Authorize_GCP_CloudShell.png" />
</div>

 That's it! You didn't have to read [GCP API docs](https://cloud.google.com/apis/docs/overview), install an [API client library](https://cloud.google.com/python/docs/reference), or learn how to use that client to make API calls and unpack JSON responses. Steampipe did all that for you. It works the same way for every GCP table. And because you can use SQL to join across multiple tables representing GCP services, it's easy to reason over your entire GCP organization.


To view the information about your [GCP Organization](https://hub.steampipe.io/plugins/turbot/gcp/tables/gcp_organization), you can run:

```sql
select
  display_name,
  organization_id,
  lifecycle_state,
  creation_time
from
  gcp_organization;
```

To see the full set of columns for any table, along with examples of their use, visit the [Steampipe Hub](https://hub.steampipe.io/plugins/turbot/gcp/tables). For quick reference you can autocomplete table names directly in the shell.


If you haven't used SQL lately, see our [handy guide](https://steampipe.io/docs/sql/steampipe-sql) for writing Steampipe queries.






