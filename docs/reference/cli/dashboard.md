---
title: steampipe dashboard
sidebar_label: steampipe dashboard
---

# steampipe dashboard
Run the Steampipe Dashboard server.

The Dashboard loads the `mod` in the current working directory or the `--workspace-chdir` and listens for changes to dashboards defined in the `mod`.

## Usage
```bash
steampipe dashboard [flags]
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
    <td nowrap="true"> <inlineCode>--dashboard-listen string</inlineCode>  </td> 
    <td>  Accept connections from <inlineCode>local</inlineCode> (localhost only) or <inlineCode>network</inlineCode>  (default <inlineCode>local</inlineCode>). </td>
  </tr>

  <tr> 
    <td nowrap="true"> <inlineCode>--dashboard-port int</inlineCode>  </td> 
    <td>  Dashboard webserver port (default <inlineCode>9194</inlineCode>). </td>
  </tr>

  <tr> 
    <td nowrap="true"> <inlineCode>--mod-install bool</inlineCode>  </td> 
    <td>  Specify whether to install mod dependencies before running the dashboard (default <inlineCode>true</inlineCode>). </td>
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
    <td nowrap="true"> <inlineCode>--var string </inlineCode>  </td> 
    <td>  Specify the value of a mod variable. 
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