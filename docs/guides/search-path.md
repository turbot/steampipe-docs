---
title: Using search_path to target connections and aggregators
sidebar_label: Using search_path
---


# Using search_path to target connections and aggregators

You are probably here for one of the following reasons:
- You can't figure out why Steampipe isn't using your [aggregator](https://steampipe.io/docs/managing/connections#querying-multiple-connections)
- You want to run `steampipe query`, `check`, or `dashboard` against a specific connection
- You want to change your default connection
- You've seen references to the search path elsewhere, but you're not sure why it's important
- You asked what you thought was a simple question on the Steampipe Slack, and instead of an answer they sent you this link (ugh...homework...)

This guide will attempt to answer these questions in 5 minutes or less.

## Schemas in Postgres

Steampipe leverages PostgreSQL foreign data wrappers to provide a SQL interface to external services and systems. The Steampipe database is an embedded PostgreSQL database.

A PostgreSQL database contains one or more [schemas](https://www.postgresql.org/docs/current/ddl-schemas.html).  A schema is a namespaced collection of named objects, like tables, functions, and views.  Steampipe creates a Postgres schema for each Steampipe connection.  In fact, if you query the Postgres information schema, you can get a list of the schemas in the database:

```sql
select 
  schema_name 
from 
 information_schema.schemata 
order by 
  schema_name;
```

Note that the schema names match your Steampipe connection names:
```sql
.inspect
```

The schemas, in turn, contain the foreign tables that you write queries against.  Again, you can see this in the information schema:

```sql
select 
  foreign_table_schema,
  foreign_table_name
from 
  information_schema.foreign_tables
where
  foreign_table_schema = 'aws'
```

Or more simply, using the steampipe `.inspect` command:
```sql
.inspect aws
```

In Steampipe, a [plugin](https://steampipe.io/docs/managing/plugins) defines and implements a set of related foreign tables.  All connections for a given plugin will contain the same set of tables.  

Within a schema, table names must be unique, however the same table name can be used in different schemas.  You can reference tables using a **qualified name** to disambiguate.   A qualified name consists of the schema name and the object name, separated by a period.  For example, to query the `aws_account` table in the `aws_prod` schema (which corresponds to the `aws_prod` connection) you can refer to it as `aws_prod.aws_account`: 

```sql
select 
  * 
from 
  aws_prod.aws_account
```


## Unqualified Success

Postgres also allows you to use **unqualified names**:

```sql
select 
  * 
from 
  aws_account
```

Note that the `aws_account` table is specified, but the schema is not.  If you have the same table name in multiple schemas, how does Postgres determine which table to use?  As you probably guessed, this is where the [schema search path](https://www.postgresql.org/docs/current/ddl-schemas.html#DDL-SCHEMAS-PATH) comes in.  The search path allows you to specify a list of schemas to be searched for the object.  The first schema in the list that contains an object that matches the name will be used.  

For example, assume that that search path is set to `gcp_prod, azure_prod, aws_prod, aws_test`, and you run `select * from aws_account`.  

1. Postgres will look in the `gcp_prod` schema for a table named `aws_account`, but it does not exist so it continues to the next schema in the list
2. Postgres will look in the `azure_prod` schema for a table named `aws_account`, but it does not exist so it continues to the next schema in the list
3. Postgres will look in the `aws_prod` schema for a table named `aws_account`. It finds the `aws_account` table, so it runs the query against the `aws_prod.aws_account` table.  


Queries in Steampipe [Mods](https://steampipe.io/docs/mods/overview) are written using **unqualified names**.   This allows you to run the exact same queries, dashboards, and benchmarks against any connection, just by changing the search path!  


## Setting the Search Path

By default, Steampipe sets the schema search path as follows:
1. The `public` schema first.  This schema is writable, and allows you to create your own objects (views, tables, functions, etc).
2. Connection schemas, in **alphabetical order** by default.
3. The `internal` schema last.   This schema contains Steampipe built-in functions and other internal Steampipe objects.  This schema is not displayed or managed by the Steampipe search path commands and options, but you'll see it in native SQL commands such as `show search_path`.

Since the connection schemas are added to the search_path alphabetically by default, the simplest way to set the default is to rename the connections. For example, let's assume that I have 3 AWS accounts and an [aggregator](https://steampipe.io/docs/managing/connections#querying-multiple-connections), and I want the aggregator to be the first in the search path.  I could name them as follows:
- `aws_prod` - Production AWS account
- `aws_qa`   - QA AWS account
- `aws_dev`  - Development AWS account
- `aws`  - an aggregator of all 3 of the above AWS connections

Steampipe will add the aggregator before the other aws connections because `aws` is first alphabetically:

```
> .search_path
+-------------------------------------+
| search_path                         |
+-------------------------------------+
| public,aws,aws_dev,aws_prod,aws_qa  |
+-------------------------------------+
```

If you prefer, you can explicitly set the `search_path` in the [database options ](https://steampipe.io/docs/reference/config-files/database) in your `~/.steampipe/config/default.spc` file.  Note that this is somewhat brittle because every time you install or uninstall a plugin, or add or remove a connection, you will need to update the file with the new  `search_path`.


## Search Path Prefix

Setting the `search_path` will replace the current search path.  Usually, however, you will not want to replace the entire search path, but rather *prefer* a given connection.  To simplify this case, set the `search_path_prefix`.  Setting the prefix will *move* the prefix to the front of the search path.


You can change the search path in your interactive terminal session with the [search_path](/docs/reference/dot-commands/search_path) or [search_path_prefix](/docs/reference/dot-commands/search_path_prefix) meta-commands.  This will change the search path only for the current session.

You can also pass a search path or prefix to the `steampipe query`, `steampipe dashboard`, or `steampipe check` commands to change the search path for that command.  For instance, to run the CIS Benchmark against the `aws_prod` connection, you can run.

```bash
steampipe check benchmark.cis_v140 --search_path_prefix aws_prod
```

## Tips & Tricks

- Manage your default search path with a good connection-naming strategy. For most users, this means aggregator first.  With AWS, for example, use the plugin name as the name of the aggregator (e.g. `aws`), and as a prefix to the other connections (e.g. `aws_prod`, `aws_dev`, etc).  With this approach the aggregator always comes first, even when adding and removing connections.
- Use the search path **prefix** command or argument to modify the search path when you want to prefer a connection.  
- When writing mods, use **unqualified** table names:
  - Qualified names would require you to know the connection names, which you don't know (they are defined by the user).
  - Users of your mod can vary the search path to target different connections
- If you create custom views or other objects, make sure you keep the `public` schema in your path.
- Since the `public` schema is first (by default), you can create your own tables and views to use instead of the steampipe tables.  If, for example, there is a table that you want to 'permanently' cache (or only manually refresh), you can create a materialized view with the same name: `create materialized view aws_iam_credential_report as select * from aws_iam_credential_report`. 


## More Information
- [Setting the Search Path](https://steampipe.io/docs/managing/connections#setting-the-search-path)
- [.search_path_prefix meta-command](https://steampipe.io/docs/reference/dot-commands/search_path_prefix)
- [.search_path meta-command](https://steampipe.io/docs/reference/dot-commands/search_path)
- [PostgreSQL Schema Search Path documentation](https://www.postgresql.org/docs/current/ddl-schemas.html#DDL-SCHEMAS-PATH)
- [database options](https://steampipe.io/docs/reference/config-files/database)
- [terminal options](https://steampipe.io/docs/reference/config-files/terminal)
- [cli reference - steampipe query](https://steampipe.io/docs/reference/cli/query)
- [cli reference - steampipe check](https://steampipe.io/docs/reference/cli/check)
- [cli reference - steampipe dashboard](https://steampipe.io/docs/reference/cli/dashboard)
