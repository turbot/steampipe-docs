---
title: Using AI
sidebar_label: Using AI
---

# Using AI

Creating new tables for Steampipe plugins with AI tools and IDEs works remarkably well, primarily because you're developing within existing plugin repositories that contain numerous examples of tables, documentation, and code patterns. AI can learn from these existing examples to generate high-quality, consistent implementations.

At Turbot, we develop plugin tables frequently and use AI for almost every new table we create. We've experimented with various approaches - detailed prompt engineering, explicit guidelines, IDE rules and instructions, and complex workflows - but found that AI typically produces excellent results even without heavy guidance, thanks to the rich context provided by existing plugin code and documentation.

## Why AI Works Well for Steampipe Development

The key to successful AI-assisted Steampipe development is **examples**. When working in an existing plugin repository, AI tools have access to:
- Multiple existing table implementations showing consistent patterns
- Comprehensive documentation examples demonstrating query patterns
- Established code structure and naming conventions
- Standard column definitions and data type usage

This context allows AI to understand and replicate the patterns without extensive prompting.

## Getting Started

We still recommend installing the [Steampipe MCP server](https://github.com/turbot/steampipe-mcp) to help test and validate your new tables during development.

## Example Prompts We Use

While AI often works well with simple requests like "create a table for [resource_type]", here are some prompts we use at Turbot that you may find helpful. Feel free to adapt them to your preferred style or use them as starting points.

These prompts are organized into stages that can be useful for breaking down the work, though you may find that a single prompt works just as well for your workflow.

You can use each prompt in one of several ways:
- Use the prompt directly
- Add them to your prompt context as files, e.g., [Cursor @Files](https://docs.cursor.com/context/@-symbols/@-files)
- Add them to your rules or instructions, e.g., [Cursor rules](https://docs.cursor.com/context/rules), [VS Code instructions or prompt files](https://code.visualstudio.com/docs/copilot/copilot-customization), [Windsurf rules](https://docs.windsurf.com/plugins/cascade/memories#rules)

## Prerequisites

Before you begin, ensure you have:
- Steampipe installed with a connection configured for the plugin
- Access to create resources in the provider (for testing, if needed)
- [Steampipe MCP server configured](https://github.com/turbot/steampipe-mcp) (recommended for testing)

## Create Table

First, create the new table and its documentation, using existing tables and docs as reference.

```
Your goal is to create a new Steampipe table and documentation for <resource_type>. This will involve implementing the table code and creating comprehensive documentation with example queries.

1. Review existing tables in the plugin to understand the established patterns, naming conventions, and column structures. This ensures your new table follows the same standards and integrates seamlessly.

2. Use `go doc` commands to understand the SDK's API structure for the resource type. This gives you the authoritative source for available fields and data types.

3. Create the table implementation with appropriate List/Get functions and any additional hydrate functions needed for extra API calls. Avoid hydrate functions that require paging as these belong in separate tables.

4. Register the new table in plugin.go in alphabetical order to maintain organization.

5. Create documentation at `docs/tables/<table_name>.md` with 4-5 practical example queries that specify columns and use `->` and `->>` operators. Include resource identifiers in non-aggregate queries to make examples actionable.
```

## Build Plugin

Next, build the plugin and verify your new table is properly registered.

```
Your goal is to build the plugin and verify that your new <resource_type> table is properly registered and functional. This validation step ensures the table can be queried before proceeding with testing.

1. Build the plugin using `make dev` if available, otherwise use `make`. This compiles your new table code into the plugin binary.

2. Check the Steampipe service status with `steampipe service status`. Start it with `steampipe service start` if not running, or restart it with `steampipe service restart` if already running. This ensures Steampipe picks up your new table.

3. Test if the Steampipe MCP server is available by running the `steampipe_table_list` tool. The MCP server provides the most convenient way to verify table registration and run test queries.

4. If the Steampipe MCP server is available, use it to verify the table exists in the schema and can be queried successfully.

5. If the MCP server is not available, verify table registration manually by querying the information schema with `steampipe query "SELECT column_name, data_type FROM information_schema.columns WHERE table_schema = '[plugin_name]' AND table_name = '[table_name]' ORDER BY ordinal_position"`, then test basic querying with `steampipe query "select * from [table_name]"`.
```

## Create Test Resources

To test the table's functionality, you'll need resources to query. You can either use existing resources or create new test resources with appropriate properties.

```
Your goal is to create test resources for <resource_type> to validate your Steampipe table implementation. Having actual resources with diverse properties ensures you can test all table columns and verify data accuracy.

1. Create the necessary resources using the provider's CLI if available, Terraform configuration if CLI isn't available, or API calls via shell script as a last resort. The provider's native tools typically offer the most reliable resource creation.

2. Configure the resources with as many properties set as possible to ensure comprehensive testing of all table columns. Rich resource configurations help validate that your table correctly maps all available data fields.

3. Use the most cost-effective configuration for the resources. If the estimated cost exceeds $500, warn about the expense rather than proceeding with creation.

4. Create any dependent resources required for the main resource to function properly. Many cloud resources have dependencies that must exist first.

5. Verify that all resources were created successfully using the same tool or method used for creation. This confirmation step ensures your test environment is ready before proceeding with table validation.
```

## Validate Column Data

Next, query the table to test that columns and data types are correctly implemented.

```
Your goal is to thoroughly test your <resource_type> table implementation by validating column data and executing documentation examples. This comprehensive testing ensures your table works correctly and provides accurate data.

1. Execute `select * from [table_name]` to validate that all columns return expected data based on the actual resource properties and have correct data types. This broad query reveals any fundamental issues with column mapping or data type conversions.

2. Test each example query from the table documentation to verify the SQL syntax is correct, queries execute without errors, and results match the example descriptions. Documentation examples serve as both user guidance and functional tests.

3. Share all test results in raw Markdown format to make them easy to export and review. Well-formatted results help identify any discrepancies and provide documentation of successful validation.

Use the Steampipe MCP server for running test queries if available, otherwise use the `steampipe` CLI commands directly.
```

## Cleanup Test Resources

After testing is completed, remove any resources created for testing.

```
Your goal is to clean up all test resources created for <resource_type> validation to avoid ongoing costs and maintain a clean environment. Proper cleanup prevents unnecessary charges and ensures your test environment doesn't accumulate abandoned resources.

1. Delete all resources created for testing, including any dependent resources that were created. Use the same method that was used to create the resources, as this ensures compatibility and completeness.

2. Verify that all resources were successfully deleted using the same tool or method used for creation and deletion. Confirmation prevents billing surprises and ensures the cleanup was thorough.
```