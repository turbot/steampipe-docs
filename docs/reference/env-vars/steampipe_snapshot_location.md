---
title: STEAMPIPE_SNAPSHOT_LOCATION
sidebar_label: STEAMPIPE_SNAPSHOT_LOCATION
---


# STEAMPIPE_SNAPSHOT_LOCATION

> ***Powerpipe is now the recommended way to run dashboards and benchmarks!***
> Mods still work as normal in Steampipe for now, but they are deprecated and will be removed in a future release:
> - [Steampipe Unbundled →](https://steampipe.io/blog/steampipe-unbundled)
> - [Powerpipe for Steampipe users →](https://powerpipe.io/blog/migrating-from-steampipe)

Sets the location to write [batch snapshots](/docs/snapshots/batch-snapshots) - either a local file path or a [Turbot Pipes workspace](https://turbot.com/pipes/docs/workspaces).

By default, Steampipe will write snapshots to your default Turbot Pipes user workspace.

## Usage 
Set the snapshot location to a local filesystem path:

```bash
export STEAMPIPE_SNAPSHOT_LOCATION=~/my-snaps
```


Set the snapshot location to a Turbot Pipes workspace:

```bash
export STEAMPIPE_SNAPSHOT_LOCATION=vandelay-industries/latex 
```