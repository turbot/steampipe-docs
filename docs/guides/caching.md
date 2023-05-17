---
title: Users Guide to Steampipe Caching
sidebar_label: Understanding Caching 
---


# Users Guide to Steampipe Caching

Caching is an essential part of the Steampipe experience and is enabled by default. While caching is important in any database, it is especially critical to Steampipe where data is retrieved from external APIs "on-demand".  Caching not only significantly improves query performance, it also reduces API calls to external systems which helps avoid throttling and sometimes even reduces costs.

Steampipe introduced caching options in one of the earliest releases (v0.2.0). Back then, Steampipe was really just a CLI tool - we didn't really differentiate between server and client. The caching options and behavior were designed when the plugin execution model was different as well -- at the time, each Steampipe connection had its own OS process and its own cache, and the options reflected that design.

In Steampipe v0.20.0, the caching options and behavior have changed.  This guide will describe how caching works in Steampipe, as well as the options and settings that you can set to modify caching behavior.


## Types of Caches

There are 2 caches in Steampipe:
- The **Query Cache** is used to cache query results.  Plugins automatically support query caching just by using the Steampipe Plugin SDK -  It requires no plugin-specific code (that's not *entirely* true, as there are instances where the plugin author nay need to dictate the caching behavior for a given table).  The query cache resides in the plugin process.  

- The **Plugin Cache** (sometimes called the **Connection Cache**) can be used by plugin authors to cache arbitrary data.  The plugin cache resides in the plugin process.

The **Query Cache** is the focus of this guide - The Steampipe caching [environment variables](/docs/reference/env-vars/overview) and [configuration file options](/docs/reference/config-files/overview) are used to modify the behavior of the **query cache**, and do not affect the plugin cache.


## How it (basically) works 

When you issue a query, Steampipe will add the results to the query cache.  If you make a subsequent query, it will be served from the cache if:
  - It selects the same columns or a subset of the columns; AND
  - The qualifiers are the same or more restrictive

Some examples:
-  If you `select * from aws_s3_bucket` and then do `select title,arn from aws_s3_bucket`, the second query will be returned from the cache.  
-  If you `select * from aws_s3_bucket` and then do `select * from aws_s3_bucket where title like '%vandelay%'`, the second query will be returned from the cache.  


In fact, the caching is actually done by the SDK on a per-table, per connection basis so in many cases its clever enough to use the cache even in subsequent queries  that join the data.  For example:

1. Run `select * from aws_lambda_function`. Steampipe fetches the data from the API and it is added to the cache
1. Run `select * from aws_vpc_subnet`. Steampipe fetches the data from the API and it is added to the cache
1.  Run the following query, and it will return the data entirely from the cache:
  ```sql
  select
    fn.name,
    fn.region,
    count (availability_zone) as zone_count
  from
    aws_lambda_function as fn
    cross join jsonb_array_elements_text(vpc_subnet_ids) as vpc_subnet
    join aws_vpc_subnet as sub on sub.subnet_id = vpc_subnet
  group by
    fn.name,
    fn.region
  order by
    zone_count;
  ```

The implementation has a few important implications:
- The cache resides in the plugin's process space which implies it is on the server where the database runs, not on the client.  This means that the caching is used by any client, not just the `steampipe` cli - `psql`, `pgcli`, etc will also get the benefit of the query cache.
- The caching is done per-connection.  This means that if you query an aggregator, an equivalent query to the individual connection would be able to use the cached results, and vice-versa.
- The cache is shared by ALL connected clients - If multiple different users connect to the same steampipe database, they all share the same cache
  

## Cache settings / options

Steampipe provides options for enable/disabling the cache, changing the TTL, and controlling the cache size.  These options can be set via config file option, environment variables, or via commands in an interactive query shell session.

Broadly speaking, there are two groups of settings:
1. [Server-level settings](#server-level-cache-settings) that apply to ALL connections
1. [Client-level settings](#client-level-cache-settings) that apply to a single client session

### Server-level Cache Settings

The server settings dictate the actual operation of the cache on the server:
- If the server has the `cache` disabled, then caching is off -- Data is not even written to the cache.  Any client connecting will NOT be able to use the cache, regardless of their settings.
- The `cache_max_ttl` is the actual maximum cache lifetime - items are invalidated/ejected from the cache after this TTL.  A client can request a specific ttl, however if it exceeds the max ttl on the server, then the effective ttl will be the max ttl.
- The `cache_max_size_mb` is the maximum physical size of the cache.  There is no equivalent client setting.

The server level settings can set in the [database options](/docs/reference/config-files/options#database-options) or by setting environment variables on the host where the database is running.


```hcl
options "database" {
  cache               = true                  # true, false
  cache_max_ttl       = 900                   # max expiration (TTL) in seconds
  cache_max_size_mb   = 1024                  # max total size of cache across all plugins
}
```

| Argument | Default | Values | Description 
|-|-|-|-
| `cache` | `true` | `true`, `false`  | Enable or disable query caching. This can also be set via the  [STEAMPIPE_CACHE](/docs/reference/env-vars/steampipe_cache) environment variable.
| `cache_max_size_mb` | unlimited | an integer    | The maximum total size of the query cache across all plugins.   This can also be set via the  [STEAMPIPE_CACHE_MAX_SIZE_MB](/docs/reference/env-vars/steampipe_cache_max_size_mb) environment variable.
| `cache_max_ttl` | `300` | an integer    | The maximum length of time to cache query results, in seconds. This can also be set via the  [STEAMPIPE_CACHE_MAX_TTL](/docs/reference/env-vars/steampipe_cache_max_ttl) environment variable.


### Client-level Cache Settings
The client settings allow you to choose how your specific client session will use the cache.  Because these are client settings, they only apply when connecting with `steampipe`.

Remember that the cache actually lives on the server -- The client level settings allow you to specify how your client session interacts with the cache but it is subject to the server level settings:
- If caching is enabled on the server, you can specify that it be disabled for your connection.  This is commonly used for testing or troubleshooting.
- If caching is disabled on the server, then the client option to enable is ignored - caching is disabled for *all* clients.
- You can specify the `cache_ttl` for your client session.  Note the client is always subject to the `max_cache_ttl` set on the server though - if the `cache_ttl` is greater than the server's `max_cache_ttl`, then the `max_cache_ttl` is the effective ttl.


The client level settings can set for each [workspace](/docs/reference/config-files/workspace) or by setting environment variables on the host from which you are connecting.


```hcl
workspace "my_workspace" {
  cache           = true                  # true, false
  cache_ttl       = 300                   # max expiration (TTL) in seconds
}
```

| Argument | Default | Values | Description 
|-|-|-|-
| `cache`   | `true` | `true`, `false`  | Enable/disable caching.  Note that is a **client**  setting -  if the database (`options "database"`) has the cache disabled, then the cache is disabled regardless of the workspace setting. This can also be set via the  [STEAMPIPE_CACHE](/docs/reference/env-vars/steampipe_cache) environment variable.
| `cache_ttl` | `300`| an integer     | Set the client query cache expiration (TTL) in seconds.  Note that is a **client**  setting - if the database (`options "database"`) `cache_max_ttl` is lower than the cache_ttl in the workspace, then the effective ttl for this workspace is the cache_max_ttl. This can also be set via the [STEAMPIPE_CACHE_TTL](/docs/reference/env-vars/steampipe_cache_ttl) environment variable.



### Client Cache Commands

When running an interactive `steampipe query` session, you can use the [.cache meta-command](/docs/reference/dot-commands/cache) commands to enable, disable, or clear the cache for the session.  This command affects the caching behavior for this session only - it does not change the server caching options, and changes will not persist after the session ends.  

If caching is enabled on the server, you can disable it for your query session:
```sql
.cache off
```
Subsequent queries for this session will neither be added to nor fetched from the cache.  You can re-enable it for the session:
```sql
.cache on
```
Note that if the *server* has caching disabled, you cannot enable it, however.

You can also clear the cache for this session:
```sql
.cache clear
```

Clearing the cache does not actually remove anything from the cache, it just removes items from *your view* of the cache.  This is implemented using timestamps on the cache entries.  Every time data is added to the cache, it is added with a timestamp when it was added.  When you do `.cache clear`, Steampipe changes the minimum timestamp for your session to the current time.  When looking for items in the cache, it ignores any item with a timestamp greater (older) than the minimum for this session.

The `.cache` meta-command is simple, but only exists in the Steampipe client (`steampipe query`).  It is possible to perform equivalent operations from other clients (`psql`, `pgcli`, etc), though the interface is not as pleasant:


Clear the cache:
```sql
insert into steampipe_command.cache (operation) values ('cache_clear')
```

Enable the cache:
```sql
....
```

Clear the cache:
```sql
...

```







