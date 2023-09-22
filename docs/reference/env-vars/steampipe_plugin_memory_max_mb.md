---
title: STEAMPIPE_PLUGIN_MEMORY_MAX_MB
sidebar_label: STEAMPIPE_PLUGIN_MEMORY_MAX_MB
---

# STEAMPIPE_PLUGIN_MEMORY_MAX_MB

Set a default memory soft limit for each plugin process. 

Note that each plugin can have its own `memory_max_mb` set in [a `plugin` definition](/docs/reference/config-files/plugin), and that value would override this default setting.

Set the `STEAMPIPE_PLUGIN_MEMORY_MAX_MB` to `0` disable the default soft memory limit.


## Usage 

Set the default plugin memory soft limit to 2GB:

```bash
export STEAMPIPE_PLUGIN_MEMORY_MAX_MB=2048
```

Disable the default plugin memory soft limit:

```bash
export STEAMPIPE_PLUGIN_MEMORY_MAX_MB=0
```