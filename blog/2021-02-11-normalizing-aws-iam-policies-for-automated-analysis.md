---
id: normalizing-aws-iam-policies-for-automated-analysis
title: "Normalizing AWS IAM Policies for Automation"
category: "Research"
description: Uncovering the power of SQL to analyze IAM policies via normalization of the AWS IAM policy syntax.
author:
  name: John Smyth
publishedAt: "2021-02-11T13:00:00"
durationMins: 12
image: /images/blog/2021-02-11-normalizing-aws-iam/hero.jpg
slug: normalizing-aws-iam-policies-for-automated-analysis
schema: "2021-01-08"
---

## Abstract
All interactions with AWS resources are governed by policies implemented by AWS Identity and Access Management (IAM). IAM's scope expanded over time while maintaining backward compatibility; the resulting implementation's optionality makes IAM challenging to analyze programmatically. This article discusses the choices and tradeoffs we made while standardizing the IAM policy format for access via SQL and shows off the potential of IAM Policy analysis when normalized.

<br />
<div className="row"> 
  <div className="col col-xs-12 col-md-6 mb-4">
    <Terminal fillParent={true} title="Source">
      <TerminalCommand withPrompt={false} language="json" enableCopyToClipboard={false}>
        {`
{                                        
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "MustBeEncryptedInTransit",
      "Action": "s3:*",
      "Effect": "Deny",
      "Resource": [
        "arn:aws:s3:::scranton-bucket",
        "arn:aws:s3:::scranton-bucket/*"
      ],   
      "Condition": {   
        "Bool": { 
          "aws:SecureTransport": "false"
        } 
      },
      "Principal": "*"
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
  "Statement": [
    {
      "Action": [
        "s3:*"
      ],
      "Condition": {
        "Bool": {
          "aws:securetransport": [
            "false"
          ]
        }
      },
      "Effect": "Deny",
      "Principal": {
        "AWS": [
          "*"
        ]
      },
      "Resource": [
        "arn:aws:s3:::scranton-bucket",
        "arn:aws:s3:::scranton-bucket/*"
      ],
      "Sid": "MustBeEncryptedInTransit"
    }
  ],
  "Version": "2012-10-17"
}
        `}
      </TerminalCommand>
    </Terminal>
  </div>
</div>
<br /> 

## Why be Normal  ?
AWS IAM policies can have multiple representations that mean the same thing. Converting to a standard, machine-readable format makes them easier to search, analyze, join with other data and to calculate differences.

When working through the normalization process for an API, we generally work with 3 forms of each response:
1. The original **source** form, verbatim (or as verbatim as the API allows). This is usually a string, including whitespace, comments, etc. The value of the keeping the source format varies - it's usually important for YAML but less important for JSON, for example. 
1. The **object** form - A 'usable' form where the source (which is usually a string) is transformed into an object that can be manipulated in a standard way. Such transformation may be lossy - duplicate keys may be removed, comments are typically not included, etc. For steampipe, this format is typically `jsonb`.
1. A **standard** form - A single, canonical form that objects are converted to. The **source** and **object** forms may allow multiple syntaxes to represent a single semantic meaning. In such cases, converting all of these equivalent syntaxes to a single format simplifies and optimizes searching, comparing, and analyzing the object. 

Note that which forms are important vary by API, object, etc. For AWS IAM policies, Steampipe currently returns the object form (in the `policy` column) and the standardized form as `policy_std`. Because the source form is JSON and it sufficiently similar to the object form, we do not currently include it. 

Many of the AWS IAM policy elements in the object form may be single elements or arrays. To search these elements, you don't just need to look for values, you would need to evaluate the **structure** of the result as well. For example, let's says you want to search for policies that allow the `s3:DeleteBucket` action. Without the standard form, you would need to look for both cases:
- Where the action is a string, and has value `"s3:DeleteBucket"`
<br /><br />
 <Terminal fillParent={true} title="Scalar Value Example">
      <TerminalCommand withPrompt={false} language="json" enableCopyToClipboard={false}>
        {`
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "s3:DeleteBucket",
      "Resource": "*"
    }
  ]
}
`}
      </TerminalCommand>
    </Terminal>
