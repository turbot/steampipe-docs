---
title: STEAMPIPE_INTROSPECTION
sidebar_label: STEAMPIPE_INTROSPECTION
---

# STEAMPIPE_INTROSPECTION

Steampipe can create a set of introspection tables that allow you to query the mod resources in the workspace.  For performance reasons, introspection is disabled by default, however you can enable it by setting the `STEAMPIPE_INTROSPECTION` environment variable.

Once enabled, you can query the introspection tables.  For example, you can list all the benchmarks in the workspace:

```
> select resource_name from steampipe_benchmark order by resource_name
+----------------------+
| resource_name        |
+----------------------+
| cis_v130             |
| cis_v130_1           |
| cis_v130_2           |
| cis_v130_2_1         |
| cis_v130_2_2         |
| cis_v130_3           |
| cis_v130_4           |
| cis_v130_5           |
| pci_v321             |
| pci_v321_autoscaling |
| pci_v321_cloudtrail  |
| pci_v321_kms         |
+----------------------+
```



<!--
generate with:
select table_name from information_schema.tables where table_name like 'steampipe_%' and table_type = 'LOCAL TEMPORARY'
-->
When introspection is enabled, the following tables are available to query:
- `steampipe_benchmark`
- `steampipe_control`
- `steampipe_dashboard`
- `steampipe_dashboard_card`
- `steampipe_dashboard_chart`
- `steampipe_dashboard_container`
- `steampipe_dashboard_flow`
- `steampipe_dashboard_graph`
- `steampipe_dashboard_hierarchy`
- `steampipe_dashboard_image`
- `steampipe_dashboard_input`
- `steampipe_dashboard_table`
- `steampipe_dashboard_text`
- `steampipe_mod`
- `steampipe_query`
- `steampipe_reference`
- `steampipe_variable`



## Usage 


Enable introspection data

```bash
export STEAMPIPE_INTROSPECTION=info
```


Disable introspection data (the default):

```bash
unset STEAMPIPE_INTROSPECTION

```