---
title: .inspect
sidebar_label: .inspect
---



## .inspect

Inspect the available connections, tables, and columns.

### Usage
```
.inspect [connection][.table]
```
### Examples
List all active connections:
```
.inspect
```

List all tables in the aws connection:
```
.inspect aws
```

List the columns in the aws_ec2_instance table:
```
.inspect aws.aws_ec2_instance
```
