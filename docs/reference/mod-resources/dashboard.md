---
title: Dashboard
sidebar_label: dashboard
---

# dashboard

A dashboard is designed to be used by consumers of your mod to answer specific questions, such as "How many public AWS buckets do I have?" or "Show me the number of aging Zendesk tickets by owner".

Dashboards can be declared as named resources at the top-level of a mod, or be nested inside another `dashboard` or `container` by using a named `dashboard` with `base = <mod>.dashboard.<dashboard_resource_name>`.

For layout, a dashboard consists of 12 grid units, where items inside it will consume the full 12 grid units, unless they specify an explicit [width](#width).



## Example Usage

<img src="/images/reference_examples/dashboard_ex_1.png" width="100%" />

```hcl

dashboard "my_s3_dashboard" {

  title = "My S3 Dashboard"

  container {
    card {
      sql = <<-EOQ
        select
          count(*) as "Total Buckets"
        from
          aws_s3_bucket
      EOQ
      width = 2
    } 

    card {
      sql = <<-EOQ
        select
          count(*) as "Unencrypted Buckets"
        from
          aws_s3_bucket
        where
          server_side_encryption_configuration is null;
        EOQ
      type  = "alert" 
      width = 2
    } 
  }


  container {
    title = "Analysis"

    chart {
      title = "Buckets by Account"
      sql = <<-EOQ
        select
          a.title as "account",
          count(i.*) as "total"
        from
          aws_s3_bucket as i,
          aws_account as a
        where
          a.account_id = i.account_id
        group by
          account
        order by count(i.*) desc
      EOQ
      type  = "column"
      width = 6
    }


    chart {
      title = "Buckets by Region"
      sql = <<-EOQ
        select
          region,
          count(i.*) as total
        from
          aws_s3_bucket as i
        group by
          region
      EOQ
      type  = "column"
      width = 6
    }
  }

}
```



### Existing dashboard re-used with `base`
```hcl
dashboard "compose_other" {
  dashboard "reused_hello_world" {
    base = dashboard.hello_world
  }
}
```



## Argument Reference
| Argument | Type | Optional? | Description
|-|-|-|-
| `benchmark`    | Block	| Optional | [benchmark](/docs/reference/mod-resources/benchmark) blocks to embed benchmarks in the dashboard.
| `chart`        | Block	| Optional | [chart](/docs/reference/mod-resources/chart)  blocks to visualize SQL data in a number of ways e.g. `bar`, `column`, `line`, `pie`.
| `container` |  Block	| Optional |  [container](/docs/reference/mod-resources/container) blocks to lay out related components together in a dashboard. 
| `description` | String |  Optional| A description of the dashboard
| `documentation` | String (Markdown)| Optional | A markdown string containing a long form description, used as documentation for the dashboard on hub.steampipe.io. 
| `flow` | Block	| Optional |  [flow](/docs/reference/mod-resources/flow)  blocks to visualize flows using types such as `sankey`. 
| `hierarchy` | Block	| Optional |  [hierarchy](/docs/reference/mod-resources/hierarchy)  blocks to visualize hierarchical data using types such as `tree`. 
| `image`     | Block	| Optional | [image](/docs/reference/mod-resources/image)    blocks to embed images in dashboards. Supports static URLs, or can be derived from SQL.                                                                               
| `input`     | Block	| Optional | [input](/docs/reference/mod-resources/input) blocks to make dynamic dashboards based on user-provided input.     
| `table`      | Block	| Optional | [table](/docs/reference/mod-resources/table)   blocks to show tabular data in a dashboard.
| `tags` | Map | Optional | A map of key:value metadata for the dashboard, used to categorize, search, and filter.  The structure is up to the mod author. 
| `text`       | Block	| Optional | [text](/docs/reference/mod-resources/text) blocks to add GitHub-flavoured markdown to a dashboard.      
| `title` |  String	| Optional | Plain text [title](/docs/reference/mod-resources/dashboard#title) used to display in lists, page title etc. When viewing the dashboard in a browser, will be rendered as a `h1`.



## Common Properties

### title

Optional `title` for an item. Provided as plain text, but will be rendered as `text` with a `type` of `markdown` using h1 (for `dashboard`), h2 (for `container`) or h3 (for any leaf nodes e.g. `chart`). This `text` block and the item it is titling will be wrapped by a `container`.

E.g. a `container` that defines a title:

```hcl
container {
  title = "AWS S3 Metrics"
  width = 6
  
  # Other dashboard components
}
```

...is really just shorthand for:

```hcl
container {
  width = 6
  
  text {
    value = "## AWS S3 Metrics"
  }

  container {
    # Other dashboard components
  }
}
```

A `chart` that defines a title:

```hcl
chart {
  title = "AWS S3 Buckets by Region"
  width = 4
  
  # Other chart options
}
```

...is really just shorthand for:

```hcl
container {
  width = 4
 
  text {
    value = "### AWS S3 Buckets by Region"
  }

  chart {
    # Other chart options
  }
}
```

### width

The number of grid units that this item should consume from its parent.

A dashboard has 12 grid columns. By default, any dashboard component will consume the full width of its parent e.g. 12 grid columns, regardless of what `width` it specifies. As more viewport space becomes available in the browser, we provide more grid space up to and including the specified width.

| width | width on mobile (`<768px`) | width on tablet (`768-1023px`) | width on desktop (`>=1024px`) |
|-------|----------------------------|--------------------------------|-------------------------------|
| 0     | 0                          | 0                              | 0                             |
| 1     | 12                         | 3                              | 1                             |
| 2     | 12                         | 3                              | 2                             |
| 3     | 12                         | 3                              | 3                             |
| 4     | 12                         | 6                              | 4                             |
| 5     | 12                         | 6                              | 5                             |
| 6     | 12                         | 6                              | 6                             |
| 7     | 12                         | 7                              | 7                             |
| 8     | 12                         | 8                              | 8                             |
| 9     | 12                         | 9                              | 9                             |
| 10    | 12                         | 10                             | 10                            |
| 11    | 12                         | 11                             | 11                            |
| 12    | 12                         | 12                             | 12                            |

For example, both of these dashboard components will consume the full width of the report at all viewport sizes, as they either implicitly or explicitly define 12 grid units: 

```hcl
dashboard "width_example" {
  text {
    value = "## I am implictly 12 grid units"
  }

  card {
    sql = query.aws_s3_bucket_unencrypted_count.sql
    width = 12 # Explicitly 12 grid units
  }
}
```

In this example we have 3 cards, each specifying a width of 4. As specified in the table above, they will consume either 12, 6 or 4 grid units according to the viewport size:

```hcl
dashboard "width_example" {
  card {
    sql = query.aws_s3_bucket_public_count.sql
    width = 4 # 12 on mobile, 6 on tablet and 4 on desktop
  }
    
  card {
    sql = query.aws_s3_bucket_unencrypted_count.sql
    width = 4 # 12 on mobile, 6 on tablet and 4 on desktop
  }
    
  card {
    sql = query.aws_s3_bucket_unversioned_count.sql
    width = 4 # 12 on mobile, 6 on tablet and 4 on desktop
  }
}
```

In this example we have a card with a width of 2. As specified in the table above, it will consume either 12, 3 or 2 grid units according to the viewport size:

```hcl
dashboard "width_example" {
  card {
    sql = query.aws_s3_bucket_public_count.sql
    width = 2 # 12 on mobile, 3 on tablet and 2 on desktop
  }
}
```

As a dashboard component always consumes the grid units of its parent, consider the following example.

On mobiles each container will consume 12 grid units, with each card inside it also consuming 12 grid units of its parent (its respective parent container), meaning you effectively have 2 full-width cards, 1 below the other.

On tablets and desktop each container will consume 6 grid units, with each card inside it also consuming 6 grid units of its parent (its respective parent container), meaning you have 4 cards side-by-side on the page.

```hcl
dashboard "width_example" {
  container {
    width = 6

    card {
      sql = query.aws_s3_bucket_private_count.sql
      width = 6 # 12 on mobile, 6 on tablet and 6 on desktop
    }

    card {
      sql = query.aws_s3_bucket_public_count.sql
      width = 6 # 12 on mobile, 6 on tablet and 6 on desktop
    }
  }
  
  container {
    width = 6
    
    card {
      sql = query.aws_s3_bucket_encrypted_count.sql
      width = 6 # 12 on mobile, 6 on tablet and 6 on desktop
    }
        
    card {
      sql = query.aws_s3_bucket_unencrypted_count.sql
      width = 6 # 12 on mobile, 6 on tablet and 6 on desktop
    }
  }
}
```


### color

Many dashboard elements contain a `color` argument.  The color arguments support a standard set of functionality and options, and may be:  

- A [standard HTML color](https://www.w3schools.com/tags/ref_colornames.asp): `color = "green"`
- A control status value (`alert`, `info`, `ok`):  `color = "alert"`
- An RGB hexadecimal color value: `color = "#AABBCC"`
- An RGB color value of the format `color = "rgb(128, 0, 128)"`
- An [RGBA color value](https://www.w3schools.com/css/css3_colors.asp#:~:text=RGBA%20color%20values%20are%20an,and%201.0%20(fully%20opaque).) of the format `color = "rgb(128, 0, 128, 0.5)"`


### href - Using jq Templates
Some elements ( `card`, `column` in a `table`) allow you to specify a [jq](https://stedolan.github.io/jq/) template to dynamically generate a hyperlink from the data in the row. To use a jq template, enclose the jq in double curly braces (`{{ }}`).  

Steampipe will pass each row of data to jq in the same format that is returned by [steampipe query json mode output](reference/dot-commands/output), where the keys are the column names and the values are the data for that row. 

For example, this query:
```sql
select 
  instance_id, 
  region, 
  sg->>'GroupId' as security_group
from 
  aws_ec2_instance, 
  jsonb_array_elements(security_groups) as sg

```

will present rows to the jq template in this format:
```json
{
  "instance_id": "i-03d11d111b1407bbc",
  "region": "us-east-2",
  "security_group": "sg-01ee40ea54e0fa089"
 }
```

which you can then use in a jq template in the `href` argument:

```hcl
table {
  title = "Attached Security Groups"
  width = 4
  sql = <<-EOQ
    select 
      instance_id, 
      region, 
      sg->>'GroupId' as security_group
    from 
      aws_ec2_instance, 
      jsonb_array_elements(security_groups) as sg      
  EOQ

  column "security_group" {
    href = "${dashboard.aws_vpc_security_group_detail.url_path}?input.security_group_id={{.'security_group' | @uri}}"
  }
}
```

#### JQ Escaping & Interpolation 

At a high level, templates have string components and `{{ interpolated }}` components. 

For example:

```hcl
href = "/region/{{ .region }}"
```

becomes:

```hcl
href = "/region/us-east-2"
```

Interpolation is fairly straightforward when column names are simple and don't contain spaces. Complex field names require escaping, however.  

Take the following example:

```sql
select 
  instance_id as "Unique ID", 
  region, 
  sg->>'GroupId' as security_group
from 
  aws_ec2_instance, 
  jsonb_array_elements(security_groups) as sg
```

will present rows to the jq template in this format:

```json
{
  "Unique ID": "i-03d11d111b1407bbc",
  "region": "us-east-2",
  "security_group": "sg-01ee40ea54e0fa089"
 }
```

Note that the query returns a `Unique ID` field.  To refer to this in a jq interpolated field, you need to quote it (jq uses double quotes):  

```hcl
/detail/{{ ."Unique ID" }}
```

In HCL, this is easy with HEREDOC:

```hcl
href = <<EOT-
  /detail/{{ ."Unique ID" }}
EOT
```

Using an inline string, however, requires you to escape the double quotes (with a `\`):

```hcl
href = "/detail/{{ .\"Unique ID\" }}"
```

To simplify and improve readability, Steampipe automatically converts single quotes to double quotes when used in a jq template, thus the following is also valid:

```hcl
href = "/detail/{{ .'Unique ID' }}"
```

Under the hood, Steampipe builds a jq expression by combining the pieces:

1. Get the string from HCL: `/detail/{{ .'Unique ID' }}`
2. Convert the single quotes inside the interpolation: `/detail/{{ ."Unique ID" }}`
3. Build a jq expression: `[ "/detail/", (."Unique ID") ] | join("")` (we use an array with join to avoid errors for any type coercion across the expression)
4. Evaluate to be: `/detail/i-03d11d111b1407bbc`


##### Raw Strings v/s JSON Strings
For more complex examples, it's important to understand the difference between the raw strings (not interpolated) and JSON strings (inside the jq interpolation):

```
This is a raw string {{ "this is a JSON string" }}
```

Because jq treats all strings as JSON, any string inside your interpolation section is actually a JSON string, not a raw string. That means that escape characters etc are handled differently. For example, knowing that `\u1F916` is the character code for robot face (:robot_face:):

```
Raw string \u1F916 {{ 'and JSON string \u1F916' }}
```

Will give:

```
Raw string \u1F916 and JSON string 🤖
```

Notice that the raw string is printed exactly as given, while the jq string gets interpreted as a JSON string, converting the `\u1F916` into its unicode character. The same effect will happen for newlines (`\n`) and any other JSON escape sequences.

Of course, before we get lost in complex cases, if you want the actual robot face you can just use it directly at any point:

```
Raw string 🤖 {{ 'and JSON string 🤖' }}
```

Note that HCL also uses the backslash for escapes, so the example above in HCL form looks like this:

```
template = "Raw string \\u1F916 {{ 'and JSON string \\u1F916' }}"
```

##### Escaping Single Quotes
Since Steampipe converts single quotes in the interpolated section into double quotes, it's a little tricky to include a true single quote character in the interpolation. 

Consider this example:

```
Foo's thing {{ "and Bar's thing" }}
```

Steampipe will error, because it converts the single quote to a double quote before setting up the jq expression (making it invalid):

```
Foo's thing {{ "and Bar"s thing" }}
```

Instead, we can use the unicode character equivalent to prevent this conversion:

```
Foo's thing {{ "and Bar\u0027s thing" }}
```

Which will become:

```
Foo's thing and Bar's thing
```

##### Escaping Double Curly Braces

Another rare but interesting case is when a raw {{ is required. The {{ is significant since it starts an interpolated sequence. If you want to include a {{ as a raw string then you need to use this trick:

```
Inject a {{ '{{' }} into my {{ .region }}
```

Which gives:

```
Inject a {{ into my us-east-2
```