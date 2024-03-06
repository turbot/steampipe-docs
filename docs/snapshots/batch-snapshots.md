---
title: Batch Snapshots
sidebar_label: Batch Snapshots
---

# Taking Snapshots from the Command Line

> ***Powerpipe is now the recommended way to run dashboards and benchmarks!***
> Mods still work as normal in Steampipe for now, but they are deprecated and will be removed in a future release:
> - [Steampipe Unbundled →](https://steampipe.io/blog/steampipe-unbundled)
> - [Powerpipe for Steampipe users →](https://powerpipe.io/blog/migrating-from-steampipe)

*To upload snapshots to Turbot Pipes, you must either [log in via the `steampipe login` command](/docs/reference/cli/login) or create an [API token](https://turbot.com/pipes/docs/profile#tokens) and pass it via the [`--cloud-token`](/docs/reference/cli/overview#global-flags) flag or [`STEAMPIPE_CLOUD_TOKEN`](/docs/reference/env-vars/steampipe_cloud_token) environment variable.*

To take a snapshot and save it to [Turbot Pipes](https://turbot.com/pipes/docs), simply add the `--snapshot` flag to your command.  

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

The `--snapshot` flag will create a snapshot with `workspace` visibility in your user workspace. A snapshot with `workspace` visibility is visible only to users that have access to the workspace in which the snapshot resides -- A user must be authenticated to Turbot Pipes with permissions on the workspace.

If you want to create a snapshot that can be shared with *anyone*, use the `--share` flag instead. This will create the snapshot with `anyone_with_link` visibility:

```bash
steampipe dashboard --share aws_insights.dashboard.aws_account_report
```


You can set a snapshot title in Turbot Pipes with the `--snapshot-title` argument.  This is especially useful for ad hoc queries:

```bash
steampipe query --share --snapshot-title "Public Buckets" "select name from aws_s3_bucket where bucket_policy_is_public" 
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

Steampipe provides a shortcut for this though.  The `--workspace` flag supports [passing the cloud workspace](/docs/managing/workspaces#implicit-workspaces):
```bash
steampipe check --snapshot --workspace vandelay-industries/latex benchmark.cis_v140 
```

While not a common case, you can even run a benchmark against a Turbot Pipes workspace database, but store the snapshot in an entirely different Turbot Pipes workspace:
```bash
steampipe check --snapshot vandelay-industries/latex-dev \
  --workspace vandelay-industries/latex-prod benchmark.cis_v140 
```



## Passing Inputs

If your dashboard has [inputs](/docs/reference/mod-resources/input), you may specify them with one or more `--dashboard-input` arguments:

```bash
steampipe dashboard --snapshot --dashboard-input vpc_id=vpc-9d7ae1e7 \
  aws_insights.dashboard.aws_vpc_detail  
```

## Tagging Snapshots

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


## Saving Snapshots to Local Files

Turbot Pipes makes it easy to save and share your snapshots, however it is not strictly required;  You can save and view snapshots using only the CLI.  

You can specify a local path in the `--snapshot-location` argument or `STEAMPIPE_SNAPSHOT_LOCATION` environment variable to save your snapshots to a directory in your filesystem:

```bash
steampipe check --snapshot --snapshot-location . benchmark.cis_v150
```

You can also set `snapshot_location` in a [workspace](/docs/managing/workspaces) if you wish to make it the default location.


Alternatively, you can use the `--export` argument to export a query, dashboard, or benchmark in the Steampipe snapshot format.  This will create a file with a `.sps` extension in the current directory:

```bash
steampipe dashboard --export sps dashboard.aws_account_report
```

The `snapshot` export/output type is an alias for `sps`:

```bash
steampipe dashboard --export snapshot dashboard.aws_account_report
```

To give the file a name, simply use `{filename}.sps`, for example:

```bash
steampipe dashboard --export account_report.sps dashboard.aws_account_report
```

Alternatively, you can write the steampipe snapshot to stdout with `--output sps`
```bash
steampipe query --output sps  "select * from aws_account" > mysnap.sps
```

or `--output snapshot`
```bash
steampipe query --output snapshot  "select * from aws_account" > mysnap.sps
```


## Controlling Output
When using `--share` or `--snapshot`, the output will include the URL to view the snapshot that you created in addition to the usual output:
```bash
Snapshot uploaded to https://pipes.turbot.com/user/costanza/workspace/vandelay/snapshot/snap_abcdefghij0123456789_asdfghjklqwertyuiopzxcvbn
```

You can use the `--progress=false` argument to suppress displaying the URL and other progress data.  This may be desirable when you are using an alternate output format, especially when piping the output to another command:

```bash
steampipe query --snapshot --output json  \
  --progress=false  "select * from aws_account" | jq
```

You can use all the usual `--export` or `--output` formats with `--snapshot` and `--share`.  Neither the `--output` nor the `--export` flag affect the snapshot format though; the snapshot itself is always a json file that is saved to Turbot Pipes and viewable as html:

```bash
steampipe check --snapshot --export cis.csv --export cis.json  benchmark.cis_v140
```

In fact, all the usual arguments will work with snapshots:
```bash
steampipe check --snapshot all 
steampipe check --snapshot aws_compliance.control.cis_v140_1_1 
steampipe check --snapshot --where "severity in ('critical', 'high')" all
```
