---
title: Graph
sidebar_label: graph
---

# graph

A graph is a component that can be used to display data in a graphical format within a dashboard. It allows you to visualize the relationships between different resources and understand how they are connected.

Graphs can be declared as a block inside a dashboard or container. The data to be displayed in the graph is specified using a series of node and edge blocks. The node blocks define the vertices of the graph, and the edge blocks define the connections between them.

## Example Usage

<img src="/images/reference_examples/graph_ex_1.png" width="100%" />

```hcl
dashboard "tables" {

  graph {
    title = "Schemas & Tables"

    node {
      category = category.catalog

      sql = <<-EOQ
        select
          distinct on (catalog_name)
          concat('catalog:',catalog_name) as id,
          catalog_name as title
        from
          information_schema.schemata
       where
          schema_name = 'net'
      EOQ
    }

    node {
      category = category.schema
      sql = <<-EOQ
        select
          concat('schema:',schema_name) as id,
          schema_name as title,
          json_build_object(
            'catalog', catalog_name,
            'schema', schema_name,
            'owner', schema_owner
          ) as properties
        from
          information_schema.schemata
        where
          schema_name = 'net'
      EOQ
    }

      node {
        category = category.table
        sql = <<-EOQ
          select
            concat('table:',table_name) as id,
            table_name as title,
            json_build_object(
              'catalog', table_catalog,
              'schema', table_schema,
              'type', table_type
            ) as properties
          from
            information_schema.tables
          where
            table_schema = 'net'
        EOQ
      }

      edge {
        sql = <<-EOQ
          select
            concat('catalog:',catalog_name) as from_id,
            concat('schema:',schema_name) as to_id
          from
            information_schema.schemata
        EOQ
      }

      edge {
        sql = <<-EOQ
          select
            concat('schema:',table_schema) as from_id,
            concat('table:',table_name) as to_id
          from
            information_schema.tables
        EOQ
      }
  }
}

```




| Argument    | Type   | Optional? | Description
|-------------|--------|-----------|------------
| `args` | Map | Optional| A map of arguments to pass to the query. 
| `base` |  graph Reference		| Optional | A reference to a named `graph` resource that this `graph` should source its definition from. `title` and `width` can be overridden after sourcing via `base`.
| `category` | Block | Optional| [category](#category) blocks that specify display options for nodes with that category.
| `direction` | String | Optional | The direction of the graph layout. Valid options `left_right` and `top_down`.  The default is  `top_down`.
| `edge` | Block | Optional| [edge](#edge) blocks that specify display options for edges with that category.
| `node` | Block | Optional| [node](#node) blocks that specify display options for nodes with that category.
| `param` | Block | Optional| A [param](reference/mod-resources/query#param) block that defines the parameters that can be passed in to the graph.  
| `query` | Query Reference | Optional | A reference to a [query](reference/mod-resources/query) resource that defines the query to run.  A chart may either specify the `query` argument or the `sql` argument, but not both.
| `sql` |  String	| Optional |  An SQL string to provide data for the chart.  A chart may either specify the `query` argument or the `sql` argument, but not both.
| `title`     | String | Optional | The title to display above the graph.
| `type`      | String | Optional | The type of graph to display. Currently, only `graph` is supported. The default is `graph`.
| `width` |  Number	| Optional | The [width](/docs/reference/mod-resources/dashboard#width) as a number of grid units that this item should consume from its parent.


Note that the graph component also includes node and edge blocks, which define the nodes and edges of the graph, respectively. These blocks have their own set of arguments, which can be used to specify the data and appearance of the nodes and edges.