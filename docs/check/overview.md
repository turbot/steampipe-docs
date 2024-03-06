---
title: Run Benchmarks
sidebar_label: Run Benchmarks
---

# Running Benchmarks

> ***Powerpipe is now the recommended way to run dashboards and benchmarks!***
> Mods still work as normal in Steampipe for now, but they are deprecated and will be removed in a future release:
> - [Steampipe Unbundled →](https://steampipe.io/blog/steampipe-unbundled)
> - [Powerpipe for Steampipe users →](https://powerpipe.io/blog/migrating-from-steampipe)

Steampipe **controls** and **benchmarks** provide a generic mechanism for defining and running control frameworks such as CIS, NIST, HIPAA, etc, as well as your own customized groups of controls.

There are many control frameworks in existence today, and though they are all implemented with their own specific syntax and structure, they are generally organized in a defined, hierarchical structure, with a pass/fail type of [status](/docs/reference/mod-resources/control#control-statuses) for each item.  The control and benchmark resources allow Steampipe to provide simplified, consistent mechanisms for defining, running, and returning output from these disparate frameworks.


Steampipe benchmarks automatically appear as [dashboards](/docs/dashboard/overview) when you run `steampipe dashboard` in the mod.  From the dashboard home, you can select any benchmark to run it and view it in an interactive HTML format.  You can even export the benchmark results as a CSV from the [panel view](/docs/dashboard/panel).

<img src="/images/reference_examples/benchmark_dashboard_view.png" />

<br />

You can also run controls and benchmarks in batch mode with the [steampipe check](/docs/reference/cli/check) command.  The `steampipe check` command provides options for selecting which controls to run, supports many output formats, and provides capabilities often required when using `steampipe` in your scripts, pipelines, and other automation scenarios.  

To run every benchmark in the mod:

```bash
steampipe check all
```

The console will show progress as its runs, and will print the results to the screen when it is complete:

<img src="/images/steampipe-check-output-sample-1.png" width="100%" />



You can find controls and benchmarks in the [Steampipe Mods](https://hub.steampipe.io/mods) section of the [Steampipe Hub](https://hub.steampipe.io), or by searching [Github](https://github.com/topics/steampipe-mod) directly.  

You can also [create your own controls and benchmarks](/docs/mods/writing-controls), and package them into a [mod](/docs/reference/mod-resources/overview).  



## More Examples

The [steampipe check](reference/cli/check) command executes one or more Steampipe benchmarks and controls.  You may specify one or more benchmarks or controls to run, or run steampipe check all to run all 

You can run all controls in the workspace:
```bash
steampipe check all 
```

Or only run a specific benchmark:
```bash
steampipe check benchmark.cis_v130
```

Or run only specific controls:
```bash
steampipe check control.cis_v130_1_4 control.cis_v130_2_1_1
```

Or only run controls with specific tags.  For example, to run the controls that have tags cis_level=1 and benchmark=cis:
```bash
steampipe check all --tag cis_level=1 --tag cis=true
```

Usually, steampipe mods use unqualified queries to "target" whichever connection is first in the [search path](/docs/managing/connections#setting-the-search-path), but you can specify a different path or prefix if you want:

```bash
steampipe check all --search-path-prefix aws_connection_2
```


You can filter the controls to run using a where clause on the steampipe_control reflection table.  
```bash
steampipe check all --where "severity in ('critical', 'high')"
```



You can preview which controls with the `--dry-run` flag:
```bash
steampipe check all --where "severity in ('critical', 'high')" --dry-run
```




