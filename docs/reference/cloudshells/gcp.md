---
title: Using Steampipe in Google Cloud Shell
sidebar_label: Google Cloud Shell
---

# Using Steampipe in Google Cloud Shell

Google Cloud Shell is a web-based environment preloaded with tools for managing Google Cloud. It leverages your Google cloud credentials for accessing data. This pre-configured environment with established credentials provides a quick and easy way to get started querying Google Cloud resources in Steampipe.


## About the Google Cloud Shell
The [Google Cloud Shell](https://cloud.google.com/shell) is available free to all Google Cloud customers. Because it's a free resource, Google imposes a few [limits on the service](https://cloud.google.com/shell/docs/quotas-limits). You can only use 50 hours of Google Cloud Shell each week. Additionally, the home directory of your cloud shell is deleted if you don't use your Cloud Shell for 120 days. An inactive Cloud Shell is terminated after one hour, and the longest session a Cloud Shell supports is 12 hours.

When the Google Cloud Shell terminates, only files inside the home directory are preserved. For that reason we want to install `steampipe` in the local directory and not in `/usr/local/bin`. For this reason all Steampipe commands will start with `./`.

To get started with the Google Cloud Shell, go to the [Google Cloud Console](https://console.cloud.google.com/). You want to select a Google Project that has billing enabled, then click on the Cloud Shell icon in the upper right.

!["Google Cloud Screenshot showing project selection and location of the Google Cloud Shell icon"](/images/docs/cloudshells/GCP_Cloud_Shell.png)


## Installing Steampipe in Google Cloud Shell

You'll want to run two commands. The first will download the latest linux version of Steampipe and install it in your local home directory. The second command will install the gcp plugin for Steampipe.

Download Steampipe from the official GitHub repository and untar it into your home directory
```bash
curl -s -L https://github.com/turbot/steampipe/releases/latest/download/steampipe_linux_amd64.tar.gz | tar -xzvf -
```

Install the GCP Plugin
```bash
./steampipe plugin install gcp
```

Your output should look something like:
```bash
chris@cloudshell:~$ curl -s -L https://github.com/turbot/steampipe/releases/latest/download/steampipe_linux_amd64.tar.gz | tar -xzvf -
steampipe
chris@cloudshell:~$ ./steampipe plugin install gcp

Installed plugin: gcp@latest v0.27.0
Documentation:    https://hub.steampipe.io/plugins/turbot/gcp

```

## Run your first query

To run a query, just type:
```bash
./steampipe query
```

To start, [this query](https://hub.steampipe.io/plugins/turbot/gcp/tables/gcp_project) will list the information on the currently active GCP Project.

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

You main find that the first time you want to run a query, a dialog box will appear prompt you to authorize CloudSell to use you credentials. You should just click "Authorize".

!["Screenshot of Google prompting a user to Authorize Cloud Shell"](/images/docs/cloudshells/Authorize_GCP_CloudShell.png)

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


