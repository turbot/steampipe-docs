---
title: STEAMPIPE_CACHE_TTL
sidebar_label: STEAMPIPE_CACHE_TTL
---

# STEAMPIPE_CACHE_TTL

The amount of time to cache results, in seconds. The default is `300` (5 minutes).

Caching must be enabled for this setting to take effect.

## Usage 
Set TTL to 1 minute
```bash
export STEAMPIPE_CACHE_TTL=60 
```