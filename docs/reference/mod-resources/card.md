---
title: Card
sidebar_label: card
---

# card

A card is used to show a value to the user, or some change in value. A card can also present itself in different types e.g. show me a count of public S3 buckets and if the value is greater than 0 show as an `alert`, else as `ok`.

Cards can be declared as named resources at the top level of a mod, or be declared as anonymous blocks inside a `dashboard` or `container`, or be re-used inside a `dashboard` or `container` by using a `card` with `base = <mod>.card.<card_resource_name>`.



## Example Usage

<img src="/images/reference_examples/card_ex_1.png" width="200pt" />

<br />

```hcl
card {
  sql = <<-EOQ
    select 
      count(*) as "Buckets" 
    from 
  aws_s3_bucket
  EOQ
  
  icon  = "hashtag"
  width = 2
} 

```




## Argument Reference
| Argument | Type | Optional? | Description
|-|-|-|-
| `args` | Map | Optional| A map of arguments to pass to the query. 
| `base` |  Card Reference		| Optional | A reference to a named `card` resource that this `card` should source its definition from. `label`, `title`, `value`, `type` and `width` can be overridden after sourcing via `base`.
| `icon` |  String	| Optional | A custom icon to use on the card. All [heroicons](https://heroicons.com/) are available. Either with no scheme (`shield-check`) which defaults to outline, or specify the outline or solid schema with `heroicons-outline:shield-check` or `heroicons-solid:shield-check` respectively. Any icon provided via SQL is considered most specific, followed by an icon in the HCL, followed by any icon provided by the `type`. 
| `href`    | String |Optional | A url that the card should link to.  The `href` may use a [jq template](#jq-templates) to dynamically generate the link the card.  |
| `label` |  String	| Optional | Inferred from the first column name in simple data format. Else can be set explicitly in HCL, or returned by the query in the `label` column in the formal data format.
| `param` | Block | Optional| A [param](reference/mod-resources/query#param) block that defines the parameters that can be passed in to the query.  `param` blocks may only be specified for cards that specify the `sql` argument. 
| `query` | Query Reference | Optional | A reference to a [query](reference/mod-resources/query) resource that defines the query to run.  A card may either specify the `query` argument or the `sql` argument, but not both.
| `sql` |  String	| Optional |  An SQL string to provide data for the card.  A card may either specify the `query` argument or the `sql` argument, but not both.
| `title` |  String	| Optional | A plain text [title](/docs/reference/mod-resources/dashboard#title) to display for this card.
| `type` |  String	| Optional | `plain` (default), `alert`, `info` or `ok`. You can also use `table` to review the raw data.
| `value` |  String	| Optional | Inferred from the first column's value in simple data format.
| `width` |  Number	| Optional | The [width](/docs/reference/mod-resources/dashboard#width) as a number of grid units that this item should consume from its parent.

## Data Structure

A card supports 2 data structures.

1. A simple structure where column 1's name is the card `label` and column 1's value is the card `value`.
2. A formal data structure where the column names map to properties of the `card`.

Simple data structure:

| <label\> |
|----------|
| <value\> |

For example:

| Unencrypted Buckets |
|---------------------|
| 25                  |


Formal data structure:

| label               | value | type |
| ------------------- | ----- | ----- |
| Unencrypted Buckets | 10    | alert |


#### JQ Templates
The `href` argument allows you to specify a [jq](https://stedolan.github.io/jq/) template to dynamically generate a hyperlink from the data in the row. To use a jq template, enclose the jq in double curly braces (`{{ }}`).  

Steampipe will pass the first row of data to jq in the same format that is returned by [steampipe query json mode output](reference/dot-commands/output), where the keys are the column names and the values are the data for that row. 

For example, this query:
```sql
select
  s.volume_id as value,
  'Source Volume' as label,
  'info' as type,
  v.arn
from
  aws_ebs_snapshot as s,
  aws_ebs_volume as v
where
  s.volume_id = v.volume_id
  and s.snapshot_id = 'snap-0cc613495a9fe5c1c';

```

will present rows to the jq template in this format:
```json
{
  "arn": "arn:aws:ec2:us-east-2:123456789012:volume/vol-0566e02dcc2c08e77",
  "label": "Source Volume",
  "type": "info",
  "value": "vol-0566e02dcc2c08e77"
 }
```

which you can then use in a jq template in the `href` argument:
```hcl
card {
  sql = <<-EOQ
    select
      s.volume_id as value,
      'Source Volume' as label,
      'info' as type,
      v.arn
    from
      aws_ebs_snapshot as s,
      aws_ebs_volume as v
    where
      s.volume_id = v.volume_id
      and s.snapshot_id = 'snap-0cc613495a9fe5c1c';
  EOQ
  
  width = 3
  href  = "/aws_insights.dashboard.aws_ebs_volume_detail?input.volume_arn={{.arn | @uri}}"
}
```

Note that for a `card`, we pass `label` , `value` , `type`  or `icon` HCL attributes in the JQ context, but the columns from the SQL query will overwrite any of the statically-defined HCL attributes.


Refer to [JQ Escaping & Interpolation ](/docs/reference/mod-resources/dashboard#jq-escaping--interpolation) for more advanced examples.


## More Examples



### Alert Card

<img src="/images/reference_examples/card_ex_alert.png" width="200pt" />

<br />

```hcl
card {
  sql = "select 0 as alert"
  type  = "alert"
  width = 2
} 
```

### OK Card

<img src="/images/reference_examples/card_ex_ok.png" width="200pt" />

<br />

```hcl
card {
  sql = "select 0 as ok"
  type  = "ok"
  width = 2
} 
```


### Info Card

<img src="/images/reference_examples/card_ex_info.png" width="200pt" />

<br />

```hcl
card {
  sql = "select 0 as info"
  type  = "info"
  width = 2
} 
```



### Dynamic Styling via formal query data structure

<img src="/images/reference_examples/card_ex_dynamic.png" width="200pt" />

<br />

```hcl
card {
  sql = <<-EOQ
    select
      'Unencrypted Buckets' as label,
      count(*) as value,
      case
        when count(*) > 0 then 'alert'
        else 'ok'
      end as type
    from
      aws_s3_bucket
    where
      server_side_encryption_configuration is null;
  EOQ
  width = 2
}
```



### Static data and static (external) link

<img src="/images/reference_examples/card_ex_static_link.png" width="200pt" />

<br />

```hcl
card {
  value = "github"
  label = "site"
  width = 2
  href  = "https://github.com"
}
```


### Dynamic data and static (internal) link
<img src="/images/reference_examples/card_ex_internal_link.png" width="200pt" />

<br />

```hcl
card {
  sql = <<-EOQ
    select
      count(*) as value,
      'Has Public Bucket Policy' as label,
      case
        count(*)
        when 0 then 'ok'
        else 'alert'
      end as "type"
    from
      aws_s3_bucket
    where
      bucket_policy_is_public;
  EOQ
  
  icon  = "hashtag"
  width = 2
  href  = "${dashboard.aws_s3_bucket_public_access_report.url_path}"
}
```


### Dynamic link with JQ template
<img src="/images/reference_examples/card_ex_dynamic_link.png" width="300pt" />

<br />

```hcl
card {
  sql = <<-EOQ
    select
      s.volume_id as value,
      'Source Volume' as label,
      'info' as type,
      v.arn
    from
      aws_ebs_snapshot as s,
      aws_ebs_volume as v
    where
      s.volume_id = v.volume_id
      and s.snapshot_id = 'snap-0cc613495a9fe5c1c';
  EOQ
  
  width = 3
  href  = "/aws_insights.dashboard.aws_ebs_volume_detail?input.volume_arn={{.arn | @uri}}"
}
```
