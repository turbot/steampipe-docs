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
- Each example MUST include the resource id/name (friendly name preferred) for non-aggregate queries.

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