---
title: STEAMPIPE_CACHE
sidebar_label: STEAMPIPE_CACHE
---

# STEAMPIPE_CACHE

Enable or disable automatic caching of results.  This can significantly improve performance of some queries, at the expense of data freshness.  Caching is enabled by default.

Set `STEAMPIPE_CACHE` to `true` to enable caching, or `false` to disable.

Note that when connecting to a remote Steampipe database instance, `STEAMPIPE_CACHE` can be set at BOTH the server and the client:
- Setting `STEAMPIPE_CACHE` on the host where the Steampipe database is running controls whether caching is enabled at all (the same as setting the `cache` argument in [database options](/docs/reference/config-files/options#database-options)).
- Setting `STEAMPIPE_CACHE` on the remote client controls the caching options for this session only (the same as setting the `cache` argument in the [workspace](/docs/reference/config-files/workspace)).
- If the server has caching enabled a client may choose to disable it for their session, but if the server disables caching then no client can enable it.


## Usage 
Disable caching:
```bash
export STEAMPIPE_CACHE=false 
```

Enable caching:
```bash
export STEAMPIPE_CACHE=true 
```
