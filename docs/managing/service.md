---
title: Service Mode
sidebar_label: Service Mode
---

# Service Mode

By default, when you run `steampipe query`, Steampipe will start the database if it is not already running.  In this case, the database only listens on the loopback address (127.0.0.1) - You cannot connect over the network.  Steampipe will shut it down at the end of the query command or session if there are no other active steampipe sessions.

Alternatively, you can run Steampipe in service mode.  Running `steampipe service start` will run Steampipe as a local service, exposing it as a database endpoint for connection from any Postgres-compatible database client.  

## Starting the database in service mode

When you run `steampipe service start`, Steampipe will start in service mode.  Steampipe prints connection information to the console that you can use in connection strings for your application or 3rd party tools:

```bash
$ steampipe service start

Steampipe service is running:

Database:

  Host(s):            localhost, 127.0.0.1, 192.168.10.174
  Port:               9193
  Database:           steampipe
  User:               steampipe
  Password:           4cbe-4bc2-9c18
  Connection string:  postgres://steampipe:4cbe-4bc2-9c18@localhost:9193/steampipe

Managing the Steampipe service:

  # Get status of the service
  steampipe service status

  # Restart the service
  steampipe service restart

  # Stop the service
  steampipe service stop

```


Once the service is started, you can [connect to the Steampipe](/docs/integrations/overview) from tools that integrate with Postgres.


## Stopping the service

To stop the Steampipe service, issue the `steampipe service stop` command.
