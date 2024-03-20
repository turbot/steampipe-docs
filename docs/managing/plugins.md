---
title: Managing Plugins
sidebar_label: Plugins
---
# Managing Plugins

Steampipe provides an integrated, standardized SQL interface for querying various services, but it relies on **plugins** to define and implement tables for those services.  This approach decouples the core Steampipe code from the provider-specific implementations, providing flexibility and extensibility. 


## Installing Plugins

Steampipe plugins are packaged as Open Container Images (OCI) and stored in the [Steampipe Hub registry](https://hub.steampipe.io).  This registry contains a curated set of plugins developed by and/or vetted by Turbot.  To install the latest version of a standard plugin, you can simply install it by name.

For example, to install the latest `aws` plugin:
```
$ steampipe plugin install aws
```

This will download the latest aws plugin (the one with the `latest` tag) from the hub registry, and will set up a default connection named `aws`. 


### Installing a Specific Version
To install a specific version, simply specify the version tag after the plugin name, separated by `@` or `:`

For example, to install the 0.0.1 version of the aws plugin:
```
$ steampipe plugin install aws@0.0.1
```

This will download the aws plugin version 0.0.1 (the one with the `0.0.1` tag) from the hub registry.  Note that installing a specific version will NOT create a connection for you - you must create/edit a [connection](/docs/managing/connections) configuration file in order to use the plugin. 


### Installing from a Release Stream

Plugins should follow semantic versioning guidelines, and they are tagged in the registry with a **version tag** that specifies their *exact version* (e.g. `1.0.1`).  

In addition, **release stream** tags are used to allow you to limit updates to specific *major or minor release families*.  

The intent of the version tag is that is immutable - while it is technically possible to move the version tag to a different image version, this should not be done.  Unlike the version tag, the release stream tags are intentionally moved as new versions are released.  For example `steampipe plugin install aws@1.0` will install the latest version in the `1.0` minor release stream.  If versions `1.0.0` and `1.0.1` both exist, then `aws@1.0` will point to `1.0.1`.  When `1.0.2` is added to the registry, the `1.0` tag will be moved to point to `1.0.2`. 

Installing a release stream tag allows you to "lock" to a specific major or minor release.  If you install `aws@1`, for example, `steampipe plugin update` (and auto-updates) will only update to the latest 1.x version - you will not be updated to version 2.x.

Because these are just tags, the install command uses the same `imagename@tag` syntax:
- To install the latest version in major release stream:
```
$ steampipe plugin install aws@2
```

- To install the latest version in minor release stream:
```
$ steampipe plugin install aws@2.1
```

Note that installing a tagged release will NOT create a connection for you - you must create/edit a [connection](managing/connections) configuration file in order to use the plugin. 

### Installing from another registry
Steampipe plugins are packaged in OCI format and can be hosted and installed from any artifact repository or container registry that supports OCI V2 images. To install a plugin from a repository, specify the full path in the install command:

```
$ steampipe plugin install us-docker.pkg.dev/myproject/myrepo/myplugin@mytag
```

### Installing from a File
A plugin binary can be installed manually, and this is often convenient when developing the plugin. Steampipe will attempt to load any plugin that is referred to in a `connection` configuration:
- The plugin binary file must have a `.plugin` extension
- The plugin binary must reside in a subdirectory of the `~/.steampipe/plugins/` directory and must be the ONLY `.plugin` file in that subdirectory
- The `connection` must specify the path (relative to `~/.steampipe/plugins/`) to the plugin in the `plugin` argument

For example, consider a `myplugin` plugin that you have developed.  To install it:
- Create a subdirectory `.steampipe/plugins/local/myplugin`
- Name your plugin binary `myplugin.plugin`, and copy it to `.steampipe/plugins/local/myplugin/myplugin.plugin` 
- Create a `~/.steampipe/config/myplugin.spc` config file containing a connection definition that points to your plugin:
    ```hcl
    connection "myplugin" {
        plugin    = "local/myplugin"                 
    }
    ```

### Installing Missing Plugins

You can install all missing plugins that are referenced in your configuration files:

```bash
$ steampipe plugin install
```

Running `steampipe plugin install` with no arguments will cause Steampipe to read all `connection` and `plugin` blocks in all `.spc` files in the `~/.steampipe/config` directory and install any that are referenced but are not installed.  Note that when doing so, any default `.spc` file that does not exist in the configuration will also be copied.  You may pass the `--skip-config` flag if you don't want to copy these files:

```bash
$ steampipe plugin install --skip-config
```


## Viewing Installed Plugins
You can list the installed plugins with the `steampipe plugin list` command:

```
$ steampipe plugin list
┌─────────────────────────────────────────────────────┬─────────┬─────────────────────────────────────────────┐
│ NAME                                                │ VERSION │ CONNECTIONS                                 │
├─────────────────────────────────────────────────────┼─────────┼─────────────────────────────────────────────┤
│ hub.steampipe.io/plugins/turbot/aws@latest          │ 0.4.0   │ aws,aws_account_aaa,aws_account_aab         │
│ hub.steampipe.io/plugins/turbot/digitalocean@latest │ 0.1.0   │ digitalocean                                │
│ hub.steampipe.io/plugins/turbot/gcp@latest          │ 0.0.6   │ gcp_project_a,gcp,gcp_project_b             │
│ hub.steampipe.io/plugins/turbot/github@latest       │ 0.0.5   │ github                                      │
│ hub.steampipe.io/plugins/turbot/steampipe@latest    │ 0.0.2   │ steampipe                                   │
└─────────────────────────────────────────────────────┴─────────┴─────────────────────────────────────────────┘
```

## Updating Plugins

To update a plugin to the latest version for a given stream, you can use the  `steampipe plugin update` command:

```
steampipe plugin update plugin_name[@stream]
``` 

The syntax and semantics are identical to the install command -  `steampipe plugin update aws` will get the latest aws plugin, `steampipe plugin update aws@1` will get the latest in the 1.x major stream, etc.


To update **all** plugins to the latest in the installed stream:
```bash
steampipe plugin update --all
```


## Removing Plugins
You can uninstall a plugin with the `steampipe plugin remove` command:

```
steampipe plugin uninstall [plugin]
```  

Note that you cannot remove a plugin if there are active connections using it.  You must remove any connections that use the plugin first:

```
$ steampipe plugin list
+--------------------------------------------------+---------+-------------+
|                       NAME                       | VERSION | CONNECTIONS |
+--------------------------------------------------+---------+-------------+
| hub.steampipe.io/plugins/turbot/aws@latest       | 0.0.5   | aws         |
| hub.steampipe.io/plugins/turbot/steampipe@latest | 0.0.1   | steampipe   |
+--------------------------------------------------+---------+-------------+

$ steampipe plugin remove steampipe
Error: Failed to remove plugin 'steampipe' - there are active connections using it: 'steampipe'

$ rm ~/.steampipe/config/steampipe.spc 

$ steampipe plugin remove steampipe
Removed plugin steampipe
$ steampipe plugin list
+--------------------------------------------+---------+-------------+
|                    NAME                    | VERSION | CONNECTIONS |
+--------------------------------------------+---------+-------------+
| hub.steampipe.io/plugins/turbot/aws@latest | 0.0.5   | aws         |
+--------------------------------------------+---------+-------------+
```

## Steampipe Plugin Registry Support Lifecycle

The Steampipe Plugin Registry is committed to ensuring accessibility and stability for its users by maintaining copies of plugins for at least one year and preserving at least eight versions of each plugin. This practice ensures that users can access older versions of plugins if needed, providing a safety net for compatibility issues or preferences. By retaining multiple versions, the registry accommodates users who may require specific functionalities or rely on older software configurations.