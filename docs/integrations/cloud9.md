---
title: Using Steampipe in AWS Cloud9
sidebar_label: AWS Cloud9
---
# Using Steampipe in AWS Cloud9

[AWS Cloud9](https://aws.amazon.com/cloud9/) is a cloud-based IDE integrated with a code editor, debugger, and terminal that enables you to write, run, and debug your code with a browser. Steampipe seamlessly integrates to enable querying of AWS resources and creation of Steampipe dashboards.

## Installing Steampipe in AWS Cloud9

To install Steampipe, paste this command in your AWS Cloud9 terminal.

```
sudo /bin/sh -c "$(curl -fsSL https://raw.githubusercontent.com/turbot/steampipe/main/install.sh)"
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

## Visualize Steampipe Dashboards with AWS Cloud9

[Steampipe dashboards](https://steampipe.io/docs/dashboard/overview) provide rich visualizations of Steampipe data. Here, we will use the [AWS Well-Architected Mod](https://hub.steampipe.io/mods/turbot/aws_well_architected) to develop a dashboard to check adherence to the best practices defined by the AWS Well-Architected Framework. To get started, install the mod by pasting this command.

```
git clone https://github.com/turbot/steampipe-mod-aws-well-architected
cd steampipe-mod-aws-well-architected
```

Then, execute the following command to install the mod's dependencies.

```
steampipe mod install
```

After installing the mod and its dependencies, start the dashboard server with this command.

```
steampipe dashboard  --dashboard-port 8080
```

AWS Cloud9 only allows `port 8080` to be opened for a local host, so use the `--dashboard-port` flag to specify that port.

Now click on `Preview`, select `Preview Running Application` to view the dashboard, then click `Reliability Pillar`.

<div style={{"marginBottom":"2em","borderWidth":"thin", "borderStyle":"solid", "borderColor":"lightgray", "padding":"20px", "width":"100%"}}>
<img alt="well-architected-dashboard-preview" src="/images/docs/ci-cd-pipelines/cloud9-well-architected-dashboard-preview.png" />
</div>

Alternatively, you can run the benchmark in the AWS Cloud9 terminal: `steampipe check benchmark.reliability`.

That's it! Now you use Cloud9 to query and create dashboards using Steampipe's [plugins](https://hub.steampipe.io/plugins) and [mods](https://hub.steampipe.io/mods).
