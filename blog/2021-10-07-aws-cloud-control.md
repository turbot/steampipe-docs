---
id: aws-cloud-control
title: "A deep dive into AWS Cloud Control for asset inventory"
category: "Research"
description: "We dig into AWS Cloud Control and explore how Steampipe can use it to enhance our resource coverage."
author:
  name: Steamipe Team
publishedAt: "2021-10-07T08:00:00"
durationMins: 10
image: /images/blog/2021-10-07-aws-cloud-control/cloudtrail-trace.png
slug: aws-cloud-control
schema: "2021-01-08"
---

Last week Amazon announced the [AWS Cloud Control API: A uniform API to access AWS & Third-Party Services](https://aws.amazon.com/blogs/aws/announcing-aws-cloud-control-api/), which builds on the [CloudFormation Public Registry](https://aws.amazon.com/blogs/aws/introducing-a-public-registry-for-aws-cloudformation/) announced in June. Here at Steampipe we're all about API uniformity. That's true across the [241 AWS tables](https://hub.steampipe.io/plugins/turbot/aws/tables) that we map from AWS APIs, and more broadly across the 45+ other [Steampipe plugins](https://hub.steampipe.io/plugins) that map various APIs to a common set of SQL-queryable tables. 

Can we use Cloud Control to simplify our job of mapping AWS resources to tables you can query in Steampipe? Will it help us expand our coverage of AWS APIs? We dug into this exciting new uber-API to find answers to these questions.

## Listing resources

Cloud Control is a CRUDL (Create/Read/Update/Delete/List) API. Steampipe's
focus is on gathering and analyzing inventories of cloud assets, so we started
by just trying to list resources.

List IAM Users is a typical first query for Steampipe:

```shell
aws cloudcontrol list-resources --type-name AWS::IAM::User

An error occurred (UnsupportedActionException) when calling the ListResources operation:
Resource type AWS::IAM::User does not support LIST action
```

Turns out, many of the most commonly used resource types are **not supported**, including:
```shell
# Not supported
AWS::DynamoDB::Table
AWS::EC2::Instance
AWS::EC2::SecurityGroup
AWS::EC2::Volume
AWS::IAM::Group
AWS::IAM::ManagedPolicy
AWS::IAM::User
AWS::RDS::DBCluster
AWS::RDS::DBInstance
AWS::SNS::Topic
AWS::SQS::Queue
```

Cloud Control does work for multiple resources in these services (e.g. `AWS::IAM::SAMLProvider` or `AWS::EC2::DHCPOptions`), but seems to have the best support for the resources we care about the least? Not a great first impression.

## Region-dependent S3 commands

You can list S3 buckets.

```shell
aws cloudcontrol list-resources --region us-east-1 --type-name AWS::S3::Bucket

{
  "TypeName": "AWS::S3::Bucket",
  "ResourceDescriptions": [
    {
      "Identifier": "10k-with-bucket-kms",
      "Properties": "{\"BucketName\":\"10k-with-bucket-kms\"}", ...
    },
    ...
```

But, be careful, because that only works if called in the `us-east-1` region. Trying list in other regions fails. _Note: fixed by AWS on 7-Oct-2021._

```shell
aws cloudcontrol list-resources --region us-west-1 --type-name AWS::S3::Bucket

An error occurred (UnsupportedActionException) when calling the ListResources operation: 
Resource type AWS::S3::Bucket does not support LIST action
```

Given a bucket identifier from a `list-resources` command, can you read the bucket with a `get-resource` command? Yes, but only if you know -- and specify -- the region. So this fails.

```shell
aws cloudcontrol get-resource --type-name AWS::S3::Bucket \
  --identifier agitated-hertz-bucket-828685001623-us-west-2

An error occurred (GeneralServiceException) when calling the GetResource operation 
(reached max retries: 2): AWS::S3::Bucket Handler returned status FAILED: null 
(Service: S3, Status Code: 400, Request ID: null
```

We had to query the `us-west-2` endpoint in order to read the bucket.

```shell
aws cloudcontrol get-resource --type-name AWS::S3::Bucket --region us-west-2 \
  --identifier agitated-hertz-bucket-828685001623-us-west-2

{
  "TypeName": "AWS::S3::Bucket",
  "ResourceDescription": {
    "Identifier": "agitated-hertz-bucket-828685001623-us-west-2",
    "Properties": "{\"BucketName\":\"agitated-hertz-bucket-828685001623-us-west-2\", ...
  }
}
```

But, since the `list-resources` command doesn't include the bucket's region, how do you know which region to query with `get-resource`?

S3 nerds will understand this is related to its [history as a global namespace](https://www.marksayson.com/blog/s3-bucket-creation-dates-s3-master-regions/). But still, that's exactly the kind of complexity we want an all-encompassing inventory API to shield us from!


## APIs requests are abstracted, but still happening

Using CloudTrail we traced a `get-resource` command for a bucket and found that Cloud Control makes all of the same underlying service API calls that Steampipe uses to populate the response. In this case Cloud Control ran 18 API calls to get all of the bucket's information; the sub-API calls include `GetBucketVersioning`, `GetBucketTagging`, `GetBucketReplication`, etc. Be aware that when you use Cloud Control you are using -- and paying for -- all those API calls. 

We've found it important to query for only what you need, to minimize requests and avoid throttling. If you don't care about a bucket's replication details, why make the `GetBucketReplication` call?

Here's a CloudTrail trace for a read of a KMS key. The `GetResource` cascades to the four sub-API calls shown. They all run, whether or not you need them to.

![](/images/blog/2021-10-07-aws-cloud-control/cloudtrail-trace-2.png)


## Sparse results and missing properties

We found the results for `list-resources` commands to be sparse. Typically a `list-resources` command only reports enough information to enable a follow-on `get-resource` call. We'd rather see more complete results when listing resources, so you can gather information faster, reason about it more effectively, and make fewer API calls.

We also found that properties advertised in a schema aren't always included in list or get results. For example, the schema for `AWS::AppFlow::Flow` includes the properties `KMSArn` and `Tags`. These are never returned, even if they're set on the flows. That was true for a list of flows.

```shell
aws cloudcontrol list-resources --type-name AWS::AppFlow::Flow

{
    "TypeName": "AWS::AppFlow::Flow",
    "ResourceDescriptions": [
        {
            "Identifier": "test-flow",
            "Properties": "{\\"FlowName\\":\\"test-flow\\",
               \\"FlowArn\\":\\"arn:aws:appflow:us-east-1:828685001623:flow/test-flow\\"
             }"
        },
    ]
}
```

(Note that `Properties` is, annoyingly, a JSON string instead of a JSON object.)

It was also true when we used a `get-resource` command to read an individual flow: the same two properties, `KMSArn` and `Tags`, were missing. Strangely, one property, `FlowArn`, appeared when we listed a flow but not when we read it.

## Incomplete schemas

We found missing descriptions even with a given resource type. For example, here's part of the schema for `AWS::CloudTrail::Trail`.

```shell
aws cloudformation describe-type --type RESOURCE \
  --type-name AWS::CloudTrail::Trail \
  | jq --raw-output .Schema | jq .properties --raw-output

{
  "CloudWatchLogsRoleArn": {
    "description": "Specifies the role for the CloudWatch Logs endpoint to assume to write to a user's log group.",
    "type": "string"
  },
  "EnableLogFileValidation": {
    "description": "Specifies whether log file validation is enabled. The default is false.",
    "type": "boolean"  
  },
  ...
  "Tags": {
    "type": "array",
    "uniqueItems": false,
    "insertionOrder": false,
    "items": {
      "$ref": "#/definitions/Tag"
    }
  },
  "TrailName": {
    "type": "string",
    "pattern": "(^[a-zA-Z0-9]$)|(^[a-zA-Z0-9]([a-zA-Z0-9\\._-])*[a-zA-Z0-9]$)",
    "minLength": 3,
    "maxLength": 128
  }
 ...
```

Only some of the elements have descriptions. That doesn't bode well for our plan to auto-generate Steampipe tables based on these schemas. Will we have to mark exceptions and hand-edit them? If we do, how to sync with forthcoming versions of Cloud Control? It's puzzling because Amazon clearly has all the descriptions in the machine-readable format that's used to generate the Go, Python, and other wrappers for the underlying AWS APIs.

## Reliability and debugging

It's early days for Cloud Control, so perhaps not surprising that a lot of things don't yet seem to work as advertised. We expect that'll improve but, given that there will always be glitches, how readily will we be able to diagnose problems? Here's a failure case. 

```shell
aws cloudcontrol list-resources --type-name AWS::KMS::Key

An error occurred (GeneralServiceException) when calling the ListResources 
operation (reached max retries: 2): AWS::KMS::Key Handler returned status FAILED: 
Error occurred during operation 'ListKeys'. (HandlerErrorCode: GeneralServiceException, 
RequestToken: f899f956-9ecd-4ace-8b01-ac356a51619c)
```

We can get specific KMS key information, so we clearly have KMS permissions:

```shell
aws cloudcontrol get-resource --identifier 27b17381-fab8-4eb7-8848-85f8656eee6b \
  --type-name AWS::KMS::Key

{
    "TypeName": "AWS::KMS::Key",
    "ResourceDescription": {
        "Identifier": "27b17381-fab8-4eb7-8848-85f8656eee6b",
        "Properties": "{\"MultiRegion\":false,\"Description\":\"\",...
    }
}
```

It's unclear why it failed or what key it failed on. We wondered if the request token could help but it didn't seem to.

```shell
aws cloudcontrol get-resource-request-status \
  --request-token f899f956-9ecd-4ace-8b01-ac356a51619c

An error occurred (RequestTokenNotFoundException) when calling the 
GetResourceRequestStatus operation: Request with token 
f899f956-9ecd-4ace-8b01-ac356a51619c was not found
```

To make this more challenging, in our testing the Go SDK considers these
`GeneralServiceException` errors to be retryable. Unfortunately, Cloud Control
returns `GeneralServiceException` errors for all problems including obviously
fatal problems like resource not found. Given the criticality of throttling
when collecting inventory, this ambiguity is particularly difficult to
handle.

## Benchmarking Cloud Control and Steampipe

To compare apples to apples we implemented a parallel version of the [aws_cloudtrail_trail](https://hub.steampipe.io/plugins/turbot/aws/tables/aws_cloudtrail_trail) table using the Cloud Control API. Here are the results for the same query run both ways.

```sql
-- Native API calls
select * from aws_cloudtrail_trail;

Time: 190ms
```

```sql
-- API calls via Cloud Control
select * from aws_cloudcontrol_cloudtrail_trail_test;

Time: 1.6s
```

The two versions are ultimately making the same underlying API calls. We don't know how Cloud Control works under the covers, so we won't speculate as to why the native Steampipe version is so much faster.

## Using Cloud Control in Steampipe

The allure of broad resource coverage is strong and important to our users.
But, ultimately we believe that performance, consistency, documentation and
examples are more critical to Steampipe's success.

Unfortunately, given the challenges above we cannot (yet) automate or scale
a high-quality system using Cloud Control. We considered a Terraform-like approach:  
a parallel `awscc` pluginc. But Cloud Control's support 
for inventory isn't as strong as for provisioning, and the issues we've described 
here would entail a lot of work with limited benefit for our users.

Instead, we've chosen to add a single table to the AWS plugin: 
[aws_cloudcontrol_resource](https://hub.steampipe.io/plugins/turbot/aws/tables/aws_cloudcontrol_resource).
This one table can be used to list or get resources of any type. It's a simple
way to quickly extend the wide coverage of Cloud Control to our users while
keeping our high standards for other tables.

Here is a query combining Steampipe's multi-account, multi-region superpowers
with Cloud Control to list AppFlow Flows:

```sql
select
  properties ->> 'FlowName'
  region,
  account_id
from
  aws_cloudcontrol_resource
where
  type_name = 'AWS::AppFlow::Flow'
```

More examples are available in the [table documentation](https://hub.steampipe.io/plugins/turbot/aws/tables/aws_cloudcontrol_resource).

Please give it a try and let us know what you think! Of course, we'd also
welcome suggestions or contributions to better leverage Cloud Control in
Steampipe!
