---
title: Edge
sidebar_label: edge
---

# edge

The `edge` block represents a connection between 2 nodes (vertices) in a `graph`, `hierarchy` or `flow`.  

Like most dashboard elements, nodes and edges are query-provider resources; they may have either a `sql` or `query` argument (but not both), as well as `with` blocks, `param` blocks and `args`, and these behave the same as they do for other resources that run sql (`control`, `chart`, `card`, etc).

Anonymous `edge` blocks can be declared inside a `graph`, `hierarchy` or `flow`.  They may also may be declared as named resources at the top level of a mod and referenced via `base` from other edges in a `graph`, `hierarchy` or `flow`.


## Example Usage

```hcl
edge "plugin_to_version" {
  title = "version"

  sql = <<-EOQ
    select
      name as from_id,
      digest as to_id
    from
      steampipe_registry_plugin_version
    where
      name = $1
  EOQ

  param "plugin_name" {}
}
```
    


## Argument Reference
| Argument | Type | Optional? | Description
|-|-|-|-
| `args` | Map | Optional| A map of arguments to pass to the query. 
| `base` |  flow Reference		| Optional | A reference to a named `edge` resource that this `edge` should source its definition from. 
| `category` | Block | Optional| [category](/docs/reference/mod-resources/category) blocks that specify display options for edges with that category.
| `param` | Block | Optional| [param](reference/mod-resources/query#param) blocks that defines the parameters that can be passed in to the query.  `param` blocks may only be specified when the edge is defined as a top-level (mod level), named resource. 
| `query` | Query Reference | Optional | A reference to a [query](reference/mod-resources/query) resource that defines the query to run.  You must either specify the `query` argument or the `sql` argument, but not both.
| `sql` |  String	| Optional |  An SQL string to provide data for the `edge`.  You must either specify the `query` argument or the `sql` argument, but not both.
| `title` |  String	| Optional | A plain text [title](/docs/reference/mod-resources/dashboard#title) to display for this edge.
| `with` | Block | Optional| [with](/docs/reference/mod-resources/with)) blocks that define prerequisite queries to run.  `with` blocks may only be specified when the edge is defined as a top-level (mod level), named resource.


## Data Format
Data must be provided in a format where each row represents an *edge*. 

Significant columns are:

| Name       | Description
|------------|---------------------------------------------------
| `title`    | An optional title to display for the edge.
| `category` | An optional display category.  This must be a reference to a named `category` declared in the parent `graph`, `flow`, or `hierarchy`. 
| `from_id`  | The `id` of the source side of an edge. `from_id` is required for edges
| `properties`| A jsonb key/value map of properties to display for the node/edge when the user hovers over it.  The `properties` column is optional for nodes and edges.
| `to_id`    |  The `id` of the destination side of an edge. `to_id` is required for edges

The `category` and `title` may be specified either in the SQL results or in HCL.  If both are specified, the value in the SQL result set has precedence.  



## More Examples

### inline edge in a graph
 
```hcl
dashboard "edge_ex_1" {
  graph {

    edge {
      title = "version"

      sql = <<-EOQ
        select
          name as from_id,
          digest as to_id
        from
          steampipe_registry_plugin_version
        where
          name = 'turbot/ldap'
      EOQ
    }

  }
}
```


### Reusable edge with `base`
 
```hcl
dashboard "edge_ex_2" {
  graph {

    edge {
      base = edge.plugin_to_version
    }

  }
}

edge "plugin_to_version" {
  title = "version"

  sql = <<-EOQ
    select
      name as from_id,
      digest as to_id
    from
      steampipe_registry_plugin_version
  EOQ
}

```


### Reusable edge with `base` passing args

```hcl
dashboard "edge_ex_2" {
  graph {

    edge {
      base = edge.plugin_to_version
      args = {
        plugin_name = self.input.plugin_name.value
      }
    }

  }
}

edge "plugin_to_version" {
  title = "version"

  sql = <<-EOQ
    select
      name as from_id,
      digest as to_id
    from
      steampipe_registry_plugin_version
    where
      name = $1
  EOQ

  param "plugin_name" {}
}

```