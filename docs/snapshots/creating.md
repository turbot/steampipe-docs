---
title: Creating Snapshots
sidebar_label: Creating Snapshots
---

## Creating Snapshots

> To upload snapshots to Steampipe Cloud, you must either [log in via the `steampipe login` command](reference/cli/login) or create an [API token](/docs/cloud/profile#api-tokens) and pass it via the [`--cloud-token`](reference/cli/overview#global-flags) flag or [`STEAMPIPE_CLOUD_TOKEN`](reference/env-vars/steampipe_cloud_token) environment variable.

To take a snapshot and save it to [Steampipe Cloud](/docs/cloud/overview), simply add the `--snapshot` flag to your command.  

You can take a snapshot of a dashboard:
```bash
steampipe dashboard --snapshot aws_insights.dashboard.aws_account_report
```

or a benchmark:

```bash
steampipe check --snapshot benchmark.cis_v140 
```

or a query:

```bash
steampipe query --snapshot "select * from aws_ec2_instance" 
```

including named queries:

```bash
steampipe query --snapshot aws_compliance.query.vpc_network_acl_unused  
```


## Sharing Snapshots

The `--snapshot` flag will create a snapshot with `workspace` visibility in your user workspace. A snapshot with `workspace` visibility is visible only to users that have access to the workspace in which the snapshot resides - A user must be authenticated to Steampipe Cloud with permissions on the workspace.

If you want to create a snapshot that can be shared with *anyone*, use the `--share` flag instead. This will create the snapshot with `anyone_with_link` visibility:

```bash
steampipe dashboard --share aws_insights.dashboard.aws_account_report
```

If you wish to save to the snapshot to a different workspace, such as an org workspace, you can use the `--snapshot-location` argument with `--share` or `--snapshot`:

```bash
steampipe check --snapshot --snapshot-location vandelay-industries/latex benchmark.cis_v140 
```

Note that the previous command ran the benchmark against the *local* database, but saved the snapshot to the `vandelay-industries/latex` workspace.  If you want to run the benchmark against the remote `vandelay-industries/latex` database AND store the snapshot there, you can also add the `--database-location` argument:

```bash
steampipe check --snapshot --snapshot-location vandelay-industries/latex \
  --workspace-database vandelay-industries/latex benchmark.cis_v140
```

Steampipe provides a shortcut for this though.  The `--workspace` flag supports [passing the cloud workspace](http://localhost:3000/docs/managing/workspaces#implicit-workspaces):
```bash
steampipe check --snapshot --workspace vandelay-industries/latex benchmark.cis_v140 
```

While not a common case, you can even run a benchmark against a Steampipe Cloud workspace database, but store the snapshot in an entirely different Steampipe Cloud workspace:
```bash
steampipe check --snapshot vandelay-industries/latex-dev \
  --workspace vandelay-industries/latex-prod benchmark.cis_v140 
```



## Passing Inputs

If your dashboard takes input parameters, you may specify them with one or more `--dashboard-input` arguments:

```bash
steampipe dashboard --snapshot --dashboard-input vpc_id=vpc-9d7ae1e7 \
  aws_insights.dashboard.aws_vpc_detail  
```

## Tagging snapshots

You may want to tag your snapshots to make it easier to organize them.  You can use the `--snapshot-tag` argument to add a tag:

```bash
steampipe dashboard --snapshot-tag env=local --snapshot \
  aws_insights.dashboard.aws_account_report
```

Simply repeat the flag to add more than one tag:
```bash
steampipe dashboard --snapshot-tag env=local --snapshot-tag owner=george  \
  --snapshot aws_insights.dashboard.aws_account_report
```

## Controlling Output
When using `--share` or `--snapshot`, the output will include the URL to view the snapshot that you created in addition to the usual output:
```bash
Snapshot uploaded to https://cloud.steampipe.io/user/costanza/workspace/vandelay/snapshot/snap_abcdefghij0123456789_asdfghjklqwertyuiopzxcvbn
```

You may use the `--progress=false` argument to suppress displaying the URL and other progress data:

```bash
steampipe query --snapshot --output csv --progress=false \
  "select * from aws_account"
```

You can use all the usual `--export` or `--output` formats with `--snapshot` and `--share`.  Neither the `--output` nor the `--export` flag affect the snapshot format though - the snapshot itself is always a json file that is saved to Steampipe Cloud and viewable as html:

```bash
steampipe check --snapshot --export cis.csv --export cis.json  benchmark.cis_v140
```

In fact, all the usual arguments will work with snapshots:
```bash
steampipe check --snapshot all 
steampipe check --snapshot aws_compliance.control.cis_v140_1_1 
steampipe check --snapshot --where "severity in ('critical', 'high')" all
```

## Saving snapshots to local files

Steampipe Cloud makes it easy to save and share your snapshots, however it is not strictly required;  You can save and view snapshots using only the CLI.  

You can specify a local path in `--mod-location` argument or `STEAMPIPE_MOD_LOCATION` environment variable to save your snapshots to a directory in your filesystem:

```bash
steampipe check --snapshot --snapshot-location . benchmark.cis_v150
```

Alternately, you can use the `--export` argument to export a query, dashboard, or benchmark in the steampipe snapshot format.  This will create a file with a `.sps` extension in the current directory.

```bash
steampipe dashboard --export sps dashboard.aws_account_report
```

The `snapshot` export/output type is an alias for `sps`:

```
steampipe dashboard --export snapshot dashboard.aws_account_report
```

To give the file a name, simply use `{filename}.sps`, for example:

```bash
steampipe dashboard --export account_report.sps dashboard.aws_account_report
```

Alternatively, you can write the native steampipe snapshot to stdout with `--output sps`
```bash
steampipe query --output sps  "select * from aws_account" > mysnap.sps
```

or `--output snapshot`
```bash
steampipe query --output snapshot  "select * from aws_account" > mysnap.sps
```
