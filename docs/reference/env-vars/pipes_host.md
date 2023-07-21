---
title: PIPES_HOST
sidebar_label: PIPES_HOST
---

# PIPES_HOST
Sets the Turbot Pipes host used when connecting to Turbot Pipes workspaces.  The default is `pipes.turbot.com` -- you only need to set this if you are connecting to a remote Turbot Pipes database that is NOT hosted in `pipes.turbot.com`, such as a dev/test instance.  Your `PIPES_TOKEN` must be valid for the `PIPES_HOST`.

Alternatively, you can set the cloud host in the [`STEAMPIPE_CLOUD_HOST` environment variable](/docs/reference/env-vars/steampipe_cloud_host).  Note that `PIPES_HOST` has lower precedence than `STEAMPIPE_CLOUD_HOST` - if both are set then `STEAMPIPE_CLOUD_HOST` will be used.

## Usage 
Default to use workspaces in `test.steampipe.io`:

```bash
export PIPES_HOST=test.turbot.com
export PIPES_TOKEN=spt_c6f5tmpe4mv9appio5rg_3jz0a8fakekeyf8ng72qr646
```