<br />
- Where the action is an array, and the array includes the value `"s3:DeleteBucket"`
<br /><br />
    <Terminal fillParent={true} title="Array Value Example">
      <TerminalCommand language="json" withPrompt={false} enableCopyToClipboard={false}>
        {`
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:CreateBucket",
        "s3:DeleteBucket"
      ],
      "Resource": "*"
    }
  ]
}        
        `}
      </TerminalCommand>
    </Terminal>

<br />
In fact, the real world situation is even more complex - The action value may be any case, the resource may also be either string or array, etc. By converting policies to a single, standardized format, Steampipe makes it easier to find what you are looking for regardless of the source format.

## Baseline Normalization Rules
The general guidelines for building the standard policy are:
1. Normalize the structure. In IAM policies, many elements may optionally contain either a single item, or an array of items, in these cases **convert any single item values into a single item  array**.
1. Standardize the case. For values or keys that are case insensitive, **convert to consistent case (lower case)**.
1. Order the elements consistently. Generally, the order of array elements is not important in the IAM policy, so **sort array elements alphabetically** to make them easier to read and easier to to compare/diff. 


## Applicability for each AWS IAM Policy Element
The devil is in the details, and so it is worthwhile to consider each policy element individually.

### `Statement`
A policy can contain a single `Statement` object or an array of `Statement` objects, thus the following are equivalent:

<div className="row">
  <div className="col col-xs-12 col-md-6 mb-4">
    <Terminal fillParent={true} title="Source">
      <TerminalCommand withPrompt={false} language="json" enableCopyToClipboard={false}>
        {`
{
  "Version": "2012-10-17",
  "Statement": {
    "Effect": "Allow",
    "Action": [
      "s3:PutObject"
    ],
    "Resource": [
      "*"
    ]
  }
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
        "s3:PutObject"
      ],
      "Resource": [
        "*"
      ]
    }
  ]
}   
        `}
      </TerminalCommand>
    </Terminal>
  </div>
</div>
<br />  

The standard form will always convert the `Statement` to the array format.

### `Action` and `NotAction`
Like `Statement`, a policy may represent a single `Action` as a string, or one or more actions as an array. In the standard form, the action will always be an **array**. 

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
      "Action": "s3:putobject",
      "Resource": [
        "*"
      ]
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
        "s3:putobject"
      ],
      "Resource": [
        "*"
      ]
    }
  ]
}
        `}
      </TerminalCommand>
    </Terminal>
  </div>
</div>
<br />  

Actions may appear in any case - `s3:PutObject`, `s3:putobject`, and `S3:PUTOBJECT` are valid and equivalent. In the standard form, we convert all actions to **lower case** to simplify equivalency and matching operations. An argument could be made for camel case as well, as the documentation most frequently refers to them in camel case; however, we chose lower case because it is simple and unambiguous. This also has the benefit of avoiding stylistic choices that can arise in camel case (e.g. `IpAddress` v/s `IPAddress`).

Actions may appear in any order. In the standard form, we arrange them **alphabetically**. This makes them easier to read and scan, but it also prevents having to sort them later for programmatic comparison and diffs (which is a common operation and computationally costly operation if done at runtime).
<br />

<div className="row"> 
  <div className="col col-xs-12 col-md-6 mb-4">
    <Terminal fillParent={true} title="Source">
      <TerminalCommand withPrompt={false} language="json" enableCopyToClipboard={false}>
        {`
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "VisualEditor0",
      "Effect": "Allow",
      "Action": [
        "s3:List*",
        "s3:GetObject*",
        "s3:PutObject",
        "ec2:DESCRIBE*",
        "ec2:list*"
      ],
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
  "Statement": [
    {
      "Action": [
        "ec2:describe*",
        "ec2:list*",
        "s3:getobject*",
        "s3:list*",
        "s3:putobject"
      ],
      "Effect": "Allow",
      "Resource": [
        "*"
      ],
      "Sid": "VisualEditor0"
    }
  ],
  "Version": "2012-10-17"
}
        `}
      </TerminalCommand>
    </Terminal>
  </div>
</div>
<br />

### `Principal` and `NotPrincipal`
The `Principal` field may be a string with value `'*'` or a map of principal types (`AWS`, `Service`, `Federated`). Each principal type may have either a single principal string value, or an array of principals.

Following our rules, the single strings are converted to arrays:

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
   "Action": "s3:putobject",
   "Principal": {
    "Service": "cloudtrail.amazonaws.com",
    "AWS": "arn:aws:iam::012345678901:root"
   }
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
        "s3:putobject"
      ],
      "Principal": {
        "AWS": [
          "*"
        ],
        "Service": [
          "cloudtrail.amazonaws.com"
        ]
      }
    }
  ]
}        
        `}
      </TerminalCommand>
    </Terminal>
  </div>
