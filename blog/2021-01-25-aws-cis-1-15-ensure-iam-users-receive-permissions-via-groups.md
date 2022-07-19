---
id: aws-cis-1-15
title: "Monitor compliance of the AWS CIS 1.15 benchmark."
category: "Case Study"
description: Ensure IAM users only receive permissions via groups.
author:
  name: David Boeke
publishedAt: "2021-01-25T16:00:00"
durationMins: 7
image: /images/blog/scuba-group.jpg
slug: aws-cis-1-15-ensure-iam-users-have-group-permissions
schema: "2021-01-08"
---

### AWS IAM policy management best practice.

CIS recommends that IAM policies be applied directly to groups and roles but not to users. Assigning privileges at the group or role level reduces the complexity of access management as the number of users grow, and reducing access management complexity should reduce the opportunity for someone to inadvertently receive or retain excessive privileges. 

### AWS IAM User Schema

Within steampipe, we have a couple columns available to us that relate to `IAM User Policies`:

```
> .inspect aws.aws_iam_user
```
```
+---------------------------+-----------------------------+---------------------------------------------------------------+
|          Column           |            Type             |                         Description                           |
+---------------------------+-----------------------------+---------------------------------------------------------------+
| account_id                | text                        | The AWS Account ID in which  the resource is located          |
| akas                      | jsonb                       | Array of globally unique identifier strings (also known as)   |
| arn                       | text                        | The Amazon Resource Name (ARN) that identifies the user       |
| attached_policy_arns      | jsonb                       | A list of managed policies  attached to the user              |
| create_date               | timestamp without time zone | The date and time, when the user was created                  |
| groups                    | jsonb                       | A list of groups attached to the user                         |
| inline_policies           | jsonb                       | A list of policy documents that are embedded as inline        |
|                           |                             | policies for the user                                         |
| name                      | text                        | The friendly name identifying the user                        |
| partition                 | text                        | The AWS partition in which the resource is located            |
| password_last_used        | timestamp without time zone | The date and time, when the user's password was last used     |
|                           |                             | to sign in to an AWS website                                  |
| path                      | text                        | The path to the user                                          |
| permissions_boundary_arn  | text                        | The ARN of the policy used to set the permissions boundary    |
| permissions_boundary_type | text                        | The permissions boundary usage type that indicates what type  |
|                           |                             | of IAM resource is used as the permissions boundary for       |
|                           |                             | an entity. This data type can only have a value of Policy     |
| region                    | text                        | The AWS Region in which the esource is located                |
| tags                      | jsonb                       | A map of tags for the resource.                               |
| tags_src                  | jsonb                       | A list of tags that are attached to the user                  |
| title                     | text                        | Title of the resource.                                        |
| user_id                   | text                        | The stable and unique string identifying the user             |
+---------------------------+-----------------------------+---------------------------------------------------------------+
```

