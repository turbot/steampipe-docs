---
title: Connect to Steampipe Cloud from Gitpod
sidebar_label: Gitpod
---
## Connect to Steampipe Cloud from Gitpod

[Gitpod](https://www.gitpod.io/) is an open source platform that provisions ready-to-code developer environments with a rich catalog of extensions, some of which can connect to databases.

Steampipe provides a single interface to all your cloud, code, logs and more. Because it's built on Postgres, Steampipe provides an endpoint that any Postgres-compatible client -- including Gitpod database extensions -- can connect to.

The [Connect](/docs/cloud/integrations/overview) tab for your workspace provides the details you need to connect Gitpod to Steampipe Cloud.

<div style={{"marginTop":"1em", "marginBottom":"1em", "width":"90%"}}>
<img src="/images/docs/cloud/steampipe-cloud-connect-details.jpg" />
</div>

Once Steampipe Cloud is successfully connected, you can explore the tables provided by the Steampipe plugins, run queries and build reports.

##  Connect to Steampipe CLI from Gitpod

You can also connect Gitpod to [Steampipe CLI](https://steampipe.io/downloads). To do that, run `steampipe service start --show-password` and use the displayed connection details.

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

There are a number of Gitpod extensions that connect to and query databases. For this example we'll use [SQLTools PostgreSQL](https://open-vsx.org/extension/mtxr/sqltools-driver-pg).

To create a connection via the command palette, choose `Add New Connection`, select PostgreSQL and add the connection details.

<div style={{"marginTop":"1em", "marginBottom":"1em", "width":"90%"}}>
<img src="/images/docs/cloud/gitpod-connect-details.png" />
</div>

Once you're connected to Steampipe Cloud, the SQLTools Explorer can access the tables available in your workspace. Here we'll use the RSS connection and use this query to list items from a feed. Gitpod previews the data which can be exported into a JSON or CSV format.

```
select
  title,
  published,
  link
from
  rss_item
where
  feed_link = 'https://www.hardcorehumanism.com/feed/'
order by
  published desc;
  ```

<div style={{"marginTop":"1em", "marginBottom":"1em", "width":"90%"}}>
<img src="/images/docs/cloud/gitpod-data-preview.png" />
</div>