---
title: Managing Connections
sidebar_label: Connections
---

# Managing Connections

A Steampipe **connection** represents a set of tables for a single data source.  Each connection is represented as a distinct Postgres schema.  

A connection is associated with a single plugin type. The boundary/scope of the connection varies by plugin, but is typically aligned with the vendor's cli tool and/or api.  For example:

- An `azure` connection contains tables for a single Azure subscription
- A `google` connection contains tables for a single GCP project
- An `aws` connection contains tables for a single AWS account

Many plugins will create a default connection when they are installed.  This connection should be dynamic, and use the same scope and credentials that would be used for the equivalent CLI.  Usually, this entails evaluating environment variables (`AWS_PROFILE`, `AWS_REGION`, `AZURE_SUBSCRIPTION_ID`, etc) and configuration files -- The details vary by provider.

This means that by default, Steampipe "just works" per the CLI:
- `select * from aws_ec2_instance` in the `aws` connection will target the same account/region as `aws ec2 describe-instances`
- `select * from azure_compute_virtual_machine` in the `azure` connection works the same as `az vm list` 

Note that there is nothing special about the default connection, other than that it is created by default on plugin install - You can delete or rename this connection, or modify its configuration options (via the configuration file).

## Connection configuration files

### Structure
Connection configurations are defined using HCL in one or more Steampipe config files.  Steampipe will load ALL configuration files from `~/.steampipe/config` that have a `.spc` extension. A config file may contain multiple connections.

Upon installation, a plugin may install a default configuration file, typically named `{plugin name}.spc`.  This file usually contains a single connection, configured in such as way as to to dynamically match the configuration of the associated CLI.   In addition, it may contain commented out sample connections for common configurations. 

For example, the `aws` plugin will install the `~/.steampipe/config/aws.spc` configuration file.  This file contains a single `aws` connection definition that configures the plugin to use the same configuration as the `aws` cli.  


### Syntax
Steampipe config files use HCL Syntax, with connections defined in a `connection` block.  The `connection` name will be used as the Postgres schema name in the Steampipe database.  Each `connection` must contain a single `plugin` argument that specifies which plugin to use in this connection.  Additional arguments are plugin-specific, and are used to determine the scope, credentials, and other configuration items. 

The `plugin` argument should contain the path to the plugin relative to the plugin directory.  Note that for standard Steampipe plugins that are installed from the Steampipe Hub, the short name may be used, and will use `latest` if the tag is omitted, thus the following are equivalent:


```hcl
connection "aws" {
  plugin = "aws" 
}
```


```hcl
connection "aws" {
  plugin = "hub.steampipe.io/plugins/turbot/aws@latest" 
}
```


A plugin may define additional, plugin-specific arguments.  For example, the AWS plugin allows you to define one or more regions to query, and either an AWS profile or key pair to use for authentication:

```hcl
// default
connection "aws" {
  plugin      = "aws" 
}

// credentials via profile
connection "aws_profile2" {
  plugin      = "aws" 
  profile     = "profile2"
  regions     = ["us-east-1", "us-west-2"]
}

// credentials via key pair
connection "aws_another_account" {
  plugin      = "aws" 
  secret_key  = "gMCYsoGqjfThisISNotARealKeyVVhh"
  access_key  = "ASIA3ODZSWFYSN2PFHPJ"  
  regions     = ["us-east-1"]
}
```

