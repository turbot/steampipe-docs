---
title: locals
sidebar_label: locals
---



# locals
The `locals` block defines and sets one or more [local variables](mods/mod-variables#local-variables), using standard HCL assignment syntax.  The locals are scoped to the mod, and a mod may contain multiple `locals` blocks.  Locals may reference other values in the mod, including other local values.

You can reference local values as `local.<NAME>`



## Example Usage

```hcl
locals {
  cis_version = "v1.4.0"
  plugin_name = "aws"
}

locals {
  cis_v140_common_tags = {
    cis         = "true"
    cis_version = local.cis_version
    plugin      = local.plugin_name
  }
}

benchmark "cis_v140" {
  title         = "CIS v1.4.0"
  description   = "The CIS Amazon Web Services Foundations Benchmark provides prescriptive guidance for configuring security options for a subset of Amazon Web Services with an emphasis on foundational, testable, and architecture agnostic settings."
  documentation = file("./cis_v140/docs/cis_overview.md")
  children = [
    benchmark.cis_v140_1,
    benchmark.cis_v140_2,
    benchmark.cis_v140_3,
    benchmark.cis_v140_4,
    benchmark.cis_v140_5
  ]
  tags = local.cis_v140_common_tags
}
```

