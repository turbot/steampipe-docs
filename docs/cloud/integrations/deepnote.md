---
title: Connect to Steampipe Cloud from Deepnote
sidebar_label: Deepnote
---

##  Connect to Steampipe Cloud from Deepnote

[Deepnote](https://deepnote.com/home) is a collaborative notebook for discovering, understanding and sharing data. It connects to many databases, including Postgres, and enables users to explore, query, and visualize data.

Steampipe provides a single interface to all your cloud, code, logs and more. Because it's built on Postgres, Steampipe provides an endpoint that any Postgres-compatible client -- including Deepnote -- can connect to.

The [Connect](/docs/cloud/integrations/overview) tab for your workspace provides the details you need to connect Deepnote to Steampipe Cloud.

<div style={{"marginBottom":"2em","borderWidth":"thin", "borderStyle":"solid", "borderColor":"lightgray", "padding":"20px", "width":"90%"}}>
<img src="/images/docs/cloud/steampipe-cloud-connect-details.jpg" />
</div>

##  Connect to Steampipe CLI from Deepnote

You can also connect Deepnote to [Steampipe CLI](https://steampipe.io/downloads). To do that, run `steampipe service start --show-password` and use the displayed connection details.

```
Steampipe service is running:

Database:

  Host(s):            localhost, 127.0.0.1, 192.168.29.204
  Port:               9193
  Database:           steampipe
  User:               steampipe
  Password:           99**_****_**8c
  Connection string:  postgres://steampipe:99**_****_**8c@localhost:9193/steampipe
  ```

## Getting started

[Deepnote](https://deepnote.com/sign-up) works with any web browser.

To create a new connection, first click on `Projects` to create a new project. Then click `Create new` from the `Integrations` tab on the right sidebar, select `PostgreSQL` and enter the connection details.

<div style={{"marginTop":"1em", "marginBottom":"1em", "width":"90%"}}>
<img src="/images/docs/cloud/deepnote-connection-success.png" />
</div>

Once the integration is successful, click `View Schema` from the navigation bar to explore the connections in your workspace.

<div style={{"marginTop":"1em", "marginBottom":"1em", "width":"40%"}}>
<img src="/images/docs/cloud/deepnote-navigationbar.png" />
</div>

## Create a chart with custom query

Let's use the [Finance](https://hub.steampipe.io/plugins/turbot/finance) plugin to chart the change percentage for bitcoin during regular market session. To begin, click the `SQL` block and select the integrated database from the dropdown list on the projects page. Paste this query in the command palette and click `Run notebook`. You can refresh the notebook on an hourly, daily or weekly schedule to update the data using the `Schedule notebook` feature.

```
select
  symbol,
  short_name,
  regular_market_price,
  regular_market_change_percent,
  regular_market_time
from
  finance_quote
where
  symbol in ('GME', 'BTC-USD', 'DOGE-USD', 'ETH-USD');
```

Deepnote previews the data in a table form. The data can also be exported in a CSV format.

<div style={{"marginTop":"1em", "marginBottom":"1em", "width":"70%"}}>
<img src="/images/docs/cloud/deepnote-table-preview.png" />
</div>

Now click `Visualize` to open the visualize data form and select Type as `Bar chart`. Update the X and Y Axis data fields with `regular_market_change_percent` and `symbol` to display the chart with the data. Deepnote also supports `Block sharing`: it can generate a link that anyone can use to view the shared block.

<div style={{"marginTop":"1em", "marginBottom":"1em", "width":"90%"}}>
<img src="/images/docs/cloud/deepnote-bitcoin-chart.png" />
</div>

## Summary

With Deepnote and Steampipe Cloud you can:

- View tables in your Steampipe Cloud workspace

- Write custom queries to preview data from the tables in your Steampipe Cloud workspace

- Create and share charts driven by your custom queries