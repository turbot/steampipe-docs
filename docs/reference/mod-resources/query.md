---
title: query
sidebar_label: query
---

# query
Queries define common SQL statements that may be used alone, or referenced in other blocks like controls and charts.

Note that a Steampipe `query` is NOT a database resource. It does not create a view, stored procedure, etc.  `query` blocks are interpreted by and executed by Steampipe, and are only available from Steampipe, not from 3rd party tools.

## Example Usage

```hcl
query "plus_size_instances" {
  title = "EC2 Instances xlarge and bigger"
  sql = "select * from aws_ec2_instance where instance_type like '%xlarge'"
}
```

You can run a query by its fully qualified name in the Steampipe query shell:
```sql
> aws_ec2_reports.query.prohibited_instance_types 
```

or in a non-interactive `steampipe query` command:
```bash 
$ steampipe query "aws_ec2_reports.query.plus_size_instances"
```

## Argument Reference

| Argument |Type | Required? | Description
|-|-|-|-
| `sql` | String | Required | SQL statement to define the query.
| `description` | String |  Optional| A description of the query.
| `documentation` | String (Markdown)| Optional | A markdown string containing a long form description, used as documentation for the mod on hub.steampipe.io. 
| `param` | Block | Optional| A [param](#param) block that defines the parameters that can be passed in to the control's query.  `param` blocks may only be specified for controls that specify the `sql` argument. 
| `search_path` | String | Optional| A schema search path to use for this query.
| `search_path_prefix` | String | Optional| A schema to prefer for this query.
| `tags` | Map | Optional | A map of key:value metadata for the benchmark, used to categorize, search, and filter.  The structure is up to the mod author and varies by benchmark and provider. 
| `title` | String | Optional | A display title for the query.


#### param
One or more `param` blocks may optionally be used in a query or control to define parameters that the query accepts.  Note that the SQL statement only supports positional arguments (`$1`, `$2`, ...) and that the param blocks are assigned in order -- the first param block describes `$1`, the second describes `$2`, etc.

| Name | Type| Description
|-|-|-
| `description` | String | A description of the parameter.
| `default`     | Any | A value to use if no argument is passed for this parameter when the query is run.


```hcl
variable "max_access_key_age" {
  type = number
}

query "old_access_keys" {
  sql = <<-EOT
    select
      access_key_id,
      user_name,
      create_date,
      age(create_date) as age
    from
      aws_iam_access_key
    where
      create_date < NOW() - ($1 ::numeric || ' days')::interval;
  EOT

  param "max_days" {
    default     = var.max_access_key_age
    description = "The maximum allowed key age, in days."
  } 
}
```

You can run a parameterized query for any named query from `steampipe query`.  If the query provides defaults for all the parameters, you can run it without arguments in the same way you would run a query that takes no parameters, and it will run with the default values:

```sql
query.old_access_keys
```

If the query does not provide a default, or you wish to run the query with a different value, you can pass an argument to the query.

You can pass them by name:
```sql
query.old_access_keys(max_days => 365)
```

Or by position:
```sql
query.old_access_keys(365)
```

If the parameter takes an array, you can pass an array literal:
```sql
query.bucket_count_for_regions(["us-east-2", "us-east-1"])
```


---

# Query-based Resources

There are many steampipe mod elements that execute a query, including `control` and most dashboard visualization elements (`card`,`chart`, `node`, `edge`, `graphs` etc). These resources essentially implement the same interface:
  - They have a `sql` argument for specifying a SQL string to execute
  - They have a `query` argument for referencing a `query` to execute
  - They require the user to set either `sql` or `query`, but both may not be specified.
  - They have an optional `param` argument to specify parameters that the `sql` accepts
  - They have an optional `args` argument to specify what arguments to pass to the `query` or `sql`


## Query v/s SQL

When using a query-based resource, you **must** specify either the `sql` or `query` argument, but not both.

The difference between these arguments is somewhat subtle.

The `sql` argument is a simple *string* that defines a SQL statement to execute. This allows you to inline the statement in the resource definition.

```hcl
card {
  sql = <<-EOQ
    select
      count(*) as "Buckets"
    from
      aws_s3_bucket
  EOQ

  width = 2
}
```

The `query` argument is a *reference to a named `query` resource* to run. This allows you to reuse a query from multiple other resources:


```hcl
card {
  width = 2
  query = query.bucket_count
}

query "bucket_count" {
  sql = <<-EOQ
    select
      count(*) as "Buckets"
    from
      aws_s3_bucket
  EOQ

}
```


## Params v/s Args

Query-based resources allow you to specify parameters that the `sql` accepts and to specify what arguments to pass to the `query` or `sql`.  The difference between `param` and `args` is a common source of confusion.

A `param` block is used to define a parameter *that the `sql` accepts* - It is a definition of what you can pass. The `args` block is used to specify what *values to pass to the `query` or `sql`* - these are the actual values to use when running the query.

`param` blocks are only used when the `sql` argument is specified and the SQL statement includes parameters (`$1`, `$2`):

```hcl
card "bucket_count_for_region" {
  sql = <<-EOQ
    select
      count(*) as "Buckets"
    from
      aws_s3_bucket
    where
      region = $1
  EOQ

  param "region" {
    default = "us-east-1"
  }

  width = 2
}
```

***You can only specify `param` blocks for resources that are defined as top-level named resources in your mod.***  It would not make sense to specify a `param` block for an anonymous resource that is defined in dashboard, since you cannot reference it anyway.


The `args` argument is used to pass values to a query at run time.  If the `query` resource has parameters defined, then the `args` argument is used to pass values to the query:

```hcl
dashboard "s3_dashboard" {
  card {
    width = 2
    query = query.bucket_count_for_region

    args = {
      region = "us-east-1"
    }
  }
}

query "bucket_count_for_region" {
  sql = <<-EOQ
    select
      count(*) as "Buckets"
    from
      aws_s3_bucket
    where
      region = $1
  EOQ

  param "region" {}
}
```

Note that most query-based resources can be defined as top-level resources and reused with `base`, and you can pass arguments to them in the same manner:

```hcl
dashboard "s3_buckets" {

  card {
    base = card.bucket_count_for_region
    args = {
      region = "us-east-1"
    }
  }

  card {
    base = card.bucket_count_for_region
    args = {
      region = "us-east-2"
    }
  }
}

card "bucket_count_for_region" {
  sql = <<-EOQ
    select
      count(*) as "Buckets"
    from
      aws_s3_bucket
    where
      region = $1
  EOQ

  param "region" {
    default = "us-east-1"
  }

  width = 2
}
```

While `param` blocks are ***recommended*** when SQL statements define parameters, they are not required -- you wont be able to pass arguments by name, but you can still pass them positionally using the array format of the `args` argument:

```hcl
dashboard "s3_dashboard" {
  card {
    width = 2
    query = query.bucket_count_for_region

    args  = ["us-east-1"]
  }
}

query "bucket_count_for_region" {
  sql = <<-EOQ
    select
      count(*) as "Buckets"
    from
      aws_s3_bucket
    where
      region = $1
  EOQ
}
```


## Running from the Steampipe CLI

You can run top-level, named query-based resources from `steampipe query` by name, in the same way that you run named queries.

```sql
card.bucket_count_for_region
```

If the query does not provide a default, or you wish to run the query with a different value, you can pass an argument to the query.

You can pass them by name:
```sql
 card.bucket_count_for_region(region => "us-east-2")
```

Or by position:
```sql
card.bucket_count_for_region("us-east-2")
```

If the parameter takes an array, you can pass an array literal:
```sql
card.bucket_count_for_regions(["us-east-2", "us-east-1"])
```
