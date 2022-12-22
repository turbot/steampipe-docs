---
title: Category
sidebar_label: category
---

# category




## Example Usage

```hcl
category "ec2_instance" {
  title = "EC2 Instance"
  href  = "/aws_insights.dashboard.ec2_instance_detail?input.instance_arn={{.properties.'ARN' | @uri}}"
  icon  = "memory"
  color = "orange"
}
```

    


## Argument Reference
| Argument | Type | Optional? | Description
|-|-|-|-
| `color`  | string | The matching color from the default theme for the data series index. | A [valid color value](reference/mod-resources/dashboard#color).  This may be a named color, RGB or RGBA string, or a control status color. |  The color to display for this category.           |




## More Examples


### Category with Material Symbol Icon

### Category with Heroicons Icon

### Category with Text Icon

### Category with `fold` properties

