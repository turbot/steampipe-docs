---
title: Viewing Details
sidebar_label: Viewing Details
---

# Viewing Details

> ***Powerpipe is now the recommended way to run dashboards and benchmarks!***
> Mods still work as normal in Steampipe for now, but they are deprecated and will be removed in a future release:
> - [Steampipe Unbundled →](https://steampipe.io/blog/steampipe-unbundled)
> - [Powerpipe for Steampipe users →](https://powerpipe.io/blog/migrating-from-steampipe)
> - [Powerpipe for Steampipe users →](https://powerpipe.io/blog/migrating-from-steampipe)

Most Steampipe dashboard elements (chart, card, table, etc) support a **Panel View** that allows you to enlarge the element, inspect its definition, and easily export its data.  

To see the panel view, hover over the element and the expand button (4 opposing arrows) will appear at the top of the chart or table:   

<img src="/images/docs/cost_chart_with_expander.png" width="500px" />



Click the expand button to enter panel view.

The **Preview** pane displays the element in an enlarged view, allowing you to inspect detail that may be difficult to discern in the dashboard view.

<img src="/images/docs/cost_chart_preview.png" />


The **Definition** pane displays the HCL definition for the element. 

<img src="/images/docs/cost_chart_definition.png" />


The **Query** pane displays the SQL query used by the element.  You can cut and paste this query into a SQL query editor (including the Steampipe query shell) to run or save it.

<img src="/images/docs/cost_chart_query.png" />


The **Data** pane displays a table of the results of the SQL query used by the element.  For a `table`, this will also include any hidden columns.  To download the data to CSV, click the **Download** button.

<img src="/images/docs/cost_chart_data.png" />
