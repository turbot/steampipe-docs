---
title: STEAMPIPE_CACHE_MAX_SIZE_MB
sidebar_label: STEAMPIPE_CACHE_MAX_SIZE_MB
---

# STEAMPIPE_CACHE_MAX_SIZE_MB

Set the maximum size (in MB) of the query cache. This size is ***one total for all plugins***.

`STEAMPIPE_CACHE_MAX_SIZE_MB` sets the same value as `cache_max_size_mb` in the [database options](/docs/reference/config-files/options#database-options). If you set both, `STEAMPIPE_CACHE_MAX_SIZE_MB` takes precedence.

By default, Steampipe does not limit the size of the query cache. A value of `0` also means no limit.

## How Steampipe shares the total

Each plugin runs in a separate process, and each plugin process has its own query cache. Steampipe divides the total between the plugins. Each plugin gets a share in proportion to its number of connections. Aggregator connections do not count.

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

In this example, there are 25 connections in total, so each connection's share is 4000 / 25 = ***160 MB***. The plugin query caches are capped as follows:


| Plugin  | Max Cache Size
|---------|-----------------
| `aws`   | **1600 MB** (10 connections x 160 MB)
| `azure` | **800 MB**  (5 connections x 160 MB)
| `gcp`   | **800 MB**  (5 connections x 160 MB)
| `github`| **160 MB**  (1 connection x 160 MB)
| `rss`   | **160 MB**  (1 connection x 160 MB)
| `net`   | **160 MB**  (1 connection x 160 MB)
| `csv`   | **320 MB**  (2 connections x 160 MB)

Steampipe rounds each share down to a whole MB, so the shares never add up to more than the total. Each plugin gets at least 1 MB.

Steampipe calculates the share of a plugin when the plugin starts. If you add or remove connections, a plugin that is already running keeps its share until it restarts.

Do not set the total too low. A small share can be smaller than one large page of query results (a page is up to 1,000 rows). Steampipe cannot cache a page that does not fit.

## Notes

This is a server setting. Set it in the environment of the command that starts the Steampipe service. When connecting to a remote database, setting `STEAMPIPE_CACHE_MAX_SIZE_MB` on the client has no effect.

`STEAMPIPE_CACHE_MAX_SIZE_MB` is not the same as [STEAMPIPE_PLUGIN_MEMORY_MAX_MB](/docs/reference/env-vars/steampipe_plugin_memory_max_mb). `STEAMPIPE_PLUGIN_MEMORY_MAX_MB` sets a soft memory target for garbage collection in each plugin process (`GOMEMLIMIT`). It does not limit the size of the query cache.

`STEAMPIPE_CACHE_MAX_SIZE_MB` only works with plugins compiled with [Steampipe Plugin SDK](https://github.com/turbot/steampipe-plugin-sdk) version 4.0.0 and later.

## Usage
Limit the cache for all plugins to 4 GB in total:
```bash
export STEAMPIPE_CACHE_MAX_SIZE_MB=4096
```

Reset caching to unlimited:
```bash
unset STEAMPIPE_CACHE_MAX_SIZE_MB
```
