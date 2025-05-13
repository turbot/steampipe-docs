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

### Example

```
---
title: "Steampipe Table: aws_ec2_instance - Query AWS EC2 Instances using SQL"
description: "Allows users to query AWS EC2 Instances for comprehensive data on each instance, including instance type, state, tags, and more."
folder: "EC2"
---

# Table: aws_ec2_instance - Query AWS EC2 Instances using SQL

The AWS EC2 Instance is a virtual server in Amazon's Elastic Compute Cloud (EC2) for running applications on the Amazon Web Services (AWS) infrastructure. It provides scalable computing capacity in the AWS cloud, eliminating the need to invest in hardware up front, so you can develop and deploy applications faster. With EC2, you can launch as many or as few virtual servers as you need, configure security and networking, and manage storage.

## Table Usage Guide

The `aws_ec2_instance` table in Steampipe provides you with information about EC2 Instances within AWS Elastic Compute Cloud (EC2). This table allows you, as a DevOps engineer, to query instance-specific details, including instance state, launch time, instance type, and associated metadata. You can utilize this table to gather insights on instances, such as instances with specific tags, instances in a specific state, instances of a specific type, and more. The schema outlines the various attributes of the EC2 instance for you, including the instance ID, instance state, instance type, and associated tags.

## Examples

### List instances whose detailed monitoring is not enabled
Determine the areas in which detailed monitoring is not enabled for your AWS EC2 instances. This is useful for identifying potential blind spots in your system's monitoring coverage.

```sql+postgres
select
  instance_id,
  monitoring_state
from
  aws_ec2_instance
where
  monitoring_state = 'disabled';
```

```sql+sqlite
select
  instance_id,
  monitoring_state
from
  aws_ec2_instance
where
  monitoring_state = 'disabled';
```

### Count the number of instances by instance type
Determine the distribution of your virtual servers based on their configurations, allowing you to assess your resource allocation and optimize your infrastructure management strategy.

```sql+postgres
select
  instance_type,
  count(instance_type) as count
from
  aws_ec2_instance
group by
  instance_type;
```

```sql+sqlite
select
  instance_type,
  count(instance_type) as count
from
  aws_ec2_instance
group by
  instance_type;
```

### List instances stopped for more than 30 days
Determine the areas in which AWS EC2 instances have been stopped for over 30 days. This can be useful for identifying and managing instances that may be unnecessarily consuming resources or costing money.

```sql+postgres
select
  instance_id,
  instance_state,
  launch_time,
  state_transition_time
from
  aws_ec2_instance
where
  instance_state = 'stopped'
  and state_transition_time <= (current_date - interval '30' day);
```

```sql+sqlite
select
  instance_id,
  instance_state,
  launch_time,
  state_transition_time
from
  aws_ec2_instance
where
  instance_state = 'stopped'
  and state_transition_time <= date('now', '-30 day');
```

### List EC2 instances having termination protection safety feature enabled
Identify instances where the termination protection safety feature is enabled in EC2 instances. This is beneficial for preventing accidental terminations and ensuring system stability.

```sql+postgres
select
  instance_id,
  disable_api_termination
from
  aws_ec2_instance
where
  not disable_api_termination;
```

```sql+sqlite
select
  instance_id,
  disable_api_termination
from
  aws_ec2_instance
where
  disable_api_termination = 0;
```

### List the unencrypted volumes attached to the instances
Identify instances where data storage volumes attached to cloud-based virtual servers are not encrypted. This is useful for enhancing security measures by locating potential vulnerabilities where sensitive data might be exposed.

```sql+postgres
select
  i.instance_id,
  vols -> 'Ebs' ->> 'VolumeId' as vol_id,
  vol.encrypted
from
  aws_ec2_instance as i
  cross join jsonb_array_elements(block_device_mappings) as vols
  join aws_ebs_volume as vol on vol.volume_id = vols -> 'Ebs' ->> 'VolumeId'
where
  not vol.encrypted;
```

```sql+sqlite
select
  i.instance_id,
  json_extract(vols.value, '$.Ebs.VolumeId') as vol_id,
  vol.encrypted
from
  aws_ec2_instance as i,
  json_each(i.block_device_mappings) as vols
  join aws_ebs_volume as vol on vol.volume_id = json_extract(vols.value, '$.Ebs.VolumeId')
where
  not vol.encrypted;
```

### Get subnet details for each instance
Explore the association between instances and subnets in your AWS environment. This can be helpful in understanding how resources are distributed and for planning infrastructure changes or improvements.

```sql+postgres
select 
  i.instance_id, 
  i.vpc_id, 
  i.subnet_id, 
  s.tags ->> 'Name' as subnet_name
from 
  aws_ec2_instance as i, 
  aws_vpc_subnet as s 
where 
  i.subnet_id = s.subnet_id;
```

```sql+sqlite
select 
  i.instance_id, 
  i.vpc_id, 
  i.subnet_id, 
  json_extract(s.tags, '$.Name') as subnet_name
from 
  aws_ec2_instance as i, 
  aws_vpc_subnet as s 
where 
  i.subnet_id = s.subnet_id;
```
```
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