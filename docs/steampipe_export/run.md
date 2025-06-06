---
title: Run
sidebar_label: Run
---


# Running Steampipe Plugin Exporters

Each Steampipe Export CLI is distributed as a separate binary, but the command line options are the same:

```bash
Export data using the aws plugin.

Find detailed usage information including table names, column names, and
examples at the Steampipe Hub: https://hub.steampipe.io/plugins/turbot/aws

Usage:
  steampipe_export_aws TABLE_NAME [flags]

Flags:
      --config string       Inline HCL config data for the connection  (deprecated - use --connection instead)
      --config-dir string   Directory to read config files from (defaults to $STEAMPIPE_INSTALL_DIR/config)
      --connection string   Name of the connection to use (must match a connection defined in the config file)
  -h, --help                Help for steampipe_export_aws
      --limit int           Maximum number of rows to return (0 means no limit)
      --output string       Output format: csv, json or jsonl (default "csv")
      --select strings      Columns to include in the output
  -v, --version             Version for steampipe_export_aws

```

## Configuration

Many plugins have a *default* configuration that will use environment variables or other "native" configuration files to set your credentials if don't provide a `--config` or a `--connection`.  The behavior varies by plugin but should be documented in the [Steampipe hub](https://hub.steampipe.io/plugins).  The AWS plugin, for example, will resolve the region and credentials using the same mechanism as the AWS CLI (AWS environment variables, default profile, etc).  If you have AWS CLI default credentials set up, Steampipe will use them if you don't specify `--config` or `--connection`:

```bash
steampipe_export_aws aws_account
```

There are a few different ways to configure the Exporters:

1. You can specify the configuration with the `--config` argument. The `--config` argument takes a string containing the HCL configuration options for the plugin.  The options vary per plugin, and match the [connection](https://steampipe.io/docs/managing/connections) options for the corresponding plugin.  You can view the available options and syntax for the plugin in the [Steampipe hub](https://hub.steampipe.io/plugins). This has been deprecated.

```bash
steampipe_export_aws --config 'profile = "my_profile"' aws_account
```

Note that HCL is newline-sensitive and you must include the line break.  You can use `\n` with the [bash `$’string’` syntax](https://www.gnu.org/software/bash/manual/html_node/ANSI_002dC-Quoting.html#ANSI_002dC-Quoting) to accomplish this:
```bash
steampipe_export_aws --config $'access_key="AKIA4YFAKEKEYT99999" \n secret_key="A32As+zuuBFThisIsAFakeSecretNb77HSLmcB"' aws_account

```

Or you can write your config to a file:
```hcl
access_key = "AKIA4YFAKEKEYT99999"
secret_key = "A32As+zuuBFThisIsAFakeSecretNb77HSLmcB"
```
And then `cat` the file into the `-config` arg:
```bash
steampipe_export_aws --config "$(cat my_aws_config.hcl)"  aws_account
```

2. Alternatively, you can use a named connection with the `--connection` argument. The `--connection` argument allows you to specify the name of a Steampipe connection defined in a `.spc` config file. This is the preferred method for configuring your export tool. By default, the exporter will look for the config files in the Steampipe install directory `($STEAMPIPE_INSTALL_DIR/config)`, but you can override this path with the `--config-dir` argument.

```bash
steampipe_export_aws --connection aws_prod aws_account
```
This assumes a file such as aws.spc exists in the steampipe config directory with content like:
```hcl
connection "aws_prod" {
  plugin  = "aws"
  profile = "dundermifflin"
  regions = ["us-east-1", "us-west-2"]
}
```

If your configuration files are stored in a different directory, specify the path with the --config-dir argument:
```bash
steampipe_export_aws --connection aws_prod --config-dir ~/my/custom/config aws_account
```

This provides a cleaner and more reusable approach than --config, especially for managing multiple environments or teams. It also supports full Steampipe connection syntax including named connections, plugin configurations, credentials, and options.

## Filtering Results

You can use `--limit` to specify the number of rows to return, which will reduce both the query time and the number of outbound API requests:
```bash
steampipe_export_aws aws_ec2_instance  --limit 3
```

The `--select` argument allows you to specify which columns to return.  Generally, you should select only the columns that you want in order to reduce the number of API calls, improve query performance, and minimize memory usage.  Specify the columns you want, separated by a comma:

```bash
steampipe_export_aws aws_ec2_instance  --select instance_id,instance_type,account_id,region
```

The `--where` argument allows you to filter the rows based on key columns: 

```bash
steampipe_export_aws aws_ec2_instance  --where "instance_type = 't2.micro'"
```

You can **only specify key columns** in `--where` because the Export CLI does the filtering server-side, via the API or service that it is calling. Refer to the table documentation in the [Steampipe hub](https://hub.steampipe.io/plugins) for a list of key columns (e.g. https://hub.steampipe.io/plugins/turbot/aws/tables/aws_ec2_instance#inspect).  

Note that you do not have to select the column to filter by it:
```bash
steampipe_export_aws aws_ec2_instance  --select instance_id,account_id,region,_ctx --where "instance_type = 't2.micro'"
```

The syntax for the `--where` argument generally follows the same structure as a SQL where clause comparison. Be aware that not all key columns support all operators (most only support `=` ) and you can only use the supported operators:
```bash
steampipe_export_aws aws_ec2_instance  --select instance_id,instance_state,account_id,region --where "instance_type like 't2.%'"
key column for 'instance_type' does not support operator '~~'
```

You can specify multiple `--where` arguments, and they will be and'ed together:
```bash
steampipe_export_aws aws_ec2_instance  --select instance_id,account_id,region,_ctx --where "instance_type = 't2.micro'" --where "instance_state = 'stopped'"
```



## Formatting output

By default, the output is returned as CSV, but you can instead return as JSON:
```bash
steampipe_export_aws aws_ec2_instance  --select instance_id,account_id,region --output json
```

Or JSON lines (JSONL):
```bash
steampipe_export_aws aws_ec2_instance  --select instance_id,account_id,region --output jsonl  
```


## Logging
You can set the logging level with the [STEAMPIPE_LOG_LEVEL](/docs/reference/env-vars/steampipe_log) environment variable.  By default, the log level is set to `warn`.

```bash
export STEAMPIPE_LOG_LEVEL=DEBUG
```

Logs are written to STDERR so by default they will be printed to the console.  You can redirect them to a file instead with the standard file redirection mechanism:

```bash
steampipe_export_aws aws_iam_policy 2> errors.log
```