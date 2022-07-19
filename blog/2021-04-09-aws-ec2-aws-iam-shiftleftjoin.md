---
id: shift-left-join-ec2-instances-not-using-imdsv2
title: "Shift Left Join: Find all AWS EC2 instances not using IMDSv2"
category: Shift Left Join
description: "Join metadata across EC2 instances and IAM instance profiles."
summary: "Shift Left Join: Find all AWS EC2 instances not using IMDSv2"
author:
  name: David Boeke
  twitter: "@boeke"
publishedAt: "2021-04-09T14:00:00"
durationMins: 7
image: /images/blog/shift-left-join/aws-ec2-aws-iam.png
slug: shift-left-join-ec2-instances-not-using-imdsv2
schema: "2021-01-08"
---


One of the most pernicious issues in application development is how to secure credentials used to connect tiers of an application.  A web application with an autoscaling fleet of web servers will likely need database connectivity and the ability to manage objects in S3.  Finding secure ways to push credentials to those instances and rotating them over time is a difficult problem to solve on premise, let alone as part of a cloud service.

In 2012 AWS introduced a feature that allowed you to assign an AWS IAM Role to instances running within your AWS account. Services on that instance would then have the ability to operate with the permissions of a given IAM role without need to store credentials.  When the EC2 instance is launched, an IAM role with [temporary AWS security credentials](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_temp_use-resources.html) will be securely provisioned to the instance and made available via the [EC2 Instance Metadata Service](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-instance-metadata.html) (IDMS). It then becomes the EC2 service that is responsible for ensuring credentials are rotated (based on the session expiration settings on the role).

