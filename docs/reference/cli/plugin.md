---
title: steampipe plugin
sidebar_label: steampipe plugin
---



## steampipe plugin
Steampipe plugin management.

Plugins extend Steampipe to work with many different services and providers. Find plugins using the public registry at [hub.steampipe.io](https://hub.steampipe.io).


### Usage
```bash
steampipe plugin [command]
```

### Available Commands:

| Command | Description
|-|-
| `install`     | Install or update a plugin
| `list`        | List currently installed plugins
| `uninstall`   | Uninstall a plugin
| `update `     | Update one or more plugins

| Flag | Description
|-|-
|` --all` | Applies only to `plugin update`, updates ALL installed plugins

### Examples

Install or update a plugin:
```bash
steampipe plugin install aws
```

List installed plugins:
```bash
steampipe plugin list
```

Uninstall a plugin:
```bash
steampipe plugin uninstall dmi/paper
```

Update all plugins to the latest in the installed stream:
```bash
steampipe plugin update --all
```

Update the aws plugin to the latest in the 0.1 minor stream:
```bash
steampipe plugin update aws@0.1
```