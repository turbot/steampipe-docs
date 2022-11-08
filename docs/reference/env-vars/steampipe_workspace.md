---
title: STEAMPIPE_WORKSPACE
sidebar_label: STEAMPIPE_WORKSPACE
---


# STEAMPIPE_WORKSPACE

Sets the Steampipe [workspace](/docs/reference/config-files/workspace). 

A Steampipe `workspace` is a "profile" that allows you to define a unified environment that the Steampipe client can interact with. 

To learn more, see **[Managing Workspaces →](/docs/managing/workspaces)**



## Usage 
Use the `my_workspace` workspace:
```bash
export STEAMPIPE_WORKSPACE=my_workspace
```

Use the `acme/prod` Steampipe Cloud workspace:
```bash
export STEAMPIPE_WORKSPACE=acme/prod
```