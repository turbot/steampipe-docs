---
title: Writing Control Output Templates
sidebar_label: Writing Control Output Templates
---

# Writing Control Output Templates

Export formats for the [steampipe check](reference/cli/check) command are governed by a set of templates based on the golang [text/template](https://pkg.go.dev/text/template) package. For each output format there is a directory, in `~/.steampipe/check/templates/`, that minimally includes a file called `output.tmpl`. The name of the directory defines the name of an output format. The content of `output.tmpl` defines how to unpack and format an object, called `Data`, that's passed to the template.

## Example of a simple template

Here is a template that defines a new `summary` output format.

```
{{ define "output" }}

{{ range .Data.Root.Groups }}
Summary for {{ .Title }}
{{ end }}
total: {{ .Data.Root.Summary.Status.TotalCount }}
passed: {{ .Data.Root.Summary.Status.PassedCount }}
failed: {{ .Data.Root.Summary.Status.FailedCount }}
skipped: {{ .Data.Root.Summary.Status.Skip }}

{{ end }}
```

Once installed as `~/.steampipe/check/templates/summary/output.tmpl`, this command prints a summary.

```
cd ~/steampipe-mod-zoom-compliance
steampipe check --output=summary all
```

```
Summary for Zoom Compliance

total: 185
passed: 119
failed: 66
skipped: 0
```

This command puts the above output into the file `output.summary`.

```
steampipe check --export=output.summary all
```

This command produces an inferred filename like `all-20220119-111307.summary`.

```
steampipe check --export=summary all
```

This command produces the fully-qualified name `output.asff.json`.

```
steampipe check --export=output.asff.json all
```

## Data available to the template

Steampipe sends an object with a `Data` field of type [controlexecute.ExecutionTree](https://pkg.go.dev/github.com/turbot/steampipe@v0.11.2/control/controlexecute#ExecutionTree), the structure that represents control hierarchy. Templates typically use fields of structs defined in [ControlRun](https://github.com/turbot/steampipe/blob/v0.11.2/control/controlexecute/control_run.go), [ResultGroup](https://github.com/turbot/steampipe/blob/v0.11.2/control/controlexecute/result_group.go), [ResultRow](https://github.com/turbot/steampipe/blob/v0.11.2/control/controlexecute/result_row.go), and [StatusSummary](https://github.com/turbot/steampipe/blob/v0.11.2/control/controlexecute/status_summary.go).