**attached_policy_arns**: Are a [jsonb](https://www.postgresql.org/docs/9.4/datatype-json.html) object of what `managed policies` are attached to a user.

**inline_policies**: Are a `jsonb` object of what `inline policies` are attached to a user.

>  When setting permissions for an IAM user, you must decide between using an AWS managed policy, a customer managed policy, or an inline policy. 
>  - An AWS managed policy is a standalone policy that is created and administered by AWS.
>  - Customer managed policies are standalone policies that are created by an authorized individual and are custom to each AWS account.
>  - An inline policy is a policy that's created as part of the user, and is part of the user definition.

#### Find all users with an inline policy attached.

For the purposes of compliance with `AWS CIS 1.15` it is equally bad to have inline policies and managed policies attached to a user. Lets check for inline policies first:

```sql
> select
    user_id,
    name,
    inline_policies
  from
    aws_iam_user;
```
```   
+-----------------------+----------------+-----------------------------------------------------------------------------------------------------------------------------------------------------------
|        user_id        |      name      |
+-----------------------+----------------+-----------------------------------------------------------------------------------------------------------------------------------------------------------
| AIDA5CXHA655LL7T2F2RU | kelly_kapoor   |
| AIDA5CXHA655FZ3JXIZJD | dwight_schrute |
| AIDA5CXHA655IZG7WI637 | darryl_philbin |
| AIDA5CXHA655BCGDQIWRG | ryan_howard    | [{"PolicyDocument":{"Statement":[{"Action":"honeycode:*","Effect":"Allow","Resource":"*","Sid":"VisualEditor0"}],"Version":"2012-10-17"},"PolicyName":"hon
+-----------------------+----------------+-----------------------------------------------------------------------------------------------------------------------------------------------------------
```
That is kind of hard to read, lets clean it up using [PostgreSQL jsonb functions](https://www.postgresql.org/docs/9.5/functions-json.html).

```sql
> select
    user_id,
    name,
    jsonb_pretty(inline_policies)
  from
    aws_iam_user;
```
```
+-----------------------+----------------+----------------------------------------------+
|        user_id        |      name      |                 jsonb_pretty                 |
+-----------------------+----------------+----------------------------------------------+
| AIDA5CXHA655FZ3JXIZJD | dwight_schrute |                                              |
| AIDA5CXHA655IZG7WI637 | darryl_philbin |                                              |
| AIDA5CXHA655BCGDQIWRG | ryan_howard    | [                                            |
|                       |                |     {                                        |
|                       |                |         "PolicyName": "honeycomb_admin",     |
|                       |                |         "PolicyDocument": {                  |
|                       |                |             "Version": "2012-10-17",         |
|                       |                |             "Statement": [                   |
|                       |                |                 {                            |
|                       |                |                     "Sid": "VisualEditor0",  |
|                       |                |                     "Action": "honeycode:*", |
|                       |                |                     "Effect": "Allow",       |
|                       |                |                     "Resource": "*"          |
|                       |                |                 }                            |
|                       |                |             ]                                |
|                       |                |         }                                    |
|                       |                |     },                                       |
|                       |                |     {                                        |
|                       |                |         "PolicyName": "all_ec2_admin",       |
|                       |                |         "PolicyDocument": {                  |
|                       |                |             "Version": "2012-10-17",         |
|                       |                |             "Statement": [                   |
|                       |                |                 {                            |
|                       |                |                     "Sid": "VisualEditor0",  |
|                       |                |                     "Action": "ec2:*",       |
|                       |                |                     "Effect": "Allow",       |
|                       |                |                     "Resource": "*"          |
|                       |                |                 }                            |
|                       |                |             ]                                |
|                       |                |         }                                    |
|                       |                |     }                                        |
|                       |                | ]                                            |
| AIDA5CXHA655LL7T2F2RU | kelly_kapoor   |                                              |
+-----------------------+----------------+----------------------------------------------+
```

Those are some pretty insecure inline policies for Ryan, and according to CIS best practices we should not have any.  We can simplify this and just look for records with *any* number of inline policies; time for a little more `jsonb` and `sql` magic:

```sql
> select
    user_id,
    name,
    jsonb_array_length(inline_policies) as inline_policies
  from
    aws_iam_user
  where 
    inline_policies is not null;
```
```
+-----------------------+-------------+-----------------+
|        user_id        |    name     | inline_policies |
+-----------------------+-------------+-----------------+
| AIDA5CXHA655BCGDQIWRG | ryan_howard |               2 |
+-----------------------+-------------+-----------------+
```

#### Find all users with a managed policy attached

Now that we have the users with inline policies handled, let's check for any users with managed policies attached. I always like to start by exploring the data a bit.

```sql
> select
    user_id,
    name,
    attached_policy_arns
  from
    aws_iam_user;
```
```
+-----------------------+----------------+-----------------------------------------------------------------------------------------------------------+
|        user_id        |      name      |                                            attached_policy_arns                                           |
+-----------------------+----------------+-----------------------------------------------------------------------------------------------------------+
| AIDA5CXHA655IZG7WI637 | darryl_philbin | ["arn:aws:iam::899206412154:policy/test_boundary","arn:aws:iam::899206412154:policy/turbot/acm_operator"] |
| AIDA5CXHA655BCGDQIWRG | ryan_howard    |                                                                                                           |
| AIDA5CXHA655FZ3JXIZJD | dwight_schrute |                                                                                                           |
| AIDA5CXHA655LL7T2F2RU | kelly_kapoor   |                                                                                                           |
+-----------------------+----------------+-----------------------------------------------------------------------------------------------------------+
```
Darryl seems to be out of policy here with two managed policies directly attached. Let's filter out the users who are not in violation and combine with our inline policy query:

```sql
> select
    user_id,
    name,
    jsonb_array_length(inline_policies) as inline_policies,
    jsonb_array_length(attached_policy_arns) as attached_policies
  from
    aws_iam_user
  where 
    inline_policies is not null
    or attached_policy_arns is not null;
```
```
+-----------------------+----------------+-----------------+-------------------+
|        user_id        |      name      | inline_policies | attached_policies |
+-----------------------+----------------+-----------------+-------------------+
| AIDA5CXHA655IZG7WI637 | darryl_philbin |                 |                 2 |
| AIDA5CXHA655BCGDQIWRG | ryan_howard    |               2 |                   |
+-----------------------+----------------+-----------------+-------------------+
```

User ID is not very helpful in this context, what we really want to do is email these guys and get the environment cleaned up. Two users are easy to handle manually, but if I am going to export a long list it might work better in the `csv` format. Steampipe has a number of [meta-commands](https://steampipe.io/docs/reference/dot-commands) available and the one we are looking for is `.output`:

```
> .output csv
```
Now I can repeat the query, pulling the offenders email out of the available tags:

```sql 
select
    name,
    tags -> 'email' as email,
    jsonb_array_length(inline_policies) as inline_policies,
    jsonb_array_length(attached_policy_arns) as attached_policies
  from
    aws_iam_user
  where 
    inline_policies is not null
    or attached_policy_arns is not null;
```
```csv
name,email,inline_policies,attached_policies
darryl_philbin,"""dphilbin@dundermifflin.com""",,2
ryan_howard,"""ryan@wuphf.com""",2,
```

Now that we have our query complete and tested in our sandbox, let's **get to work** and run it against our development, staging and production environments. Are you having fun with Steampipe? Let us know what you are querying via twitter [@steampipeio](https://twitter.com/steampipeio)!

### Haven't tried Steampipe yet? Get started and download for yourself today!

Steampipe is [available for download today](https://steampipe.io/downloads). Install, query and get cloud work done. 

We can’t wait to see what you query, and iterate based on your feedback. If you’d like to help expand the Steampipe universe, or even dive into the CLI code, the whole project is open source (https://github.com/turbot/steampipe) and we’d love to collaborate! 

Keep an eye on https://hub.steampipe.io for the latest supported resource types from both Turbot and the Steampipe community, and for your own personal guided tour of steampipe, checkout our documentation: https://steampipe.io/docs.

If you experience any issues, please report them on our [GitHub issue tracker](https://github.com/turbot/steampipe/issues) or join our [Slack workspace](https://steampipe.io/community/join).