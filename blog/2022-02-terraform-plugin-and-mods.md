---
id: sql-queries-and-compliance-checks-for-terraform-files
title: "SQL queries + compliance checks for Terraform files"
category: Featured Plugin
description: "Steampipe's Terraform plugin makes your .tf files queryable with SQL. A trio of new mods, for AWS/Azure/GCP, use the plugin to run compliance controls. Now you can check what you've defined as well as what you've deployed!"
summary: ""
author:
  name: Jon Udell
  twitter: "@judell"
publishedAt: "2022-02-21T14:00:00"
durationMins: 7
image: "/images/blog/2022-02-terraform-plugin-and-mods/opener.png"
slug: sql-queries-and-compliance-checks-for-terraform-files
schema: "2021-01-08"
---

Steampipe provides a trio of mods that check your deployed [AWS](https://hub.steampipe.io/mods/turbot/aws_compliance), [Azure](https://hub.steampipe.io/mods/turbot/azure_compliance), and [GCP](https://hub.steampipe.io/mods/turbot/gcp_compliance) infrastructure for compliance with frameworks such as CIS, HIPAA, NIST 800, and SOC 2.

If you're using Terraform to define that infrastructure, there's now a companion trio of mods that run compliance controls -- again for [AWS](https://hub.steampipe.io/mods/turbot/terraform_aws_compliance), [Azure](https://hub.steampipe.io/mods/turbot/terraform_azure_compliance), and [GCP](https://hub.steampipe.io/mods/turbot/terraform_gcp_compliance) -- that check that your defined infrastructure complies with best practices.

The mods that check deployed infrastructure use cloud APIs, provided by the [AWS](https://hub.steampipe.io/plugins/turbot/aws), [Azure](https://hub.steampipe.io/plugins/turbot/azure), and [GCP](https://hub.steampipe.io/plugins/turbot/gcp) plugins, to query your environments in realtime. The mods that check Terraform-defined infrastructure rely on a single plugin, [Terraform](https://hub.steampipe.io/plugins/terraform), which turns the HCL code in your `.tf` files into data that you can query with SQL. 

To explore how these Terraform compliance mods work, we'll use the examples from [https://github.com/futurice/terraform-examples](https://github.com/futurice/terraform-examples). Here's the initial setup.

```
cd ~
git clone https://github.com/turbot/steampipe-mod-terraform-aws-compliance.git
git clone https://github.com/futurice/terraform-examples.git
```
## Running a S3 control on Terraform files in a directory

The `terraform_aws_compliance` mod defines 39 benchmarks, based on 153 controls and 153 named queries.  First, we'll run a single control, [S3 bucket object lock should be enabled](https://hub.steampipe.io/mods/turbot/terraform_aws_compliance/controls/control.s3_bucket_object_lock_enabled?context=benchmark.s3), on the examples in one subdirectory of the repo.

```
cd ~/terraform-examples/aws/aws_static_site
steampipe check --workspace-chdir ~/steampipe-mod-terraform-aws-compliance \
  control.s3_bucket_object_lock_enabled --export output.md
```

By default the Terraform plugin looks for `.tf` files in the current directory. The `--workspace-chdir` argument points to the directory into which we cloned the `terraform_aws_compliance` mod that defines the `s3_bucket_object_lock_enabled` control.

Here's the Markdown output.

<img width="80%" src="/images/blog/2022-02-terraform-plugin-and-mods/object-lock-enabled.png" />

<br/>

`s3.tf` fails to comply with the policy enforced by the control. How does Steampipe define that policy? Here's the control.

```
control "s3_bucket_object_lock_enabled" {
  title         = "S3 bucket object lock should be enabled"
  description   = "Ensure that your Amazon Simple Storage Service (Amazon S3) bucket has lock enabled, by default."
  sql           = query.s3_bucket_object_lock_enabled.sql
}
```

It refers to this [named query](https://hub.steampipe.io/mods/turbot/terraform_aws_compliance/queries/s3_bucket_object_lock_enabled).

```
select
  type || ' ' || name as resource,
  case
    when coalesce(trim(arguments -> 'object_lock_configuration' ->> 'object_lock_enabled'), '') = 'Enabled' then 'ok'
    else 'alarm'
  end status,
  name || case
    when (arguments -> 'object_lock_configuration' -> 'object_lock_enabled') is null then ' ''object_lock_enabled'' is not defined'
    when (arguments -> 'object_lock_configuration' ->> 'object_lock_enabled') = 'Enabled' then ' object lock enabled'
    else ' object lock not enabled'
  end || '.' reason,
  path
from
  terraform_resource
where
  type = 'aws_s3_bucket';
```

Steampipe expects `.tf` files that provision S3 buckets to include an argument like this.

```
object_lock_configuration = {
  object_lock_enabled = "Enabled"
}
```

We'll fix the problem by adding the argument to the `aws_s3_bucket` resource, then repeat the check.

```
steampipe check --workspace-chdir ~/steampipe-mod-terraform-aws-compliance \ 
  control.s3_bucket_object_lock_enabled --export output.md
```

All good now!

<img width="80%" src="/images/blog/2022-02-terraform-plugin-and-mods/object-lock-enabled-fixed.png" />

## Querying HCL with SQL

The Terraform compliance mods use the Terraform plugin to query `.tf` files. These mods provide a rich catalog of named queries. The mods run those queries for you, but you can also run them directly in Steampipe. 

For our next examples, let's include all the subdirectories of the repo. To do that, we'll edit `~/.steampipe/config/terraform.spc` and set `paths = ["~/terraform-examples/**/*.tf"]` to match all Terraform files in `~/terraform-examples` and its subdirectories.

The Terraform plugin defines these tables.

<ul><li><a href="https://hub.steampipe.io/plugins/turbot/terraform/tables/terraform_data_source">terraform_data_source</a></li><li><a href="https://hub.steampipe.io/plugins/turbot/terraform/tables/terraform_local">terraform_local</a></li><li><a href="https://hub.steampipe.io/plugins/turbot/terraform/tables/terraform_output">terraform_output</a></li><li><a href="https://hub.steampipe.io/plugins/turbot/terraform/tables/terraform_provider">terraform_provider</a></li><li><a href="https://hub.steampipe.io/plugins/turbot/terraform/tables/terraform_resource">terraform_resource</a></li></ul>

At each of those links you'll find yet more sample queries. And you can also easily write your own queries.  Here's a query that extracts `assume_role_policy` statements from `aws_iam_role` resources.

```
select
  name,
  replace(path, '/home/jon/terraform-examples/','') as path,
  jsonb_array_elements (
    (arguments ->> 'assume_role_policy')::jsonb -> 'Statement'
  ) as Statement
from
  terraform_resource
where
  type = 'aws_iam_role'
```

```
+---------------------+---------------------------------------+--------------------------------------------------------------------------------------------------------------------------+
| name                | path                                  | statement                                                                                                                |
+---------------------+---------------------------------------+--------------------------------------------------------------------------------------------------------------------------+
| this                | aws/aws_lambda_cronjob/permissions.tf | {"Action":"sts:AssumeRole","Effect":"Allow","Principal":{"Service":["lambda.amazonaws.com"]}}                            |
| this                | aws/aws_lambda_api/permissions.tf     | {"Action":"sts:AssumeRole","Effect":"Allow","Principal":{"Service":["lambda.amazonaws.com","edgelambda.amazonaws.com"]}} |
| this                | aws/aws_reverse_proxy/lambda.tf       | {"Action":"sts:AssumeRole","Effect":"Allow","Principal":{"Service":["lambda.amazonaws.com","edgelambda.amazonaws.com"]}} |
| KafkaClientIAM_Role | aws/aws_vpc_msk/msk-client.tf         | {"Action":"sts:AssumeRole","Effect":"Allow","Principal":{"Service":"ec2.amazonaws.com"},"Sid":""}                        |
| task_execution_role | aws/wordpress_fargate/fargate.tf      | {"Action":"sts:AssumeRole","Effect":"Allow","Principal":{"Service":["ecs-tasks.amazonaws.com"]}}                         |
| task_role           | aws/wordpress_fargate/fargate.tf      | {"Action":"sts:AssumeRole","Effect":"Allow","Principal":{"Service":["ecs-tasks.amazonaws.com"]}}                         |
+---------------------+---------------------------------------+--------------------------------------------------------------------------------------------------------------------------+
```

Here's one that counts resources by type.

```
select 
  count(*),
  type
from
  terraform_resource
group by 
  type
order by 
  count desc
```

```
+-------+---------------------------------------------+
| count | type                                        |
+-------+---------------------------------------------+
| 13    | aws_route53_record                          |
| 12    | null_resource                               |
| 11    | google_bigquery_table                       |
| 9     | local_file                                  |
| 8     | google_project_iam_member                   |
| 7     | aws_security_group                          |
| 7     | aws_iam_role_policy_attachment              |
| 7     | google_storage_bucket_object                |
| 6     | aws_security_group_rule                     |
| 6     | aws_lambda_function                         |
| 6     | aws_iam_role                                |
| 5     | aws_iam_policy                              |
| 5     | google_cloudfunctions_function              |
| 5     | google_service_account                      |
| 4     | google_pubsub_topic                         |
| 4     | google_cloud_run_service                    |
| 4     | google_bigquery_dataset                     |
| 3     | azurerm_key_vault_access_policy             |
... etc ...
```
## Querying deployed and defined infrastructure

For deployed infrastructure, Steampipe's compliance mods support these frameworks with a combined total of 1,120 named queries and 770 controls:

- AWS: Audit Manager Control Tower, AWS Foundational Security Best Practices, CIS, GDPR, HIPAA, NIST 800-53, NIST CSF, PCI DSS, RBI Cyber Security Framework and SOC 2.

- Azure: CIS, HIPAA HITRUST and NIST

- GCP: CIS, Forseti Security and CFT Scorecard

- Kubernetes: NSA and CISA Kubernetes Hardening Guidance

For defined infrastructure, the new set of compliance mods delivers an additional 359 queries and 359 controls. We think the ability to query both deployed and defined resources is unique and powerful. We hope you'll give it a try, and look forward to hearing your feedback on [Twitter](https://twitter.com/steampipeio) or [Slack](https://steampipe.io/community/join).
