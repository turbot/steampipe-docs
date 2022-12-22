---
title: With
sidebar_label: with
---

# with

Some resources may also include `with` blocks. Similar to a `with` clause in a postgres CTE, the `with` block allows you to specify additional queries or sql statements to run **before** running "main" query specified in the `sql` or `query` argument for the resource.

`with` is not a top-level named resource in its own right - it is ONLY a block within other resources. 

You can only specify `with` blocks on **top-level named resources** in your mod. The results of the `with` query can be referenced only within the resource in which it is defined (including any sub-blocks).  

## Example Usage
```hcl
dashboard "with_ex_1" {

  input "lambda_function_arn" {
    query   = query.lambda_function_input
    width  = 6
  }

  with "vpc_info" {
    sql = <<-EOQ
      select
        vpc_id,
        subnet as subnet_id
      from
        aws_lambda_function,
        jsonb_array_elements_text(vpc_subnet_ids) as subnet
      where
        arn = $1
    EOQ

    args = [self.input.lambda_function_arn.value]
  }

  graph {

    node {
      base = node.aws_lambda_function_node
      args = {
        lambda_function_arn = self.input.lambda_function_arn.value
      }
    }

    node {
      base = node.aws_vpc
      args = {
        vpc_id = with.vpc_info.rows[*].vpc_id
      }
    }

    node {
      base = node.aws_vpc_subnet
      args = {
        subnet_id = with.vpc_info.rows[*].subnet_id
      }
    }

    edge {
      base = edge.aws_lambda_function_to_vpc_subnet
      args = {
        lambda_function_arn = self.input.lambda_function_arn.value
      }
    }

    edge {
      base = edge.aws_vpc_subnet_to_vpc
      args = {
        subnet_id = with.vpc_info.rows[*].subnet_id
      }
    }

  }
}

query "lambda_function_input"{
  sql = <<-EOQ
    select
      arn as value,
      arn as label
    from 
      aws_lambda_function
  EOQ
}

node "aws_lambda_function_node"{
  category = category.aws_lambda_function

  sql = <<-EOQ
    select
      arn as id,
      title,
      json_build_object(
        'name', name,
        'runtime', runtime
      ) as properties
    from
      aws_lambda_function
    where
      arn = $1
  EOQ

  param "lambda_function_arn" {}
}

node "aws_vpc" {
  category = category.aws_vpc

  sql = <<-EOQ
    select
      distinct on (vpc_id)
      vpc_id as id,
      title,
      json_build_object(
        'name', tags ->> 'Name',
        'id', vpc_id,
        'cidr', cidr_block
      ) as properties
    from
      aws_vpc
    where
      vpc_id = any($1)
  EOQ

  param "vpc_id" {}
}

node "aws_vpc_subnet" {
  category = category.aws_vpc_subnet

  sql = <<-EOQ
    select
      subnet_id as id,
      title,
      json_build_object(
        'id', subnet_id,
        'cidr', cidr_block
      ) as properties
    from
      aws_vpc_subnet
    where
      subnet_id = any($1)
  EOQ

  param "subnet_id" {}
}

edge "aws_lambda_function_to_vpc_subnet" {
  sql = <<-EOQ
    select
      arn as from_id,
      subnet_id as to_id
    from
      aws_lambda_function,
      jsonb_array_elements_text(vpc_subnet_ids) as subnet_id
    where
      arn = $1
  EOQ

  param "lambda_function_arn" {}

}

edge "aws_vpc_subnet_to_vpc" {
  sql = <<-EOQ
    select
      subnet_id as from_id,
      vpc_id as to_id
    from
      aws_vpc_subnet
    where
      subnet_id = any($1)
  EOQ

  param "subnet_id" {}
}

category "aws_lambda_function" {
  title = "Lambda Function"
  icon = "function"
  color = "#FF9900"
}

category "aws_vpc" {
  title = "VPC"
  icon = "cloud"
  color = "#FF9900"
}

category "aws_vpc_subnet" {
  title = "Subnet"
  icon = "lan"
  color = "#FF9900"
}
```

## Referencing `with` results
`with` blocks are scoped to the resource in which they are defined.  You can reference the results of a `with` block in any sub-block of that resource.  Y

`with` blocks can only be added to **top-level named resources**.  You cannot add `with` blocks to **top-level anonymous resources** or **sub-resources**.  

You can reference the with block results as `with.<name>.rows`. 

For example, given the following `with` block:
```h
with "stuff1" {
  sql = "select a, b from table"
}
```

Rows is essentially a list, and you can index it to get a single row. Each row, in turn, contains all the columns, so you can get a single column of a single row:
```h
with.stuff1.rows[0].a
```

If you splat the row, then you can get an array of a single column from all rows.  This would be passed to sql as an array:
```h
with.stuff1.rows[*].a
```
- if `a` is a scalar value, then `with.stuff1.rows[*].a` is an array of scalar values
- if `a` is an array (or jsonb array, then `with.stuff1.rows[*].a` is an array of arrays.  

<!--
  - You can subsequently flatten it with the hcl `flatten` function if desired: `flatten(with.stuff1.rows[*].a)`
  - duplicates values are not automatically removed from the array, but you can remove them with the hcl `distinct` function if desired:: `distinct(flatten(with.stuff1.rows[*].a))`
-->





    


## Argument Reference
| Argument | Type | Optional? | Description
|-|-|-|-
| `args` | Map | Optional| A map of arguments to pass to the query. 
| `query` | Query Reference | Optional | A reference to a [query](reference/mod-resources/query) resource that defines the query to run.  You must either specify the `query` argument or the `sql` argument, but not both.
| `sql` |  String	| Optional |  An SQL string to provide data for the `edge`.  You must either specify the `query` argument or the `sql` argument, but not both.





## More Examples
