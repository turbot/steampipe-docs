---
id: control-cost-with-aws-thrifty
title: "Use Steampipe to identify cost savings in AWS"
category: Cost Control
description: "An introduction to AWS Thrifty, a mod that finds underutilized AWS resources."
summary: "An introduction to AWS Thrifty, a mod that finds underutilized AWS resources."
author:
  name: Jon Udell
  twitter: "@judell"
publishedAt: "2022-03-31T14:00:00"
durationMins: 5
image: "/images/blog/2022-04-mod-aws-thrifty-themes/opener.png"
slug: control-cost-with-aws-thrifty
schema: "2021-01-08"
---

The suite of Steampipe mods includes a half-dozen that focus on [cost control](https://hub.steampipe.io/mods?objectives=cost). These mods check for idle compute instances, unused volumes, stale backups, and more. Here we'll focus on [AWS Thrifty](https://hub.steampipe.io/mods/turbot/aws_thrifty), but all Thrifty mods follow the same pattern.

## Install the plugin

If you haven't already installed and configured the corresponding plugin -- in this case, it's the [AWS plugin](https://hub.steampipe.io/plugins/turbot/aws) -- then start by doing so.

```
steampipe plugin install aws
```

To check multiple AWS accounts, use a [connection aggregator](https://hub.steampipe.io/plugins/turbot/aws#multi-account-connections) to define an aggregate connection (e.g. `aws_all`) that combines single-account connections (e.g. `aws_01`, `aws_02`, etc). You can also use a [region wildcard](https://hub.steampipe.io/plugins/turbot/aws#multi-region-connections) on the aggregated connection to run cost controls across all regions.

It's a good idea to check that Steampipe can access all your configured accounts. Here's a query to do that.

```
select account_id from aws_all.aws_account
```

If you've configured four accounts, the query should return four rows.

## Clone the mod

To run the benchmarks and controls provided by the AWS Thrifty mod, clone the repo and then visit its local copy.

```
git clone https://github.com/turbot/steampipe-mod-aws-thrifty.git
cd steampipe-mod-aws-thrifty
```

The mod defines 41 controls grouped into these 15 benchmarks.

<ul><li><a href="https://hub.steampipe.io/mods/turbot/aws_thrifty/controls/benchmark.cloudfront">CloudFront Checks</a></li><li><a href="https://hub.steampipe.io/mods/turbot/aws_thrifty/controls/benchmark.cloudtrail">CloudTrail Checks</a></li><li><a href="https://hub.steampipe.io/mods/turbot/aws_thrifty/controls/benchmark.cloudwatch">CloudWatch Checks</a></li><li><a href="https://hub.steampipe.io/mods/turbot/aws_thrifty/controls/benchmark.cost-explorer">Cost Explorer Checks</a></li><li><a href="https://hub.steampipe.io/mods/turbot/aws_thrifty/controls/benchmark.dynamodb">DynamoDB Checks</a></li><li><a href="https://hub.steampipe.io/mods/turbot/aws_thrifty/controls/benchmark.ebs">EBS Checks</a></li><li><a href="https://hub.steampipe.io/mods/turbot/aws_thrifty/controls/benchmark.ec2">EC2 Checks</a></li><li><a href="https://hub.steampipe.io/mods/turbot/aws_thrifty/controls/benchmark.ecs">ECS Checks</a></li><li><a href="https://hub.steampipe.io/mods/turbot/aws_thrifty/controls/benchmark.elasticache">ElastiCache Checks</a></li><li><a href="https://hub.steampipe.io/mods/turbot/aws_thrifty/controls/benchmark.emr">EMR Checks</a></li><li><a href="https://hub.steampipe.io/mods/turbot/aws_thrifty/controls/benchmark.lambda">Lambda Checks</a></li><li><a href="https://hub.steampipe.io/mods/turbot/aws_thrifty/controls/benchmark.network">Networking Checks</a></li><li><a href="https://hub.steampipe.io/mods/turbot/aws_thrifty/controls/benchmark.rds">RDS Checks</a></li><li><a href="https://hub.steampipe.io/mods/turbot/aws_thrifty/controls/benchmark.redshift">Redshift Checks</a></li><li><a href="https://hub.steampipe.io/mods/turbot/aws_thrifty/controls/benchmark.s3">S3 Checks</a></li></ul>

## Run a single control

Let's start with the first of the 9 EBS controls, [Old EBS snapshots should be deleted](https://hub.steampipe.io/mods/turbot/aws_thrifty/controls/control.ebs_snapshot_max_age?context=benchmark.ebs). Here's a command to run just that one control on four AWS accounts.

```
steampipe check aws_thrifty.control.ebs_snapshot_max_age \
  --search-path-prefix aws_all
```

The `search-path-prefix` argument ensures that the connection named `aws_all` will be the target of this control run. 

Here's the console output.

<img alt="console output for one control" src="/images/blog/2022-03-mod-aws-thrifty/single-control-console-output.png" />

<br />

The control finds that 6 of 8 snapshots are older than its default threshold of 90 days. What if your policy is to only flag snapshots older than 180 days? You can change the threshold. The above `steampipe check` command is equivalent to this expanded version.

```
steampipe check aws_thrifty.control.ebs_snapshot_max_age \
  --var ebs_snapshot_age_max_days=90 \
  --search-path-prefix aws_all
```

Here's the same check with a threshold of 180 days.

```
steampipe check aws_thrifty.control.ebs_snapshot_max_age \
  --var ebs_snapshot_age_max_days=180 \
  --search-path-prefix aws_all
```

<img alt="result of altered default" src="/images/blog/2022-03-mod-aws-thrifty/single-control-console-output-with-altered-default.png" />

<br />

Results are slightly different. With this policy in effect, only 5 of 8 snapshots cross the threshold. 

How would you know that the variable `ebs_snapshot_max_age` exists? Visit the mod's [variables](https://hub.steampipe.io/mods/turbot/aws_thrifty/variables) page to see what's available, and to review the defaults.

## Run a benchmark

The `ebs_snapshot_max_age` control is one of the 9 controls that comprise the [EBS benchmark](https://hub.steampipe.io/mods/turbot/aws_thrifty/controls/benchmark.ebs). You can run all 9 controls with a single command. 

```
steampipe check aws_thrifty.benchmark.ebs \
  --search-path-prefix aws_all
```

You can pass one or more variables to adjust the defaults.

```
steampipe check aws_thrifty.benchmark.ebs \
  --var ebs_snapshot_age_max_days=180 \
  --var ebs_volume_avg_read_write_ops_low=200 \
  --search-path-prefix aws_all
```

You can read the whole report in the console, but when you're running many controls it's convenient to review the output in HTML or Markdown. This command displays the report in the console, renders it as Markdown, and saves that output to a file.

```
steampipe check aws_thrifty.benchmark.ebs \
  --var ebs_snapshot_age_max_days=180 \
  --var ebs_volume_avg_read_write_ops_low=200 \
  --search-path-prefix aws_all \
  --export ebs.md
```

<img alt="output as markdown" src="/images/blog/2022-03-mod-aws-thrifty/single-benchmark-output-as-markdown.png" />

<br />

## Run all the things!

You can run all 15 benchmarks with one command.

```
steampipe check all \
  --search-path-prefix aws_all
```

When you're generating this much data, it may make sense to export to CSV. 

```
steampipe check all \
  --search-path-prefix aws_all \
  --export csv
```

This command creates a CSV file with a name like `all-20220329-181410.csv` (because the command ran on March 29 at 4:15PM). If you want to track your progress as you tackle the issues surfaced in the report, you can run this command periodically to accumulate a series of CSV files. 

How to analyze that series of CSV files? Use the [CSV plugin](https://hub.steampipe.io/plugins/csv) to query them as SQL tables. To enable that, point the `paths` argument in your `~/steampipe/config/csv.spc` file to the mod's repo.

```
  connection "csv"
  paths = [ "~/steampipe-mod-aws-thrifty/*.csv" ]
```

Now you can track the stats over time as you make adjustments based on the report. How to chart those changing stats? Create a [dashboard](https://steampipe.io/blog/dashboards-as-code)! That's easier, and more fun, than you might expect. Check out our [tutorial](https://steampipe.io/docs/mods/writing-dashboards) to see how it's done.

If you have questions, head on over to our [Slack](https://steampipe.io/community/join) workspace. It's full of friendly people who want to share their experiences and help you succeed with AWS Thrifty (or anything else Steampipe-related).

If you want to report a bug, suggest a new control, or contribute one of your own, the AWS Thrifty [GitHub repo](https://github.com/turbot/steampipe-mod-aws-thrifty) is waiting to hear from you. We love feedback, and we treasure contributions. 

Meanwhile, happy hunting as you use AWS Thrifty to find ways to control resource costs!

