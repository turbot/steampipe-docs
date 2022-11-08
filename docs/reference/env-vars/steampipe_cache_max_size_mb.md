---
title: STEAMPIPE_CACHE_MAX_SIZE_MB
sidebar_label: STEAMPIPE_CACHE_MAX_SIZE_MB
---

# STEAMPIPE_CACHE_MAX_SIZE_MB
Set the maximum size (in MB) of the query cache across all plugins.

If `STEAMPIPE_CACHE_MAX_SIZE_MB` is set, Steampipe will limit the query cache ***across all plugins*** to the specified size.  Each plugin version runs in a separate process, and each plugin process has its own cache.  When `STEAMPIPE_CACHE_MAX_SIZE_MB` is set, Steampipe divides the cache based on the total number of connections and allocates memory shares to each plugin process based on the number of connections for that plugin. 

For example, consider the following case:
- A Steampipe instance has:
  - 10 `aws` connections
  - 5 `azure` connections
  - 5 `gcp` connections
  - 1 `github` connection
  - 1 `rss` connection
  - 1 `net` connection
  - 2 `csv` connections
- `STEAMPIPE_CACHE_MAX_SIZE_MB` is set to `4000`

In this example, there are 25 total connections, so each connection's share is 4000 / 25 = ***160 MB***.  The plugin query caches will be capped as follows:


| Plugin  | Max Cache Size
|---------|-----------------
| `aws`   | **1600 MB** (10 connections x 160 MB)
| `azure` | **800 MB**  (5 connections x 160 MB)
| `gcp`   | **800 MB**  (5 connections x 160 MB)
| `github`| **160 MB**  (1 connection x 160 MB)
| `rss`   | **160 MB**  (1 connection x 160 MB)
| `net`   | **160 MB**  (1 connection x 160 MB)
| `csv`   | **320 MB**  (2 connections x 160 MB


By default, Steampipe does not limit the size of the query cache.  

`STEAMPIPE_CACHE_MAX_SIZE_MB` only works with plugins compiled with [Steampipe Plugin SDK](https://github.com/turbot/steampipe-plugin-sdk) version 4.0.0 and later.

## Usage 
Limit cache to 4GB:
```bash
export STEAMPIPE_CACHE_MAX_SIZE_MB=4096 
```

Reset caching to unlimited:
```bash
unset STEAMPIPE_CACHE_MAX_SIZE_MB
```
