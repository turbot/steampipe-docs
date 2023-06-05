---
title: Connect to Steampipe Cloud from DuckDB
sidebar_label: DuckDB
---
## Connect to Steampipe Cloud from DuckDB

[DuckDB](https://duckdb.org/) is a free open-source, analytical SQL database system.

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

To get started, install [DuckDB](https://duckdb.org/docs/installation/index). DuckDB provides the capability to execute queries directly on a running PostgreSQL database by utilizing the `postgres` extension that can be installed by running this in the DuckDB CLI.

```
INSTALL postgres;
```

Paste this to Load the postgres extension

```
LOAD postgres;
```

Once the Postgres extension is installed and loaded, tables can be queried using the `postgres_scan` function. The first parameter to the function is the `postgres connection string` followed by `schema` and `table name`. Here we will execute a query with this command to list the top news using the [hackernews plugin](https://hub.steampipe.io/plugins/turbot/hackernews).

```
SELECT * FROM postgres_scan('postgresql://rahulsrivastav14:76**_****_**9c@rahulsrivastav14-rahulsworkspace.usea1.db.steampipe.io:9193/dea4px', 'hackernews', 'hackernews_top');
```

<div style={{"marginTop":"1em", "marginBottom":"1em", "width":"90%"}}>
<img src="/images/docs/cloud/duckdb-data-preview.png" />
</div>

That's it! Now you can use DuckDB to query Steampipe's [plugins](https://hub.steampipe.io/plugins) and [mods](https://hub.steampipe.io/mods).