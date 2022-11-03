---
title: Steampipe Check
sidebar_label: steampipe check
---



# steampipe check
Execute one or more Steampipe benchmarks and controls.

You may specify one or more benchmarks or controls to run, or run `steampipe check all` to run all controls in the workspace.

## Usage
Run benchmarks/controls:
```bash
steampipe check [item,item,...] [flags]
```

List available benchmarks:
```bash
steampipe check list
```


## Flags:

<table>
  <tr> 
    <th> Argument </th> 
    <th> Description </th> 
  </tr>
  <tr> 
    <td nowrap="true"> <inlineCode>--dry-run</inlineCode> </td> 
    <td>  If specified, prints the controls that would be run by the command, but does not execute them.</td> 
  </tr>

  <tr> 
    <td nowrap="true"> <inlineCode>--export string</inlineCode>  </td> 
    <td> Export control output to a file.  You may export multiple <a href="#output-formats">output formats</a> for a single control run by entering multiple <inlineCode>--export</inlineCode> arguments.  If a file path is specified as an argument, its type will be inferred by the suffix.  Supported export formats are <inlineCode>asff</inlineCode>, <inlineCode>csv</inlineCode>, <inlineCode>html</inlineCode>, <inlineCode>json</inlineCode>, <inlineCode>md</inlineCode>,<inlineCode>snapshot</inlineCode>,<inlineCode>sps</inlineCode>
    </td> 

  </tr>


  <tr> 
    <td nowrap="true"> <inlineCode>--header string</inlineCode>  </td> 
    <td> Specify whether to include column headers in csv output/export (default <inlineCode>true</inlineCode>).</td> 
  </tr>

  <tr> 
    <td nowrap="true"> <inlineCode>--help</inlineCode> </td> 
    <td>  Help for <inlineCode>steampipe check.</inlineCode></td> 
  </tr>

  <tr> 
    <td nowrap="true"> <inlineCode>--input</inlineCode> </td> 
    <td>  Enable/Disable interactive prompts for missing variables.  To disable prompts and fail on missing variables, use <inlineCode>--input=false</inlineCode>.  This is useful when running from scripts. (default true)</td> 
  </tr>

  <tr>
    <td nowrap="true"> <inlineCode>--max-parallel integer</inlineCode>  </td> 
    <td> Set the maximum number of parallel executions. When running steampipe check, Steampipe will attempt to run up to this many controls in parallel.  See the <a href="reference/env-vars/steampipe_max_parallel">STEAMPIPE_MAX_PARALLEL</a> environment variable documentation for details. </td> 
  </tr>


  <tr> 
    <td nowrap="true"> <inlineCode>--mod-install </inlineCode> </td> 
    <td>  Specify whether to install mod dependencies before running the check (default true) </td> 
  </tr>
                       

  <tr> 
    <td nowrap="true"> <inlineCode>--output string</inlineCode> </td> 
    <td>  Select the console <a href="#output-formats">output format</a>.  Defaults to <inlineCode>text</inlineCode>. Possible values are <inlineCode>brief,csv,html,json,md,snapshot, sps,text,none</inlineCode> </td> 
  </tr>

  <tr> 
    <td nowrap="true"> <inlineCode>--progress</inlineCode>  </td> 
    <td> Enable or disable progress information. By default, progress information is shown - set <inlineCode>--progress=false</inlineCode> to hide the progress bar.  </td>
  </tr>

  <tr> 
    <td nowrap="true"> <inlineCode>--search-path strings</inlineCode>  </td> 
    <td>  Set a comma-separated list of connections to use as a custom <a href="managing/connections#setting-the-search-path">search path</a> for the control run. </td>
  </tr>
      <tr> 
    <td nowrap="true"> <inlineCode>--search-path-prefix strings</inlineCode>  </td> 
    <td>  Set a comma-separated list of connections to use as a prefix to the current <a href="managing/connections#setting-the-search-path">search path</a> for the control run. </td>
  </tr>
  <tr> 
    <td nowrap="true"> <inlineCode>--separator string</inlineCode>  </td> 
    <td>  A single character to use as a separator string for csv output (defaults to  ",")  </td>
  </tr>


  <tr> 
    <td nowrap="true"> <inlineCode>--share</inlineCode>  </td> 
    <td> Create snapshot in Steampipe Cloud with <inlineCode>anyone_with_link</inlineCode> visibility.  </td>
  </tr>

  <tr> 
    <td nowrap="true"> <inlineCode>--snapshot</inlineCode>  </td> 
    <td> Create snapshot in Steampipe Cloud with the default (<inlineCode>workspace</inlineCode>) visibility.  </td>
  </tr>
    
  <tr> 
    <td nowrap="true"> <inlineCode>--snapshot-location string</inlineCode>  </td> 
    <td> The location to write snapshots - either a local file path or a Steampipe Cloud workspace  </td>
  </tr>

  <tr> 
    <td nowrap="true"> <inlineCode>--snapshot-tag string=string  </inlineCode>  </td> 
    <td> Specify tags to set on the snapshot.  Multiple <inlineCode>--snapshot-tag </inlineCode> arguments may be passed.</td>
  </tr>

  <tr> 
    <td nowrap="true"> <inlineCode>--snapshot-title string=string  </inlineCode>  </td> 
    <td> The title to give a snapshot when uploading to Steampipe Cloud.  </td>
  </tr>

  <tr> 
    <td nowrap="true"> <inlineCode>--tag string=string</inlineCode>  </td> 
    <td>  Filter the list of controls to run by one or more tag values.  Multiple <inlineCode>--tag</inlineCode> arguments may be passed -- discrete keys are <inlineCode>and'ed</inlineCode> and duplicate keys are <inlineCode>or'ed</inlineCode>.  For example,  <inlineCode>steampipe check all --tag pci=true --tag service=ec2 --tag service=iam</inlineCode> will run only controls with a <inlineCode>service</inlineCode> tag equal to either <inlineCode>ec2</inlineCode> or <inlineCode>iam</inlineCode> that also are tagged with <inlineCode>pci=true</inlineCode>. 
    </td>
  </tr>
  <tr> 
    <td nowrap="true"> <inlineCode>--theme</inlineCode>  </td> 
    <td>  Select output theme (color scheme, etc).  Defaults to <inlineCode>dark</inlineCode>. Possible values are <inlineCode>light,dark, plain</inlineCode> </td>
  </tr>

  <tr> 
    <td nowrap="true"> <inlineCode>--timing  </inlineCode>  </td> 
    <td>Turn on the query timer. </td>
  </tr>

  <tr> 
    <td nowrap="true"> <inlineCode>--var string=string </inlineCode>  </td> 
    <td>  Specify the value of a mod variable.  Multiple <inlineCode>--var </inlineCode> arguments may be passed.
    </td>
  </tr>

  <tr> 
    <td nowrap="true"> <inlineCode>--var-file string</inlineCode>  </td> 
    <td>  Specify an .spvars file containing mod variable values. 
    </td>
  </tr>

  <tr> 
    <td nowrap="true"> <inlineCode>--where</inlineCode>  </td> 
    <td>  Filter the list of controls to run, using a sql <inlineCode>where</inlineCode> clause against the <inlineCode>steampipe_control</inlineCode> reflection table. 
    </td>
  </tr>
