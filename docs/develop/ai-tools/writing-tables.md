---
title: Writing Tables
sidebar_label: Writing Tables
---

# Writing Tables

When creating a new table, we have included some prompts below that you can use with your AI tools.

## Create Table

```
---
# Specify the following for Cursor rules
description: Guidelines for writing Steampipe tables
alwaysApply: false
---

# Writing Steampipe Tables

You are an expert in Steampipe, Steampipe plugins, and Postgres. Use the following guidelines when creating Steampipe tables and documentation.

## General

- ALWAYS use the `go doc` command to get the API details first.
- If supported, list operations should implement limits to control result set size.
- The plugin should properly handle rate limiting wtih retries.

## Table Structure

- All tables MUST start with the prefix `<plugin>_`, e.g., `aws_`, `azure_`, `oci_`.
- Table names should follow the pattern `<plugin>_<service>_<resource>`, e.g., `aws_s3_bucket`, `azure_compute_virtual_machine`, `oci_identity_authentication_policy`.
- If a provider does not have distinct services, the table names should follow the pattern `<plugin>_<resource>`, e.g., `github_repository`, `pagerduty_incident`.
- Each table should implement standard configurations:
  - `List` - Retrieve multiple resources.
  - `Get` - Retrieve a single resource by ID or name.
  - `GetMatrixItemFunc` - Usually includes additional hierarchy enumeration, e.g., region, resource group, compartment.

## Common Implementation Patterns

- Tables should the service's Go SDK to call API endpoints.
- Tables should include both applicable hierarchy matrix items.
- Key columns are defined in the table's List and Get configs.
- Determine from the SDK if pagination is possible for any List calls, and if so, implement it using the maximum page size.

## Columns

- The table MUST include resource specific columns and standard plugin tables.

## Standard Columns

All tables include these common columns:

- `compartment_id` - The OCID of the compartment
- `tenant_id` - The OCID of the tenant
- **ALWAYS** Use the `commonColumnsForAllResource()` function in he column definition.

## Documentation Structure

Documentation for each OCI table includes:

1. Title and description
2. Table usage guide
3. Multiple SQL examples with both PostgreSQL and SQLite syntax
4. Filter columns section explaining column qualifiers
5. Complete columns list with types and descriptions

## Query Optimization

For optimal query performance:

- Always include `compartment_id` when possible
- Use region-specific queries when targeting specific resources
- Filter by ID when retrieving individual resources
- Use appropriate lifecycle states to narrow results
```

## Testing

```
---
# Specify the following for Cursor rules
description: Guidelines for testing Steampipe tables
alwaysApply: false
---

You are an expert in Steampipe, Steampipe plugins, and Postgres. Use the following guidelines when testing Steampipe tables and documentation.

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

- All resources used for testing (including dependent resources) MUST be deleted.
- Use the provider's CLI if available to delete the resources.
  - If no CLI is available, create and run a Shell script using the provider's API.
```