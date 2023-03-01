---
title:  Queries
sidebar_label: Queries
---

# Running Queries

Once you've added a connection you will be able to run [SQL queries](sql/steampipe-sql) to explore your data, either interactively in the console, or via any PostgreSQL-compatible client - see our [integrations pages](cloud/integrations/overview) for some examples.

## Exploring Schemas

If you navigate to your workspace, then the **Query** tab, you'll see the interactive query console.

<img src="/images/docs/cloud/cloud-query-editor.png" width="400pt"/>
<br />

From here you can either explore your schemas on the left, or dive right in and test out your own queries in the editor. The schema list supports flexible searching across all the tables in your schemas. For example, if you search for `hack new`, 
that will find a match for the `hackernews_show_hn` table in our `hackernews` schema.

<img src="/images/docs/cloud/cloud-query-schema-search.png" width="200pt"/>
<br />

Clicking the search result will automatically generate a query to select all the columns from that schema table, limited to 100 rows and will automatically run it for you.

<img src="/images/docs/cloud/cloud-query-table-results.png" width="400pt"/>
<br />

If you click the `Edit` button you can amend the query, perhaps by selecting just the columns you're interested in, or adding a `where` clause to filter the results. Please note that we limit queries to 5,000 rows in the interactive query console.  

<img src="/images/docs/cloud/cloud-query-custom-query.png" width="400pt"/>
<br />

## Downloading Results

After you've run a query, you can download the results to a CSV file by clicking the **Download** button at the bottom of the query editor.

## Saving & Sharing Snapshots

Steampipe Cloud allows you to save and share query **snapshots** that are dashboards containing a table generated from your query results.

To take a snapshot, click the **Snap** button at the top of the query editor after you have run the query you wish to snap.  

<img src="/images/docs/cloud/cloud-query-toolbar.png" width="200pt"/>
<br />

This will then take you to the dashboard snapshot view.

<img src="/images/docs/cloud/cloud-query-snapshot.png" width="400pt"/>
<br />

## Browsing Snapshots

From any query snapshot, you can browse and navigate its snapshot history. We generate a hash of the query used in the snapshot, allowing us to find other snapshots relating to this query. 
Click the **View** button at the top of the dashboard to display the menu.  You can select a date from the calendar and the snapshots from that date are listed beneath. Click any snapshot to open it.

<img src="/images/docs/cloud/cloud-query-related-snapshots.png" width="200pt"/>
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


## Scheduling Query Snapshots

Rather than manually capture query snapshots, Steampipe Cloud allows you to schedule them and be notified when complete.

Scheduling a snapshot is as simple as navigating to the query editor, selecting a table or writing a query and choosing the **Schedule** dropdown from the query toolbar.

<img src="/images/docs/cloud/cloud-query-snapshot-schedule-dropdown.png" width="300pt"/>
<br />

From here you can either choose to create a new schedule, or see any existing schedules that are configured for this query.

If you select **New Schedule** you'll be presented with the following screen.

<img src="/images/docs/cloud/cloud-query-snapshot-schedule-new.png" width="300pt"/>
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
    <td>Optionally send a summary notification to a Slack and/or Microsoft Teams webhook. This will contain a link back to the Snapshot.
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