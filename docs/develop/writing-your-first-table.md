---
title: Writing Your First Table
sidebar_label:  Writing Your First Table
---


# Writing Your First Table

The <a href="https://github.com/turbot/steampipe-plugin-sdk"
target="_blank" rel="noopener noreferrer">Steampipe Plugin SDK</a> makes writing tables fast, easy, and
fun! This guide will walk you through building the AWS plugin locally, testing
a minor change, and then how to start creating a new table.

## Prerequisites

- Install <a href="https://golang.org/doc/install" target="_blank" rel="noopener noreferrer">Golang</a>
- Install <a href="/downloads" target="_blank">Steampipe</a>

## Clone the Repository

1. Clone the <a href="https://github.com/turbot/steampipe-plugin-aws" target="_blank" rel="noopener noreferrer">Steampipe Plugin AWS repository</a>:

  ```bash
  git clone https://github.com/turbot/steampipe-plugin-aws.git
  cd steampipe-plugin-aws
  ```

## Build and Run Locally

1. Copy the default `config/aws.spc` into `~/.steampipe/config`. If not using the default AWS profile, please see <a href="https://hub.steampipe.io/plugins/turbot/aws" target="_blank" rel="noopener">AWS plugin</a> for more information on connection configuration.

  ```bash
  cp config/aws.spc ~/.steampipe/config/aws.spc
  ```
2. Run `make` to build the plugin locally and install the new version to your `~/.steampipe/plugins` directory:

  ```bash
  make
  ```
3. Launch the Steampipe query shell:

  ```bash
  steampipe query
  ```
4. Test basic functionality:

  ```sql
  .inspect aws
  select name, region from aws_s3_bucket;
  ```

## Make Your First Change

1. Edit the `aws/table_aws_s3_bucket.go` table file.
2. Locate the definition for the `name` column:

  ```go
  {
    Name:        "name",
    Description: "The user friendly name of the bucket.",
    Type:        proto.ColumnType_STRING,
  },
  ```
3. Copy the code above and create a duplicate column `name_test`:

  ```go
  {
    Name:        "name_test",
    Description: "Testing new column.",
    Type:        proto.ColumnType_STRING,
    Transform:   transform.FromField("Name"),
  },
  ```
4. Save your changes in `aws/table_aws_s3_bucket.go`.
5. Run `make` to re-build the plugin:

  ```bash
  make
  ```
6. Launch the Steampipe query shell:

  ```bash
  steampipe query
  ```
7. Test your changes by inspecting and querying the new column:

  ```sql
  .inspect aws_s3_bucket
  select name, name_test, region from aws_s3_bucket;
  ```
8. The `name` and `name_test` columns should have the same data in them for each bucket.
9. Undo your changes in `aws/table_aws_s3_bucket.go` once done testing:

  ```bash
  git restore aws/table_aws_s3_bucket.go
  make
  ```

## Create a New Table

1. Create a new file in `aws/`, copying an existing table and following the table naming standards in <a href="/docs/develop/standards#naming" target="_blank" rel="noopener">Steampipe Table & Column Standards</a>:

  ```bash
  cp aws/table_aws_s3_bucket.go aws/table_aws_new_table.go
  ```
2. Check if the AWS service has a service connection function in `aws/service.go` already; if not, add a new function in `aws/service.go`.
3. Add an entry for the new table into the `TableMap` in `aws/plugin.go`. For more information on this file, please see <a href="/docs/develop/writing-plugins#plugingo" target="_blank" rel="noopener">Writing Plugins - plugin.go</a>.
5. Update the code in your new table so the table returns the correct information for its AWS resource.
4. Add a document for the table in `docs/tables/` following the <a href="/docs/develop/table-docs-standards" target="_blank" rel="noopener">Table Documentation Standards</a>.

## References

- <a href="/docs/develop/standards" target="_blank" rel="noopener">Steampipe Table & Column Standards</a>
- <a href="/docs/develop/table-docs-standards" target="_blank" rel="noopener">Table Documentation Standards</a>
- <a href="/docs/develop/writing-example-queries" target="_blank" rel="noopener">Writing Example Queries</a>
- <a href="/docs/develop/coding-standards" target="_blank" rel="noopener">Coding Standards</a>
