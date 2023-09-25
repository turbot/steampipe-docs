---
title: Users Guide to Concurrency & Rate Limiting with `limiter`
sidebar_label: Concurrency & Rate Limiting
---

# Concurrency & Rate Limiting with `limiter`

Steampipe is designed to be fast - it provides parallel execution at multiple layers:
- It runs controls in parallel
- It runs queries in parallel
- For a given query it runs [List, Get, and Hydrate functions](/docs/develop/writing-plugins#hydrate-functions) in parallel

This high degree of concurrency results in low latency and high throughput, but may at times overwhelm the underlying service or API.  Features like exponential back-off & retry and [caching](/docs/guides/caching) markedly improve the situation, but at large scale you may still run out of local or remote resources.  The steampipe `limiter` was created to help solve these types of problems.  Limiters provide a simple, flexible interface to implement client-site rate limiting and concurrency thresholds at compile time or run time.  You can use limiters to:
- Smooth the request rate from steampipe to reduce load on the remote API or service
- Limit the number of parallel request to reduce  contention for client and network resources
- Avoid hitting server limits and throttling

## Defining limiters

Limiters may be defined in Go code and compiled into a plugin, or they may be defined in HCL in `.spc` configuration files.  In either case, the possible settings are the same.  

Each limiter must have a name.  In the case of an HCL definition, the label on the `limiter` block is used as the rate limiter name.  For a limiter defined in Go, you must include a `Name`.

A limiter may specify a `max_concurrency` which sets a ceiling on the number of [List, Get, and Hydrate functions](/docs/develop/writing-plugins#hydrate-functions) that can run in parallel.

```hcl
# run up to 250 hydrate/list/get functions concurrently
plugin "aws" {
  limiter "aws_global_concurrency" {
    max_concurrency = 250 
  }
}
```

A limiter may also specify a `bucket_size` and `fill_rate` to limit the rate at which List, Get, and Hydrate functions may run.  The rate limiter uses a token-bucket algorithm, where the `bucket_size` specifies the maximum number of tokens that may accrue (the burst size) and the `fill_rate` specifies how many tokens are refilled each second.

```hcl
plugin "aws" {
  # run up to 1000 hydrate/list/get functions per second
  limiter "aws_global_rate_limit" {
    bucket_size = 1000
    fill_rate   = 1000
  }
}
```

Every limiter has a **scope**.  The scope defines the context for the limit - which resources are subject to / counted against the limit. There are built-in scopes for `connection`, `table`, `function_name`, and any matrix qualifiers that the plugin may include.  A plugin author may also add [function tags](#function-tags) that can also be used as scopes.

If no scope is specified, then the limiter applies to all functions in the plugin.  For instance, this limiter will allow 1000 hydrate/list/get functions per second *across all connections*:
```hcl
plugin "aws" {
  # run up to 1000 hydrate/list/get functions per second across all aws connections
  limiter "aws_regional_rate_limit" {
    bucket_size = 1000
    fill_rate   = 1000
  }
}
```

If you specify a list of scopes, then *a limiter instance is created for each unique combination of scope values* - it acts much like `group by` in a sql statement.

For example, to limit to 1000 hydrate/list/get functions per second in *each region of each connection*:
```hcl
plugin "aws" {

  # run up to 1000 hydrate/list/get functions per second in each region of each connection
  limiter "aws_regional_rate_limit" {
    bucket_size = 1000
    fill_rate   = 1000
    scope       = ["connection", "region"]
  }
}
```

You can use a `where` clause to further filter the scopes to specific values. For example, we can restrict the limiter so that it only applies to a specific region:

```hcl

plugin "aws" {
  # run up to 1000 hydrate/list/get functions per second in us-east-1 for each connection
  limiter "aws_rate_limit_us_east_1" {
    bucket_size = 1000
    fill_rate   = 1000
    scope       = ["connection", "region"]
    where       = "region = 'us-east-1'"
  }
}
```


You can define multiple limiters.  If a function is included in the scope of multiple rate limiters, they will all apply - the function will wait until every rate limiter that applies to it has available bucket tokens and is below its max concurrency.


```hcl
plugin "aws" {

  # run up to 250 functions concurrently across all connections
  limiter "aws_global_concurrency" {
    max_concurrency = 250
  }

  # run up to 1000 functions per second in us-east-1 for each connection
  limiter "aws_rate_limit_us_east_1" {
    bucket_size = 1000
    fill_rate   = 1000
    scope       = ["connection", "region"]
    where       = "region = 'us-east-1'"
  }

  # run up to 200 functions per second in regions OTHER than us-east-1
  # for each connection
  limiter "aws_rate_limit_non_us_east_1" {
    bucket_size = 200
    fill_rate   = 200
    scope       = ["connection", "region"]
    where       = "region <> 'us-east-1'"
  }
}
```



## Function Tags

Hydrate function tags provide useful diagnostic metadata, and they can also be used as scopes in rate limiters.  Rate limiting requirements vary by plugin because the underlying APIs that they access implement rate limiting differently.  Tags provide a way for a plugin author to scope rate limiters in a way that aligns with the API implementation.

Function tags must be [added in the plugin code by the plugin author](/docs/develop/writing-plugins#function-tags).  Once the tags are added to the plugin, you can use them in the `scope` and `where` arguments for your rate limiter.

```hcl
plugin "aws" {
  limiter "sns_get_topic_attributes_us_east_1" {
    bucket_size  = 3000 
    fill_rate    = 3000

    scope  = ["connection", "region", "service", "action"]
    where  = "action = 'GetTopicAttributes' and service = 'sns' and region = 'us-east-1' "
  }
}
```

You can view the available tags in the `scope_values` when in [diagnostic mode](#exploring--troubleshooting-with-diagnostic-mode).  For example, to see the tags in the `aws_sns_topic` table:

```sql
with one_row as materialized (
  select * from aws_sns_topic limit 1
)
select 
  c ->> 'function_name' as function_name,
  jsonb_pretty(c -> 'scope_values') as scope_values
from 
  one_row,
  jsonb_array_elements(_ctx -> 'diagnostics' -> 'calls') as c
```

```sql
+-------------------------------+--------------------------------------------+
| function_name                 | scope_values                               |
+-------------------------------+--------------------------------------------+
| listAwsSnsTopics              | {                                          |
|                               |     "table": "aws_sns_topic",              |
|                               |     "action": "ListTopics",                |
|                               |     "region": "us-east-1",                 |
|                               |     "service": "sns",                      |
|                               |     "connection": "aws_dmi",               |
|                               |     "function_name": "listAwsSnsTopics"    |
|                               | }                                          |
| listTagsForSnsTopic           | {                                          |
|                               |     "table": "aws_sns_topic",              |
|                               |     "action": "ListTagsForResource",       |
|                               |     "region": "us-east-1",                 |
|                               |     "service": "sns",                      |
|                               |     "connection": "aws_dmi",               |
|                               |     "function_name": "listTagsForSnsTopic" |
|                               | }                                          |
| listRegionsForServiceUncached | {                                          |
|                               |     "table": "aws_sns_topic",              |
|                               |     "region": "us-east-1",                 |
|                               |     "connection": "aws_dmi"                |
|                               | }                                          |
| getTopicAttributes            | {                                          |
|                               |     "table": "aws_sns_topic",              |
|                               |     "action": "GetTopicAttributes",        |
|                               |     "region": "us-east-1",                 |
|                               |     "service": "sns",                      |
|                               |     "connection": "aws_dmi",               |
|                               |     "function_name": ""                    |
|                               | }                                          |
+-------------------------------+--------------------------------------------+
```

## Exploring & Troubleshooting with Diagnostic Mode

To assist in troubleshooting your rate limiter setup, Steampipe has introduced Diagnostic Mode.  To enable Diagnostic Mode, set the `STEAMPIPE_DIAGNOSTIC_LEVEL` environment variable to `ALL` when you start the Steampipe DB:
```bash
STEAMPIPE_DIAGNOSTIC_LEVEL=ALL  steampipe service start
```

With diagnostics enabled, the `_ctx` column will contain information about what functions were called to fetch the row, the scope values (including any [tags](#defining-tags)) for the function, the limiters that were in effect and the amount of time the request was delayed by the `limiters`.  This diagnostic information can help you discover what scopes are available to use in limiters as well as to see the effect and impact of limiters that you have defined. 

```sql
select jsonb_pretty(_ctx) as _ctx ,display_name from aws_sns_topic limit 2
```
```sql
+-----------------------------------------------------------+--------------+
| _ctx                                                      | display_name |
+-----------------------------------------------------------+--------------+
| {                                                         |              |
|     "diagnostics": {                                      |              |
|         "calls": [                                        |              |
|             {                                             |              |
|                 "type": "list",                           |              |
|                 "scope_values": {                         |              |
|                     "table": "aws_sns_topic",             |              |
|                     "action": "ListTopics",               |              |
|                     "region": "us-east-2",                |              |
|                     "service": "sns",                     |              |
|                     "connection": "aws_dmi",              |              |
|                     "function_name": "listAwsSnsTopics"   |              |
|                 },                                        |              |
|                 "function_name": "listAwsSnsTopics",      |              |
|                 "rate_limiters": [                        |              |
|                     "aws_global",                         |              |
|                     "sns_list_topics"                     |              |
|                 ],                                        |              |
|                 "rate_limiter_delay_ms": 0                |              |
|             },                                            |              |
|             {                                             |              |
|                 "type": "hydrate",                        |              |
|                 "scope_values": {                         |              |
|                     "table": "aws_sns_topic",             |              |
|                     "action": "GetTopicAttributes",       |              |
|                     "region": "us-east-2",                |              |
|                     "service": "sns",                     |              |
|                     "connection": "aws_dmi",              |              |
|                     "function_name": ""                   |              |
|                 },                                        |              |
|                 "function_name": "getTopicAttributes",    |              |
|                 "rate_limiters": [                        |              |
|                     "sns_get_topic_attributes_150",       |              |
|                     "aws_global"                          |              |
|                 ],                                        |              |
|                 "rate_limiter_delay_ms": 808              |              |
|             }                                             |              |
|         ]                                                 |              |
|     },                                                    |              |
|     "connection_name": "aws_dmi"                          |              |
| }                                                         |              |
| {                                                         |              |
|     "diagnostics": {                                      |              |
|         "calls": [                                        |              |
|             {                                             |              |
|                 "type": "list",                           |              |
|                 "scope_values": {                         |              |
|                     "table": "aws_sns_topic",             |              |
|                     "action": "ListTopics",               |              |
|                     "region": "us-east-1",                |              |
|                     "service": "sns",                     |              |
|                     "connection": "aws_dmi",              |              |
|                     "function_name": "listAwsSnsTopics"   |              |
|                 },                                        |              |
|                 "function_name": "listAwsSnsTopics",      |              |
|                 "rate_limiters": [                        |              |
|                     "aws_global",                         |              |
|                     "sns_list_topics"                     |              |
|                 ],                                        |              |
|                 "rate_limiter_delay_ms": 597              |              |
|             },                                            |              |
|             {                                             |              |
|                 "type": "hydrate",                        |              |
|                 "scope_values": {                         |              |
|                     "table": "aws_sns_topic",             |              |
|                     "action": "GetTopicAttributes",       |              |
|                     "region": "us-east-1",                |              |
|                     "service": "sns",                     |              |
|                     "connection": "aws_dmi",              |              |
|                     "function_name": ""                   |              |
|                 },                                        |              |
|                 "function_name": "getTopicAttributes",    |              |
|                 "rate_limiters": [                        |              |
|                     "sns_get_topic_attributes_us_east_1", |              |
|                     "aws_global"                          |              |
|                 ],                                        |              |
|                 "rate_limiter_delay_ms": 0                |              |
|             }                                             |              |
|         ]                                                 |              |
|     },                                                    |              |
|     "connection_name": "aws_dmi"                          |              |
| }                                                         |              |
+-----------------------------------------------------------+--------------+
```


The diagnostics information includes information about each Get, List, and Hydrate function that was called to fetch the row, including:

| Key                     | Description
|-------------------------|---------------------- 
| `type`                  | The type of function (`list`, `get`, or `hydrate`).
| `function_name`         | The name of the function.
| `scope_values`          | A map of scope names to values.  This includes the built-in scopes as well as any matrix qualifier scopes and function tags.
| `rate_limiters`         | A list of the rate limiters that are scoped to the function.
| `rate_limiter_delay_ms` | The amount of time (in milliseconds) that Steampipe waited before calling this function due to client-side (`limiter`) rate limiting.


## Viewing and Overriding Limiters
Steampipe includes the `steampipe_rate_limiter` table to provide visibility into all the limiters that are defined in your installation, including those defined in plugin code as well as limiters defined in HCL.

```sql
select name,plugin,source,status,bucket_size,fill_rate,max_concurrency from steampipe_rate_limiter
```
```sql
+------------------------------+--------+--------+--------+-------------+-----------+-----------------+
| name                         | plugin | source | status | bucket_size | fill_rate | max_concurrency |
+------------------------------+--------+--------+--------+-------------+-----------+-----------------+
| exec_max_concurrency_limiter | exec   | plugin | active | <null>      | <null>    | 15              |
| aws_global_concurrency       | aws    | config | active | <null>      | <null>    | 200             |
| sns_read_us_east_1           | aws    | config | active | 2700        | 2700      | <null>          |
| sns_read_900                 | aws    | config | active | 810         | 810       | <null>          |
| sns_read_150                 | aws    | config | active | 135         | 135       | <null>          |
| sns_read_30                  | aws    | config | active | 27          | 27        | <null>          |
+------------------------------+--------+--------+--------+-------------+-----------+-----------------+
```

You can override a limiter that is compiled into a plugin by creating an HCL limiter with the same name.  In the previous example, we can see that the `exec` plugin includes a default limiter named `exec_max_concurrency_limiter` that sets the max_concurrency to 15.  We can override this value at run time by creating an HCL `limiter` for this plugin with the same name. The `limiter` block must be contained in a `plugin` block. Like `connection`, Steampipe will load all `plugin` blocks that it finds in any `.spc` file in the `~/.steampipe/config` directory.  For example, we can add the following snippet to the `~/.steampipe/config/exec.spc` file:

```hcl
plugin "exec" {
   limiter "exec_max_concurrency_limiter" {
      max_concurrency = 20
   }
}
```

Querying the `steampipe_rate_limiter` table again, we can see that there are now 2 rate limiters for the `exec` plugin named `exec_max_concurrency_limiter`, but the one from the plugin is overridden by the one in the config file. 

```sql
+------------------------------+--------+--------+------------+-------------+-----------+-----------------+
| name                         | plugin | source | status     | bucket_size | fill_rate | max_concurrency |
+------------------------------+--------+--------+------------+-------------+-----------+-----------------+
| exec_max_concurrency_limiter | exec   | plugin | overridden | <null>      | <null>    | 15              |
| exec_max_concurrency_limiter | exec   | config | active     | <null>      | <null>    | 20              |
| aws_global_concurrency       | aws    | config | active     | <null>      | <null>    | 200             |
| sns_read_us_east_1           | aws    | config | active     | 2700        | 2700      | <null>          |
| sns_read_900                 | aws    | config | active     | 810         | 810       | <null>          |
| sns_read_150                 | aws    | config | active     | 135         | 135       | <null>          |
| sns_read_30                  | aws    | config | active     | 27          | 27        | <null>          |
+------------------------------+--------+--------+------------+-------------+-----------+-----------------+
```


## Hints, Tips, & Best practices

- You can use ANY scope in the `where`, even if it does not appear in the `scope` for the limiter.  Remember that the `scope` defines the grouping; it acts similar to `group by` in SQL.  Consider the following rate limiter:

  ```hcl
  plugin "aws" {
    limiter "aws_sns_read_rate_limit" {
      bucket_size = 2500
      fill_rate   = 2500
      scope       = ["connection", "region", "service", "action"]
      where       = "service = 'sns' and (action like 'Get%' or action like 'List%') "
    }
  }
  ```

  This will create a separate rate limiter instance for every action in the `sns` service in every region of every account - You can do 2500 `GetTopicAttributes` requests/sec in each account/region, and also 2500 `ListTagsForResource` requests/sec in each account/region, and also 2500 `ListTopics` requests/sec in each account/region.  

  If we remove `action` from the `scope`, there will be *one* rate limiter instance for *all* actions in the `sns` service in each region/account - You can do 2500 total `GetTopicAttributes` or `ListTagsForResource` or `ListTopics` requests per second in each account/region.

  ```hcl
  plugin "aws" {
    limiter "aws_sns_read_rate_limit" {
      bucket_size = 2500
      fill_rate   = 2500
      scope       = ["connection", "region", "service"]
      where       = "service = 'sns' and (action like 'Get%' or action like 'List%') "
    }
  }
  ```

- Setting `max_concurrency` at the plugin level can help prevent running out of local resources like network bandwidth, ports, file handles, etc.
  ```hcl
  plugin "aws" {
    max_concurrency = 250
  }
  ```

- Optimizing rate limiters requires knowledge of how the API is implemented.  If the API publishes information about what the rate limits are, and how they are applied it provides a good starting place for setting your `bucket_size` and `fill_rate` values.  Getting the `limiter` values right usually involves some trial & error though, and simply setting `max_concurrency` is often good enough to get past a problem. 

- Use the plugin logs (`~/.steampipe/logs/plugin*.log`) to verify that the rate limiters are reducing the throttling and other errors from the API as you would expect.

- Use the `steampipe_rate_limiter` table to see what rate limiters are in effect from both the plugins and the config files, as well as which are active.  Use `STEAMPIPE_DIAGNOSTIC_LEVEL=ALL` to enable extra diagnostic info in the `_ctx` to discover what scopes are available and to verify that limiters are being applied as you expect.  Note that the `STEAMPIPE_DIAGNOSTIC_LEVEL` variable must be set in the database service process - if you run steampipe as a service, it must be set when you run `steampipe service start`

- Throttling errors from the server, such as `429 Too Many Requests` are not *inherently* bad.  Most cloud SDKs actually account for retrying such errors and expect that it will sometimes occur.  Steampipe plugins generally implement an exponential back-off & retry to account for such cases.  You can use client side limiters to help avoid resource contention and to reduce throttling from the server, but completely avoiding server-side throttling is probably not necessary in most cases.
