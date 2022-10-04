---
title: Query Snapshots
sidebar_label: Query Snapshots
---

# Query Snapshots

> To upload snapshots to Steampipe Cloud, you must connect with an [API token](/docs/cloud/profile#api-tokens).  The examples in this section assume that you have set the [`STEAMPIPE_CLOUD_TOKEN`](reference/env-vars/steampipe_cloud_token) to a valid API token:
```bash
export STEAMPIPE_CLOUD_TOKEN=spt_c6rnjt8afakemj4gha10_svpnmxqfaketokenad431k
```

To take a snapshot of a query, simply add the `--snapshot` flag to your command:

```bash
steampipe query --snapshot "select * from aws_ec2_instance" 
```
The command will return the url to view the snapshot that you created:
```bash
Snapshot uploaded to https://cloud.steampipe.io/user/costanza/workspace/vandelay/snapshot/snap_abcdefghij0123456789_asdfghjklqwertyuiopzxcvbn
```

You may use the `--output` argument if you  prefer to see the the normal table output written to stdout (or an alternate format such as CSV or JSON).  Note that when `--output` is specified, the url will not be returned on stdout, though you can view all of your snapshots from the **snapshots** page on the [Steampipe Cloud](/docs/cloud/overview) console:

```bash
steampipe query --snapshot "select * from aws_ec2_instance"  --output table
```

If you are running steampipe from a mod with named queries, you can snapshot those as well:

```bash
steampipe query --snapshot aws_compliance.query.vpc_network_acl_unused  
```

The `--snapshot` flag will create a snapshot with `workspace` visibility in your user workspace. A snapshot with `workspace` visibility is visible only to users that have access to the workspace in which the snapshot resides - A user must be authenticated to Steampipe Cloud with permissions on the workspace.

If you want to create a snapshot that can be shared with *anyone*, use the `--share` flag instead. This will create the snapshot with `anyone_with_link` visibility:

```bash
steampipe query --share "select * from aws_ec2_instance" 
```

You may want to tag your snapshots to make it easier to organize them.  You can use the `--snapshot-tag` argument to add a tag:

```bash
steampipe query --snapshot-tag=env=localdev  --snapshot "select * from aws_ec2_instance" 
```

Simply repeat the flag to add more than one tag:
```bash
steampipe query --snapshot-tag=env=local --snapshot-tag=owner=george  --snapshot "select * from aws_ec2_instance" 
```


If you wish to save to the snapshot to a different workspace, such as an org workspace, you can pass the org as an argument to `--share` or `snapshot`:

```bash
steampipe query --snapshot=vandelay-industries/latex "select * from aws_ec2_instance" 
```

Note that the previous command ran the query against the *local* database, but saved the snapshot to the `vandelay-industries/latex` workspace.  If you want to run the query against the remote `vandelay-industries\latex` database AND store the snapshot there, use the `--workspace` flag:
```bash
steampipe query --snapshot --workspace=vandelay-industries/latex "select * from aws_ec2_instance" 
```

While not a common case, you can even run a query against a Steampipe Cloud workspace database, but store the snapshot in an entirely different Steampipe Cloud workspace:
```bash
steampipe query --snapshot=vandelay-industries/latex-dev --workspace=vandelay-industries/latex-prod "select * from aws_ec2_instance" 
```