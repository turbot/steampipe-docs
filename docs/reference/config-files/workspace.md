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

Workspace configurations can be defined in any `.spc` file in the `~/.steampipe/config` directory,
but by convention they are defined in `~/.steampipe/config/workspaces.spc` file. This file may contain
multiple workspace definitions that can then be referenced by name.

Steampipe workspaces allow you to define multiple named configurations and easily switch between them using the `--workspace` argument or `STEAMPIPE_WORKSPACE` 
environment variable. 


```hcl
workspace "local" {
  workspace_database = "local"  
}

workspace "dev_insights" {
  workspace_database = "local"  
  mod_location       = "~/mods/steampipe-mod-aws-insights"
}

workspace "acme_prod" {
  workspace_database = "acme/prod"
  snapshot_location  = "acme/prod"
}
```


To learn more, see **[Managing Workspaces →](/docs/managing/workspaces)**


## Workspace Arguments



Many of the workspace arguments correspond to CLI flags and/or environment variables. 
Any unset arguments will assume the default values.


| Argument            |    Default                                    | Description
|---------------------|-----------------------------------------------|-----------------------------------------
| `base`              |                                               | A reference to a named workspace resource that this workspace should source its definition from. Any argument can be overridden after sourcing via base.
| `cache`             | `true`                                        | Enable/disable caching.  Note that is a **client**  setting -  if the database (`options "database"`) has the cache disabled, then the cache is disabled regardless of the workspace setting. <br /> <br /> Env: [STEAMPIPE_CACHE](/docs/reference/env-vars/steampipe_cache)
| `cache_ttl`         | `300`                                         | Set the client query cache expiration (TTL) in seconds.  Note that is a **client**  setting - if the database `cache_max_ttl` is lower than the `cache_ttl` in the workspace, then the effective ttl for this workspace is the `cache_max_ttl`. <br /> <br /> Env: [STEAMPIPE_CACHE_TTL](/docs/reference/env-vars/steampipe_cache_ttl)
| `cloud_host`        | `pipes.turbot.com`                          | Set the Turbot Pipes host for connecting to Turbot Pipes workspace. DEPRECATED - Use `pipes_host`. <br /> <br /> Env: [STEAMPIPE_CLOUD_HOST](/docs/reference/env-vars/steampipe_cloud_host), [PIPES_HOST](/docs/reference/env-vars/pipes_host)  <br /> CLI: `--cloud-host`
| `cloud_token`       | The token obtained by `steampipe login`       | Set the Turbot Pipes authentication token for connecting to a Turbot Pipes workspace.  DEPRECATED - Use `pipes_token`, <br /> <br /> Env: [STEAMPIPE_CLOUD_TOKEN](/docs/reference/env-vars/steampipe_cloud_token), [PIPES_TOKEN](/docs/reference/env-vars/pipes_token)   <br /> CLI: `--cloud-token`
| `input`             | `true`                                        | Enable/Disable interactive prompts for missing variables.  To disable prompts and fail on missing variables, set to `false`. This is useful when running from scripts.   <br /> <br /> CLI: `--input`
| `install_dir`       | `~/.steampipe`                                | The directory in which the Steampipe database, plugins, and supporting files can be found. <br /> <br /> Env: [STEAMPIPE_INSTALL_DIR](/docs/reference/env-vars/steampipe_install_dir)  <br /> CLI: `--install-dir`
| `introspection`     | `none`                                        | Enable introspection tables that allow you to query the mod resources in the workspace.  Supported values are `none` and `info`. <br /> <br /> Env:  [STEAMPIPE_INTROSPECTION](/docs/reference/env-vars/steampipe_introspection)
| `max_parallel`      | `5`                                           | Set the maximum number of parallel executions. When running steampipe check, Steampipe will attempt to run up to this many controls in parallel. <br /> <br /> Env: [STEAMPIPE_MAX_PARALLEL](/docs/reference/env-vars/steampipe_max_parallel)  <br /> CLI: `--max-parallel`
| `mod_location`      | The current working directory                 | Set the workspace working directory. <br /> <br /> Env: [STEAMPIPE_MOD_LOCATION](/docs/reference/env-vars/steampipe_mod_location)  <br /> CLI: `--mod-location`
| `options`           |                                               | An options block to set command-specific options for this workspace.  [Query](#steampipe-query-options), [check](#steampipe-check-options), and [dashboard](#steampipe-dashboard-options) options are supported.
| `pipes_host`        | `pipes.turbot.com`                          | Set the Turbot Pipes host for connecting to Turbot Pipes workspace. <br /> <br /> Env: [PIPES_HOST](/docs/reference/env-vars/pipes_host)  <br /> CLI: `--pipes-host`
| `pipes_token`       | The token obtained by `steampipe login`       | Set the Turbot Pipes authentication token for connecting to a Turbot Pipes workspace.  This may be a token obtained by `steampipe login` or a user-generated [token](https://turbot.com/pipes/docs/profile#tokens). <br /> <br /> Env: [PIPES_TOKEN](/docs/reference/env-vars/pipes_TOKEN) <br /> CLI: `--pipes-token`
| `progress`          | `true`                                        | Enable or disable progress information.  <br /> <br />CLI: `--progress`
| `query_timeout`     | `240` for controls, unlimited otherwise       | The maximum time (in seconds) a query is allowed to run before it times out. <br /> <br /> Env: [STEAMPIPE_QUERY_TIMEOUT](/docs/reference/env-vars/steampipe_query_timeout)  <br /> CLI: `--query_timeout`
| `search_path`       | `public`, then alphabetical                   | A comma-separated list of connections to use as a custom search path for the control run. See also: [Using search_path to target connections and aggregators](https://steampipe.io/docs/guides/search-path).   <br /> <br />CLI: `--search-path`   
| `search_path_prefix`|                                               | A comma-separated list of connections to use as a prefix to the current search path for the control run.  See also: [Using search_path to target connections and aggregators](https://steampipe.io/docs/guides/search-path).  <br /> <br />CLI: `--search-path-prefix`   
| `snapshot_location` | The Turbot Pipes user's personal workspace | Set the Turbot Pipes workspace or filesystem path for writing snapshots. <br /> <br /> Env: [STEAMPIPE_SNAPSHOT_LOCATION](/docs/reference/env-vars/steampipe_snapshot_location)  <br /> CLI: `--snapshot-location`
| `theme`             | `dark`                                        | Select output theme (color scheme, etc) when running `steampipe check`.  Possible values are `light`,`dark`, and `plain`  <br /> <br />CLI: `--theme` 
| `watch`             | `true`                                        | Watch .sql and .sp files in the current workspace (works only in interactive mode).  <br /> <br />CLI: `--watch` 
| `workspace_database`| `local`                                       | Workspace database. This can be local or a remote Turbot Pipes database. <br /> <br /> Env: [STEAMPIPE_WORKSPACE_DATABASE](/docs/reference/env-vars/steampipe_workspace_database)  <br /> CLI: `--workspace-database`







### Steampipe Query Options 

A `workspace` may include a `options "query"` block to specify values specific to the `steampipe query` command.  

These options often correspond to CLI flags.

<table>
  <thead>
    <tr>
      <th>Argument</th>
      <th>Default</th>
      <th>Description</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><inlineCode>autocomplete</inlineCode></td>
      <td><inlineCode>true</inlineCode></td>
      <td>Enable or disable autocomplete in the interactive query shell.</td>
    </tr>
    <tr>
      <td><inlineCode>header</inlineCode></td>
      <td><inlineCode>true</inlineCode></td>
      <td>Enable or disable column headers. <br /> <br /> CLI: <inlineCode>--header</inlineCode></td>
    </tr>
    <tr>
      <td><inlineCode>multi</inlineCode></td>
      <td><inlineCode>false</inlineCode></td>
      <td>Enable or disable multiline mode.</td>
    </tr>
    <tr>
      <td><inlineCode>output</inlineCode></td>
      <td><inlineCode>table</inlineCode></td>
      <td>Set output format (<inlineCode>json</inlineCode>, <inlineCode>csv</inlineCode>, <inlineCode>table</inlineCode>, or <inlineCode>line</inlineCode>). <br /> <br /> CLI: <inlineCode>--output</inlineCode></td>
    </tr>
    <tr>
      <td><inlineCode>separator</inlineCode></td>
      <td><inlineCode>,</inlineCode></td>
      <td>Set csv output separator. <br /> <br /> CLI: <inlineCode>--separator</inlineCode></td>
    </tr>
    <tr>
      <td><inlineCode>timing</inlineCode></td>
      <td><inlineCode>false</inlineCode></td>
      <td>Enable or disable query execution timing: <inlineCode>off</inlineCode>/<inlineCode>false</inlineCode>, <inlineCode>on</inlineCode>/<inlineCode>true</inlineCode>, or <inlineCode>verbose</inlineCode> <br /> <br /> CLI: <inlineCode>--timing</inlineCode></td>
    </tr>
  </tbody>
</table>


### Steampipe Check Options 
A `workspace` may include a `options "check"` block to specify values specific to the `steampipe check` command.  

These option often correspond to CLI flags.

<table>
  <thead>
    <tr>
      <th>Argument</th>
      <th>Default</th>
      <th>Description</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><inlineCode>header</inlineCode></td>
      <td><inlineCode>true</inlineCode></td>
      <td>Enable or disable column headers. <br /> <br /> CLI: <inlineCode>--header</inlineCode></td>
    </tr>
    <tr>
      <td><inlineCode>output</inlineCode></td>
      <td><inlineCode>text</inlineCode></td>
      <td>Set output format (<inlineCode>brief</inlineCode>, <inlineCode>csv</inlineCode>, <inlineCode>html</inlineCode>, <inlineCode>json</inlineCode>, <inlineCode>md</inlineCode>, <inlineCode>sps</inlineCode> (<i>snapshot</i>), <inlineCode>text</inlineCode>, <inlineCode>none</inlineCode>). <br /> <br /> CLI: <inlineCode>--output</inlineCode></td>
    </tr>
    <tr>
      <td><inlineCode>separator</inlineCode></td>
      <td><inlineCode>,</inlineCode></td>
      <td>Set csv output separator. <br /> <br /> CLI: <inlineCode>--separator</inlineCode></td>
    </tr>
    <tr>
      <td><inlineCode>timing</inlineCode></td>
      <td><inlineCode>false</inlineCode></td>
      <td>Enable or disable query execution timing: <inlineCode>off</inlineCode>/<inlineCode>false</inlineCode>, <inlineCode>on</inlineCode>/<inlineCode>true</inlineCode>, or <inlineCode>verbose</inlineCode> <br /> <br /> CLI: <inlineCode>--timing</inlineCode></td>
    </tr>
  </tbody>
</table>



### Steampipe Dashboard Options 
A `workspace` may include a `options "dashboard"` block to specify values specific to the `steampipe dashboard` command.  

These option often correspond to CLI flags.

<table>
  <thead>
    <tr>
      <th>Argument</th>
      <th>Default</th>
      <th>Description</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><inlineCode>browser</inlineCode></td>
      <td><inlineCode>true</inlineCode></td>
      <td>Specify whether to launch the browser after starting the dashboard server.  <br /> <br /> CLI: <inlineCode>--browser</inlineCode></td>
    </tr>
  </tbody>
</table>


## Examples


```hcl

workspace "default" {
  query_timeout       = 300
}

workspace "dev" {
  base               = workspace.default
  snapshot_location   = "~/snapshots/"
}

workspace "all_options" {
  pipes_host          = "pipes.turbot.com"
  pipes_token         = "tpt_999faketoken99999999_111faketoken1111111111111"
  install_dir         = "~/steampipe2"
  mod_location        = "~/src/steampipe-mod-aws-insights"  
  query_timeout       = 300
  snapshot_location   = "acme/dev"
  workspace_database  = "local" 
  search_path         = "aws,aws_1,aws_2,gcp,gcp_1,gcp_2,slack,github"
  search_path_prefix  = "aws_all"
  watch               = true
  max_parallel        = 5
  introspection       = false
  input               = true
  progress            = true
  theme               = "dark"  # light, dark, plain 
  cache               = true
  cache_ttl           = 300


  options "query" {
    autocomplete        = true
    header              = true    # true, false
    multi               = false   # true, false
    output              = "table" # json, csv, table, line
    separator           = ","     # any single char
    timing              = true   # true, false, verbose
  }

  options "check" {
    header              = true    # true, false
    output              = "text"  # brief, csv, html, json, md, text, snapshot or none (default "text")
    separator           = ","     # any single char
    timing              = true    # true, false, verbose
  }
  
  options "dashboard" {
    browser            = true
  }

}

```




