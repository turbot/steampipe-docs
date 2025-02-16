---
title:  It's Just Postgres!
sidebar_label:  It's Just Postgres!
---

# It's Just Postgres!

Because Steampipe is built on Postgres, you can export your data, connect to the Steampipe database with 3rd party tools, or write code against your database using your favorite library.  

By default, when you run `steampipe query`, Steampipe will start the database and shut it down at the end of the query command or session. To connect from third party tools, you must run `steampipe service start` to start steampipe in [service mode](/docs/managing/service).

Once the service is started, you can connect to the Steampipe from tools that integrate with Postgres, such as [TablePlus](https://tableplus.com/)!


<img alt="Query your data with 3rd part tools like TablePlus" src="/table_plus.png" width="100%" />

<br />
<br />


To stop the Steampipe service, issue the `steampipe service stop` command.


