---
title: Connect to Steampipe Cloud from DBT
sidebar_label: DBT
---
## Connect to Steampipe Cloud from DBT

[DBT](https://www.getdbt.com/) is a SQL-first IDE to query, edit and manage your databases.

Steampipe provides a single interface to all your cloud, code, logs and more. Because it's built on Postgres, Steampipe provides an endpoint that any Postgres-compatible client -- including DBT -- can connect to.

The [Connect](/docs/cloud/integrations/overview) tab for your workspace provides the details you need to connect DBT to Steampipe Cloud.

<div style={{"marginTop":"1em", "marginBottom":"1em", "width":"90%"}}>
<img src="/images/docs/cloud/steampipe-cloud-connect-details.jpg" />
</div>

Once the connection to Steampipe cloud is established and tested, you can explore the Steampipe plugins, run queries and build reports.

You can also connect DBT to [Steampipe CLI](https://steampipe.io/downloads). To do that, run `steampipe service start --show-password` and use the displayed connection details.

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

[[DBT](https://docs.getdbt.com/docs/get-started/getting-started/overview) is available to use on the desktop and the cloud. To use it, create an account and select a DBT cloud plan -- here we use the free [developer plan](https://www.getdbt.com/pricing/). In this example we will create a Steampipe Cloud connection from DBT and query the top stories by score from hackernews_top.

Since DBT projects include [version control](https://docs.getdbt.com/docs/collaborate/git-version-control), it requires linking your git repository with write access enabled through `linked accounts` under `account settings`. Next, Select PostgreSQL under `Credentials` to create a new connection and enter the Steampipe Cloud connection details, click `Test Connection` to `Verify`.

<div style={{"marginTop":"1em", "marginBottom":"1em", "width":"90%"}}>
<img src="/images/docs/cloud/dbt-pg-connect.png" />
</div>

Once you've connected to Steampipe Cloud, paste this query and click compile. DBT then previews the data in a table form which can also be saved in a `.csv` file.

```
select
  *
from
  hackernews_top
order by
  score desc
  ```

<div style={{"marginTop":"1em", "marginBottom":"1em", "width":"90%"}}>
<img src="/images/docs/cloud/dbt-query-data-preview.png" />
</div>