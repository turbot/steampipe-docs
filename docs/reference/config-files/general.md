---
title: General options
sidebar_label: general
---




### General options
**General** options apply generally to the steampipe CLI. 

#### Supported options  
| Argument | Default | Values | Description 
|-|-|-|-
| `max_parallel` | `5` | an integer| Set the maximum number of parallel executions. When running `steampipe check`, Steampipe will attempt to run up to this many controls in parallel. This can also be set via the  `STEAMPIPE_MAX_PARALLEL` environment variable.
| `telemetry` | `none` | `none`, `info` | Set the telemetry level in Steampipe. This can also be set via the  [STEAMPIPE_TELEMETRY](reference/env-vars/steampipe_telemetry) environment variable.
| `update_check` | `true` | `true`, `false` | Enable or disable automatic update checking. This can also be set via the  [STEAMPIPE_UPDATE_CHECK](reference/env-vars/steampipe_update_check) environment variable.
#### Example: General Options  

```hcl
options "general" {
  update_check = true    # true, false
  max_parallel = 3
  telemetry    = "info"  # info, none
}   
```

---