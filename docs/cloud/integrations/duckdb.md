---
title: Connect to Steampipe Cloud from DuckDB
sidebar_label: DuckDB
---
## Connect to Steampipe Cloud from DuckDB

[DuckDB](https://duckdb.org/) is a free open-source, high-performance analytical SQL database system designed to handle large data sets efficiently.

Steampipe provides a single interface to all your cloud, code, logs and more. Because it's built on Postgres, Steampipe provides an endpoint that any Postgres-compatible client -- including DuckDB -- can connect to.

The [Connect](/docs/cloud/integrations/overview) tab for your workspace provides the details you need to connect DuckDB to Steampipe Cloud.

<div style={{"marginTop":"1em", "marginBottom":"1em", "width":"90%"}}>
<img src="/images/docs/cloud/steampipe-cloud-connect-details.jpg" />
</div>

Once Steampipe Cloud is successfully connected, you can explore the tables provided by the Steampipe plugins, run queries and build reports.

##  Connect to Steampipe CLI from DuckDB

You can also connect DuckDB to [Steampipe CLI](https://steampipe.io/downloads). To do that, run `steampipe service start --show-password` and use the displayed connection details.

```
Steampipe service is running:

Database:

  Host(s):            localhost, 127.0.0.1, 192.168.29.204
  Port:               9193
  Database:           steampipe
  User:               steampipe
  Password:           99**_****_**8c
  Connection string:  postgres://steampipe:99**_****_**8c@localhost:9193/steampipe
```

## Getting started

To get started, first install [DuckDB](https://duckdb.org/docs/installation/index) and [postgreSQL](https://www.postgresql.org/download/). Now install [duckdb_fdw](https://github.com/alitrack/duckdb_fdw) which is a foreign data wrapper that is used to connect to external databases. Create the duckdb_fdw extension using this command.

```
CREATE EXTENSION duckdb_fdw;
```

Run this command to create a server definition that connects to your DuckDB instance.

```
CREATE SERVER duckdb_steampipe
FOREIGN DATA WRAPPER duckdb_fdw
OPTIONS (database 'dea4px');
```

Run this command command to create a user mapping for the current PostgreSQL user

```
CREATE USER MAPPING FOR current_user
SERVER duckdb_steampipe;
```

with DuckDB now installed and running, paste this query to retrive the AWS S3 Buckets with versioning disabled.

```sql
select
  name,
  region,
  account_id,
  versioning_enabled
from
  aws_s3_bucket
where
  not versioning_enabled;
```

That's it! Now you use DuckDB to query Steampipe's [plugins](https://hub.steampipe.io/plugins) and [mods](https://hub.steampipe.io/mods).