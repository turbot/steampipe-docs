---
title: Querying JSON 
sidebar_label: Querying JSON
---


# Querying JSON 
Steampipe plugins call API functions, and quite often these functions return structured object data, most commonly in json or yaml.  As a result, json columns are very common in steampipe.  Fortunately, PostgreSQL has native support for json.  Steampipe stores json columns using the [jsonb](https://www.postgresql.org/docs/14/datatype-json.html) datatype, and you can use the standard [Postgres JSON functions and operators](https://www.postgresql.org/docs/14/functions-json.html) with Steampipe.

To return the **full json** column, you can simply select it like any other column:
```sql
select
  title,
  policy
from
  aws_s3_bucket;
```

You can make the json more **readable** with `jsonb_pretty`:
```sql
select
  title,
  jsonb_pretty(policy)
from
  aws_s3_bucket;
```

You can **extract objects** from json columns using jsonb `->` operator:
```sql
select
  name,
  acl -> 'Owner' as owner
from
  aws_s3_bucket;
```

Alternatively you can use [array-style subscripting](https://www.postgresql.org/docs/14/datatype-json.html#JSONB-SUBSCRIPTING) with Steampipe 0.14 and later:
```sql
select
  name,
  acl['Owner'] as owner
from
  aws_s3_bucket;
```


You can **extract text** from json columns using jsonb `->>` operator:
```sql
select
  title,
  tags ->> 'Name' as name,
  tags ->> 'application' as application,
  tags ->> 'owner' as owner
from
  aws_ebs_snapshot;
```

Array subscripting ALWAYS returns jsonb though, so if you want text (similar to `->>`) you will have to extract it: 

```sql
select
  title,
  tags['Name']  #>> '{}' as name
from
  aws_ebs_snapshot;
```


You can get **text from nested objects** with arrow operators:
```sql
select
  name,
  acl -> 'Owner' ->> 'ID' as acl_owner_id,
  acl -> 'Owner' ->> 'DisplayName' as acl_owner
from
  aws_s3_bucket;
```

or using array subscripting:

```sql
select
  name,
  acl['Owner']['ID'] #>> '{}'  as acl_owner_id,
  acl['Owner']['DisplayName'] #>> '{}' as acl_owner
from
  aws_s3_bucket;
```

or even combining array subscripting with arrow operators:
```sql
select
  name,
  acl['Owner'] ->> 'ID' as acl_owner_id,
  acl['Owner'] ->> 'DisplayName' as acl_owner
from
  aws_s3_bucket;
```


You can **use jsonpath** to extract or filter data if you prefer:
```sql
select
  name,
  jsonb_path_query(acl, '$.Owner.ID') as acl_owner_id,
  jsonb_path_query(acl, '$.Owner.DisplayName') as acl_owner
from
  aws_s3_bucket;
```

You can **filter, sort, and group** your data using the arrow operators as well:
```sql
select
  tags ->> 'application' as application,
  count(*) as count
from
  aws_ebs_snapshot
where
  tags ->> 'application' is not null
group by
  application
order by
  application asc;
```

You can **count** the number of items in a json array:
```sql
select
  vpc_endpoint_id,
  jsonb_array_length(subnet_ids) as subnet_id_count
from
  aws_vpc_endpoint;
```

You can **enumerate json arrays** and extract data from each element:
```sql
select
  snapshot_id,
  volume_id,
  jsonb_array_elements(create_volume_permissions) as perm
from
  aws.aws_ebs_snapshot;
```


And even **extract items within nested json** in the arrays:

```sql
select
  snapshot_id,
  volume_id,
  jsonb_array_elements(create_volume_permissions) ->> 'UserId' as account_id
from
  aws.aws_ebs_snapshot;
```

