---
title: Configuration Files
sidebar_label: Configuration Files
---

# Configuration Files

## Options
Configuration options are defined using HCL `options` blocks in one or more Steampipe config files.  Steampipe will load ALL configuration files from `~/.steampipe/config` that have a `.spc` extension.  By default, Steampipe creates a `~/.steampipe/config/default.spc` file for setting `options`.  

Terminal options may also be set at the workspace level; workspace options will override any global options set in the `~/.steampipe/config` directory.  To set terminal options at the workspace level, add them to a `workspace.spc` file in the root of your workspace folder.  The syntax and supported arguments are identical to the [terminal options](reference/config-files/terminal) as set in the global config file.

Note that many of the `options` control settings that can also be specified via other mechanisms, such as command line arguments, environment variables, etc.  These settings are resolved in a standard order:
1. Explicitly set in session (via a meta-command).
2. Specified in command line argument.
3. Set in environment variable.
4. Set in a configuration file `options` argument.
5. If not specified, a default value is used.

The following `options` are currently supported:

| Option Type                       | Description
|-|-
| [general](reference/config-files/general)       | General CLI options, such as auto-update options
| [terminal](reference/config-files/terminal)     | Terminal options, which generally map to meta-commands
| [database](reference/config-files/database)     | Database options
| [connection](reference/config-files/connection) | Options that apply to connections