One potential issue with this approach is that if software on the instance is configured insecurly, it could potentially expose those temporary credentials. In November 2019 AWS [released an updated version of IMDS named IMDSv2](https://aws.amazon.com/blogs/security/defense-in-depth-open-firewalls-reverse-proxies-ssrf-vulnerabilities-ec2-instance-metadata-service/) that provided additional capabilities to protect against this type of threat.

### In this [#shiftleftjoin](https://steampipe.io/blog/#shiftleftjoin), you will learn how to visualize what EC2 instances are using what IAM roles, and determine which IDMS version is configured on those instances.

## Prerequisites

We assume in this example that you have:
- One (or more) AWS Accounts
- At least one EC2 instance configured with an IAM instance profile
- [Steampipe installed](https://steampipe.io/downloads)
- AWS Plugin for Steampipe [installed and connectivity configured](https://hub.steampipe.io/plugins/turbot/aws)

## Get Started

### 1. Explore instances

<div className="mt-4 row"> 
  <div className="col col-0 col-lg-1"></div>
  <div className="col col-12  col-lg-11 col-xl-10">
    <p>
      Open Steampipe and run query to see how many instances are in each region:
    </p>
    <Terminal title="steampipe cli">
      <TerminalCommand withPrompt={false} enableCopyToClipboard={false}>
        {`   
$ steampipe query
Welcome to Steampipe v0.3.6
For more information, type .help
 
> select
    region,
    count(*) as instances
  from
    aws_ec2_instance
  group by
    region;
        `}
    </TerminalCommand>
    <TerminalResult>
    {`
+-----------+-----------+
| region    | instances |
+-----------+-----------+
| us-east-1 | 7         |
| us-west-2 | 2         |
| eu-west-1 | 3         |
+-----------+-----------+
        `}
      </TerminalResult>
    </Terminal>
  </div>
</div>

### 2. Explore roles 



<div className="mt-4 row"> 
  <div className="col col-0 col-lg-1"></div>
  <div className="col col-12 col-lg-11 col-xl-10">
    <p>
      Roles that can be used for EC2 instances will have an instance profile associated with them:
    </p>
    <Terminal title="steampipe cli">
      <TerminalCommand withPrompt={true} enableCopyToClipboard={true}>
        {`   
select
  title as role_name,
  instance_profile_arns
from
  aws_iam_role
where
  instance_profile_arns is not null;
        `}
    </TerminalCommand>
    <TerminalResult>
    {`
+------------+-----------------------------------------------------------+
| role_name  | instance_profile_arns                                     |
+------------+-----------------------------------------------------------+
| ec2_role_a | ["arn:aws:iam::111222333444:instance-profile/ec2_role_a"] |
| ec2_role_b | ["arn:aws:iam::111222333444:instance-profile/ec2_role_b"] |
+------------+-----------------------------------------------------------+
        `}
      </TerminalResult>
    </Terminal>
  </div>
</div>

### 3. Join the data 

<div className="mt-4 row"> 
  <div className="col col-0 col-lg-1"></div>
  <div className="col col-12 col-lg-11 col-xl-10">
    <p>
      We can construct a query to identify which instances are using which roles:
    </p>
    <Terminal title="steampipe cli">
      <TerminalCommand withPrompt={true} enableCopyToClipboard={true}>
        {`   
select
  i.instance_id,
  i.region,
  r.title as role_name
from
  aws_ec2_instance as i,
  aws_iam_role as r
where
  r.instance_profile_arns::jsonb ? i.iam_instance_profile_arn;
        `}
    </TerminalCommand>
    <TerminalResult>
    {`
+---------------------+-----------+------------+
| instance_id         | region    | role_name  |
+---------------------+-----------+------------+
| i-0dc60dd191cb86542 | us-east-1 | ec2_role_a |
| i-00cf426db9b8a58b6 | us-east-1 | ec2_role_a |
| i-042a51a815773780d | eu-west-1 | ec2_role_b |
| i-0e97f373db42dfa3f | eu-west-1 | ec2_role_b |
+---------------------+-----------+------------+
        `}
      </TerminalResult>
    </Terminal>
  </div>
</div>

### 4. Identify non-compliant resources

<div className="mt-4 row"> 
  <div className="col col-0 col-lg-1"></div>
  <div className="col col-12 col-lg-11 col-xl-10">
    <p>
      We can now add to this query to identify which of these instances are using the older version of the Instance Metadata Service (IMDS)?
    </p>
    <Terminal title="steampipe cli">
      <TerminalCommand withPrompt={true} enableCopyToClipboard={true}>
        {`   
select
  i.instance_id,
  i.region,
  i.metadata_options ->> 'HttpTokens' as imdsv2,
  r.title as role_name
from
  aws_ec2_instance as i,
  aws_iam_role as r
where
  r.instance_profile_arns::jsonb ? i.iam_instance_profile_arn;
        `}
    </TerminalCommand>
    <TerminalResult>
    {`
+---------------------+-----------+----------+------------+
| instance_id         | region    | imdsv2   | role_name  |
+---------------------+-----------+----------+------------+
| i-0dc60dd191cb86542 | us-east-1 | optional | ec2_role_a |
| i-00cf426db9b8a58b6 | us-east-1 | required | ec2_role_a |
| i-042a51a815773780d | eu-west-1 | optional | ec2_role_b |
| i-0e97f373db42dfa3f | eu-west-1 | required | ec2_role_b |
+---------------------+-----------+----------+------------+
        `}
      </TerminalResult>
    </Terminal>
    <p className="mt-4">
      The column `metadata_options_http_tokens` is set to optional if the instance is capable of using IMDSv1 and required if only allowed to be used with IMDSv2.
    </p>
  </div>
</div>

### 5. Notify responsible parties

<div className="mt-4 mb-5 row"> 
  <div className="col col-0 col-lg-1"></div>
  <div className="col col-12 col-lg-11 col-xl-10">
    <p>
      Now that we can easily identify the instances that need updating to the new standard, we want to notify the owners of those instances to make the appropriate change.  We store our operations metadata as tags on each instance to identify the responsible party for all resources.  If you do something similar you can use a query to get their email address from the `owner` tag:
    </p>
    <Terminal title="steampipe cli">
      <TerminalCommand withPrompt={true} enableCopyToClipboard={true}>
        {`   
select
  i.instance_id,
  i.title as instance_name,
  i.tags ->> 'owner' as owner
from
  aws_ec2_instance as i,
  aws_iam_role as r
where
  r.instance_profile_arns::jsonb ? i.iam_instance_profile_arn
  and i.metadata_options ->> 'HttpTokens' = 'optional';
        `}
    </TerminalCommand>
    <TerminalResult>
    {`
+---------------------+------------------+----------------+
| instance_id         | instance_name    | owner          |
+---------------------+------------------+----------------+
| i-0dc60dd191cb86542 | Sales Reporting  | dwight@dmi.com |
| i-042a51a815773780d | Finance Database | angela@dmi.com |
+---------------------+------------------+----------------+
        `}
      </TerminalResult>
    </Terminal>
  </div>
</div>

<br />

##### **Problem Solved**. You now have a way to easily see what roles are being used in your AWS account to provide authentication to EC2 instances, and can identify the owners that have yet to upgrade to the new (more secure) instance metadata service v2.

## Related Articles

- [The Hitchhiker's Guide to IAM Policy Wildcards](https://steampipe.io/blog/aws-iam-policy-wildcards-reference)
- [Normalizing AWS IAM Policies for Automation](https://steampipe.io/blog/normalizing-aws-iam-policies-for-automated-analysis)
- [New: AWS Multi-Region Queries and Query Caching](https://steampipe.io/blog/release-0-2-0)