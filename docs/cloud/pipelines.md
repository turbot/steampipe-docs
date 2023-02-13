---
title:  Pipelines
sidebar_label: Pipelines
---

# Pipelines
Steampipe Cloud **Pipelines** provide a fault-tolerant, retryable, scalable mechanism for scheduling and running long running workflows.  Steampipe Cloud uses pipelines for creating [scheduled snapshots](/docs/cloud/dashboards#scheduling-snapshots).

## Viewing and Editing Pipelines

To view your currently defined pipelines, head to your workspace and navigate to the **Pipelines** tab. Here you'll see a list of all the defined pipelines, with information on when they last run and when they are next due to run. Clicking on the **Last run**
option will take you to the [process](/docs/cloud/activity#processes) for that run.

<img src="/images/docs/cloud/cloud-pipelines.png" width="400pt"/>
<br />

If you navigate into a pipeline, you'll get an overview of 2 main areas. The left section shows details about the task that this pipeline is performing and on the right you'll get metadata about the pipeline, such as its run frequency.

<img src="/images/docs/cloud/cloud-pipeline-detail.png" width="400pt"/>
<br />

Depending on the type of pipeline being run, certain properties may be editable, such as **Snapshot Tags**, **Visibility** and **Notifications**.  Clicking the edit icon will bring up a modal that will allow you to edit the property.

<img src="/images/docs/cloud/cloud-pipeline-detail-frequency.png" width="400pt"/>
<br />

Note that which properties are available and editable varies by both the pipeline type and the limitations of your plan.

## Manual Pipeline Run

If desired, you can manually initiate a Pipeline run by clicking the **Run now**  button at the top of the page.  This allows you to run a pipeline on an ad hoc basis, and is useful for testing and troubleshooting. As with other Steampipe Cloud APIs, **Run now** is rate-limited, with per-plan limits.


## Deleting Pipelines
If you wish to delete the pipeline, click the **Delete pipeline** at the bottom of the metadata section. You'll be asked to confirm before it's deleted.

<img src="/images/docs/cloud/cloud-pipeline-detail-delete.png" width="400pt"/>
<br />