---
title: steampipe mod
sidebar_label: steampipe mod
---


# steampipe mod
Steampipe mod management.

Mods provide an easy way to share Steampipe queries, controls, and benchmarks.  Find mods using the public registry at [hub.steampipe.io](https://hub.steampipe.io/mods).


## Usage
```bash
steampipe mod [command]
```

## Available Commands:

| Command | Description
|-|-
| `init`        | Initialize the current directory with a `mod.sp` file 
| `install`     | Install one or more mods and their dependencies
| `list`        | List currently installed mods
| `uninstall`   | Uninstall a mod and its dependencies
| `update `     | Update one or more mods and their dependencies


| Flag | Description
|-|-
|` --dry-run` | Show which mods would be installed/updated/uninstalled without modifying them (default `false`).
|` --prune` | Remove unused mods and dependencies when doing `mod update` and `mod install` (default `true`).



## Examples
List installed mods:
```bash
steampipe mod list
```

Install a mod and add the `require` statement to your `mod.sp`:
```bash
steampipe mod install github.com/turbot/steampipe-mod-aws-compliance
```

Install an exact version of a mod and update the `require` statement to your `mod.sp`.  This may upgrade or downgrade the mod if it is already installed:
```bash
steampipe mod install github.com/turbot/steampipe-mod-aws-compliance@0.1
```

Install a version of a mod using a semver constraint and update the `require` statement to your `mod.sp`.  This may upgrade or downgrade the mod if it is already installed:
```bash
steampipe mod install github.com/turbot/steampipe-mod-aws-compliance@'^1'
```

Install all mods specified in the `mod.sp` and their dependencies:
```bash
steampipe mod install
```

Preview what `steampipe mod install` will do, without actually installing anything:
```bash
steampipe mod install --dry-run
```


Update a mod to the latest version allowed by its current constraint:
```bash
steampipe mod update github.com/turbot/steampipe-mod-aws-compliance
```

Update all mods specified in the `mod.sp` and their dependencies to the latest versions that meet their constraints, and install any that are missing:
```bash
steampipe mod update
```


Uninstall a mod:
```bash
steampipe mod uninstall github.com/turbot/steampipe-mod-azure-compliance
```

Preview uninstalling a mod, but don't uninstall it:
```bash
steampipe mod uninstall  github.com/turbot/steampipe-mod-gcp-compliance --dry-run
```
