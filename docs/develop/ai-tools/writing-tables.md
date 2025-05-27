---
title: Writing Tables
sidebar_label: Writing Tables
---

# Writing Tables

To help you create new tables for Steampipe plugins, we have included suggested prompts and workflows you can use with your AI tools and IDEs.

We recommend using multiple prompts to create the table, build the plugin, and run test queries to allow specific context to be passed in at each step.

## Prerequisites

Before you begin, ensure you have:
- Steampipe installed with a connection configured for the plugin
- Access to create resources in the provider (for testing)
- [Steampipe MCP server configured](https://github.com/turbot/steampipe-mcp) (strongly recommended)

## Create Table

First, create the new table and its documentation, using existing tables and docs as reference.

```
---
# Specify the following for Cursor rules
description: Use these rules when creating Steampipe tables and documentation
alwaysApply: false
---

# Steampipe Plugin Table Writing

Create a new table and documentation for the [resource type] using the following guidelines.

## Table Guidelines

### References

- ALWAYS use the `go doc` command to get the API details from the SDK.
- ALWAYS review other tables for similar services and resources to learn Steampipe table standards and guidelines.

### Register Table

- The table MUST be registered in plugin.go.
- The table should be added to the list in alphabetical order.

### Hydrate Functions

- If there are any additional API calls that can be used to get data for the resource not available in the List/Get functions, add a hydrate function for each additional API call.
- If a non-List hydrate function requires paging, do not create that hydrate function as it belongs in a separate table to avoid throttling/rate limiting.

### Columns

- The table MUST include resource specific columns and standard plugin columns.

## Table Documentation Guidelines

- You MUST look at the example documentation to understand the format.
- Each table must have a document called `docs/tables/<table_name>.md`.
- Each table doc should show 4–5 useful, real-world example queries. Examples should specify columns, not just use `SELECT *`.
- Each example MUST include the resource id/name (friendly name preferred) for non-aggregate queries.
- Queries should use `->` and `->>` operators instead of `json_extract` functions.
```

## Build Plugin

Next, build the plugin and verify your new table is properly registered.

```
---
# Specify the following for Cursor rules
description: Guidelines for building Steampipe plugins and verifying table registration
alwaysApply: false
---

# Testing Steampipe Plugin Tables

Build the plugin and verify the [resource type] table was properly registered with the plugin using the following guidelines.

## Building Plugin

- Use `make dev` to compile a plugin if available, else use `make`.

## Start Steampipe Service

- Check if the Steampipe service is running with `steampipe service status`
  - If it's not running, start it using `steampipe service start`.
  - If it is already running, restart it using `steampipe service restart`.

## Verify Table Registration

- Test if the Steampipe MCP server is available by running the `steampipe_table_list` tool.
- If the Steampipe MCP server is available, you MUST use it to:
  - Verify the table exists in the schema.
  - Verify the table can be queried successfully.
- If the Steampipe MCP server is not available:
  - Use `steampipe query "SELECT column_name, data_type FROM information_schema.columns WHERE table_schema = '[plugin_name]' AND table_name = '[table_name]' ORDER BY ordinal_position"` to verify the table exists.
  - Use `steampipe query "select * from [table_name]"` to verify basic querying works.
```

## Create Test Resources

To test the table's functionality, you'll need resources to query. You can either use existing resources or create new test resources with appropriate properties.

```
---
# Specify the following for Cursor rules
description: Guidelines for creating resources for testing Steampipe table queries
alwaysApply: false
---

# Create Resources for Testing Steampipe Tables

Create test resources for [resource type] and confirm they were created successfully.

- Use the provider's CLI if available to create resources for the table.
  - If no CLI is available, create a Terraform configuration file to create the resources.
  - If neither are available, create and run a Shell script using the provider's API.
- Create the resource with as many properties set as possible to ensure comprehensive column data.
- Use the cheapest configuration for the resource.
- If the initial cost of creating the resource is very high, e.g, $500, do not create the resource and warn me instead.
- If you need to create additional resources as dependencies, create them too.
- Use the same tool or its output to confirm the resources were created successfully.
```

## Validate Column Data

Next, query the table to test that columns and data types are correctly implemented.

```
---
# Specify the following for Cursor rules
description: Guidelines for querying Steampipe tables to verify column data is correct
alwaysApply: false
---

# Testing Table Data and Queries

Test the implementation for [resource type] by querying resources and validating column data.

## Validate Column Data

- Use the Steampipe MCP server to run test queries. If the Steampipe MCP server is not available, use `steampipe` CLI commands.
- Execute `select * from [table_name]` and validate:
  - All columns return expected data based on the resource properties.
  - All columns have the correct data types.

## Test Documentation Examples

- Execute all queries from the table documentation to verify:
  - SQL syntax is correct and queries run without errors.
  - Result data matches the example's title and description.
- Share all test results in raw Markdown format to make them easy to export.
```

## Cleanup Test Resources

After testing is completed, remove any resources created for testing.

```
---
# Specify the following for Cursor rules
description: Guidelines for deleting resources used for testing Steampipe table queries
alwaysApply: false
---

# Delete Test Resources

Remove all [resource type] resources used for testing.

- All resources used for testing (including dependent resources) MUST be deleted.
- Use the same method used to create the resources to delete them.
- Verify the resources were deleted using the same method as well.
```
