---
id: adding-a-column-to-a-table
title: "Adding a column to a Steampipe table"
category: "Case Study"
description: "A small tweak to the GitHub plugin unlocks new capability"
author:
  name: Jon Udell
  twitter: "@judell"
publishedAt: "2021-09-19T20:00:00"
durationMins: 8
image: /images/blog/2021-09-17-adding-a-column-to-a-table/github-gists.jpg
slug: adding-a-column-to-a-table
schema: "2021-01-08"
---

## Exploring the GitHub plugin

If you install Steampipe's GitHub plugin and scan the [tables it provides](https://hub.steampipe.io/plugins/turbot/github/tables), you'll spot several related to gists. What would it be like to list and query a gist collection? I launched `steampipe query` and asked to see the table.

<Terminal mode="light">
  <TerminalCommand>
    {`
select * from github_my_gist
`}
  </TerminalCommand>
  <TerminalResult>
{`+----------------------------------+-------------------------------------------------------
| id                               | description                                           
+----------------------------------+-------------------------------------------------------
| 273d045eb744b5fd2e1b30be06d4ffc9 |                                                       
| 7863e9f9ff8a1200ba4dda563f37485d | wiki page inspector                                                      
| fd6808210fe615bcb30d2cee29cd8ff7 |                                                       
| 51f29f517dda52c27b2f2486dc91261d | DOI aliases
| 3159ddfa6cfd42e5beda185600e9b4fb | data inventory                                      
| 935f8a8a8e088e8fe6c80f2e5f3d627a |                                                       
`}
  </TerminalResult>
</Terminal>

<br />

Most of the columns fall off the edge of the page. In Steampipe you can use arrow keys to scroll up, down, left, and right. To show a complete record here I'll just select one record as JSON.

<Terminal mode="light">
  <TerminalCommand>
    {`
.output json
`}
  </TerminalCommand>
  <TerminalCommand>
    {`
select * from github_my_gist where id = 'e85a3d8e7a23c247f672aaf95b6c3da9'
`}
  </TerminalCommand>
  <TerminalResult>
{`[
 {
  "comments": 0,
  "created_at": "2018-12-01 03:11:24",
  "description": "minimal hypothesis websocket client for python",
  "git_pull_url": "https://gist.github.com/e85a3d8e7a23c247f672aaf95b6c3da9.git",
  "git_push_url": "https://gist.github.com/e85a3d8e7a23c247f672aaf95b6c3da9.git",
  "html_url": "https://gist.github.com/e85a3d8e7a23c247f672aaf95b6c3da9",
  "id": "e85a3d8e7a23c247f672aaf95b6c3da9",
  "node_id": "MDQ6R2lzdGU4NWEzZDhlN2EyM2MyNDdmNjcyYWFmOTViNmMzZGE5",
  "owner_id": 46509,
  "owner_login": "judell",
  "owner_type": "User",
  "public": true,
  "updated_at": "2019-06-14 14:24:49"
 }
] 
`}
  </TerminalResult>
</Terminal>

<br />

## Case of the missing filename

