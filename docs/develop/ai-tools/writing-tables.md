---
title: Writing Tables
sidebar_label: Writing Tables
---

# Writing Tables

To help you create new tables for Steampipe plugins, we have included suggested prompts and workflows you can use with your AI tools and IDEs.

We recommend breaking up the various steps across several prompts to keep them short and focused.

We also recommend installing the [Steampipe MCP server](https://github.com/turbot/steampipe-mcp) to help test running queries for your new table.

## Prerequisites

Before you begin, ensure you have:
- Steampipe installed and configured
- Familiarity with the provider's API or SDK
- Access to create resources in the provider (for testing)

## Create Table

First, create the new table and its documentation, using existing tables and docs as reference.

```
---
description: Use these rules when creating Steampipe tables and documentation
alwaysApply: false
---

# Steampipe Plugin Table Writing

Create a new table and documentation for the [resource type] using the following guidelines. 

## Table Guidelines

### References

- ALWAYS use the `go doc` command to get the API details from the SDK.
- ALWAYS review other tables for similar services and resources to learn Steampipe table standards and guidelines. 

### Hydrate Functions

- If there are any additional API calls that can be used to get data for the resource not available in the List/Get functions, add a hydrate function for each additional API call.
- If a non-List hydrate function requires paging, do not create that hydrate function as it belongs in a separate table to avoid throttling/rate limiting.

### Columns

- The table MUST include resource specific columns and standard plugin tables.

## Table Documentation Guidelines

- You MUST look at the example documentation to understand the format.
- Each table must have a document called `docs/tables/<table_name>.md`.
- Each table doc should show 4–5 useful, real-world example queries. Examples should specify columns, not just use `SELECT *`.
- Each example MUST include the resource id/name (friendly name preferred) for non-aggregate queries.
```

## Build Plugin and Verify Table Registration

Next, build the plugin and verify your new table is properly registered (even if you don't have resources created for it yet).

```
---
# Specify the following for Cursor rules
description: Guidelines for testing Steampipe tables
alwaysApply: false
---

# Testing Steampipe Plugin Tables

Build the plugin and verify the [resource type] table was properly registered using the following guidelines.

## Building Plugin

- Use `make dev` to compile a plugin if available, else use `make`.

## Start Steampipe Service

- Start the Steampipe service using `steampipe service start`.
- If the service is already running, restart it using `steampipe service restart`.

## Verify Table Registration

- Use the Steampipe MCP server to verify the table exists and can be queried successfully.
- If the Steampipe MCP server is not available, use `.inspect [table_name]` to verify the table exists and `steampipe query "select * from [table_name] "` to test querying.
```

## Create Resources

If you don't have any resources to query, you can create test resources to verify the table's column data is correct.

```
---
# Specify the following for Cursor rules
description: Guidelines for creating resources for testing Steampipe table queries
alwaysApply: false
---

# Create and Query Resources for Testing Steampipe Tables

Create resources for [resource type] and then verify the table returns the correct data.

## Create Resources

- Use the provider's CLI if available to create resources for the table.
  - If no CLI is available, then create a Terraform configuration file to create the resources.
  - If neither are available, then create and run a Shell script using the provider's API.
- The resource should be created with as many properties set as possible to help populate column data.
- If you need to create additional resources as dependencies, create them too.
- Use the same tool or output from the tool to verify the resources were created successfully.

## Verify Table Data

- Use the Steampipe MCP server to test queries. If the Steampipe MCP server is not available, use `steampipe` CLI commands.
- Run a query `select * from [table_name]` and verify:
  - All column data is returned as expected based on the resource's properties.
  - All column data have the correct types.

## Test Documentation Queries

- Run all queries in the table documentation to verify:
  - SQL syntax is correct
  - The returned data matches the example's title and description
- For all test results, share the query results in raw Markdown format.
```

## Cleanup

After testing, clean up any test resources you created.

```
---
# Specify the following for Cursor rules
description: Guidelines for cleaning up Steampipe testing resources
alwaysApply: false
---

# Clean Up Steampipe Testing Resources

Delete resources for [resource type] used for testing.

- All resources used for testing (including dependent resources) Steampipe tables MUST be deleted.
- Use the same method used to create the resources to also delete them.
- Verify the resources were successfully deleted by running queries that should return empty results.
```
