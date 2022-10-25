---
title: Connect to Steampipe Cloud from VS Code
sidebar_label: VS Code
---
## Connect to Steampipe Cloud from VS Code

[VS Code](https://code.visualstudio.com/) is a source code editor with a rich catalog of extensions, some of which can connect to databases.

Steampipe provides a single interface to all your cloud, code, logs and more. Because it's built on Postgres, Steampipe provides an endpoint that any Postgres-compatible client -- including VS Code database extensions -- can connect to.

The [Connect](/docs/cloud/integrations/overview) tab for your workspace provides the details you need to connect VS Code to Steampipe Cloud.

<div style={{"marginTop":"1em", "marginBottom":"1em", "width":"90%"}}>
<img src="/images/docs/cloud/steampipe-cloud-connect-details.jpg" />
</div>

Once Steampipe Cloud is successfully connected, you can explore the tables provided by the Steampipe plugins, run queries and build reports.

Similarly, you can also connect VS Code to [Steampipe CLI](https://steampipe.io/downloads). To do that, run `steampipe service start --show-password` and use the displayed connection details.

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

There are a number of VS Code extensions that connect to and query databases. For this example we'll use [Chris Koklman's extension](https://marketplace.visualstudio.com/items?itemName=ckolkman.vscode-postgres).

To create a connection via the command palette, choose `PostgreSQL: Add Connection` and add the connection details.

<div style={{"marginTop":"1em", "marginBottom":"1em", "width":"90%"}}>
<img src="/images/docs/cloud/vscode-add-connection.png" />
</div>

Once you're connected to Steampipe Cloud, the PostgreSQL Explorer can access the tables available in your workspace. Here we'll use the AWS connection and query the `aws_ebs_volume` table. VS Code displays the table's schema and previews its data. You can export the data to JSON, XML, or CSV.

<div style={{"marginTop":"1em", "marginBottom":"1em", "width":"90%"}}>
<img src="/images/docs/cloud/vscode-ebs-volume-data.png" />
</div>

## Run your first custom query

Use the query editor to write and run custom queries. This query fetches the list of enabled AWS regions.

```
select
  name,
  opt_in_status
from
  aws_region
where
  opt_in_status = 'not-opted-in';
  ```

<div style={{"marginTop":"1em", "marginBottom":"1em", "width":"90%"}}>
<img src="/images/docs/cloud/vscode-custom-query-result.png" />
</div>