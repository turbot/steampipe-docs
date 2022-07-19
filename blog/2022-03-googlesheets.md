---
id: sql-for-googlesheets
title: "SQL for Google Sheets"
category: Featured Plugin
description: "Use the Google Sheets plugin to join spreadsheets with other tables, enforce named ranges, find secrets, and pivot with SQL."
summary: "Use the Google Sheets plugin to join spreadsheets with other tables, enforce named ranges, find secrets, and pivot with SQL."
author:
  name: Jon Udell
twitter: "@judell"
publishedAt: "2022-03-30T14:00:00"
durationMins: 8
image: "/images/blog/2022-03-googlesheets/named-ranges-2.png"
slug: sql-for-googlesheets
schema: "2021-01-08"
---

The [Google Sheets plugin](https://hub.steampipe.io/plugins/turbot/googlesheets) provides two kinds of tables. First, there are data tables that map the data in each spreadsheet tab to a database table. In our [sample sheet](https://docs.google.com/spreadsheets/d/11iXfj-RHpFsil7_hNK-oQjCqmBLlDfCvju2AOF-ieb4) the tabs are *"Dashboard"*, *"Students"*, *"Books"*, *"Marks"*, and *"Employees"*. 

```sql
select * from "Marks"
```

These queries deliver results that correspond to what you see in the *Marks* tab of the sample sheet. 

```
 student | subject | score
---------+---------+-------
 Bob     | art     | 70
 Bob     | history | 70
 Sue     | art     | 89
 Bob     | math    | 77
 Bob     | science | 71
 Sue     | math    | 87
 Sue     | history | 89
 Sue     | science | 88
```

The plugin also provides three introspection tables that describe: 1) the spreadsheet as a whole, 2) each tab, and 3) each cell across all tabs. Click these links to review them; you can also use `.inspect` in the Steampipe CLI.

