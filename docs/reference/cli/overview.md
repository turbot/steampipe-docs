---
title: Steampipe CLI
sidebar_label: Steampipe CLI
---

# Steampipe CLI

## Sub-Commands

| Command | Description
|-|-
| [steampipe check](reference/cli/check)    | Run Steampipe benchmarks and controls
| [steampipe completion](reference/cli/completion)| Generate the autocompletion script for the specified shell
| [steampipe dashboard](reference/cli/dashboard)| Steampipe dashboards
| [steampipe help](reference/cli/help)      | Help about any command
| [steampipe mod](reference/cli/mod)        | Steampipe mod management
| [steampipe plugin](reference/cli/plugin)  | Steampipe plugin management
| [steampipe query](reference/cli/query)    | Execute SQL queries interactively or by argument
| [steampipe service](reference/cli/service)| Steampipe service management
| [steampipe variable](reference/cli/variable)| Steampipe variable management


## Global Flags


<table>
  <tr> 
    <th> Flag </th> 
    <th> Description </th> 
  </tr>

  <tr> 
    <td nowrap="true"> <inlineCode>--cloud-host</inlineCode>  </td> 
    <td>  Sets the Steampipe Cloud host used when connecting to Steampipe Cloud workspaces.  See the <a href="/docs/reference/env-vars/steampipe_cloud_host">STEAMPIPE_CLOUD_HOST</a> environment variable documentation for details. </td>
  </tr>

  <tr> 
    <td nowrap="true"> <inlineCode>--cloud-token</inlineCode>  </td> 
    <td>  Sets the Steampipe Cloud authentication token used when connecting to Steampipe Cloud workspaces.  See the <a href="/docs/reference/env-vars/steampipe_cloud_token">STEAMPIPE_CLOUD_TOKEN</a> environment variable documentation for details. </td>
  </tr>

  <tr> 
    <td nowrap="true"> <inlineCode>-h</inlineCode>, <inlineCode>--help</inlineCode> </td> 
    <td>  Help for Steampipe. </td> 
  </tr>

  <tr> 
    <td nowrap="true"> <inlineCode>--input</inlineCode> </td> 
    <td>  Enable interactive prompts (default true) </td> 
  </tr>
                        

  <tr> 
    <td nowrap="true"> <inlineCode>--install-dir</inlineCode>  </td> 
    <td>  Sets the directory for the Steampipe installation, in which the Steampipe database, plugins, and supporting files can be found.  See the <a href="/docs/reference/env-vars/steampipe_install_dir">STEAMPIPE_INSTALL_DIR</a> environment variable documentation for details. </td>
  </tr>


<!--
  <tr> 
    <td nowrap="true"> <inlineCode>--schema-comments</inlineCode></td> 
    <td>   Include schema comments when importing connection schemas (default true).  Set to false to reduce the load time for very high connection counts.  If you disable schema comments, the inspect command will not have descriptions. </td> 
  </tr>

-->
  <tr> 
    <td nowrap="true"> <inlineCode>-v</inlineCode>, <inlineCode>--version</inlineCode>  </td> 
    <td>  Display Steampipe version. </td> 
  </tr>

  <tr> 
    <td nowrap="true"> <inlineCode>--workspace</inlineCode>  </td> 
    <td>  <b>(DEPRECATED: please use <inlineCode>--workspace-chdir</inlineCode>).</b> Sets the Steampipe workspace directory.  If not specified, the workspace directory will be set to the current working directory. </td>
  </tr>

  <tr> 
    <td nowrap="true"> <inlineCode>--workspace-chdir</inlineCode>  </td> 
    <td>  Sets the Steampipe workspace directory.  If not specified, the workspace directory will be set to the current working directory.  See the <a href="/docs/reference/env-vars/steampipe_workspace_chdir">STEAMPIPE_WORKSPACE_CHDIR</a> environment variable documentation for details. </td>
  </tr>

  <tr> 
    <td nowrap="true"> <inlineCode>--workspace-database</inlineCode>  </td> 
    <td>  Sets the database that Steampipe will connect to. This can be <inlineCode>local</inlineCode> (the default) or a remote Steampipe Cloud database.  See the <a href="/docs/reference/env-vars/steampipe_workspace_database">STEAMPIPE_WORKSPACE_DATABASE</a> environment variable documentation for details. </td>
  </tr>


</table>



---

