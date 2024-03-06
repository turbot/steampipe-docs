---
title: PIPES_TOKEN
sidebar_label: PIPES_TOKEN
---


# PIPES_TOKEN
Sets the [Turbot Pipes authentication token](https://turbot.com/pipes/docs/profile#tokens). This is used when connecting to Turbot Pipes workspaces.  

By default, Steampipe will use the token obtained by running `steampipe login`, but you may also set this to a user-generated [API token](https://turbot.com/pipes/docs/profile#tokens).  You can manage your API tokens from the **Settings** page for your user account in Turbot Pipes.


## Usage 
Set your API token:
```bash
export PIPES_TOKEN=tpt_c6f5tmpe4mv9appio5rg_3jz0a8fakekeyf8ng72qr646
```
