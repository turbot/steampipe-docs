---
id: steampipe-builds-on-parliament-aws-iam
title: "Steampipe ❤ Parliament"
category: "Research"
description: "How Steampipe leveraged Parliament to make SQL queries against IAM even more powerful."
author:
  name: David Boeke
publishedAt: "2021-02-14T16:00:00"
durationMins: 6
image: /images/blog/2021-02-14-parliament/au-parliament.jpg
slug: steampipe-builds-on-parliament-aws-iam
schema: "2021-01-08"
---

## Our first date with IAM

From the very earliest days of development on Steampipe, we knew that using SQL to query AWS Identity and Access Management (IAM) resources would be one of the killer features of the product. IAM tables were in some of the earliest builds, and stood out in terms of creating instant value for us in our day-to-day workflow.  Simple joins could answer critical questions that were only before possible with far more complex SDK scripting.

A common mistake for developers new to AWS is to use AWS managed policies to assign privileges to, well anything really ;)

<img width="100%" src="/images/blog/2021-02-14-parliament/diagram.png" />
<br />
<br />

Using the Steampipe tables above, we can easily write a query to find any Lambda functions that are using AWS managed IAM policies.

<br />
<Terminal mode="light">
  <TerminalCommand>
    {`
select
  func.name,
  role.name,
  pol.name
from
  aws_lambda_function func,
  aws_iam_role role,
  aws_iam_policy pol
where
  pol.is_aws_managed
  and func.role = role.arn
  and role.attached_policy_arns ? pol.arn;
`}
  </TerminalCommand>
  <TerminalResult>
{`+---------------------+----------------------------------+---------------------------------+
| name                | name                             | name                            |
+---------------------+----------------------------------+---------------------------------+
| function-in-subnet  | function-in-subnet-role-q28s496o | AWSLambdaVPCAccessExecutionRole |
| second-warehouse    | second-warehouse-role-fjqdxi6l   | AWSLambdaVPCAccessExecutionRole |
| second-warehouse    | second-warehouse-role-fjqdxi6l   | IAMFullAccess                   |
| dundies_algo        | dundies_algo-role-323dfg45       | AWSLambdaVPCAccessExecutionRole |
| dundies_algo        | dundies_algo-role-323dfg45       | IAMFullAccess                   |
+---------------------+----------------------------------+---------------------------------+
`}
  </TerminalResult>
</Terminal>
<br />
<br />

## Taking the relationship to the next level

20 seconds after patting yourself on the back for finishing that query, your immediate next question is:  “What privileges does that policy grant to the resource (i.e. function / role / instance / user) that I am working with? For that we needed a way to enumerate the individual policy statements, and the actions in those policy statements. For example, what is the difference between these two IAM policy statements?

<div className="row"> 
  <div className="col col-xs-12 col-md-6 mb-4">
    <Terminal fillParent={true} title="Source">
      <TerminalCommand withPrompt={false} language="json" enableCopyToClipboard={false}>
        {`
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "s3:*",
      "Resource": "*"
    } 
  ]
}
      `}
      </TerminalCommand>
    </Terminal>
  </div>
  <div className="col col-xs-12 col-md-6 mb-4">
    <Terminal fillParent={true} title="Normalized">
      <TerminalCommand language="json" withPrompt={false} enableCopyToClipboard={false}>
        {`
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:C*",
        "s3:D*"
      ],
      "Resource": "*"
    }
  ]
}   
        `}
      </TerminalCommand>
    </Terminal>
  </div>
</div>
<br /> 

The ability to answer those questions relies on having a full list of all IAM permissions available, so you can expand glob syntax and know specifically what actions are allowed by a given policy statement. No problem, I will just go find the AWS API that allows me to query that information…

<video width="100%" autoPlay={true} muted={true} loop={true}>
  <source src="/images/blog/2021-02-14-parliament/lost.mp4" type="video/mp4" />
Your browser does not support the video tag.
</video> 

## Parliament, the hero we need!

