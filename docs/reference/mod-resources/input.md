---
title: Input
sidebar_label: input
---

# input

> ***Powerpipe is now the recommended way to run dashboards and benchmarks!***
> Mods still work as normal in Steampipe for now, but they are deprecated and will be removed in a future release:
> - [Steampipe Unbundled →](https://steampipe.io/blog/steampipe-unbundled)
> - [Powerpipe for Steampipe users →](https://powerpipe.io/blog/migrating-from-steampipe)

Allow user input in a dashboard using common form components such as `text`, `select`, `multiselect`, `combo` and `multicombo`. Data can either be static or derived from a SQL query.

Dashboard components can depend on the value of an input within the dashboard by referring to `self` e.g. `self.input.<input_name>.value`.  This allows you to pass the value of an input as an argument to a query (or any other dashboard element) to create dynamic dashboards!

Input blocks can be declared as named resources at the top level of a mod, or be declared as named blocks inside a `dashboard` or `container`, or be re-used inside a `dashboard` or `container` by using an `input` with `base = <mod>.input.<input_resource_name>`.

## Example Usage

<img src="/images/reference_examples/input_select_open_ex_1.png" width="200pt" />

<br />

```hcl
input "vpc_id" {
  title = "VPC"
  type  = "select"
  width = 2

  sql  = <<-EOQ
    select
      title as label,
      vpc_id as value
    from
      aws_vpc;
  EOQ
}
```




## Argument Reference

| Argument      | Type    | Optional? | Description                                                                                                                                                                             |
|---------------|---------|-----------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `args` | Map | Optional| A map of arguments to pass to the query. 
| `base`        | String	 | Optional  | A reference to a named `input` resource that this `input` should source its definition from. `title`, `sql`, `type`, `options` and `width` can be overridden after sourcing via `base`. |
| `option`     | Block	 | Optional  | [option](#option) block to add static values to the input                            |
| `placeholder` | String	 | Optional  | Placeholder text to display.  If a `placeholder` is set for a `combo`, `multicombo`, `select` or `multiselect`, then dependent resources will not run until a selection is made.  If no `placeholder` is set, the first item in the list will be selected by default.
| `param` | Block | Optional| A [param](reference/mod-resources/query#param) block that defines the parameters that can be passed in to the query.  `param` blocks may only be specified for inputs that specify the `sql` argument. 
| `query` | Query Reference | Optional | A reference to a [query](reference/mod-resources/query) resource that defines the query to run.  An `input` may either specify the `query` argument or the `sql` argument, but not both.
| `sql` |  String	| Optional |  An SQL string to provide data for the `input`.  An `input` may either specify the `query` argument or the `sql` argument, but not both.
| `title`       | String	 | Optional  | A plain text [title](/docs/reference/mod-resources/dashboard#title) to display for this input.                                                                                          |
| `type`        | String	 | Optional  | The [type of the input](#input-types). Can be `text`, `combo`, `multicombo`, `select` or `multiselect`.                                                                                                              |
| `width`       | Number	 | Optional  | The [width](/docs/reference/mod-resources/dashboard#width) as a number of grid units that this item should consume from its parent.                                                     |


## Input Types
| Type | Description
|------|-----------------
| [text](#text-input)                               | Enter a single line of text
| [select](#select-with-dynamic-options)            | Select a single item from a dropdown list
| [multiselect](#multi-select-with-dynamic-options) | Select one or more items from a dropdown list
| [combo](#combo-box)                               | Select a single item from a dropdown list, or enter a new value
| [multicombo](#multi-select-combo-box)             | Select one or more items from a dropdown list, or enter new values


## Common Input Properties

### option

Add static options to an input.  Applies to `select` and `multiselect`.  The block name is the value.  If a `label` is not specified, the value will be used as the label. 

| Property | Type     | Default |  Description |
| -------- | ---------| ------- |  ----------- |
| `label`  | String   |  If not specified, the value will be used as the label      |     the display label for this option         |



## Data Structure
 
The data structure for an `input` will depend on the `type`.

## select / multiselect / combo / multicombo

| label               | value                 | tags                             |
| ------------------- | --------------------- |----------------------------------|
| default             | vpc-05657e5bef9676266 | null                             |
| acme @ 10.84.0.0/16 | vpc-03656e5eef967f366 | { "account_id": "123456789012" } |

`tags` is an optional JSONB object of key/value pairs. Any tag values will be displayed in the list of available options, along with the selected option(s). This will allow you to identify resources across multi-account queries for example.  When a user types to search in the input, the labels and tags will be searched.

## More Examples

### Single-select with tags

<img src="/images/reference_examples/input_ex_tags.png" width="400pt" />

<br />

```hcl
input "instance_arn" {
    title = "Select an instance:"
    width = 4

    sql = <<-EOQ
      select
        title as label,
        arn as value,
        json_build_object(
          'region', region,
          'instance_id', instance_id
        ) as tags
      from
        aws_ec2_instance
      order by
        title;
    EOQ
  }

```


### Single-select with fixed options

<img src="/images/reference_examples/input_ex_static_1.png" width="200pt" />


```hcl

input "regions" {
  title = "Select regions:"
  width = 2
  option "us-east-1" {}
  option "us-east-2" {}
}

```

### Single-select with fixed options, using labels

<img src="/images/reference_examples/input_ex_static_2.png" width="200pt" />


```hcl

input "vpc_id" {
  title = "Select VPC:"
  width = 2
  option  "vpc-05657e5bef9676266" {
    label = "default"
  }
  option  "vpc-03656e5eef967f366" {
    label = "acme @ 10.84.0.0/16"
  }
}

```

### Multi-select with dynamic options

<img src="/images/reference_examples/input_multiselect_open_ex_1.png" width="200pt" />

<br />

```hcl

input "policy_arns" {
  title = "Select policies:"
  type  = "multiselect"
  width = 2
  sql = <<-EOQ
    select
      name as label,
      arn as value
    from
      aws_iam_policy;
  EOQ
}

```


### Select with dynamic options

<img src="/images/reference_examples/input_select_open_ex_1.png" width="200pt" />

<br />

```hcl
input "vpc_id" {
  title = "VPC"
  type  = "select"
  width = 2

  sql  = <<-EOQ
    select
      title as label,
      vpc_id as value
    from
      aws_vpc;
  EOQ
}
```




### Text input

<img src="/images/reference_examples/input_text.png" width="200pt" />

<br />

```hcl
input "search_string" {
  title = "Search String:"
  width = 2
  type  = "text"
  placeholder = "enter a search string"
}

```



### Combo box

<img src="/images/reference_examples/input_combo.png" width="200pt" />

<br />

```hcl
input "cost_center" {
  title = "Select a Cost Center:"
  type  = "combo"
  width = 2

  sql   = <<-EOQ
    select distinct
      tags ->> 'costcenter' as label,
      tags ->> 'costcenter' as value
    from
      aws_tagging_resource
    where
      tags ->> 'costcenter' is not null;
  EOQ
}
```

### Multi-select combo box

<img src="/images/reference_examples/input_multicombo.png" width="200pt" />

<br />

```hcl
input "cost_centers" {
  title = "Select a Cost Center:"
  type  = "multicombo"
  width = 3

  sql   = <<-EOQ
    select distinct
      tags ->> 'costcenter' as label,
      tags ->> 'costcenter' as value
    from
      aws_tagging_resource
    where
      tags ->> 'costcenter' is not null;
  EOQ
}
```









<!--   To DO - not yet in as of alpha 10


### Select with static options
```hcl
input {
  type = "select"
  options = [
    {
      label = "default"
      value = "vpc-05657e5bef9676266"
    }
    {
      label = "acme @ 10.84.0.0/16"
      value = "vpc-03656e5eef967f366"
    }
  ]
}
```

-->


### Example dashboard using an input

<img src="/images/reference_examples/inputs_example_dashboard_1.png"  />

<br />


```hcl
query "aws_region_input" {
  sql = <<-EOQ
    select
      distinct region as label,
      region as value
    from
      aws_region
    order by
      region;
  EOQ
}

query "aws_s3_buckets_by_versioning_enabled" {
  sql = <<-EOQ
    with versioning as (
      select
        case when versioning_enabled then 'Enabled' else 'Disabled' end as versioning_status,
        region
      from
        aws_s3_bucket
    )
    select
      versioning_status,
      count(versioning_status) as "Total"
    from
      versioning
    where
      region = $1
    group by
      versioning_status
  EOQ
  
  param "region" {}
}


query "aws_s3_buckets_in_region" {
  sql = <<-EOQ
    select
      name,
      versioning_enabled
    from
      aws_s3_bucket
    where
      region = $1
  EOQ
  
  param "region" {}
}

dashboard "inputs_example_dashboard" {
  title = "Inputs Example Dashboard"

  input "region" {
    sql   = query.aws_region_input.sql
    width = 3
  }

  container {
    
    chart {
      title = "AWS Bucket Versioning Status"
      type  = "pie"
      width = 2
      query = query.aws_s3_buckets_by_versioning_enabled
      args  = {
        "region" = self.input.region.value
      }
    }

    table {
      width = 4
      query = query.aws_s3_buckets_in_region
      args = {
        "region" = self.input.region.value
      }
    }

  }
}
```
