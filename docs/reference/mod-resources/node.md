---
title: Node
sidebar_label: node
---

# node

> ***Powerpipe is now the recommended way to run dashboards and benchmarks!***
> Mods still work as normal in Steampipe for now, but they are deprecated and will be removed in a future release:
> - [Steampipe Unbundled →](https://steampipe.io/blog/steampipe-unbundled)
> - [Powerpipe for Steampipe users →](https://powerpipe.io/blog/migrating-from-steampipe)


The `node` block represents a vertex in a `graph`, `hierarchy` or `flow`.  

Anonymous `node` blocks can be declared inside a `graph`, `hierarchy` or `flow`.  They may also may be declared as named resources at the top level of a mod and referenced via `base` from other nodes in a `graph`, `hierarchy` or `flow`.


## Example Usage

```hcl
node {
  category = category.plugin_version

  sql = <<-EOQ
    select
      digest as id,
      left(split_part(digest,':',2),12) as title,
      json_build_object(
        'digest', digest,
        'created', create_time,
        'updated', update_time
      ) as properties
    from
      steampipe_registry_plugin_version
    where
      name = 'turbot/ldap'
  EOQ
}
```
    


## Argument Reference
| Argument | Type | Optional? | Description
|-|-|-|-
| `args` | Map | Optional| A map of arguments to pass to the query. 
| `base` |  flow Reference		| Optional | A reference to a named `node` resource that this `node` should source its definition from. 
| `category` | Block | Optional| [category](/docs/reference/mod-resources/category) blocks that specify display options for nodes with that category.
| `depth`  | Number	| Optional |  An integer to set the position of the node in a flow. The layout of the nodes is inferred from the query, however you can force placement with the `depth` argument if you need to override the default behavior. The `depth` argument is optional, and is only used by `flow` resources.
| `param` | Block | Optional| [param](reference/mod-resources/query#param) blocks that defines the parameters that can be passed in to the query.  `param` blocks may only be specified when the node is defined as a top-level (mod level), named resource. 
| `query` | Query Reference | Optional | A reference to a [query](reference/mod-resources/query) resource that defines the query to run.  You must either specify the `query` argument or the `sql` argument, but not both.
| `sql` |  String	| Optional |  An SQL string to provide data for the `node`.  You must either specify the `query` argument or the `sql` argument, but not both.
| `title` |  String	| Optional | A plain text [title](/docs/reference/mod-resources/dashboard#title) to display for this node.


## Data Format
Data must be provided in a format where each row represents a *node* (vertex).  Significant columns are:

| Name       | Description
|------------|---------------------------------------------------
| `id`       | A unique identifier for the node. `id` is required for nodes.
| `title`    | An optional title to display for the node.
| `category` | An optional display category.  This must be the name of a `category` declared in the parent `graph`, `flow`, or `hierarchy`. 
| `depth`    | An integer to set the position of the node in a flow. The layout of the nodes is inferred from the query, however you can force placement with the `depth` column if you need to override the default behavior. The `depth` column is optional, and is only used in `flow` resources.
| `properties`| A jsonb key/value map of properties to display for the node/edge when the user hovers over it.  The `properties` column is optional.

The `category`, `depth`, and `title` may be specified either in the SQL results or in HCL.  If both are specified, the value in the SQL result set has precedence.  



## More Examples

### inline node in a graph
 
```hcl
dashboard "node_ex_1" {
  graph {

    node {
      category = category.plugin_version

      sql = <<-EOQ
        select
          digest as id,
          left(split_part(digest,':',2),12) as title,
          json_build_object(
            'digest', digest,
            'created', create_time,
            'updated', update_time
          ) as properties
        from
          steampipe_registry_plugin_version
        where
          name = 'turbot/ldap'
      EOQ
    }
    
  }
}
```


### Reusable node with `base`
 
```hcl
dashboard "node_ex_2" {
  graph {

    node {
      base = node.plugin
    }

  }
}

node "plugin"{
  category = category.plugin

  sql = <<-EOQ
    select
      name as id,
      name as title,
      json_build_object(
        'name', name,
        'created', create_time,
        'updated', update_time
      ) as properties
    from
      steampipe_registry_plugin
  EOQ
}
```


### Reusable node with `base` passing args

```hcl
dashboard "node_ex_3" {
  graph {

    node {
      base = node.plugin
      args = {
        plugin_name = self.input.plugin_name.value
      }
    }

  }
}

node "plugin"{
  category = category.plugin

  sql = <<-EOQ
    select
      name as id,
      name as title,
      json_build_object(
        'name', name,
        'created', create_time,
        'updated', update_time
      ) as properties
    from
      steampipe_registry_plugin
    where
      name = $1
  EOQ

  param "plugin_name" {}
}
```