Parliament is [an open-source project from Duo Labs](https://github.com/duo-labs/parliament) that is designed to automate the evaluation of IAM policies.  A huge part of the heavy lifting they have done for the community is to build a tool that scrapes [AWS IAM Online Docs](https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_policies_actions-resources-contextkeys.html) to create a canonical list of all documented AWS IAM policy actions.

The Steampipe team was able to build on top of this work, and create a new table [`aws_iam_action`](https://hub.steampipe.io/plugins/turbot/aws/tables/aws_iam_action) that allows us to dynamically expand globbed policy statements to uncover and categorize the specific capabilities of any IAM policy:

<br />
<Terminal mode="light">
  <TerminalCommand>
    {`select * from aws_iam_action where prefix = 's3' limit 10;`}
  </TerminalCommand>
  <TerminalResult>
    {`
+----------------------------+--------+-------------------------+------------------------+---------------------------------------------------------------------------------------------------------------------------------------+
| action                     | prefix | privilege               | access_level           | description                                                                                                                           |
+----------------------------+--------+-------------------------+------------------------+---------------------------------------------------------------------------------------------------------------------------------------+
| s3:deleteobject            | s3     | DeleteObject            | Write                  | Grants permission to remove the null version of an object and insert a delete marker, which becomes the current version of the object |
| s3:createjob               | s3     | CreateJob               | Write                  | Grants permission to create a new Amazon S3 Batch Operations job                                                                      |
| s3:deleteaccesspoint       | s3     | DeleteAccessPoint       | Write                  | Grants permission to delete the access point named in the URI                                                                         |
| s3:createbucket            | s3     | CreateBucket            | Write                  | Grants permission to create a new bucket                                                                                              |
| s3:deleteobjecttagging     | s3     | DeleteObjectTagging     | Tagging                | Grants permission to use the tagging subresource to remove the entire tag set from the specified object                               |
| s3:deleteaccesspointpolicy | s3     | DeleteAccessPointPolicy | Permissions management | Grants permission to delete the policy on a specified access point                                                                    |
| s3:deleteobjectversion     | s3     | DeleteObjectVersion     | Write                  | Grants permission to remove a specific version of an object                                                                           |
| s3:deletebucketwebsite     | s3     | DeleteBucketWebsite     | Write                  | Grants permission to remove the website configuration for a bucket                                                                    |
| s3:abortmultipartupload    | s3     | AbortMultipartUpload    | Write                  | Grants permission to abort a multipart upload                                                                                         |
| s3:deletejobtagging        | s3     | DeleteJobTagging        | Tagging                | Grants permission to remove tags from an existing Amazon S3 Batch Operations job                                                      |
+----------------------------+--------+-------------------------+------------------------+---------------------------------------------------------------------------------------------------------------------------------------+
    `}
  </TerminalResult>
</Terminal>
<br />
<br />

Parliament’s previous work not only allows Steampipe to have a full list of IAM actions, but also provides additional metadata to understand the `access_level` of the action and human readable descriptions of each action's capabilities.

Combining that metadata with our own product team's work to [normalize IAM policy statements](/blog/normalizing-aws-iam-policies-for-automated-analysis) gives us new ways to assess and analyze our IAM risk. We can now, for example, query to find all policies that allow a specific IAM action:

<br />
<Terminal mode="light">
  <TerminalCommand>
    {`select
  p.name,
  action_glob as action_granted,
  a.access_level,
  a.description
from
  aws_iam_policy as p,
  jsonb_array_elements(p.policy_std -> 'Statement') as stmt,
  jsonb_array_elements_text(stmt -> 'Action') as action_glob,
  aws_iam_action a 
where
  a.action LIKE glob(action_glob)
  and a.action = 's3:deletebucket'
  and stmt ->> 'Effect' = 'Allow'
order by
  a.action;`}
  </TerminalCommand>
  <TerminalResult>
    {`
+-----------------------------------+-----------------+--------------+---------------------------------------------------------+
| name                              | action_granted  | access_level | description                                             |
+-----------------------------------+-----------------+--------------+---------------------------------------------------------+
| superuser                         | *               | Write        | Grants permission to delete the bucket named in the URI |
| boundary                          | s3:*            | Write        | Grants permission to delete the bucket named in the URI |
| AmazonDMSRedshiftS3Role           | s3:deletebucket | Write        | Grants permission to delete the bucket named in the URI |
| AWSLambdaFullAccess               | s3:*            | Write        | Grants permission to delete the bucket named in the URI |
| AmazonS3FullAccess                | s3:*            | Write        | Grants permission to delete the bucket named in the URI |
| AmazonElasticMapReduceforEC2Role  | s3:*            | Write        | Grants permission to delete the bucket named in the URI |
| AWSCodeStarServiceRole            | s3:*            | Write        | Grants permission to delete the bucket named in the URI |
| SystemAdministrator               | s3:*            | Write        | Grants permission to delete the bucket named in the URI |
| AmazonMacieSetupRole              | s3:deletebucket | Write        | Grants permission to delete the bucket named in the URI |
| AWSElasticBeanstalkFullAccess     | s3:*            | Write        | Grants permission to delete the bucket named in the URI |
| AmazonElasticMapReduceFullAccess  | s3:*            | Write        | Grants permission to delete the bucket named in the URI |
| AdministratorAccess               | *               | Write        | Grants permission to delete the bucket named in the URI |
...    
    `}
  </TerminalResult>
</Terminal>
<br />
<br />

Or expand all possible permission grants for EC2 instances with an instance profile attached:

<br />
<Terminal mode="light">
  <TerminalCommand>
    {`
select
  i.instance_id,
  r.name as role_name,
  p.title as policy_name,
  a.action,
  a.access_level,
  a.description
from
  aws_ec2_instance as i,
  aws_iam_role as r,
  jsonb_array_elements_text(r.attached_policy_arns) as pol_arn,
  aws_iam_policy as p,
  jsonb_array_elements(p.policy_std -> 'Statement') as stmt,
  jsonb_array_elements_text(stmt -> 'Action') as action_glob,
  glob(action_glob) as action_regex
  join aws_iam_action a on a.action like action_regex
where
  r.instance_profile_arns::jsonb ? i.iam_instance_profile_arn
  and pol_arn = p.arn
  and stmt ->> 'Effect' = 'Allow'
  order by 1,2,3,4,5;
    `}
  </TerminalCommand>
  <TerminalResult>
    {`
+---------------------+-------------------+------------------------------+-------------------------------------------+------------------------+-----------------------------------------------------------------------------------------------------------------------------------+
| instance_id         | role_name         | policy_name                  | action                                    | access_level           | description                                                                                                                       |
+---------------------+-------------------+------------------------------+-------------------------------------------+------------------------+-----------------------------------------------------------------------------------------------------------------------------------+
| i-0e97f373db22dfa3f | ec2_instance_role | AmazonS3FullAccess           | s3:deletebucket                           | Write                  | Grants permission to delete the bucket named in the URI                                                                                          |
| i-0e97f373db22dfa3f | ec2_instance_role | AmazonS3FullAccess           | s3:deletebucketownershipcontrols          | Write                  | Grants permission to delete ownership controls on a bucket                                                                                       |
| i-0e97f373db22dfa3f | ec2_instance_role | AmazonS3FullAccess           | s3:deletebucketpolicy                     | Permissions management | Grants permission to delete the policy on a specified bucket                                                                                     |
| i-0e97f373db22dfa3f | ec2_instance_role | AmazonS3FullAccess           | s3:deletebucketwebsite                    | Write                  | Grants permission to remove the website configuration for a bucket                                                                               |
| i-0e97f373db22dfa3f | ec2_instance_role | AmazonS3FullAccess           | s3:deletejobtagging                       | Tagging                | Grants permission to remove tags from an existing Amazon S3 Batch Operations job                                                                 |
| i-0e97f373db22dfa3f | ec2_instance_role | AmazonS3FullAccess           | s3:deleteobject                           | Write                  | Grants permission to remove the null version of an object and insert a delete marker, which becomes the current version of the object            |
| i-0e97f373db22dfa3f | ec2_instance_role | AmazonS3FullAccess           | s3:deletestoragelensconfigurationtagging  | Tagging                | Grants permission to remove tags from an existing Amazon S3 Storage Lens configuration                                                           |
| i-0e97f373db22dfa3f | ec2_instance_role | AmazonS3FullAccess           | s3:describejob                            | Read                   | Grants permission to retrieve the configuration parameters and status for a batch operations job                                                 |
| i-0e97f373db22dfa3f | ec2_instance_role | AmazonS3FullAccess           | s3:getaccelerateconfiguration             | Read                   | Grants permission to uses the accelerate subresource to return the Transfer Acceleration state of a bucket, which is either Enabled or Suspended |
...
| i-0e97f373db22dfa3f | ec2_instance_role | AmazonSSMManagedInstanceCore | ec2messages:deletemessage                 | Write                  | Deletes a message                                                                                                                                |
| i-0e97f373db22dfa3f | ec2_instance_role | AmazonSSMManagedInstanceCore | ec2messages:failmessage                   | Write                  | Fails a message, signifying the message could not be processed successfully, ensuring it cannot be replied to or delivered again                 |
| i-0e97f373db22dfa3f | ec2_instance_role | AmazonSSMManagedInstanceCore | ec2messages:getendpoint                   | Read                   | Routes traffic to the correct endpoint based on the given destination for the messages                                                           |
| i-0e97f373db22dfa3f | ec2_instance_role | AmazonSSMManagedInstanceCore | ec2messages:getmessages                   | Read                   | Delivers messages to clients/instances using long polling                                                                                        |
| i-0e97f373db22dfa3f | ec2_instance_role | AmazonSSMManagedInstanceCore | ec2messages:sendreply                     | Write                  | Sends replies from clients/instances to upstream service                                                                                         |
...  
    `}
  </TerminalResult>
</Terminal>
<br />
<br />

## Thank you Parliament Team!

We love that the open-source ecosystem allowed Steampipe to leverage Parliament’s work and we hope that others find inspiration to build on top of what Steampipe has added to the conversation. Huge thanks to [@duo_labs](https://twitter.com/duo_labs), [@0xdabbad00](https://twitter.com/0xdabbad00), [@kmcquade3](https://twitter.com/kmcquade3) and all the [contributors on Parliament](https://github.com/duo-labs/parliament/graphs/contributors).
