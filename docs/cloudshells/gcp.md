---
title: Using Steampipe in Google CloudShell
sidebar_label: Google CloudShell
---

Google Cloud Shell is a web-based environment preloaded with tools for managing Google Cloud. It leverages your Google cloud credentials for accessing data.


## About the Google Cloud Shell
- epthermal
- timeouts
- install locally

## Installing Steampipe in Google Cloud Shell

```bash
chris@cloudshell:~$ curl -s -L https://github.com/turbot/steampipe/releases/latest/download/steampipe_linux_amd64.tar.gz | tar -xzvf -
steampipe
chris@cloudshell:~$ ./steampipe plugin install gcp

Installed plugin: gcp@latest v0.27.0
Documentation:    https://hub.steampipe.io/plugins/turbot/gcp

chris@cloudshell:~$ ./steampipe query
Welcome to Steampipe v0.16.3
For more information, type .help
>

```

## Run your first query

This query will list the information on the currently active GCP Project.

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

To view the information about your GCP Organization, you can run:

```sql
select
  display_name,
  organization_id,
  lifecycle_state,
  creation_time
from
  gcp_organization;
```

