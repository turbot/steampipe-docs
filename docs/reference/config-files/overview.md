---
title: Configuration Files
sidebar_label: Configuration Files
---

# Configuration Files

Configuration file resource are defined using HCL in one or more Steampipe config files.  Steampipe will load ALL configuration files from `~/.steampipe/config` that have a `.spc` extension.  


Typically, config files are laid out as follows:
- Steampipe creates a `~/.steampipe/config/default.spc` file for setting [options](/docs/reference/config-files/options).
- Each plugin creates a `~/.steampipe/config/{plugin name}.spc` (e.g. `aws.spc`, `github.spc`, `net.spc`, etc). Define your [connections](/docs/reference/config-files/connection) and [plugins](/docs/reference/config-files/plugin) in these files.
- Define your [workspaces](/docs/reference/config-files/workspace) in `~/.steampipe/config/workspaces.spc`.