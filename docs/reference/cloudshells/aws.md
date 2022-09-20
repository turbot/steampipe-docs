---
title: Using Steampipe in AWS Cloud Shell
sidebar_label: AWS Cloud Shell
---

# Using Steampipe in AWS Cloud Shell

[AWS CloudShell](https://aws.amazon.com/cloudshell/) is a free service that spins up a terminal right in your AWS account. Because the terminal includes the AWS CLI and your credentials, it takes just a few seconds to install Steampipe itself, along with the [AWS plugin](https://hub.steampipe.io/plugins/turbot/aws). You can then immediately write SQL queries to pull data from the hundreds of Postgres tables supported by the plugin.

## About AWS Cloud Shell

To start the shell, visit an URL like https://us-east-1.console.aws.amazon.com/cloudshell/home and click the highlighted icon. If you don't see the icon, switch to a [supported region](https://docs.aws.amazon.com/cloudshell/latest/userguide/supported-aws-regions.html). 

<div style={{"marginBottom":"2em","borderWidth":"thin", "borderStyle":"solid", "borderColor":"lightgray", "padding":"20px", "width":"90%"}}>
<img src="/images/docs/cloudshells/aws-cloudshell-homescreen.jpg" />
</div>

Cloud Shell includes 1 GB of free persistent storage per region. When you exit the shell, AWS preserves only the files inside your home directory. So we'll install Steampipe in your home directory (vs `/usr/local/bin`), and we'll run Steampipe as `./steampipe` (vs `steampipe`). 

## Installing Steampipe in AWS Cloud Shell

To install Steampipe, copy and run this command.

```bash
curl -s -L https://github.com/turbot/steampipe/releases/latest/download/steampipe_linux_amd64.tar.gz | tar -xzvf -
```

To install the AWS plugin, copy and run this command.

```
./steampipe plugin install aws
```

Your output should look like:

```
aws                  [====================================================================] Done                

Installed plugin: aws@latest v0.77.0
Documentation:    https://hub.steampipe.io/plugins/turbot/aws
```

## Run your first query

To launch Steampipe in query mode, type `steampipe query`.

```bash
./steampipe query
```

Steampipe prints a welcome message and a prompt.

```
Welcome to Steampipe v0.16.3
For more information, type .help
> 
```

To find all your S3 buckets, enter this query:

```
select * from aws_s3_bucket
```

Your output should look like:

```
+-------------------------------------------+--------------------------------------------------------+----------------------+-------------------------+
| name                                      | arn                                                    | creation_date        | bucket_policy_is_public |
+-------------------------------------------+--------------------------------------------------------+----------------------+-------------------------+
| aws-cloudtrail-logs-605491513981-45df8af0 | arn:aws:s3:::aws-cloudtrail-logs-605491513981-45df8af0 | 2022-05-04T16:37:09Z | false                   |
| jon-turbot-test-bucket-01                 | arn:aws:s3:::jon-turbot-test-bucket-01                 | 2021-10-04T16:55:29Z | false                   |
| cf-templates-1s5tzrjxv4j52-us-west-1      | arn:aws:s3:::cf-templates-1s5tzrjxv4j52-us-west-1      | 2021-12-28T00:37:38Z | false                   |
+-------------------------------------------+--------------------------------------------------------+----------------------+-------------------------+
```

To see the full set of columns for any table, along with examples of their use, visit the [Steampipe Hub](https://hub.steampipe.io). For S3 buckets, visit [aws_s3_bucket](https://hub.steampipe.io/plugins/turbot/aws/tables/aws_s3_bucket). For quick reference you can autocomplete table names directly in the shell.

<div style={{"marginBottom":"2em","borderWidth":"thin", "borderStyle":"solid", "borderColor":"lightgray", "padding":"20px", "width":"90%"}}>
<img src="/images/docs/cloudshells/aws-cloudshell-inspect.jpg" />
</div>

If you haven't used SQL lately, is rusty, see our [handy guide](https://steampipe.io/docs/sql/steampipe-sql) for writing Steampipe queries.

