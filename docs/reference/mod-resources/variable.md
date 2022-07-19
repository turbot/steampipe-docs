---
title: variable
sidebar_label: variable
---


# variable

[Variables](mods/mod-variables#input-variables), are module-level objects that essentially act as parameters for the module.  When running `steampipe check`, you can pass values on the command line, from a `.spvars` file, or from environment variables, and you will be promoted for any variables that have no values.

You can reference variable values as `var.<NAME>`



## Example Usage
```hcl
variable "instance_state" {
  type    = string
  default = "stopped" 
}

query "instances_in_state" {
  sql = "select instance_id, instance_state from aws_ec2_instance where instance_state = $1;" 
  param "find_state" {
    default = var.instance_state
  } 
}
```

## Argument Reference
| Argument | Type | Optional? | Description
|-|-|-|-
| `default` | Any |Optional|  A default value.  If no value is passed, the user is not prompted and the default is used. 
| `description` | String| Optional|  A description of the variable.  This text is included when tne user is prompted for a variable's value.
| `type` | String | Optional | The [variable type](#variable-types).  This may be a simple type or a collection.


<!--
- `validation` - A block to define custom validation rules.
- `sensitive` - Allows you to suppress showing the variable's value in output.
-->
## Variable Types
Variables may be simple types:
- `string`
- `number`
- `bool`

Variables may also be collection types:
- `list(<TYPE>)`
- `set(<TYPE>)`
- `map(<TYPE>)`
- `object({<ATTR NAME> = <TYPE>, ... })`
- `tuple([<TYPE>, ...])`

The keyword `any` may be used to indicate that any type is acceptable 
