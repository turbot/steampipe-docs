---
title: Managing Workspaces
sidebar_label: Workspaces
---
# Managing Workspaces (Workspace Profiles)

A Steampipe **Workspace** is a "profile" that allows you to define a unified environment 
that the Steampipe client can interact with.  Each workspace is composed of:
- a single steampipe database instance
- a single mod directory (which may also contain dependency mods)
- one or more locations for other artifacts, such as snapshot files

Steampipe workspaces allow you to [define multiple named configurations](#defining-workspaces):

```hcl
workspace "local" {
  workspace_database = "local"  
  search_path_prefix = "aws_all"
}

workspace "dev_insights" {
  workspace_database = "local"  
  search_path_prefix = "aws_dev"
  mod_location       = "~/mods/steampipe-mod-aws-insights"
}

workspace "acme_prod" {
  workspace_database = "acme/prod"
  snapshot_location  = "acme/prod"
}
```

and [easily switch between them](#using-workspaces) using the `--workspace` argument or `STEAMPIPE_WORKSPACE` 
environment variable:

```bash
steampipe query --workspace local "select * from aws_account"
steampipe query --workspace acme_prod "select * from aws_account"
steampipe dashboard --workspace dev_insights
```

Steampipe Cloud workspaces are [also supported](#implicit-workspaces)
```bash
steampipe query --workspace acme/dev "select * from aws_account"
```


## Defining Workspaces
Workspace configurations can be defined in any `.spc` file in the  `~/.steampipe/config` directory, but by convention they are defined in `~/.steampipe/config/workspaces.spc` file.  This file may contain multiple `workspace` definitions that can then be referenced
by name. 

Note that the HCL argument names are the same as the equivalent cli argument names,
except using underscore in place of dash:

| Workspace Argument            | Environment Variable           |     Flag             
|-------------------------------|--------------------------------|----------------------|
| `cloud_host`                  | `STEAMPIPE_CLOUD_HOST`         | `--cloud-host`       |
| `cloud_token`                 | `STEAMPIPE_CLOUD_TOKEN`        | `--cloud-token`      |
| `snapshot_location`           | `STEAMPIPE_SNAPSHOT_LOCATION`  | `--snapshot-location`|
| `mod_location`                | `STEAMPIPE_MOD_LOCATION`       | `--mod-location`     |
| `workspace_database`          | `STEAMPIPE_WORKSPACE_DATABASE` | `--workspace-database`|
| `search_path`                 | none                           | `--search-path`       |
| `search_path_prefix`          | none                           | `--search-path-prefix`|
| `watch`                       | none                           | `--watch`             |
| `max_parallel`                | `STEAMPIPE_MAX_PARALLEL`       | `--max-parallel`      |
| `query_timeout`               | `STEAMPIPE_QUERY_TIMEOUT`      | `--query_timeout`     |



Any unset arguments will assume use the default values - you don't need to set them all.

```hcl
workspace "default" {
  search_path_prefix = "aws_prod,azure_prod,github,net"
  query_timeout       = 300 # (in seconds) 
  max_parallel        = 3   
}
```

You can use `base=` to inherit settings form another profile:
```hcl
workspace "dev" {
  base               = workspace.default
  search_path_prefix = "aws_dev,azure_dev,github,net"
}
```

The `workspace_database` may be `local` (which is the default):
```
workspace "local_db" {
  workspace_database = "local" # this is the default
}
```

or a Steampipe Cloud workspace, in the form of `{identity_handle}/{workspace_handle}`:
```hcl
workspace "acme_prod" {
  workspace_database = "acme/prod"
}
```

The `snapshot_location` can also be a Steampipe Cloud workspace, in the form 
of `{identity_handle}/{workspace_handle}`: 
```hcl
workspace "acme_prod" {
  workspace_database = "acme/prod"
  snapshot_location  = "acme/prod"
}
```

or if it doesn't match that pattern it will be interpreted to be a path to a 
directory in the local filesystem where snapshots should be written to:

```hcl
workspace "local" {
  workspace_database = "local" 
  snapshot_location  = "home/raj/my-snapshots" 
}
```

The `mod_location` can only be a local filesystem path, as mod files are always read from the machine on which the steampipe client runs.  Often the default
(the working directory) is appropriate, but you can set it explicitly for a workspace.

```hcl
workspace "aws_insights" {
  mod_location       = "~/src/steampipe/mods/steampipe-mod-aws-insights"
  workspace_database = "local" # this is the default
  snapshot_location  = "~/src/steampipe/snaps/steampipe-mod-aws-insights
}
```

You can even specify [`option` blocks for query](/docs/reference/config-files/options#query-options) and [check](/docs/reference/config-files/options#check-options) in a workspace:

```hcl
workspace "local_dev" {
  search_path_prefix  = "aws_all"
  watch  			  = false
  query_timeout       = 300 
  max_parallel        = 5   

  cloud_token        = "spt_999faketoken99999999_111faketoken1111111111111"
  cloud_host         = "cloud.steampipe.io"
  snapshot_location  = "acme/dev"
  mod_location       = "~/mods/steampipe-mod-aws-insights"
  workspace_database = "local" 

  options "query" { 
    multi               = false   # true, false
    output              = "table" # json, csv, table, line
    header              = true    # true, false
    separator           = ","     # any single char
    timing              = true    # true, false
    autocomplete        = true
  }

  options "check" {
    output              = "table" # json, csv, table, line
    header              = true    # true, false
    separator           = ","     # any single char
  }
```


You can even set the `install-dir` for a workspace if you want to use a steampipe data
layer from another [steampipe installation directory](https://steampipe.io/docs/reference/env-vars/steampipe_install_dir).

This allows you to define workspaces in
any install dir:

```hcl
workspace "steampipe_2" {
  workspace_database = "local" 
  install_dir  = "/home/raj/steampipe2" # use that db layer (db, plugins, etc)
}
```

And simply pass the `--workspace` flag (you don't also need to pass `--install-dir`):
```bash
steampipe dashboard --workspace steampipe_2
```



## Using Workspaces

The workspace named `default` is special; If a workspace named `default` exists,
`--workspace` is not  specified in the command, and `STEAMPIPE_WORKSPACE` is not set, 
then steampipe uses "default" workspace:

```bash
steampipe query --snapshot "select * from aws_account"
```

You can pass any workspace to `--workspace` to use its values:

```bash
steampipe query --snapshot --workspace=acme_dev "select * from aws_account" 
```

Or do the same with the `STEAMPIPE_WORKSPACE` environment variable:

```bash
STEAMPIPE_WORKSPACE=acme_dev steampipe query --snapshot "select * from aws_account" 
```

If you specify a workspace on the cli AND environment variable, cli flag wins

```bash
# acme_prod will be used as the effective workspace
export STEAMPIPE_WORKSPACE=acme_dev 
steampipe query --snapshot --workspace=acme_prod "select * from aws_account" 
```

If you specify a workspace on the cli AND more specific flags, any more specific flags will override the workspace values

```bash
# will use "local" as the db, and acme_prod workspace for any OTHER options
steampipe query --snapshot \
  --workspace=acme_prod \
  --workspace_database=local \
  "select * from aws_account" 
```

Environment variable values override 'default' workspace settings when 
'default' workspace is *implicitly used*

```bash
# will use acme/dev as DB, but get the rest of the values from default workspace
export STEAMPIPE_WORKSPACE_DATABASE=acme/dev 
steampipe query --snapshot "select * from aws_account" 
```

If the default  workspace is *explicitly* passed to the `--workspace` argument, 
its values will override any individual environment variables:

```bash
# will NOT use acme/dev as DB - will use ALL of the values from default workspace
export STEAMPIPE_WORKSPACE_DATABASE=acme/dev 
steampipe query --snapshot --workspace=default "select * from aws_account" 
```

The same is true of any named workspace:
```bash
# will NOT use acme/dev as DB - wil use ALL of the values from acme_prod workspace
export STEAMPIPE_WORKSPACE_DATABASE=acme/dev 
steampipe query --snapshot --workspace=acme_prod "select * from aws_account" 
```

## Implicit Workspaces

Named workspaces follow normal standards for hcl identities, thus they cannot contain
the slash (`/`) character.  If you pass a value to `--workspace` or `STEAMPIPE_WORKSPACE`
in the form of `{identity_handle}/{workspace_handle}`, it will be interpreted as
an **implicit workspace**.  Implicit workspaces, as the name suggests, do not
need to be specified in the `workspaces.spc` file.  Instead they will be assumed
to refer to a Steampipe Cloud workspace, which will be used as both the database
and snapshot location.

Essentially, `--workspace acme/dev` is equivalent to:
```hcl
workspace "acme/dev" {
  workspace_database = "acme/dev"
  snapshot_location  = "acme/dev"
}
```
