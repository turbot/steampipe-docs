---
title: Connecting to Your Workspace from Metabase
sidebar_label: Metabase
---

#  Connecting to Your Workspace from Metabase

[Metabase](https://metabase.com/) is an open source tool that connects to many databases, including Postgres, and enables users to explore, query, and visualize data. 

Steampipe provides a single interface to all your cloud, code, logs and more.  Because it's built on Postgres, Steampipe provides an endpoint that any Postgres-compatible client -- including Metabase -- can connect to. 

The [Connect](/docs/cloud/integrations/overview) tab for your workspace provides the details you need to connect Metabase to Steampipe Cloud.

<div style={{"borderWidth":"thin", "borderStyle":"solid", "borderColor":"lightgray", "padding":"20px", "width":"90%"}}>
<img src="/images/docs/cloud/cloud-connect-tab.jpg" />
</div>

## Getting Started

Metabase is a JVM app that you can run as a JAR file, or in a container, or as a native Mac app. 

Here's one way to launch Metabase.

```
docker run -d -p 3000:3000 --name metabase metabase/metabase
```

With Metabase up and running, point a browser at port 3000, select `Postgres` as the database type, and enter your Steampipe Cloud connection info.

<div style={{"borderWidth":"thin", "borderStyle":"solid", "borderColor":"lightgray", "padding":"12px", "marginTop":"1em", "marginBottom":"1em", "width":"90%"}}>
<img src="/images/docs/cloud/metabase-connect-info.png" />
</div>
   
Browsing to the Steampipe Cloud database reveals the set of installed plugins. Note that if you're using the AWS plugin as in the examples here, it will take a while for Metabase to do its initial metadata sync for the hundreds of tables provided by the AWS plugin. 

<div style={{"borderWidth":"thin", "borderStyle":"solid", "borderColor":"lightgray", "padding":"12px", "marginTop":"1em", "marginBottom":"1em", "width":"90%"}}>
<img src="/images/docs/cloud/metabase-installed-plugins.jpg" />
</div>

Each button opens the tables provided by a plugin. Here's the first screenful of tables provided by the `aws` plugin. 

<div style={{"borderWidth":"thin", "borderStyle":"solid", "borderColor":"lightgray", "padding":"12px", "marginTop":"1em", "marginBottom":"1em", "width":"90%"}}>
<img src="/images/docs/cloud/metabase-aws-tables.jpg" />
</div>

## Summarize, filter, and chart one AWS table

We'll focus here on the [aws_cost_by_service_daily](https://hub.steampipe.io/plugins/turbot/aws/tables/aws_cost_by_service_daily) table. Metabase displays an initial view of the data, with buttons to `Filter` and `Summarize`.

<div style={{"borderWidth":"thin", "borderStyle":"solid", "borderColor":"lightgray", "padding":"12px", "marginTop":"1em", "marginBottom":"1em", "width":"90%"}}>
<img src="/images/docs/cloud/metabase-aws-cost-by-service-daily-initial.jpg" />
</div>

Click `Summarize`, choose `Sum of ...`, and pick `Blended Cost Amount`. Under `Group by` choose `Period Start`. Metabase charts the total costs for all services. The default grouping is weekly but you can switch to daily or monthly. 

To summarize by the names of AWS services, open the `Admin → Data Model` screen, navigate to the `aws_cost_by_service_daily` table, and change the type of the `Service` column from `No semantic type` to `Category`. Then revisit the `Filter` operation on the table and choose `Service`. Now you can search for one or more services and filter the view to just those services. 

<div style={{"borderWidth":"thin", "borderStyle":"solid", "borderColor":"lightgray", "padding":"12px", "marginTop":"1em", "marginBottom":"1em", "width":"90%"}}>
<img src="/images/docs/cloud/metabase-cost-by-service-daily-filtered.jpg" />
</div>

These interactive methods are handy, but you can also open a SQL editor (click `Ask a question → Native query`) and write queries just as you do in Steampipe Cloud, with some extra features provided by Metabase.

## Using Metabase-enhanced SQL

You can augment your SQL queries with Metabase idioms that parameterize queries and connect them to a suite of UX widgets. To try that, click `Ask a question → Native query → Steampipe Cloud` and paste this SQL.

```
select 
  service,
  blended_cost_amount,
  to_char(period_end, 'YYYY-MM-DD') as day
from 
  aws_cost_by_service_daily
where
  {{ service }} 
  and period_start > now() - interval '1 month'
order by
  day desc
```

When it sees a name in double squigglies, Metabase opens its `Variables` pane. Choose `Field Filter` as the type. To pick a field to map to, navigate from the list of schemas (all the installed plugins) to `Aws` to `Aws Cost By Service Daily` and choose `Service`. Now you can use a picker to filter the view to one or more services, as above.

<div style={{"borderWidth":"thin", "borderStyle":"solid", "borderColor":"lightgray", "padding":"12px", "marginTop":"1em", "marginBottom":"1em", "width":"90%"}}>
<img src="/images/docs/cloud/metabase-cost-by-service-daily-filtered-with-variable.jpg" />
</div>

To chart the data, click `Visualization`. Here's a chart for a selection of 3 services.

<div style={{"borderWidth":"thin", "borderStyle":"solid", "borderColor":"lightgray", "padding":"12px", "marginTop":"1em", "marginBottom":"1em", "width":"90%"}}>
<img src="/images/docs/cloud/metabase-cost-by-service-daily-filtered-with-variable-as-line-chart.jpg" />
</div>

## Sending notifications

Suppose you'd like to be notified when the daily blended cost of any service exceeds 10 dollars. Here's a query to find those rows in the table.

```
select 
  service,
  to_char(period_end, 'MM-DD') as day,
  period_end,
  blended_cost_amount 
from 
  aws_cost_by_service_daily 
where 
  blended_cost_amount > 10 
  and period_start > now()::timestamptz - interval '2 day'
```
In order to send an alert when one or more rows exceeds the threshold, first save the query as a Metabase *question*: a URL-addressable view like `HOST://question/1-costly-services`. Then create a Metabase *dashboard*, which is a container for one or more Metabase queries, and add the question to the dashboard. 

Using a Metabase feature called *Dashboard Subscriptions*, you can can then set up notifications using email or Slack. Metabase will only notify when a table on the subscribed dashboard produces rows.

<div style={{"borderWidth":"thin", "borderStyle":"solid", "borderColor":"lightgray", "padding":"12px", "marginTop":"1em", "marginBottom":"1em", "width":"90%"}}>
<img src="/images/docs/cloud/metabase-costly-services-dashboard-with-subscription.jpg" />
</div>

## Summary

You can use Metabase + Steampipe Cloud to:

- Apply basic Metabase-style filtering and summarization to Steampipe tables

- Use Metabase-enhanced SQL to create interactive widgets

- Create Metabase dashboard subscriptions that send alerts via email or Slack