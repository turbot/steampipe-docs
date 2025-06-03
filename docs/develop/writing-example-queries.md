---
title: Writing Example Queries
sidebar_label: Writing Example Queries
---

# Writing Example Queries

To help you get started on creating useful example queries, we've compiled a
list of potential topics that can be used as guidelines and includes some
basic and advanced examples of these from existing tables.

Please note though that the topics below are just suggestions and example
queries are not limited to just these topics.

- Security
  - Access policies
  - Credential expiration and rotation
  - Encryption
  - Versioning
- Operations
  - Audit logging
  - Data retention and backups
  - Tagging
- Cost management
  - Capacity optimization
  - Underutilized resources

## Basic Examples

### aws_s3_bucket

````markdown
### Basic info

```sql
select
  name,
  region
from
  aws_s3_bucket;
```

### List buckets which do not have default encryption enabled

```sql
select
  name,
  server_side_encryption_configuration
from
  aws_s3_bucket
where
  server_side_encryption_configuration is null;
```

### List buckets that are missing required tags

```sql
select
  name,
  tags
from
  aws_s3_bucket
where
  tags -> 'owner' is null
  or tags -> 'app_id' is null;
```
````

### aws_ebs_volume

````markdown
### Basic info

```sql
select
  volume_id,
  volume_type,
  encrypted,
  region
from
  aws_ebs_volume;
```

### List unencrypted volumes

```sql
select
  volume_id,
  encrypted
from
  aws_ebs_volume
where
  not encrypted;
```

### Count the number of volumes by volume type

```sql
select
  volume_type,
  count(volume_type) as count
from
  aws_ebs_volume
group by
  volume_type;
```

### List unattached volumes

```sql
select
  volume_id,
  volume_type
from
  aws_ebs_volume
where
  attachments is null;
```
````

## Advanced Examples

### Joining information from the AWS EC2 instance and volume tables

````markdown
### List unencrypted volumes attached to each instance

```sql
select
  i.instance_id,
  vols -> 'Ebs' ->> 'VolumeId' as vol_id,
  vol.encrypted
from
  aws_ec2_instance as i
  cross join
    jsonb_array_elements(block_device_mappings) as vols
  join
    aws_ebs_volume as vol
    on vol.volume_id = vols -> 'Ebs' ->> 'VolumeId'
where
  not vol.encrypted;
```
````

### Joining information from the Azure Compute virtual machine and network security group tables

````markdown
### Get network security group rules for all security groups attached to a virtual machine

```sql
select
  vm.name,
  nsg.name,
  jsonb_pretty(security_rules)
from
  azure.azure_compute_virtual_machine as vm,
  jsonb_array_elements(vm.network_interfaces) as vm_nic,
  azure_network_security_group as nsg,
  jsonb_array_elements(nsg.network_interfaces) as nsg_int
where
  lower(vm_nic ->> 'id') = lower(nsg_int ->> 'id')
  and vm.name = 'warehouse-01';
```
````

### Querying complex jsonb columns for AWS S3 buckets

````markdown
### List buckets that enforce encryption in transit

```sql
select
  name,
  p as principal,
  a as action,
  s ->> 'Effect' as effect,
  s ->> 'Condition' as conditions,
  ssl
from
  aws_s3_bucket,
  jsonb_array_elements(policy_std -> 'Statement') as s,
  jsonb_array_elements_text(s -> 'Principal' -> 'AWS') as p,
  jsonb_array_elements_text(s -> 'Action') as a,
  jsonb_array_elements_text( s -> 'Condition' -> 'Bool' -> 'aws:securetransport' ) as ssl
where
  p = '*'
  and s ->> 'Effect' = 'Deny'
  and ssl :: bool = false;
```
````
