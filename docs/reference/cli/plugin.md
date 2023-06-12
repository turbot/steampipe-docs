---
title: steampipe plugin
sidebar_label: steampipe plugin
---

# steampipe plugin
Steampipe plugin management.

Plugins extend Steampipe to work with many different services and providers. Find plugins using the public registry at [hub.steampipe.io](https://hub.steampipe.io).


## Usage
```bash
steampipe plugin [command]
```

## Available Commands:

| Command | Description
|-|-
| `install`     | Install or update a plugin
| `list`        | List currently installed plugins
| `uninstall`   | Uninstall a plugin
| `update `     | Update one or more plugins

<table>
  <thead>
    <tr>
      <th nowrap="true">Flag</th>
      <th>Description</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td nowrap="true"><inlineCode>--all</inlineCode></td>
      <td>Applies only to <inlineCode>plugin update</inlineCode>, updates ALL installed plugins.</td>
    </tr>
    <tr>
      <td nowrap="true"><inlineCode>--progress</inlineCode></td>
      <td>Enable or disable progress information. By default, progress information is shown - set <inlineCode>--progress=false</inlineCode> to hide the progress bar. Applies only to <inlineCode>plugin install</inlineCode> and <inlineCode>plugin update</inlineCode>.</td>
    </tr>
  </tbody>
</table>

## Examples

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

Update all plugins to the latest and hide the progress bar:
```bash
steampipe plugin update --all --progress=false
```