---
title: Implementing Tables
sidebar_label: Implementing Tables
---

# Implementing Tables

By convention, each table should be implemented in a separate file named `table_{table name}.go`.  Each table will have a single table definition function that returns a pointer to a `plugin.Table` (this is the function specified in the `TableMap` of the [plugin definition](/docs/develop/writing_plugins/the-basics#plugin-definition)).  The function name is typically the table name in camel case (per golang standards) prefixed by `table`.

The table definition specifies the name and description of the table, a list of column definitions, and the functions to call in order to list the data for all the rows, or to get data for a single row.

When a connection is created, Steampipe uses the table and column definitions to create the Postgres foreign tables, however the tables don't store the data — the data is populated (hydrated) when a query is run.

The basic flow is:

1. A user runs a Steampipe query against the database

1. Postgres parses the query and sends the parsed request to the Steampipe FDW.

1. The Steampipe Foreign Data Wrapper ([Steampipe FDW](https://github.com/turbot/steampipe-postgres-fdw)) determines what tables and columns are required.

1. The FDW calls the appropriate [Hydrate Functions](/docs/develop/writing_plugins/hydrate-functions) in the plugin, which fetch the appropriate data from the API, cloud provider, etc.
    - Each table defines two special hydrate functions, `List` and `Get`.  The `List` or `Get` will always be called before any other hydrate function in the table, as the other functions typically depend on the result of the Get or List call.
    - Whether `List` or `Get` is called depends upon whether the qualifiers (in `where` clauses and `join...on`) match the `KeyColumns`.  This allows Steampipe to fetch only the "row" data that it needs. Qualifiers (aka quals) enable  Steampipe to map a Postgres constraint (e.g. `where created_at > date('2023-01-01')`) to the API parameter (e.g. `since=1673992596000`) that the plugin's supporting SDK uses to fetch results matching the Postgres constraint. (See [Translating SQL Operators to API Calls](/docs/develop/writing_plugins/hydrate-functions#translating-sql-operators-to-api-calls).)
    - Multiple columns may (and usually do) get built from the same hydrate function, but Steampipe only calls the hydrate functions for the columns requested (specified in the `select`, `join`, or `where`).   This enabless Steampipe to call only those APIs for the "column" data requested in the query.

1. The [Transform Functions](/docs/develop/writing_plugins/transform-functions) are called for each column.  The transform functions extract and/or reformat data returned by the hydrate functions into the format to be returned in the column.

1. The plugin returns the transformed data to the Steampipe FDW

1. Steampipe FDW returns the results to the database
