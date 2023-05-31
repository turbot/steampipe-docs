---
title: options
sidebar_label: options
---

# options
Configuration options are defined using HCL `options` blocks in one or more Steampipe config files.  Steampipe will load ALL configuration files from `~/.steampipe/config` that have a `.spc` extension.  By default, Steampipe creates a `~/.steampipe/config/default.spc` file for setting `options`.  


Note that many of the `options` settings can also be specified via other mechanisms, such as command line arguments, environment variables, etc.  These settings are resolved in a standard order:
1. Explicitly set in session (via a meta-command).
2. Specified in command line argument.
3. Set in environment variable.
4. Set in a configuration file `options` argument.
5. If not specified, a default value is used.

The following `options` are currently supported:

| Option Type                       | Description
|-|-
| [database](#database-options)     | Database options.
| [dashboard](#dashboard-options)   | Dashboard options.
| [general](#general-options)       | General CLI options, such as auto-update options.




<!--
Deprecated...
| [terminal](#terminal-options)     | Terminal options, which generally map to .meta-commands
| [connection](#connection-options) | Options that apply to connections.
-->


---

## Database Options

**Database** options are used to control database options, such as the IP address and port on which the database listens.

### Supported options  
| Argument | Default | Values | Description 
|-|-|-|-
| `cache` | `true` | `true`, `false`  | Enable or disable query caching. This can also be set via the  [STEAMPIPE_CACHE](/docs/reference/env-vars/steampipe_cache) environment variable.
| `cache_max_size_mb` | unlimited | an integer    | The maximum total size of the query cache across all plugins.   This can also be set via the  [STEAMPIPE_CACHE_MAX_SIZE_MB](/docs/reference/env-vars/steampipe_cache_max_size_mb) environment variable.
| `cache_max_ttl` | `300` | an integer    | The maximum length of time to cache query results, in seconds. This can also be set via the  [STEAMPIPE_CACHE_MAX_TTL](/docs/reference/env-vars/steampipe_cache_max_ttl) environment variable.
| `listen` | `network` | `local`, `network`| The network listen mode when Steampipe is started in [service mode](/docs/managing/service#starting-the-database-in-service-mode). Use `network` to listen on all IP addresses, or `local` to restrict to localhost.
| `port` | `9193` | any valid, open port number | The TCP port that Postgres will listen on.
| `search_path` | All connections, alphabetically | Comma separated string | Set an exact [search path](managing/connections#setting-the-search-path).  Note that setting the search path in the database options sets it in the database; this setting will also be in effect when connecting to Steampipe from 3rd-party tools. See also: [Using search_path to target connections and aggregators](https://steampipe.io/docs/guides/search-path).
| `search_path_prefix` | none | Comma separated string | Move one or more connections or aggregators to the front of the  [search path](managing/connections#setting-the-search-path).  Note that setting the search path prefix in the database options sets in the database; this setting will also be in effect when connecting to Steampipe from 3rd-party tools. See also: [Using search_path to target connections and aggregators](https://steampipe.io/docs/guides/search-path).
| `start_timeout` | `30` | an integer | The maximum time (in seconds) to wait for the Postgres process to start accepting queries after it has been started. This can also be set via the  [STEAMPIPE_DATABASE_START_TIMEOUT](/docs/reference/env-vars/steampipe_database_start_timeout) environment variable.


### Example: Database Options

```hcl
options "database" {
  cache               = true                  # true, false
  cache_max_ttl       = 900                   # max expiration (TTL) in seconds
  cache_max_size_mb   = 1024                  # max total size of cache across all plugins
  port                = 9193                  # any valid, open port number
  listen              = "local"               # local, network
  search_path_prefix  = "aws,aws2,gcp,gcp2"   # comma-separated string; an exact search_path
  start_timeout       = 30                    # maximum time (in seconds) to wait for the database to start up
}
```



---
## Dashboard Options

**Dashboard** options are used to set dashboard service options, such as the IP address and port on which the dashboard web server listens.

### Supported options  
| Argument | Default | Values | Description 
|-|-|-|-
| `listen` | `network` | `local`, `network`| The network listen mode when steampipe is started in [service mode](/docs/managing/service#starting-the-database-in-service-mode). Use `network` to listen on all IP addresses, or `local` to restrict to localhost. 
| `port` | `9193` | any valid, open port number | The TCP port that Postgres will listen on


### Example: Dashboard Options

```hcl
options "dashboard" {
  port          = 9194                  # any valid, open port number
  listen        = "local"               # local, network
}
```


----
## General options
**General** options apply generally to the Steampipe CLI.

### Supported options  
| Argument | Default | Values | Description
|-|-|-|-
| `log_level` | `warn` | `trace`, `debug`, `info`, `warn`, `error` | Sets the output logging level. Standard log levels are supported. This can also be set via the  [STEAMPIPE_LOG_LEVEL](reference/env-vars/steampipe_log) environment variable.
| `telemetry` | `none` | `none`, `info` | Set the telemetry level in Steampipe. This can also be set via the  [STEAMPIPE_TELEMETRY](reference/env-vars/steampipe_telemetry) environment variable. See also: [Telemetry](https://steampipe.io/blog/release-0-15-0#telemetry).
| `update_check` | `true` | `true`, `false` | Enable or disable automatic update checking. This can also be set via the  [STEAMPIPE_UPDATE_CHECK](reference/env-vars/steampipe_update_check) environment variable.


<!-- Deprecated

| `max_parallel` | `10` | an integer| Set the maximum number of parallel executions. When running `steampipe check`, Steampipe will attempt to run up to this many controls in parallel. This can also be set via the  `STEAMPIPE_MAX_PARALLEL` environment variable.


-->
### Example: General Options  

```hcl
options "general" {
  log_level     = "warn"  # trace, debug, info, warn, error
  telemetry     = "info"  # info, none
  update_check  = true    # true, false
}
```

---



## Connection Options

***The `options "connection"` block was deprecated in Steampipe v0.20.0.***
- Set server query cache options in the [database options →](#database-options)
- Set client query cache options for each [workspaces →](/docs/reference/config-files/workspace)


<!--
## Connection Options
**Connection** options are options that can be set on a per-connection basis.  Connection options may be set at 2 scopes:
- Defined in a top-level `options "connection"`, these apply to ALL connections that do not explicitly override them.
- Defined in an `options` block under a `connection`, these apply only to that connection.  Per-connection options always override top-level connection options, and their arguments are identical.


### Supported options  
| Argument | Default | Values | Description 
|-|-|-|-
| `cache` | `true` | `true`, `false`  | Enable or disabled caching.
| `cache_ttl` | `300` | an integer    | The length of time to cache results, in seconds.


### Example: Top-Level Connection Options
Top-Level connection options apply to ALL connections (unless overridden in an `options` block within a `connection`).
```hcl
options "connection" {
    cache     = true # true, false
    cache_ttl = 300  # expiration (TTL) in seconds
}
```

### Example: Per-Connection Options
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
-->

## Terminal Options
***The `options "terminal"` block was deprecated in Steampipe v0.20.0.***
- Set these options for each [workspace →](/docs/reference/config-files/workspace)


<!--
***`terminal` options have been deprecated - please use `query` and `check` options instead***


**Terminal** options can be used to change query output formats and other terminal options.  Typically, these can also be set via [meta-commands](/docs/reference/dot-commands/overview) or [command line arguments](/docs/reference/cli/overview) of the same name.


### Supported options  
| Argument | Default | Values | Description 
|-|-|-|-
| `autocomplete` |  `true` |  `true`, `false` | Enable or disable autocomplete in the interactive query shell. 
| `header` |  `true` |  `true`, `false` | Enable or disable column headers.
| `multi` | `false` |  `true`, `false` | Enable or disable multiline mode.
| `output` | `table` | `json`, `csv`, `table`, `line` | Set output format.
| `separator` | `,` | Any single character | Set csv output separator.
| `timing` | `false` |  `true`, `false` | Enable or disable query execution timing.
| `search_path` | The active database search path | Comma separated string | Set an exact [search path](managing/connections#setting-the-search-path). Note that setting the search path in the terminal options sets it for the session when running `steampipe`; this setting will not be in effect when connecting to Steampipe from 3rd party tools. See also: [Using search_path to target connections and aggregators](https://steampipe.io/docs/guides/search-path).
| `search_path_prefix`| Empty | Comma separated string |  Move connections to the front of the [search path](managing/connections#setting-the-search-path).
| `watch` |  `true` |  `true`, `false` |  Watch SQL files in the current workspace for changes (works only in interactive mode).

### Example: Terminal Options

```hcl
options "terminal" {
  autocomplete       = true                # true, false
  header             = true                # true, false
  multi              = false               # true, false
  output             = "table"             # json, csv, table, line
  separator          = ","                 # any single character
  timing             = false               # true, false
  search_path        = "aws,aws2,gcp,gcp2" # comma-separated string; an exact search_path
  search_path_prefix = "aws2,gcp2"         # comma-separated string; a search_path_prefix to prepend to the search_path
  watch              =  true               # true, false
}
```
-->








