---
title: STEAMPIPE_DIAGNOSTIC_LEVEL
sidebar_label: STEAMPIPE_DIAGNOSTIC_LEVEL
---
# STEAMPIPE_DIAGNOSTIC_LEVEL

Sets the diagnostic level.  Supported levels are `ALL`, `NONE`. By default, the diagnostic level is `NONE`.

## Usage 
```bash
export STEAMPIPE_DIAGNOSTIC_LEVEL=ALL
```

When enabled, diagnostics information will appear in the `_ctx` column for all tables:


```sql
> select jsonb_pretty(_ctx),display_name from aws_sns_topic limit 1


+-----------------------------------------------------------+--------------+
| jsonb_pretty                                              | display_name |
+-----------------------------------------------------------+--------------+
| {                                                         |              |
|     "connection": "aws_dev_01",                           |              |
|     "diagnostics": {                                      |              |
|         "calls": [                                        |              |
|             {                                             |              |
|                 "type": "list",                           |              |
|                 "scope_values": {                         |              |
|                     "table": "aws_sns_topic",             |              |
|                     "action": "ListTopics",               |              |
|                     "region": "us-east-1",                |              |
|                     "service": "sns",                     |              |
|                     "connection": "aws_dev_01"            |              |
|                 },                                        |              |
|                 "function_name": "listAwsSnsTopics",      |              |
|                 "rate_limiters": [                        |              |
|                     "sns_list_topics",                    |              |
|                     "aws_global_concurrency"              |              |
|                 ],                                        |              |
|                 "rate_limiter_delay_ms": 0                |              |
|             },                                            |              |
|             {                                             |              |
|                 "type": "hydrate",                        |              |
|                 "scope_values": {                         |              |
|                     "table": "aws_sns_topic",             |              |
|                     "action": "GetTopicAttributes",       |              |
|                     "region": "us-east-1",                |              |
|                     "service": "sns",                     |              |
|                     "connection": "aws_dev_01"            |              |
|                 },                                        |              |
|                 "function_name": "getTopicAttributes",    |              |
|                 "rate_limiters": [                        |              |
|                     "sns_get_topic_attributes_us_east_1", |              |
|                     "aws_global_concurrency"              |              |
|                 ],                                        |              |
|                 "rate_limiter_delay_ms": 107              |              |
|             }                                             |              |
|         ]                                                 |              |
|     }                                                     |              |
| }                                                         |              |

```

The diagnostics information includes information about each Get, List, and Hydrate function that was called to fetch the row, including:

| Key                     | Description
|-------------------------|---------------------- 
| `type`                  | The type of function (`list`, `get`, or `hydrate`).
| `function_name`         | The name of the function.
| `scope_values`          | A map of scope names to values.  This includes the built-in scopes as well as any matrix qualifier scopes and function tags.
| `rate_limiters`         | A list of the rate limiters that are scoped to the function.
| `rate_limiter_delay_ms` | The amount of time (in milliseconds) that Steampipe waited before calling this function due to client-side (`limiter`) rate limiting.
