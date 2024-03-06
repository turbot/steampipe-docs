---
title: Container
sidebar_label: container
---

# container

> ***Powerpipe is now the recommended way to run dashboards and benchmarks!***
> Mods still work as normal in Steampipe for now, but they are deprecated and will be removed in a future release:
> - [Steampipe Unbundled →](https://steampipe.io/blog/steampipe-unbundled)
> - [Powerpipe for Steampipe users →](https://powerpipe.io/blog/migrating-from-steampipe)

A container groups and arranges related items within a dashboard. For example, you may want to group together a number of different charts for a specific AWS service.

Containers can only be declared as anonymous blocks inside a `dashboard` or `container`.


## Example Usage

<img src="/images/reference_examples/container_ex_1.png" width="100%" />

```hcl

container {
  title = "Side by Side Container Example"
  container {
    width = 6

    card {
      sql  = "select 1 as \"Left Side\""
    }
     card {
      sql  = "select 2 as \"Left Side\""
    }
  }

  container {
    width = 6
    card {
      sql  = "select 1 as \"Right Side\""
    }
     card {
      sql  = "select 2 as \"Right Side\""
    }
  }
}
```


## Argument Reference
| Argument | Type | Optional? | Description
|-|-|-|-
| `base` |  Dashboard or Container Reference		| Optional | A reference to a named `dashboard` or `container` that this `container` should source its definition from. `title` and `width` can be overridden after sourcing via `base`.
| `benchmark`    | Block	| Optional | [benchmark](/docs/reference/mod-resources/benchmark) blocks to embed benchmarks in the dashboard.
| `chart`        | Block	| Optional | [chart](/docs/reference/mod-resources/chart)  blocks to visualize SQL data in a number of ways e.g. `bar`, `column`, `line`, `pie` 
| `container` |  Block	| Optional |  [container](/docs/reference/mod-resources/container) blocks to lay out related components together in a dashboard. 
| `flow` | Block	| Optional |  [flow](/docs/reference/mod-resources/flow)  blocks to visualize flows using types such as `sankey`. 
| `hierarchy` | Block	| Optional |  [hierarchy](/docs/reference/mod-resources/hierarchy)  blocks to visualize hierarchical data using types such as `tree`. 
| `image`     | Block	| Optional | [image](/docs/reference/mod-resources/image)    blocks to embed images in dashboards. Supports static URLs, or can be derived from SQL.                                                                               
| `input`     | Block	| Optional | [input](/docs/reference/mod-resources/input) blocks to make dynamic dashboards based on user-provided input.     
| `table`      | Block	| Optional | [table](/docs/reference/mod-resources/table)   blocks to show tabular data in a dashboard.
| `text`       | Block	| Optional | [text](/docs/reference/mod-resources/text) blocks to add GitHub-flavoured markdown to a dashboard.      
| `title` |  String	| Optional | A plain text [title](/docs/reference/mod-resources/dashboard#title) to display for this container.
| `width` |  Number	| Optional | The [width](/docs/reference/mod-resources/dashboard#width) as a number of grid units that this item should consume from its parent.
