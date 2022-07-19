---
title: Flow
sidebar_label: flow
---

# flow

A flow allows visualization of queries using types such as `sankey`.

Flow blocks can be declared as named resources at the top level of a mod, or can be declared as anonymous blocks inside a `dashboard` or `container`, or be re-used inside a `dashboard` or `container` by using a `flow` with `base = <mod>.flow.<flow_resource_name>`.



## Example Usage

<img src="/images/reference_examples/sankey_ex_1.png" width="100%" />

```hcl
flow {
  type  = "sankey"
  title = "AWS VPC Subnets by AZ"
  width = 6

  sql = <<-EOQ

    with vpc as
      (select 'vpc-9d7ae1e7' as vpc_id)

    select
      null as from_id,
      vpc_id as id,
      vpc_id as title,
      0 as depth,
      'aws_vpc' as category
    from
      aws_vpc
    where
      vpc_id in (select vpc_id from vpc)

    union all
    select
      distinct on (availability_zone)
      vpc_id as from_id,
      availability_zone as id,
      availability_zone as title,
      1 as depth,
      'aws_availability_zone' as category
    from
      aws_vpc_subnet
    where
      vpc_id in (select vpc_id from vpc)


    union all
    select
      availability_zone as from_id,
      subnet_id as id,
      subnet_id as title,
      2 as depth,
      'aws_vpc_subnet' as category
    from
      aws_vpc_subnet
    where
      vpc_id in (select vpc_id from vpc)

  EOQ
}
```


