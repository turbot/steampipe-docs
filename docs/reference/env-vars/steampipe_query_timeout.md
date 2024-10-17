---
title: STEAMPIPE_QUERY_TIMEOUT
sidebar_label: STEAMPIPE_QUERY_TIMEOUT
---

# STEAMPIPE_QUERY_TIMEOUT
The amount of time to wait for a query to complete before timing out, in seconds. 

Set to `0` to disable the query timeout.  The default is `0`.



## Usage 
Set query timeout to 2 minutes

```bash
export STEAMPIPE_QUERY_TIMEOUT=120
```

Disable the query timeout:

```bash
export STEAMPIPE_QUERY_TIMEOUT=0
```

Reset query timeout to the default

```bash
unset STEAMPIPE_QUERY_TIMEOUT
```