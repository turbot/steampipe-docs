---
title: Query
sidebar_label: Query
---

# Querying Steampipe Postgres FDW

Your Steampipe Postgres FDW adds foreign tables to your Postgres installation.  Typically, these table are prefixed with the plugin name.  There is extensive documentation for the plugin in the [Steampipe Hub](https://hub.steampipe.io/plugins), including sample queries for each table.   You can also query the information schema to list the foreign tables that have been added to your schema:

```sql
select
  foreign_table_name
from
  information_schema.foreign_tables
where
  foreign_table_schema = 'aws_01' 
```

You can use standard Postgres syntax to query the tables.  Note that you will have to qualify the tables name with the schema name unless you add the schema to the [search path](https://www.postgresql.org/docs/current/ddl-schemas.html#DDL-SCHEMAS-PATH):

```sql
select
  instance_id,
  instance_type
  instance_state,
  region,
  account_id
from
  aws_01.aws_ec2_instance
```

There are many [examples in the Steampipe documentation](/docs/sql/steampipe-sql), as sell as the [Steampipe Hub](https://hub.steampipe.io/plugins). These examples all use unqualified table names, so if you want to run them as-is, you'll need to add your schema to your search path:

```sql
SELECT set_config('search_path', current_setting('search_path') || ',aws_01', false);
show search_path;
```

You can now unqualified queries:
```sql
select
  instance_id,
  instance_type
  instance_state,
  region,
  account_id
from
  aws_ec2_instance
```

The search path will persist for the duration of your database session.  You can revert to the default search_path if you want:
```sql
set search_path  to default
```

Refer to the [documentation](https://www.postgresql.org/docs/current/ddl-schemas.html) for more details.
