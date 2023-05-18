---
title: STEAMPIPE_CACHE_MAX_TTL
sidebar_label: STEAMPIPE_CACHE_MAX_TTL
---

# STEAMPIPE_CACHE_MAX_TTL

The maximum amount of time to cache query results, in seconds. The default is `300` (5 minutes).

Caching must be enabled for this setting to take effect.

This is a server setting, not a client setting. When connecting to a Steampipe database, you are subject to the `STEAMPIPE_CACHE_MAX_TTL` set on the server.  You can set the [STEAMPIPE_CACHE_TTL](reference/env-vars/steampipe_cache_ttl) (or `cache_ttl` in a [workspace](/docs/reference/config-files/workspace)) from your client to *reduce* the TTL for your session but not to expand it. The net effect for your session will be the lower of the two values.


## Usage 
Set the maximum query cache TTL to 10 minutes
```bash
export STEAMPIPE_CACHE_MAX_TTL=600
```