---
title: connection
sidebar_label: connection
---

# connection 

The `connection` block defines a Steampipe [plugin connection](/docs/managing/plugins#installing-plugins) or [aggregator](/docs/managing/connections#using-aggregators). 

Most `connection` arguments are plugin-specific, and they are used to specify credentials, accounts, and other options.  The [Steampipe Hub](https://hub.steampipe.io/plugins) provides detailed information about the arguments for each plugin. 

## Supported options  
| Argument | Default | Values | Description 
|-|-|-|-
| `plugin` | none     | [plugin version string](#plugin-version-strings) |  The plugin version that this connection uses.  This must refer to an [installed plugin version](/docs/managing/plugins#installing-plugins).
| `type`   | `plugin` | `plugin`, `aggregator` | The type of connection  - [plugin connection](/docs/managing/plugins#installing-plugins) or [aggregator](/docs/managing/connections#using-aggregators).
| `options` | none     | `options "connection"` block | An optional `options` block to set [connection options](reference/config-files/options#connection-options) for this connection.   Only `connection` options are supported.
| `{plugin argument}`| varies |  varies|  Additional options are defined in each plugin - refer to the documentation for your plugin on the [Steampipe Hub](https://hub.steampipe.io/plugins).



### Plugin Version Strings 

Steampipe plugin versions are in the format:
```
[{organization}/]{plugin name}[@release stream]
```

The `{organization}` is optional, and if it is not specified, it is assumed to be `turbot`.  The `{release stream}` is also optional, and defaults to `@latest`.  As a result, plugin version are usually simple plugin names:

```hcl
connection "net" {
  plugin = "net"  # this is the same as turbot/net@latest
}
```

You may specify a [specific version](/docs/managing/plugins#installing-a-specific-version):
```hcl
connection "net" {
  plugin = "net@0.6.0"
}
```

Or a [release stream](/docs/managing/plugins#installing-from-a-release-stream):
```hcl
connection "net" {
  plugin = "net@0.6"
}
```


For third-party plugins, the `{organization}` must be specified:
```hcl
connection "scalingo" {
  plugin = "francois2metz/scalingo"
}
```

You can even use a [local path](/docs/managing/plugins#installing-from-a-file) while developing plugins:

```hcl
connection "myplugin" {
   plugin            = "local/myplugin"
}
```

## Examples
```hcl
connection "aws_all" {
  type        = "aggregator"
  plugin      = "aws"  
  connections = ["aws_*"]
}

connection "aws_01" {
  plugin      = "aws" 
  profile     = "aws_01"
  regions     = ["*"]
}

connection "aws_02" {
  plugin      = "aws" 
  profile     = "aws_02"
  regions     = ["us-*", "eu-*"]
}

connection "aws_03" {
  plugin      = "aws" 
  aws_access_key_id = AKIA4YFAKEKEYXTDS252
  aws_secret_access_key = SH42YMW5p3EThisIsNotRealzTiEUwXN8BOIOF5J8m
  regions     = ["us-east-1", "us-west-2"]
}

```