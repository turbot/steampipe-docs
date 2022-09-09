---
title: Chart
sidebar_label: chart
---

# chart

A chart enables visualisation of queries in a variety of charting types such as `bar`, `column`, `donut`, `line` or `pie`.  

The chart types share key properties such as shape of the data and  configuration. So, for example, if you change the type of chart from `bar` to `line` it just works. 

Chart blocks can be declared as named resources at the top level of a mod, or be declared as anonymous blocks inside a `dashboard` or `container`, or be re-used inside a `dashboard` or `container` by using a `chart` with `base = <mod>.chart.<chart_resource_name>`.



## Example Usage

<img src="/images/reference_examples/bar_chart_ex_1.png" width="100%" />


```hcl

chart {
  type  = "bar"
  title = "AWS S3 Buckets by Region"

  sql = <<-EOQ
    select
        region as Region,
        count(*) as Total
    from
        aws_s3_bucket
    group by
        region
    order by
        Total desc
  EOQ
}

```



## Argument Reference
| Argument | Type | Optional? | Description
|-|-|-|-
| `args` | Map | Optional| A map of arguments to pass to the query. 
| `axes` |  Block	| Optional | See [axes](#axes).
| `base` |  Chart Reference		| Optional | A reference to a named `chart` resource that this `chart` should source its definition from. `title` and `width` can be overridden after sourcing via `base`.
| `grouping` |  Block	| Optional | The layout for multi-series charts. Can be `stack` (the default) or `compare`.
| `legend` |  Block	| Optional | See [legend](#legend).
| `param` | Block | Optional| A [param](reference/mod-resources/query#param) block that defines the parameters that can be passed in to the query.  `param` blocks may only be specified for charts that specify the `sql` argument. 
| `query` | Query Reference | Optional | A reference to a [query](reference/mod-resources/query) resource that defines the query to run.  A chart may either specify the `query` argument or the `sql` argument, but not both.
| `series` |  Block	| Optional | A named block matching the name of the series you wish to configure. See [series](#series).
| `sql` |  String	| Optional |  An SQL string to provide data for the chart.  A chart may either specify the `query` argument or the `sql` argument, but not both.
| `title` |  String	| Optional | A plain text [title](/docs/reference/mod-resources/dashboard#title) to display for this chart.
| `transform` |  String	| Optional | See [transform](#transform). 
| `type` |  String	| Optional | The type of the chart. Can be `bar`, `column`, `donut`, `line` or `pie`. You can also use `table` to review the raw data.
| `width` |  Number	| Optional | The [width](/docs/reference/mod-resources/dashboard#width) as a number of grid units that this item should consume from its parent.


## Data Format

Data can be provided in 2 formats. Either in classic "Excel-like" column format, where each series data is contained in its own column:

| X-Axis  | Y-Axis Series 1  | Y-Axis Series 2  | ... | Y-Axis Series N  |
| ------- | ---------------- | ---------------- | --- | ---------------- |
| Label 1 | Value 1 Series 1 | Value 1 Series 2 | ... | Value 1 Series N |
| Label 2 | Value 2 Series 1 | Value 2 Series 2 | ... | Value 2 Series N |
| ...     | ...              | ...              | ... | ...              |
| Label N | Value N Series 1 | Value 1 Series 2 | ... | Value N Series N |

Alternatively, data can be provided with the series data in rows.

| region    | series_name | count |
|-----------|-------------|-------|
| us-east-1 | foo         | 4     |
| us-east-2 | bar         | 1     |
| us-west-1 | foo         | 1     |
| us-west-1 | bar         | 2     |

The chart will automatically crosstab the data into the below format. See [transform](#transform):

| region    | foo  | bar  |
|-----------|------|------|
| us-east-1 | 4    | NULL |
| us-east-2 | NULL | 1    |
| us-west-1 | 1    | 2    |


## Common Chart Properties

### axes

Applicable to `bar`, `column`, `line` and `scatter`.

#### `x`

| Property | Type                         | Default | Values | Description |
| -------- | ---------------------------- | ------- | ------ | ----------- |
| `title`  | See [axis title](#axis-title) |         |        |             |
| `labels` | See [labels](#labels)        |         |        |             |

#### `y`

| Property | Type                         | Default                                                                                                                                                                   | Values            | Description |
| -------- | ---------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------- | ----------- |
| `title`  | See [axis title](#axis-title) |                                                                                                                                                                           |                   |             |
| `labels` | See [labels](#labels)        |                                                                                                                                                                           |                   |             |
| `min`    | number                       | Determined by the range of values. For positive ranges, this will be `0`. For negative ranges, this will be scaled to the next appropriate value below the range min.     | Any valid number. |             |
| `max`    | number                       | Determined by the range of values. For positive ranges, this will be scaled to the next appropriate value above the range max `0`. For negative ranges, this will be `0`. | Any valid number. |             |

### axis title

| Property  | Type   | Default  | Values                                | Description                                                                                                                              |
| --------- | ------ | -------- | ------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------- |
| `display` | string | `none`   | `always` or `none` (default).         | `always` will ensure the axis title is `always` shown, or `none` will never show it.                                                     |
| `align`   | string | `center` | `start`, `center` (default) or `end`. | By default the chart will align the axis title in the `center` of the chart, but this can be overridden to `start` or `end` if required. |
| `value`   | string |          | Max 50 characters.                    |                                                                                                                                          |

### transform

What data transform to apply.

Defaults to `auto`, which will automatically crosstab row series data into column series data if it detects a 3-column dataset, with the first 2 columns non-numeric and the 3rd column numeric.

Alternative values are `none`, which applies no data transforms, or `crosstab` which explicitly applies the crosstab transform that `auto` may apply.

### labels

| Property  | Type   | Default | Values                                | Description                                                                                                                                                                                                        |
| --------- | ------ | ------- | ------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `display` | string | `auto`  | `auto` (default), `always` or `none`. | `auto` will display as many labels as possible for the size of the chart. `always` will always show all labels, but will truncate them with an ellipsis as necessary. `none` will never show labels for this axis. |
| `format`  | TBD    |         |                                       |                                                                                                                                                                                                                    |

### legend

| Property   | Type   | Default | Values                              | Description                                                                                                                                        |
| ---------- | ------ | ------- | ----------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------- |
| `display`  | string | `auto`  | `auto`, `always` or `none`.         | `auto` will display a legend if there are multiple data series. `show` will ensure a legend is `always` shown, or `hide` will never show a legend. |
| `position` | string | `top`   | `top`, `right`, `bottom` or `left`. | By default the chart will display a legend at the `top` of the chart, but this can be overridden to `right`, `bottom` or `left` if required.       |

### point

| Property | Type   | Default                                                              | Values                                                                                                                                  | Description |
| -------- | ------ | -------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------- | ----------- |
| `color`  | string | The matching color from the default theme for the data series index. |A [valid color value](reference/mod-resources/dashboard#color).  This may be a named color, RGB or RGBA string, or a control status color. |             |

### series

| Property | Type   | Default                                                              | Values                                                                                                                                  | Description |
| -------- | ------ | -------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------- | ----------- |
| `title`  | string | The column name that the series data resides in.                     | Max 50 characters                                                                                                                       |             |
| `color`  | string | The matching color from the default theme for the data series index. |A [valid color value](reference/mod-resources/dashboard#color).  This may be a named color, RGB or RGBA string, or a control status color. |             |



## More Examples


#### Multi-series bar chart with custom properties 


<img src="/images/reference_examples/multi-bar_ex_1.png" width="100%" />

```hcl
chart {
  type  = "bar"
  title = "Bucket Versioning by Region"
  width = 4 

  legend {
    display  = "auto"
    position = "top"
  }

  series versioned {
    title = "Versioned Buckets"
    color = "green"
  }
  series nonversioned {
    title = "Non-Versioned Buckets"
    color = "red"
  }
  axes {
    x {
      title {
        value  = "Regions"
      }
      labels {
        display = "auto"
      }
    }
    y {
      title {
        value  = "Totals"
      }
      labels {
        display = "show"
      }
      min    = 0
      max    = 100
    }
  }
  sql = <<-EOQ
    with versioned_buckets_by_region as (
      select
        region,
        count(*) as versioned
      from
        aws_s3_bucket
      where
        versioning_enabled
      group by
        region
    ),
    nonversioned_buckets_by_region as (
      select
        region,
        count(*) as nonversioned
      from
        aws_s3_bucket
      where
        not versioning_enabled
      group by
        region
    )
    select
      v.region,
      v.versioned,
      n.nonversioned
    from
      versioned_buckets_by_region as v
      full join nonversioned_buckets_by_region n on v.region = n.region;
  EOQ
}
```

### Bar Chart

<img src="/images/reference_examples/bar_chart_ex_1.png" width="100%" />

```hcl

chart {
  type  = "bar"
  title = "AWS S3 Buckets by Region"

  sql = <<-EOQ
    select
        region as Region,
        count(*) as Total
    from
        aws_s3_bucket
    group by
        region
    order by
        Total desc
  EOQ
}

```

### Column Chart
<img src="/images/reference_examples/column_chart_ex_1.png" width="100%" />

```hcl
chart {
  type = "column"
  title = "AWS S3 Buckets by Region"

  sql = <<-EOQ
    select
        region as Region,
        count(*) as Total
    from
        aws_s3_bucket
    group by
        region
    order by
        Total desc
  EOQ
}
```

### Donut Chart

<img src="/images/reference_examples/donut_chart_ex_1.png" width="100%" />

```hcl
chart {
  type = "donut"
  title = "AWS S3 Buckets by Region"

  sql = <<-EOQ
    select
        region as Region,
        count(*) as Total
    from
        aws_s3_bucket
    group by
        region
    order by
        Total desc
  EOQ
}
```
### Multiple donut charts 

<img src="/images/reference_examples/donut_chart_ex_2.png" width="100%" />

<br/>

```hcl
chart "db_base" {
  series "mentions" {
    point "Citus" {
      color = "green"
    }
    point "MongoDB" {
      color = "gray"
    }
    point "MySQL|MariaDB" {
      color = "orange"
    }
    point "Oracle" {
      color = "red"
    }
    point "Postgres" {
      color = "lightblue"
    }
    point "SQL Server" {
      color = "blue"
    }
    point "Supabase" {
      color = "yellow"
    }
    point "Redis" {
       color = "#065E5B"
    }
    point "SQLite" {
      color = "purple"
    }

  }
```

### Line Chart
<img src="/images/reference_examples/line_chart_ex_1.png" width="100%" />

```hcl
chart {
  type = "line"
  title = "AWS S3 Buckets by Region"

  sql = <<-EOQ
    select
        region as Region,
        count(*) as Total
    from
        aws_s3_bucket
    group by
        region
    order by
        Total desc
  EOQ
}
```

### Pie Chart
<img src="/images/reference_examples/pie_chart_ex_1.png" width="100%" />

```hcl
chart {
  type = "pie"
  title = "AWS S3 Buckets by Region"

  sql = <<-EOQ
    select
        region as Region,
        count(*) as Total
    from
        aws_s3_bucket
    group by
        region
    order by
        Total desc
  EOQ
}
```


### Stack Chart
<img src="/images/reference_examples/column_chart_ex_stack.png" width="100%" />

```hcl
chart {
  type  = "column"
  title = "EBS total Storage by Region"
  width = 4 

  sql = <<-EOQ
    select
      region,
      state, 
      sum(size) 
    from 
      aws_ebs_volume
    group by
      region,
      state
  EOQ
}
```


### Comparison Chart
<img src="/images/reference_examples/column_chart_ex_compare.png" width="100%" />

```hcl
chart {
  type  = "column"
  title = "EBS total Storage by Region"
  grouping = "compare"
  width = 4 

  sql = <<-EOQ
    select
      region,
      state, 
      sum(size) 
    from 
      aws_ebs_volume
    group by
      region,
      state
  EOQ
}
```