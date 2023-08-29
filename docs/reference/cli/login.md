---
title: steampipe login
sidebar_label: steampipe login
---


# steampipe login
Log in to [Turbot Pipes](https://turbot.com/pipes/docs).

The Steampipe CLI can interact with Turbot Pipes to run queries, benchmarks, and dashboards against a remote cloud database, and to save and share snapshots. These capabilities require authenticating to Turbot Pipes.  The `steampipe login` command launches an interactive process for logging in and obtaining a temporary (30 day) token. The token is written to `~/.steampipe/internal/{cloud host}.tptt`.

## Usage
```bash
steampipe login
```

## Flags:

<table>
  <tr> 
    <th> Argument </th> 
    <th> Description </th> 
  </tr>
  <tr> 
    <td nowrap="true"> <inlineCode>--cloud-host</inlineCode> </td> 
    <td>  Sets the Turbot Pipes host used when connecting to Turbot Pipes workspaces. See <a href="reference/env-vars/steampipe_cloud_host">STEAMPIPE_CLOUD_HOST</a> for details.</td> 
  </tr>

  <tr> 
    <td nowrap="true"> <inlineCode>--cloud-token</inlineCode> </td> 
    <td>  Sets the Turbot Pipes authentication token used when connecting to Turbot Pipes workspaces. See <a href="reference/env-vars/steampipe_cloud_token">STEAMPIPE_CLOUD_TOKEN</a> for details.</td> 
  </tr>

  <tr> 
    <td nowrap="true"> <inlineCode>--workspace</inlineCode>  </td> 
    <td>  Sets the Steampipe <a href="/docs/managing/workspaces"> workspace profile</a>.  If not specified, the <inlineCode>default</inlineCode> workspace will be used if it exists.  See <a href="/docs/reference/env-vars/steampipe_workspace">STEAMPIPE_WORKSPACE</a> for details.</td>
  </tr>

  <tr> 
    <td nowrap="true"> <inlineCode>--workspace-database</inlineCode>  </td> 
    <td>  Sets the database that Steampipe will connect to. This can be <inlineCode>local</inlineCode> (the default) or a remote Turbot Pipes database.  See <a href="/docs/reference/env-vars/steampipe_workspace_database">STEAMPIPE_WORKSPACE_DATABASE</a> for details. </td>
  </tr>
</table>

## Examples

Login to `pipes.turbot.com`:

```bash
steampipe login
```


The `steampipe login` command will launch your web browser to continue the login process. Verify the request.



<img src="/images/docs/steampipe-login/steampipe-login-1.png" width="100%" />



After you have verified the request, the browser will display a verification code.   
<img src="/images/docs/steampipe-login/steampipe-login-2.png" width="100%" />

Paste the code into the cli and hit enter to complete the login process:

```bash
$ steampipe login
Verify login at https://pipes.turbot.com/login/token?r=tpttr_cdckfake6ap10t9dak0g_3u2k9hfake46g4o4wym7h8hw
Enter verification code: 745278
Login successful for user johnsmyth
```
