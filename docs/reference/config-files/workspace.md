---
title:  workspace
sidebar_label: workspace
---
# Workspace 

A Steampipe **Workspace** is a "profile" that allows you to define a unified environment 
that the Steampipe client can interact with.  Each workspace is composed of:
- a single steampipe database instance
- a single mod directory (which may also contain dependency mods)
- one or more locations for other artifacts, such as snapshot files

Steampipe workspaces allow you to define multiple named configurations and easily switch between them using the `--workspace` argument or `STEAMPIPE_WORKSPACE` 
environment variable. 



### Supported options  

| Argument            |    Default  | Description
|---------------------|-----------------------------------------------|-----------------------------------------
| `base`              | none                                          | A reference to a named workspace resource that this workspace should source its definition from. Any argument can be overridden after sourcing via base
| `cloud_host`        | `cloud.steampipe.io`                          | Set the Steampipe Cloud host, for connecting to Steampipe Cloud workspace
| `cloud_token`       | The token obtained by `steampipe login`       | Set the Steampipe Cloud authentication token for connecting to Steampipe Cloud workspace
| `snapshot_location` | The Steampipe Cloud user's personal workspace | Set the Steampipe CLoud workspace or filesystem path for reading and writing snapshots
| `mod_location`      | The current working directory                 | Set the workspace working directory
| `workspace_database`| `local`                                       | Workspace database. This can be local or a remote Steampipe Cloud database
| `search_path`       | `public`, then alphabetical                   | A comma-separated list of connections to use as a custom search path for the control run.
| `search_path_prefix`| none                                          | A comma-separated list of connections to use as a prefix to the current search path for the control run.
| `watch`             | `true`                                        | Watch .sql and .sp files in the current workspace (works only in interactive mode)        
| `max_parallel`      | 5                                             | Set the maximum number of parallel executions. When running steampipe check, Steampipe will attempt to run up to this many controls in parallel 
| `query_timeout`     | no limit                                      | The maximum time (in seconds) a query is allowed to run before it times out
| `option`            | none                                          | An option block to set command-specific options for this workspace.   Only `query` and `check` options are supported

### Examples


```hcl

workspace "default" {
  search_path_prefix = "aws_prod,azure_prod,github,net"
}

workspace "all_options" {
  search_path_prefix  = "aws_all"
  watch               = true
  query_timeout       = 300
  max_parallel        = 5
  cloud_token         = "spt_999faketoken99999999_111faketoken1111111111111"
  cloud_host          = "latestpipe.turbot.io"
  snapshot_location   = "acme/dev"
  mod_location        = "~/mods/steampipe-mod-aws-insights"
  workspace_database  = "local" 
  install_dir         = "/home/raj/steampipe2" # use that db layer (db, plugins, etc)

  options "query" { 
    multi               = false
    output              = "table"
    header              = true
    separator           = ","
    timing              = true
    autocomplete        = true
  }

  options "check" {
    output              = "csv"
    header              = true
    separator           = ","
  }
}

workspace "dev" {
  base               = workspace.default
  search_path_prefix = "aws_dev"
}
```


See [Managing Workspaces](/docs/managing/workspaces) for more examples.



