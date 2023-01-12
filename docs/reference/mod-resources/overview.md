---
title: Mod Resources
sidebar_label: Mod Resources
---

# Mod Resources

## General

| Type | Description
|-|-
| [locals](reference/mod-resources/locals) | Locals are internal, module level variables.
| [mod](reference/mod-resources/mod)     | The mod block contains metadata, documentation, and dependency data for the mod.
| [query](reference/mod-resources/query) | Queries define common SQL statements that may be used alone, or referenced by arguments in other blocks like reports and actions.
| [variable](reference/mod-resources/variable) | Variables are module level objects that essentially act as parameters for a module.


## Benchmarks and Controls

| Type | Description
|-|-
| [benchmark](reference/mod-resources/benchmark) | Benchmark provides a mechanism for organizing controls into hierarchical structures. 
| [control](reference/mod-resources/control) | Controls provide a defined structure and interface for queries that draw a specific conclusion (e.g. 'ok', 'alarm') about each row.


## Dashboards

| Type        | Description                                                                                                                                                           | Valid children types                                                                                               | Allowed at top-level |
| ----------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------ | -------------------- |
| [dashboard](reference/mod-resources/dashboard) | Compose resources to meet a reporting requirement. Within the `steampipe dashboard` UI, each `dashboard` will be presented as an available item to run.      | `chart`<br/>`container`<br/>`control`<br/>`card`<br/>`flow`<br/>`graph`<br/>`hierarchy`<br/>`image`<br/>`input`<br/>`table`<br/>`text` <br/>`with` | Yes                  |
| [container](reference/mod-resources/container) | Lay out reporting resources within a dashboard. Conceptually similar to a dashboard, except it will not be presented as an available item to run within the steampipe dashboard UI. | `chart`<br/>`container`<br/>`control`<br/>`card`<br/>`flow`<br/>`graph`<br/>`image`<br/>`input`<br/>`table`<br/>`text` <br/>`with` | Yes                  |
| [card](reference/mod-resources/card)      | Display a simple value in different styles e.g. `plain`, `alert` etc. Supports static values, or derived from SQL. | None                                                                                                               | Yes                  |
| [category](reference/mod-resources/category)      | Specify display options for `nodes` and `edges` | None | Yes                  |
| [chart](reference/mod-resources/chart)     | Visualize SQL data in a chart  e.g. `bar`, `column`, `line`, `pie` etc.                                                                                       | None                                                                                                               | Yes                  |
| [edge](reference/mod-resources/edge) | Display an edge to connect nodes on a`flow`, `graph`, or `hierarchy` | None| Yes |
| [flow](reference/mod-resources/flow) | Visualize flow data using things such as `sankey`. | `node`, `edge` | Yes |
| [graph](reference/mod-resources/graph) | Visualize graph relationships.  | `node`, `edge` | Yes |
| [hierarchy](reference/mod-resources/hierarchy) | Visualize hierarchical data using things such as `tree`.| `node`, `edge` | Yes |
| [image](reference/mod-resources/image)     | Embed images in reports. Supports static URLs, or can be derived from SQL.                                                                           | None                                                                                                               | Yes                  |
| [input](reference/mod-resources/input)     | Enable dynamic dashboards based on user-provided `input`.                                                                                                           | None                                                                                                               | Yes                  |
| [node](reference/mod-resources/node) | Display a vertex (node) on a`flow`, `graph`, or `hierarchy` | None| Yes |
| [table](reference/mod-resources/table)     | Display tabular data in a dashboard.                                                                                                                                    | None                                                                                                               | Yes                  |
| [text](reference/mod-resources/text)      | Add GitHub-flavoured markdown to a dashboard.                                                                                                          | None                                                                                                               | Yes                  |
| [with](reference/mod-resources/with)      | Specify additional queries or SQL statements to run **first**, and then pass the query results as arguments to `sql`, `query`, and `node` & `edge` blocks.| None | No |
   