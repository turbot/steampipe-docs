---
title: Benchmark Snapshots
sidebar_label: Benchmark Snapshots
---

# Benchmark Snapshots

> To upload snapshots to Steampipe Cloud, you must connect with an [API token](/docs/cloud/profile#api-tokens).  The examples in this section assume that you have set the [`STEAMPIPE_CLOUD_TOKEN`](reference/env-vars/steampipe_cloud_token) to a valid API token:
```bash
export STEAMPIPE_CLOUD_TOKEN=spt_c6rnjt8afakemj4gha10_svpnmxqfaketokenad431k
```

To take a snapshot of a benchmark, simply add the `--snapshot` flag to your command:

```bash
steampipe check --snapshot benchmark.cis_v140 
```
The command will return the url to view the snapshot that you created:
```bash
Snapshot uploaded to https://cloud.steampipe.io/user/costanza/workspace/vandelay/snapshot/snap_abcdefghij0123456789_asdfghjklqwertyuiopzxcvbn
```

You may use the `--output` argument if you prefer to see the the normal text output written to stdout (or an alternate format such as brief, csv, html, json or md,).  Note that when `--output` is specified, the url will not be returned on stdout, though you can view all of your snapshots from the **snapshots** page on the [Steampipe Cloud](/docs/cloud/overview) console:

```bash
steampipe check --snapshot benchmark.cis_v140  --output text
```

The `--export` argument also works as you would expect.  This will write the export files in the requested format. Neither the `--output` nor the `--export` flag affect the snapshot format though - the snapshot itself is always a json file that is saved to Steampipe Cloud and viewable as html:

```bash
steampipe check --snapshot benchmark.cis_v140  --export cis.csv --export cis.json
```

In fact, all the usual `steampipe check` arguments will work with snapshots:
```bash
steampipe check all --snapshot
steampipe check aws_compliance.control.cis_v140_1_1 --snapshot
steampipe check all --where="severity in ('critical', 'high')" --snapshot
```

The `--snapshot` flag will create a snapshot with `workspace` visibility in your user workspace. A snapshot with `workspace` visibility is visible only to users that have access to the workspace in which the snapshot resides - A user must be authenticated to Steampipe Cloud with permissions on the workspace.

If you want to create a snapshot that can be shared with *anyone*, use the `--share` flag instead. This will create the snapshot with `anyone_with_link` visibility:

```bash
steampipe check --share benchmark.cis_v140 
```

You may want to tag your snapshots to make it easier to organize them.  You can use the `--snapshot-tag` argument to add a tag:

```bash
steampipe check --snapshot-tag=env=localdev  --snapshot benchmark.cis_v140 
```

Simply repeat the flag to add more than one tag:
```bash
steampipe check --snapshot-tag=env=local --snapshot-tag=owner=george  --snapshot benchmark.cis_v140 
```


If you wish to save to the snapshot to a different workspace, such as an org workspace, you can pass the org as an argument to `--share` or `snapshot`:

```bash
steampipe check --snapshot=vandelay-industries/latex benchmark.cis_v140 
```

Note that the previous command ran the benchmark against the *local* database, but saved the snapshot to the `vandelay-industries/latex` workspace.  If you want to run the benchmark against the remote `vandelay-industries\latex` database AND store the snapshot there, use the `--workspace` flag:
```bash
steampipe check --snapshot --workspace=vandelay-industries/latex benchmark.cis_v140 
```

While not a common case, you can even run a benchmark against a Steampipe Cloud workspace database, but store the snapshot in an entirely different Steampipe Cloud workspace:
```bash
steampipe check --snapshot=vandelay-industries/latex-dev --workspace=vandelay-industries/latex-prod benchmark.cis_v140 
```