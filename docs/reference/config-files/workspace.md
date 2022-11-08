---
title:  workspace
sidebar_label: workspace
---
# workspace 

A Steampipe `workspace` is a "profile" that allows you to define a unified environment 
that the Steampipe client can interact with.  Each workspace is composed of:
- a single Steampipe database instance
- a single mod directory (which may also contain [dependency mods](/docs/mods/mod-dependencies#mod-dependencies))
- context-specific settings and options  (snapshot location, query timeout, etc)

Steampipe workspaces allow you to define multiple named configurations and easily switch between them using the `--workspace` argument or `STEAMPIPE_WORKSPACE` 
environment variable. 

To learn more, see **[Managing Workspaces →](/docs/managing/workspaces)**



## Supported options  

| Argument            |    Default  | Description
|---------------------|-----------------------------------------------|-----------------------------------------
| `base`              | none                                          | A reference to a named workspace resource that this workspace should source its definition from. Any argument can be overridden after sourcing via base.
| `cloud_host`        | `cloud.steampipe.io`                          | Set the Steampipe Cloud host for connecting to Steampipe Cloud workspace.
| `cloud_token`       | The token obtained by `steampipe login`       | Set the Steampipe Cloud authentication token for connecting to a Steampipe Cloud workspace.  This may be a token obtained by `steampipe login` or a user-generated [token](/docs/cloud/profile#tokens).
| `install_dir`       | `~/.steampipe`                                | The directory in which the Steampipe database, plugins, and supporting files can be found.
| `mod_location`      | The current working directory                 | Set the workspace working directory.
| `query_timeout`     | `240` for controls, unlimited otherwise       | The maximum time (in seconds) a query is allowed to run before it times out.
| `snapshot_location` | The Steampipe Cloud user's personal workspace | Set the Steampipe Cloud workspace or filesystem path for writing snapshots.
| `workspace_database`| `local`                                       | Workspace database. This can be local or a remote Steampipe Cloud database.


<!--

| `search_path`       | `public`, then alphabetical                   | A comma-separated list of connections to use as a custom search path for the control run. See also: [Using search_path to target connections and aggregators](https://steampipe.io/docs/guides/search-path).
| `search_path_prefix`| none                                          | A comma-separated list of connections to use as a prefix to the current search path for the control run. 
| `watch`             | `true`                                        | Watch .sql and .sp files in the current workspace (works only in interactive mode).



| `max_parallel`      | 5                                             | Set the maximum number of parallel executions. When running steampipe check, Steampipe will attempt to run up to this many controls in parallel.


| `options`            | none                                          | An options block to set command-specific options for this workspace.   Only `query` and `check` options are supported.

-->

Note that the HCL argument names are the same as the equivalent CLI argument names,
except using underscore in place of dash:

| Workspace Argument            | Environment Variable           |     Flag             
|-------------------------------|--------------------------------|----------------------|
| `cloud_host`                  | `STEAMPIPE_CLOUD_HOST`         | `--cloud-host`       |
| `cloud_token`                 | `STEAMPIPE_CLOUD_TOKEN`        | `--cloud-token`      |
| `install_dir`                 | `STEAMPIPE_INSTALL_DIR`        | `--install-dir`     |
| `mod_location`                | `STEAMPIPE_MOD_LOCATION`       | `--mod-location`     |
| `query_timeout`               | `STEAMPIPE_QUERY_TIMEOUT`      | `--query_timeout`     |
| `snapshot_location`           | `STEAMPIPE_SNAPSHOT_LOCATION`  | `--snapshot-location`|
| `workspace_database`          | `STEAMPIPE_WORKSPACE_DATABASE` | `--workspace-database`|

<!--
| `search_path`                 | none                           | `--search-path`       |
| `search_path_prefix`          | none                           | `--search-path-prefix`|
| `watch`                       | none                           | `--watch`             |

| `max_parallel`                | `STEAMPIPE_MAX_PARALLEL`       | `--max-parallel`      |
-->

## Examples


```hcl

workspace "default" {
  query_timeout       = 300
}

workspace "all_options" {
  query_timeout       = 300
  cloud_token         = "spt_999faketoken99999999_111faketoken1111111111111"
  cloud_host          = "latestpipe.turbot.io"
  snapshot_location   = "acme/dev"
  workspace_database  = "local" 
  mod_location        = "~/src/steampipe-mod-aws-insights"  
}

workspace "dev" {
  base               = workspace.default
  snapshot_location   = "~/snapshots/"
}
```









