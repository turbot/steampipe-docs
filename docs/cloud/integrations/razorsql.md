---
title: Connect to Steampipe Cloud from RazorSQL
sidebar_label: RazorSQL
---
## Connect to Steampipe Cloud from RazorSQL

[RazorSQL](https://razorsql.com/index.html) is a SQL IDE to query, edit, browse and manage your databases.

Steampipe provides a single interface to all your cloud, code, logs and more. Because it's built on Postgres, Steampipe provides an endpoint that any Postgres-compatible client -- including RazorSQL -- can connect to.

The [Connect](/docs/cloud/integrations/overview) tab for your workspace provides the details you need to connect RazorSQL to Steampipe Cloud.

<div style={{"marginTop":"1em", "marginBottom":"1em", "width":"90%"}}>
<img src="/images/docs/cloud/steampipe-cloud-connect-details.jpg" />
</div>

Once the connection to Steampipe cloud is established and tested, you can access the tables provided by the Steampipe plugins, run queries and build reports.

You can also connect RazorSQL to [Steampipe CLI](https://steampipe.io/downloads). To do that, run `steampipe service start --show-password` and use the displayed connection details.

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

[RazorSQL](https://razorsql.com/download.html) is available to use on the desktop; there's a 30 day free trial. In this example we will create a Steampipe Cloud connection with RazorSQL and query the best stories from Hacker News.

To establish a new connection click on `Connect to a Database`, select PostgreSQL and click `Continue`. Enter the Steampipe Cloud connection details, and click `Connect`.

<div style={{"marginTop":"1em", "marginBottom":"1em", "width":"90%"}}>
<img src="/images/docs/cloud/razorsql-connection-success.png" />
</div>

Once you've connected to Steampipe Cloud, you can access the Hacker News plugin and its tables from the database navigator.

<div style={{"marginTop":"1em", "marginBottom":"1em", "width":"50%"}}>
<img src="/images/docs/cloud/razorsql-database-navigator.png" />
</div>

Here we select the `hackernews_best` table. RazorSQL displays the table's schema and previews the data. You may also choose to export the data to a [variety of formats](https://steampipe.io/docs/reference/cli/check#output-formats).

<div style={{"marginTop":"1em", "marginBottom":"1em", "width":"90%"}}>
<img src="/images/docs/cloud/razorsql-hackernews-best-preview.png" />
</div>

## Run your first custom query

RazorSQL provides a SQL editor that you may use to write custom queries. However, it requires the Schema name and the Database name to be prefixed before the table name. Here is a query to fetch new stories by score.

```
select
  *
from
  <DatabaseName>.hackernews.hackernews_new
order by
  score desc
  ```

<div style={{"marginTop":"1em", "marginBottom":"1em", "width":"90%"}}>
<img src="/images/docs/cloud/razorsql-custom-query-preview.png" />
</div>