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
| [STEAMPIPE_CACHE](reference/env-vars/steampipe_cache)| `true` | Enable/disable caching [DEPRECATED]
| [STEAMPIPE_CACHE_MAX_SIZE_MB](reference/env-vars/steampipe_cache_max_size_mb)| unlimited | Set the maximum size of the query cache across all plugins
| [STEAMPIPE_CACHE_TTL](reference/env-vars/steampipe_cache_ttl)| `300` | The amount of time to cache results, in seconds [DEPRECATED]
| [STEAMPIPE_CLOUD_HOST](reference/env-vars/steampipe_cloud_host)  | `cloud.steampipe.io` | Set the Steampipe Cloud host, for connecting to Steampipe Cloud workspace
| [STEAMPIPE_CLOUD_TOKEN](reference/env-vars/steampipe_cloud_token)  |  | Set the Steampipe Cloud authentication token for connecting to Steampipe Cloud workspace
| [STEAMPIPE_DATABASE_PASSWORD](reference/env-vars/steampipe_database_password)| randomly generated | Set the steampipe database password for this session.  This variable must be set when the steampipe service starts
| [STEAMPIPE_INSTALL_DIR](reference/env-vars/steampipe_install_dir)| `~/.steampipe` | The directory in which the Steampipe database, plugins, and supporting files can be found
| [STEAMPIPE_LOG](reference/env-vars/steampipe_log)  | `warn` | Set the logging output level [DEPRECATED - use STEAMPIPE_LOG_LEVEL]
| [STEAMPIPE_LOG_LEVEL](reference/env-vars/steampipe_log)  | `warn` | Set the logging output level
| [STEAMPIPE_MAX_PARALLEL](reference/env-vars/steampipe_max_parallel)  | `5` | Set the maximum number of parallel executions
| [STEAMPIPE_OTEL_LEVEL](reference/env-vars/steampipe_otel_level)  | `NONE` | Specify which [OpenTelemetry](https://opentelemetry.io/) data to send via OTLP
| [STEAMPIPE_TELEMETRY](reference/env-vars/steampipe_telemetry)  | `info` | Set the level of telemetry data to collect and send
| [STEAMPIPE_UPDATE_CHECK](reference/env-vars/steampipe_update_check)| `true` | Enable/disable automatic update checking
| [STEAMPIPE_WORKSPACE_CHDIR](reference/env-vars/steampipe_workspace_chdir)  | current working directory | Set the workspace working directory
| [STEAMPIPE_WORKSPACE_DATABASE](reference/env-vars/steampipe_workspace_database)  | `local` | Workspace database.  this can be `local` or a remote Steampipe Cloud database