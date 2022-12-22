---
title: With
sidebar_label: with
---

# with

Some resources may also include `with` blocks. Similar to a `with` clause in a postgres CTE, the `with` block allows you to specify additional queries or sql statements to run **before** running "main" query specified in the `sql` or `query` argument for the resource.

`with` is not a top-level named resource in its own right - it is ONLY a block within other resources. You can only specify `with` blocks on **top-level named resources** in your mod. The results of the `with` query can be referenced within the resource in which it is defined (including any sub-blocks) as `with.{name}`.  





## Example Usage



    


## Argument Reference
| Argument | Type | Optional? | Description
|-|-|-|-
| `args` | Map | Optional| A map of arguments to pass to the query. 
| `query` | Query Reference | Optional | A reference to a [query](reference/mod-resources/query) resource that defines the query to run.  You must either specify the `query` argument or the `sql` argument, but not both.
| `sql` |  String	| Optional |  An SQL string to provide data for the `edge`.  You must either specify the `query` argument or the `sql` argument, but not both.





## More Examples
