---
title: Using Steampipe in AWS Cloud9
sidebar_label: AWS Cloud9
---
# Using Steampipe in AWS Cloud9

[AWS Cloud9](https://aws.amazon.com/cloud9/) is a cloud-based IDE integrated with a code editor, debugger, and terminal that lets you write, run, and debug your code with a browser. Steampipe seamlessly integrates to enable querying of AWS resources and generating Steampipe dashboards.

## Installing Steampipe in AWS Cloud9

To install Steampipe, simply paste this command in your AWS Cloud9 terminal.

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

The plugin installation is swift due to the AWS CLI and credential integration into the terminal. You can instantly create SQL queries to retrieve data from hundreds of Postgres tables supported by the plugin. This query retrieves public access specifics of S3 buckets in your account.

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

[Steampipe dashboards](https://steampipe.io/docs/dashboard/overview) provide rich visualizations of Steampipe data. Here, we will leverage the [AWS Well-Architected Mod](https://hub.steampipe.io/mods/turbot/aws_well_architected) to develop a dashboard for verifying adherence to the best practices of the AWS Well-Architected Framework in the account. To get started, paste this command to install the mod.

```
git clone https://github.com/turbot/steampipe-mod-aws-well-architected
cd steampipe-mod-aws-well-architected
```

Then, execute the following command to install the mod's dependencies.

```
steampipe mod install
```

After installing the mod and its dependencies, initiate the dashboard server by executing this command. As AWS Cloud9 only allows `port 8080` to be opened for a local host, the `--dashboard-port` flag is utilized to specify the port number.

```
steampipe dashboard  --dashboard-port 8080
```

Click on `Preview`, select `Preview Running Application` to view the dashboard and click on `Reliability Pillar`.

<div style={{"marginBottom":"2em","borderWidth":"thin", "borderStyle":"solid", "borderColor":"lightgray", "padding":"20px", "width":"100%"}}>
<img alt="well-architected-dashboard-preview" src="/images/docs/ci-cd-pipelines/cloud9-well-architected-dashboard-preview.png" />
</div>

Likewise, you can also run the benchmark within the AWS Cloud9 terminal with `steampipe check benchmark.reliability`.

That's it! Now you can query and create dashboards using Steampipe's [plugins](https://hub.steampipe.io/plugins) and [mods](https://hub.steampipe.io/mods) in your AWS Cloud9 Environment.
