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
| [steampipe login](reference/cli/login)        | Log in to Steampipe CLoud
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
    <td>  Sets the Steampipe Cloud host used when connecting to Steampipe Cloud workspaces.  See <a href="/docs/reference/env-vars/steampipe_cloud_host">STEAMPIPE_CLOUD_HOST</a> for details. </td>
  </tr>

  <tr> 
    <td nowrap="true"> <inlineCode>--cloud-token</inlineCode>  </td> 
    <td>  Sets the Steampipe Cloud authentication token used when connecting to Steampipe Cloud workspaces.  See <a href="/docs/reference/env-vars/steampipe_cloud_token">STEAMPIPE_CLOUD_TOKEN</a> for details. </td>
  </tr>

  <tr> 
    <td nowrap="true"> <inlineCode>-h</inlineCode>, <inlineCode>--help</inlineCode> </td> 
    <td>  Help for Steampipe. </td> 
  </tr>
                  
  <tr> 
    <td nowrap="true"> <inlineCode>--install-dir</inlineCode>  </td> 
    <td>  Sets the directory for the Steampipe installation, in which the Steampipe database, plugins, and supporting files can be found.  See <a href="/docs/reference/env-vars/steampipe_install_dir">STEAMPIPE_INSTALL_DIR</a> for details. </td>
  </tr>

  <tr> 
    <td nowrap="true"> <inlineCode>--mod-location</inlineCode>  </td> 
    <td> Sets the Steampipe workspace working directory.  If not specified, the workspace directory will be set to the current working directory.  See <a href="/docs/reference/env-vars/steampipe_mod_location">STEAMPIPE_MOD_LOCATION</a> for details. </td>
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
    <td>  Sets the Steampipe <a href="/docs/managing/workspaces"> workspace profile</a>.  If not specified, the <inlineCode>default</inlineCode> workspace will be used if it exists.  See <a href="/docs/reference/env-vars/steampipe_workspace">STEAMPIPE_WORKSPACE</a> for details.</td>
  </tr>

  <tr> 
    <td nowrap="true"> <inlineCode>--workspace-chdir</inlineCode>  </td> 
    <td>  <b>(DEPRECATED: please use <inlineCode>--mod-location</inlineCode>)</b> Sets the Steampipe workspace directory.  If not specified, the workspace directory will be set to the current working directory.  See <a href="/docs/reference/env-vars/steampipe_workspace_chdir">STEAMPIPE_WORKSPACE_CHDIR</a> for details. </td>
  </tr>

  <tr> 
    <td nowrap="true"> <inlineCode>--workspace-database</inlineCode>  </td> 
    <td>  Sets the database that Steampipe will connect to. This can be <inlineCode>local</inlineCode> (the default) or a remote Steampipe Cloud database.  See <a href="/docs/reference/env-vars/steampipe_workspace_database">STEAMPIPE_WORKSPACE_DATABASE</a> for details. </td>
  </tr>


</table>



---

