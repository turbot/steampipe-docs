---
title: Using AI
sidebar_label: Using AI
---

# Using AI

Creating new tables for Steampipe plugins with AI tools and IDEs works remarkably well. At Turbot, we develop plugin tables frequently and use AI for almost every new table we create. We've experimented with various approaches, including detailed prompt engineering, explicit guidelines, IDE rules and instructions, and complex workflows, but found that AI typically produces excellent results even without heavy guidance.

The key to this success is working within existing plugin repositories and opening the entire repository as a folder or project in your IDE. This gives AI tools access to existing table implementations, documentation examples, code patterns, and naming conventions to generate consistent, high-quality results without extensive prompting.

If you're looking to use AI to query Steampipe rather than develop new tables, you can use the [Steampipe MCP server](../query/mcp), which provides powerful tools for AI agents to inspect tables and run queries.

## Getting Started

While AI often works well with simple requests like "Create a table for <resource_type>", here are some prompts we use at Turbot that you may find helpful as starting points.

### Prerequisites

1. Open the plugin repository in your IDE (Cursor, VS Code, Windsurf, etc.) to give AI tools access to all existing code and documentation.
2. Ensure you have Steampipe installed with a connection configured for the plugin.
3. Set up access to create test resources in the provider.
4. Configure the [Steampipe MCP server](https://github.com/turbot/steampipe-mcp) which allows the agent to inspect tables and run queries.

### Create Table

First, create the new table and its documentation, using existing tables and docs as reference.

```md
Your goal is to create a new Steampipe table and documentation for <resource type>.

1. Review existing tables and their documentation in the plugin to understand the established patterns, naming conventions, and column structures.

2. Use `go doc` commands to understand the SDK's API structure for the resource type.

3. Create the table implementation with appropriate List/Get functions and any additional hydrate functions needed for extra API calls. Avoid hydrate functions that require paging as these belong in separate tables.

4. Register the new table in plugin.go in alphabetical order.

5. Create documentation at `docs/tables/<table_name>.md`.
  - For Postgres queries, use `->` and `->>` operators with spaces before and after instead of `json_extract` functions.
  - Include resource identifiers in non-aggregate queries.
```

### Build Plugin

Next, build the plugin with your changes and verify your new table is properly registered.

```md
Your goal is to build the plugin using the exact commands below and verify that your new <resource_type> table is properly registered and functional.

1. Build the plugin using `make dev` if available, otherwise use `make`.

2. Check the Steampipe service status with `steampipe service status`. Start it with `steampipe service start` if not running, or restart it with `steampipe service restart` if already running.

3. Test if the Steampipe MCP server is available by running the `steampipe_table_list` tool.

4. If the MCP server is available, use it to verify the table exists in the schema and can be queried successfully.

5. If the MCP server is not available, verify table registration manually with `steampipe query "select column_name, data_type from information_schema.columns where table_schema = '<plugin_name>' and table_name = '<table_name>' order by ordinal_position"`, then test basic querying with `steampipe query "select * from <table_name>"`.
```

### Create Test Resources

To test the table's functionality, you'll need resources to query. You can either use existing resources or create new test resources with appropriate properties.

```md
Your goal is to create test resources for <resource_type> to validate your Steampipe table implementation.

1. Create test resources with as many properties set as possible.
  - Use the provider's CLI if available, Terraform configuration if CLI isn't available, or API calls via shell script as a last resort.
  - Create any dependent resources needed.
  - Use the most cost-effective configuration. If the estimated cost is high, e.g., $50, warn about the expense rather than proceeding.

2. Verify that all resources were created successfully using the same tool or method used for creation.
```

### Validate Column Data

Next, query the table to test that columns and data types are correctly implemented.

```md
Your goal is to thoroughly test your <resource_type> table implementation by validating column data and executing documentation examples.

Use the Steampipe MCP server for running test queries if available, otherwise use the `steampipe` CLI commands directly.

1. Execute `select * from <table_name>` to validate that all columns return expected data based on the actual resource properties and have correct data types.

2. Test each example query from the table documentation to verify the SQL syntax is correct, queries execute without errors, and results match the example descriptions.

3. Share all test results in raw Markdown format to make them easy to export and review.
```

### Cleanup Test Resources

After testing is completed, remove any resources created for testing.

```md
Your goal is to clean up all test resources created for <resource_type> validation to avoid ongoing costs.

1. Delete all resources created for testing, including any dependent resources, using the same method that was used to create them.

2. Verify that all resources were successfully deleted, using the same method that was used to delete them.
```
