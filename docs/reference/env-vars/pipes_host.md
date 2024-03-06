---
title: PIPES_HOST
sidebar_label: PIPES_HOST
---

# PIPES_HOST
Sets the Turbot Pipes host used when connecting to Turbot Pipes workspaces.  The default is `pipes.turbot.com` -- you only need to set this if you are connecting to a remote Turbot Pipes database that is NOT hosted in `pipes.turbot.com`, such as an enterprise tenant instance.  Your `PIPES_TOKEN` must be valid for the `PIPES_HOST`.


## Usage 
Default to use workspaces in `test.steampipe.io`:

```bash
export PIPES_HOST=test.turbot.com
export PIPES_TOKEN=tpt_c6f5tmpe4mv9appio5rg_3jz0a8fakekeyf8ng72qr646
```