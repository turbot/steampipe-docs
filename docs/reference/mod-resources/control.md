---
title: control
sidebar_label: control
---

# control

**Controls** provide a defined structure and interface for queries that draw a specific conclusion (e.g. 'OK', 'Alarm') about each row (typically, each row represents a single evaluated 'block').  This pattern is common across multiple control benchmarks (CIS, etc) and  unit testing benchmarks (JUnit, NUnit, etc).

Controls use **queries** to gather data, but contain specific metadata and return specific columns with specified values in a specific format.  


## Example Usage

```hcl
control "cisv130_2_1_2" {
  title         = "2.1.2 Ensure S3 Bucket Policy allows HTTPS requests (Manual)"
  description   = "At the Amazon S3 bucket level, you can configure permissions through a bucket policy making the objects accessible only through HTTPS."
  documentation = file("docs/cisv130/2_1_2.md")
  sql           = query.s3_bucket_encryption_in_transit_control.sql

  tags = {
    cloud_provider = "aws" 
    framework      = "cis"
    cis_version    = "v1.3.0"
    cis_item_id    = "1.4"
    cis_control    = "4.3"
    cis_type       = "automated"
    cis_level      = "1"
  }

} 

``` 

You may run all controls in a group:

```bash
# run all the cis controls
steampipe check aws.benchmark.cisv130

# run all cis section 2 controls
steampipe check aws.benchmark.cisv130_2

# run all cis section 2.1 controls
steampipe check aws.benchmark.cisv130_2_1

```

## Argument Reference
| Argument | Type | Optional? | Description
|-|-|-|-
| `args` | Map | Optional| A map of arguments to pass to the query. The `args` argument may only be specified for controls that specify the `query` argument. 
| `description` | String| Optional| A description of the control.
| `documentation` | String (Markdown)| Optional | A markdown string containing a long form description, used as documentation for the mod on hub.steampipe.io. 
| `param` | Block | Optional| A [param](reference/mod-resources/query#param) block that defines the parameters that can be passed in to the control's query.  `param` blocks may only be specified for controls that specify the `sql` argument. 
| `query` | Query Reference | Optional | A reference to a [query](reference/mod-resources/query) resource that defines the control query to run.  The referenced query must conform to the control interface - it must return the [required control columns](#required-control-columns).  A control must either specify the `query` argument or the `sql` argument, but not both.
| `severity`| String | Optional | The potential impact of given control.  Allowed values are `none`,`low`,`medium`,`high`,`critical`. The severity names are taken from the [Common Vulnerability Scoring System version 3.1: Specification Document](https://www.first.org/cvss/specification-document).  This document may be used as guidance for classifying your controls.
| `sql` | String | Required | An SQL string that returns rows that conform to the control interface - it must return the [required control columns](#required-control-columns).  A control must either specify the `query` argument or the `sql` argument, but not both.
| `tags` | Map | Optional | A map of key:value metadata for the benchmark, used to categorize, search, and filter.  The structure is up to the mod author and varies by benchmark and provider. 
| `title` | String | Optional | Display title for the control.



#### Required Control Columns

ALL controls must specify queries that return rows that contain the following standard columns:

| Column | Type | Description
|-|-|-
| **status** | String | The control status for this row.  Only the defined [control statuses](#control-statuses) should be used.
| **reason** | String | A description that details WHY the row has the specified status.  The reason should always be set, even if the control is in an 'ok' state.  It should be a sentence ending with a period.
| **resource** | String | A unique identifier that identifies the targeted resource for this control check.  Ideally, this should be a ***globally unique identifier*** such as an arn.



##### Control Statuses

| Status | Description
|-|-
| **ok** | The control is compliant for the resource/row.
| **alarm** | The control is not compliant for the resource/row, and should be remediated.
| **skip** | This control was not evaluated because Steampipe was requested to skip it.
| **info** | This control is not automated.  The control may provide instructions to manually verify, and/or may provide additional context.
| **error** | Used when an error has occurred in calculating the control state.



#### Additional Control Columns & Dimensions
A control's query MUST return the required columns, but it may also return additional columns.  These additional columns are referred to as `dimensions`, and can be used to specify additional provider-specific columns that are included in control reports and outputs to provide additional context.  For example, a benchmark that runs controls against AWS resources may specify dimensions for `account_id` and `region` to help locate the evaluated resource.  The `account_id` and `region` columns will be added as dimensions to the control output for any control whose query returns those columns.

