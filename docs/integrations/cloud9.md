---
title: Using Steampipe in AWS Cloud9
sidebar_label: AWS Cloud9
---
# Using Steampipe in AWS Cloud9

[AWS Cloud9](https://aws.amazon.com/cloud9/) is a cloud-based IDE integrated with a code editor, debugger, and terminal that enables you to write, run, and debug your code with a browser. Steampipe seamlessly integrates to enable querying of AWS resources and creation of Steampipe dashboards.

## Installing Steampipe in AWS Cloud9

To install Steampipe, paste this command in your AWS Cloud9 terminal.

```
sudo /bin/sh -c "$(curl -fsSL https://raw.githubusercontent.com/turbot/steampipe/main/scripts/install.sh)"
```

<div style={{"marginBottom":"2em","borderWidth":"thin", "borderStyle":"solid", "borderColor":"lightgray", "padding":"20px", "width":"100%"}}>
<img alt="cloud9-install-steampipe" src="/images/docs/ci-cd-pipelines/cloud9-install-steampipe.png" />
</div>

## Query AWS resources

To query AWS resources using Steampipe, first install the [AWS plugin](https://hub.steampipe.io/plugins/turbot/aws) with this command.

```
steampipe plugin install aws
```

Because Cloud9 includes the AWS CLI and knows your credentials, you can immediately run SQL queries to retrieve data from hundreds of Postgres tables supported by the plugin. This query retrieves public access details for S3 buckets in your account.

```sql
select
  region,
  block_public_acls,
  bucket_policy_is_public,
  ignore_public_acls,
  restrict_public_buckets,
  block_public_policy,
  name
from
  aws_s3_bucket;
```

<div style={{"marginBottom":"2em","borderWidth":"thin", "borderStyle":"solid", "borderColor":"lightgray", "padding":"20px", "width":"100%"}}>
<img alt="s3-public-access-preview" src="/images/docs/ci-cd-pipelines/cloud9-s3-public-access-preview.png" />
</div>