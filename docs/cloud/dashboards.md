---
title:  Dashboards
sidebar_label: Dashboards
---

# Viewing Dashboards

Once you've added a connection and installed one or more mods into your workspace, the [Dashboards](dashboard/overview) (including [Benchmarks](check/overview)) will become available for you to run in the **Dashboards** tab. You can browse the list, or use the powerful search to filter by name / tag etc.


<img src="/images/docs/cloud/gs_dashboard_list.png" width="400pt"/>
<br />

Click on a dashboard to run it.

<img src="/images/docs/cloud/dash_example_1.png" width="400pt"/>
<br />



## Saving & Sharing Snapshots

Steampipe Cloud allows you to save and share dashboard **snapshots**.
A snapshot is a saved view of a dashboard at a point in time with a given set of inputs and variables.


To take a snapshot, click the **Snap** button at the top of the dashboard after the dashboard is fully loaded (the button will be disabled until the dashboard has finished loading).  

<img src="/images/docs/cloud/dash_snapshot_header.png" width="400pt"/>
<br />


Alternately, you can click the **Share** button to take a snapshot and share a link with others.  You can set the visibility of the snapshot to
restrict access to only those with access to your workspace, or share it such that anyone on the internet with the link can view it.

<img src="/images/docs/cloud/dash_snapshot_share.png" width="400pt"/>
<br />

## Browsing Snapshots

From any dashboard, you can browse and navigate its snapshot history.  Click the **View** button at the top of the dashboard to display the menu.  You can select a date from the calendar and the snapshots from that date are listed beneath.  Click any snapshot to open it.

<img src="/images/docs/cloud/dash_snapshot_dropdown.png" width="400pt"/>
<br />

Clicking **All matching snapshots** at the bottom of the menu will take you to the snapshots page (you can also navigate to this page by clicking the **Snapshots** button at the top of the **Dashboards** pane).


## Managing Snapshots

You can browse and search all snapshots in your workspace. From the main dashboard page, click the **Snapshots** button at the top of the page.  

<img src="/images/docs/cloud/dash_header_snap.png" width="400pt"/>
<br />

The Snapshots page allows you to manage all snapshots in your workspace.  The **Query** box allows you to enter a [query filter](cloud/reference/query-api) to search and filter the snapshot list.

<img src="/images/docs/cloud/dash_snap_list.png" width="400pt"/>
<br />

Click any snapshot to view it.  

To delete a snapshot, click the trash can icon for the snapshot you wish to delete.  You will be prompted to confirm deletion.

<img src="/images/docs/cloud/dash_snap_delete_confirm.png" width="400pt"/>
<br />


## Scheduling Snapshots

Rather than manually capture dashboard snapshots, Steampipe Cloud allows you to schedule them and be notified when complete.

Scheduling a snapshot is as simple as navigating to the dashboard you wish to schedule, optionally setting it up with any required inputs and choosing the **Schedule** dropdown from the dashboard toolbar.

<img src="/images/docs/cloud/dash-snapshot-schedule-dropdown.png" width="400pt"/>
<br />

From here you can either choose to create a new schedule, or see any existing schedules that are configured for this dashboard.

If you select **New Schedule** you'll be presented with the following screen.

<img src="/images/docs/cloud/dash-snapshot-schedule-new.png" width="400pt"/>
<br />

<table>
  <tr>
    <th>Option</th>
    <th>Description</th>
  </tr>
  <tr>
    <td nowrap="true">Title</td>
    <td>The title of the <a href="/docs/cloud/pipelines">pipeline</a> that will run this schedule.</td>
  </tr>

  <tr>
    <td nowrap="true">Frequency</td>
    <td>When should this scheduled snapshot run? The options you have here depend on your plan:
      <br/>
      <br/>
      Developer: <inlineCode>Weekly</inlineCode>, <inlineCode>Daily</inlineCode><br/>
      Team: <inlineCode>Weekly</inlineCode>, <inlineCode>Daily</inlineCode>, <inlineCode>Hourly</inlineCode>, <inlineCode>Custom</inlineCode> (not more than once per hour)<br/>
      Enterprise: <inlineCode>Weekly</inlineCode>, <inlineCode>Daily</inlineCode>, <inlineCode>Hourly</inlineCode>, <inlineCode>Custom</inlineCode>(not more than once every 15 minutes)<br/><br/>
      For <inlineCode>Weekly</inlineCode>, <inlineCode>Daily</inlineCode> and <inlineCode>Hourly</inlineCode> frequencies, Steampipe Cloud will automatically allocate a random time for these, with <inlineCode>Weekly</inlineCode> schedules being run at that time on a Sunday. For a <inlineCode>Custom</inlineCode> frequency, you can supply a cron schedule.  The maximum frequency for the cron schedule varies by plan.
    </td>
  </tr>

  <tr>
    <td nowrap="true">Visibility</td>
    <td>Optionally choose the visibility of the snapshot generated. By default, visibility is restricted to only those with access to your workspace, but you can choose to share it such that anyone on the internet with the link can view it.</td>
  </tr>

  <tr>
    <td nowrap="true">Notifications</td>
    <td>Optionally send a summary notification to a Slack and/or Microsoft Teams webhook. We will send a summary of all the card values in the dashboard with a link back to the Snapshot.
    </td>
  </tr>

  <tr>
    <td nowrap="true">Snapshot tags</td>
    <td>Add optional tags to the created snapshot. These can be used to easily find snapshots at a later date via the search functionality.</td>
  </tr>
</table>

After scheduling a snapshot, you will be taken to the [pipeline detail](/docs/cloud/pipelines) page, which shows you editable details of the schedule, information on its next run and last run status, along with a link out to the [process](/docs/cloud/activity#processes) logs.

The scheduled snapshot pipeline will upload the snapshot to your workspace as the `system` user, rather than attribute the activity to the user creating the schedule. We will retry steps in the pipeline where possible e.g. any 5xx series errors
from a call to a notification webhook will retry up to a maximum of 2 times, whereas a 400 error would not retry.