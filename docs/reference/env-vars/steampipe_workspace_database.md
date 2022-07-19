---
title: STEAMPIPE_WORKSPACE_DATABASE
sidebar_label: STEAMPIPE_WORKSPACE_DATABASE
---


### STEAMPIPE_WORKSPACE_DATABASE
Sets the database that Steampipe will connect to. By default, Steampipe will use the locally installed database (`local`).  Alternately, you can use a remote database such as a Steampipe Cloud workspace database.

#### Usage 
Use a Steampipe cloud remote database:
```bash
export STEAMPIPE_CLOUD_TOKEN=spt_c6f5tmpe4mv9appio5rg_3jz0a8fakekeyf8ng72qr646
export STEAMPIPE_WORKSPACE_DATABASE=acme/prod
```

Use a remote postgres database via connection string:
```bash
export STEAMPIPE_WORKSPACE_DATABASE=postgresql://myusername:mypassword@acme-prod.apse1.db.cloud.turbot.io:9193/aaa000
```