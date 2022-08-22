---
title: Query Filters
sidebar_label: Query Filters
---

# Steampipe Cloud Query Filters

Many Steampipe Cloud APIs support a filter syntax that allows you to search and filter lists using SQL-like grammar.  APIs that support this capability will have a `where` parameter that allows you to pass in a `where` clause for the filter:

```bash
export STEAMPIPE_CLOUD_TOKEN=spt_c6rnjt8afakemj4gha10_svpnmxqfaketokenad431k

curl -H "Authorization: Bearer ${STEAMPIPE_CLOUD_TOKEN}" \
https://cloud.steampipe.io/api/latest/user/johnsmyth/workspace/myworkspace/snapshot?where="dashboard_name='aws_insights.dashboard.aws_account_report'" 
```


The console also supports this query syntax:

<img src="/images/docs/cloud/api_filter_query_ex1.png" width="600pt"/>
<br />


Note that the query filter is parsed and processed by the Steampipe API, not passed to a backend database - there's no need to worry about SQL injection.  In fact, the schema of the query reflects the API output, and is entirely abstracted from the backend storage implementation.


Note that this filter capability is not subject to SQL injection attacks, as it is parsed and processed by the Steampipe API, not passed to a backend database.  In fact, the schema of the query reflects the API output, and is entirely abstracted from the backend storage implementation.


# Syntax

The `where` argument syntax supports a subset of the postgres `where` clause syntax. 

You can do simple equality operations:
```sql
dashboard_title = 'AWS Account Report'
```

Or inequalities (using `!=` or `<>`):
```sql
visibility != 'workspace'
```
```sql
visibility <> 'workspace'
```

You can use `like` (or `not like`) to do wildcard matching
```sql
dashboard_name like 'aws_insights%'
```
```sql
dashboard_name not like '%.benchmark.%'
```

Or `ilike` for case-insensitive wildcard matching
```sql
dashboard_name ilike 'aws_insights%'
```

You can use standard comparison operators (`>`, `>=`, `<`, `<=`) \:

```sql
dashboard_title > 'S'
```
```sql
created_at < '2022-08-10T18:32:09Z'
```


You can even use `now()` and `interval` to do relative date/time filters:
```sql
created_at > now() - interval '26 hr'
```
```sql
created_at > now() - interval '2 days'
```
```sql
created_at > now() - interval '1 week'
```
```sql
created_at > now() - interval '1 month'
```


<!--
Boolean
```sql 
!!! We dont have any Boolean fields currently
```
<-->

You can use `in()` to compare against multiple values:
```sql
dashboard_title in ('AWS Account Report', 'Shared Access')
```

Or `not in()` to do the inverse:
```sql
dashboard_title not in ('AWS Account Report', 'Shared Access')
```

You can check for null:
```sql
tags is null
```

Or  not null values:
```sql
inputs is not null
```

You can use json arrow operators for json fields, with the usual string, numeric, and boolean operators:
```sql
inputs ->> 'input.vpc_id' = 'vpc-11111111'
```
```sql
tags ->> 'Name' is null
```
```sql
inputs ->> 'volume_arn' like '%:123456789012:%'
```

You can even do complex compound statements with `and` and  `or`:
```sql
inputs ->> 'input.vpc_id' = 'vpc-11111111' and dashboard_title = 'AWS VPC Detail'
```
```sql
(dashboard_title = 'Shared Access' or dashboard_title = 'AWS Account Report') and created_at > '2022-08-10T18:32:09Z' 
```

# Queryable Columns
The queryable columns come from the API results, but not all columns can be used in a `where` filter - Each API has specific columns allowed for querying. 

For example, the `snapshot` API returns:

```json
{
  "items": [
    {
      "id": "snap_cbpvpdmv4vji3f000000_3v1gvdufu9eez5cwpjgy8u80k",
      "identity_id": "u_01234567890123456789",
      "workspace_id": "w_01234567890123456789",
      "state": "available",
      "visibility": "workspace",
      "dashboard_name": "aws_insights.dashboard.aws_account_report",
      "dashboard_title": "AWS Account Report",
      "schema_version": "20220614",
      "inputs": null,
      "tags": null,
      "created_at": "2022-08-10T18:45:10Z",
      "created_by_id": "u_01234567890123456789",
      "created_by": {
        "id": "u_01234567890123456789",
        "handle": "johnsmyth",
        "display_name": "johnsmyth",
        "avatar_url": "https://avatars.githubusercontent.com/u/6843140?v=4",
        "status": "accepted",
        "version_id": 11,
        "created_at": "2021-11-23T18:20:15Z",
        "updated_at": "2022-08-10T14:06:10Z"
      },
      "version_id": 1
    }
  ]
}
```

But the `snapshot` API only allows you to filter on:
  - `created_at`
  - `dashboard_name`
  - `dashboard_title`
  - `input`
  - `tags`
  - `visibility`


## Supported APIs & Columns

- `/api/latest/{identity type}/{identity handle}/workspace/{workspace handle}/snapshot`
  - `created_at`
  - `dashboard_name`
  - `dashboard_title`
  - `input`
  - `tags`
  - `visibility`
