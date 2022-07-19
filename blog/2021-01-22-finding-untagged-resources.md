---
id: finding-untagged-resources
title: "Corral your untagged cloud cattle"
category: "Case Study"
description: How to quickly find cloud resources that are missing tags
author:
  name: David Boeke
publishedAt: "2021-01-22T16:00:00"
durationMins: 4
image: /images/blog/2021-01-22-finding-untagged-resources/tagged-cattle.jpg
slug: finding-untagged-resources
schema: "2021-01-08"
---

### Who moved my tags?

Tags are critical to cloud work. They are used to identify resources for cost allocation & operational support, while the associated metadata plays an increasing important role in access control and as parameters for governance automation. 

As tags become more important to your cloud operations workflow, your tagging standards will have to evolve to match; however, it is tedious work to identify resources that aren't tagged correctly across dozens of services.

### One tag (schema) to rule them all.

Steampipe's standardized schemas allow you to approach tagging queries with common patterns across resources and clouds. Let's look at the schema for `aws_ec2_key_pair`:
```
> .inspect aws.aws_ec2_key_pair
+-----------------+-------+--------------------------------+
|     Column      | Type  |          Description           |
+-----------------+-------+--------------------------------+
| key_name        | text  | The name of the key pair       |
| key_pair_id     | text  | The ID of the key pair         |
...
| tags            | jsonb | A map of tags for the          |
|                 |       | resource.                      |
+-----------------+-------+--------------------------------+
```

We see above that the EC2 Keypair resource has a `tags` column that is of type `jsonb` and is a map of the tags currently on the resource.  (For more information on how to query json data using SQL, checkout our docs: https://steampipe.io/docs/sql/querying-json).  On the Google Cloud Platform tags are called `labels`, but Steampipe's implementation stays consistent; let's look at `gcp_pubsub_topic`:

```
> .inspect gcp.gcp_pubsub_topic
+--------------+-------+--------------------------------+
|    Column    | Type  |          Description           |
+--------------+-------+--------------------------------+
| name         | text  | The name of the topic.         |
| project      | text  | The Google Project in which    |
|              |       | the resource is located        |
...
| tags         | jsonb | A map of tags for the          |
|              |       | resource.                      |
+--------------+-------+--------------------------------+
```

Here again you see the same `tags` column with the same format.  This allows us to have a standard approach when performing tagging queries across services.

#### Find all EC2 Keypairs without an `owner` tag

```bash
~$ steampipe query "select title from aws_ec2_key_pair where tags ->> 'owner' is null;"

+----------------+
|     title      |
+----------------+
| dschrute       |
| devops_keypair |
+----------------+
``` 

Now that I have a working query I can extend it to check for multiple tags and make it more readable:
```
select 
  title,
  key_pair_id as id,
  'aws_ec2_key_pair' as resource
from 
  aws_ec2_key_pair
where 
  tags ->> 'owner' is null
  or tags ->> 'projectid' is null;
```
```
+----------------+-----------------------+------------------+
|     title      |          id           |     resource     |
+----------------+-----------------------+------------------+
| dschrute       | key-0c753b63a9d0eb0a9 | aws_ec2_key_pair |
| devops_keypair | key-00c81a803763eb16d | aws_ec2_key_pair |
+----------------+-----------------------+------------------+
``` 

Including `id` and `resource` in the result set means we can query multiple services using some sql magic:

```
select title, id, resource from
  (
    select
      title,
      key_pair_id as id,
      'aws_ec2_key_pair' as resource,
      tags
    from
      aws_ec2_key_pair
    union
    select
      title,
      instance_id as id,
      'aws_ec2_instance' as resource,
      tags
    from
      aws_ec2_instance
  ) as untagged
where
  untagged.tags ->> 'owner' is null
  or untagged.tags ->> 'projectid' is null;
```
```
+---------------------+-----------------------+------------------+
|        title        |          id           |     resource     |
+---------------------+-----------------------+------------------+
| ARM Instance        | i-03f3b66e057009f41   | aws_ec2_instance |
| Redhat 8 Test       | i-0dc60dd191cb86539   | aws_ec2_instance |
| Ubuntu 20 Test      | i-00cfa26db9b8a58b6   | aws_ec2_instance |
| dschrute            | key-00c81a803763eb16d | aws_ec2_key_pair |
| devops_keypair      | key-0c753b63a9d0eb0a9 | aws_ec2_key_pair |
+---------------------+-----------------------+------------------+
```

#### This is even more fun across cloud providers.

```
select title, id, resource from
  (
    select
      title,
      key_pair_id as id,
      'aws_ec2_key_pair' as resource,
      tags
    from
      aws_ec2_key_pair
    union
    select
      title,
      instance_id as id,
      'aws_ec2_instance' as resource,
      tags
    from
      aws_ec2_instance
    union
    select
      title,
      vault_uri as id,
      'azure_key_vault' as resource,
      tags
    from
      azure_key_vault
  ) as untagged
where
  untagged.tags ->> 'owner' is null
  or untagged.tags ->> 'projectid' is null;
```
```
+---------------------+------------------------------------+------------------+
|        title        |                 id                 |     resource     |
+---------------------+------------------------------------+------------------+
| ARM Instance        | i-03f3b66e057009f41                | aws_ec2_instance |
| Redhat 8 Test       | i-0dc60dd191cb86539                | aws_ec2_instance |
| Ubuntu 20 Test      | i-00cfa26db9b8a58b6                | aws_ec2_instance |
| dschrute            | key-00c81a803763eb16d              | aws_ec2_key_pair |
| devops_keypair      | key-0c753b63a9d0eb0a9              | aws_ec2_key_pair |
| poctester           | https://poctester.vault.azure.net/ | azure_key_vault  |
+---------------------+------------------------------------+------------------+
```


### Think this is fun? Dive in and try it for yourself today.

Steampipe v0.1.0 is [available for download today](https://steampipe.io/downloads). Install, query and get cloud work done. 

We can’t wait to see what you query, and iterate based on your feedback. If you’d like to help expand the Steampipe universe, or even dive into the CLI code, the whole project is open source (https://github.com/turbot/steampipe) and we’d love to collaborate! 

Keep an eye on https://hub.steampipe.io for the latest supported resource types from both Turbot and the Steampipe community, and for your own personal guided tour of steampipe, checkout our documentation: https://steampipe.io/docs.

If you experience any issues, please report them on our [GitHub issue tracker](https://github.com/turbot/steampipe/issues) or join our [Slack workspace](https://steampipe.io/community/join).