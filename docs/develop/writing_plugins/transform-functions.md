---
title: Transform Functions
sidebar_label: Transform functions
---

# Transform Functions

Transform functions are used to extract and/or reformat data returned by a hydrate function into the desired type/format for a column.  You can call your own transform function with `From`, but you probably don't need to write one -- The SDK provides many that cover the most common cases.  You can chain transforms together, but the transform chain must be started with a `From` function:

| Name | Description
|-|-
| `FromConstant` | Return a constant value (specified by 'param').
| `FromField` | Generate a value by retrieving a field from the source item.
| `FromValue` | Generate a value by returning the raw hydrate item.
| `FromCamel` | Generate a value by converting the given field name to camel case and retrieving from the source item.
| `FromGo` | Generate a value by converting the given field name to camel case and retrieving from the source item.
| `From` | Generate a value by calling a 'transformFunc'.
| `FromJSONTag` | Generate a value by finding a struct property with the json tag matching the column name.
| `FromTag` | Generate a value by finding a struct property with the tag 'tagName' matching the column name.
| `FromP` | Generate a value by calling 'transformFunc' passing param.


Additional functions can be chained after a `From` function to transform the data:

| Name | Description
|-|-
| `Transform` | Apply an arbitrary transform to the data (specified by 'transformFunc').
| `TransformP` | Apply an arbitrary transform to the data, passing a parameter.
| `NullIfEqual` | If the input value equals the transform param, return nil.
| `NullIfZero` | If the input value equals the zero value of its type, return nil.