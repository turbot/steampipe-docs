---
title:  Steampipe Snapshot
sidebar_label:  Steampipe Snapshot
---

#  Steampipe Snapshot

> To upload snapshots to Steampipe Cloud, you must connect with an [API token](/docs/cloud/profile#api-tokens).  The examples in this section assume that you have set the [`STEAMPIPE_CLOUD_TOKEN`](reference/env-vars/steampipe_cloud_token) to a valid API token:
```bash
export STEAMPIPE_CLOUD_TOKEN=spt_c6rnjt8afakemj4gha10_svpnmxqfaketokenad431k
```

You can use the `steampipe snapshot create` command to take a point-in-time snapshot.  

You can take a snapshot of a query:
```bash
steampipe snapshot create "select * from aws_vpc"
```

Or a named query:
```bash
steampipe snapshot create query.vpc_network_acl_unused  
```

Or a benchmark:
```bash
steampipe snapshot create benchmark.cis_v140
```

Or a dashboard:
```bash
steampipe snapshot create aws_insights.dashboard.aws_account_report
```

If your dashboard takes input parameters, you may specify them with one or more `--dashboard-input` arguments:

```bash
steampipe snapshot create aws_insights.dashboard.aws_vpc_detail --dashboard-input=vpc_id=vpc-9d7ae1e7
```

The command will return the url to view the snapshot that you created:
```bash
Snapshot uploaded to https://cloud.steampipe.io/user/costanza/workspace/vandelay/snapshot/snap_abcdefghij0123456789_asdfghjklqwertyuiopzxcvbn
```

You may use the `--output` argument if you prefer to see the full json snapshot output written to stdout. Note that when `--output` is specified, the url will not be returned on stdout, though you can view all of your snapshots from the **snapshots** page on the [Steampipe Cloud](/docs/cloud/overview) console:

```bash
steampipe snapshot create aws_insights.dashboard.aws_account_report  --output snapshot.json
```

By default, `steampipe snapshot create` will create a snapshot with `workspace` visibility in your user workspace. A snapshot with `workspace` visibility is visible only to users that have access to the workspace in which the snapshot resides - A user must be authenticated to Steampipe Cloud with permissions on the workspace.

If you want to create a snapshot that can be shared with *anyone*, set `--visibility=anyone_with_link`:

```bash
steampipe snapshot create aws_insights.dashboard.aws_account_report --visibility=anyone_with_link
```

You may want to tag your snapshots to make it easier to organize them.  You can use the `--tag` argument to add a tag:

```bash
steampipe snapshot create aws_insights.dashboard.aws_account_report  --tag=env=localdev 
```

Simply repeat the flag to add more than one tag:
```bash
steampipe snapshot create aws_insights.dashboard.aws_account_report  --tag=env=local --tag=owner=george
```


If you wish to save to the snapshot to a different workspace, such as an org workspace, you can pass the org as an argument to `--destination`:

```bash
steampipe snapshot create aws_insights.dashboard.aws_account_report --destination=vandelay-industries/latex
```

Note that the previous command ran the dashboard against the *local* database, but saved the snapshot to the `vandelay-industries/latex` workspace.  If you want to run the dashboard against the remote `vandelay-industries\latex` database AND store the snapshot there, use the `--workspace` flag:
```bash
steampipe snapshot create aws_insights.dashboard.aws_account_report --workspace=vandelay-industries/latex 
```

While not a common case, you can even run a benchmark against a Steampipe Cloud workspace database, but store the snapshot in an entirely different Steampipe Cloud workspace:
```bash
steampipe snapshot create aws_insights.dashboard.aws_account_report --workspace=vandelay-industries/latex 
--destination=vandelay-industries/latex
```