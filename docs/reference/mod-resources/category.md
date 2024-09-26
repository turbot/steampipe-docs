---
title: Category
sidebar_label: category
---

# category

> ***Powerpipe is now the recommended way to run dashboards and benchmarks!***
> Mods still work as normal in Steampipe for now, but they are deprecated and will be removed in a future release:
> - [Steampipe Unbundled →](https://steampipe.io/blog/steampipe-unbundled)
> - [Powerpipe for Steampipe users →](https://powerpipe.io/blog/migrating-from-steampipe)

The `category` block defines a category for a graph node or edge.  Categories are used to define display properties for the item, such as the color, icon, and folding options.


## Example Usage

```hcl
category "ec2_instance" {
  title = "EC2 Instance"
  href  = "/aws_insights.dashboard.ec2_instance_detail?input.instance_arn={{.properties.'ARN' | @uri}}"
  icon  = "memory"
  color = "orange"
}
```

A `category` may be defined as a top-level, named resource block, or as a block inside a `graph`, `flow`, or `hierarchy`.  If defined as a top-level resource, the category will be available to all graph nodes and edges, and you can set it on a node or edge using the `category` HCL property:
  
```hcl

dashboard "categories_ex1" {
  graph {
    node "iam_policy" {
      category = category.iam_policy

      sql = <<-EOQ
        select
          arn as id,
          name as title,
          jsonb_build_object(
            'ARN', arn,
            'AWS Managed', is_aws_managed::text,
            'Attached', is_attached::text,
            'Create Date', create_date,
            'Account ID', account_id
          ) as properties
        from
          aws_iam_policy
        where
          arn = 'arn:aws:iam::aws:policy/ReadOnlyAccess';
      EOQ

    }
  }
}

category "iam_policy" {
  title = "IAM Policy"
  color = "red"
  href  = "/aws_insights.dashboard.iam_policy_detail?input.policy_arn={{.properties.'ARN' | @uri}}"
  icon  = "policy"
}
```

If defined as a block inside a `graph`, `flow`, or `hierarchy`, the category will only be available to that `graph`, `flow`, or `hierarchy`.  In this case, you cannot set the category with `category` HCL property, but can set it dynamically for each row in the SQL result set using the `category` column:
  
```hcl
dashboard "categories_ex2" {
  graph {
    category "iam_policy" {
      title = "IAM Policy"
      color = "red"
      href  = "/aws_insights.dashboard.iam_policy_detail?input.policy_arn={{.properties.'ARN' | @uri}}"
      icon  = "policy"
    }

    node "iam_policy" {
      sql = <<-EOQ
        select
          arn as id,
          name as title,
          'iam_policy' as category,
          jsonb_build_object(
            'ARN', arn,
            'AWS Managed', is_aws_managed::text,
            'Attached', is_attached::text,
            'Create Date', create_date,
            'Account ID', account_id
          ) as properties
        from
          aws_iam_policy
        where
          arn = 'arn:aws:iam::aws:policy/ReadOnlyAccess';
      EOQ
    }
  }
}
```

The inline `category` block is useful when you want to define a category dynamically based on the SQL result set.  You can even use the `base` property in the inline category to inherit properties from a named category:
  
```hcl
dashboard "categories_ex3" {
  graph {
    category "iam_policy" {
      base = category.iam_policy
    }

    node "iam_policy" {
      sql = <<-EOQ
        select
          arn as id,
          name as title,
          'iam_policy' as category,
          jsonb_build_object(
            'ARN', arn,
            'AWS Managed', is_aws_managed::text,
            'Attached', is_attached::text,
            'Create Date', create_date,
            'Account ID', account_id
          ) as properties
        from
          aws_iam_policy
        where
          arn = 'arn:aws:iam::aws:policy/ReadOnlyAccess';
      EOQ
    }
  }
}

category "iam_policy" {
  title = "IAM Policy"
  color = "red"
  href  = "/aws_insights.dashboard.iam_policy_detail?input.policy_arn={{.properties.'ARN' | @uri}}"
  icon  = "policy"
}
```



## Argument Reference
| Argument | Type | Optional? | Description
|-|-|-|-
| `color`  | String | The matching color from the default theme for the data series index. | A [valid color value](reference/mod-resources/dashboard#color).  This may be a named color, RGB or RGBA string, or a control status color. |  The color to display for this category.           |
| `href`    | String | Optional | A url that the item should link to.  The `href` may use a [jq template](reference/mod-resources/dashboard#jq-templates) to dynamically generate the link.  |
| `icon` |  String	| Optional | An [icon](reference/mod-resources/dashboard#icon) to use for the elements with this category. 
| `title` |  String	| Optional | A plain text [title](/docs/reference/mod-resources/dashboard#title) to display for this category.
| `fold` |  Block	| Optional | A `fold` block for this category.



## Folding

The `graph` resource supports *folding*, allowing you to collapse multiple nodes that have the same category into a single node.  You can click to expand or collapse the folded nodes.  To be considered for folding, the nodes must have the same category and the same edges.

By default, folding is enabled with a threshold of `3`.  This means that if there are 3 or more nodes with the same category and edges, they will be folded into a single node.  You can change the fold options in the `fold` block in the category definition.  The `fold` block has the following properties:

| Argument | Type | Optional? | Description
|-|-|-|-
| `icon` |  String	| Optional | An [icon](reference/mod-resources/dashboard#icon) to use when this category is folded.  If not specified, the `category` icon will be used.
| `title` |  String	| Optional | A plain text [title](/docs/reference/mod-resources/dashboard#title) to display for this category. If not specified, the `category` title will be used.
| `threshold` |  Number	| Optional | The number of items that should be displayed before folding.  The default is `3`.



## More Examples


### Category with Material Symbol Icon

```hcl
category "ec2_instance" {
  title = "EC2 Instance"
  color = "orange"
  icon  = "memory"
}
```

### Category with Heroicons Icon
```hcl
category "ec2_instance" {
  title = "EC2 Instance"
  color = "orange"
  icon = "heroicons-outline:cpu-chip"
}
```

### Category with Text Icon
```hcl
category "ec2_instance" {
  title = "EC2 Instance"
  color = "orange"
  icon = "text:Instance"
}
```

### Category with `fold` properties

```hcl
category "aws_vpc_subnet" {
  title = "Subnet"
  icon = "lan"
  color = "#FF9900"

  fold {
    title = "Subnets..."
    icon  = "more-horiz"
    threshold = 2
  }
```