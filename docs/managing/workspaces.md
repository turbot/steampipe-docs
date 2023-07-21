---
title: Managing Workspaces
sidebar_label: Workspaces
---
# Managing Workspaces

A Steampipe `workspace` is a "profile" that allows you to define a unified environment 
that the Steampipe client can interact with.  Each workspace is composed of:
- a single Steampipe database instance
- a single mod directory (which may also contain [dependency mods](/docs/mods/mod-dependencies#mod-dependencies))
- context-specific settings and options  (snapshot location, query timeout, etc)

Steampipe workspaces allow you to [define multiple named configurations](#defining-workspaces):

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

and [easily switch between them](#using-workspaces) using the `--workspace` argument or `STEAMPIPE_WORKSPACE` 
environment variable:

```bash
steampipe query --workspace local "select * from aws_account"
steampipe query --workspace acme_prod "select * from aws_account"
steampipe dashboard --workspace dev_insights
```

Turbot Pipes workspaces are [automatically supported](#implicit-workspaces):
```bash
steampipe query --workspace acme/dev "select * from aws_account"
```


## Defining Workspaces
[Workspace](/docs/reference/config-files/workspace) configurations can be defined in any `.spc` file in the  `~/.steampipe/config` directory, but by convention they are defined in `~/.steampipe/config/workspaces.spc` file.  This file may contain multiple `workspace` definitions that can then be referenced
by name. 


Any unset arguments will assume the default values - you don't need to set them all:

```hcl
workspace "default" {
  query_timeout       = 300
}
```

You can use `base=` to inherit settings form another profile:
```hcl
workspace "dev" {
  base               = workspace.default
  workspace_database = "acme/dev"
}
```

The `workspace_database` may be `local` (which is the default):
```hcl
workspace "local_db" {
  workspace_database = "local"
}
```

or a Turbot Pipes workspace, in the form of `{identity_handle}/{workspace_handle}`:
```hcl
workspace "acme_prod" {
  workspace_database = "acme/prod"
}
```

The `snapshot_location` can also be a Turbot Pipes workspace, in the form 
of `{identity_handle}/{workspace_handle}`: 
```hcl
workspace "acme_prod" {
  workspace_database = "acme/prod"
  snapshot_location  = "acme/prod"
}
```

If it doesn't match the `{identity_handle}/{workspace_handle}` pattern it will be interpreted to be a path to a directory in the local filesystem where snapshots should be written to:

```hcl
workspace "local" {
  workspace_database = "local" 
  snapshot_location  = "home/raj/my-snapshots" 
}
```

The `mod_location` can only be a local filesystem path, as mod files are always read from the machine on which the Steampipe client runs.  Often the default (the working directory) is appropriate, but you can set it explicitly for a workspace.

```hcl
workspace "aws_insights" {
  workspace_database = "local"
  snapshot_location  = "home/raj/my-snapshots"
  mod_location       = "~/src/steampipe/mods/steampipe-mod-aws-insights"
}
```

<!--
You can specify [`options` blocks for query](/docs/reference/config-files/options#query-options) and [check](/docs/reference/config-files/options#check-options) in a workspace:

```hcl
workspace "local_dev" {
  search_path_prefix  = "aws_all"
  watch  			        = false
  query_timeout       = 300 
  max_parallel        = 5   
  cloud_token         = "spt_999faketoken99999999_111faketoken1111111111111"
  cloud_host          = "pipes.turbot.com"
  snapshot_location   = "acme/dev"
  mod_location        = "~/mods/steampipe-mod-aws-insights"
  workspace_database  = "local" 

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
}
```

-->

You can even set the `install_dir` for a workspace if you want to use the data layer from another [Steampipe installation directory](https://steampipe.io/docs/reference/env-vars/steampipe_install_dir).

This allows you to define workspaces that use a database from another installation directory:

```hcl
workspace "steampipe_2" {
  install_dir = "~/steampipe2"
}
```

and easily switch between them with the `--workspace` flag:
```bash
steampipe dashboard --workspace steampipe_2
```



## Using Workspaces
Workspaces may be defined in any `.spc` file in the `~/.steampipe/config` directory, but by convention they should be placed in the `~/.steampipe/config/workspaces.spc` file.

The workspace named `default` is special; if a workspace named `default` exists,
`--workspace` is not  specified in the command, and `STEAMPIPE_WORKSPACE` is not set, 
then Steampipe uses the `default` workspace:

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

If you specify the `--workspace` argument and the `STEAMPIPE_WORKSPACE` environment variable, the `--workspace` argument wins:

```bash
# acme_prod will be used as the effective workspace
export STEAMPIPE_WORKSPACE=acme_dev 
steampipe query --snapshot --workspace=acme_prod "select * from aws_account" 
```

If you specify the `--workspace` argument and more specific arguments (`workspace_database`, `mod_location`, etc), any more specific arguments will override the workspace values:

```bash
# will use "local" as the db, and acme_prod workspace for any OTHER options
steampipe query --snapshot \
  --workspace=acme_prod \
  --workspace_database=local \
  "select * from aws_account" 
```

Environment variable values override `default` workspace settings when the `default` workspace is *implicitly used*:

```bash
# will use acme/dev as DB, but get the rest of the values from default workspace
export STEAMPIPE_WORKSPACE_DATABASE=acme/dev 
steampipe query --snapshot "select * from aws_account" 
```

If the default  workspace is *explicitly* passed to the `--workspace` argument, its values will override any individual environment variables:

```bash
# will NOT use acme/dev as DB - will use ALL of the values from default workspace
export STEAMPIPE_WORKSPACE_DATABASE=acme/dev 
steampipe query --snapshot --workspace=default "select * from aws_account" 
```

The same is true of any named workspace:
```bash
# will NOT use acme/dev as DB - will use ALL of the values from acme_prod workspace
export STEAMPIPE_WORKSPACE_DATABASE=acme/dev 
steampipe query --snapshot --workspace=acme_prod "select * from aws_account" 
```

## Implicit Workspaces

Named workspaces follow normal standards for HCL identifiers, thus they cannot contain
the slash (`/`) character.  If you pass a value to `--workspace` or `STEAMPIPE_WORKSPACE`
in the form of `{identity_handle}/{workspace_handle}`, it will be interpreted as
an **implicit workspace**.  Implicit workspaces, as the name suggests, do not
need to be specified in the `workspaces.spc` file.  Instead they will be assumed
to refer to a Turbot Pipes workspace, which will be used as both the database (`workspace_database`)
and snapshot location (`snapshot_location`).

Essentially, `--workspace acme/dev` is equivalent to:
```hcl
workspace "acme/dev" {
  workspace_database = "acme/dev"
  snapshot_location  = "acme/dev"
}
```
