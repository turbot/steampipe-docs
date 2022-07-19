---
title: Table & Column Standards
sidebar_label: Table & Column Standards
---

# Steampipe Table & Column Standards

- [Naming](#naming)
- [Standard Columns](#standard-columns)
- [Data Types](#data-types)
- [Table and Column Descriptions](#table-and-column-descriptions)
- [Column Defaults and null](#column-defaults-and-null)
- [Standardized Structure](#standardized-structure)

## Naming
- Use snake_case for all table and column names.

- Table names are in the format `{plugin}_{service}_{resource_type}`.  Generally, table names should match the corresponding Terraform resource name.

- Use singular form (not plural) for table names, e.g. `aws_s3_bucket`, not `aws_s3_buckets`.

- For columns derived from nested object fields, the column should contain the path, snake cased.  For example `Foo.Bar.Baz` should will be in a column named `foo_bar_baz`:
    ```json
    "foo": {
        "bar": {
            "baz": "value"
        }
    }
    ```

- Use Terraform as a strong inspiration for field names, when to expand arrays, etc. Being consistent with Terraform is a desirable, and minimum position.  [Standard columns](#standard-columns) are an exception and should be consistent in our tables regardless of the Terraform name (they will very rarely conflict anyway)

- When naming columns for which there is no direct equivalent:
    - Where the field contains an arn or arns, explicitly suffix with `_arn`:
        - Good: `attached_policy_arns`
        - Bad: `attached_policies`
    - Where the field contains an id, explicitly suffix with `_id`:
        - Good: `aws_account_id`
        - Bad: `aws_account`
    - Where the field contains a name but references something that may also have an id or arn, explicitly suffix with `_name`:
        - Good: `role_name`
        - Bad: `role`


## Standard Columns
ALL tables that represent a resource should contain the following standard columns:

| Column Name | Data Type | Description
|-|-|-
| `title` | `ColumnType_STRING` | The display name for this resource.
| `akas` | `ColumnType_JSON` | A JSON array of AKAs (also-known-as) that uniquely identify this resource.  The format of the akas varies by plugin (arns in aws, resource paths for azure) but they must be unique and should be immutable.
| `tags` | `ColumnType_JSON` | The tags on this resource, **as a map of `key:value` pairs**.  Many resources support tags, though not all in the same format.  If the provider tags are in a different format, expose them in the native format in a `tags_raw` column, and convert them to `key:value` map in the `tags` column.  When tags are simple labels with no key:value (like github issue lables), use the format `label:true`.


You may choose to define additional standard columns that are specific to your plugin as well, and it is recommended to do so when appropriate.  For example, we define standard columns for our cloud provider plugins:
- AWS
    - `partition`
    - `account_id`
    - `region`
- Azure
    - `subscription_id`
    - `resource_group`
    - `region`
- Google
    - `project`
    - `location`

## Data Types
Use the appropriate <a href="/docs/develop/writing-plugins#column-data-types" target="_blank" rel="noopener">data type</a> so that you can search and filter intelligently.  Most of this is fairly self-explanatory but there are a couple items worth pointing out:
- Steampipe does not not support native Postgres arrays - use `ColumnType_JSON` for arrays
- There are 2 valid IP address formats, `ColumnType_IPADDR` and  `ColumnType_CIDR` which correspond to <a href="https://www.postgresql.org/docs/13/datatype-net-types.html" target="_blank" rel="noopener noreferrer">Postgres inet and cidr</a> data types:
    - Use `ColumnType_IPADDR` for single ip address  - `10.11.12.13`.
    - Use `ColumnType_IPADDR` when a file can either be a single single ip address OR a cidr range - `192.168.0.0/24`, `10.11.12.13`.
    - Use `ColumnType_CIDR` for cidr ranges that are ALWAYS represented as a cidr - `192.168.0.0/24`, `10.11.12.13/32`.
    - The essential difference between `ColumnType_IPADDR` and `ColumnType_CIDR` data types is that `ColumnType_IPADDR` accepts values with nonzero bits to the right of the netmask, whereas `ColumnType_CIDR` does not. For example, `192.168.0.1` is valid for `ColumnType_IPADDR` but not for `ColumnType_CIDR`.


## Table and Column Descriptions
- While technically optional, all tables and columns should contain a `Description`. This is added as a comment in the postgres schema and will be used:
    - To show more info within the cli in the `.inspect` command.
    - To generate help/reference documentation on <a href="https://hub.steampipe.io" target="_blank" rel="noopener">hub.steampipe.io</a>
- The descriptions should be pretty brief (1-2 sentences), and generally should be taken from the provider's API docs.
- The descriptions should start with a capital letter, and end with a period.

## Column Defaults and null
In general, use `null` when a field isn't present instead of setting a default.


## Standardized Structure

- Arrays should be stored in their native format as jsonb.

- Fields containing an array of deep and important information (e.g. security group rules) **may** be expanded into a separate table. For example, `aws_vpc_security_groups` has an associated table of `aws_vpc_security_group_rules`. Use this model when the data is both important to query and large in scale.

- Cloud providers sometimes store data in an array, even if they only ever have one value (e.g. AWS Subnet IPv6 CIDR Associations). In this case, you may choose to expand to columns as if there was a single object.
    - The original field (e.g. foo) should NOT be used, and should NOT have the full JSON array. Instead, we exclude the array data (it's noisy), but leave the field name available in case the provider actually uses an array in the future.
    - Generally, nested object fields like Foo.Bar.Baz are stored as foo_bar_baz - see [Naming](#naming)

- JSON objects should be stored as `ColumnType_JSON` (jsonb), not a delimited string. If the JSON contains sub-objects that are json as string, convert to json (for example inline policies in AWS roles).

- For JSON/YAML objects fields, if the raw format is also useful in itself (for example, the `template_body` in `aws_cloudformation_stack`), you may choose to create 2 columns:
    - `fieldname_src`: The string representation as `ColumnType_STRING`.
    - `fieldname`: The object representation as `ColumnType_JSON` (for joining, querying, etc).

- Some JSON/YAML fields may allow multiple schema formats to represent the same object.  For example, AWS IAM policies allow you to specify an array of `Action`s, or a single `Action` as a string, and are not case sensitive.  In such a case, it is often useful to convert all of these objects to the same format to simplify searching and filtering.  In such a case, you should keep the original object format in the `fieldname` column, and add an additional `fieldname_std` column in the standardized format.

- Some fields are base64 encoded in the cloud provider's API.  These can be evaluated on a case-by-case basis, but generally they should be decoded - If someone wants the column, they more than likely want to view or search the decoded text.

- Key columns should appear first, then the rest added alphabetically, then "standard" columns last.  Note that help  (`.inspect`, online docs) order the columns alphabetically regardless of the order in the `create table` statement.
