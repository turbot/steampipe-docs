---
title:  Using the Steampipe Cloud plugin for Steampipe
sidebar_label: Plugin
---


#  Query Steampipe Cloud API with the Steampipe Cloud Plugin
The Steampipe Cloud plugin, available on the [Steampipe Hub](https://hub.steampipe.io/plugins/turbot/steampipecloud), makes it easy to query your Workspaces, Connections, and other Steampipe Cloud assets using Steampipe!

```sql
select
  user_handle,
  email,
  status
from
  steampipecloud_organization_member
where
  status = 'invited'
```