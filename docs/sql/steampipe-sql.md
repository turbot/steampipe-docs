---
title: It's Just SQL!
sidebar_label: It's Just SQL!
---

# It's Just SQL!

Steampipe leverages PostgreSQL Foreign Data Wrappers to provide a SQL interface to external services and systems.  Steampipe uses an embedded PostgreSQL database (currently, version 14.2.0), and you can use [standard Postgres syntax](https://www.postgresql.org/docs/14/sql.html) to query Steampipe.


## Basic SQL

Like most popular relational databases, Postgres complies with the ANSI SQL standard - If you know SQL, you already know how to query Steampipe!

You can **query all the columns** in a table:
```sql
select * from aws_ec2_instance;
```

This is inefficient though -- you should **only query the columns that you need**.  This will save Steampipe from making API calls to gather data that you don't want anyway:
```sql
select
  instance_id,
  instance_type,
  instance_state
from
  aws_ec2_instance;
```

You can **filter** rows where columns only have a specific value: 
```sql
select
  instance_id,
  instance_type,
  instance_state
from
  aws_ec2_instance
where
  instance_type = 't2.small';
```

or a **range** of values:
```sql
select
  instance_id,
  instance_type,
  instance_state
from
  aws_ec2_instance
where
  instance_type in ('t2.small', 't2.micro');
```


or match a **pattern**: 
```sql
select
  instance_id,
  instance_type,
  instance_state
from
  aws_ec2_instance
where
  instance_type like '%small';
```

You can **filter on multiple columns**, joined by `and` or `or`:
```sql
select
  instance_id,
  instance_type,
  instance_state
from
  aws_ec2_instance
where
  instance_type = 't2.small'
  and instance_state = 'stopped'; 
```

You can **sort** your results:
```sql
select
  name,
  runtime,
  memory_size
from
  aws_lambda_function
order by
  runtime;
```

You can **sort on multiple columns, ascending or descending**:
```sql
select
  name,
  runtime,
  memory_size
from
  aws_lambda_function
order by
  runtime asc,
  memory_size desc;
```

You can group and use standard aggregate functions. You can **count** results:
```sql
select
  runtime,
  count(*)
from
  aws_lambda_function
group by
  runtime
order by
  count desc;
```

or **sum** them:
```sql
select
  runtime,
  sum(memory_size)
from
  aws_lambda_function
group by
  runtime;
```

or find **min**, **max**, and **average**:
```sql
select
  runtime,
  min(memory_size),
  max(memory_size),
  avg(memory_size)
from
  aws_lambda_function
group by
  runtime;
```


Of course the real power of SQL is in combining data from multiple tables!

You can **join tables** together on a key field.  When doing so, you may need to alias the tables (with `as`) to disambiguate them:

```sql
select
  instance.instance_id,
  instance.subnet_id,
  subnet.availability_zone
from
  aws_ec2_instance as instance
  join aws_vpc_subnet as subnet on instance.subnet_id = subnet.subnet_id;
```


You can use outer joins (left, right, or full) when you want to **find non-matching** rows as well.  For example to see all your volumes and the number snapshots from them:
```sql
select
  v.volume_id,
  count(s.snapshot_id) as snapshot_count
from
  aws_ebs_volume as v
  left join aws_ebs_snapshot as s on v.volume_id = s.volume_id
group by
  v.volume_id;
```

or to find snapshots from volumes that no longer exist:
```sql
select
  s.snapshot_id,
  s.volume_id
from
  aws_ebs_volume as v
  right join aws_ebs_snapshot as s on v.volume_id = s.volume_id
where
  v.volume_id is null;
```


You can use union queries to **combine datasets**.  Note that `union all` is much more efficient if you don't need to eliminate duplicate rows.

```sql
select
  name,
  arn,
  account_id
from
  aws_iam_role
union all
select
  name,
  arn,
  account_id
from
  aws_iam_user
union all
select
  name,
  arn,
  account_id
from
  aws_iam_group;
```
