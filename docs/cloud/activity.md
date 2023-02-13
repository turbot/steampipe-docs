---
title:  Activity
sidebar_label: Activity
---
# Activity
The **Activity** tab provides visibility into the events that occur in your Steampipe Cloud environment.  


## Audit Log
The **Audit Log** provides a log of API activity associated with your user, organization, or workspace, including *who* did *what* and *when*.  
- To view the audit log for your workspace, click **Audit Log** on the **Activity** page for the workspace.  
- To view the audit log for your user or organization, click **Audit Log** on the **Settings** page for the user or organization.

<img src="/images/docs/cloud/cloud_audit_log.png" width="400pt"/>
<br />


## DB Logs
Steampipe Cloud provides a log of the queries that have been run against your workspace.
To view the query logs, go to the **Activity** tab for your workspace, then select **DB Log** from the menu on the left.


<img src="/images/docs/cloud/cloud_db_log.png" width="400pt"/>
<br />


## Processes

Many Steampipe Cloud APIs perform tasks asynchronously. These tasks include one-time requests (install a mod into a workspace), recurring system tasks (update the workspace container image and plugins every week), and user-scheduled activities (create a snapshot of the AWS CIS v1.5.0 Benchmark every day).  Steampipe **Processes** provide visibility into these activities.

To view your processes, navigate to either your own identity or workspace **Activity**
tab and then to the **Processes** left-nav. Here you'll find a list of processes with a link to the detail for each.

<img src="/images/docs/cloud/cloud-processes.png" width="400pt"/>
<br />

If you click into a process in the list, you'll see the status, which user initiated it and where applicable, a link to the pipeline for it.

<img src="/images/docs/cloud/cloud-process-detail.png" width="400pt"/>
<br />

You'll also see detailed logs, with expandable and copyable data where available.

<img src="/images/docs/cloud/cloud-process-logs.png" width="400pt"/>
<br />
