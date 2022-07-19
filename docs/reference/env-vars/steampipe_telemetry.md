---
title: STEAMPIPE_TELEMETRY
sidebar_label: STEAMPIPE_TELEMETRY
---

### STEAMPIPE_TELEMETRY

By default, Steampipe collects usage information to help assess features, usage patterns, and bugs.  This information helps us improve and optimize the Steampipe experience.  We do not collect any sensitive information such as secrets, environment variables or file contents.  We do not share your data with anyone.  Current options are:
- `none`: do not collect or send any telemetry data.
- `info`: send basic information such as which plugins are installed, what mods are used, how and when steampipe is started and stopped.  **If you are connecting to [Steampipe Cloud](cloud/overview)**, we also include the following:
  - actor id
  - actor handle
  - identity id
  - identity handle
  - identity type
  - workspace id


#### Usage 

Disable telemetry data:

```bash
export STEAMPIPE_TELEMETRY=none
```

Enable telemetry data at `info` level (this is the default)

```bash
export STEAMPIPE_TELEMETRY=info
```