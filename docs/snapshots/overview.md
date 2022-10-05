---
title: Save Snapshots
sidebar_label: Save Snapshots
---

# Save Snapshots

Steampipe allows you to take **snapshots** of queries, dashboards, and benchmarks.  A snapshot is a saved view of a dashboard, query, or benchmark at a given point in time with a given set of inputs and variables.  All data and metadata for a snapshot is contained in a json file which is uploaded and saved to [Steampipe Cloud](/docs/cloud/overview).

A snapshot may be shared only with Steampipe Cloud users that have access to the workspace, or you may make a snapshot public, available to anyone that has the link. Note that the public url is the same as the private url, and whether or not a snapshot is public or private depends only on a property of the snapshot.

You may create tags on your snapshots. Tags can be used to search for and organize snapshots.

You can create snapshots directly from the Steampipe CLI, however if you with to subsequently [modify]](/docs/cloud/dashboards#managing-snapshots) them (add/remove tags, change visibility) or delete them, you must do so from the Steampipe Cloud console. You may [browse the snapshot list](/docs/cloud/dashboards#browsing-snapshots) by clicking the **Snapshots** button on the top of your workspace's **Dashboards** page.
