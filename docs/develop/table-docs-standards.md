---
title: Table Documentation Standards
sidebar_label: Table Documentation Standards
---

# Table Documentation Standards

- [Overview](#overview)
- [Description Guidelines](#description-guidelines)
- [Example Query Guidelines](#example-query-guidelines)

## Overview

Creating table documentation is an important part of developing tables, as each
document provides basic table information and example queries that appear on
the <a href="https://hub.steampipe.io" target="_blank" rel="noopener">Steampipe Hub</a>. These
example queries are especially important, as they are often the first thing a
user will run to explore and understand a new table.

Every table should have a Markdown document with a filename derived from the
table name, e.g., `docs/tables/aws_acm_certificate.md` for
`table_aws_acm_certificate.go`.

Each document should include:
- A header with the table name, e.g., `# Table: aws_s3_bucket`
- A basic description
- An `## Examples` section with multiple example queries

For example, here's a table document for the `aws_s3_bucket` table:
````markdown
# Table: aws_s3_bucket

An Amazon S3 bucket is a public cloud storage resource available in Amazon Web
Services' (AWS) Simple Storage Service (S3), an object storage offering.

## Examples

### Basic info

```sql
select
  name,
  region,
  account_id,
  bucket_policy_is_public
from
  aws_s3_bucket;
```

### List buckets with versioning disabled

```sql
select
  name,
  region,
  account_id,
  versioning_enabled
from
  aws_s3_bucket
where
  not versioning_enabled;
```

### List buckets with default encryption disabled

```sql
select
  name,
  server_side_encryption_configuration
from
  aws_s3_bucket
where
  server_side_encryption_configuration is null;
```
````

When the plugin is packaged and deployed to the Steampipe Registry, this <a
href="https://github.com/turbot/steampipe-plugin-aws/blob/main/docs/tables/aws_s3_bucket.md"
target="_blank" rel="noopener noreferrer">Markdown file</a> will be included in the plugin documentation
on the <a
href="https://hub.steampipe.io/plugins/turbot/aws/tables/aws_s3_bucket"
target="_blank" rel="noopener">Steampipe Hub</a>.

## Description Guidelines

### Style Conventions

- Descriptions should be short (1-3 sentences) and provide basic information on the table and its resource type
- All sentences in the description should have the first word capitalized and end with a period
  - Good
    - `An AWS IAM user is an entity that you create in AWS to represent the person or application that uses it to interact with.`
  - Bad: The first letter should be capitalized and the sentence should end with a period
    - `an AWS IAM user is an entity that you create in AWS to represent the person or application that uses it to interact with`
- References to resource names should follow the provider's documentation on capitalization
  - Good
    - `An AWS S3 bucket is a public cloud storage resource in AWS.`
  - Bad: "Bucket" should not be capitalized
    - `An AWS S3 Bucket is a public cloud storage resource in AWS.`

## Example Query Guidelines

### Basic Info Example

The first example in each document should be a basic info query. This example
query should select commonly used columns from the table and should only
contain the `select` and `from` keywords.

Example:
````markdown
### Basic info

```sql
select
  instance_id,
  instance_type,
  region
from
  aws_ec2_instance;
```
````

### Additional Examples

After the basic info query, there should be a few (but at least one) additional
example queries that provide an interesting view of the table data. For more
information on creating additional example queries, please see <a
href="/docs/develop/writing-example-queries" target="_blank" rel="noopener">Writing Example
Queries</a>.

### Style Conventions

- Use H3 (`###`) for example query descriptions, e.g., `### List my resources`
- Use <a href="https://www.freeformatter.com/sql-formatter.html" target="_blank" rel="noopener noreferrer">SQL Formatter</a> to format all SQL queries
  - Indentation level should be set to `2 spaces per indent level`
  - SQL keywords and identifiers should be set to `Modify to lower case`
  - Please test your queries after formatting them in case unexpected changes are made
- Example descriptions should be in the imperative mood, e.g., `List buckets that are...`, `Count the number of instances...`
  - Good
    - `### List unecrypted databases`
    - `### List users named foo`
  - Bad: Should use "List" instead of "Listing"
    - `### Listing unecrypted databases`
  - Bad: Should not include "of"
    - `### List of users named foo`
- Example descriptions should use the plural form of the resource name if the query can return more than 1 row
  - Good
    - `### List unecrypted instances`
    - `### Get the instance with a specific resource ID`
  - Bad: "instance" should be the plural form "instances"
    - `### List unecrypted instance`
  - Bad: "instances" should be singular since only one row can be returned
    - `### Get the instances with a specific resource ID`
- Example descriptions should follow the provider's documentation on capitalization for resource and property names
  - Good
    - `### List instances with termination protection disabled`
  - Bad: "Instances" should not be capitalized
    - `### List Instances with termination protection disabled`
- Do not include the service name in descriptions unless its required to differentiate similarly named tables
  - Good
    - `### List buckets in us-east-1`
  - Bad: Should not include "S3"
    - `### List S3 buckets in us-east-1`
