---
title: Writing Dashboards
sidebar_label: Writing Dashboards
---

# Steampipe Dashboards

> ***Powerpipe is now the recommended way to run dashboards and benchmarks!***
> Mods still work as normal in Steampipe for now, but they are deprecated and will be removed in a future release:
> - [Steampipe Unbundled →](https://steampipe.io/blog/steampipe-unbundled)
> - [Powerpipe for Steampipe users →](https://powerpipe.io/blog/migrating-from-steampipe)


A Steampipe [dashboard](reference/mod-resources/dashboard) uses a combination of HCL and SQL to visualize data in a variety of ways. This *dashboards as code* approach makes it easy to create and combine charts and tables, style them, and make them interactive. Use your favorite text editor, receive immediate feedback as you type, and manage your dashboards on GitHub with all your other code artifacts.

## Tutorial

Let's walk through building a simple dashboard that will introduce the key concepts as we go along. For this dashboard we'll be using the Steampipe [RSS plugin](https://hub.steampipe.io/plugins/turbot/rss).  If you have not already, please download and install the latest RSS plugin:
```bash
steampipe plugin install rss
```

### Create a mod

First, create a new directory and initialize a new mod.

```bash
mkdir dashboards_introduction
cd dashboards_introduction
steampipe mod init
```

Then edit the `mod.sp` for our mod:

```hcl
mod "dashboards_introduction" {
  title = "Dashboards Introduction"
}
```

### Start the dashboard server

If you have not done so already, `cd` into the `mod`  directory you created in the previous step and run the following command:

```bash
steampipe dashboard
```

This will start a dashboard server for your mod and will open up a web browser in which to browse and view your dashboards.

### Create a dashboard

Create a file `dashboard.sp` and add the following:

```hcl
dashboard "dashboard_tutorial" {
  title = "Dashboard Tutorial"
}
```

You'll now see your dashboard appear in the list shown in the browser.
### Add some text

Click this dashboard to run it. As you can see, the dashboard is currently empty.  Let's add some overview [text](reference/mod-resources/text):

```hcl
dashboard "dashboard_tutorial" {
  title = "Dashboard Tutorial"
  
  text {
    value = "This will guide you through the key concepts of building your own dashboards."
  }
}
```

Notice that the `text` block isn't named. Resource blocks nested inside a dashboard are anonymous, with the exception of [input](reference/mod-resources/input).  This makes it very easy to add things to your dashboard without having to worry about unique names.
### Show some totals

Adding text to a dashboard isn't that exciting, so let's work with some real data. First, add a query to your mod:

```hcl
query "rss_steampipe_io_blog_post_totals" {
  sql = <<-EOQ
    select
      count(*) as "Total Blog Posts"
    from
      rss_item
    where
      feed_link = 'https://steampipe.io/blog/feed.xml'
  EOQ
}
```

Then add a [card](reference/mod-resources/card) to the dashboard:

```hcl
dashboard "dashboard_tutorial" {
  title = "Dashboard Tutorial"

  text {
    value = "This will guide you through the key concepts of building your own dashboards."
  }

  card {
    sql = query.rss_steampipe_io_blog_post_totals.sql
  }
}
```

Notice that we didn't need to tell Steampipe where to get the card `label` and `value` from. The above query uses a *simple* data format. It returns one row with one column. The column name is the `label`, its value is the card `value`.

You can also define a *formal* data structure which tells Steampipe where to get things by passing named columns.

```hcl
query "rss_steampipe_io_blog_post_totals" {
  sql = <<-EOQ
    select
      "Total Blog Posts" as label,
      count(*) as value
    from
      rss_item
    where
      feed_link = 'https://steampipe.io/blog/feed.xml'
  EOQ
}
```

### Chart some data

Now that we've seen how to show simple card values, let's chart some data. We'll need a query for this:

```hcl
query "rss_steampipe_io_blog_posts_by_month" {
  sql = <<-EOQ
    select
      to_char(date_trunc('month', published), 'YYYY-MM') as "Month",
      count(*) as "Total Blog Posts"
    from
      rss_item
    where
      feed_link = 'https://steampipe.io/blog/feed.xml'
    group by
      "Month";
  EOQ
}
```

This query contains the X-axis in the first column (`Month` in this example) and the series data in the second column (the number of blog posts per month).

Now let's [chart](reference/mod-resources/chart) the data from our query:

```hcl
dashboard "dashboard_tutorial" {
  title = "Dashboard Tutorial"

  text {
    value = "This will guide you through the key concepts of building your own dashboards."
  }

  card {
    sql = query.rss_steampipe_io_blog_post_totals.sql
  }

  chart {
    title = "Steampipe.io Blog Posts by Month"
    sql = query.rss_steampipe_io_blog_posts_by_month.sql
  }
}
```

Notice that we didn't need to configure anything. Steampipe infers the series from the shape of the data, and defaults to showing a `column` chart.

What if we wanted a different chart type? How about a `line` chart?

```hcl
chart {
  title = "Steampipe.io Blog Posts by Month"
  sql   = query.rss_steampipe_io_blog_posts_by_month.sql
  type  = "line"
}
```

### Re-use a chart
Defining charts inline is simple, but you'll likely have some charts you'll want to re-use. Let's try that. First add a named chart at the top level.


```hcl
chart "steampipe_io_blog_posts_by_month_line_chart" {
  title = "Steampipe.io Blog Posts by Month"
  sql   = query.rss_steampipe_io_blog_posts_by_month.sql
  type  = "line"
}
```

Note that this `chart` block is named. Resource blocks *nested in a dashboard* are anonymous, but when *defined outside of a dashboard* they **must have a name** that is unique within the mod so that you can refer to them.  Note also that the chart that you just created cannot be viewed by itself. It must be used in a dashboard.  To use the chart we just created, we'll refer to it with `base` keyword:

```hcl
chart {
  base = chart.steampipe_io_blog_posts_by_month_line_chart
}
```

This pattern works for any dashboard component (except for [container](reference/mod-resources/container) which can only be anonymous within a dashboard). Define a component at the top level with a name, then re-use it in a dashboard. What's powerful about this approach is we can override aspects of the chart.

```hcl
chart {
  base = chart.steampipe_io_blog_posts_by_month_line_chart
  type = "pie"
}
```

### Layout control

We have control over the [width](reference/mod-resources/dashboard#width) of an item too. Let's put 2 versions of the above chart side-by-side on the page:

```hcl
chart "steampipe_io_blog_posts_by_month_line_chart" {
  title = "Steampipe.io Blog Posts by Month"
  sql   = query.rss_steampipe_io_blog_posts_by_month.sql
  type  = "line"
}

dashboard "dashboard_tutorial" {
  title = "Dashboard Tutorial"

  text {
    value = "This will guide you through the key concepts of building your own dashboards."
  }

  card {
    sql = query.rss_steampipe_io_blog_post_totals.sql
  }

  chart {
    base  = chart.steampipe_io_blog_posts_by_month_line_chart
    width = 6
  }
  
  chart {
    base  = chart.steampipe_io_blog_posts_by_month_line_chart
    type  = "bar"
    width = 6
  }
}
```

We've utilized the built-in grid system. A dashboard has 12 grid columns and by default a component will always consume the full width of its parent.

If you make your browser narrower you'll notice that the two charts go full-width.

We start at the smallest screen size with components being full-width. Between 768-1023px any component with a width of <6 becomes 6 grid units. At >=1024px we respect the width specified. For a more detailed explanation see [width](reference/mod-resources/dashboard#width).

### Nesting components

So far, everything we've defined in the dashboard is a direct child of the dashboard resource. We can also group related items and nest them inside a [container](reference/mod-resources/container). 

```hcl
container {
  width = 6

  text {
    value = "### Steampipe.io Blog Posts by Month"
  }

  chart {
      sql   = query.rss_steampipe_io_blog_posts_by_month.sql
  }
}

container {
  width = 6

  text {
    value = "### Steampipe.io Blog Posts by Month"
  }

  chart {
    sql   = query.rss_steampipe_io_blog_posts_by_month.sql
    type  = "bar"
  }
}
```

By wrapping the related components in a `container` we are able to show side-by-side sections, while keeping the title+chart together as the page resizes.

### Wrap-up

We've only scratched the surface of what's possible here. For the full story on dashboard components and their options please check out the [reference docs](reference/mod-resources/overview#dashboards).
