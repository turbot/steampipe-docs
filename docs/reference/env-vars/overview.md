---
title:  Environment Variables
sidebar_label:  Environment Variables
---



# Environment Variables

Steampipe supports environment variables to allow you to change its default behavior.  These are optional settings - You are not required to set any environment variables.

Note that plugins may also support environment variables, but these are plugin-specific - refer to your plugin's documentation on hub.steampipe.io for details.

## Steampipe Environment Variables

| Command | Default | Description
|-|-|-
| [PIPES_HOST](/docs/reference/env-vars/pipes_host)  | `pipes.turbot.com` | Set the Turbot Pipes host, for connecting to Turbot Pipes workspace.
| [PIPES_TOKEN](/docs/reference/env-vars/pipes_token)  |  | Set the Turbot Pipes authentication token for connecting to Turbot Pipes workspace.
| [STEAMPIPE_CACHE](/docs/reference/env-vars/steampipe_cache)| `true` | Enable/disable caching.
| [STEAMPIPE_CACHE_MAX_SIZE_MB](/docs/reference/env-vars/steampipe_cache_max_size_mb)| unlimited | Set the maximum size of the query cache across all plugins. [DEPRECATED - use `STEAMPIPE_PLUGIN_MEMORY_MAX_MB`].
| [STEAMPIPE_CACHE_MAX_TTL](/docs/reference/env-vars/steampipe_cache_max_ttl)| `300` | The maximum amount of time to cache results, in seconds.
| [STEAMPIPE_CACHE_TTL](/docs/reference/env-vars/steampipe_cache_ttl)| `300` | The amount of time to cache results, in seconds.
| [STEAMPIPE_DATABASE_PASSWORD](/docs/reference/env-vars/steampipe_database_password)| randomly generated | Set the steampipe database password for this session.  This variable must be set when the steampipe service starts.
| [STEAMPIPE_DATABASE_SSL_PASSWORD](/docs/reference/env-vars/steampipe_database_ssl_password)|  | Set the passphrase used to decrypt the private key for your custom SSL certificate.  By default, Steampipe generates a certificate without a passphrase; you only need to set this variable if you use a custom certificate that is protected by a passphrase.
| [STEAMPIPE_DATABASE_START_TIMEOUT](/docs/reference/env-vars/steampipe_database_start_timeout)| `30` | Set the maximum time (in seconds) to wait for the Postgres process to start accepting queries after it has been started.
| [STEAMPIPE_DIAGNOSTIC_LEVEL](/docs/reference/env-vars/steampipe_diagnostic_level)| `NONE` | Sets the diagnostic level.  Supported levels are `ALL`, `NONE`.
| [STEAMPIPE_INSTALL_DIR](/docs/reference/env-vars/steampipe_install_dir)| `~/.steampipe` | The directory in which the Steampipe database, plugins, and supporting files can be found.
| [STEAMPIPE_LOG](/docs/reference/env-vars/steampipe_log)  | `warn` | Set the logging output level [DEPRECATED - use `STEAMPIPE_LOG_LEVEL`].
| [STEAMPIPE_LOG_LEVEL](/docs/reference/env-vars/steampipe_log)  | `warn` | Set the logging output level.
| [STEAMPIPE_MEMORY_MAX_MB](/docs/reference/env-vars/steampipe_memory_max_mb)| `1024` | Set a soft memory limit for the `steampipe` process.
| [STEAMPIPE_OTEL_INSECURE](/docs/reference/env-vars/steampipe_otel_insecure)  | `false` | Bypass the SSL/TLS secure connection requirements when connecting to an OpenTelemetry server.
| [STEAMPIPE_OTEL_LEVEL](/docs/reference/env-vars/steampipe_otel_level)  | `NONE` | Specify which [OpenTelemetry](https://opentelemetry.io/) data to send via OTLP.
| [STEAMPIPE_PLUGIN_MEMORY_MAX_MB](/docs/reference/env-vars/steampipe_plugin_memory_max_mb)| `1024` | Set a default memory soft limit for each plugin process.
| [STEAMPIPE_QUERY_TIMEOUT](/docs/reference/env-vars/steampipe_query_timeout)  |  `240` for controls, unlimited in all other cases. | Set the amount of time to wait for a query to complete before timing out, in seconds.
| [STEAMPIPE_SNAPSHOT_LOCATION](/docs/reference/env-vars/steampipe_snapshot_location) | The Turbot Pipes user's personal workspace | Set the Turbot Pipes workspace or filesystem path for writing snapshots.
| [STEAMPIPE_TELEMETRY](/docs/reference/env-vars/steampipe_telemetry)  | `info` | Set the level of telemetry data to collect and send.
| [STEAMPIPE_UPDATE_CHECK](/docs/reference/env-vars/steampipe_update_check)| `true` | Enable/disable automatic update checking.
| [STEAMPIPE_WORKSPACE](/docs/reference/env-vars/steampipe_workspace)  | `default` | Set the Steampipe workspace .  This can be named workspace from `workspaces.spc` or a remote Turbot Pipes workspace
| [STEAMPIPE_WORKSPACE_DATABASE](/docs/reference/env-vars/steampipe_workspace_database)  | `local` | Workspace database.  This can be `local` or a remote Turbot Pipes database.