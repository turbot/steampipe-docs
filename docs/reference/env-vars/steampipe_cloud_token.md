---
title: STEAMPIPE_CLOUD_TOKEN
sidebar_label: STEAMPIPE_CLOUD_TOKEN
---


# STEAMPIPE_CLOUD_TOKEN
Sets the [Turbot Pipes authentication token](https://turbot.com/pipes/docs/profile#tokens). This is used when connecting to Turbot Pipes workspaces.  

By default, Steampipe will use the token obtained by running `steampipe login`, but you may also set this to user-generated [API token](https://turbot.com/pipes/docs/profile#tokens).  You can manage your API tokens from the **Settings** page for your user account in Turbot Pipes.

## Usage 
Set your api token:
```bash
export STEAMPIPE_CLOUD_TOKEN=spt_c6f5tmpe4mv9appio5rg_3jz0a8fakekeyf8ng72qr646
```
