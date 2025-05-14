---
title: Writing Tables
sidebar_label: Writing Tables
---

# Writing Tables

When creating a new table, we have included some prompts below that you can use with your AI tools.

## Create Table

For all tables, include the following prompt:

```
---
# Specify the following for Cursor rules
description: Guidelines for writing Steampipe tables
alwaysApply: false
---

# Writing Steampipe Tables

You are an expert in Steampipe, Steampipe plugins, and Postgres. Use the following guidelines when creating Steampipe tables.

## General

- Each table must have a document called `<provider>/table_<table_name>.go`.
- ALWAYS use the `go doc` command to get the API details first.

## Error Handling

- Use `ShouldIgnoreErrorFunc` in `GetConfig` to gracefully handle expected errors (e.g., resource not found).
- Return errors as soon as they are encountered to avoid partial or misleading results.
- Add comments to clarify why certain errors are ignored or handled in a specific way.

## Logging

- Always log errors with sufficient context, including the function name, error type, error message, and any related arguments, using `plugin.Logger(ctx).Error(...)`.
- When returning errors, include the location and any related args, along with the error itself.

## Pagination and Limits

- Implement pagination for all list operations using the SDK's paginator when available.
- Respect the `QueryContext.Limit` parameter to avoid returning more rows than requested, but also handle API minimums (e.g., AWS EC2 requires a minimum of 5 for `MaxResults`).
- Use the `RowsRemaining(ctx)` check to stop processing when the requested row limit is reached.
- If a non-List hydrate function requires paging, consider moving that data to a separate table to avoid throttling/rate limiting.

## Rate Limiting

- Use `d.WaitForListRateLimit(ctx)` in list functions to respect Steampipe's rate limiting and avoid API throttling.
- Be aware of provider-specific rate limits and implement retries or backoff strategies as needed.
- Use Steampipe plugin SDK's `RetryHydrate` if the API SDK doesn't handle backoff/retry.
- Set `HydrateConfig.MaxConcurrency` for hydrate functions if the API has strict rate limits.
- Document any rate limiting considerations or custom logic in code comments for maintainability.

## Hydrate Functions

- Use hydrate functions for columns that require additional API calls, and only fetch extra data when those columns are queried.
- Group related hydrate functions in `HydrateConfig` for clarity and maintainability.
- Ensure hydrate functions are efficient and avoid unnecessary API calls.
- Document the purpose of each hydrate function, especially if it handles special cases or provider-specific logic.
- List hydrate functions should check for remaining rows and abort loops if there are none.

## Column Definitions

- Use `Transform` functions to extract or format data as needed (e.g., `transform.FromField("State.Name")`).
- Set a preferred transform as the default for columns (e.g., `transform.FromGo().NullIfZero()`).
- Provide clear and concise descriptions for each column to improve usability and documentation. Descriptions must adhere to the [Table and Column Descriptions Standards](https://steampipe.io/docs/develop/standards#table-and-column-descriptions).
- Use appropriate column types (`STRING`, `INT`, `BOOL`, `TIMESTAMP`, `IPADDR`, `JSON`) to match the data being returned. Represent money as a string, not a double.
- Include resource IDs and names as key columns for easy identification and querying.
- Add an `arn` column for AWS resources, using a hydrate function to construct it if not directly available.
- Include a `tags` column (or equivalent) and provide a transform function to convert provider-specific tag structures into a simple key-value map.

## Matrix Items and Regionality

- Use `GetMatrixItemFunc` to support multi-region or multi-account enumeration where applicable.
- Use helper functions like `awsRegionalColumns()` to add standard columns for region/account.
- Ensure that matrix items are included in both List and Get operations when required by the provider.
- Document any assumptions or requirements about matrix items in code comments for clarity.

## Utility and Helper Functions

- Encapsulate filter-building and value-extraction logic in utility functions for reuse and clarity.
- Use helper functions to keep table definitions concise and maintainable.
- Place utility functions near the end of the file or in a shared location if used across multiple tables.
- Document the purpose and usage of each utility function, especially if it handles provider-specific logic or edge cases.

## Table Structure

- All tables MUST start with the prefix `<plugin>_`, e.g., `aws_`, `azure_`, `oci_`.
- Table names should follow the pattern `<plugin>_<service>_<resource>`, e.g., `aws_s3_bucket`, `azure_compute_virtual_machine`, `oci_identity_authentication_policy`.
- If a provider does not have distinct services, the table names should follow the pattern `<plugin>_<resource>`, e.g., `github_repository`, `pagerduty_incident`.
- Each table should implement standard configurations:
  - `List` - Retrieve multiple resources.
  - `Get` - Retrieve a single resource by ID or name.
  - `GetMatrixItemFunc` - Usually includes additional hierarchy enumeration, e.g., region, resource group, compartment.
- If the API provides both global and per-authenticated-user data, create separate tables (e.g., `github_repository` and `github_my_repository`).
- If tables share columns, abstract them into a common structure (see AWS plugin's common_columns.go).

## Common Implementation Patterns

- Tables should the service's Go SDK to call API endpoints.
- Tables should include both applicable hierarchy matrix items.
- Key columns are defined in the table's List and Get configs.
- See the 'Pagination and Limits' section below for guidance on implementing pagination and respecting query limits in List calls.

## Columns

- The table MUST include resource specific columns and standard plugin tables.

## Standard Columns

All tables include these common columns:

- `compartment_id` - The OCID of the compartment
- `tenant_id` - The OCID of the tenant
- **ALWAYS** Use the `commonColumnsForAllResource()` function in he column definition.
```

