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


## Named Queries
Steampipe also allows you to run **named queries** defined in [mods](mods/overview). 

Creating your own named queries is simple.  First, you need to create a mod for your queries:

```bash 
mkdir my-queries
```

By default, Steampipe looks for mods in the current directory, though you can specify a different directory with the `-mod-location` argument.  Lets change to that directory and initialize the mod:

```bash 
cd my-queries
steampipe mod init
```

Steampipe will create a **query** object for every `.sql` file in your mod directory, though you can also define [query](reference/mod-resources/query) resources using HCL in `.sp` files if you prefer.

If you have not done so already, create the `s3_versioning_disabled.sql` file from the previous example in your mod folder.

You can now run your query by name in an interactive session or from from command line.

 Start the interactive query shell:
```bash
steampipe query
```

You can run your query by name:
```sql
query.s3_versioning_disabled
```

Your saved queries even show up in the auto-complete list, making them easier to find and recall!

You can even run the named query in batch mode:
```bash
steampipe query "query.s3_versioning_disabled"
```

Steampipe makes it easy to build a library of custom queries that you can effortlessly recall and re-use!


