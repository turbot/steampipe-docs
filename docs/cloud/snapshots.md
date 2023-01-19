---
title:  Snapshots
sidebar_label: Snapshots
---

# Scheduling Snapshots

Rather than manually capture dashboard [snapshots](/cloud/dashboards#saving--sharing-snapshots), Steampipe Cloud allows you to schedule 
them and be notified when complete.

Scheduling a snapshot is as simple as navigating to the dashboard you wish to schedule, optionally setting it up with any 
required inputs and choosing the `Schedule` dropdown from the dashboard toolbar.

<img src="/images/docs/cloud/dash-snapshot-schedule-dropdown.png" width="400pt"/>
<br />

From here you can either choose to create a new schedule, or see any existing schedules that are configured for this dashboard.

If you select `New Schedule` you'll be presented with the following screen.

<img src="/images/docs/cloud/dash-snapshot-schedule-new.png" width="400pt"/>
<br />

<table>
  <tr> 
    <th>Option</th> 
    <th>Description</th> 
  </tr>
  <tr> 
    <td nowrap="true">Title</td> 
    <td>The title of the <a href="#pipelines">pipeline</a> that will run this schedule.</td>
  </tr>

  <tr> 
    <td nowrap="true">Frequency</td> 
    <td>When should this scheduled snapshot run? The options you have here depend on your plan:
      <br/>
      <br/>
      Developer: <inlineCode>Daily</inlineCode><br/>
      Team: <inlineCode>Daily</inlineCode>, <inlineCode>Hourly</inlineCode><br/>
      Enterprise: <inlineCode>Daily</inlineCode>, <inlineCode>Hourly</inlineCode>, <inlineCode>Custom</inlineCode><br/><br/>
      For <inlineCode>Daily</inlineCode> and <inlineCode>Hourly</inlineCode> frequencies, Steampipe Cloud will automatically 
      allocate a random time for these. For a <inlineCode>Custom</inlineCode> frequency, you can supply a cron schedule. 
     The cron must not run more than every 15 minutes.
    </td>
  </tr>

  <tr> 
    <td nowrap="true">Visibility</td> 
    <td>Optionally choose the visibility of the snapshot generated. By default, visibility is restricted to only those with access 
    to your workspace, but you can choose to share it such that anyone on the internet with the link can view it.</td> 
  </tr>

  <tr> 
    <td nowrap="true">Notifications</td> 
    <td>Optionally send a summary notification to a Slack and/or Microsoft Teams webhook. We will send a summary of all 
    the card values in the dashboard with a link back to the Snapshot. 
    </td> 
  </tr>

  <tr> 
    <td nowrap="true">Snapshot tags</td> 
    <td>Add optional tags to the created snapshot. These can be used to easily find snapshots at a later date via the search functionality.</td> 
  </tr>
</table>

After scheduling a snapshot, you will be taken to the `[pipeline detail](#pipelines)` page, which shows you editable details 
of  the schedule, information on its next run and last run status, along with a link out to the process logs.

<img src="/images/docs/cloud/dash-snapshot-schedule-detail.png" width="400pt"/>
<br />

For a new schedule there will be no `Last run` information, so we provide a rate-limited manual `Run now` option, allowing 
you to test out the schedule / notifications etc. 

## Pipelines

Under the cover, Steampipe Cloud schedules and runs this as a `pipeline`, which can be used to compose anything from simple 
tasks to long-running, complex workflows. This allows the process to be fault-tolerant, retryable (where applicable) and scalable.