---
title: Connect to Steampipe Cloud from Tableau
sidebar_label: Tableau
---
# Connect to Steampipe Cloud from Tableau

[Tableau](https://www.tableau.com) is a visual analytics platform that is "transforming the way we use data to solve problems."

Steampipe provides a single interface to all your cloud, code, logs and more.  Because it's built on Postgres, Steampipe provides an endpoint that any Postgres-compatible client -- including Tableau -- can connect to. 

The [Connect](./docs/cloud/connecting/overview#connecting-to-your-workspace) tab for your workspace provides the details you need to connect Tableau to Steampipe Cloud.

<div style={{"borderWidth":"thin", "borderStyle":"solid", "borderColor":"lightgray", "padding":"12px", "marginTop":"1em", "marginBottom":"1em", "width":"90%"}}>
<img src="/images/docs/cloud/cloud-connect-tab.jpg" />
</div>

Once you've tested the connection to Steampipe Cloud, you can browse the tables provided by your Steampipe plugins, run queries, and build dashboards.

## Getting started

Tableau is available on the desktop and the cloud. The examples here use Tableau Online, so start by creating an account there if you don't already have one.

Create a Tableau `Project` called `Steampipe`. In the project, create a workbook. On the `Connect to Data` screen that pops up, click `Connectors → PostgreSQL` and enter your Steampipe Cloud connection info. `Require SSL` is unchecked by default and that's OK, it's also OK to check it.

Now drag the `aws_cost_by_service_daily` table from the sidebar to the canvas, then click `Update Now`. Tableau displays the table's schema, and previews the data.

<div style={{"borderWidth":"thin", "borderStyle":"solid", "borderColor":"lightgray", "padding":"12px", "marginTop":"1em", "marginBottom":"1em", "width":"90%"}}>
<img src="/images/docs/cloud/tableau-initial-table-view.jpg" />
</div>

## Summarize and chart one AWS table

Switch from the workbook's `Data Source` tab to its `Sheet 1` tab. Drag the `Blended Cost Amount` column to the `Rows` shelf, and the `Period Start` column to the `Columns` shelf. 

The `Period Start` indicator defaults to YEAR. Open its dropdown and choose the second `Day` option which reports full dates. Tableau charts the daily sums of costs for all your AWS services.

<div style={{"borderWidth":"thin", "borderStyle":"solid", "borderColor":"lightgray", "padding":"12px", "marginTop":"1em", "marginBottom":"1em", "width":"90%"}}>
<img src="/images/docs/cloud/tableau-initial-chart.jpg" />
</div>

Publish the workbook as `daily cost for all AWS services`, and check `Embed password for data source`.

## Use Tableau-enhanced SQL

Now create another new workbook in the project. Repeat the steps to connect it to Steampipe Cloud, and again drag the `aws_cost_by_service_daily` table to the canvas.

This time, open the `aws_cost_by_service` dropdown and choose `Convert to Custom SQL`.

<div style={{"borderWidth":"thin", "borderStyle":"solid", "borderColor":"lightgray", "padding":"12px", "marginTop":"1em", "marginBottom":"1em", "width":"90%"}}>
<img src="/images/docs/cloud/tableau-convert-to-custom-sql.jpg" />
</div>

In the `Convert to SQL` editor, replace code with the following.

```
select 
 service,
  blended_cost_amount,
  period_start
from 
  aws_cost_by_service_daily
where 
  service = 
order by
  period_start
```

Then click `Insert Parameter → Create a New Parameter`. Name the parameter `Service`, set its type to `String`, for `Allowable Values` chose `List`, click `Add Values From`, and choose `Service`. 

<div style={{"borderWidth":"thin", "borderStyle":"solid", "borderColor":"lightgray", "padding":"12px", "marginTop":"1em", "marginBottom":"1em", "width":"60%"}}>
<img src="/images/docs/cloud/tableau-create-parameter.jpg" />
</div>

Click `OK`, then (if necessary) edit the `Convert to SQL` text so it reads like so.

```
select 
 service,
  blended_cost_amount,
  period_start
from 
  aws_cost_by_service_daily
where
   service = <Parameters.Service>
order by
  period_start
```

Click `OK`. Then visit the `Sheet 1` tab, choose `Parameters → Service → Show Parameter`. 

<div style={{"borderWidth":"thin", "borderStyle":"solid", "borderColor":"lightgray", "padding":"12px", "marginTop":"1em", "marginBottom":"1em", "width":"90%"}}>
<img src="/images/docs/cloud/tableau-initial-sheet-with-service-dropdown.jpg" />
</div>

The sheet now has a chooser for AWS services.

As before, drag `Blended Cost Amount` to the `Rows` shelf, drag `Period Start` to the `Columns Shelf`, and set `Period Start` to `day`.

Tableau charts the selected service.

<div style={{"borderWidth":"thin", "borderStyle":"solid", "borderColor":"lightgray", "padding":"12px", "marginTop":"1em", "marginBottom":"1em", "width":"90%"}}>
<img src="/images/docs/cloud/tableau-chart-selected-service.jpg" />
</div>

Publish the workbook as `daily cost for selected service`, again with `Embed password for data source`.

## Send alerts

Open the project (`Explore → Steampipe`), reopen the `daily cost for all AWS services` workbook, reopen `Sheet 1`, and click `Watch → Alerts`. 

<div style={{"borderWidth":"thin", "borderStyle":"solid", "borderColor":"lightgray", "padding":"12px", "marginTop":"1em", "marginBottom":"1em", "width":"90%"}}>
<img src="/images/docs/cloud/tableau-initial-watch-alerts.jpg" />
</div>

Select the `Blended Cost Amount` axis.

<div style={{"borderWidth":"thin", "borderStyle":"solid", "borderColor":"lightgray", "padding":"12px", "marginTop":"1em", "marginBottom":"1em", "width":"90%"}}>
<img src="/images/docs/cloud/tableau-select-axis-to-create-alert.jpg" />
</div>

Then click `Create` and fill in the details: `Condition`, `Threshold`, etc.

<div style={{"borderWidth":"thin", "borderStyle":"solid", "borderColor":"lightgray", "padding":"12px", "marginTop":"1em", "marginBottom":"1em", "width":"60%"}}>
<img src="/images/docs/cloud/tableau-create-alert-dialog.jpg" />
</div>

## Summary

With Tableau and Steampipe Cloud you can:

- Summarize, filter, and chart the tables in your Steampipe Cloud workspace

- Create interactive widgets driven by data in those tables

- Send query-driven alerts