1 [.inspect googlesheets_spreadsheet](https://hub.steampipe.io/plugins/turbot/googlesheets/tables/googlesheets_spreadsheet#inspect)

Reports metadata about the spreadsheet, including creation time and permissions.

2 [.inspect googlesheets_sheet](https://hub.steampipe.io/plugins/turbot/googlesheets/tables/googlesheets_sheet#inspect)

Reports metadata about each tab in the spreadsheet, including order in the sheet, charts, protected ranges, and merges.

3 [.inspect googlesheets_cell](https://hub.steampipe.io/plugins/turbot/googlesheets/tables/googlesheets_cell#inspect)

Reports every cell in the spreadsheet, across all tabs, including row and column coordinates, values, and formulas.

## Join spreadsheets with tables

If you're using the [GitHub plugin](https://hub.steampipe.io/plugins/turbot/github), and you want to query a subset of the repos visible to you in the `github-my-repository` table, one common pattern is to match repo names using a regular expression. 

```sql
select 
  full_name
from
  github_my_repository
where
  full_name ~ 'turbot/steampipe-(mod|plugin).+'
```

You can alternatively list the names in a Google Sheet.

```sql
select 
  full_name
from
  github_my_repository
join 
  reposheet."Repos"
using
  (full_name)
```

This pattern delivers a couple of benefits. First, it enables you to list names that aren't easy to capture with a regex. Second, it abstracts the list away from any particular query and makes it maintainable by people who can write to the spreadsheet but can't (or don't want to) edit queries.

The pattern extends to custom controls as well. In that case, though you can use [mod variables](https://steampipe.io/blog/release-0-8-0#variables--query-parameters-in-mods) to encode the list of names, such a list is again specific to that context and not easily team-accessible. 

Suppose you want to enforce a *license_is_apache* rule for a set of GitHub repos listed in a column of a spreadsheet like so:

```
full_name		
turbot/steampipe-plugin-github		
turbot/steampipe-mod-github-sherlock
...
```

Here's a custom control that joins `github_my_repository` with the spreadsheet to check that rule.

```sql
control "license_is_apache" {
  title = "License is Apache 2.0"
  sql = <<EOT
    select
      html_url as resource,
      case
        when license_spdx_id = 'Apache-2.0' then 'ok'
        else 'alarm' 
      end as status,
      full_name || ' license is ' || license_name as reason,
      full_name
    from
      github_my_repository
    join
      reposheet."Repos"
    using (full_name)
  EOT
}

```

To run it:

```
steampipe check control.license_is_apache
```

## Enforce named ranges

We often use spreadsheets as if they were databases, relying on implied referential integrity that does not actually exist. In [Using SQL to check spreadsheet integrity](https://steampipe.io/blog/spreadsheet-integrity#integrity-checks-for-spreadsheets) we considered a spreadsheet used for event planning. Sessions referenced in one tab are intended to refer to sessions defined in another, but nothing guarantees they do. We showed how to write a custom control, `sessions_valid_in_sessions_table`, to check for broken references.

There's another kind of referential integrity that spreadsheets aspire to but often fail to achieve: named ranges. You may intend the first thousand rows of column A in a sheet to represent a canonical list of repository names. But that intention only lives in your head until you give the range A1:A1000 a name and then refer to the range using the name.

Here's a sheet about Steampipe plugins that gets it half right. It groups plugins by schema type -- dynamic vs fixed -- and counts items in each group. The dynamic plugins are captured in a named range, and counted using that range. But the fixed plugins are captured and counted using raw cell addresses. 

<img src="/images/blog/2022-03-googlesheets/named-ranges.png" />

If you intend to use named ranges exclusively, the formula in cell D1 is an error. Here's a query to find that error.

```sql
select 
  cell, 
  regexp_matches(formula,'\w\d+:\w\d+') 
as 
  ref
from reposheet.googlesheets_cell
```

```
+------+------------+
| cell | ref        |
+------+------------+
| D1   | {C2:C1000} |
+------+------------+
```

When named ranges do exist, you can of course use them in formulas like `=counta(dynamic)`. And now you can also use them in SQL! 

```sql
select 
  count(*) 
from 
  reposheet.googlesheets_cell 
where range = 'dynamic'
```

```
+-------+
| count |
+-------+
| 3     |
+-------+
```

## Find secrets

In [Find secrets everywhere](https://steampipe.io/blog/find-secrets-everywhere) we showed how to use the [code](https://hub.steampipe.io/plugins/turbot/code) plugin's [code_secret](https://hub.steampipe.io/plugins/turbot/code/tables/code_secret) table to look for secrets in various AWS nooks and crannies. 

The same method works with any column of any table provided by any plugin. If you've configured the Google Sheets plugin for a single spreadsheet, this query scans all of its tabs for secrets in values or formulas.

```sql
select
  *
from
  googlesheets_cell
where
  src = value or src = formula
```

To scan multiple spreadsheets, use a [connection aggregator](https://steampipe.io/docs/using-steampipe/managing-connections#using-aggregators) to combine them.

```hcl
connection "all_sheets" {
  type = "aggregator"
  plugin = "googlesheets"
  connections = ["sheet1", "sheet2", "sheet3"]
}
```

Then use the `all_sheets` connection to scan across all the sheets. 

```sql
select
  *
from
  all_sheets.googlesheets_cell
where
  src = value or src = formula
```

## SQL instead of formulas

The [Dashboard tab](https://docs.google.com/spreadsheets/d/11iXfj-RHpFsil7_hNK-oQjCqmBLlDfCvju2AOF-ieb4/edit#gid=1125169872) of our sample spreadsheet summarizes the *"Students"* tab by grade. 

```
Student GPA
GPA			Grade	Count
4.0			A		2
3.0 - 3.9	B		14
2.0 - 2.9	C		8
1.0 - 1.9	D		6
0 - 0.9		F		0
```

It does that with formulas, in column C, like `=COUNTIFS(Students!H2:H31, "=4.0")`. With the `googlesheets` plugin you can accomplish the same thing with a query.


```sql
select '4.0' as gpa, 'A' as grade, count(*) from "Students" where "GPA"::float = 4.0
union 
select '3.0-3.9', 'B', count(*) from "Students" where "GPA"::float between 3.0 and 3.9
union 
select '2.0-2.9', 'C', count(*) from "Students" where "GPA"::float between 2.0 and 2.9
union 
select '1.0-1.9', 'D', count(*) from "Students" where "GPA"::float between 1.0 and 1.9
union 
select '0-0.9', 'E', count(*) from "Students" where "GPA"::float between 0 and 0.9
order by grade
```

This snippet of SQL is arguably both more readable and more maintainable than a collection of formulas scattered across multiple cells in a spreadsheet. 


## Pivot the Postgres way

To see the average GPA for students by home state and major, you'd ordinarily use a pivot table. 
With Steampipe and the `googlesheets` plugin you can do the same thing in SQL with the help of the built-in Postgres  `tablefunc` extension.

First, some context for Postgres extensions. Steampipe is an app that launches Postgres and activates a type of extension, called a [foreign data wrapper](https://wiki.postgresql.org/wiki/Foreign_data_wrappers), that converts plugin-sourced API data into database tables. But [steamipe-postgres-fdw](https://github.com/turbot/steampipe-postgres-fdw) isn't the only extension you can activate in the Steampipe instance of Postgres. There's a long list of [contributed extensions](https://www.postgresql.org/docs/current/contrib.html) that users of Postgres, and thus also of Steampipe, can use. One of these, [tablefunc](https://www.postgresql.org/docs/current/tablefunc.html), provides functions that you can use to create the same pivot table directly in SQL.

Here's the definition of the  function we'll use.

```
crosstab ( *source_sql* text, *category_sql* text ) -> setof record
  Produces a "pivot table" with the value columns specified by a second query.
```

Postgres functions, including those built in to the database and those you write yourself, can return primitive types such as integers, strings, dates, and arrays. But they can also return sets of records that behave, in SELECT contexts, just like tables, and `crosstab` is that kind of function.

Postgres functions can share a name but differ with respect to their signatures, and that's also true for `crosstab`. The variant we'll use here takes two parameters. Both are SQL snippets of type `text`. *source_sql* selects the raw data for the pivot; *category_sql* selects the columns (Art, English, etc.). 

Because *source_sql* and *category_sql* include quoted table names and column names, we'll use Postgres' [dollar-quoted string constants](https://www.postgresql.org/docs/current/sql-syntax-lexical.html#SQL-SYNTAX-DOLLAR-QUOTING) to quote SQL snippets.

Here's the query.

```sql
select * from crosstab (
  
  -- SQL snippet to select raw data for the pivot
  $$
  select 
    "Home State",
    "Major",
    avg("GPA"::float)::numeric
  from 
    "Students"
  group by
    "Home State", "Major"
  order by 
    "Home State", "Major"
  $$, 
  
  -- SQL snippet to select categories
  $$
  select distinct
    "Major"
  from
    "Students"
  $$

)

-- definition of the output table
as table_def (
  state text, 
  art numeric, 
  english numeric, 
  math numeric, 
  physics numeric
);
```

And here's the SQL output corresponding to the pivot table in the spreadsheet.

```
+-------+--------+---------+--------+---------+
| state | art    | english | math   | physics |
+-------+--------+---------+--------+---------+
| AK    | <null> | 1.6     | <null> | 2.4     |
| CA    | <null> | 2.5     | <null> | 2.2     |
| FL    | <null> | 3.4     | 3      | <null>  |
| MA    | 2.5    | <null>  | 3      | <null>  |
| MD    | 2.2    | <null>  | 1.9    | <null>  |
| NC    | <null> | 2.4     | <null> | 2.8     |
| NE    | <null> | 2.7     | <null> | 4       |
| NH    | <null> | 3.9     | <null> | 3.8     |
| NY    | 2.7    | <null>  | 3.6    | <null>  |
| RI    | 4      | <null>  | 3.2    | <null>  |
| SC    | 1.3    | <null>  | 3.6    | <null>  |
| SD    | 3.1    | <null>  | 3.5    | <null>  |
| WI    | <null> | 1.5     | <null> | 2.9     |
+-------+--------+---------+--------+---------+
```

## Spreadsheets and SQL

We use spreadsheets to capture and analyze data. With Steampipe + Google Sheets you can decouple capture from analysis. Many will agree that a web-based spreadsheet is a great tool for collaborative data entry, but few will argue that it's the best tool for analysis. Data scientists often prefer R and Python; SQL is a powerful alternative too. With Steampipe you can use SQL to validate data entry, then do your analysis with readable and maintainable SQL code. 

What about displaying the results of that analysis? If you're a user of Metabase, Tableau, PowerBI, Superset, or another visualization tool that connects to Postgres, any of these will work. But we hope you'll also try [Steampipe Dashboards](https://steampipe.io/blog/dashboards-as-code)!
