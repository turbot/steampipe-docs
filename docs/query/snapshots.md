---
title: Snapshots
sidebar_label: Snapshots
---

# Snapshots

Steampipe allows you to take **snapshots**.  A snapshot is a saved view of your query results that you can view as a [dashboard in Powerpipe](https://powerpipe.io/docs/run/dashboard)  All data and metadata for a snapshot is contained in a JSON file which can be saved and viewed locally in the Powerpipe dashboard or uploaded to [Turbot Pipes](https://turbot.com/pipes/docs).  Snapshots in Turbot Pipes may be shared with other Turbot Pipes users or made public (shared with anyone that has the link).

You can create Turbot Pipes snapshots directly from the Steampipe CLI, however if you wish to subsequently [modify](https://turbot.com/pipes/docs/dashboards#managing-snapshots) them (add/remove tags, change visibility) or delete them, you must do so from the Turbot Pipes console. You may [browse the snapshot list](https://turbot.com/pipes/docs/dashboards#browsing-snapshots) in Turbot Pipes by clicking the **Snapshots** button on the top of your workspace's **Dashboards** page.


## Taking Snapshots

> To upload snapshots to Turbot Pipes, you must either [log in via the `steampipe login` command](/docs/reference/cli/login) or create an [API token](https://turbot.com/pipes/docs/profile#tokens) and pass it via the [`--pipes-token`](/docs/reference/cli/overview#global-flags) flag or [`PIPES_TOKEN`](/docs/reference/env-vars/pipes_token) environment variable.

To take a snapshot and save it to [Turbot Pipes](https://turbot.com/pipes/docs), simply add the `--snapshot` flag to your command.  

```bash
steampipe query --snapshot "select * from aws_ec2_instance" 
```

The `--snapshot` flag will create a snapshot with `workspace` visibility in your user workspace. A snapshot with `workspace` visibility is visible only to users that have access to the workspace in which the snapshot resides -- A user must be authenticated to Turbot Pipes with permissions on the workspace.

If you want to create a snapshot that can be shared with *anyone*, use the `--share` flag instead. This will create the snapshot with `anyone_with_link` visibility:

```bash
steampipe query --share "select * from aws_ec2_instance" 
```


You can set a snapshot title in Turbot Pipes with the `--snapshot-title` argument.

```bash
steampipe query --share --snapshot-title "Public Buckets" "select name from aws_s3_bucket where bucket_policy_is_public" 
```


If you wish to save to the snapshot to a different workspace, such as an org workspace, you can use the `--snapshot-location` argument with `--share` or `--snapshot`:

```bash
steampipe query --share --snapshot-location vandelay-industries/latex  "select * from aws_ec2_instance" 
```

Note that the previous command ran the query against the *local* database, but saved the snapshot to the `vandelay-industries/latex` workspace.  If you want to run the query against the remote `vandelay-industries/latex` database AND store the snapshot there, you can also add the `--database-location` argument:

```bash
steampipe query --share --snapshot-location vandelay-industries/latex \
  --workspace-database  vandelay-industries/latex  \
  "select * from aws_ec2_instance" 
```

Steampipe provides a shortcut for this though.  The `--workspace` flag supports [passing the cloud workspace](/docs/managing/workspaces#implicit-workspaces):
```bash

steampipe query --snapshot  --workspace vandelay-industries/latex  "select * from aws_ec2_instance" 

```

While not a common case, you can even run a query against a Turbot Pipes workspace database, but store the snapshot in an entirely different Turbot Pipes workspace:
```bash

steampipe query --share --snapshot-location vandelay-industries/latex \
  --workspace  vandelay-industries/latex-prod  \
  "select * from aws_ec2_instance" 
```


## Tagging Snapshots

You may want to tag your snapshots to make it easier to organize them.  You can use the `--snapshot-tag` argument to add a tag:

```bash
steampipe query --snapshot-tag env=local --snapshot \
  "select * from aws_ec2_instance" 
```

Simply repeat the flag to add more than one tag:
```bash
steampipe query --snapshot-tag env=local --snapshot --snapshot-tag owner=george \
  "select * from aws_ec2_instance" 

```


## Saving Snapshots to Local Files

Turbot Pipes makes it easy to save and share your snapshots, however it is not strictly required;  You can save and view snapshots using only the CLI.  

You can specify a local path in the `--snapshot-location` argument or `STEAMPIPE_SNAPSHOT_LOCATION` environment variable to save your snapshots to a directory in your filesystem:

```bash
steampipe query --snapshot --snapshot-location . "select * from aws_account"
```

You can also set `snapshot_location` in a [workspace](/docs/managing/workspaces) if you wish to make it the default location.


Alternatively, you can use the `--export` argument to export a query, dashboard, or benchmark in the Steampipe snapshot format.  This will create a file with a `.sps` extension in the current directory:

```bash
steampipe query --export sps "select * from aws_account"
```

The `snapshot` export/output type is an alias for `sps`:

```bash
steampipe query --export snapshot "select * from aws_account"
```

To give the file a name, simply use `{filename}.sps`, for example:

```bash
steampipe query --export aws_accounts.sps "select * from aws_account"
```

Alternatively, you can write the steampipe snapshot to stdout with `--output sps`
```bash
steampipe query --output sps  "select * from aws_account" > aws_accounts.sps
```

or `--output snapshot`
```bash
steampipe query --output snapshot  "select * from aws_account" > aws_accounts.sps
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