## Argument Reference
| Argument | Type | Optional? | Description
|-|-|-|-
| `args` | Map | Optional| A map of arguments to pass to the query. 
| `base` |  flow Reference		| Optional | A reference to a named `flow` resource that this `flow` should source its definition from. `title` and `width` can be overridden after sourcing via `base`.
| `category` | Block | Optional| [category](#category) blocks that specify display options for nodes with that category.
| `param` | Block | Optional| [param](reference/mod-resources/query#param) blocks that defines the parameters that can be passed in to the query.  `param` blocks may only be specified for hierarchies that specify the `sql` argument. 
| `query` | Query Reference | Optional | A reference to a [query](reference/mod-resources/query) resource that defines the query to run.  A `flow`  may either specify the `query` argument or the `sql` argument, but not both.
| `sql` |  String	| Optional |  An SQL string to provide data for the `flow`.  A `flow` may either specify the `query` argument or the `sql` argument, but not both.
| `title` |  String	| Optional | A plain text [title](/docs/reference/mod-resources/dashboard#title) to display for this flow.
| `type` |  String	| Optional | The type of the flow. Can be `sankey` or `table`.
| `width` |  Number	| Optional | The [width](/docs/reference/mod-resources/dashboard#width) as a number of grid units that this item should consume from its parent.




## Common Flow Properties

### category

| Property | Type   | Default                                                              | Values                                                                                                                                  | Description |
| -------- | ------ |----------------------------------------------------------------------| --------------------------------------------------------------------------------------------------------------------------------------- | ----------- |
| `color`  | string | The matching color from the default theme for the data series index. | A [valid color value](reference/mod-resources/dashboard#color).  This may be a named color, RGB or RGBA string, or a control status color. |  The color to display for this category.           |



## Data Format
Flow data must be provided in a format where each row represents a *node* (vertex), an *edge* (connecting 2 vertices), or both. 

Note that both column *names* and their *relative position* are important in flow queries; Steampipe looks for columns *by name* in the result set, however Postgres union queries will *append the rows based on the column's position*, not the name of the column.  ***All the `union` queries must return the same columns, in the same order.***

Significant columns  are:

| Name       | Description
|------------|---------------------------------------------------------------
| `id`       | A unique identifier for the node.  Nodes have an `id`, edges do not.
| `title`    | A title to display for the node.
| `category` | A display category name. Both nodes and edges may specify a `category` to dictate how the item is displayed.  By default, items of the same category are displayed with the same appearance (color), distinct from other categories.  You can specify display options with a [category](#category) block.
| `depth`    | An integer to set the position of the node. The layout of the nodes is inferred from the query, however you can force placement with the `depth` column if you need to override the default behavior.
| `from_id`  | The `id` of the source side of an edge.
| `to_id`    | The `id` of the destination side of an edge.




Generally speaking, there are 2 data formats commonly used for flows.  If the data is hierarchical, it is often simpler to specify results where each row species a node (with an `id`, and optionally `title`, `category`, and/or `depth`) and an edge, by specifying a `from_id`:  

| from_id | id               | title            | category         |
|---------|------------------|------------------|------------------|
| <null\> | 1                | foo              | root             |
| 1       | 2                | bar              | widget           |
| 1       | 3                | baz              | widget           |
| 2       | 4                | foobar           | fidget           |

For flows that do not conform to a single-parent hierarchical structure, its usually easier to specify nodes and edges as separate rows.  In this case, nodes will have an `id` and optionally `title`, `category`, and/or `depth`, but `to_id` and `from_id` will be null.  Edges will populate `to_id` and `from_id` and optionally `category`, and will have null `id`, `depth`, and `title`:


| from_id | to_id     | id               | title            | category         |
|---------|-----------|------------------|------------------|------------------|
| <null\> |  <null\>  | 1                | foo              | root             |
| <null\> |  <null\>  | 2                | bar              | widget           |
| <null\> |  <null\>  | 3                | baz              | widget           |
| <null\> |  <null\>  | 4                | foobar           | fidget           |
| 1       |  2        |  <null\>         | <null\>          | widget           |
| 1       |  3        |  <null\>         | <null\>          | widget           |
| 2       |  4        |  <null\>         | <null\>          | fidget           |
| 3       |  4        |  <null\>         | <null\>          | fidget           |



## More Examples


### Sankey with color by category

<img src="/images/reference_examples/sankey_ex_category.png" width="100%" />

```hcl
flow {
  type  = "sankey"
  title = "AWS VPC Subnets by AZ"
  width = 6

  category "aws_vpc" {
    color = "orange"
  }

  category "aws_availability_zone" {
    color = "tan"
  }

    category "aws_vpc_subnet" {
    color = "green"
  }

  sql = <<-EOQ

    with vpc as
      (select 'vpc-9d7ae1e7' as vpc_id)

    select
      null as from_id,
      vpc_id as id,
      vpc_id as title,
      0 as depth,
      'aws_vpc' as category
    from
      aws_vpc
    where
      vpc_id in (select vpc_id from vpc)

    union all
    select
      distinct on (availability_zone)
      vpc_id as from_id,
      availability_zone as id,
      availability_zone as title,
      1 as depth,
      'aws_availability_zone' as category
    from
      aws_vpc_subnet
    where
      vpc_id in (select vpc_id from vpc)


    union all
    select
      availability_zone as from_id,
      subnet_id as id,
      subnet_id as title,
      2 as depth,
      'aws_vpc_subnet' as category
    from
      aws_vpc_subnet
    where
      vpc_id in (select vpc_id from vpc)

  EOQ
}

```

### Sankey with node / edge data format, color by category, depth

<img src="/images/reference_examples/sankey_user_to_policies_ex.png" width="100%" />


```hcl

flow {
  type  = "sankey"
  title = "AWS IAM Managed Policies for User"
  width = 6

  category "direct" {
    color = "alert"
  }

  category "indirect" {
    color = "ok"
  }

  sql = <<-EOQ
    with user_list as
      (select 'arn:aws:iam::111111111111:user/jsmyth' as arn)

    -- User Nodes
    select
      arn as id,
      name as title,
      0 as depth,
      'user' as category,
      null as from_id,
      null as to_id
    from
      aws_iam_user
    where
      arn in (select arn from user_list)

    -- Group Nodes
    union select
      g ->> 'Arn' as id,
      g ->> 'GroupName' as title,
      1 as depth,
      'group' as category,
      null as from_id,
      null as to_id
    from
      aws_iam_user,
      jsonb_array_elements(groups) as g
    where
      arn in (select arn from user_list)


    -- Policy Nodes (attached to groups)
    union select
      p.arn as id,
      p.name as title,
      2 as depth,
      'policy' as category,
      null as from_id,
      null as to_id
    from
      aws_iam_user as u,
      jsonb_array_elements(groups) as g,
      aws_iam_group as grp,
      jsonb_array_elements_text(grp.attached_policy_arns) as pol_arn,
      aws_iam_policy as p
    where
      g ->> 'Arn' = grp.arn
      and pol_arn = p.arn
      and u.arn in (select arn from user_list)


    -- Policy Nodes (attached to user)
    union select
      p.arn as id,
      p.name as title,
      2 as depth,
      'policy' as category,
      null as from_id,
      null as to_id
    from
      aws_iam_user as u,
      jsonb_array_elements_text(attached_policy_arns) as pol_arn,
      aws_iam_policy as p
    where
      pol_arn = p.arn
      and u.arn in (select arn from user_list)

    -- User-> Group Edge
    union select
      null as id,
      null as title,
      null as depth,
      'indirect' as category,
      arn as from_id,
      g ->> 'Arn' as to_id
    from
      aws_iam_user,
      jsonb_array_elements(groups) as g
    where
      arn in (select arn from user_list)

    -- User -> Policy Edge
    union select
      null as id,
      null as title,
      null as depth,
      'direct' as category,
      arn as from_id,
      pol_arn
    from
      aws_iam_user,
      jsonb_array_elements_text(attached_policy_arns) as pol_arn
    where
      arn in (select arn from user_list)


  -- Group -> Policy Edge
    union select
      null as id,
      null as title,
      null as depth,
      'indirect' as category,
      grp.arn as from_id,
      pol_arn
    from
      aws_iam_user as u,
      jsonb_array_elements(groups) as g,
      aws_iam_group as grp,
      jsonb_array_elements_text(grp.attached_policy_arns) as pol_arn,
      aws_iam_policy as p
    where
      g ->> 'Arn' = grp.arn
      and pol_arn = p.arn
      and u.arn in (select arn from user_list)

  EOQ
}
```