---
title: mod
sidebar_label: mod
---


# mod

> ***Powerpipe is now the recommended way to run dashboards and benchmarks!***
> Mods still work as normal in Steampipe for now, but they are deprecated and will be removed in a future release:
> - [Steampipe Unbundled →](https://steampipe.io/blog/steampipe-unbundled)
> - [Powerpipe for Steampipe users →](https://powerpipe.io/blog/migrating-from-steampipe)

Every mod must contain a `mod.sp` file with a single `mod` block.

The `mod` block contains metadata for the mod (including metadata used in the hub site and social media), as well as dependency data.  A mod author may edit the mod block directly, but Steampipe will **also** edit the file, adding, removing and modifying dependencies in the file when users add and remove mods via the [`steampipe mod` commands](/docs/reference/cli/mod).  For this reason, it is recommended that the `mod.sp` *only* contain a `mod` block; do not add other mod resources (`query`, `control`, `dashboard`, etc) to this file.

The block name (`aws_cis` in the example) is the mod name.  Mod names use lower_snake_case. They may contain lowercase chars, numbers or underscores, and must start with a letter.


## Example Usage

```hcl
mod "aws_cis" { 
  # hub metadata
  title          = "AWS CIS"
  description    = "AWS CIS Reporting and remediation"
  color          = "#FF9900"
  documentation  = file("./aws_cis_docs.md")
  icon           = "/images/plugins/turbot/aws.svg"
  categories         = ["Public Cloud", "AWS"]

  opengraph {
    title         = "Steampipe Mod for AWS CIS"
    description   = "CIS reports, queries, and actions for AWS. Open source CLI. No DB required."
  }

  require {
    steampipe {
      min_version = "0.20.0"
    }

    plugin "aws" {
      min_version = "0.86.0"
    }

    plugin "gcp" {
      min_version = "0.29.0"
    }

    mod "github.com/turbot/steampipe-mod-aws-compliance" {
      version = "^0.10"
    }
    mod "github.com/turbot/steampipe-mod-gcp-compliance" {
      version = "*"
    }
  }
}
```

## Argument Reference

| Name | Type | Required? | Description
|-|-|-|-
| `categories` | List(String) | Optional | A list of labels, used to categorize mods (such as on the Steampipe Hub).
| `color` | String |Optional |  A hexadecimal RGB value to use as the color scheme for the mod on hub.steampipe.io.  
| `description` |  String | Optional | A string containing a short description. 
| `documentation` | String (Markdown)| Optional | A markdown string containing a long form description, used as documentation for the mod on hub.steampipe.io. 
| `icon` |  String | Optional | The url of an icon to use for the mod on hub.steampipe.io.
| `opengraph` |  Block | Optional | Block of metadata for use in social media applications that support [Opengraph](#opengraph) metadata.
| `require` | Block | Optional | A block that specifies one or more [mod dependencies](#require).
| `tags` | Map | Optional | A map of key:value metadata for the mod, used to categorize, search, and filter.   
| `title` | String | Optional | The display title of the mod.


#### opengraph
The `opengraph` block is an optional block of metadata for use in social media applications that support [Opengraph](https://ogp.me/) metadata.

| Name | Type| Description
|-|-|-
| `description` | String | The opengraph description (`og:description`) of the mod, for use in social media applications.
| `title` | String | The opengraph display title (`og:title`) of the mod, for use in social media applications.

 

#### require
A mod may contain a `require` block to specify version dependencies for the Steampipe CLI, plugins, and mods.  While it is possible to edit this section manually, Steampipe will also modify it (including reordering and removing comments) when you run a `steampipe mod` command to install, update, or uninstall a mod.

A mod may specify a dependency on the Steampipe CLI.  Steampipe will evaluate the dependency when the mod is loaded, and will error if the constraint is not met, but it will not install or upgrade the CLI.  A `steampipe` constraint specifies a *minimum version*, and does not support semver syntax:
```hcl
require {
  steampipe {
    min_version = "0.20.0"
  }
}
```

A mod may specify a dependency on one or more plugins.  Steampipe will evaluate the dependency when the mod is loaded, and will error if the constraint is not met, but it will not install or upgrade the plugin. A `plugin` constraint specifies a *minimum version*, and does not support semver syntax:
```hcl
require {
  plugin "aws" {
    min_version = "0.24.0"
  }
}
```

A mod may specify dependencies on other mods.  While you can manually edit the `mod` dependencies in the `mod.sp`, they are more commonly managed by Steampipe when you install, update, or uninstall mods via the [steampipe mod commands](/docs/reference/cli/mod).  The `version` can be an exact version<!-- ,a tag name, a branch name, a local file --> or a [semver](https://semver.org/) string:

```hcl
require {
  mod "github.com/turbot/steampipe-mod-aws-compliance" {
    version = "^0.10"
  }
  mod "github.com/turbot/steampipe-mod-aws-insights" {
    version = "2.0"
  }
  mod "github.com/turbot/steampipe-mod-gcp-compliance" {
    version = "*"
  }
}
```

You may pass `args` to set variables defined in the dependency mods.  You can pass hard-coded values (literals), however it is more common to define variables in your mod that encapsulate the variables  and optionality of your dependencies:


```hcl
variable "common_dimensions" {
  type        = list(string)
  description = "A list of common dimensions to add to each control."
  default     = [ "account_id", "region" ]
}

variable "tag_dimensions" {
  type        = list(string)
  description = "A list of tags to add as dimensions to each control."
  default     = []
}

mod "aws_well_architected" {
  require {
    mod "github.com/turbot/steampipe-mod-aws-compliance" {
      version = "^0.63.0"
      args = {
        common_dimensions = var.common_dimensions,
        tag_dimensions    = var.tag_dimensions
      }
    }
  }
}

```
