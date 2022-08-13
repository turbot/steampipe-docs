---
title:  Using the Steampipe Cloud plugin for Steampipe
sidebar_label: Steampipe Plugin
---

#  Query Steampipe Cloud API with the Steampipe Cloud Plugin

The Steampipe Cloud plugin makes it easy to query your Workspaces, Connections, and other Steampipe Cloud assets using Steampipe!

**[View the docs on the Hub →](https://hub.steampipe.io/plugins/turbot/steampipecloud)**

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
