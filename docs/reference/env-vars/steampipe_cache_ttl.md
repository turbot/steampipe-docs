---
title: STEAMPIPE_CACHE_TTL
sidebar_label: STEAMPIPE_CACHE_TTL
---

# STEAMPIPE_CACHE_TTL

The amount of time to cache query results for this client, in seconds. The default is `300` (5 minutes).

Caching must be enabled for this setting to take effect.

This is a client setting -- when connecting to a Steampipe database, you are also subject to the [STEAMPIPE_CACHE_MAX_TTL](reference/env-vars/steampipe_cache_max_ttl) set on the server.  You can set the `STEAMPIPE_CACHE_TTL` (or `cache_ttl` in a [workspace](/docs/reference/config-files/workspace)) from your client to *reduce* the TTL for your session but not to expand it -- The net effect for your session will be the lower of the two values.


## Usage 
Set TTL to 1 minute
```bash
export STEAMPIPE_CACHE_TTL=60 
```