</div>
<br /> 

`"Principal": "*"` is a special case. (For resource-based policies, such as Amazon S3 bucket policies, a wildcard `*` in the principal element specifies all users or public access.) In this case we add a `"*"` element into the Principal.AWS array, as it is effectively the same. 


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
      "Action": [
        "s3:putobject"
      ],
      "Principal": "*"
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
        "s3:putobject"
      ],
      "Principal": {
        "AWS": [
          "*"
        ]
      }
    }
  ]
}        
        `}
      </TerminalCommand>
    </Terminal>
  </div>
</div>
<br /> 

### `Resource` and `NotResource`
Like `Action`, the `Resource` element may contain a single `Resource` as a string, or one or more resources as an array. In the standard form, the resource will always be an **array**. 

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
      "Action": "s3:putobject",
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
        "s3:putobject"
      ],
      "Resource": [
        "*"
      ]
    }
  ]
}        
        `}
      </TerminalCommand>
    </Terminal>
  </div>
</div>
<br /> 

Unlike actions, resources are **case-sensitive** so the original case is maintained in the standardized form. In the standard form, the `Resource` elements are sorted alphabetically.

### `Conditions`
In the Condition element, you build expressions in which you use condition **operators** (equal, less than, etc.) to match the condition **keys** and **values** in the policy against values in the request context:

<Terminal title="Source">
  <TerminalCommand withPrompt={false} language="json" enableCopyToClipboard={false}>
    {`
"Condition" : { 
  "{condition-operator}" : { 
    "{condition-key}" : "{condition-value}" 
  }
}
  `}
  </TerminalCommand>
</Terminal>
 
<br /> 

Note that ***conditions keys are CASE INSENSITIVE***. This is important because it is not typical (or expected) in JSON, but it means that these conditions would be equivalent:

<div className="row"> 
  <div className="col col-xs-12 col-md-6 mb-4">
    <Terminal fillParent={true} title="Source">
      <TerminalCommand withPrompt={false} language="json" enableCopyToClipboard={false}>
        {`
"Condition" : { 
  "StringEquals" : { 
    "AWS:Username" : "johndoe" 
  }
}
      `}
      </TerminalCommand>
    </Terminal>
  </div>
  <div className="col col-xs-12 col-md-6 mb-4">
    <Terminal fillParent={true} title="Normalized">
      <TerminalCommand language="json" withPrompt={false} enableCopyToClipboard={false}>
        {`
"Condition" : { 
  "StringEquals" : { 
    "aws:username" : "johndoe" 
  }
}
        `}
      </TerminalCommand>
    </Terminal>
  </div>
</div>
<br /> 

In the standard form, we always convert the condition keys to **lower case**. Note that the condition **values** on the hand **are case sensitive** so we we leave them in the original case in the standardized policy. 

Like other fields in IAM policies, the condition values can either be a string or an array of strings - we always convert them to arrays for easier searching and we remove duplicates. 

Condition value items can be string, boolean, or numeric depending on the operator and key, but wherever a boolean or integer is accepted in the policy, a string representation is also accepted - e.g. you can use `true` or `"true"`. While it would probably be ideal to cast to the ACTUAL type based on the operator, we currently cast them all to strings - It's simpler, and the net effect is the same for use in Postgres (PostgreSQL json functions only return text or jsonb, so you need to cast them explicitly in your query anyway.)

