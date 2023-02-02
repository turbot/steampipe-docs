---
title:  Pipelines
sidebar_label: Pipelines
---

## Pipelines

Under the cover, Steampipe Cloud schedules and runs workflows as a `pipeline`, which can be used to compose anything from simple
tasks to long-running, complex workflows. This allows the process to be fault-tolerant, retryable (where applicable) and scalable.

To view your currently defined pipelines, head to your workspace and navigate to the `Pipelines` tab. Here you'll see a list of
all the defined pipelines, with information on when they last run and when they are next due to run. Clicking on the `Last run`
option will take you to the [process](#processes) for that run.  

<img src="/images/docs/cloud/cloud-pipelines.png" width="400pt"/>
<br />

If you navigate into a pipeline, you'll get an overview of 2 main areas. The left section shows details about the task that
this pipeline is performing and on the right you'll get metadata about the pipeline, such as its run frequency.

<img src="/images/docs/cloud/cloud-pipeline-detail.png" width="400pt"/>
<br />

Depending on the type of pipeline being run, certain properties may be editable. In the case of a scheduled snapshot like shown,
the `Snapshot Tags`, `Visibility` and `Notifications` are editable.

Certain metadata properties of a pipeline are editable, such as the `Frequency` and `Pipeline Tags`. Clicking the edit icon for `Frequency` 
will bring up a modal that will allow you to edit this (subject to the limitations of your plan).

<img src="/images/docs/cloud/cloud-pipeline-detail-frequency.png" width="400pt"/>
<br />

For a new schedule there will be no `Last run` information, so we provide a rate-limited manual `Run now` option, allowing
you to test out the schedule / notifications etc.

If you wish to delete the pipeline, click the `Delete pipeline` at the bottom of the metadata section. You'll be asked to confirm 
this before it's deleted.

<img src="/images/docs/cloud/cloud-pipeline-detail-delete.png" width="150pt"/>
<br />