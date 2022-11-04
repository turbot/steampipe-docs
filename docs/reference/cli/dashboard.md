---
title: steampipe dashboard
sidebar_label: steampipe dashboard
---

# steampipe dashboard
Run the Steampipe Dashboard server.

The Dashboard loads the `mod` in the current working directory or the `--workspace-chdir` and listens for changes to dashboards defined in the `mod`.

## Usage
Run [Steampipe Dashboard](/docs/dashboard/overview) interactively:
```bash
steampipe dashboard [flags]
```

Take a snapshot or export of a single dashboard (non-interactively):
```bash
steampipe dashboard {dashboard name} [flags]
```

List available dashboards:
```bash
steampipe dashboard list
```

## Flags


<table>
  <tr> 
    <th> Argument </th> 
    <th> Description </th> 
  </tr>

  <tr> 
    <td nowrap="true"> <inlineCode>--browser bool</inlineCode>  </td> 
    <td>  Specify whether to launch the browser after starting the dashboard server (default <inlineCode>true</inlineCode>). </td>
  </tr>

  <tr> 
    <td nowrap="true"> <inlineCode>--dashboard-input string=string </inlineCode>  </td> 
    <td>  Specify the value of a dashboard input.  Multiple <inlineCode>--dashboard-input</inlineCode> arguments may be passed.
    </td>
  </tr>

  <tr> 
    <td nowrap="true"> <inlineCode>--dashboard-listen string</inlineCode>  </td> 
    <td>  Accept connections from <inlineCode>local</inlineCode> (localhost only) or <inlineCode>network</inlineCode>  (default <inlineCode>local</inlineCode>). </td>
  </tr>

  <tr> 
    <td nowrap="true"> <inlineCode>--dashboard-port int</inlineCode>  </td> 
    <td>  Dashboard webserver port (default <inlineCode>9194</inlineCode>). </td>
  </tr>


  <tr> 
    <td nowrap="true"> <inlineCode>--export string</inlineCode>  </td> 
    <td> Export dashboard output to a file.  Supported export formats are <inlineCode>none</inlineCode>, <inlineCode>sps</inlineCode> (<inlineCode>snapshot</inlineCode>).  
    </td> 

  </tr>

  <tr> 
    <td nowrap="true"> <inlineCode>--help</inlineCode> </td> 
    <td>  Help for <inlineCode>steampipe dashboard.</inlineCode></td> 
  </tr>

  <tr> 
    <td nowrap="true"> <inlineCode>--input</inlineCode> </td> 
    <td>  Enable/Disable interactive prompts for missing variables.  To disable prompts and fail on missing variables, use <inlineCode>--input=false</inlineCode>.  This is useful when running from scripts. (default true)</td> 
  </tr>


  <tr> 
    <td nowrap="true"> <inlineCode>--mod-install bool</inlineCode>  </td> 
    <td>  Specify whether to install mod dependencies before running the dashboard (default <inlineCode>true</inlineCode>). </td>
  </tr>

  <tr> 
    <td nowrap="true"> <inlineCode>--output string</inlineCode> </td> 
    <td>  Select the console output format.  Possible values are <inlineCode>none, sps (snapshot)</inlineCode> (default <inlineCode>none</inlineCode>).</td> 
  </tr>

  <tr> 
    <td nowrap="true"> <inlineCode>--progress</inlineCode>  </td> 
    <td> Enable or disable progress information. By default, progress is shown - set <inlineCode>--progress=false</inlineCode> to hide the progress information.  </td>
  </tr>


  <tr> 
    <td nowrap="true"> <inlineCode>--search-path strings</inlineCode>  </td> 
    <td>  Set a comma-separated list of connections to use as a custom <a href="managing/connections#setting-the-search-path">search path</a> for the dashboard run. </td>
  </tr>
      
  <tr> 
    <td nowrap="true"> <inlineCode>--search-path-prefix strings</inlineCode>  </td> 
    <td>  Set a comma-separated list of connections to use as a prefix to the current <a href="managing/connections#setting-the-search-path">search path</a> for the dashboard run. </td>
  </tr>


  <tr> 
    <td nowrap="true"> <inlineCode>--share</inlineCode>  </td> 
    <td> Create snapshot in Steampipe Cloud with <inlineCode>anyone_with_link</inlineCode> visibility.  </td>
  </tr>

  <tr> 
    <td nowrap="true"> <inlineCode>--snapshot</inlineCode>  </td> 
    <td> Create snapshot in Steampipe Cloud with the default (<inlineCode>workspace</inlineCode>) visibility.  </td>
  </tr>
    
  <tr> 
    <td nowrap="true"> <inlineCode>--snapshot-location string</inlineCode>  </td> 
    <td> The location to write snapshots - either a local file path or a Steampipe Cloud workspace  </td>
  </tr>

  <tr> 
    <td nowrap="true"> <inlineCode>--snapshot-tag string=string  </inlineCode>  </td> 
    <td> Specify tags to set on the snapshot.  Multiple <inlineCode>--snapshot-tag </inlineCode> arguments may be passed.</td>
  </tr>


  <tr> 
    <td nowrap="true"> <inlineCode>--snapshot-title string=string  </inlineCode>  </td> 
    <td> The title to give a snapshot when uploading to Steampipe Cloud.  </td>
  </tr>


  <tr> 
    <td nowrap="true"> <inlineCode>--var string=string </inlineCode>  </td> 
    <td>  Specify the value of a mod variable. Multiple <inlineCode>--var </inlineCode> arguments may be passed.
    </td>
  </tr>

  <tr> 
    <td nowrap="true"> <inlineCode>--var-file string</inlineCode>  </td> 
    <td>  Specify an .spvars file containing mod variable values. 
    </td>
  </tr>
</table>

### Examples

Start the dashboard server and launch the browser to the dashboard home page:

```bash
steampipe dashboard
```


Start the dashboard server, but don't open the browser:

```bash
steampipe dashboard --browser=false
```

List the dashboards available to run in the current mod context:

```bash
steampipe dashboard list
```

Run a dashboard and save a [snapshot](/docs/snapshots/batch-snapshots):

```bash
steampipe dashboard --snapshot aws_insights.dashboard.aws_account_report
```

Run a dashboard and share a [snapshot](/docs/snapshots/batch-snapshots):

```bash
steampipe dashboard --share  aws_insights.dashboard.aws_account_report
```


Run a dashboard and save a [snapshot](/docs/snapshots/batch-snapshots), specifying inputs:

```bash
steampipe dashboard --snapshot --dashboard-input vpc_id=vpc-9d7ae1e7 \
  aws_insights.dashboard.aws_vpc_detail
```