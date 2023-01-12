---
title: STEAMPIPE_MAX_PARALLEL
sidebar_label: STEAMPIPE_MAX_PARALLEL
---

# STEAMPIPE_MAX_PARALLEL
Set the maximum number of database connections to open.  Steampipe will attempt to run up to this many queries in parallel.  This is essentially a connection pool size - Steampipe will open a database connection for each parallel instance.  The default is 10.

## Usage 
```bash
export STEAMPIPE_MAX_PARALLEL=3
```