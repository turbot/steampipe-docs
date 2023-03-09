---
title: STEAMPIPE_DATABASE_START_TIMEOUT
sidebar_label: STEAMPIPE_DATABASE_START_TIMEOUT
---

# STEAMPIPE_DATABASE_START_TIMEOUT

The maximum time (in seconds) to wait for the Postgres process to start accepting queries after it has been started.  The default is `30`.

Note that `STEAMPIPE_DATABASE_START_TIMEOUT` is ignored if the database goes into recovery mode upon startup -- Steampipe will wait indefinitely for recovery to complete.  This can be cancelled with `Ctrl+C`.

## Usage 

Set database start timeout to 5 minutes:

```bash
export STEAMPIPE_DATABASE_START_TIMEOUT=300 
```