<div className="row"> 
  <div className="col col-xs-12 col-md-6 mb-4">
    <Terminal fillParent={true} title="Source">
      <TerminalCommand withPrompt={false} language="json" enableCopyToClipboard={false}>
        {`
"Condition": {
  "Bool": { 
    "aws:SecureTransport": "false" 
  }
}
        `}
      </TerminalCommand>
    </Terminal>
  </div>
  <div className="col col-xs-12 col-md-6 mb-4">
    <Terminal fillParent={true} title="Normalized">
      <TerminalCommand language="json" withPrompt={false} enableCopyToClipboard={false}>
        {`
"Condition": {
  "Bool": { 
    "aws:securetransport": [
      "false"
    ] 
  }
}
      `}
      </TerminalCommand>
    </Terminal>
  </div>
</div>
<br /> 

# How it works in practice

## Using the `policy_std` column

To compare the policy to the standardized policy, select both columns:

<br />
<Terminal mode="light">
  <TerminalCommand>
    {`
select 
  jsonb_pretty(policy), 
  jsonb_pretty(policy_std) 
from 
  aws_s3_bucket 
where 
  title = 'vandelay-ind-bucket';`}
  </TerminalCommand>
  <TerminalResult>
{`+----------------------------------------------+----------------------------------------------+
| jsonb_pretty                                 | jsonb_pretty                                 |
+----------------------------------------------+----------------------------------------------+
| {                                            | {                                            |
|   "Version": "2012-10-17",                   |   "Version": "2012-10-17",                   |
|   "Statement": [                             |   "Statement": [                             |
|     {                                        |     {                                        |
|       "Sid": "MustBeEncryptedInTransit",     |       "Sid": "MustBeEncryptedInTransit",     |
|       "Action": "s3:*",                      |       "Action": [                            |
|       "Effect": "Deny",                      |         "s3:*"                               |
|       "Resource": [                          |       ],                                     |
|         "arn:aws:s3:::vandelay-ind-bucket",  |       "Effect": "Deny",                      |
|         "arn:aws:s3:::vandelay-ind-bucket/*" |       "Resource": [                          |
|       ],                                     |         "arn:aws:s3:::vandelay-ind-bucket",  |
|       "Condition": {                         |         "arn:aws:s3:::vandelay-ind-bucket/*" |
|         "Bool": {                            |       ],                                     |
|           "aws:SecureTransport": "false"     |       "Condition": {                         |
|         }                                    |         "Bool": {                            |
|       },                                     |           "aws:securetransport": [           |
|       "Principal": "*"                       |               "false"                        |
|     }                                        |           ]                                  |
|   ]                                          |         }                                    |
| }                                            |       },                                     |
|                                              |       "Principal": {                         |
|                                              |         "AWS": [                             |
|                                              |           "*"                                |
|                                              |         ]                                    |
|                                              |       }                                      |
|                                              |     }                                        |
|                                              |   ]                                          |
|                                              | }                                            |
+----------------------------------------------+----------------------------------------------+`}
  </TerminalResult>
</Terminal>
<br />
<br />

Because the policies are standardized, we can now use the `policy_std` columns to evaluate and analyze our IAM policies without having to convert case or account for optional use of scalar values vs array values! 

### Query all S3 buckets that enforce HTTPS:

