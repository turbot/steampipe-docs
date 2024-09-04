---
title:  FAQ
sidebar_label: FAQ
---

# Steampipe FAQ

## Topics

[Basics and Functionality](#basics-and-functionality)

[Performance and Scalability](#performance-and-scalability)

[Security and Data Handling](#security-and-data-handling)

[Plugins and Customization](#plugins-and-customization)

[Troubleshooting and Debugging](#troubleshooting-and-debugging)

## Basics and Functionality

### How does Steampipe launch and run?

Steampipe itself is a single binary. When you launch it, either interactively or as a service, it launches its own instance of Postgres, loads the Steampipe foreign data wrapper extension into Postgres, and then prepares all configured plugins to make them ready for queries.

### Can I use psql, pgadmin, or another client with Steampipe?

Yes. Steampipe exposes a Postgres endpoint that any Postgres client can connect to. Find the connection string by starting Steampipe as a service: `steampipe service start`.

### Can I run Steampipe in a CI/CD pipeline or cloud shell?

Yes. Steampipe deploys as a single binary, it's easy to install and use in any CI/CD pipeline or cloud shell.

### What kinds of data sources can Steampipe query?

Plugins typically query cloud APIs for services like AWS/Azure/GCP/GitHub/etc. But plugins can also query data from structured files like CSV/YML/Terraform/etc. There's also the Net plugin, an HTTP client that can query data from arbitrary URLs, and the Exec plugin which runs arbitrary commands and captures their output. Plugins can be created for any kind of data source.

### Can I export query results?

Yes. You can run `steampipe query` with the `--output` argument to capture results in CSV or JSON format. 

### Does Steampipe work with WSL (Windows Subsystem for Linux)?

Yes, with WSL 2.0.

### Are there plans for Steampipe to support SQL write operations?

No. Steampipe is optimized for read-only query. However, it works closely with [Flowpipe](https://flowpipe.io) which can run Steampipe queries and act on the results.

### What are quals?

Some tables require quals, or qualifiers, in the WHERE or JOIN..ON clause of queries. For example, you can't just do this: `select * from github_issue`. Steampipe can't query all of GitHub, you have to scope (qualify) the query, for example: `select * from github_issue where repository_full_name = 'turbot/steampipe'`. 
Steampipe uses the qualifier in its call to the underlying API.

### How do I know what tables and columns are available to query?

In the Steampipe CLI you can use `.inspect` to list tables by plugin name, e.g. `.inspect aws` to produce a selectable list of tables. When you select one, e.g. `.inspect aws_s3_bucket` you'll see the schema for the table. You can see the same information on the [Steampipe Hub](https://hub.steampipe.io/plugins/turbot/aws/tables/aws_s3_bucket#inspect).

## Performance and Scalability

### How well does Steampipe perform when querying multiple connections?

Multiple connections are queried in parallel, subject to plugin-specific rate-limiting mechanisms. Recent data is served frm cache. Connection-level qualifiers, like AWS `account_id`, can reduce the number of connections queried.

### Can I use Steampipe to query and save all my AWS / Azure / GCP resources?

That's possible for many tables (excluding those that don't respond to `select *` because they  require qualifiers). But it's not a recommended use of Steampipe. Other tools are more suitable for building data lakes and warehouses. Steampipe is best for accessing live data in near-real-time.

### How does Steampipe handle rate-limiting?

Plugins can use basic rate-limiting provided by the [plugin SDK](https://github.com/turbot/steampipe-plugin-sdk). More advanced [limiters](https://steampipe.io/docs/guides/limiter) can be compiled into plugins, or defined in `.spc` files.

### How can I control the amount of memory used by Steampipe and plugins?

To set a memory limit for the Steampipe process, use the `STEAMPIPE_MEMORY_MAX_MB` environment variable. For example, to set a 2GB limit: `export STEAMPIPE_MEMORY_MAX_MB=2048`.

Each plugin can have its own memory limit set in its configuration file using the memory_max_mb attribute. For example:

```
plugin "aws" {
  memory_max_mb = 2048
}
```

Alternatively, you can set a default memory limit for all plugins using the `STEAMPIPE_PLUGIN_MEMORY_MAX_MB` environment variable. For example, to set a 2GB limit: `export STEAMPIPE_PLUGIN_MEMORY_MAX_MB=2048`.

## Security and Data Handling

### What are the security implications of using Steampipe?

Steampipe queries cloud APIs and services, which means it requires read-only access to those cloud environments. Plugins can use the same credentials used by other API clients (e.g. the AWS CLI), or use credentials that you specify in `~/.steampipe/config/*.spc`files, in either case observe best practices for guarding those secrets. Plugins communicate locally with the Steampipe instance of Postgres. Steampipe stores no query results by default, they are retained in cache for a default 5-minute TTL.

### Does Steampipe store query results locally?

No. Plugins make API calls, results flow into Postgres as ephemeral tables that are only cached for (by default) 5 minutes. Steampipe optimizes for live data, and stores nothing by default.

### Where is the Dockerfile or container example?

Steampipe can be run in a containerized setup. We run it ourselves that way as part of [Turbot Pipes](https://turbot.com/pipes). However, we don't publish or support a container definition because:

* The CLI is optimized for developer use on the command line.
* Everyone has specific goals and requirements for their containers.
* Container setup requires various mounts and access to configuration files.
* It's hard to support containers across many different environments.

We welcome users to create and share open-source container definitions for Steampipe.

## Plugins and Customization

### Can plugin X have a table for Y?

If the plugin lacks a table you need, please visit `github.com/turbot/steampipe-plugin-x/issues` and file a feature request for a new table.

### Can I query more than one AWS account / Azure subscription / GCP project?

Yes. You can create an [aggregator](https://steampipe.io/docs/managing/connections#using-aggregators). This works for multiple connections of the same type, including AWS/Azure/GCP as well as all other plugins.

### How can I dynamically create Steampipe connections?

All connections are specified in `~/.steampipe/config/*.spc` files. Steampipe watches those files and reacts to changes, so if you build those files dynamically you can create connections dynamically.

### Can I create and use regular Postgres tables?

Yes. Each Steampipe plugin defines its own foreign-table schema, but you can create native Postgres tables and views in the public schema.

### Can I use Steampipe plugins with my own database?

Yes. The AWS plugin, for example, is available as a [native Postgres FDW](https://hub.steampipe.io/plugins/turbot/github#postgres-fdw) and a [SQLite extension](https://hub.steampipe.io/plugins/turbot/github#https://hub.steampipe.io/plugins/turbot/github#sqlite-extension).

## Troubleshooting and Debugging

### How can I know what API calls a plugin makes?

Run Steampipe in [diagnostic mode](https://steampipe.io/docs/guides/limiter#exploring--troubleshooting-with-diagnostic-mode). 

### Can I disable the Steampipe cache?

Yes, in various ways. To disable caching at the server level, you can set the cache option to false in `~/.steampipe/config/default.spc`:

```
options "database" {
  cache = false
}
```

If you want to disable caching for a client session, you can do this in the CLI:

```
.cache off
```

Or run Steampipe like so:

```
export STEAMPIPE_CACHE=false steampipe query
```

### A plugin isn't doing what I expect, how can I debug?

Run Steampipe like so:

```
STEAMPIPE_DIAGNOSTIC_LEVEL=all steampipe query
```

Then check for errors in `~/steampipe/logs/plugin-YYYY-MM-DD.log`

It maybe be helpful to ensure no Steampipe processes are running. Try `steampipe service stop --force` first, and only if necessary, `pkill -f steampipe`.

