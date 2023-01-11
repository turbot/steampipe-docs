---
title: With
sidebar_label: with
---

# with

Some resources may also include `with` blocks. Similar to a `with` clause in a Postgres CTE, the `with` block allows you to specify additional queries or SQL statements to run **first**, and then pass the query results as arguments to `sql`, `query`, and `node` & `edge` blocks.

`with` is not a top-level named resource in its own right - it is ONLY a block within other resources.

You can only specify `with` blocks on `dashboard`, `graph`, `hierarchy`, and `flow`, and only when the they are defined as **top-level named resources** in your mod. The results of the `with` query can be referenced only within the resource in which it is defined (including any sub-blocks).

## Example Usage
```hcl
dashboard "with_ex2" {

  input "vpc" {
    sql = <<-EOQ
      select 
        title as label,
        vpc_id as value
      from aws_vpc
    EOQ
  }

  with "subnets" {
    sql = <<-EOQ
      select
        subnet_id
      from
        aws_vpc_subnet
      where
      vpc_id = $1
    EOQ

    args = [self.input.vpc.value]          
  }

  graph {

    node "subnet" {
      sql = <<-EOQ
        select
          subnet_id as id,
          title,
          json_build_object(
            'id', subnet_id,
            'region', region,
            'account id', account_id
          ) as properties
        from
          aws_vpc_subnet
        where
          subnet_id = any($1)
      EOQ

      args = [with.subnets.rows[*].subnet_id]
    }
        
    node "vpc"{
      sql = <<-EOQ
        select
          vpc_id as id,
          title,
          json_build_object(
            'id', vpc_id,
            'region', region,
            'account id', account_id
          ) as properties
        from
          aws_vpc
        where
          vpc_id = $1
      EOQ

      args = [self.input.vpc.value]
    }

    edge {
      sql = <<-EOQ
        select
          vpc_id as from_id,
          subnet_id as to_id
        from
          aws_vpc_subnet
        where
          vpc_id = $1
      EOQ

      args = [self.input.vpc.value]
    }

  }
}
```

## Argument Reference
| Argument | Type | Optional? | Description
|-|-|-|-
| `args` | Map | Optional| A map of arguments to pass to the query. 
| `query` | Query Reference | Optional | A reference to a [query](reference/mod-resources/query) resource that defines the query to run.  You must either specify the `query` argument or the `sql` argument, but not both.
| `sql` |  String	| Optional |  An SQL string to provide data for the `edge`.  You must either specify the `query` argument or the `sql` argument, but not both.



## Referencing `with` results
`with` blocks are scoped to the top-level resource in which they are defined.  You can reference the results of a `with` block in any sub-block of that resource. 

`with` blocks can only be added to **top-level named resources**.  You cannot add `with` blocks to **top-level anonymous resources** or **sub-resources**.  

You can reference the `with` query results as `with.<name>.rows`. 

For example, given the following `with` block:
```h
with "stuff1" {
  sql = "select a, b from table"
}
```

`with.<name>.rows` is a list, and you can index it to get a single row. Each row, in turn, contains all the columns, so you can get a single column of a single row:
```h
with.stuff1.rows[0].a
```

If you [splat](https://developer.hashicorp.com/terraform/language/expressions/splat) the row, then you can get an array of a single column from all rows.  This would be passed to sql as an array:
```h
with.stuff1.rows[*].a
```
- if `a` is a scalar value, then `with.stuff1.rows[*].a` is an array of scalar values
- if `a` is an array or jsonb array, then `with.stuff1.rows[*].a` is an array of arrays.  

At this time, you cannot pass an entire set (`with.<name>.rows`) to a query - you may pass either a single value (`with.<name>.rows[0].column`) or an array from a single column (`with.<name>.rows[*].column`).
<!--
  - You can subsequently flatten it with the hcl `flatten` function if desired: `flatten(with.stuff1.rows[*].a)`
  - duplicates values are not automatically removed from the array, but you can remove them with the hcl `distinct` function if desired:: `distinct(flatten(with.stuff1.rows[*].a))`
-->
