---
title: steampipe login
sidebar_label: steampipe login
---


## steampipe login
Log in to [Steampipe Cloud](/docs/cloud/overview).

The Steampipe CLI can interact with Steampipe Cloud to save and share snapshots, however this requires authenticating to Steampipe Cloud.  The `steampipe login` command launches an interactive process for logging in and obtaining a temporary (30 day) token. 

### Usage
```bash
steampipe login [flags] 
```

### Flags

| Flag | Description
|-|-
| `--cloud-host` | The Steampipe Cloud host to login to (defaults to `cloud.steampipe.io`).   See the [STEAMPIPE_CLOUD_HOST]("/docs/reference/env-vars/steampipe_cloud_host") environment variable documentation for details. 

### Examples

Login to `cloud.steampipe.io`:

```bash
steampipe login
```


The `steampipe login` command will launch your web browser to complete the login process.  After you have logged in, the browser will display a login code.    Enter the code when prompted:

```bash
$ steampipe login
Opening https://latestpipe.turbot.io/login/token?r=spttr_cdckfake6ap10t9dak0g_3u2k9hfake46g4o4wym7h8hw
Enter login code: 1581
Login successful for user johnsmyth
```
