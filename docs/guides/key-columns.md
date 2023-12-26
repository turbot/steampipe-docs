---
title: Using Key Column Qualifiers
sidebar_label: Using Key Column Qualifiers
---

# Using Key Column Qualifiers


## What is a Key Column?
Like any relational database table, a Steampipe table is composed of one or more columns, each with a name and data type.  When running Steampipe in the context of a database, you can join, filter, sort, and aggregate on any column.

But unlike a conventional database table, Steampipe does not simply read data that is stored on disk.  Instead, it fetches data from external sources such as APIs and cloud services.  Steampipe is able to parallelize the requests to a large degree, but these requests take time and resources; every request consumes CPU, memory and network resources on both the client and the server.  Steampipe hides the details from you, but even a simple query may result in hundreds of API calls.

**Key Columns** enable you to optimize the data retrieval by using the capabilities of the underlying API to do row-level filtering of the results when Steampipe fetches it.  Essentially, if you filter on key columns in your `where` and `join` clauses, Steampipe can do **server-side filtering**.  This improves efficiency, reduces query time, and helps avoid API throttling.


## Discovering Key Columns

Key columns are table-specific; they work with the capabilities of the underlying API.  It's up to the plugin author to define and implement them in the plugin source code.  As a user of the plugin, how do you know which columns are key columns?  And how do you know which operators are supported?

The easiest way is to look in the table documentation on the [Steampipe Hub](https://hub.steampipe.io/plugins).  Every table will have a page in the Hub that includes a table of `schema` information.  The `Operators` column indicates which key column operators are supported for the column.  

<!--
For example: 
https://hub.steampipe.io/plugins/turbot/aws/tables/aws_vpc#inspect 
-->

<img src="/images/docs/steampipe_key_column_inspect.png" width="100%" />

<br />

Alternatively, if you are running the Steampipe CLI, you can get the key column information from the [`steampipe_plugin_column` table](#introspecting-key-columns).



### Required Key Columns
There are times when listing ALL the elements represented by a table is impossible or prohibitively slow. In such cases, a table may *require* you to specify a qualifier on a key column. 

For example, the Github `ListUsers` API will enumerate ALL Github users. It is not reasonable to page through hundreds of thousands of users to find what you are looking for. Instead, Steampipe requires that you specify `where login =` to find the user directly, for example:

```sql
select
  *
from
  github_user
where
  login = 'torvalds';
```


Alternatively, you join on the key column (login) in a where or join clause:

```sql
select
  u.login,
  o.login as organization,
  u.name,
  u.company,
  u.location
from
  github_user as u,
  github_my_organization as o,
  jsonb_array_elements_text(o.member_logins) as member_login
where
  u.login = member_login;
```

or

```sql
select
  u.login,
  o.login as organization,
  u.name,
  u.company,
  u.location
from
  github_my_organization as o,
  jsonb_array_elements_text(o.member_logins) as member_login
  join github_user as u on u.login = member_login;
```

The [Hub documentation](https://hub.steampipe.io/plugins) will include information about which key columns are required.  If you don't pass a required qualifier, Steampipe will let you know though:
```sql
> select * from github_user

Error: rpc error: code = Internal desc = 'List' call for table 'github_user' is missing 1 required qual: column:'login' operator: =
 (SQLSTATE HV000)

```

### Supported Operators

**Not all key columns support all operators** and the [Hub documentation](https://hub.steampipe.io/plugins) will tell you which are supported for a given column.  

When using the Steampipe CLI, [Postgres FDWs](/docs/steampipe_postgres/overview) or [SQLite Extensions](/docs/steampipe_sqlite/overview) you can use operators in your SQL query that are not supported by the key column, but the data will be filtered on the client side after all the data has been retrieved (like any other non-key column).  When using the [Export CLIs](/docs/steampipe_export/overview), however, you may only use the operators that are supported for the key column.

#### Key Column Operators

| Operator        | Description          | Abbreviation
|-----------------|----------------------|-------
| `=`             | Equals               | `=`
| `<>`, `!=`      | Not equal to         | `ne`
| `<`             | Less than            | `lt`
| `<=`            | Less than or equal to| `le`
| `>`             | Greater than         | `gt`
| `>=`            | Greater than or equal to | `ge`
| `~~`            | Like                 | `~~`
| `!~~`           | Not Like             | `!~~`
| `~~*`           | ILike                | `~~*`
| `!~~*`          | Not ILike            | `!~~*`
| `~`             | Matches regex        | `~`
| `!~`            | Does not match regex | `!~`
| `~*`            | Matches iregex       | `~*`
| `!~*`           | Does not match iregex| `!~*`
| `is null`       | is null              | `is null`
| `is not null`   | is not null          | `is not null`


## How it (basically) works

When you run a database query, the database engine parses the query and generates one or more query plans and then selects the plan that it believes is most optimal.  It then translates the query into function calls to fetch the data. After the data is fetched, the database engine may do additional filtering, formatting, and aggregation.

Key columns are used in both the planning and the execution phases.  

In the planning phase, Steampipe assigns a lower cost to plans that filter on key columns.  This serves to influence the planner to choose query plans that will leverage the key columns.

In the execution phase, the database will call the appropriate [List, Get, and Hydrate functions](/docs/develop/writing-plugins#hydrate-functions) in the plugin. The plugin will then make API calls using the key columns to fetch data only for the rows it needs. 

After the data is fetched, the database engine will do additional filtering for the qualifiers that are not key columns, as well as any sorting, formatting, or aggregation that is required.


## Introspecting Key Columns

If you are running the Steampipe CLI, you can get the key column information from the `steampipe_plugin_column` table:

```sql
select
  name,
  type,
  (get_config || list_config) -> 'operators' as operators,
  coalesce((get_config || list_config) ->> 'require', 'optional') as required
from 
  steampipe_plugin_column
where
  (get_config || list_config) -> 'operators' is not null
  and table_name = 'aws_vpc' ;
```

```sql
+-----------------+--------+------------+----------+
| name            | type   | operators  | required |
+-----------------+--------+------------+----------+
| vpc_id          | STRING | ["="]      | optional |
| cidr_block      | CIDR   | ["="]      | optional |
| state           | STRING | ["="]      | optional |
| is_default      | BOOL   | ["=","!="] | optional |
| dhcp_options_id | STRING | ["="]      | optional |
| owner_id        | STRING | ["="]      | optional |
+-----------------+--------+------------+----------+
```
