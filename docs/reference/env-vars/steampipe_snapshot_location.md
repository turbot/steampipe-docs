---
title: STEAMPIPE_SNAPSHOT_LOCATION
sidebar_label: STEAMPIPE_SNAPSHOT_LOCATION
---


# STEAMPIPE_SNAPSHOT_LOCATION
Sets the location to write [batch snapshots](/docs/snapshots/batch-snapshots) - either a local file path or a [Steampipe Cloud workspace](/docs/cloud/workspaces).

By default, Steampipe will write snapshots to your default Steampipe Cloud user workspace.

## Usage 
Set the snapshot location to a local filesystem path:

```bash
export STEAMPIPE_SNAPSHOT_LOCATION=~/my-snaps
```


Set the snapshot location to a Steampipe Cloud workspace:

```bash
export STEAMPIPE_SNAPSHOT_LOCATION=vandelay-industries/latex 
```