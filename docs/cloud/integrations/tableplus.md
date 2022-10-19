---
title: Connect to Steampipe Cloud from TablePlus
sidebar_label: TablePlus
---
# Connect to Steampipe Cloud from TablePlus

[TablePlus](https://tableplus.com/) is a SQL IDE to query, edit and manage your databases.

Since the Steampipe Cloud workspace is a PostgreSQL database, you can directly connect TablePlus to your workspace and query the database.

The [Connect](/docs/cloud/integrations/overview) tab for your workspace provides the details you need to connect TablePlus to Steampipe Cloud.

<img src="/images/docs/cloud/steampipe-cloud-connection.png" />

Once the connection to Steampipe cloud is established and tested, you can access the tables provided by the Steampipe plugins, run queries and build reports.

## Getting started

[TablePlus](https://tableplus.com/download) is available on the desktop and the free version can be used without any need for account creation. In this example we will create a Steampipe Cloud connection with TablePlus and query the AWS EC2 SSL policies.

To establish a new connection click on `Create a new connection`, select PostgreSQL and click create. Once the PostgreSQL connection screen pops up, enter the Steampipe Cloud connection details and click on `Test` to verify the connection. To note here, the default SSL mode for TablePlus is set to `Preferred` which can be changed if needed but it will fail to create a connection when the SSL mode is set to DISABLED.

<img src="/images/docs/cloud/tableplus-connection-success.png" />

Once you've connected to Steampipe Cloud, you can access the AWS plugin and its tables from the namespace provided at the bottom left of the window.

<img src="/images/docs/cloud/tableplus-namespace-selection.png" />

Now select and run the `aws_ec2_ssl_policy` table. TablePlus will display the table's schema and preview the data. You may also choose to export the data in a csv, json or sql format if needed.

<img src="/images/docs/cloud/tableplus-ec2-ssl-data-preview.png" />

## Run your first custom query

TablePlus comes with the SQL query editor that you may use to write a custom query. For example, we can use the below query in the editor to fetch the S3 buckets with default encryption disabled

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

<img src="/images/docs/cloud/tableplus-custom-query-result.png" />

## Connect to Steampipe CLI from TablePlus

You can connect TablePlus to [Steampipe CLI](https://steampipe.io/downloads). To do so, run `steampipe service start --show-password` and use the displayed connection details.

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
