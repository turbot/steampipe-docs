---
id: aws-iam-policy-wildcards-reference
title: "The Hitchhiker's Guide to IAM Policy Wildcards"
category: "Reference"
description: "A quick reference to AWS IAM wildcard usage."
summary: "The ultimate quick reference guide to AWS IAM wildcard usage questions."
author:
  name: David Boeke
  twitter: "@boeke"
publishedAt: "2021-02-17T08:00:00"
durationMins: 10
image: /images/blog/2021-02-16-aws-iam-wildcard-reference/wildcard.jpg
slug: aws-iam-policy-wildcards-reference
schema: "2021-01-08"
---

## Caution! Wildcards ahead.

All AWS IAM identities (users, groups, roles) and many other AWS resources (e.g. S3 buckets, SNS Topics, etc) 
rely on IAM policies to define their permissions. It is often necessary (or desirable) to create policies that match to 
multiple resources, especially when the resource names include a hash or random component that is not known at design time.

Wildcards can be used to enable those use cases and therefore are incredibly powerful (and dangerous).

## Wildcard Reference

Available wildcards are:
- `?` matches any single character in a string (or ARN).
- `*` can be used by itself to indicate `all values`.
- `*` can also be used within a string (or ARN) to match zero or more characters.

IAM Policies are JSON documents that are composed of an optional header and one or more `statements`. 
Each `<statement_block>` is further composed of required and optional `elements`, a few of which do not support use of wildcards:

| **Element**   | **Usage**     | **All<br />Resource<br />Support** | **Multi&#8209;Char<br />Wildcard<br />Support** | **Single&#8209;Char<br />Wildcard<br />Support** |
|-----------|------------------------------------------------------------------------------------------------------------------|----------------------------|-----------------------------------|------------------------------------|
| **Sid**       | `"Sid": "{sid_string}"`                                                                                                 | No                         | No                                | No                                 |
| **Effect**    | `"Effect": ("Allow" or "Deny")`                                                                                         | No                         | No                                | No                                 |
| **Principal** | `("Principal" or "NotPrincipal") :` <br /> &nbsp;&nbsp;&nbsp;&nbsp;` ("*" or <principal_map>)`                                                            | Yes                        | No                               | No                                |
| **Action**    | `("Action" or "NotAction") :` <br /> &nbsp;&nbsp;&nbsp;&nbsp;` ("*" or [<action_string>, ...])`        | Yes                        | Yes                               | Yes                                |
| **Resource**  | `("Resource" or "NotResource") :` <br /> &nbsp;&nbsp;&nbsp;&nbsp;` ("*" or [<resource_string>, ...]` | Yes                        | Yes                               | Yes                                |
| **Condition** | `"Condition" : { <condition_map> }`                                                                                     | No                       | Yes                               | Yes                                |

## Principal Element
`("Principal" | "NotPrincipal") : ("*" | <principal_map>)` 

`*` can be used inside a `<principal_block>` to specify everyone (or anonymous) but it **cannot be used as a string wildcard** to match on multiple principals:

### Valid examples:    

```
"Principal": "*"

"Principal": { "AWS": "*" }

"Principal": { "AWS": [
      "arn:aws:iam::111222333444:user/dschrute",
      "arn:aws:iam::444455556666:root"
    ]
  }

"Principal": { "AWS": [
      "*",
      "arn:aws:iam::444455556666:root"
    ]
  }
```

### `Invalid` examples:
```
"Principal": { "AWS": "arn:aws:iam::444455556666:*" }

"Principal": { "AWS": "arn:aws:sts::777888998900:assumed-role/superuser/*" }
```

## Action Element
`("Action" | "NotAction") : ("*" | [<action_string>, <action_string>, ...])`

- A single `*` can be used by itself in the `<action_block>` to specify all actions.
- Multiple `*`'s can be used as string wildcards in the `<action_string>`, but not in the `namespace`.
- Multiple `?`'s can be used to match any single char in the `action name` part of the `<action_string>`. <br /> { * This is undocumented and seems of little value, but it works. *}

### Valid examples:   

```
"Action": "*"

"Action": "s3:*"

"Action":[
  "s3:Get*",
  "s3:List*"
]

"Action": "iam:*AccessKey*"

"Action": "iam:*AccessKey?"
```


