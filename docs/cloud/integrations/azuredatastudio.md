---
title: Connect to Steampipe Cloud from Azure Data Studio
sidebar_label: Azure Data Studio
---

##  Connect to Steampipe Cloud from Azure Data Studio

[Azure Data Studio](https://azure.microsoft.com/en-us/products/data-studio/) is a cross-platform database tool for data exploration and visualization that connects to many databases, including Postgres, and enables users to monitor, query, and visualize data.

Steampipe provides a single interface to all your cloud, code, logs and more. Because it's built on Postgres, Steampipe provides an endpoint that any Postgres-compatible client -- including Azure Data Studio -- can connect to.

The [Connect](/docs/cloud/integrations/overview) tab for your workspace provides the details you need to connect Azure Data Studio to Steampipe Cloud.

<div style={{"marginBottom":"2em","borderWidth":"thin", "borderStyle":"solid", "borderColor":"lightgray", "padding":"20px", "width":"90%"}}>
<img src="/images/docs/cloud/steampipe-cloud-connect-details.jpg" />
</div>

##  Connect to Steampipe CLI from Azure Data Studio

You can also connect Azure Data Studio to [Steampipe CLI](https://steampipe.io/downloads). To do that, run `steampipe service start --show-password` and use the displayed connection details.

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

[Azure Data Studio](https://learn.microsoft.com/en-gb/sql/azure-data-studio/download-azure-data-studio?view=sql-server-ver16) is available to use on the desktop. First let's create a Steampipe Cloud connection from Azure Data Studio, then chart ...

<blockquote>
I don't think it makes sense to chart the data from "select * from net_dns_record where domain = 'steampipe.io' and dns_server = '1.1.1.1:53'"

How about something like this?

<pre>
select distinct
  jsonb_array_elements_text(dns_names) as domain, count(*)
from
  crtsh_certificate
where
  query = 'steampipe.io' group by domain order by count desc

+----------------------------------+-------+
| domain                           | count |
+----------------------------------+-------+
| steampipe.io                     | 26    |
| www.steampipe.io                 | 26    |
| hub.steampipe.io                 | 23    |
| cloud.steampipe.io               | 16    |
| *.usea1.db.steampipe.io          | 10    |
| *.usea1.dashboard.steampipe.io   | 8     |
| prom.cloud.steampipe.io          | 8     |
| es.cloud.steampipe.io            | 6     |
| news.steampipe.io                | 6     |
| 0001.usea1.db.steampipe.io       | 4     |
| 0001.usea1.db.cloud.steampipe.io | 2     |
+----------------------------------+-------+
</pre>
</blockquote>

To create a new connection, first install the [PostgreSQL](https://learn.microsoft.com/en-gb/sql/azure-data-studio/extensions/postgres-extension?view=sql-server-ver16) extension from the `Extensions` tab in the sidebar. Click on `New Connection` from the Connections tab, select PostgreSQL as the `Connection type` and add the connection details. Click `Advanced` and update the Port number and set the SSL mode to Require.

<div style={{"marginTop":"1em", "marginBottom":"1em", "width":"90%"}}>
<img src="/images/docs/cloud/azure-datastudio-connection-success.png" />
</div>

Once the database is connected, you can load plugins and the tables from the navigation bar.

<div style={{"marginTop":"1em", "marginBottom":"1em", "width":"50%"}}>
<img src="/images/docs/cloud/azure-datastudio-navigatonbar.png" />
</div>

Now to create a chart, first right click on the database name, select `New Query` and paste this query.

```
select
  *
from
  net_dns_record
where
  domain = 'steampipe.io'
  and dns_server = '1.1.1.1:53';
  ```

Data studio previews the data in a table form. Now click `Chart` from the side bar and select `Chart Type` as Line. The data can be saved as a CSV, XML, JSON, Excel formats or as an Image. You may also choose to save it as a custom widget for the dashboard by using the `Create Insight` (code in JSON) feature.

<blockquote>
What does `(code in JSON)` mean?
</blockquote>

<div style={{"marginTop":"1em", "marginBottom":"1em", "width":"90%"}}>
<img src="/images/docs/cloud/azure-datastudio-linechart.png" />
</div>

## Create a dashboard to analyze Azure resources

The Insight widget charts are the building blocks of the dashboard. Here we'll build a dashboard that monitors and analyzes Azure resources. To begin, create Insights with these three queries.

### Storage accounts with versioning disabled

```
select
  count(name)
from
  azure_storage_account
where
  not blob_versioning_enabled;
  ```

### Disk metric read ops daily

```
select
  name,
  timestamp,
  minimum,
  maximum,
  average,
  sample_count
from
  azure_compute_disk_metric_read_ops_daily
order by
  timestamp;
  ```

### List of unattached disks

```
select
  name,
  disk_state,
  sku_tier,
  time_created,
  encryption_type,
  network_access_policy
from
  azure_compute_disk
where
  disk_state = 'Unattached';
  ```
### Virtual machine count per region

```
select
  region,
  count(name)
from
  azure_compute_virtual_machine
group by
  region;
  ```

To build the dashboard add insight configuration(JSON code) to `dashboard.database.widgets` found under `User Settings`. To note here, Data Studio requires the queries to be saved in a `.sql` file with the `queryFile:` configuration property pointing at its path.

<blockquote>
> insight configuration(JSON code)

OK, I'm getting the impression this (JSON code) thing appears as a label on some piece of UX? If so, showing that will help explain this otherwise puzzling phrase.
</blockquote>

<div style={{"marginTop":"1em", "marginBottom":"1em", "width":"90%"}}>
<img src="/images/docs/cloud/azure-datastudio-widget-config.png" />
</div>

Once the settings are saved, right-click the database name and select `Manage` to display the Dashboard with the data.

<div style={{"marginTop":"1em", "marginBottom":"1em", "width":"90%"}}>
<img src="/images/docs/cloud/azure-datastudio-dashboard.png" />
</div>

## Summary

With Azure Data Studio and Steampipe Cloud you can:

- View tables in your Steampipe Cloud workspace

- Write custom queries to preview data from the tables in your Steampipe Cloud workspace

- Create insight widgets for dashboards driven by your custom queries