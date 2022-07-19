---
title: steampipe service
sidebar_label: steampipe service
---



## steampipe service
Steampipe service management.

`steampipe service` allows you to run Steampipe as a local service, exposing it as a database endpoint for connection from any Postgres-compatible database client.

### Usage
```bash
steampipe service [command]
```

### Sub-Commands

| Command | Description
|-|-
| `restart` | Restart Steampipe service
| `start`   | Start Steampipe in service mode
| `status`  | Status of the Steampipe service
| `stop`    | Stop Steampipe service


### Flags

| Flag | Applies to | Description
|-|-|-
| `--dashboard` |  `start` | Start the `dashboard` web server with the database service
| `--dashboard-listen string` | `start` | Accept dashboard connections from: `local` (localhost only) or `network` (open)
| `--dashboard-port int` |  `start` | Dashboard web server port (default `9194`)
| `--database-listen string` |  `start` | Accept database connections from: `local` (localhost only) or `network` (open)
| `--database-password string`  |  `start` |  Set the steampipe database password for this session.  See [STEAMPIPE_DATABASE_PASSWORD](reference/env-vars/steampipe_database_password) for additional information
| `--database-port int` | `start` |  Database service port (default 9193)
| `--force` |  `stop`, `restart` | Forces the service to shutdown, releasing all open connections and ports
| `--foreground` |  `start` | Run the service in the foreground
| `--show-password` |  `start`, `status` | View database password for connecting from another machine (default false)
| `--var stringArray` |  `start` | Specify the value of a variable (only applies if '--dashboard' flag is also set)
| `--var-file strings` |  `start` | Specify an .spvar file containing variable values (only applies if '--dashboard' flag is also set)
| `--all` |  `status` | Bypass the `--install-dir` and print status of all running services




### Examples

Start Steampipe in the background (service mode):
```bash
steampipe service start
```

Start Steampipe on port 9194
```bash
steampipe service start --database-port 9194
```

Start the Steampipe service with a custom password:
```bash
steampipe service start --database-password MyCustomPassword
```


Start Steampipe on `localhost` only
```bash
steampipe service start --database-listen local
```

Start Steampipe with `dashboard`
```bash
steampipe service start --dashboard
```

Start Steampipe with `dashboard` running on `localhost` only
```bash
steampipe service start --dashboard --dashboard-listen local
```

Start Steampipe with `dashboard` running on port 9195
```bash
steampipe service start --dashboard --dashboard-port 9195
```

Stop the Steampipe service:
```bash
steampipe service stop
```

Forcefully kill all Steampipe services:
```bash
steampipe service stop --force
```

View Steampipe service status:
```bash
steampipe service status
```

View Steampipe service status and display the database password:
```bash
steampipe service status --show-password
```

View status of all running Steampipe services:
```bash
steampipe service status --all
```

Restart the Steampipe service:
```bash
steampipe service restart
```
