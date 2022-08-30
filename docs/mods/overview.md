---
title: Build Mods
sidebar_label: Build Mods
---
# Steampipe Mods


A Steampipe **mod** is a portable, versioned collection of related Steampipe resources such as dashboards, benchmarks, queries, and controls. Steampipe mods and mod resources are defined in HCL, and distributed as simple text files.  Modules can be found on the [Steampipe Hub](https://hub.steampipe.io), and may be shared with others from any public git repository. 

Mods provide an easy way to share dashboards, benchmarks, and other resources.

You can install a mod by cloning the repository:
```bash
git clone https://github.com/turbot/steampipe-mod-aws-compliance.git
```

Unlike plugins which are installed to the `~/.steampipe` directory, mods are installed into (and loaded from) the current working directory.  Alternatively, you may specify a path with the `--workspace--chdir` argument:

```bash
steampipe query --workspace-chdir steampipe-mod-aws-compliance
```

Notice that when running `steampipe query` from the workspace directory, the mod's queries and controls appear in the auto-complete, and you can run them by name:

```
> query.s3_bucket_versioning_enabled
+--------------------------------------------------------------+--------+---------------------------------------------------------------------+----------------+--------------+
| resource                                                     | status | reason                                                              | region         | account_id   |
+--------------------------------------------------------------+--------+---------------------------------------------------------------------+----------------+--------------+
| arn:aws:s3:::vandelay-industries-georges-bucket01            | ok     | vandelay-industries-georges-bucket01 versioning enabled.            | us-east-1      | 876515858155 |
| arn:aws:s3:::aws-cloudtrail-logs-876515858155-8592de2c       | ok     | aws-cloudtrail-logs-876515858155-8592de2c versioning enabled.       | us-east-1      | 876515858155 |
| arn:aws:s3:::vandelay-industries-cosmos-bucket               | ok     | vandelay-industries-cosmos-bucket versioning enabled.               | us-east-1      | 876515858155 |
| arn:aws:s3:::vanedaly-replicated-bucket-01                   | ok     | vanedaly-replicated-bucket-01 versioning enabled.                   | us-east-1      | 876515858155 |
| arn:aws:s3:::vandelay-industries-elaines-bucket              | ok     | vandelay-industries-elaines-bucket versioning enabled.              | us-east-1      | 876515858155 |
| arn:aws:s3:::vandelay-industries-vandelay01                  | ok     | vandelay-industries-vandelay01 versioning enabled.                  | us-east-1      | 876515858155 |
| arn:aws:s3:::vandelay-industries-darins-bucket               | ok     | vandelay-industries-darins-bucket versioning enabled.               | us-east-1      | 876515858155 |
+--------------------------------------------------------------+--------+---------------------------------------------------------------------+----------------+--------------+
```


If your mod contains dashboards, you can view them with the `steampipe dashboard` command. Simply change to the directory that contains the mod and run:
```bash
steampipe dashboard
```

You can also run `steampipe check` to run controls and benchmarks defined in the current directory:

```bash
steampipe check all 
```

When steampipe runs, it loads all the resources defined in the mod and its dependencies and makes their resources available to `steampipe query`, `steampipe check`, and `steampipe dashboard`.  Steampipe can even create a set of introspection tables that allow you to query the mod resources in the workspace.  For performance reasons, introspection is disabled by default, however you can enable it by setting the [STEAMPIPE_INTROSPECTION](reference/env-vars/steampipe_introspection) environment variable:

```bash
export STEAMPIPE_INTROSPECTION=info
```

Once enabled, you can query the introspection tables.  For example, you can list all the benchmarks in the workspace:

```
> select resource_name from steampipe_benchmark order by resource_name
+----------------------+
| resource_name        |
+----------------------+
| cis_v130             |
| cis_v130_1           |
| cis_v130_2           |
| cis_v130_2_1         |
| cis_v130_2_2         |
| cis_v130_3           |
| cis_v130_4           |
| cis_v130_5           |
| pci_v321             |
| pci_v321_autoscaling |
| pci_v321_cloudtrail  |
| pci_v321_kms         |
+----------------------+
```


You can explore the available mods on the [Steampipe Hub](https://hub.steampipe.io/mods), and you can [create your own benchmarks](mods/writing-controls) and [dashboards](mods/writing-dashboards) with [SQL](sql/steampipe-sql) and [HCL](reference/mod-resources/overview)! 
