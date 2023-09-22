---
title: STEAMPIPE_MEMORY_MAX_MB
sidebar_label: STEAMPIPE_MEMORY_MAX_MB
---
# STEAMPIPE_MEMORY_MAX_MB

Set a soft memory limit for the `steampipe` process.

Set the `STEAMPIPE_MEMORY_MAX_MB` to `0` disable the soft memory limit.

## Usage 

Set the memory soft limit to 2GB:
```bash
export STEAMPIPE_MEMORY_MAX_MB=2048
```

Disable the memory soft limit:
```bash
export STEAMPIPE_MEMORY_MAX_MB=0
```