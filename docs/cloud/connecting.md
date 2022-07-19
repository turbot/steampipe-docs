---
title:  Connecting to your Workspace
sidebar_label: Connecting to your Workspace
---

# Connecting to Your Workspace

Your Steampipe workspace database has a public IP address, allowing you to connect to it from anywhere using the Steampipe CLI or other standard tools and utilities that support Postgres.

The **Connect** tab for your workspace will provide the Postgres connection string.  Note that the connection string includes your password.  It is masked in the web console display, but you can click **Copy connection string** to copy it so you can paste it into your tool's configuration screen.


## Connecting from Steampipe CLI
You can use the [Steampipe CLI](https://steampipe.io/downloads) to query your workspace database, or to run benchmarks and controls against your workspace.  You can use [environment variables](reference/env-vars/overview) to specify your Steampipe Cloud options:

```bash
export STEAMPIPE_CLOUD_TOKEN=spt_c6f5tmpe4mv9appio5rg_3jz0a8fakekeyf8ng72qr646
export STEAMPIPE_WORKSPACE_DATABASE=acme/prod 

steampipe query

```
The CLI works exactly the same as for the embedded database, including running inline queries:
```bash
steampipe query "select * from aws_account"
```

And even running benchmarks!
```bash
steampipe check all
```

Alternatively, you can specify cloud options on the [command line](reference/cli/overview):
```bash
steampipe --cloud-token=spt_c6f5tmpe4mv9appio5rg_3jz0a8fakekeyf8ng72qr646 --workspace-database=acme/prod check all
```


