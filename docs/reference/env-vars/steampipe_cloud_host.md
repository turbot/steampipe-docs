---
title: STEAMPIPE_CLOUD_HOST
sidebar_label: STEAMPIPE_CLOUD_HOST
---

# STEAMPIPE_CLOUD_HOST
Sets the Turbot Pipes host.  This is used when connecting to Turbot Pipes workspaces.  The default is `pipes.turbot.com` -- you only need to set this if you are connecting to a remote Turbot Pipes database that is NOT hosted in `pipes.turbot.com`, such as a dev/test instance.  Your `STEAMPIPE_CLOUD_TOKEN` must be valid for the `STEAMPIPE_CLOUD_HOST`.

## Usage 
Default to use workspaces in `test.steampipe.io`:

```bash
export STEAMPIPE_CLOUD_HOST=test.steampipe.io
export STEAMPIPE_CLOUD_TOKEN=spt_c6f5tmpe4mv9appio5rg_3jz0a8fakekeyf8ng72qr646
```