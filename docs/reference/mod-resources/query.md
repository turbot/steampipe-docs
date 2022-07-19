---
title: query
sidebar_label: query
---


# query
Queries define common SQL statements that may be used alone, or referenced by arguments in other blocks like reports and actions.

Note that a Steampipe `query` is NOT a database resource. It does not create a view, stored procedure, etc.  `query` blocks are interpreted by and executed by Steampipe, and are only available from Steampipe, not from 3rd party tools.

Steampipe queries can only be run as-is. They cannot appear inside other queries, you cannot `select` from them or add qualifiers to them. 

## Example Usage

```hcl
query "plus_size_instances" {
  title = "EC2 Instances xlarge and bigger"
  sql = "select * from aws_ec2_instance where instance_type like '%xlarge'"
}
```

```hcl
query "s3_bucket_encryption_in_transit_control" {
  description  = "Ensure S3 Bucket Policy forces HTTPS"
  sql          = <<-EOI
    with ok_buckets as(
          select 
            distinct(name)
          from
            aws_s3_bucket,    
            jsonb_array_elements(policy_std -> 'Statement') as s,
            jsonb_array_elements_text(s -> 'Principal' -> 'AWS') as p,
            jsonb_array_elements_text(s -> 'Condition' -> 'Bool' -> 'aws:securetransport') as ssl
            where
            p = '*'
            and s ->> 'Effect' = 'Deny'
            and ssl :: bool = false 
    ) 
    select
      case
        when name in (select name from ok_buckets)
        then 'OK'
        else 'ALARM'
      end as "status",
      case
        when name in (select name from ok_buckets)
        then 'HTTPS is enforced in the bucket policy'
        else 'HTTPS is not enforced in the bucket policy'
      end as "reason",      
      name as resource,
      account_id,
      partition,
      region
    from
      aws_s3_bucket;
    EOI 
}
```


In the Steampipe query shell or in a non-interactive `steampipe query` command, you can run a query by its fully qualified name:

```sql
> aws_ec2_reports.query.prohibited_instance_types 
```

```bash 
$ steampipe query "aws_ec2_reports.query.plus_size_instances"
```




## Argument Reference

| Argument |Type | Required? | Description
|-|-|-|-
| `sql` | String | Required | SQL statement to define the query.
| `description` | String |  Optional| A description of the query.
| `documentation` | String (Markdown)| Optional | A markdown string containing a long form description, used as documentation for the mod on hub.steampipe.io. 
| `param` | Block | Optional| A [param](#param) block that defines the parameters that can be passed in to the control's query.  `param` blocks may only be specified for controls that specify the `sql` argument. 
| `search_path` | String | Optional| A schema search path to use for this query.
| `search_path_prefix` | String | Optional| A schema to prefer for this query.
| `tags` | Map | Optional | A map of key:value metadata for the benchmark, used to categorize, search, and filter.  The structure is up to the mod author and varies by benchmark and provider. 
| `title` | String | Optional | A display title for the query.


#### param
One or more param blocks may optionally be used in a query or control to define parameters for the query.  Note that the SQL statement only supports positional arguments (`$1`, `$2`, ...) and that the param blocks are assigned in order -- the first param block describes `$1`, the second describes `$2`, etc.

| Name | Type| Description
|-|-|-
| `description` | String | A description of the parameter.
| `default`     | Any | A value to use if no argument is passed for this parameter when the query is run.


```hcl
 variable "max_access_key_age" {
  type = number
}

query "old_access_keys" {
  sql = <<-EOT
    select
      access_key_id,
      user_name,
      create_date,
      age(create_date) as age
    from
      aws_iam_access_key
    where
      create_date < NOW() - ($1 || ' days')::interval
      ; 
  EOT
  param "max_days" {
    default     = var.max_access_key_age
    description = "The maximum allowed key age, in days."
  } 
}
```