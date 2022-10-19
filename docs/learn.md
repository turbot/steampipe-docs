---
id: learn
title: Learn Steampipe
sidebar_label: Learn Steampipe
slug: /
---

# Learn Steampipe

Steampipe exposes APIs and services as a high-performance relational database, giving you the ability to write SQL-based queries to explore dynamic data. Mods extend Steampipe's capabilities with dashboards, reports, and controls built with simple [HCL](https://github.com/hashicorp/hcl).

Let's dive in...

## Install the AWS plugin

This tutorial uses the [AWS plugin](https://hub.steampipe.io/plugins/turbot/aws). To get started, [download and install Steampipe](/downloads), and then install the plugin:

```bash
steampipe plugin install aws
```

Steampipe will download and install additional components the first time you run `steampipe query` so it may take a few seconds to load initially.

Out of the box, Steampipe will use your default AWS credentials from your credential file and/or environment variables, so you'll need to make sure those are set up as well.  If you can run `aws ec2 describe-vpcs`, you're good to go.  (The AWS plugin provides additional examples to [configure your credentials](https://hub.steampipe.io/plugins/turbot/aws#configuring-aws-credentials), and even configure steampipe to query [multiple accounts](https://hub.steampipe.io/plugins/turbot/aws#multi-account-connections) and [multiple regions](https://hub.steampipe.io/plugins/turbot/aws#multi-region-connections
).)




## Explore
Steampipe provides commands that allow you to discover and explore the tables and data without leaving the query shell.  (Of course, this information is all available in [the hub](https://hub.steampipe.io/plugins/turbot/aws/tables) if online docs are more your speed...)

Let's fire up Steampipe!  Run `steampipe query` to open an interactive query session:

```bash
$ steampipe query
Welcome to Steampipe v0.5.0
For more information, type .help
>

```

Now run the `.tables` meta-command to list the available tables:

```
> .tables
==> aws
+----------------------------------------+---------------------------------------------+
| table                                  | description                                 |
+----------------------------------------+---------------------------------------------+
| aws_accessanalyzer_analyzer            | AWS Access Analyzer                         |
| aws_account                            | AWS Account                                 |
| aws_acm_certificate                    | AWS ACM Certificate                         |
| aws_api_gateway_api_key                | AWS API Gateway API Key                     |
...
+----------------------------------------+---------------------------------------------+
```

As you can see, there are quite a few tables available in the AWS plugin!  

It looks like there's an `aws_iam_role` table - let's run `.inspect` to see what's in that table:
```
> .inspect aws_iam_role
+---------------------------+-----------------------------+---------------------------------------------------------------------------------------------------+
| column                    | type                        | description                                                                                       |
+---------------------------+-----------------------------+---------------------------------------------------------------------------------------------------+
| account_id                | text                        | The AWS Account ID in which the resource is located.                                              |
| akas                      | jsonb                       | Array of globally unique identifier strings (also known as) for the resource.                     |
| arn                       | text                        | The Amazon Resource Name (ARN) specifying the role.                                               |
| assume_role_policy        | jsonb                       | The policy that grants an entity permission to assume the role.                                   |
| assume_role_policy_std    | jsonb                       | Contains the assume role policy in a canonical form for easier searching.                         |
| attached_policy_arns      | jsonb                       | A list of managed policies attached to the role.                                                  |
| create_date               | timestamp without time zone | The date and time when the role was created.                                                      |
| description               | text                        | A user-provided description of the role.                                                          |
| inline_policies           | jsonb                       | A list of policy documents that are embedded as inline policies for the role..                    |
| inline_policies_std       | jsonb                       | Inline policies in canonical form for the role.                                                   |
| instance_profile_arns     | jsonb                       | A list of instance profiles associated with the role.                                             |
| max_session_duration      | bigint                      | The maximum session duration (in seconds) for the specified role. Anyone who uses the AWS CLI, or |
|                           |                             |  API to assume the role can specify the duration using the optional DurationSeconds API parameter |
|                           |                             |  or duration-seconds CLI parameter.                                                               |
| name                      | text                        | The friendly name that identifies the role.                                                       |
| partition                 | text                        | The AWS partition in which the resource is located (aws, aws-cn, or aws-us-gov).                  |
| path                      | text                        | The path to the role.                                                                             |
| permissions_boundary_arn  | text                        | The ARN of the policy used to set the permissions boundary for the role.                          |
| permissions_boundary_type | text                        | The permissions boundary usage type that indicates what type of IAM resource is used as the permi |
|                           |                             | ssions boundary for an entity. This data type can only have a value of Policy.                    |
| region                    | text                        | The AWS Region in which the resource is located.                                                  |
| role_id                   | text                        | The stable and unique string identifying the role.                                                |
| role_last_used_date       | timestamp without time zone | Contains information about the last time that an IAM role was used. Activity is only reported for |
|                           |                             |  the trailing 400 days. This period can be shorter if your Region began supporting these features |
|                           |                             |  within the last year. The role might have been used more than 400 days ago.                      |
| role_last_used_region     | text                        | Contains the region in which the IAM role was used.                                               |
| tags                      | jsonb                       | A map of tags for the resource.                                                                   |
| tags_src                  | jsonb                       | A list of tags that are attached to the role.                                                     |
| title                     | text                        | Title of the resource.                                                                            |
+---------------------------+-----------------------------+---------------------------------------------------------------------------------------------------+
```


## Query

Now that we know what columns are available in the `aws_iam_role` table, let's run a simple query to list the roles:

```sql
 select name from aws_iam_role
```

```
+------------------------------------------------------------------+
| name                                                             |
+------------------------------------------------------------------+
| AWSServiceRoleForOrganizations                                   |
| aws-elasticbeanstalk-service-role                                |
| admin                                                            |
| AWSServiceRoleForAmazonElasticsearchService                      |
| user                                                             |
| AWSServiceRoleForAccessAnalyzer                                  |
| CLoudtrailRoleForCloudwatchLogs                                  |
| aws-elasticbeanstalk-ec2-role                                    |
| rds_metadata                                                     |
| metadata                                                         |
| AWSServiceRoleForAutoScaling                                     |
| operator                                                         |
| s3crr_role_for_vanedaly-replicated-bucket-01_to_test-repl-dest-f |
| iam_owner                                                        |
| ec2_owner                                                        |
| ec2_operator                                                     |
| AWSServiceRoleForSSO                                             |
+------------------------------------------------------------------+

```

Now let's ask a more interesting question.  Let's find roles that have no boundary policy applied:

```sql
select
  name
from
  aws_iam_role
where
  permissions_boundary_arn is null;
```

```
+------------------------------------------------------------------+
| name                                                             |
+------------------------------------------------------------------+
| AWSServiceRoleForOrganizations                                   |
| aws-elasticbeanstalk-service-role                                |
| AWSServiceRoleForAmazonElasticsearchService                      |
| AWSServiceRoleForAccessAnalyzer                                  |
| CLoudtrailRoleForCloudwatchLogs                                  |
| aws-elasticbeanstalk-ec2-role                                    |
| AWSServiceRoleForAutoScaling                                     |
| s3crr_role_for_vanedaly-replicated-bucket-01_to_test-repl-dest-f |
| AWSServiceRoleForSSO                                             |
+------------------------------------------------------------------+

```

Like any database, we can join tables together as well.  For instance, we can find all the roles that have AWS-managed policies attached:
```sql
select
  r.name,
  policy_arn,
  p.is_aws_managed
from
  aws_iam_role as r,
  jsonb_array_elements_text(attached_policy_arns) as policy_arn,
  aws_iam_policy as p
where 
  p.arn = policy_arn
  and p.is_aws_managed;

```

```
+-------------------------------------------------------+------------------------------------------------------------------------------------+----------------+
| name                                                  | policy_arn                                                                         | is_aws_managed |
+-------------------------------------------------------+------------------------------------------------------------------------------------+----------------+
| aws-elasticbeanstalk-ec2-role                         | arn:aws:iam::aws:policy/AWSElasticBeanstalkWorkerTier                              | true           |
| aws-elasticbeanstalk-ec2-role                         | arn:aws:iam::aws:policy/AWSElasticBeanstalkMulticontainerDocker                    | true           |
| admin                                                 | arn:aws:iam::aws:policy/ReadOnlyAccess                                             | true           |
| AWSServiceRoleForSSO                                  | arn:aws:iam::aws:policy/aws-service-role/AWSSSOServiceRolePolicy                   | true           |
| AWSServiceRoleForAccessAnalyzer                       | arn:aws:iam::aws:policy/aws-service-role/AccessAnalyzerServiceRolePolicy           | true           |
| aws-elasticbeanstalk-service-role                     | arn:aws:iam::aws:policy/service-role/AWSElasticBeanstalkEnhancedHealth             | true           |
| AWSServiceRoleForElasticLoadBalancing                 | arn:aws:iam::aws:policy/aws-service-role/AWSElasticLoadBalancingServiceRolePolicy  | true           |
| aws-elasticbeanstalk-service-role                     | arn:aws:iam::aws:policy/service-role/AWSElasticBeanstalkService                    | true           |
| AWSServiceRoleForOrganizations                        | arn:aws:iam::aws:policy/aws-service-role/AWSOrganizationsServiceTrustPolicy        | true           |
+-------------------------------------------------------+------------------------------------------------------------------------------------+----------------+

```



## View Dashboards
While Steampipe plugins provide an easy way to query your configuration, Steampipe [mods](/docs/mods/overview) allows you to create and share dashboards, reports, and controls.

Steampipe **dashboards** allow you to visualize your steampipe data.

Let's download the AWS Insights mod and view the dashboards.  First, let's clone the repo:

```bash
git clone https://github.com/turbot/steampipe-mod-aws-insights.git
```

Now, let's change to that directory and run `steampipe dashboard`:
```bash
cd steampipe-mod-aws-insights
steampipe dashboard
```

<img src="/images/docs/dashboard_home.png" width="100%" />


Steampipe will load the embedded web server on port 9194 and open `http://localhost:9194/` in your browser.  The home page lists the available dashboards and is searchable by title or tags.  Click on the title of a report to view it.  For example, click the `AWS CloudTrail Trail Dashboard` to view it.

<img src="/images/docs/cloudtrail_dash_ex.png" width="100%" />

You can type in the search bar at the top of any page to navigate to another dashboard.  Alternatively, you can click the Steampipe logo in the top left to return to the home page.  When you are finished, you can return to the terminal console and type `Ctrl+c` to exit.

There are hundreds of dashboards packaged in [Steampipe Mods](https://hub.steampipe.io/mods) available on the [Steampipe Hub](https://hub.steampipe.io).  You can also [create your own dashboards](/docs/mods/writing-dashboards) - it's simple, fast, and fun!

## Run Controls
Steampipe mods can also define **benchmarks and controls** to assess your environment against security, compliance, operational, and cost controls.

Let's download the AWS compliance mod and run some benchmarks.  The AWS compliance mod contains benchmarks and controls to evaluate your AWS account against various compliance frameworks, such as the [CIS Amazon Web Services Foundations Benchmark](https://www.cisecurity.org/benchmark/amazon_web_services/).  

Lets clone the repo:

```bash
git clone https://github.com/turbot/steampipe-mod-aws-compliance.git
```

Steampipe benchmarks automatically appear as [dashboards](/docs/dashboard/overview) when you run `steampipe dashboard` in the mod.  From the dashboard home, you can select any benchmark to run and view it in an interactive HTML format.  You can even export the benchmark results as a CSV from the [panel view](/docs/dashboard/panel).

<img src="/images/reference_examples/benchmark_dashboard_view.png" />

<br />

You can also run controls and benchmarks in batch mode with the [steampipe check](/docs/reference/cli/check) command.  The `steampipe check` command provides options for selecting which controls to run, supports many output formats, and provides capabilities often required when using `steampipe` in your scripts, pipelines, and other automation scenarios.  

We can run ALL the benchmarks in the mod with the `steampipe check` command:

```bash
steampipe check all
```

The console will show progress as its runs, and will print the results to the screen when it is complete:

<img src="/images/steampipe-check-output-sample-1.png" width="100%" />

`steampipe check` provides a flexible interface for [running controls](docs/check/overview), including options to [select which controls to run](docs/check/filtering) and [control the output format](docs/check/formatting).  You can find many more controls and benchmarks on the [Steampipe Hub](https://hub.steampipe.io/mods).  You can even [create your own controls and benchmarks](docs/mods/writing-controls)!