<br />
<Terminal mode="light">
  <TerminalCommand>
    {`
select
  name,
  p as principal,
  a as action,
  s ->> 'Effect' as effect,
  s ->> 'Condition' as conditions
from
  aws_s3_bucket,
  jsonb_array_elements(policy_std -> 'Statement') as s,
  jsonb_array_elements_text(s -> 'Principal' -> 'AWS') as p,
  jsonb_array_elements_text(s -> 'Action') as a,
  jsonb_array_elements_text(
  s -> 'Condition' -> 'Bool' -> 'aws:securetransport'
  ) as ssl
where
  p = '*'
  and s ->> 'Effect' = 'Deny'
  and ssl :: bool = false;
`}
  </TerminalCommand>
  <TerminalResult>
{`+-------------------------------+-----------+--------+--------+----------------------------------------------+
| name                          | principal | action | effect | conditions                                   |
+-------------------------------+-----------+--------+--------+----------------------------------------------+
| terraform-2019080523872123001 | *         | s3:*   | Deny   | {"Bool": {"aws:securetransport": ["false"]}} |
| cf-templates-ldox7k-us-east-1 | *         | s3:*   | Deny   | {"Bool": {"aws:securetransport": ["false"]}} |
| turbot-demo-20211204          | *         | s3:*   | Deny   | {"Bool": {"aws:securetransport": ["false"]}} |
| steampipe-demo-1-20201204     | *         | s3:*   | Deny   | {"Bool": {"aws:securetransport": ["false"]}} |
+-------------------------------+-----------+--------+--------+----------------------------------------------+`}
  </TerminalResult>
</Terminal>
<br />
<br />

### Find buckets that grant external access in their resource policy:

<br />
<Terminal mode="light">
  <TerminalCommand>
    {`select
  title,
  p as principal,
  a as action,
  s ->> 'Effect' as effect,
  s -> 'Condition' as conditions
from
  aws_s3_bucket,
  jsonb_array_elements(policy_std -> 'Statement') as s,
  jsonb_array_elements_text(s -> 'Principal' -> 'AWS') as p,
  string_to_array(p, ':') as pa,
  jsonb_array_elements_text(s -> 'Action') as a
where
  s ->> 'Effect' = 'Allow'
  and (
  pa[5] != account_id
  or p = '*'
  );`}
  </TerminalCommand>
  <TerminalResult>
    {`
+-------------------------------+-------------------------------------+-----------------+--------+------------+
| title                         | principal                           | action          | effect | conditions |
+-------------------------------+-------------------------------------+-----------------+--------+------------+
| splog-000000000000-us-east-2  | arn:aws:iam::123456789012:root      | s3:putobject    | Allow  |            |
| splog-000000000000-us-east-2  | arn:aws:iam::123456789012:user/logs | s3:getbucketacl | Allow  |            |
| splog-000000000000-us-east-2  | arn:aws:iam::123456789012:user/logs | s3:putobject    | Allow  |            |
| splog-000000000000-us-east-1  | arn:aws:iam::123456789012:root      | s3:putobject    | Allow  |            |
| splog-000000000000-us-east-1  | arn:aws:iam::123456789012:user/logs | s3:getbucketacl | Allow  |            |
| splog-000000000000-us-east-1  | arn:aws:iam::123456789012:user/logs | s3:putobject    | Allow  |            |
+-------------------------------+-------------------------------------+-----------------+--------+------------+    
    `}
  </TerminalResult>
</Terminal>
<br />
<br />

### Find IAM policies that grant full ('*') access:

<br />
<Terminal mode="light">
  <TerminalCommand>
    {`select
  name,
  arn,
  action,
  s ->> 'Effect' as effect
from
  aws_iam_policy,
  jsonb_array_elements(policy_std -> 'Statement') as s,
  jsonb_array_elements_text(s -> 'Action') as action
where
  action in ('*', '*:*')
  and s ->> 'Effect' = 'Allow';`}
  </TerminalCommand>
  <TerminalResult>
    {`
+---------------------+---------------------------------------------+--------+--------+
| name                | arn                                         | action | effect |
+---------------------+---------------------------------------------+--------+--------+
| superuser           | arn:aws:iam::000000000000:policy/superuser  | *      | Allow  |
| AdministratorAccess | arn:aws:iam::aws:policy/AdministratorAccess | *      | Allow  |
+---------------------+---------------------------------------------+--------+--------+       
    `}
  </TerminalResult>
</Terminal>
<br />
<br />

### Wildcard Expansion

We can join the actions from policies with the `aws_iam_action` table to view all the permissions granted, expanding any wildcards present in the current policies:

