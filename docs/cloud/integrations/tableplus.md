---
title: Connect to Steampipe Cloud from TablePlus
sidebar_label: TablePlus
---
## Connect to Steampipe Cloud from TablePlus

[TablePlus](https://tableplus.com/) is a SQL IDE to query, edit and manage your databases.

Steampipe provides a single interface to all your cloud, code, logs and more. Because it's built on Postgres, Steampipe provides an endpoint that any Postgres-compatible client -- including TablePlus -- can connect to.

The [Connect](/docs/cloud/integrations/overview) tab for your workspace provides the details you need to connect TablePlus to Steampipe Cloud.

<div style={{"marginTop":"1em", "marginBottom":"1em", "width":"90%"}}>
<img src="/images/docs/cloud/steampipe-cloud-connect-details.jpg" />
</div>

Once the connection to Steampipe cloud is established and tested, you can access the tables provided by the Steampipe plugins, run queries and build reports.

You can also connect TablePlus to [Steampipe CLI](https://steampipe.io/downloads). To do that, run `steampipe service start --show-password` and use the displayed connection details.

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

[TablePlus](https://tableplus.com/download) is available on the desktop and the free version can be used without any need for account creation. In this example we will create a Steampipe Cloud connection with TablePlus and query the AWS EC2 SSL policies.

To establish a new connection click on `Create a new connection`, select PostgreSQL and click Create. Once the PostgreSQL connection screen pops up, enter the Steampipe Cloud connection details and click `Test` to verify the connection. To note here, the default SSL mode for TablePlus is set to `Preferred` which can be changed if needed but it will fail to create a connection when the SSL mode is set to DISABLED.

<div style={{"marginTop":"1em", "marginBottom":"1em", "width":"90%"}}>
<img src="/images/docs/cloud/tableplus-connection-success.png" />
</div>

Once you've connected to Steampipe Cloud, you can access the AWS plugin and its tables from the namespace provided at the bottom left of the window.

<div style={{"marginTop":"1em", "marginBottom":"1em", "width":"50%"}}>
<img src="/images/docs/cloud/tableplus-namespace-select.png" />
</div>

Now select and run the `aws_ec2_ssl_policy` table. TablePlus will display the table's schema and preview the data. You may also choose to export the data in a CSV, JSON or SQL format if needed.

<div style={{"marginTop":"1em", "marginBottom":"1em", "width":"90%"}}>
<img src="/images/docs/cloud/tableplus-ec2-ssl-data-preview.png" />
</div>

## Run your first custom query

TablePlus comes with a SQL query editor that you may use to write a custom query. For example, we can use this query in the editor to fetch the S3 buckets with default encryption disabled

```
select
  name,
  region,
  server_side_encryption_configuration
from
  aws_s3_bucket
where
  server_side_encryption_configuration is null;
  ```

<div style={{"marginTop":"1em", "marginBottom":"1em", "width":"90%"}}>
<img src="/images/docs/cloud/tableplus-custom-query-results.png" />
</div>