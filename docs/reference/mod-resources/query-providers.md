---
title: Query Providers
sidebar_label: Query Providers
---

# Query Providers

There are many steampipe mod elements that have execute a query.  These elements are sometimes referred to as **query provider resources**, or **query providers**, and include `query`, `control`, and most dashboard visualization elements (`card`,`chart`, `node`, `edge`, `graphs` etc). These resources essentially implement the same interface:
  - They have a `sql` argument for specifying a sql string to execute
  - They have a `query` argument for referencing a `query` to execute
  - They require the user to set either `sql` or `query`, but both may not be specified.
  - They have an optional `param` argument to specify parameters that the `sql` accepts
  - They have an optional `args` argument to specify what arguments to pass to the `query` or `sql`


## Query v/s SQL

When using a query provider, you MUST specify either the `sql` or `query` argument, but not both.  

The difference between these arguments is somewhat subtle.  

The `sql` argument is a simple *string* that defines a sql statement to execute. This allows you to inline the statement in the resource definition. 

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

Query providers allow you to specify parameters that the `sql` accepts and to specify what arguments to pass to the `query` or `sql`.  The difference between `param` and `args` is a common source of confusion.

A `param` block is used to define a parameter *that the `sql` accepts* - It is a definition of what you can pass. The `args` block is used to specify what *values to pass to the `query` or `sql`* - these are the actual values to use when running the query.

`param` blocks are only used when the `sql` argument is specified and the sql statement includes parameters (`$1`, `$2`): 

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


The `args` argument is used to pass values to a query provider at run time.  If the `query` resource has parameters defined, then the `args` argument is used to pass values to the query:

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

Note that most query provider resources can be defined as top-level resources and reused with `base`, and you can pass arguments to them in the same manner:

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

While `param` blocks are recommended when sql statements define parameters, they are not required -- you wont be able to pass arguments by name, but you can still pass them positionally using the array format of the `args` argument:

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


## `with` blocks

Query provider resources may also include [with blocks](/docs/reference/mod-resources/with). Similar to a `with` clause in a postgres CTE, the `with` block allows you to specify additional queries or sql statements to run **before* running "main" query specified in the `sql` or `query` argument.


## running from the steampipe cli

You can run a query for any top-level named query provider resources from `steampipe query`.  If the query provides defaults for all the parameters, you can run it without arguments in the same way you would run a query or control that takes no parameters, and it will run with the default values:

```sql
query.bucket_count
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
