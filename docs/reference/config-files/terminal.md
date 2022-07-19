---
title: Terminal options
sidebar_label: terminal
---


### Terminal Options
**Terminal** options can be used to change query output formats and other terminal options.  Typically, these can also be set via [meta-commands](/docs/reference/dot-commands/overview) or [command line arguments](/docs/reference/cli/overview) of the same name.


#### Supported options  
| Argument | Default | Values | Description 
|-|-|-|-
| `header` |  `true` |  `true`, `false` | Enable or disable column headers.
| `multi` | `false` |  `true`, `false` | Enable or disable multiline mode.
| `output` | `table` | `json`, `csv`, `table`, `line` | Set output format.
| `separator` | `,` | Any single character | Set csv output separator.
| `timing` | `false` |  `true`, `false` | Enable or disable query execution timing.
| `search_path` | The active database search path | Comma separated string | Set an exact [search path](managing/connections#setting-the-search-path). Note that setting the search path in the terminal options sets it for the session when running `steampipe`; this setting will not be in effect when connecting to Steampipe from 3rd party tools.
| `search_path_prefix`| Empty | Comma separated string |  Move connections to the front of the [search path](managing/connections#setting-the-search-path).
| `watch` |  `true` |  `true`, `false` |  Watch SQL files in the current workspace for changes (works only in interactive mode).

#### Example: Terminal Options

```hcl
options "terminal" {
  header             = true                # true, false
  multi              = false               # true, false
  output             = "table"             # json, csv, table, line
  separator          = ","                 # any single character
  timing             = false               # true, false
  search_path        = "aws,aws2,gcp,gcp2" # comma-separated string; an exact search_path
  search_path_prefix = "aws2,gcp2"         # comma-separated string; a search_path_prefix to prepend to the search_path
  watch              =  true               # true, false

}
```