</table>


## Output Formats
| Format | Description 
|-|-
| `asff` | [Findings](https://docs.aws.amazon.com/securityhub/latest/userguide/securityhub-findings.html) in [asff](https://docs.aws.amazon.com/securityhub/latest/userguide/securityhub-findings-format-syntax.html) json format. Only used with AWS controls.
| `brief` | Text based output that shows only actionable items (errors and alarms) as well as a summary.
| `csv` | Comma-separated output with full control details.
| `html` | Single-page HTML output with full control details and group summaries.
| `json` | Hierarchical json output with full control details and group summaries.
| `md` | Single-page markdown output with full control details and group summaries.
| `none` | Don't send any output to stdout.
| `nunit3` | Results in [nunit3](https://docs.nunit.org/articles/nunit/technical-notes/usage/Test-Result-XML-Format.html) xml format.
| `snapshot` | Steampipe snapshot json (alias for `sps`)
| `sps` | Steampipe snapshot json.
| `text` | Full text based output with details and summary.  This is the default console output format.

## Examples

Run all  controls:
```bash
steampipe check all 
```

List the benchmarks available to run in the current mod context:

```bash
steampipe check list
```

Run the cis_v130 benchmark:
```bash
steampipe check benchmark.cis_v130
```

Run a benchmark and save a [snapshot](/docs/snapshots/batch-snapshots):
```bash
steampipe check --snapshot benchmark.cis_v130
```

Run a benchmark and share a [snapshot](/docs/snapshots/batch-snapshots):
```bash
steampipe check --share benchmark.cis_v130
```

Only show "failed"  items (alarm, error)
```bash
steampipe check all --output=brief
```

Run all controls and pass variable values on the command line:
```bash
steampipe check all --var='mandatory_tags=["Owner","Application","Environment"]' --var='sensitive_tags=["password","key"]'
```

Run all controls and pass a .spvars file that contains variable values to use
```bash
steampipe check all --var-file='tags.spvars'
```


Run the controls that have tags cis_level=1 and cis=true:
```bash
steampipe check all --tag cis_level=1 --tag cis=true
```

Preview the controls that would run in the cis_v130 benchmark with the cis_level=1 tag filter:
```bash
steampipe check benchmark.cis_v130 --tag cis_level=1 --dry-run
```

Run controls with the a benchmark=pci tag that are either high or critical severity:
```bash
steampipe check all --where "severity in ('critical', 'high') and tags ->> 'pci' = 'true'"
```

Run the cis_v130 benchmark with light mode output:
```bash
steampipe check benchmark.cis_v130 --theme=light
```

Run the cis_v130_1_4 and cis_v130_2_1_1 controls:
```bash
steampipe check control.cis_v130_1_4 control.cis_v130_2_1_1
```

Run the foundational_security benchmark, but suppress items:
```bash
steampipe check benchmark.foundational_security --where "tags ->> 'foundational_security_item_id' !=  all(ARRAY['cloudformation_1','s3_11'])"
```

Use plain text and no progress (typical for CI or batch jobs)
```bash
steampipe check all --theme=plain --progress=false
```

Export to html (with default file name)
```bash
steampipe check all --export=html
```

Export to csv with default file name and json as `output.json`
```bash
steampipe check all --export=csv --export=output.json
```

Export to markdown and json with default file names, asff as `output.asff.json`, nunit3 as `output.nunit3.xml`

```bash
steampipe check all --export=md --export=json --export=output.asff.json --export=output.nunit3.xml
```

Send json output to stdout and pipe  to `jq `
```bash
steampipe check all --output=json | jq
```
