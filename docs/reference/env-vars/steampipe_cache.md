---
title: STEAMPIPE_CACHE
sidebar_label: STEAMPIPE_CACHE
---



### STEAMPIPE_CACHE
This environment variable has been deprecated and will be removed in a future version.  Please use the `cache` [connection options](reference/config-files/connection), which allow to set both global default and per-connection settings.

Enable or disable automatic caching of results.  This can significantly improve performance of some queries, at the expense of data freshness.  Caching is enabled by default in Steampipe 0.3.0 and later. 

Set `STEAMPIPE_CACHE` to `true` to enable caching, or `false` to disable.

#### Usage 
Disable caching:
```bash
export STEAMPIPE_CACHE=false 
```

Enable caching:
```bash
export STEAMPIPE_CACHE=true 
```
