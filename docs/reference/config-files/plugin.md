---
title: plugin
sidebar_label: plugin
---

# plugin 

The `plugin` block enables you to set plugin-level options like soft memory limits and rate limiters. You can then associate connections with the the plugin.

```hcl
plugin "aws" {
  memory_max_mb = 2048

  limiter "aws_global" {
    max_concurrency = 200
  }
}
```


## Supported options  
| Argument | Default | Description 
|-|-|-|-
| `source`        | none   |  A [plugin version string](#plugin-version-strings) the specifies which plugin this configuration applies to.  If not specified, the plugin block label is assumed to be the plugin source. <!--This must refer to an [installed plugin version](/docs/managing/plugins#installing-plugins). -->
| `memory_max_mb` | `1024` | The soft memory limit for the plugin, in MB. Steampipe sets `GOMEMLIMIT` for the plugin process to the specified value.  The Go runtime does not guarantee that the memory usage will not exceed the limit, but rather uses it as a target to optimize garbage collection.
| `limiter`       | none   | Optional [limiter](#limiter) blocks used to set concurrency and/or rate limits



## Plugins and Connections

You may optionally define a `plugin` in a `.spc` file to set plugin-level options like soft memory limits and rate limiters.

```hcl
plugin "aws" {
  memory_max_mb = 2048
}
```

The block label is assumed to be the plugin short name unless the `source` argument is present.  The label may only contain alphanumeric characters, dashes, or underscores. The `source` argument, however, accepts any [plugin version string](/docs/reference/config-files/connection#plugin-version-strings) allowing you to refer to any version.   

```hcl
plugin "my_aws" {
  source        = "aws@0.41.0"
  memory_max_mb = 2048
}
```

In a `connection` you may continue to use the current syntax for the `plugin` argument. Steampipe will resolve the `connection` to the `plugin` as long as they resolve to the same plugin version:

```hcl
connection "aws" {
  plugin = "aws"
}

plugin "aws" {
  memory_max_mb = 2048
}
```

Note that if a `connection` specifies a plugin version string that resolves to more than 1 plugin instance, Steampipe will not be able to load the connection, as it cannot assume which plugin instance to resolve to.  For example, this configuration will cause a warning and the connection will be in error:

```hcl
connection "aws" {
  plugin = "aws"
}

plugin "aws" {
  memory_max_mb = 2048
}

plugin "aws_low_mem" {
  source        = "aws"
  memory_max_mb = 512
}
```


You may instead specify a reference to a `plugin` block in your `connection` to disambiguate:
```hcl
connection "aws" {
  plugin = plugin.aws
}

plugin "aws" {
  memory_max_mb = 2048
}

plugin "aws_low_mem" {
  source        = "aws"
  memory_max_mb = 512
}
```

<br />

Steampipe will create a separate plugin process for each `plugin` defined that has connections associated to it.  This allows you to run multiple versions side by side, but also to create multiple processes with the SAME version to allow you to create QOS groups. In the following example, Steampipe will create 2 plugin processes:
- One process has a 2000 MB memory soft limit and no limiters, and contains the `aws_prod_1`, `aws_prod_2`, and `aws_prod_3` connections.
- One process has a 500 MB memory soft limit and the `all_requests` limiter, and contains the `aws_dev_1` and `aws_dev_2` connections.
  

```hcl
plugin "aws_high" {
  memory_max_mb = 2000
  source        = "aws"
}

plugin "aws_low" {
  memory_max_mb = 500
  source        = "aws"

  limiter "all_requests" {
    bucket_size  = 100
    fill_rate    = 100
    max_concurrency = 50
  }
}

connection "aws_prod_1" {
  plugin  = plugin.aws_high
  profile = "prod1"
  regions = ["*"]
}

connection "aws_prod_2" {
  plugin  = plugin.aws_high
  profile = "prod2"
  regions = ["*"]
}

connection "aws_prod_3" {
  plugin  = plugin.aws_high
  profile = "prod3"
  regions = ["*"]
}

connection "aws_dev_1" {
  plugin  = plugin.aws_low
  profile = "dev1"
  regions = ["*"]
}

connection "aws_dev_2" {
  plugin  = plugin.aws_low
  profile = "dev2"
  regions = ["*"]
}

```


Note that the aggregators can only aggregate connections from the single plugin instance for which they are configured.  Extending the previous example:

```hcl

connection "aws_prod" {
  plugin      = plugin.aws_high
  type        = "aggregator"
  connections = ["*"]
}

connection "aws_dev" {
  plugin      = plugin.aws_low
  type        = "aggregator"
  connections = ["*"]}
```

- The `aws_prod` aggregator will include the `aws_prod_1`, `aws_prod_2`, and `aws_prod_3` connections
- The `aws_dev` aggregator will include the `aws_dev_1` and `aws_dev_2` connections


You can also run multiple plugin versions side-by-side:

```hcl
plugin "aws_latest" {
  source = "aws"
}

plugin "aws_0_117_0" {
  source = "aws@0.117"
}


connection "aws_prod_1" {
  plugin  = plugin.aws_latest
  profile = "prod1"
  regions = ["*"]
}

connection "aws_prod_2" {
  plugin  = plugin.aws_0_117_0
  profile = "prod2"
  regions = ["*"]
}
```


## limiter

Limiters provide a simple, flexible interface to implement client-site rate limiting and concurrency thresholds.  You can use limiters to:
- Smooth the request rate from steampipe to reduce load on the remote API or service
- Limit the number of parallel request to reduce  contention for client and network resources
- Avoid hitting server limits and throttling

### Supported options  
| Argument          | Default   | Description 
|-------------------|-----------|--------------------
| `bucket_size`     | unlimited | The maximum number of requests that may be made per second (the burst size).  Used in combination with `fill_rate` to implement a token-bucket rate limit.
| `fill_rate`       | unlimited | The number of requests that are added back to refill the bucket each second.  Used in combination with `fill_rate` to implement a token-bucket rate limit.
| `max_concurrency` | The maximum number of [List, Get, and Hydrate functions](/docs/develop/writing-plugins#hydrate-functions) that can run in parallel.
| `scope`           | `[]`       | The context for the limit - which resources are subject to / counted against the limit. If no scope is specified, then the limiter applies to all functions in the plugin.  If you specify a list of scopes, then *a limiter instance is created for each unique combination of scope values* - it acts much like `group by` in a sql statement. 
| `where`           | none       | A `where` clause to further filter the scopes to specific values.


### `where` syntax

The `where` argument supports the following PostgreSQL comparison operators:

| Operator |      Description               
|----------|--------------------------------
| `<`      | less than	                    
| `<=`     | less than or equal             
| `=`      | equal                          
| `!=`     | not equal	                    
| `<>`     | not equal	                    
| `>=`     | greater than	or equal          
| `>`      | greater than	                  
| `like`   | string like (case sensitive)   
| `ilike`  | string like (case insensitive) 
| `is null`| null test         
| `not`    | logical negation
| `and`    | logical conjunction
| `or`     | logical disjunction
| `in`     | set membership (equality)

 
You may use parentheses to force explicit lexical precedence, otherwise [standard PostgreSQL operator precedence](https://www.postgresql.org/docs/current/sql-syntax-lexical.html#SQL-PRECEDENCE) applies.  




## Examples

See the [Concurrency & Rate Limiting](/docs/guides/limiter) for more examples.


```hcl
plugin "aws" {

  # up to 250 functions concurrently across all connections
  limiter "aws_global_concurrency" {
    max_concurrency = 250
  }

  # up to 1000 functions per second in us-east-1 for each connection
  limiter "aws_rate_limit_us_east_1" {
    bucket_size = 1000
    fill_rate   = 1000
    scope       = ["connection", "region"]
    where       = "region = 'us-east-1'"
  }

  # up to 200 functions per second in regions OTHER than us-east-1
  # for each connection
  limiter "aws_rate_limit_non_us_east_1" {
    bucket_size = 200
    fill_rate   = 200
    scope       = ["connection", "region"]
    where       = "region <> 'us-east-1'"
  }

}
```
