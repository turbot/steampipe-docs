---
title: Connection options
sidebar_label: connection
---

### Connection Options
**Connection** options are options that can be set on a per-connection basis.  Connection options may be set at 2 scopes:
- Defined in a top-level `options "connection"`, these apply to ALL connections that do not explicitly override them.
- Defined in an `options` block under a `connection`, these apply only to that connection.  Per-connection options always override top-level connection options, and their arguments are identical.


#### Supported options  
| Argument | Default | Values | Description 
|-|-|-|-
| `cache` | `true` | `true`, `false`  | Enable or disabled caching
| `cache_ttl` | `300` | an integer    | The length of time to cache results, in seconds


#### Example: Top-Level Connection Options
Top-Level connection options apply to ALL connections (unless overridden in an `options` block within a `connection`).
```hcl
options "connection" {
    cache     = true # true, false
    cache_ttl = 300  # expiration (TTL) in seconds
}
```

#### Example: Per-Connection Options
```hcl
connection "aws_account1" {
    plugin    = "aws"  
    profile   = "account1"
    regions   =  ["us-east-1", "us-east-2", "us-west-1", "us-west-2", "eu-west-1", "eu-west-2"]          

    options "connection" {
        cache     = true # true, false
        cache_ttl = 300  # expiration (TTL) in seconds
    }
}
```
