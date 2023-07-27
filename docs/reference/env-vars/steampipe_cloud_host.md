---
title: STEAMPIPE_CLOUD_HOST
sidebar_label: STEAMPIPE_CLOUD_HOST
---

# STEAMPIPE_CLOUD_HOST
Sets a remote cloud host used when connecting to Turbot Pipes workspaces.  The default is `pipes.turbot.com` -- you only need to set this if you are connecting to a remote Turbot Pipes database that is NOT hosted in `pipes.turbot.com`, such as a dev/test instance.  Your `STEAMPIPE_CLOUD_TOKEN` must be valid for the `STEAMPIPE_CLOUD_HOST`.

Alternatively, you can set the cloud host in the [`PIPES_HOST` environment variable](/docs/reference/env-vars/pipes_host). Note that `PIPES_HOST` has lower precedence than `STEAMPIPE_CLOUD_HOST` - if both are set then `STEAMPIPE_CLOUD_HOST` will be used.

## Usage 
Default to use workspaces in `test.steampipe.io`:

```bash
export STEAMPIPE_CLOUD_HOST=test.steampipe.io
export STEAMPIPE_CLOUD_TOKEN=tpt_c6f5tmpe4mv9appio5rg_3jz0a8fakekeyf8ng72qr646
```