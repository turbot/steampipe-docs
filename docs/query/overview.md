---
title: Query Steampipe
sidebar_label: Query Steampipe
---

# Query Steampipe

Steampipe is built on [PostgreSQL](https://www.postgresql.org/), and you can use [standard SQL syntax](https://www..org/docs/14/sql.html) to query Steampipe. It's easy to [get started writing queries](/docs/sql/steampipe-sql), and the [Steampipe Hub](https://hub.steampipe.io/mods) provides ***thousands of example queries*** that you can use or modify for your purposes.  There are [example queries for each table](https://hub.steampipe.io/plugins/turbot/aws/tables/aws_s3_bucket) in every plugin, and you can also [browse, search, and view the queries](https://hub.steampipe.io/mods/turbot/aws_insights/queries) in every published mod!


## Interactive Query Shell
Steampipe provides an [interactive query shell](/docs/query/query-shell) that provides features like auto-complete, syntax highlighting, and command history to assist you in writing queries.

To open the query shell, run `steampipe query` with no arguments:

```bash
$ steampipe query
>
```

Notice that the prompt changes, indicating that you are in the Steampipe shell.

You can exit the query shell by pressing `Ctrl+d` on a blank line, or using the `.exit` command.


## Non-interactive (batch) query mode
The Steampipe interactive query shell is a great platform for exploring your data and developing queries, but Steampipe is more than just a query shell!

Steampipe allows you to [run a query in batch mode](/docs/query/batch-query) and write the results to standard output (stdout). This is useful if you wish to redirect the output to a file, pipe to another command, or export data for use in other tools.

To run a query from the command line, specify the query as an argument to steampipe query:
```bash
steampipe query "select vpc_id, cidr_block, state from aws_vpc"
```


## AI Tools (MCP)

The [Steampipe MCP server](/docs/query/mcp) transforms how you interact with your cloud infrastructure data.  It brings the power of conversational AI to your cloud resources and configurations, allowing you to extract critical insights using plain English — no complex SQL required!

The MCP is packaged separately and runs as an integration in your AI tool, such as [Claude Desktop](https://claude.ai/download) or [Cursor](https://www.cursor.com/).


## Third Party Tools
Because Steampipe is built on Postgres, you can [connect to the Steampipe database with 3rd party tools](/docs/query/third-party), or write code against your database using your favorite library!