Hmm. Every gist has a filename but there isn't one here. To investigate I clicked the GitHub link on the [table's home page](https://hub.steampipe.io/plugins/turbot/github/tables/github_my_gist) and navigated to [table_github_my_gist.go](https://github.com/turbot/steampipe-plugin-github/blob/main/github/table_github_my_gist.go). There really isn't much to see there. Steampipe plugins are often thin shims between the [plugin SDK](https://github.com/turbot/steampipe-plugin-sdk) and a golang library that wraps an API. Here's the top of `table_github_my_gist.go`.


```go
package github

import (
	"context"
	"time"

	"github.com/google/go-github/v33/github"
	"github.com/sethvargo/go-retry"
	"github.com/turbot/steampipe-plugin-sdk/plugin"
)
```

The API wrapper is [https://github.com/google/go-github/](https://github.com/google/go-github). I went there, opened the `github` folder, searched in the page for `gist`, and landed on [gists.go](https://github.com/google/go-github/blob/master/github/gists.go) which provides the gist-related parts of the GitHub API. There I found the definition of the object that the API wrapper defines, and that the Steampipe plugin maps to a table. 

```go
// Gist represents a GitHub's gist.
type Gist struct {
	ID          *string                   `json:"id,omitempty"`
	Description *string                   `json:"description,omitempty"`
	Public      *bool                     `json:"public,omitempty"`
	Owner       *User                     `json:"owner,omitempty"`
	Files       map[GistFilename]GistFile `json:"files,omitempty"`
	Comments    *int                      `json:"comments,omitempty"`
	HTMLURL     *string                   `json:"html_url,omitempty"`
	GitPullURL  *string                   `json:"git_pull_url,omitempty"`
	GitPushURL  *string                   `json:"git_push_url,omitempty"`
	CreatedAt   *time.Time                `json:"created_at,omitempty"`
	UpdatedAt   *time.Time                `json:"updated_at,omitempty"`
	NodeID      *string                   `json:"node_id,omitempty"`
}
```

## Adding the Files object

One of these things is not like the others, and it's the missing ingredient: `Files`. At this point I know very little about golang, or the Steampipe plugin SDK, and have no idea whether I can make that Files object show up in Steampipe, but it's worth a try. The instructions at [https://github.com/turbot/steampipe-plugin-github](https://github.com/turbot/steampipe-plugin-github#developing) seem straightforward. I follow them, rebuild the plugin, verify that it works, and then consider how to add `Files` to the table. This function in `table_github_gist.go` is clearly where the mapping occurs.

```go
func gitHubGistColumns() []*plugin.Column {
	return []*plugin.Column{

		// Top columns
		{Name: "id", Type: pb.ColumnType_STRING, Description: "The unique id of the gist."},
		{Name: "description", Type: pb.ColumnType_STRING, Description: "The gist description."},
		{Name: "public", Type: pb.ColumnType_BOOL, Description: "If true, the gist is public, otherwise it is private."},
		{Name: "html_url", Type: pb.ColumnType_STRING, Description: "The HTML URL of the gist."},

		{Name: "comments", Type: pb.ColumnType_INT, Description: "The number of comments for the gist."},
		{Name: "created_at", Type: pb.ColumnType_TIMESTAMP, Description: "The timestamp when the gist was created."},
		{Name: "git_pull_url", Type: pb.ColumnType_STRING, Description: "The https url to pull or clone the gist."},
		{Name: "git_push_url", Type: pb.ColumnType_STRING, Description: "The https url to push the gist."},
		{Name: "node_id", Type: pb.ColumnType_STRING, Description: "The Node ID of the gist."},
		// Only load relevant fields from the owner
		{Name: "owner_id", Type: pb.ColumnType_INT, Description: "The user id (number) of the gist owner.", Transform: transform.FromField("Owner.ID")},
		{Name: "owner_login", Type: pb.ColumnType_STRING, Description: "The user login name of the gist owner.", Transform: transform.FromField("Owner.Login")},
		{Name: "owner_type", Type: pb.ColumnType_STRING, Description: "The type of the gist owner (User or Organization).", Transform: transform.FromField("Owner.Type")},
		{Name: "updated_at", Type: pb.ColumnType_TIMESTAMP, Description: "The timestamp when the gist was last updated."},
	}
}
```

Could it possibly be as simple as adding this?

```go
{Name: "files", Type: pb.ColumnType_JSON, Description: "The files associated with the gist."},
```

Spoiler alert, it was. Well, sort of. 

<Terminal mode="light">
  <TerminalCommand>
    {`
select * from github_my_gist where id ='e85a3d8e7a23c247f672aaf95b6c3da9'
`}
  </TerminalCommand>
  <TerminalResult>
{`[
 {
  "comments": 0,
  "created_at": "2018-12-01 03:11:24",
  "description": "minimal hypothesis websocket client for python",
  "files": {
   "wsclient.py": {
    "filename": "wsclient.py",
    "language": "Python",
    "raw_url": "https://gist.githubusercontent.com/judell/e85a3d8e7a23c247f672aaf95b6c3da9/raw/a3b48e9251a6b8beb38270a6d0ccb083778fabe8/wsclient.py",
    "size": 1264,
    "type": "application/x-python"
   }
  },
  "git_pull_url": "https://gist.github.com/e85a3d8e7a23c247f672aaf95b6c3da9.git",
  "git_push_url": "https://gist.github.com/e85a3d8e7a23c247f672aaf95b6c3da9.git",
  "html_url": "https://gist.github.com/e85a3d8e7a23c247f672aaf95b6c3da9",
  "id": "e85a3d8e7a23c247f672aaf95b6c3da9",
  "node_id": "MDQ6R2lzdGU4NWEzZDhlN2EyM2MyNDdmNjcyYWFmOTViNmMzZGE5",
  "owner_id": 46509,
  "owner_login": "judell",
  "owner_type": "User",
  "public": true,
  "updated_at": "2019-06-14 14:24:49"
 }
]
`}
  </TerminalResult>
</Terminal>

<br />

There's the `files` object. Now, how to use it?

## Working with JSONB

Let's verify that Postgres actually sees it as a JSONB object and not just a string.

```sql
> select
    pg_typeof(id) as id,
    pg_typeof(files) as files
  from github_my_gist
  limit 1
```

```
+-----------+------------+
| id        | files      |
+-----------+------------+
| text      | jsonb      |
+-----------+------------+
```

It does, which means we can use Postgres' family of [JSON functions and operators](https://www.postgresql.org/docs/current/functions-json.html) to wrangle it. Unfortunately the structure provided by the API is a bit baroque. The `files` object shown above contains a set of subobjects keyed by filename; that same filename also appears along with other data in each subobject. I'm not sure why that's so but it's the structure GitHub provides, and it would require getting the top-level key and using it to access the nested object. Here's one way to do that.

<Terminal mode="light">
  <TerminalCommand>
    {`
with filenames as (
 select
   id,
   jsonb_object_keys(files) as name
 from github_my_gist
)
select
 f.name,
 g.files -> f.name ->> 'language' as language,
 g.description
from filenames f
join github_my_gist g using (id) limit 5
`}
  </TerminalCommand>
  <TerminalResult>
{`+---------------------------------+----------+----------------------------------------------------+
| name                            | language | description                                        |
+---------------------------------+----------+----------------------------------------------------+
| internal_and_public_id          | <null>   | convert between hypothesis internal and public ids |
| async-postgres-listener.py      | Python   |                                                    |
| find-unused-security-groups.sql | SQL      | PATTERN: UNION similar things to combine them      |
| plpython.md                     | Markdown |                                                    |
| inventory                       | <null>   | h data inventory                                   |
+---------------------------------+----------+----------------------------------------------------+
`}
  </TerminalResult>
</Terminal>

<br />

If you haven't used JSONB in Postgres, the first thing to know is that -- confusingly -- there's a parallel set of JSON functions. The [Postgres documentation](https://www.postgresql.org/docs/14/datatype-json.html) explains:

> The json and jsonb data types accept almost identical sets of values as input. The major practical difference is one of efficiency. The json data type stores an exact copy of the input text, which processing functions must reparse on each execution; while jsonb data is stored in a decomposed binary format that makes it slightly slower to input due to added conversion overhead, but significantly faster to process, since no reparsing is needed. jsonb also supports indexing, which can be a significant advantage.

Generally, and always in the context of Steampipe, JSONB is the one you want. 

The second thing to know is that `->` refers to a piece of a JSON object and `->>` gets its value.

It's often helpful to use a Common Table Expression (aka CTE aka WITH clause) to make a query easier to write and to read. CTEs produce intermediate tables that you can check in stages. Here's a partial result for the above CTE.

<Terminal mode="light">
  <TerminalCommand>
    {`
with filenames as (
    select
    id,
    jsonb_object_keys(files) as name
  from github_my_gist
  )
  select * from filenames
  where id = 'e85a3d8e7a23c247f672aaf95b6c3da9'
`}
  </TerminalCommand>
  <TerminalResult>
{`+----------------------------------+-------------+
| id                               | name        |
+----------------------------------+-------------+
| e85a3d8e7a23c247f672aaf95b6c3da9 | wsclient.py |
+----------------------------------+-------------+
`}
  </TerminalResult>
</Terminal>

<br />

With the filenames broken out into a column, the main part of the query can join the CTE on `id` and use its `name` column to index into the `files` object.

Why not just have the plugin hoist those fields to the top level? It could, but per discussion [here](https://github.com/turbot/steampipe-plugin-github/issues/57) there's a tradeoff. 

> Definitely makes sense to add the files column. JSON is a reasonable starting point for it too ... if a piece of data from deep in the JSON is used a lot then sometimes we elevate it up to a column on its own, but that is usually when completely obvious or widely requested (easy to add columns, very hard to deprecate/remove them).

I'll add that if you're doing analytics on a Postgres foundation, learning how to work with JSONB is just a good investment. It's a relatively new and wildly popular Postgres capability that blurs the line between relational and object-like data.
## A better way

This approach keeps things simple for the plugin author but complicates life for the query writer who would rather the `files` object were flattened to a simple array of subobjects. Let's take this opportunity to show how transformations can reshape the data acquired from an API. 

```go
{ Name: "files", 
  Type: pb.ColumnType_JSON, Transform: transform.FromField("Files").Transform(gistFileMapToArray), 
  Description: "Files in the gist."
},
```

The helper function used in this transform works with types defined in the API wrapper: `GistFile` and `GistFileName`. Here's the helper function.

```go
func gistFileMapToArray(ctx context.Context, input *transform.TransformData) (interface{}, error) {
	var objectList []github.GistFile
	objectMap := input.Value.(map[github.GistFilename]github.GistFile)
	for _, v := range objectMap {
		objectList = append(objectList, v)
	}
	return objectList, nil
}
```

With these changes applied, we can replace the slightly awkward `jsonb_object_keys` function with the more natural `jsonb_array_elements`. Here's one way to use it to summarize gists by language.

<Terminal mode="light">
  <TerminalCommand>
    {`
select 
  f ->> 'language' as language,
  count(*)
from 
  github_my_gist g
cross join
  jsonb_array_elements(g.files) f
group by
  language
order by 
  count desc
`}
  </TerminalCommand>
  <TerminalResult>
{`+------------------+-------+
| language         | count |
+------------------+-------+
| Text             | 30    |
| Python           | 15    |
| JavaScript       | 8     |
| <null>           | 7     |
| Markdown         | 3     |
| SQL              | 3     |
| JSON             | 1     |
| reStructuredText | 1     |
| HTML             | 1     |
+------------------+-------+
`}
  </TerminalResult>
</Terminal>

<br />

## Come on in, the water's fine!

That's a nice capability to unlock with a few small tweaks to a plugin. The initial naive solution was readily discoverable and doable by a golang and plugin novice. For the transform-based solution I'll admit that I got some help from the Steampipe team, but it's still pretty straightforward. All this bodes well for a growing ecosystem of Steampipe plugins. 