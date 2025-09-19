---
title:  FAQ
sidebar_label: FAQ
---

# Steampipe FAQ

## Topics

|                         Topic                                   |
|-----------------------------------------------------------------|
| [Basics and Functionality](#basics-and-functionality)           |
| [Performance and Scalability](#performance-and-scalability)     |
| [Plugins and Customization](#plugins-and-customization)         |
| [Deployment](#deployment)                                       |
| [Support and Lifecycle](#support-and-lifecycle)                 |
| [Troubleshooting and Debugging](#troubleshooting-and-debugging) |
| [Supported Linux Distributions](#supported-linux-distributions) |


------

## Basics and Functionality

### What kinds of data sources can Steampipe query?

Steampipe's extensible [plugin](/docs/managing/plugins) model allows it so support a wide range of source data, including:
- Cloud providers like [AWS](https://hub.steampipe.io/plugins/turbot/aws), [Azure](https://hub.steampipe.io/plugins/turbot/azure), [GCP](https://hub.steampipe.io/plugins/turbot/gcp), [Cloudflare](https://hub.steampipe.io/plugins/turbot/cloudflare), [Alibaba Cloud](https://hub.steampipe.io/plugins/turbot/alicloud), [IBM Cloud](https://hub.steampipe.io/plugins/turbot/ibm), and [Oracle Cloud](https://hub.steampipe.io/plugins/turbot/oci).
- Cloud-based services like[GitHub](https://hub.steampipe.io/plugins/turbot/github), [Zoom](https://hub.steampipe.io/plugins/turbot/zoom), [Okta](https://hub.steampipe.io/plugins/turbot/okta), [Slack](https://hub.steampipe.io/plugins/turbot/slack), [Salesforce](https://hub.steampipe.io/plugins/turbot/salesforce), and [ServiceNow](https://hub.steampipe.io/plugins/turbot/servicenow).
- Structured files like [CSV](https://hub.steampipe.io/plugins/turbot/csv), [YML](https://hub.steampipe.io/plugins/turbot/config) and [Terraform](https://hub.steampipe.io/plugins/turbot/terraform).
- Ad hoc investigation of [network services](https://hub.steampipe.io/plugins/turbot/net) like DNS & HTTP.  You can even run [arbitrary commands](https://hub.steampipe.io/plugins/turbot/exec) on local or remote systems and query the output.
 
Find published plugins in the [Steampipe Hub](https://hub.steampipe.io/)!

### Does Steampipe store query results locally?

No. Plugins make API calls, results flow into Postgres as ephemeral tables that are only cached for 5 minutes (by default). Steampipe optimizes for live data, and stores nothing by default.


### Can I use `psql`, `pgadmin`, or another client with Steampipe?

Yes. Steampipe exposes a [Postgres endpoint](/docs/query/third-party) that any Postgres client can connect to.   When you start the Steampipe [service](/docs/managing/service), Steampipe will print the connection string to the console.  You can also run `steampipe service status` to see the connection string.


### Can I export query results as CSV, JSON, etc?

Yes. You can run [steampipe query](/docs/reference/cli/query) with the `--output` argument to capture results in CSV or JSON format:
```bash
steampipe query --output json "select * from aws_account"
```

### Does Steampipe work with WSL (Windows Subsystem for Linux)?

Yes, with WSL 2.0.


### Does Steampipe support SQL write operations?

No. Steampipe is optimized for read-only query. However, it works closely with [Flowpipe](https://flowpipe.io) which can run Steampipe queries and act on the results.

### How do I know what tables and columns are available to query?

In the Steampipe CLI you can use [.inspect](/docs/reference/dot-commands/inspect) to list tables by plugin name, e.g. `.inspect aws` to produce a selectable list of tables. When you select one, e.g. `.inspect aws_s3_bucket` you'll see the schema for the table. You can see the same information on the [Steampipe Hub](https://hub.steampipe.io/plugins/turbot/aws/tables/aws_s3_bucket#inspect).

### Can I query more than one AWS account / Azure subscription / GCP project?

Yes. You can create an [aggregator](/docs/managing/connections#using-aggregators). This works for multiple connections of the same type, including AWS/Azure/GCP as well as all other plugins. 

It's common practice to use a script to generate the `.spc` files for an organization. See, for example, [https://github.com/happy240/steampipe-conn-generator-for-aws-organization](https://github.com/happy240/steampipe-conn-generator-for-aws-organization).

Turbot Pipes provides [integrations](https://turbot.com/pipes/docs/integrations) to simplify the setup and keep configurations up to date by automatically maintaining connections for [AWS organizations](https://turbot.com/pipes/docs/integrations/aws), [Azure tenants](https://turbot.com/pipes/docs/integrations/azure), [GCP organizations](https://turbot.com/pipes/docs/integrations/gcp) and [GitHub organizations](https://turbot.com/pipes/docs/integrations/github)

## Performance and Scalability

### How well does Steampipe perform when querying multiple connections?

The large variance in customer environments and configurations make it impossible to provide specific estimates, but many users have scaled Steampipe to hundreds of connections.  Multiple connections are queried in parallel, subject to plugin-specific [rate-limiting mechanisms](/docs/guides/limiter). Recent data is served from [cache](https://steampipe-dwhhps9u9-turbot.vercel.app/docs/guides/caching).  Connection-level qualifiers, like AWS account_id, can reduce the number of connections queried.

Writing good queries makes a significant difference in performance:
  - Select only the columns that you need, to avoid making API calls to hydrate data that you don't require.
  - Limit results with a `where` clause on [key columns](https://steampipe-dwhhps9u9-turbot.vercel.app/docs/guides/key-columns) when possible to allow Steampipe to do server-side row-level filtering.


### How does Steampipe handle rate-limiting?
Generally, Plugins are responsible for handling rate limiting because the details are service specific. Plugins should typically recognize when they are being rate limited and backoff and retry either using their native Go SDK,  the basic rate-limiting provided by the [plugin SDK](https://github.com/turbot/steampipe-plugin-sdk), or adding [limiters](/docs/guides/limiter) compiled in the plugin . You can also define your own custom [limiters](/docs/guides/limiter) in [configuration files](/docs/reference/config-files/overview).

### How can I control the amount of memory used by Steampipe and plugins?

To set a set soft memory limit for the Steampipe process, use the `STEAMPIPE_MEMORY_MAX_MB` environment variable. For example, to set a 2GB limit: `export STEAMPIPE_MEMORY_MAX_MB=2048`.

Each plugin runs as its own process, and can have its own memory limit set in its configuration file using the memory_max_mb attribute. For example:

```hcl
plugin "aws" {
  memory_max_mb = 2048
}
```

Alternatively, you can set a default memory limit for all plugin processes using the `STEAMPIPE_PLUGIN_MEMORY_MAX_MB` environment variable. For example, to set a 2GB limit: 
```bash
export STEAMPIPE_PLUGIN_MEMORY_MAX_MB=2048
```



## Plugins and Customization

### Can plugin X have a table for Y?

If the plugin lacks a table you need, file a feature request (GitHub issue) for a new table in the applicable plugin repo, e.g. `github.com/turbot/steampipe-plugin-{pluginName}/issues`. Of course we welcome contributions! The following [guide](/docs/develop/writing-your-first-table) shows you how to write your first table.

### Does Steampipe have a plugin for X?

If you have an idea for a new plugin, file a [feature request](https://github.com/turbot/steampipe/issues/) (GitHub issue) with the label 'plugin suggestions'. We welcome code contributions as well. If you want to write a plugin, our [guide](/docs/develop/writing_plugins/overview) will help you get started.

### How can I dynamically create Steampipe connections?

All connections are specified in [~/.steampipe/config/*.spc](/docs/reference/config-files/overview) files. Steampipe watches those files and reacts to changes, so if you build those files dynamically you can create connections dynamically.

### Can I create and use regular Postgres tables?

Yes. Each Steampipe plugin defines its own foreign-table schema, but you can create native Postgres tables and views in the public schema.

### Can I use Steampipe plugins with my own database?

Yes. Most plugins support native [Postgres FDWs](/docs/steampipe_postgres/overview) and [SQLite Extensions](/docs/steampipe_sqlite/overview). Find the details for a plugin in its Steampipe Hub documentation, e.g. the AWS plugin [for Postgres](https://hub.steampipe.io/plugins/turbot/github#postgres-fdw) and for [SQLite](https://hub.steampipe.io/plugins/turbot/github#https://hub.steampipe.io/plugins/turbot/github#sqlite-extension).

## Deployment

### Can I run Steampipe in a CI/CD pipeline or cloud shell?

Yes, it's easy to install and use Steampipe in any [CI/CD pipeline or cloud shell](/docs/integrations/overview).


### Where is the Dockerfile or container example?

Steampipe can be run in a containerized setup. We run it ourselves that way as part of [Turbot Pipes](https://turbot.com/pipes). However, we don't publish or support a container definition because:

* The CLI is optimized for developer use on the command line.
* Everyone has specific goals and requirements for their containers.
* Container setup requires various mounts and access to configuration files.
* It's hard to support containers across many different environments.

We welcome users to create and share open-source container definitions for Steampipe.

## Troubleshooting and Debugging

### My query resulted in an error stating that is `missing 1 required qual`.  What does that mean?

The error indicates that you must add a `where =` (or `join...on`) clause for the specified column to your query. The Steampipe database doesn't store data, it makes API calls to get data dynamically. There are times when listing ALL the elements represented by a table is impossible or prohibitively slow. In such cases, a table may [require you to specify an equals qualifier](/docs/sql/tips#some-tables-require-a-where-or-join-clause) in a `where` or `join` clause. 


### How can I know what API calls a plugin makes?
Steampipe plugins are open source, and you can inspect the code to see what calls it is making.

Some plugins (like the AWS plugin) provide information about the APIs being called using [function tags](/docs/guides/limiter#function-tags) that can be inspected by running Steampipe in [diagnostic mode](/docs/guides/limiter#exploring--troubleshooting-with-diagnostic-mode).



### Can I disable the Steampipe cache?

Yes. [Caching](/docs/guides/caching) significantly improves query performance and reduces API calls to external systems.  It is enabled by default, but you can disable it either for the server or for a given client session.

To disable caching at the server level, you can set the cache option to false in `~/.steampipe/config/default.spc`:

```hcl
options "database" {
  cache = false
}
```

Alternatively, set the [STEAMPIPE_CACHE](/docs/reference/env-vars/steampipe_cache) environment variable to `false` before starting Steampipe.

Within an interactive query session, you can disable caching for the client session with the [`.cache off` meta-command](/docs/reference/dot-commands/cache).



### A plugin isn't doing what I expect, how can I debug?

Steampipe writes plugin logs to `~/steampipe/logs/plugin-YYYY-MM-DD.log`.  By default, these logs are written at `warn` level.
You can change the log level with the [STEAMPIPE_LOG_LEVEL](/docs/reference/env-vars/steampipe_log) environment variable:

```bash
export STEAMPIPE_LOG_LEVEL=TRACE
```

If Steampipe is running, the plugins must be restarted for it to take effect: `steampipe service stop --force  && steampipe service start`.

## Support and Lifecycle

### What is the support lifecycle for Steampipe CLI and plugins?

Both the Steampipe CLI and plugins follow a 1-year support lifecycle policy. Each major version is supported for 1 year from its release date. During this support period:

For Steampipe CLI:
- Security updates and critical bug fixes are provided
- Compatibility with supported plugin versions is maintained
- Documentation and community support are available

For Steampipe Plugins:
- Bug fixes and security patches are provided
- API compatibility updates are maintained
- Documentation and community support are available

After the support period ends:
- The version will continue to function but will no longer receive updates
- Users are encouraged to upgrade to a supported version
- Compatibility between unsupported CLI versions and new plugin versions is not guaranteed
- Unsupported plugin versions may not work with API changes in cloud services

### Plugin Registry Support Lifecycle

The Steampipe Plugin Registry is committed to ensuring accessibility and stability for its users by maintaining versions of plugins for at least one year and preserving at least one version of each plugin. This practice ensures that users can access older versions of plugins if needed, providing a safety net for compatibility issues or preferences.

### Registry Support Status

The legacy Steampipe Plugin Registry (registry.steampipe.io) has been deprecated and replaced with GitHub Container Registry (ghcr.io). All users must use the new registry location for plugin installations and updates. For more information about configuring plugins, see the [Managing Plugins](/docs/managing/plugins) documentation.

## Supported Linux Distributions

Steampipe requires glibc version 2.34 or higher. It will not function on systems with an older glibc version.

Steampipe is tested on the latest versions of Linux LTS distributions. While it may work on other distributions with the required glibc version, official support and testing are limited to the following:


| Distribution       | Version | glibc Version | Notes                                                   |
|--------------------|---------|---------------|---------------------------------------------------------|
| Ubuntu LTS         | 24.04   | 2.39          |                                                         |
| Ubuntu             | 22.04   | 2.35          | To cover Windows WSL2, which may be behind              |
| CentOS (Stream)    | 9       | 2.34          |                                                         |
| RHEL               | 9       | 2.34          |                                                         |
| Amazon Linux       | 2023    | 2.34          |                                                         |
