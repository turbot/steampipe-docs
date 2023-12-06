---
title: Query
sidebar_label: Query
---


# Querying Steampipe SQLite Extensions

Your Steampipe extension adds virtual tables to your SQLite installation.  Typically, these table are prefixed with the plugin name.   You can run `pragma module_list;` to get a list of virtual tables, or refer to the documentation for the plugin in the [Steampipe Hub](https://hub.steampipe.io/plugins).  The Hub also contains sample queries for each table.

You can use standard SQLite syntax to query the tables:
```sql
SELECT
  name,
  is_private,
  owner_login
FROM
  github_my_repository
```


It is often useful to use `limit` to discover what columns are available for a table without fetching too much data:
```sql
SELECT * FROM aws_iam_access_key LIMIT 1
```

The normal [Steampipe guidance](/docs/sql/tips) applies:
- Select only the columns that you need.
- Limit results with a `where` clause on key columns when possible.
- Be aware that some tables *require* a where or join clause.



## SQLite Data Types
Unlike Postgres, SQLite does not have [native data types](https://www.sqlite.org/datatype3.html) for date/time, boolean, json, or ip addresses, so these columns are represented as `TEXT` or `NUMBER`.  While the data types are not supported as native storage types, SQLite does provide functions to manipulate these types of data.

### Boolean
Boolean values are stored as integers: `0` (false) and `1` (true):

```sql
SELECT
  name,
  bucket_policy_is_public
FROM
  aws_s3_bucket
WHERE
  bucket_policy_is_public = 1;
```

As a result, implicit boolean comparisons work as you would expect: 

```sql
SELECT
  name,
  bucket_policy_is_public
FROM
  aws_s3_bucket
WHERE
  bucket_policy_is_public;
```

SQLite version 3.23.0 also recognize the keywords `TRUE` and `FALSE`.  They are essentially just aliases for `1` and `0`:
```sql
SELECT
  name,
  bucket_policy_is_public
FROM
  aws_s3_bucket
WHERE
  bucket_policy_is_public = TRUE;
```

### Date/Time
Steampipe SQLite extensions store date time fields as text in RFC-3339 format.  You can use [SQLite date and time functions](https://www.sqlite.org/lang_datefunc.html) to work with these columns.

```sql
select
  access_key_id,
  user_name,
  status,
  create_date,
  julianday('now') - julianday(create_date) as age_in_days
FROM
  aws_iam_access_key
WHERE
  age_in_days > 30;
```

### JSON
Steampipe SQLite extensions store JSON fields as jsonb-formatted text. You can use [SQLite JSON functions and operators](https://www.sqlite.org/json1.html) to work with this data.


You can extract data with `json_extract`:
```sql
SELECT
  name,
  json_extract(acl, '$.Owner') AS owner
FROM
  aws_s3_bucket;
```


But SQLite version 3.38.0 and later support the `->` and `->>` operators, which is usually simpler:  

```sql
SELECT
  name,
  acl -> 'Owner' ->> 'ID'  AS owner
FROM
  aws_s3_bucket;
```


You can use the [json_each table-valued function](https://www.sqlite.org/json1.html#jeach) to treat json arrays as rows and use them to join tables:

```sql
SELECT
  i.instance_id,
  vol.volume_id,
  vol.size
FROM
  aws_ebs_volume AS vol,
  json_each(vol.attachments) AS att
  JOIN aws_ec2_instance AS i ON i.instance_id = att.value ->> 'InstanceId'
ORDER BY
  i.instance_id;
```

### INET/CIDR
Currently, SQLite does not include any functions for IP address or CIDR data.  There are multiple 3rd party extensions you can install that provide functions for working with IP address data.