### Additional Plugin Prompts

Adding extra rules and context can be helpful per plugin. Several examples for popular plugins have been added below.

### OCI Plugin

```
---
# Specify the following for Cursor rules
description: Guidelines for writing Steampipe OCI plugin tables
alwaysApply: false
---

# Writing Steampipe OCI Plugin Tables

You are an expert in Steampipe, Steampipe plugins, and Postgres. Use the following guidelines when creating Steampipe OCI plugin tables.

## Standard Columns

All tables include these common columns:

- `compartment_id` - The OCID of the compartment
- `tenant_id` - The OCID of the tenant
- **ALWAYS** Use the `commonColumnsForAllResource()` function in he column definition.
```

## Documentation

```
---
# Specify the following for Cursor rules
description: Guidelines for writing Steampipe table documentation
alwaysApply: false
---

# Writing Steampipe Table Documentation

You are an expert in Steampipe, Steampipe plugins, and Postgres. Use the following guidelines when creating Steampipe documentation.

### Guidelines

- Each table must have a document called `docs/tables/<table_name>.md`.
- Each table doc should show 4–5 useful, real-world example queries. Most examples should specify columns, not just use `SELECT *`.
- If some columns are required, call them out and explain why.
- Each example MUST include the resource id/name (friendly name preferred) for non-aggregate queries.
- Provide example queries for each table, including at least one that uses the resource id or name (preferably a friendly name) for non-aggregate queries.
- Document any non-obvious implementation details, API limitations, or special behaviors in code comments and in the documentation file.
- Reference similar or related tables as examples where appropriate (e.g., link to `aws_ec2_instance` or `github_repository` docs).

### Examples

- `aws_ec2_instance`: https://github.com/turbot/steampipe-plugin-aws/blob/main/docs/tables/aws_ec2_instance.md
- `github_repository`: https://github.com/turbot/steampipe-plugin-github/blob/main/docs/tables/github_repository.md
```

## Testing

```
---
# Specify the following for Cursor rules
description: Guidelines for testing Steampipe tables
alwaysApply: false
---

# Testing Steampipe Tables

You are an expert in Steampipe, Steampipe plugins, and Postgres. Use the following steps when testing Steampipe tables and documentation.

## Build

- Build the plugin locally by running the command `make dev`.

## Create Resources

- Use the provider's CLI if available to create resources for the table.
  - If no CLI is available, create and run a Shell script using the provider's API.
- The resource should be created with as many properties set as possible to help populate column data. 
- If you need to create additional resources as dependencies, create them too.
- Use the CLI to verify the resources were created successfully.

## Start Steampipe Service

- Start the Steampipe service using `steampipe service start`.
- If the service is already running, restart it using `steampipe service restart`.

## Query

- You MUST use the Steampipe MCP server to test the tables.
- For all test results, share the query results in raw Markdown format.
- Run a query `select * from <table>` and verify:
  - All column data is returned as expected.
  - All column data have the correct types.
- Next, run all queries in the table documentation.
```

## Cleanup

```
---
# Specify the following for Cursor rules
description: Guidelines for cleaning up testing resources
alwaysApply: false
---

# Clean Up Testing Resources

- All resources used for testing (including dependent resources) MUST be deleted.
- Use the provider's CLI if available to delete the resources.
  - If no CLI is available, create and run a Shell script using the provider's API.
```
