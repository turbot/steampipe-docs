---
title: Batch Queries
sidebar_label: Batch Queries
---
# Batch Queries

Steampipe queries can provide valuable insight into your cloud configuration, and the interactive client is a powerful tool for ad hoc queries and exploration.  Often, however, you will write a query that you will want to re-run in the future, either manually or perhaps as a cron job.  Steampipe allows you to save your query to a file, and pass the file into the `steampipe query` command.

For example, lets create a query to find S3 buckets where versioning is not enabled.  Paste the following snippet into a file named `s3_versioning_disabled.sql`:

```sql
select
  name,
  region,
  account_id,
  versioning_enabled
from
  aws_s3_bucket
where
  not versioning_enabled;
```

We can now run the query by passing the file name to `steampipe query`
```bash
steampipe query s3_versioning_disabled.sql
```

You can even run multiple sql files by passing a glob or a space separated list of file names to the command:
```bash
steampipe query *.sql
```


## Query output formats
By default, the output format is `table`, which provides a tabular, human-readable view:
```
+-----------------------+---------------+-----------+
|        vpc_id         |  cidr_block   |   state   |
+-----------------------+---------------+-----------+
| vpc-0de60777fdfd2ebc7 | 10.66.8.0/22  | available |
| vpc-9d7ae1e7          | 172.31.0.0/16 | available |
| vpc-0bf2ca1f6a9319eea | 172.16.0.0/16 | available |
+-----------------------+---------------+-----------+
```
  
You can use the `--output` argument to output in a different format.  To print your output to json, specify `--output json`:

```
$ steampipe query "select vpc_id, cidr_block,state from aws_vpc" --output json
[
 {
  "cidr_block": "10.66.8.0/22",
  "state": "available",
  "vpc_id": "vpc-0de60777fdfd2ebc7"
 },
 {
  "cidr_block": "172.31.0.0/16",
  "state": "available",
  "vpc_id": "vpc-9d7ae1e7"
 },
 {
  "cidr_block": "172.16.0.0/16",
  "state": "available",
  "vpc_id": "vpc-0bf2ca1f6a9319eea"
 }
]

```

To print your output to csv, specify `--output csv`:

```
$ steampipe query "select vpc_id, cidr_block,state from aws_vpc" --output csv
vpc_id,cidr_block,state
vpc-0de60777fdfd2ebc7,10.66.8.0/22,available
vpc-9d7ae1e7,172.31.0.0/16,available
vpc-0bf2ca1f6a9319eea,172.16.0.0/16,available
```

Redirecting the output to CSV is common way to export data for use in other tools, such as Excel:

```
steampipe query "select vpc_id, cidr_block,state from aws_vpc" --output csv > vpcs.csv
```


To use a different delimiter, you can specify the `--separator` argument.  For example, to print to a pipe-separated format:

```
$ steampipe query "select vpc_id, cidr_block,state from aws_vpc" --output csv --separator '|'
vpc_id|cidr_block|state
vpc-0bf2ca1f6a9319eea|172.16.0.0/16|available
vpc-9d7ae1e7|172.31.0.0/16|available
vpc-0de60777fdfd2ebc7|10.66.8.0/22|available
```
