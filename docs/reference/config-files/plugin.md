---
title: plugin
sidebar_label: plugin
---

# plugin 

The `plugin` block allows you to set plugin-level options like soft memory limits and rate limiters. You can then associate connections with the the plugin.

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
| `memory_max_mb` | `1024` | The soft memory limit for the plugin, in MB. 
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

In a `connection` you may continue to use the current syntax for `plugin` argument - Steampipe will resolve the `connection` to the `plugin` as long as they resolve to the same plugin version:

```hcl
connection {
  plugin = "aws"
}

plugin "aws" {
  memory_max_mb = 2048
}
```

Note that if a `connection` specifies a plugin version string that resolves to more than 1 plugin instance, `steampipe` will not be able to load the connection, as it cannot assume which plugin instance to resolve to.  For example, this configuration will cause a warning and the connection will be in error:

```hcl
connection {
  plugin = "aws"
}

plugin "aws" {
  memory_max_mb = 2048
}

plugin "aws2" {
  source        = "aws"
  memory_max_mb = 512
}
```


You may instead specify a reference to a `plugin` block in your `connection` to disambiguate:
```hcl
connection {
  plugin = plugin.aws
}

plugin "aws" {
  memory_max_mb = 2048
}

plugin "aws2" {
  source        = "aws"
  memory_max_mb = 512
}
```

Steampipe will create a separate plugin process for each `plugin` defined that has connections associated to it.  This allows you to run multiple versions side by side, but also to create multiple processes with the SAME version to allow you to create QOS groups. In this example, steampipe will create 2 plugins process.  
  - one process as a 2000 MB memory soft limit and no limiters, and will contain the `prod_1`, `prod_2`, and `prod_3` connections
  - one process as a 500 MB memory soft limit and the `all_requests` limiter, and will contain the `dev_1` and `dev_2` connections
  

```hcl
plugin "aws_high" {
  memory_max_mb = 2000

}

plugin "aws_low" {
  memory_max_mb = 500

  limiter "all_requests" {
    plugin       = "aws"  
    bucket_size  = 100
    fill_rate    = 100
    max_concurrency = 50
  }
}


connection "prod_1" {
  plugin  = plugin.aws_high
  profile = "prod1"
}

connection "prod_2" {
  plugin  = plugin.aws_high
  profile = "prod2"
}

connection "prod_3" {
  plugin  = plugin.aws_high
  profile = "prod3"
}

connection "dev_1" {
  plugin  = plugin.aws_low
  profile = "dev1"
}
connection "dev_2" {
  plugin  = plugin.aws_low
  profile = "dev2"
}

```


## limiter

Limiters provide a simple, flexible interface to implement client-site rate limiting and concurrency thresholds.  You can use limiters to:
- Smooth the request rate from steampipe to reduce load on the remote API or service
- Limit the number of parallel request to reduce  contention for client and network resources
- Avoid hitting server limits and throttling

[link to guide here]

### Supported options  
| Argument          | Default   | Description 
|-------------------|-----------|--------------------
| `bucket_size`     | unlimited | The maximum number of requests that may be made per second (the burst size).  Used in combination with `fill_rate` to implement a token-bucket rate limit.
| `fill_rate`       | unlimited | The number of requests that are added back to refill the bucket each second.  Used in combination with `fill_rate` to implement a token-bucket rate limit.
| `max_concurrency` | The maximum number of [List, Get, and Hydrate functions](/docs/develop/writing-plugins#hydrate-functions) that can run in parallel.
| `scope`           | `[]`       | The context for the limit - which resources are subject to / counted against the limit. If no scope is specified, then the limiter applies to all functions in the plugin.  If you specify a list of scopes, then *a limiter instance is created for each unique combination of scope values* - it acts much like `group by` in a sql statement. 
| `where`           | none       | A `where` clause to further filter the scopes to specific values.


## Examples
```hcl

```