Plugin-specific configuration details can be found in the plugin documentation on the [Steampipe Hub](https://hub.steampipe.io)



## Querying multiple connections
A plugin may contain multiple connections:
```hcl
// default
connection "aws" {
  plugin      = "aws" 
}

connection "aws_01" {
  plugin      = "aws" 
  profile     = "aws_01"
  regions     = ["us-east-1", "us-west-2"]
}

connection "aws_02" {
  plugin      = "aws" 
  profile     = "aws_02"
  regions     = ["us-east-1", "us-west-2"]
}

connection "aws_03" {
  plugin      = "aws" 
  profile     = "aws_03"
  regions     = ["us-east-1", "us-west-2"]
}

```

Each connection is implemented as a distinct [Postgres schema](https://www.postgresql.org/docs/current/ddl-schemas.html).  As such, you can use qualified table names to query a specific connection:

```sql
select * from aws_02.aws_account
```

Alternatively, can use an unqualified name and it will be resolved according to the [Search Path](#setting-the-search-path):
```sql
select * from aws_account
```


## Using Aggregators 

You can aggregate or search for data across multiple connections by using an **aggregator** connection.  Aggregators allow you to query data from multiple connections for a plugin as if they are a single connection.  For example, using aggregators, you can create tables that allow you to query multiple AWS accounts:

```hcl
connection "aws_all" {
  plugin      = "aws" 
  type        = "aggregator"
  connections = ["aws_01", "aws_02", "aws_03"]
}
```

Querying tables from this connection will return results from the `aws_01`, `aws_02`, and `aws_03` connections:
```sql
select * from aws_all.aws_account
```

Steampipe supports the `*` wildcard in the connection names.  For example, to aggregate all the AWS plugin connections whose names begin with `aws_`:

```hcl
connection "aws_all" {
  type        = "aggregator"
  plugin      = "aws"  
  connections = ["aws_*"]
}
```


Aggregators are powerful, but they are not infinitely scalable.  Like any other steampipe connection, they query APIs and are subject to API limits and throttling.  Consider as an example and aggregator that includes 3 AWS connections, where each connection queries 16 regions.  This means you essentially run the same list API calls 48 times!  When using aggregators, it is especially important to:
- Query only what you need!  `select * from aws_s3_bucket` must make a list API call in each connection, and then 11 API calls *for each bucket*, where `select name, versioning_enabled from aws_s3_bucket` would only require a single API call per bucket.
- Consider extending the [cache TTL](reference/config-files/connection).  The default is currently 300 seconds (5 minutes).  Obviously, anytime steampipe can pull from the cache, it is faster and less impactful to the APIs.  If you don't need the most up-to-date results, increase the cache TTL!

### Aggregating Dynamic Tables

Most tables in Steampipe plugins are statically defined -- the column names and types are defined at compile time.  As a result, all connections for a given table from a given plugin have the same structure and they can be aggregated by simply appending data.

Some plugins define tables dynamically, and their structure is only known at runtime.  The [`kubernetes` plugin](), for example, creates some tables dynamically by reading the CRD data.  Furthermore, the structure may not be identical across multiple connections.  When Steampipe aggregates this data:
- Steampipe performs a merge, where the table in the aggregator contains the union of all columns from all connections.
- If a connection does not contain a given column, it will be null in the aggregated result for all rows from that connection.
- If a column has the same name but different data type across connections, the column will be returned as JSONB.


## Setting the Search Path

Postgres allows you to set a [schema search path](https://www.postgresql.org/docs/current/ddl-schemas.html#DDL-SCHEMAS-PATH) to control the resolution order of unqualified names.  When using unqualified names, the first object in the search path that matches the object name will be used. 

For example, assume you have 3 connections that use the `aws` plugin, named `aws_01`, `aws_02`, and `aws_03`, and you run the query `select * from aws_account`.  In this query, the table name is unqualified, so the first schema (connection) in the search path that implements the `aws_account` table will be used.  By default, the search path puts the public schema first, followed by all connection schemas ordered alphabetically, thus the query will return results from `aws_01.aws_account`.  To instead return results from `aws_02`, you can simply change the search path and re-run the query.

Usually, you will not want to replace the entire search path, but rather *prefer* a given connection.  To simplify this case, set the `search_path_prefix`.  Setting the prefix will not *replace* the entire path, but will merely *prepend* the the prefix to the front of the search path. 

You can change the default search path in many places, and the active path will be determined from the most precise scope where it is set:

1. The session setting, as set by the most recent `.search_path` and/or .`search_path_prefix` meta-command.
1. The `--search-path` or `--search-path-prefix` command line arguments.
1. The `search_path` or `search_path_prefix` set in the `terminal` options for the workspace, in the `workspace.spc` file.
1. The `search_path` or `search_path_prefix` set in the `terminal` global option, typically set in `~/.steampipe/config/default.spc`
1. The `search_path` or `search_path_prefix` set in the `database` global option, typically set in `~/.steampipe/config/default.spc`
1. The compiled default (`public`, then alphabetical by connection name)

Note that setting the search path in the `terminal` options, from the command line arguments, or via meta-commands sets the path for the session when running `steampipe`; this setting *will not* be in effect when connecting to Steampipe from 3rd party tools.  Setting the `search_path` in the `database` options will set the `search_path` option in the database, however, and *will* be in effect when connecting from tools other than the `steampipe` cli.

