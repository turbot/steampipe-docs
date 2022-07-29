---
title:  Connecting to Your Workspace from the Steampipe CLI
sidebar_label: Steampipe CLI
---
# Connecting to Your Workspace from the Steampipe CLI

You can use the [Steampipe CLI](https://steampipe.io/downloads) to query your workspace database, or to run benchmarks and controls against your workspace.  You will need to create an [API token](/docs/cloud/profile#api-tokens), and then set the `STEAMPIPE_CLOUD_TOKEN` [environment variable](reference/env-vars/overview) to authenticate: 


```bash
export STEAMPIPE_CLOUD_TOKEN=spt_c6f5tmpe4mv9appio5rg_3jz0a8fakekeyf8ng72qr646
```



The **Connect** tab for your workspace provides examples that you can copy, paste and run to run an interactive query, run an interactive dashboard, or run a benchmark against your cloud workspace!


<img src="/images/docs/cloud/int_cli.png" width="600pt"/>
<br />

