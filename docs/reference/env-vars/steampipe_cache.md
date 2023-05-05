---
title: STEAMPIPE_CACHE
sidebar_label: STEAMPIPE_CACHE
---

# STEAMPIPE_CACHE

Enable or disable automatic caching of results.  This can significantly improve performance of some queries, at the expense of data freshness.  Caching is enabled by default in Steampipe 0.3.0 and later. 

Set `STEAMPIPE_CACHE` to `true` to enable caching, or `false` to disable.

## Usage 
Disable caching:
```bash
export STEAMPIPE_CACHE=false 
```

Enable caching:
```bash
export STEAMPIPE_CACHE=true 
```
