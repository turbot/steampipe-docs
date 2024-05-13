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

List available [named queries](/docs/query/batch-query#named-queries):
```bash
steampipe query list
```


## Flags

| Flag | Description
|-|-


<table>
  <tr> 
    <th> Argument </th> 
    <th> Description </th> 
  </tr>
  <tr> 
    <td nowrap="true"> <inlineCode>--cloud-host</inlineCode> </td> 
    <td>  Sets the Turbot Pipes host used when connecting to Turbot Pipes workspaces. DEPRECATED - Use <inlineCode>--pipes-host</inlineCode>. </td> 
  </tr>

  <tr> 
    <td nowrap="true"> <inlineCode>--cloud-token</inlineCode> </td> 
    <td>  Sets the Turbot Pipes authentication token used when connecting to Turbot Pipes workspaces. DEPRECATED - Use <inlineCode>--pipes-token</inlineCode>. </td> 
  </tr>

  <tr> 
    <td nowrap="true"> <inlineCode>--export string</inlineCode>  </td> 
    <td> Export query output to a file.  You may export multiple output formats by entering multiple <inlineCode>--export</inlineCode> arguments.  If a file path is specified as an argument, its type will be inferred by the suffix.  Supported export formats are  <inlineCode>sps</inlineCode> (<inlineCode>snapshot</inlineCode>).
    </td> 

  </tr>


  <tr> 
    <td nowrap="true"> <inlineCode>--header string</inlineCode>  </td> 
    <td> Specify whether to include column headers in csv and table output (default <inlineCode>true</inlineCode>).</td> 
  </tr>

  <tr> 
    <td nowrap="true"> <inlineCode>--help</inlineCode> </td> 
    <td>  Help for <inlineCode>steampipe query.</inlineCode></td> 
  </tr>

  <tr> 
    <td nowrap="true"> <inlineCode>--input</inlineCode> </td> 
    <td>  Enable/Disable interactive prompts for missing variables.  To disable prompts and fail on missing variables, use <inlineCode>--input=false</inlineCode>.  This is useful when running from scripts. (default true)</td> 
  </tr>

  <tr> 
    <td nowrap="true"> <inlineCode>--mod-location </inlineCode> </td> 
    <td>  Sets the Steampipe workspace working directory. If not specified, the workspace directory will be set to the current working directory. See <a href="reference/env-vars/steampipe_mod_location">STEAMPIPE_MOD_LOCATION</a> for details. </td> 
  </tr>

  <tr> 
    <td nowrap="true"> <inlineCode>--output string</inlineCode> </td> 
    <td>  Select the console output format.   Possible values are <inlineCode>line, csv, json, table, snapshot</inlineCode> (default <inlineCode>table) </inlineCode>. </td> 
  </tr>


  <tr> 
    <td nowrap="true"> <inlineCode>--pipes-host</inlineCode> </td> 
    <td>  Sets the Turbot Pipes host used when connecting to Turbot Pipes workspaces. See <a href="reference/env-vars/pipes_host">PIPES_HOST</a> for details.</td> 
  </tr>

  <tr> 
    <td nowrap="true"> <inlineCode>--pipes-token</inlineCode> </td> 
    <td>  Sets the Turbot Pipes authentication token used when connecting to Turbot Pipes workspaces. See <a href="reference/env-vars/pipes_token">PIPES_TOKEN</a> for details.</td> 
  </tr>
  
  <tr> 
    <td nowrap="true"> <inlineCode>--progress</inlineCode>  </td> 
    <td> Enable or disable progress information. By default, progress information is shown - set <inlineCode>--progress=false</inlineCode> to hide the progress bar.  </td>
  </tr>

  <tr> 
    <td nowrap="true"> <inlineCode>--query-timeout int</inlineCode>  </td> 
    <td>  The query timeout, in seconds.  The default is <inlineCode>0</inlineCode>  (no timeout).  </td>
  </tr>

  <tr> 
    <td nowrap="true"> <inlineCode>--search-path strings</inlineCode>  </td> 
    <td>  Set a comma-separated list of connections to use as a custom <a href="managing/connections#setting-the-search-path">search path</a> for the query session. </td>
  </tr>
      <tr> 
    <td nowrap="true"> <inlineCode>--search-path-prefix strings</inlineCode>  </td> 
    <td>  Set a comma-separated list of connections to use as a prefix to the current <a href="managing/connections#setting-the-search-path">search path</a> for the query session. </td>
  </tr>
  <tr> 
    <td nowrap="true"> <inlineCode>--separator string</inlineCode>  </td> 
    <td>  A single character to use as a separator string for csv output (defaults to  ",")  </td>
  </tr>


  <tr> 
    <td nowrap="true"> <inlineCode>--share</inlineCode>  </td> 
    <td> Create snapshot in Turbot Pipes with <inlineCode>anyone_with_link</inlineCode> visibility.  </td>
  </tr>

  <tr> 
    <td nowrap="true"> <inlineCode>--snapshot</inlineCode>  </td> 
    <td> Create snapshot in Turbot Pipes with the default (<inlineCode>workspace</inlineCode>) visibility.  </td>
  </tr>
    
  <tr> 
    <td nowrap="true"> <inlineCode>--snapshot-location string</inlineCode>  </td> 
    <td> The location to write snapshots - either a local file path or a Turbot Pipes workspace  </td>
  </tr>

  <tr> 
    <td nowrap="true"> <inlineCode>--snapshot-tag string=string  </inlineCode>  </td> 
    <td> Specify tags to set on the snapshot.  Multiple <inlineCode>--snapshot-tag </inlineCode> arguments may be passed.</td>
  </tr>


  <tr> 
    <td nowrap="true"> <inlineCode>--snapshot-title string=string  </inlineCode>  </td> 
    <td> The title to give a snapshot when uploading to Turbot Pipes.  </td>
  </tr>




  <tr> 
    <td nowrap="true"> <inlineCode>--timing=string </inlineCode> </td>
    <td>Enable or disable query execution timing: <inlineCode>off</inlineCode> (default), <inlineCode>on</inlineCode>, or <inlineCode>verbose</inlineCode>  </td>
  </tr>



  <tr> 
    <td nowrap="true"> <inlineCode>--var string=string </inlineCode>  </td> 
    <td>  Specify the value of a mod variable.  Multiple <inlineCode>--var </inlineCode> arguments may be passed.
    </td>
  </tr>
  <tr> 
    <td nowrap="true"> <inlineCode>--var-file string</inlineCode>  </td> 
    <td>  Specify an .spvars file containing mod variable values. 
    </td>
  </tr>

  <tr> 
    <td nowrap="true"> <inlineCode>--watch</inlineCode>  </td> 
    <td> Watch SQL files in the current workspace (works only in interactive mode) (default true)
    </td>
  </tr>

  <tr> 
    <td nowrap="true"> <inlineCode>--workspace-database</inlineCode>  </td> 
    <td>  Sets the database that Steampipe will connect to. This can be <inlineCode>local</inlineCode> (the default) or a remote Turbot Pipes database.  See <a href="/docs/reference/env-vars/steampipe_workspace_database">STEAMPIPE_WORKSPACE_DATABASE</a> for details. </td>
  </tr>
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

List the named queries available to run in the current mod context:

```bash
steampipe query list
```

Run a named query:
```bash
steampipe query query.s3_bucket_logging_enabled
```


Run the SQL command in the `my_queries/my_query.sql` file:
```bash
steampipe query my_queries/my_query.sql
```

Run the SQL commands in all `.sql` files in the `my_queries` directory and concatenate the results:
```bash
steampipe query my_queries/*.sql
```

Run a specific query directly and report the query execution time:
```bash
steampipe query "select * from aws_s3_bucket" --timing
```

Run a specific query directly and report the query execution time and details for each scan:
```bash
steampipe query "select * from aws_s3_bucket" --timing=verbose
```


Run a specific query directly and return output in json format:
```bash
steampipe query "select * from aws_s3_bucket" --output json
```

Run a specific query directly and return output in CSV format:
```bash
steampipe query "select * from aws_s3_bucket" --output csv
```

Run a specific query directly and return output in pipe-separated format:
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