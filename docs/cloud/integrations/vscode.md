---
title: Connect to Steampipe Cloud from VS Code
sidebar_label: VS Code
---
## Connect to Steampipe Cloud from VS Code

[VS Code](https://code.visualstudio.com/) is a source code editor with support for several languages and runtimes.

The Steampipe Cloud workspace is a postgres database that can be directly connected with VS Code to query your database. The connection can be made using a query tool for PostgreSQL databases available from the extension marketplace.

The [Connect](/docs/cloud/integrations/overview) tab for your workspace provides the details you need to connect VS Code to Steampipe Cloud.

<div style={{"marginTop":"1em", "marginBottom":"1em", "width":"90%"}}>
<img src="/images/docs/cloud/steampipe-cloud-connect-details.jpg" />
</div>

Once Steampipe Cloud is successfully connected, you can explore the tables provided by the Steampipe plugins, run queries and build reports.

## Getting started

[VS Code](https://code.visualstudio.com/download) installs and runs on the desktop. In this example we will create a Steampipe Cloud connection with VS code using a PostgreSQL extension from Chris Kolkman which is pretty simple and straight forward to query the database.

To create a connection via the command palette, enter `PostgreSQL: Add Connection` and add the connection details.

<div style={{"marginTop":"1em", "marginBottom":"1em", "width":"90%"}}>
<img src="/images/docs/cloud/vscode-add-connection.png" />
</div>

Once you're connected to Steampipe Cloud, you can access the installed plugins and its tables from the PostgreSQL explorer. Here we use the AWS plugin. Now select and run the `aws_ebs_volume` table. VS Code will display the table's schema and preview the data. The data can be exported in a json, xml and csv format if required.

<div style={{"marginTop":"1em", "marginBottom":"1em", "width":"90%"}}>
<img src="/images/docs/cloud/vscode-ebs-volume-data.png" />
</div>

## Run your first custom query

VS Code lets you write custom queries through the SQL query editor. For example, we can use the below query in the editor to fetch the list of enabled AWS regions.

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

## Connect to Steampipe CLI from VS Code

Similarly, you can connect VS Code to [Steampipe CLI](https://steampipe.io/downloads). To do so, run `steampipe service start --show-password` and use the displayed connection details.

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
