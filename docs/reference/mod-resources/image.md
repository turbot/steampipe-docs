---
title: Image
sidebar_label: image
---

# image

Display images in dashboard, either from a known publicly-accessible `src` URL, or from a `src` returned in a SQL query.

Image blocks can be declared as named resources at the top level of a mod, or be declared as anonymous blocks inside a `dashboard` or `container`, or be re-used inside a `dashboard` or `container` by using an `image` with `base = <mod>.image.<image_resource_name>`.


## Example Usage

<img src="/images/reference_examples/image_ex_1.png" width="200pt" />

```hcl
image {
  src = "https://steampipe.io/images/steampipe_logo_wordmark_color.svg"
  alt = "Steampipe Logo"
  width = 2
}
```


## Argument Reference
| Argument | Type | Optional? | Description
|-|-|-|-
| `alt` |  String	| Optional | Alternative text for the image.
| `args` | Map | Optional| A map of arguments to pass to the query.  
| `base` |   Text Reference		| Optional | A reference to a named `text` resource that this `text` should source its definition from. `title` and `width` can be overridden after sourcing via `base`.
| `param` | Block | Optional| A [param](reference/mod-resources/query#param) block that defines the parameters that can be passed in to the query.  `param` blocks may only be specified for images that specify the `sql` argument. 
| `query` | Query Reference | Optional | A reference to a [query](reference/mod-resources/query) resource that defines the query to run.  An `image`  may either specify the `query` argument or the `sql` argument, but not both.
| `sql` |  String	| Optional |  An SQL string to provide data for the `image`.  An `image` may either specify the `query` argument or the `sql` argument, but not both.
| `src` |  String	| Optional | Publicly-accessible URL for the image.
| `title` |  String	| Optional | A plain text [title](/docs/reference/mod-resources/dashboard#title) to display for this image.
| `width` |  Number	| Optional | The [width](/docs/reference/mod-resources/dashboard#width) as a number of grid units that this item should consume from its parent.

## Data Structure

If an image provides a `sql` query, it supports 2 data structures.

1. A simple structure where column 1's name is the `alt` and column 1's value is the image `src`.
2. A formal data structure where the column names map to properties of the `image`.

Simple data structure:

| <alt\> |
|--------|
| <src\> |

Formal data structure:

| src                                  | alt            |
| ------------------------------------ | -------------- |
| https://steampipe.io/images/logo.png | Steampipe Logo |


## More Examples


### Via query
<img src="/images/reference_examples/image_ex_torvalds.png" width="200pt" />

```hcl
image {
  sql = <<-EOQ
    select 
      avatar_url as "Avatar"
    from 
      github_user 
    where 
      login = 'torvalds'
  EOQ
  width = 2
}
```


### Dynamic Styling via formal query data structure
<img src="/images/reference_examples/image_ex_ken.png" width="200pt" />

```hcl
image {
  sql = <<-EOQ
   select 
    avatar_url as src,
    'Avatar' as alt
  from 
    github_user 
  where 
    login = 'ken'
  EOQ
  width = 2
}
```