---
id: find-secrets-everywhere
title: "Find secrets everywhere"
category: Featured Plugin
description: "Use Steampipe to find secrets in all the nooks and crannies of your cloud infrastructure."
summary: "Use Steampipe to find secrets in all the nooks and crannies of your cloud infrastructure."
author:
  name: Jon Udell
  twitter: "@judell"
publishedAt: "2021-11-10T14:00:00"
durationMins: 7
image: "/images/blog/2021-11-10-find-secrets-everywhere/find-secrets-everywhere.jpg"
slug: find-secrets-everywhere
schema: "2021-01-08"
---

There are many ways to scan source code repositories for secrets, but they can also be hiding in all sorts of infrastructure nooks and crannies. Steampipe's [code plugin](https://github.com/turbot/steampipe-plugin-code) provides a novel way to find them. Its [code_secret](https://hub.steampipe.io/plugins/turbot/code/tables/code_secret) table doesn't map a particular API, as other plugins do. Instead it searches columns of other tables for secrets. Join `code_secret` with any other table in the [Steampipe ecosystem](https://hub.steampipe.io/plugins) to look for secrets in those tables' columns.

Consider, for example, the `user_data` column of the [aws_ec2_instance](https://hub.steampipe.io/plugins/turbot/aws/tables/aws_ec2_instance) table. It contains scripts that configure an instance at launch. If secrets are lurking there, this query will find them.

<Terminal>
  <TerminalCommand>
    {`
select
  instance_id,
  secret_type,
  secret
from
  code_secret,
  aws_ec2_instance
where src = user_data
    `}
  </TerminalCommand>
  <TerminalResult>
    {`
+---------------------+------------------------------+-----------------------------------------------
| instance_id         | secret_type                  | secret                                        
+---------------------+------------------------------+-----------------------------------------------
| i-02a4257fe2f08496f | basic_auth                   | https://joe:passwd123                         
| i-02a4257fe2f08496f | azure_storage_account_key    | mllhBNrG467B7Q5iT+ePFr6eLCE24ij9vT/fCeckOunfqz
| i-02a4257fe2f08496f | github_personal_access_token | 45ab6f911111f9f376a5b52c25d22113f2b45fa1      
| i-02a4257fe2f08496f | okta_token                   | 00Am7B2M_U-63q_Ppd6tDzAbBOkvcCht-kDG-baM7t    
| i-02a4257fe2f08496f | stripe_api_key               | sk_live_tR3PYbcVNZZ796tH88S4VQ2u              
| i-02a4257fe2f08496f | slack_api_token              | xoxp-5228148520-5228148525-1323104836872-10674
| i-02a4257fe2f08496f | aws_access_key_id            | AKIA4YFAKFKFYXTDS353                          
+---------------------+------------------------------+-----------------------------------------------
    `}
  </TerminalResult>
</Terminal>

<br/>


That's obviously a cooked example, but imagine that these kinds of secrets are stashed in several EC2 instances running in many regions across many AWS accounts. If you've configured Steampipe to look in all those places, using region wildcards and a [connection aggregator](https://steampipe.io/docs/using-steampipe/managing-connections#using-aggregators), that 8-line snippet of SQL will search everywhere for secrets in EC2 `user_data`.

Where else might secrets be hiding?

## Secrets in Elastic Container Service task definitions

Similar to `user_data`, task definitions govern the deployment of containers on a managed cluster of EC2 instances. Those definitions can set environment variables and run scripts, and might include secrets. To find them, join [aws_ecs_task_definition](https://hub.steampipe.io/plugins/turbot/aws/tables/aws_ecs_task_definition) with `code_secret`. 


<Terminal>
  <TerminalCommand>
    {`
with cdefs as (
  select
    task_definition_arn,
    container_definitions::text as cdef
  from
    aws_ecs_task_definition
  order by
    task_definition_arn
)
select
  s.secret_type,
  c.*
from 
  cdefs c,
  code_secret s
where
  s.src = c.cdef
    `}
  </TerminalCommand>
  <TerminalResult>
    {`
+------------------------------+--------------------------------------------------------------------------------+
| secret_type                  | task_definition_arn                                                            |
+------------------------------+--------------------------------------------------------------------------------+
| github_personal_access_token | arn:aws:ecs:us-west-1:605491513981:task-definition/first-run-task-definition:2 |
| okta_token                   | arn:aws:ecs:us-west-1:605491513981:task-definition/first-run-task-definition:2 |
| aws_access_key_id            | arn:aws:ecs:us-west-1:605491513981:task-definition/first-run-task-definition:2 |
+------------------------------+--------------------------------------------------------------------------------+
    `}
  </TerminalResult>
</Terminal>

<br/>

## Secrets in CodeBuild projects

An AWS CodeBuild project uses a *buildspec* that contains commands and settings. That's another place where secrets shouldn't be. Join [aws_codebuild_project](https://hub.steampipe.io/plugins/turbot/aws/tables/aws_codebuild_project) with `code_secret` to find them.

<Terminal>
  <TerminalCommand>
    {`
with code_build as (
  select
    name,
    source::text
  from
    aws_codebuild_project
  order by
    name
)
select
  s.secret_type,
  c.*
from 
  code_build c,
  code_secret s
where
  s.src = c.source
    `}
  </TerminalCommand>
  <TerminalResult>
    {`
+------------------------------+--------+
| secret_type                  | name   |
+------------------------------+--------+
| github_personal_access_token | cb-01  |
+------------------------------+--------+
    `}
  </TerminalResult>
</Terminal>

<br/>

## Secrets sent to CloudWatch logs by AWS Lambda functions


Are your Lambda functions inadvertantly logging secrets? Join [aws_cloudwatch_log_event](https://hub.steampipe.io/plugins/turbot/aws/tables/aws_cloudwatch_log_event) with `code_secret` to find out.


<Terminal>
  <TerminalCommand>
    {`
with data as (
  select 
    timestamp,
    message
  from 
    aws_cloudwatch_log_event a
  where 
    a.log_group_name = '/aws/lambda/aws-lambda-01'
)
select 
  d.*,
  s.*
from 
  data d,
  code_secret s
where 
  s.src = d.message
    `}
  </TerminalCommand>
  <TerminalResult>
    {`
+----------------------+--------------------+
| timestamp            | secret_type        |
+----------------------+--------------------+
| 2021-11-09T15:52:29Z | aws_access_key_id  |   
+----------------------+--------------------+
  `}
  </TerminalResult>
</Terminal>

<br/>


## Secrets in DNS TXT records

It's nice that we can put anything at all into our DNS TXT records, but what if we accidentally put secrets there? Here's a 3-way join to find them, involving the [net_dns_record](https://hub.steampipe.io/plugins/turbot/net/tables/net_dns_record) table, the [CSV plugin](https://hub.steampipe.io/plugins/turbot/csv), and `code_secret`. The setup here: a file called `domains.csv` has a list of your domains. Join that with `net_dns_record` to find the TXT records for your domains, then join with `code_secret` to check for secrets.


<Terminal>
  <TerminalCommand>
    {`
with dns_data as (
  select
    *
  from 
    net_dns_record n
  join
    csv.domains d
  using
    (domain)
  where
    type = 'TXT'
    and value is not null
)
select 
  *  
from 
  dns_data,
  code_secret
where
  src = value
    `}
  </TerminalCommand>
</Terminal>

<br/>

## Secrets elsewhere

As our cloud infrastructure grows ever more complex, there will be more nooks and crannies in which secrets can hide. Queries like these can flush them out. And as we showed in [Using SQL to check spreadsheet integrity](https://steampipe.io/blog/spreadsheet-integrity), it's straightforward to embed such queries in custom controls that run automated checks and tabulate results. 

Take a look at the Steampipe [ecosystem of plugins](https://hub.steampipe.io/plugins), think about which tables can usefully join with `code_secret`, [share your ideas](https://steampipe.io/community/join) with the Steampipe community, and maybe [contribute a new secret](https://github.com/turbot/steampipe-plugin-code/tree/main/secrets): it's easy and fun!
