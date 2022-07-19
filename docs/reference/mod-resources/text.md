---
title: Text
sidebar_label: text
---

# text

Display either rendered `markdown` ([GitHub Flavored Markdown](https://github.github.com/gfm/)) or `raw` text with no interpretation of markup.

Text blocks can be declared as named resources at the top level of a mod, or be declared as anonymous blocks inside a `dashboard` or `container`, or be re-used inside a `dashboard` or `container` by using a `text` with `base = <mod>.text.<text_resource_name>`.



## Example Usage

<img src="/images/reference_examples/text_ex_1.png" width="200pt" />

```hcl

text {
  width = 2
  value = <<-EOM
    # I am some markdown text.

    *I* respect ***markdown***.
  
  EOM
}
```


## Argument Reference
| Argument | Type | Optional? | Description
|-|-|-|-
| `base` |   Text Reference		| Optional | A reference to a named `text` resource that this `text` should source its definition from. `title` and `width` can be overridden after sourcing via `base`.
| `title` |  String	| Optional | A plain text [title](/docs/reference/mod-resources/dashboard#title) to display for this text.
| `type` |  String	| Optional | `markdown` (default) or `raw`.
| `value` |  String	| Optional | The `markdown` or `html` string to use. Can also be sourced using the HCL `file` function.
| `width` |  Number	| Optional | The [width](/docs/reference/mod-resources/dashboard#width) as a number of grid units that this item should consume from its parent.



###  More Examples

 ### Plain Text

<img src="/images/reference_examples/text_raw.png" width="200pt" />

```hcl
text {
  width = 2
  type  = "raw"
  value = "<h2>I am a HTML title, but I'll be displayed as-is</h2>"
}
```