### `Invalid` examples:
```
"Action": "s*:*"

"Action": "s??:*"
```

## Resource Element
`("Resource" | "NotResource") : ("*" | [<resource_string>, <resource_string>, ...]`

- A single `*` can be used by itself in the `<resource_block>` to specify all resources.
- Multiple `*`'s can be used as string wildcards in the `<resource_string>`.
- Multiple `?`'s can be used to match single chars in the `<resource_string>`.

### Valid examples: 
```
"Resource": "*"

"Resource": "arn:aws:sns:us-east-2:*:aaa_api_handler"    // All Accounts 

"Resource": "arn:*:sns:*:*:aaa_api_handler"              // partition, region and account wildcards

"Resource": "arn:aws:sns:*:111222333444:aaa?api?handler" // Any region and not sure if using `-` or `_`
```
### `Invalid` examples:

```
"Resource": "arn:aws:*:aws_api_handler"   // Spanning sections of the ARN is not allowed
```

## Condition Element

The optional `<condition_block>` specifies the conditions under which the policy is in effect.  The `<condition_block>` is comprised of three parts: 

`"Condition" : { "{condition-operator}" : { "{condition-key}" : "{condition-value}" }}`

Wildcards are allowed as part of the `{condition-value}` for a subset of `string` and `arn` condition operators:


**Condition Operator**      | **Allows Wildcards**
--------------------------|-----------------------------
ArnEquals                 |  **Yes**
ArnLike                   |  **Yes**
ArnNotEquals              |  **Yes**
ArnNotLike                |  **Yes**
ArnEqualsIfExists         |  **Yes**
ArnLikeIfExists           |  **Yes**
ArnNotEqualsIfExists      |  **Yes**
ArnNotLikeIfExists        |  **Yes**
Bool                      | `No`
BinaryEquals              | `No`
IpAddress                 | `No`
NotIpAddress              | `No`
Null                      | `No`
Numeric*                  | `No`
StringEquals              | `No`
StringNotEquals           | `No`
StringEqualsIgnoreCase    | `No`
StringNotEqualsIgnoreCase | `No`
StringLike                |  **Yes**
StringNotLike             |  **Yes**
StringLikeIfExists        |  **Yes**
StringNotLikeIfExists     |  **Yes**

### Valid examples: 
```
"Condition": {"StringNotLike": {"aws:PrincipalTag/cost-center": "*scranton*"}}

"Condition": {"ArnLike": {"aws:SourceArn": "arn:aws:sns:*"}}

"Condition": {
  "StringLikeIfExists": {
      "ec2:InstanceType": [
          "t1.*",
          "t2.*",
          "m3.*"
]}}
```

### Note: ARNs and Strings behave differently:

ARNs and String conditionals work slightly differently when it comes to wildcards:

- For `string` types wildcards are only supported in the `StringLike*` and `StringNotLike*` condition operations, the `StringEquals` and `StringNotEquals` varients do not support them:
  
  **Invalid**: `"Condition" : { "StringEquals" : { "aws:username" : "*schrute*" }}`

- However `ArnEquals` and `ArnLike` are functionally equivalent and both support wildcards.
  
  **Valid**:  `"Condition": {"ArnEquals": {"aws:SourceArn": "arn:aws:sns:*"}}`


## Bonus: How to escape special characters:

Since wildcards match multiple values, how would you go about explictly matching against a string that includes `*` `?` or `$`? The variable syntax introduced in the latest version of the IAM policy language includes escape sequences for this eventuality:

- `${*}` - use where you need an * (asterisk) character.
- `${?}` - use where you need a ? (question mark) character.
- `${$}` - use where you need a $ (dollar sign) character.

### Valid Example:
```
"Condition": {
  "StringLike": {
    "aws:PrincipalTag/department": "sales${*}service"
  }
} 
// would match a tag {"department": "sales*service"}
```

## Aditional Resources

- [IAM Grammar Reference](https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_policies_grammar.html)
- [Action Reference Docs](https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_policies_elements_action.html)
- [Resource Reference Docs](https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_policies_elements_resource.html)
- [Variables and Tags](https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_policies_variables.html)
- [Condition Operators](https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_policies_elements_condition_operators.html)
- [IAM Policy Simulator](https://policysim.aws.amazon.com/home/index.jsp)
