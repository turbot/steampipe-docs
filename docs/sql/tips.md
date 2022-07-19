---
title: Tips and Tricks
sidebar_label: Tips and Tricks
---

# Tips and Tricks

## Select only the columns that you need.  
This is a common recommendation for any SQL database, but it is especially important for Steampipe, as it can avoid making API calls to gather data that you don't want anyway.  The difference in execution time varies by table and environment, but can be quite significant. For example, in a test account: `select *  from aws_iam_policy;` took 14 seconds to execute, but this call took less than a second:

```sql
select 
  name, 
  arn, 
  is_aws_managed 
from 
  aws_iam_policy;
```

The exception to this rule is the `count` aggregate function - Steampipe will optimize it, thus this call is very efficient (and also takes less than a second):
```sql
select 
  count(*)
from
  aws_iam_policy;
```

## Limit results with a `where =` clause on key columns when possible.
The Steampipe FDW can be more efficient if your query specifies the key columns exactly in a `where` clause.  

For example:
```sql
select 
  * 
from 
  aws_ec2_instance 
where 
  instance_id = 'i-0f16e4805caddfd44';
```

For non-key columns, data for all rows must be collected, and then filtered.  Currently, the only way to know definitively which columns are key columns is in the plugin source file.

## Some tables ***require*** a where or join clause
The Steampipe database doesn't store data, it makes API calls to get data dynamically.  There are times when listing ALL the elements represented by a table is impossible or prohibitively slow.  In such cases, a table may require you to specify a qualifier in a `where =` (or `join...on`) clause.  For example, the Github `ListUsers` API will enumerate ALL Github users.  It is not reasonable to page through hundreds of thousands of users to find what you are looking for.  Instead, Steampipe requires that you specify `where login =` to find the user directly, for example:

```sql
select
  *
from
  github_user
where
  login = 'torvalds';
```

Alternatively, you join on the key column (`login`) in a `where` or `join` clause:

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