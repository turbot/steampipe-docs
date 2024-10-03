---
title: Steampipe CLI
sidebar_label: Steampipe CLI
---

# Steampipe CLI

## Sub-Commands

| Command | Description
|-|-
| [steampipe completion](reference/cli/completion)| Generate the autocompletion script for the specified shell
| [steampipe help](reference/cli/help)      | Help about any command
| [steampipe login](reference/cli/login)        | Log in to Steampipe CLoud
| [steampipe plugin](reference/cli/plugin)  | Steampipe plugin management
| [steampipe query](reference/cli/query)    | Execute SQL queries interactively or by argument
| [steampipe service](reference/cli/service)| Steampipe service management

<!--
| [steampipe check](reference/cli/check)    | Run Steampipe benchmarks and controls
| [steampipe dashboard](reference/cli/dashboard)| Steampipe dashboards
| [steampipe mod](reference/cli/mod)        | Steampipe mod management
| [steampipe variable](reference/cli/variable)| Steampipe variable management

-->

## Global Flags


<table>
  <tr> 
    <th> Flag </th> 
    <th> Description </th> 
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
    <td nowrap="true"> <inlineCode>--workspace</inlineCode>  </td> 
    <td>  Sets the Steampipe <a href="/docs/managing/workspaces"> workspace profile</a>.  If not specified, the <inlineCode>default</inlineCode> workspace will be used if it exists.  See <a href="/docs/reference/env-vars/steampipe_workspace">STEAMPIPE_WORKSPACE</a> for details.</td>
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

</table>

## Exit Codes

|  Value  |   Name                                | Description
|---------|---------------------------------------|----------------------------------------
|   **0** | `ExitCodeSuccessful`                  | Steampipe ran successfully, with no runtime errors, control errors, or alarms
|  **11** | `ExitCodePluginLoadingError`          | Plugin loading error
|  **12** | `ExitCodePluginListFailure`           | Plugin listing failed
|  **13** | `ExitCodePluginNotFound`              | Plugin not found
|  **14** | `ExitCodePluginInstallFailure`        | Plugin install failed
|  **31** | `ExitCodeServiceSetupFailure`         | Service setup failed
|  **32** | `ExitCodeServiceStartupFailure`       | Service start failed
|  **33** | `ExitCodeServiceStopFailure`          | Service stop failed
|  **41** | `ExitCodeQueryExecutionFailed`        | One or more queries failed for `steampipe query` 
|  **51** | `ExitCodeLoginCloudConnectionFailed`  | Connecting to cloud failed
| **249** | `ExitCodeInvalidExecutionEnvironment` | Steampipe was run in an unsupported environment
| **250** | `ExitCodeInitializationFailed`        | Initialization failed
| **251** | `ExitCodeBindPortUnavailable`         | Network port binding failed
| **253** | `ExitCodeFileSystemAccessFailure`     | File system access failed
| **254** | `ExitCodeInsufficientOrWrongInputs`   | Runtime error - insufficient or incorrect input
| **255** | `ExitCodeUnknownErrorPanic`           | Runtime error - an unknown panic occurred


<!--
|   **1** | `ExitCodeControlsAlarm`               | `steampipe check` completed with no runtime or control errors, but there were one or more alarms
|   **2** | `ExitCodeControlsError`               | `steampipe check` completed with no runtime errors,  but one or more control errors occurred
|  **21** | `ExitCodeSnapshotCreationFailed`      | Snapshot creation failed
|  **22** | `ExitCodeSnapshotUploadFailed`        | Snapshot upload failed
|  **61** | `ExitCodeModInitFailed`               | Mod init failed
|  **62** | `ExitCodeModInstallFailed`            | Mod install failed
| **252** | `ExitCodeNoModFile`                   | The command requires a mod, but no mod file was found

-->