<br />
<Terminal mode="light">
  <TerminalCommand>
    {`select
  a.action,
  a.access_level,
  a.description
from
  aws_iam_policy as p,
  jsonb_array_elements(p.policy_std -> 'Statement') as stmt,
  jsonb_array_elements_text(stmt -> 'Action') as action_glob
join aws_iam_action a ON a.action LIKE glob(action_glob)
where
  p.name = 'AmazonEC2ReadOnlyAccess'
  and stmt ->> 'Effect' = 'Allow'
order by
  a.action;`}
  </TerminalCommand>
  <TerminalResult>
    {`
+---------------------------------------------------------------------+--------------+-------------------------------------------------
| action                                                              | access_level | description
+---------------------------------------------------------------------+--------------+-------------------------------------------------
| autoscaling:describeaccountlimits                                   | List         | Describes the current Auto Scaling resource limi
| autoscaling:describeadjustmenttypes                                 | List         | Describes the policy adjustment types for use wi
| autoscaling:describeautoscalinggroups                               | List         | Describes one or more Auto Scaling groups. If a
| autoscaling:describeautoscalinginstances                            | List         | Describes one or more Auto Scaling instances. If
| autoscaling:describeautoscalingnotificationtypes                    | List         | Describes the notification types that are suppor
| autoscaling:describeinstancerefreshes                               | List         | Grants permission to describe one or more instan
| autoscaling:describelaunchconfigurations                            | List         | Describes one or more launch configurations. If
... 
    `}
  </TerminalResult>
</Terminal>
<br />
<br />

There are a lot of rows there, maybe some aggregation would help understand it better:

<br />
<Terminal mode="light">
  <TerminalCommand>
    {`
select
  a.prefix,
  a.access_level,
  count(a.action)
from
  aws_iam_policy as p,
  jsonb_array_elements(p.policy_std -> 'Statement') as stmt,
  jsonb_array_elements_text(stmt -> 'Action') as action_glob
join aws_iam_action a ON a.action LIKE glob(action_glob)
where
  p.name = 'AmazonEC2ReadOnlyAccess'
  and stmt ->> 'Effect' = 'Allow'
group by
  a.prefix,
  a.access_level
order by 
  count desc;
    `}
  </TerminalCommand>
  <TerminalResult>
    {`
+----------------------+--------------+-------+
| prefix               | access_level | count |
+----------------------+--------------+-------+
| ec2                  | List         | 112   |
| autoscaling          | List         | 18    |
| elasticloadbalancing | Read         | 16    |
| ec2                  | Read         | 7     |
| cloudwatch           | Read         | 6     |
| cloudwatch           | List         | 1     |
| autoscaling          | Read         | 1     |
| elasticloadbalancing | List         | 1     |
+----------------------+--------------+-------+
    `}
  </TerminalResult>
</Terminal>
<br />
<br />

Flipping that search around, we can also find all policies that grant a given action (including via wildcard):

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

## Leveraging what we built

The Steampipe CLI is great (and fun) for interactive introspection, but you can also build on top of our data in a few ways:

1. Run a query and [export it as JSON or CSV](https://steampipe.io/docs/reference/dot-commands#output).
2. [Run Steampipe as a service](https://steampipe.io/docs/using-steampipe/integrations) and connect to it with any PostgreSQL client.
3. [Leverage our `Go` source library](https://github.com/turbot/steampipe-plugin-aws/blob/main/aws/canonical_policy.go) 

### References:
- [Steampipe Hub](https://hub.steampipe.io): [aws_iam_action table](https://hub.steampipe.io/plugins/turbot/aws/tables/aws_iam_action)
- [Steampipe Hub](https://hub.steampipe.io): [aws_iam_policy table](https://hub.steampipe.io/plugins/turbot/aws/tables/aws_iam_policy)
- [AWS Docs: IAM Policy Grammar](https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_policies_grammar.html#policies-grammar-bnf)
- [How to Audit IAM Policies](https://summitroute.com/blog/2019/03/26/how_to_audit_aws_iam_and_resource_policies/)
- [AWS IAM Linting Library](https://github.com/duo-labs/parliament)

### Feedback
Have something to add to the conversation? [Join our Slack workspace](https://steampipe.io/community/join)!