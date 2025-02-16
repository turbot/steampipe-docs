---
title: steampipe query
sidebar_label: steampipe query
---

# steampipe query
Execute SQL queries interactively, or by a query argument.

To open the interactive query shell, run `steampipe query` with no arguments.  The query shell provides a way to explore your data and run multiple queries. 

If a query string is passed on the command line then it will be run immediately and the command will exit.  Alternatively, you may specify one or more files containing SQL statements.  You can run multiple SQL files by passing a glob or a space-separated list of file names.

If the Steampipe service was previously started by `steampipe service start`, steampipe will connect to the service instance - otherwise, the query command will start the `service`. At the end of the query command or session, if other sessions have not connected to the `service` already, the `service` will be shutdown. If other sessions have already connected to the `service`, then the last session to exit will shutdown the `service`.

## Usage
Run Steampipe [interactive query shell](/docs/query/query-shell):
```bash
steampipe query [flags]
```

Run a [batch query](/docs/query/batch-query):
```bash
steampipe query {query} [flags]
```


## Flags

<table>
  <thead>
  <tr>
    <th> Argument </th>
    <th> Description </th>
  </tr>
  </thead>

  <tbody>
  <tr> 
    <td nowrap="true"> `--export string`  </td> 
    <td> 
    Export query output to a file.  You may export multiple output formats by entering multiple `--export` arguments.  If a file path is specified as an argument, its type will be inferred by the suffix.  Supported export formats are  `sps` (`snapshot`).
    </td> 
  </tr>

  <tr> 
    <td nowrap="true"> `--header string`  </td> 
    <td> Specify whether to include column headers in csv and table output (default `true`).</td> 
  </tr>

  <tr> 
    <td nowrap="true"> `--help` </td> 
    <td>  Help for `steampipe query.`</td> 
  </tr>
 
  <tr> 
    <td nowrap="true"> `--output string` </td> 
    <td>  Select the console output format.   Possible values are `line, csv, json, table, snapshot` (default `table) `. </td> 
  </tr>

  <tr> 
    <td nowrap="true"> `--pipes-host` </td> 
    <td>  Sets the Turbot Pipes host used when connecting to Turbot Pipes workspaces. See <a href="reference/env-vars/pipes_host">PIPES_HOST</a> for details.</td> 
  </tr>

  <tr> 
    <td nowrap="true"> `--pipes-token` </td> 
    <td>  Sets the Turbot Pipes authentication token used when connecting to Turbot Pipes workspaces. See <a href="reference/env-vars/pipes_token">PIPES_TOKEN</a> for details.</td> 
  </tr>
  
  <tr> 
    <td nowrap="true"> `--progress`  </td> 
    <td> Enable or disable progress information. By default, progress information is shown - set `--progress=false` to hide the progress bar.  </td>
  </tr>

  <tr> 
    <td nowrap="true"> `--query-timeout int`  </td> 
    <td>  The query timeout, in seconds.  The default is `0`  (no timeout).  </td>
  </tr>

  <tr> 
    <td nowrap="true"> `--search-path strings`  </td> 
    <td>  Set a comma-separated list of connections to use as a custom <a href="managing/connections#setting-the-search-path">search path</a> for the query session. </td>
  </tr>
      
  <tr> 
    <td nowrap="true"> `--search-path-prefix strings`  </td> 
    <td>  Set a comma-separated list of connections to use as a prefix to the current <a href="managing/connections#setting-the-search-path">search path</a> for the query session. </td>
  </tr>

  <tr>
    <td nowrap="true"> `--separator string`  </td> 
    <td>  A single character to use as a separator string for csv output (defaults to  ",")  </td>
  </tr>

  <tr>
    <td nowrap="true"> `--share`  </td>
    <td> Create snapshot in Turbot Pipes with `anyone_with_link` visibility.  </td>
  </tr>

  <tr>
    <td nowrap="true"> `--snapshot`  </td>
    <td> Create snapshot in Turbot Pipes with the default (`workspace`) visibility.  </td>
  </tr>
    
  <tr>
    <td nowrap="true"> `--snapshot-location string`  </td>
    <td> The location to write snapshots - either a local file path or a Turbot Pipes workspace  </td>
  </tr>

  <tr>
    <td nowrap="true"> `--snapshot-tag string=string  `  </td>
    <td> Specify tags to set on the snapshot.  Multiple `--snapshot-tag ` arguments may be passed.</td>
  </tr>

  <tr>
    <td nowrap="true"> `--snapshot-title string=string  `  </td>
    <td> The title to give a snapshot when uploading to Turbot Pipes.  </td>
  </tr>

  <tr>
    <td nowrap="true"> `--timing=string ` </td>
    <td>Enable or disable query execution timing: `off` (default), `on`, or `verbose`  </td>
  </tr>

  <tr>
    <td nowrap="true"> `--workspace-database`  </td>
    <td>  Sets the database that Steampipe will connect to. This can be `local` (the default) or a remote Turbot Pipes database.  See <a href="/docs/reference/env-vars/steampipe_workspace_database">STEAMPIPE_WORKSPACE_DATABASE</a> for details. </td>
  </tr>
  </tbody>
</table>



## Examples

Open an interactive query console:
```bash
steampipe query
```

Run a specific query directly:
```bash
steampipe query "select * from aws_s3_bucket"
```

Run a query and save a [snapshot](/docs/snapshots/batch-snapshots):
```bash
steampipe query --snapshot "select * from aws_s3_bucket"
```

Run a query and share a [snapshot](/docs/snapshots/batch-snapshots):
```bash
steampipe query --share "select * from aws_s3_bucket"
```

Run the SQL command in the `my_queries/my_query.sql` file:
```bash
steampipe query my_queries/my_query.sql
```

Run the SQL commands in all `.sql` files in the `my_queries` directory and concatenate the results:
```bash
steampipe query my_queries/*.sql
```

Run a query and report the query execution time:
```bash
steampipe query "select * from aws_s3_bucket" --timing
```

Run a query and report the query execution time and details for each scan:
```bash
steampipe query "select * from aws_s3_bucket" --timing=verbose
```

Run a query and return output in json format:
```bash
steampipe query "select * from aws_s3_bucket" --output json
```

Run a query and return output in CSV format:
```bash
steampipe query "select * from aws_s3_bucket" --output csv
```

Run a query and return output in pipe-separated format:
```bash
steampipe query "select * from aws_s3_bucket" --output csv --separator '|'
```


Run a query with a specific search_path:
```bash
steampipe query --search-path="aws_dmi,github,slack" "select * from aws_s3_bucket"
```

Run a query with a specific search_path_prefix:
```bash
steampipe query --search-path-prefix="aws_dmi" "select * from aws_s3_bucket"
```