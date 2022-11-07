---
title: Configuration Files
sidebar_label: Configuration Files
---

# Configuration Files

Configuration file resource are defined using HCL in one or more Steampipe config files.  Steampipe will load ALL configuration files from `~/.steampipe/config` that have a `.spc` extension.  


Typically, config files are laid out as follows:
- Steampipe creates a `~/.steampipe/config/default.spc` file for setting [options](reference/config-files/options).
- Each plugin creates a `~/.steampipe/config/{plugin name}.spc` (e.g. `aws.spc`, `github.spc`, `net.spc`, etc). Define your [connections](reference/config-files/connection) in these files.
- Define your [workspaces](reference/config-files/workspace) in `~/.steampipe/config/workspaces.spc`.