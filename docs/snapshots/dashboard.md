---
title: Dashboard Snapshots
sidebar_label: Dashboard Snapshots
---

# Dashboard Snapshots

> To upload snapshots to Steampipe Cloud, you must connect with an [API token](/docs/cloud/profile#api-tokens).  The examples in this section assume that you have set the [`STEAMPIPE_CLOUD_TOKEN`](reference/env-vars/steampipe_cloud_token) to a valid API token:
```bash
export STEAMPIPE_CLOUD_TOKEN=spt_c6rnjt8afakemj4gha10_svpnmxqfaketokenad431k
```

To take a snapshot of a dashboard, add the `--snapshot` flag to your command:

```bash
steampipe dashboard --snapshot aws_insights.dashboard.aws_account_report
```
The command will return the url to view the snapshot that you created:
```bash
Snapshot uploaded to https://cloud.steampipe.io/user/costanza/workspace/vandelay/snapshot/snap_abcdefghij0123456789_asdfghjklqwertyuiopzxcvbn
```

The `--snapshot` flag will create a snapshot with `workspace` visibility in your user workspace. A snapshot with `workspace` visibility is visible only to users that have access to the workspace in which the snapshot resides - A user must be authenticated to Steampipe Cloud with permissions on the workspace.

If you want to create a snapshot that can be shared with *anyone*, use the `--share` flag instead. This will create the snapshot with `anyone_with_link` visibility:

```bash
steampipe dashboard --share aws_insights.dashboard.aws_account_report
```

You may want to tag your snapshots to make it easier to organize them.  You can use the `--snapshot-tag` argument to add a tag:

```bash
steampipe dashboard --snapshot-tag=env=localdev  --snapshot aws_insights.dashboard.aws_account_report
```

Simply repeat the flag to add more than one tag:
```bash
steampipe dashboard --snapshot-tag=env=local --snapshot-tag=owner=george  --snapshot aws_insights.dashboard.aws_account_report
```

If your dashboard takes input parameters, you may specify them with one or more `--dashboard-input` arguments:

```bash
steampipe dashboard aws_insights.dashboard.aws_vpc_detail --dashboard-input=vpc_id=vpc-9d7ae1e7 --snapshot
```

If you want to save to the snapshot to a different workspace, such as an org workspace, you can pass the org as an argument to `--share` or `snapshot`:

```bash
steampipe dashboard --snapshot=vandelay-industries/latex aws_insights.dashboard.aws_account_report 
```

Note that the previous command ran the dashboard against the *local* database, but saved the snapshot to the `vandelay-industries/latex` workspace.  If you want to run the dashboard against the remote `vandelay-industries\latex` database AND store the snapshot there, use the `--workspace` flag:
```bash
steampipe dashboard --snapshot --workspace=vandelay-industries/latex aws_insights.dashboard.aws_account_report 
```

While not a common case, you can even run a dashboard against a Steampipe Cloud workspace database, but store the snapshot in an entirely different Steampipe Cloud workspace:
```bash
steampipe dashboard --snapshot=vandelay-industries/latex-dev --workspace=vandelay-industries/latex-prod aws_insights.dashboard.aws_account_report 
```