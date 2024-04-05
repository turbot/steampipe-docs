---
title: SQL Operators as API Filters
sidebar_label: SQL Operators as API Filters
---

# SQL Operators as API Filters

When you write SQL that resolves to API calls, you want a SQL operator like `>` to influence an API call in the expected way. 

Consider this query:

```
SELECT * FROM github_issue WHERE updated_at > '2022-01-01'
```

You would like the underlying API call to filter accordingly. 

In order to intercept the SQL operator, and implement it in your table code, you [declare it](https://github.com/turbot/steampipe-plugin-github/blob/ec932825c781a66c325fdbc5560f96cac272e64f/github/table_github_issue.go#L75-L93) in the `KeyColumns` property of the table.


```
KeyColumns: []*plugin.KeyColumn{
  {
    Name:    "repository_full_name",
    Require: plugin.Required,
  },
  {
    Name:    "author_login",
    Require: plugin.Optional,
  },
  {
    Name:    "state",
    Require: plugin.Optional,
  },
  {
    Name:      "updated_at",
    Require:   plugin.Optional,
    Operators: []string{">", ">="},  // declare operators your get/list/hydrate function handles
  },
```

Then, in your table code, you write a handler for the column. The handler configures the API to [filter on one or more operators](https://github.com/turbot/steampipe-plugin-github/blob/ec932825c781a66c325fdbc5560f96cac272e64f/github/table_github_issue.go#L135-L147).


```
if d.Quals["updated_at"] != nil {
	for _, q := range d.Quals["updated_at"].Quals {
		givenTime := q.Value.GetTimestampValue().AsTime()  // timestamp from the SQL query
		afterTime := givenTime.Add(time.Second * 1)  // one second after the given time
		switch q.Operator {
		case ">":
			filters.Since = githubv4.NewDateTime(githubv4.DateTime{Time: afterTime})  // handle WHERE updated_at > '2022-01-01'
		case ">=":
			filters.Since = githubv4.NewDateTime(githubv4.DateTime{Time: givenTime})  // handle WHERE updated_at >= '2022-01-01'
		}
	}
}

```


