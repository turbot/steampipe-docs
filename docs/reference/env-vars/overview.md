---
title:  Environment Variables
sidebar_label:  Environment Variables
---



# Environment Variables

Steampipe supports environment variables to allow you to change its default behavior.  These are optional settings - You are not required to set any environment variables.

Note that plugins may also support environment variables, but these are plugin-specific - refer to your plugin's documentation on the hub.steampipe.io for details.

## Steampipe Environment Variables

| Command | Default | Description
|-|-|-
| [PIPES_HOST](reference/env-vars/pipes_host)  | `pipes.turbot.com` | Set the Turbot Pipes host, for connecting to Turbot Pipes workspace.
| [PIPES_TOKEN](reference/env-vars/pipes_token)  |  | Set the Turbot Pipes authentication token for connecting to Turbot Pipes workspace.
| [STEAMPIPE_CACHE](reference/env-vars/steampipe_cache)| `true` | Enable/disable caching.
| [STEAMPIPE_CACHE_MAX_SIZE_MB](reference/env-vars/steampipe_cache_max_size_mb)| unlimited | Set the maximum size of the query cache across all plugins.
| [STEAMPIPE_CACHE_MAX_TTL](reference/env-vars/steampipe_cache_max_ttl)| `300` | The maximum amount of time to cache results, in seconds.
| [STEAMPIPE_CACHE_TTL](reference/env-vars/steampipe_cache_ttl)| `300` | The amount of time to cache results, in seconds.
| [STEAMPIPE_CLOUD_HOST](reference/env-vars/steampipe_cloud_host)  | `pipes.turbot.com` | Set the Turbot Pipes host, for connecting to Turbot Pipes workspace.
| [STEAMPIPE_CLOUD_TOKEN](reference/env-vars/steampipe_cloud_token)  |  | Set the Turbot Pipes authentication token for connecting to Turbot Pipes workspace.
| [STEAMPIPE_DATABASE_PASSWORD](reference/env-vars/steampipe_database_password)| randomly generated | Set the steampipe database password for this session.  This variable must be set when the steampipe service starts.
| [STEAMPIPE_DATABASE_START_TIMEOUT](reference/env-vars/steampipe_database_start_timeout)| `30` | Set the maximum time (in seconds) to wait for the Postgres process to start accepting queries after it has been started.
| [STEAMPIPE_DIAGNOSTIC_LEVEL](reference/env-vars/steampipe_diagnostic_level)| `NONE` | Sets the diagnostic level.  Supported levels are `ALL`, `NONE`.
| [STEAMPIPE_INSTALL_DIR](reference/env-vars/steampipe_install_dir)| `~/.steampipe` | The directory in which the Steampipe database, plugins, and supporting files can be found.
| [STEAMPIPE_INTROSPECTION](reference/env-vars/steampipe_introspection)  | `none` | Enable introspection tables that allow you to query the mod resources in the workspace.
| [STEAMPIPE_LOG](reference/env-vars/steampipe_log)  | `warn` | Set the logging output level [DEPRECATED - use STEAMPIPE_LOG_LEVEL].
| [STEAMPIPE_LOG_LEVEL](reference/env-vars/steampipe_log)  | `warn` | Set the logging output level.
| [STEAMPIPE_MAX_PARALLEL](reference/env-vars/steampipe_max_parallel)  | `10` | Set the maximum number of parallel executions.
| [STEAMPIPE_MEMORY_MAX_MB](reference/env-vars/steampipe_memory_max_mb)| `1024` | Set a soft memory limit for the `steampipe` process.
| [STEAMPIPE_MOD_LOCATION](reference/env-vars/steampipe_mod_location)  | current working directory | Set the workspace working directory.
| [STEAMPIPE_OTEL_LEVEL](reference/env-vars/steampipe_otel_level)  | `NONE` | Specify which [OpenTelemetry](https://opentelemetry.io/) data to send via OTLP.
| [STEAMPIPE_PLUGIN_MEMORY_MAX_MB](reference/env-vars/steampipe_plugin_memory_max_mb)| `1024` | Set a default memory soft limit for each plugin process.
| [STEAMPIPE_QUERY_TIMEOUT](reference/env-vars/steampipe_query_timeout)  |  `240` for controls, unlimited in all other cases. | Set the amount of time to wait for a query to complete before timing out, in seconds.
| [STEAMPIPE_SNAPSHOT_LOCATION](/docs/reference/env-vars/steampipe_snapshot_location) | The Turbot Pipes user's personal workspace | Set the Turbot Pipes workspace or filesystem path for writing snapshots.
| [STEAMPIPE_TELEMETRY](reference/env-vars/steampipe_telemetry)  | `info` | Set the level of telemetry data to collect and send.
| [STEAMPIPE_UPDATE_CHECK](reference/env-vars/steampipe_update_check)| `true` | Enable/disable automatic update checking.
| [STEAMPIPE_WORKSPACE](reference/env-vars/steampipe_workspace)  | `default` | Set the Steampipe workspace .  This can be named workspace from `workspaces.spc` or a remote Turbot Pipes workspace| [STEAMPIPE_WORKSPACE_CHDIR](reference/env-vars/steampipe_workspace_chdir)  | current working directory | Set the workspace working directory.  [DEPRECATED - use `STEAMPIPE_MOD_LOCATION`].
| [STEAMPIPE_WORKSPACE_DATABASE](reference/env-vars/steampipe_workspace_database)  | `local` | Workspace database.  This can be `local` or a remote Turbot Pipes database.