---
title: Writing Plugins
sidebar_label:  Writing Plugins
---

# Writing Plugins

The <a href="https://github.com/turbot/steampipe-plugin-sdk" target="_blank" rel="noopener noreferrer">Steampipe Plugin SDK</a> makes writing tables fast, easy, and fun!  Most of the heavy lifting is taken care of for you — just define your tables and columns, wire up a few API calls, and you can start to query your service with standard SQL!

While this document will provide an introduction and some examples, note that Steampipe is an evolving, open source project - refer to the code as the authoritative source, as well as for real-world examples.

Also, please try to be a good community citizen — following the <a href="/docs/develop/standards" target="_blank" rel="noopener">standards</a> makes for a better, more consistent experience for end-users and developers alike.

Let's get started!

- [The Basics](#the-basics)
- [Implementing Tables](#implementing-tables)
- [Hydrate Functions](#hydrate-functions)
- [Client-Side Rate Limiting](#client-side-rate-limiting)
- [Function Tags](#function-tags)
- [Accounting for Paged List calls](#accounting-for-paged-list-calls)
- [Logging](#logging)
- [Installing and Testing Your Plugin](#installing-and-testing-your-plugin)

----

## The Basics

### main.go

The `main` function in then `main.go` is the entry point for your plugin.  This function must call `plugin.Serve` from the plugin sdk to instantiate your plugin gRPC server.  You will pass the plugin function that you will create in the [plugin.go](#plugingo) file:

### Example: main.go

```go
package main

import (
	"github.com/turbot/steampipe-plugin-sdk/v5/plugin"
	"github.com/turbot/steampipe-plugin-zendesk/zendesk"
)

func main() {
	plugin.Serve(&plugin.ServeOpts{PluginFunc: zendesk.Plugin})
}

```

### plugin.go

The `plugin.go` file should implement a single [Plugin Definition](#plugin-definition) (`Plugin()` function) that returns a pointer to a `Plugin` to be loaded by the gRPC server.

By convention, the package name for your plugin should be the same name as your plugin, and go files for your plugin (except `main.go`) should reside in a folder with the same name.

### Example: plugin.go

```go
package zendesk

import (
	"context"

	"github.com/turbot/steampipe-plugin-sdk/plugin"
	"github.com/turbot/steampipe-plugin-sdk/plugin/transform"
)

func Plugin(ctx context.Context) *plugin.Plugin {
	p := &plugin.Plugin{
		Name:             "steampipe-plugin-zendesk",
		DefaultTransform: transform.FromGo().NullIfZero(),
		TableMap: map[string]*plugin.Table{
			"zendesk_brand":        tableZendeskBrand(),
			"zendesk_group":        tableZendeskGroup(),
			"zendesk_organization": tableZendeskOrganization(),
			"zendesk_search":       tableZendeskSearch(),
			"zendesk_ticket":       tableZendeskTicket(),
			"zendesk_ticket_audit": tableZendeskTicketAudit(),
			"zendesk_trigger":      tableZendeskTrigger(),
			"zendesk_user":         tableZendeskUser(),
		},
	}
	return p
}
```

### Plugin Definition

| Argument | Description
|-|-
| `Name`             | The name of the plugin (`steampipe-plugin-{plugin name}`).
| `TableMap`         | A map of table names to [Table definitions](#implementing-tables).
| `DefaultTransform` | A default [Transform Function](#transform-functions) to be used when one is not specified.  While not required, this may save quite a bit of repeated code.
| `DefaultGetConfig` | Provides an optional mechanism for providing plugin-level defaults to a get config.  This is merged with the GetConfig defined in the table and/or columns. Typically, this is used to standardize error handling with `ShouldIgnoreError`.
| `SchemaMode`       | Specifies if the schema should be checked and re-imported if changed every time Steampipe starts. This can be set to `dynamic` or `static`. Defaults to `static`.
| `RequiredColumns`  | An optional list of columns that ALL tables in this plugin MUST implement.

---

### Table Definition

The `plugin.Table` may specify:

| Argument | Description
|-|-
| `Name` | The name of the table.
| `Description` | A short description, added as a comment on the table and used in help commands and documentation.
| `Columns`  | An array of [column definitions](#column-definition).
| `List` | A [List Config](#list-config) definition, used to fetch the data items used to build all rows of a table.
| `Get` | A [Get Config](#get-config) definition, used to fetch a single item.
| `DefaultTransform` |  A default [transform function](#transform-functions) to be used when one is not specified.  If set, this will override the default set in the plugin definition.
| `HydrateDependencies` | Definitions of dependencies between hydrate functions (for cases where a hydrate function needs the results of another hydrate function).

### List Config

A ListConfig definition defines how to list all rows of a table.

| Argument | Description
|-|-
| `KeyColumns` | An optional list of columns that require a qualifier in order to list data for this table.
| `Hydrate` | A [hydrate function](#hydrate-functions) which is called first when performing a 'list' call.
| `ParentHydrate` | An optional parent list function - if you list items with a parent-child relationship, this will list the parent items.

### Get Config

A GetConfig definition defines how to get a single row of a table.

| Argument | Description
|-|-
| `KeyColumns` | A list of keys which are used to uniquely identify rows - used to determine whether a query is a 'get' call.
| `ItemFromKey [DEPRECATED]`] | This property is deprecated.
| `Hydrate` | A [hydrate function](#hydrate-functions) which is called first when performing a 'get' call. If this returns 'not found', no further hydrate functions are called.
| `ShouldIgnoreError` | A function which will return whether to ignore a given error.

### Column Definition

A column definition definition specifies the name and description of the column, its data type, and the functions to call to hydrate the column (if the list call does not) and transform it (if the default transformation is not sufficient).

| Argument | Description
|-|-
| `Name` | The column name.
| `Type` | The [data type](#column-data-types) for this column.
| `Description` | The column description, added as a comment and used in help commands and documentation.
| `Hydrate` | You can explicitly specify the [hydrate function](#hydrate-functions) function to populate this column. This is only needed if neither the default hydrate functions nor the `List` function return data for this column.
| `Default` | An optional default column value.
| `Transform` | An optional chain of [transform functions](#transform-functions) to generate the column value.

### Column Data Types

Currently supported data types are:

| Name | Type
|-|-
| `ColumnType_BOOL` | Boolean
| `ColumnType_INT` | Integer
| `ColumnType_DOUBLE` | Double precision floating point
| `ColumnType_STRING` | String
| `ColumnType_JSON` | JSON
| `ColumnType_DATETIME` | Date/Time (Deprecated - use ColumnType_TIMESTAMP)
| `ColumnType_TIMESTAMP` | Date/Time
| `ColumnType_IPADDR` | IP Address
| `ColumnType_CIDR` | IP network CIDR
| `ColumnType_UNKNOWN` | Unknown
| `ColumnType_INET` | Either an IP Address or an IP network CIDR  
| `ColumnType_LTREE` | [Ltree](https://www.postgresql.org/docs/current/ltree.html)

---


## Implementing Tables

By convention, each table should be implemented in a separate file named `table_{table name}.go`.  Each table will have a single table definition function that returns a pointer to a `plugin.Table` (this is the function specified in the `TableMap` of the [plugin definition](#plugin-definition)).  The function name is typically the table name in camel case (per golang standards) prefixed by `table`.

The table definition specifies the name and description of the table, a list of column definitions, and the functions to call in order to list the data for all the rows, or to get data for a single row.

When a connection is created, Steampipe uses the table and column definitions to create the Postgres foreign tables, however the tables don't store the data — the data is populated (hydrated) when a query is run.

The basic flow is:

1. A user runs a steampipe query against the database

1. Postgres parses the query and sends the parsed request to the Steampipe FDW.

1. The Steampipe Foreign Data Wrapper (Steampipe FDW) determines what tables and columns are required.

1. The FDW calls the appropriate [Hydrate Functions](#hydrate-functions) in the plugin, which fetch the appropriate data from the API, cloud provider, etc.
    - Each table defines two special hydrate functions, `List` and `Get`.  The `List` or `Get` will always be called before any other hydrate function in the table, as the other functions typically depend on the result of the Get or List call.
    - Whether `List` or `Get` is called depends upon whether the qualifiers (in `where` clauses and `join...on`) match the `KeyColumns`.  This allows Steampipe to fetch only the "row" data that it needs. Qualifiers (aka quals) enable  Steampipe to map a Postgres constraint (e.g. `where created_at > date('2023-01-01')`) to the API parameter (e.g. `since=1673992596000`) that the plugin's supporting SDK uses to fetch results matching the Postgres constraint. See [How To enhance a plugin with a new table that supports 'quals'](https://steampipe.io/blog/vercel-table) for a complete example.
    - Multiple columns may (and usually do) get built from the same hydrate function, but steampipe only calls the hydrate functions for the columns requested (specified in the `select`, `join`, or `where`).   This allows steampipe to call only those APIs for the "column" data requested in the query.

1. The [Transform Functions](#transform-functions) are called for each column.  The transform functions extract and/or reformat data returned by the hydrate functions into the format to be returned in the column.

1. The plugin returns the transformed data to the Steampipe FDW

1. Steampipe FDW returns the results to the database

## Hydrate Functions

A hydrate function connects to an external system or service and gathers data to fill a database table.

`Get` and `List` are hydrate functions, defined in the [Table Definition](#table-definition), that have these special characteristics:

- Every table ***must*** define a `List` and/or `Get` function.

- The `List` or `Get` will always be called before any other hydrate function in the table, as the other functions typically depend on the result of the `Get` or `List` call.

- Whether `List` or `Get` is called depends upon whether the qualifiers (in `where` clauses and `join...on`) match the `KeyColumns` defined in the [Get Config](#get-config).  This enables Steampipe to fetch only the "row" data that it needs.

- Typically, hydrate functions return a single data item (data for a single row).  *List functions are an exception* — they stream data for multiple rows using the [QueryData](https://github.com/turbot/steampipe-plugin-sdk/blob/HEAD/plugin/query_data.go) object, and return `nil`.

- The `Get` function will usually get the key column data from the `QueryData.KeyColumnQuals` so that it can get the appropriate item as based on the qualifiers (`where` clause, `join...on`).  If the `Get` hydrate function is used as both a `Get` function AND a normal hydrate function, you should get the key column data from the `HydrateData.Item` if it is not nil, and use the `QueryData.KeyColumnQuals` otherwise.

### About List Functions

A `List` function retrieves all the items of a particular resource type from an API. For example, the [github_my_gist](https://hub.steampipe.io/plugins/turbot/github/tables/github_my_gist) table supports the query:

```sql
select
  *
from
  github_my_gist
```

The function `tableGitHubMyGist` [defines the table](https://github.com/turbot/steampipe-plugin-github/blob/ec932825c781a66c325fdbc5560f96cac272e64f/github/table_github_my_gist.go#L10-L19) like so.

```go
func tableGitHubMyGist() *plugin.Table {
	return &plugin.Table{
		Name:        "github_my_gist",
		Description: "GitHub Gists owned by you. GitHub Gist is a simple way to share snippets and pastes with others.",
		List: &plugin.ListConfig{
			Hydrate: tableGitHubMyGistList,
		},
		Columns: gitHubGistColumns(),
	}
}
```

The table's `List` property refers, by way of the `Hydrate` property, to a Steampipe function that lists gists, [tableGitHubMyGistList](https://github.com/turbot/steampipe-plugin-github/blob/ec932825c781a66c325fdbc5560f96cac272e64f/github/table_github_my_gist.go#L21-L58). That function calls the GitHub Go SDK's [GistsService.List](https://pkg.go.dev/github.com/google/go-github/v60/github#GistsService.List) and returns an array of pointers to items of type `Gist` as [defined](https://pkg.go.dev/github.com/google/go-github/v60/github#Gist) in the Go SDK.

```go
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
	CreatedAt   *Timestamp                `json:"created_at,omitempty"`
	UpdatedAt   *Timestamp                `json:"updated_at,omitempty"`
	NodeID      *string                   `json:"node_id,omitempty"`
}
```

The `Columns` property in `tableGitHubMyGist` refers to the function `gitHubGistColumns`, which is shared with a related table [table_github_gist](https://github.com/turbot/steampipe-plugin-github/blob/ec932825c781a66c325fdbc5560f96cac272e64f/github/table_github_gist.go#L13-L32), and which maps that Go schema to this database schema.


```go

func gitHubGistColumns() []*plugin.Column {
	return []*plugin.Column{
		// Top columns
		{Name: "id", Type: proto.ColumnType_STRING, Description: "The unique id of the gist."},
		{Name: "description", Type: proto.ColumnType_STRING, Description: "The gist description."},
		{Name: "public", Type: proto.ColumnType_BOOL, Description: "If true, the gist is public, otherwise it is private."},
		{Name: "html_url", Type: proto.ColumnType_STRING, Description: "The HTML URL of the gist."},
		{Name: "comments", Type: proto.ColumnType_INT, Description: "The number of comments for the gist."},
		{Name: "created_at", Type: proto.ColumnType_TIMESTAMP, Transform: transform.FromField("CreatedAt").Transform(convertTimestamp), Description: "The timestamp when the gist was created."},
		{Name: "git_pull_url", Type: proto.ColumnType_STRING, Description: "The https url to pull or clone the gist."},
		{Name: "git_push_url", Type: proto.ColumnType_STRING, Description: "The https url to push the gist."},
		{Name: "node_id", Type: proto.ColumnType_STRING, Description: "The Node ID of the gist."},
		// Only load relevant fields from the owner
		{Name: "owner_id", Type: proto.ColumnType_INT, Description: "The user id (number) of the gist owner.", Transform: transform.FromField("Owner.ID")},
		{Name: "owner_login", Type: proto.ColumnType_STRING, Description: "The user login name of the gist owner.", Transform: transform.FromField("Owner.Login")},
		{Name: "owner_type", Type: proto.ColumnType_STRING, Description: "The type of the gist owner (User or Organization).", Transform: transform.FromField("Owner.Type")},
		{Name: "updated_at", Type: proto.ColumnType_TIMESTAMP, Transform: transform.FromField("UpdatedAt").Transform(convertTimestamp), Description: "The timestamp when the gist was last updated."},
		{Name: "files", Type: proto.ColumnType_JSON, Transform: transform.FromField("Files").Transform(gistFileMapToArray), Description: "Files in the gist."},
	}
}
```

Here's the [tableGitHubMyGistList](https://github.com/turbot/steampipe-plugin-github/blob/ec932825c781a66c325fdbc5560f96cac272e64f/github/table_github_my_gist.go#L21-#L58) function.

```go
func tableGitHubMyGistList(ctx context.Context, d *plugin.QueryData, h *plugin.HydrateData) (interface{}, error) {
	client := connect(ctx, d)

	opt := &github.GistListOptions{ListOptions: github.ListOptions{PerPage: 100}}

	limit := d.QueryContext.Limit  // the SQL LIMIT 
	if limit != nil {
		if *limit < int64(opt.ListOptions.PerPage) {
			opt.ListOptions.PerPage = int(*limit)
		}
	}

	for {
		gists, resp, err := client.Gists.List(ctx, "", opt) // call https://pkg.go.dev/github.com/google/go-github/v60/github#GistsService.List
		if err != nil {
			return nil, err
		}

		for _, i := range gists {
			if i != nil {
				d.StreamListItem(ctx, i) // send the item to steampipe
			}

			// Context can be cancelled due to manual cancellation or the limit has been hit
			if d.RowsRemaining(ctx) == 0 {
				return nil, nil
			}
		}

		if resp.NextPage == 0 {
			break
		}

		opt.Page = resp.NextPage
	}

	return nil, nil
}
```

A Steampipe `List` function is one of two special forms of [hydrate function](/docs/develop/writing-plugins#hydrate-functions) — `Get` is the other — that take precedence over other [hydrate functions](https://pkg.go.dev/github.com/turbot/steampipe-plugin-sdk/v5/plugin#HydrateFunc) which are declared using the `HydrateConfig` property of a table definition.

### About Get Functions

A `Get` function fetches a single item by its key. While it's possible to define a table that only uses `Get`, the common pattern combines `List` to retrieve basic data and `Get` to enrich it. For example, here's the definition of the table [github_gitignore](https://github.com/turbot/steampipe-plugin-github/blob/ec932825c781a66c325fdbc5560f96cac272e64f/github/table_github_gitignore.go#L12-L30).

```go
func tableGitHubGitignore() *plugin.Table {
	return &plugin.Table{
		Name:        "github_gitignore",
		Description: "GitHub defined .gitignore templates that you can associate with your repository.",
		List: &plugin.ListConfig{
			Hydrate: tableGitHubGitignoreList,
		},
		Get: &plugin.GetConfig{
			KeyColumns:        plugin.SingleColumn("name"),
			ShouldIgnoreError: isNotFoundError([]string{"404"}),
			Hydrate:           tableGitHubGitignoreGetData,
		},
		Columns: []*plugin.Column{
			// Top columns
			{Name: "name", Type: proto.ColumnType_STRING, Description: "Name of the gitignore template."},
			{Name: "source", Type: proto.ColumnType_STRING, Hydrate: tableGitHubGitignoreGetData, Description: "Source code of the gitignore template."},
		},
	}
}
````

In this case, the `source` column data is not included in the API response from the `tableGitHubGitignoreList` function. So the `tableGitHubGitignoreGetData` function is specified as the `Hydrate` function for that column.

The `List` function, [tableGitHubGitignoreList](https://github.com/turbot/steampipe-plugin-github/blob/ec932825c781a66c325fdbc5560f96cac272e64f/github/table_github_gitignore.go#L32-L51), calls the SDK's [GitignoresService.List](https://pkg.go.dev/github.com/google/go-github/v55@v55.0.0/github#GitignoresService.List) which returns an array of strings which are the names of [.gitignore templates](https://docs.github.com/en/rest/gitignore?apiVersion=2022-11-28#listing-available-templates).

The `Get` function, [tableGitHubGitignoreGetData](https://github.com/turbot/steampipe-plugin-github/blob/ec932825c781a66c325fdbc5560f96cac272e64f/github/table_github_gitignore.go#L53-L75), receives the name of a template and calls the SDK's [GitignoresService.Get](https://pkg.go.dev/github.com/google/go-github/v55@v55.0.0/github#GitignoresService.Get) to return an item of type [GitIgnore](https://pkg.go.dev/github.com/google/go-github/v55@v55.0.0/github#Gitignore), which corresponds to the `Columns` in the table definition.

```go
type Gitignore struct {
	Name   *string `json:"name,omitempty"`
	Source *string `json:"source,omitempty"`
}
```

For example, here's the result for `select * from github_gitignore where name = 'go'`.

```
+------+-------------------------------------------------------------------------------------------+
| name | source                                                                                    |
+------+-------------------------------------------------------------------------------------------+
| Go   | # If you prefer the allow list template instead of the deny list, see community template: |
|      | # https://github.com/github/gitignore/blob/main/community/Golang/Go.AllowList.gitignore   |
|      | #                                                                                         |
|      | # Binaries for programs and plugins                                                       |
|      | *.exe                                                                                     |
|      | *.exe~                                                                                    |
|      | *.dll                                                                                     |
|      | *.so                                                                                      |
|      | *.dylib                                                                                   |
+------+-------------------------------------------------------------------------------------------+
```

The `List` function finds all the names of the templates provided by GitHub, and the `Get` function adds the `source` column. 

#### When the column definition doesn't need to specify a `Hydrate`

When the underlying SDK functions for a `List` and `Get` both return complete information, the column definition doesn't need to specify a `Hydrate`. For example, here's the definition for [table_github_actions_artifact](https://github.com/turbot/steampipe-plugin-github/blob/ec932825c781a66c325fdbc5560f96cac272e64f/github/table_github_actions_artifact.go#L13-L42).

```go
func tableGitHubActionsArtifact() *plugin.Table {
	return &plugin.Table{
		Name:        "github_actions_artifact",
		Description: "Artifacts allow you to share data between jobs in a workflow and store data once that workflow has completed.",
		List: &plugin.ListConfig{
			KeyColumns:        plugin.SingleColumn("repository_full_name"),
			ShouldIgnoreError: isNotFoundError([]string{"404"}),
			Hydrate:           tableGitHubArtifactList,
		},
		Get: &plugin.GetConfig{
			KeyColumns:        plugin.AllColumns([]string{"repository_full_name", "id"}),
			ShouldIgnoreError: isNotFoundError([]string{"404"}),
			Hydrate:           tableGitHubArtifactGet,
		},
		Columns: []*plugin.Column{
			// Top columns
			{Name: "repository_full_name", Type: proto.ColumnType_STRING, Transform: transform.FromQual("repository_full_name"), Description: "Full name of the repository that contains the artifact."},
			{Name: "name", Type: proto.ColumnType_STRING, Description: "The name of the artifact."},
			{Name: "id", Type: proto.ColumnType_INT, Description: "Unique ID of the artifact."},
			{Name: "size_in_bytes", Type: proto.ColumnType_INT, Description: "Size of the artifact in bytes."},

			// Other columns
			{Name: "archive_download_url", Type: proto.ColumnType_STRING, Transform: transform.FromField("ArchiveDownloadURL"), Description: "Archive download URL for the artifact."},
			{Name: "created_at", Type: proto.ColumnType_TIMESTAMP, Transform: transform.FromField("CreatedAt").Transform(convertTimestamp), Description: "Time when the artifact was created."},
			{Name: "expired", Type: proto.ColumnType_BOOL, Description: "It defines whether the artifact is expires or not."},
			{Name: "expires_at", Type: proto.ColumnType_TIMESTAMP, Transform: transform.FromField("ExpiresAt").Transform(convertTimestamp), Description: "Time when the artifact expires."},
			{Name: "node_id", Type: proto.ColumnType_STRING, Description: "Node where GitHub stores this data internally."},
		},
	}
}
```

The SDK's [ListArtifacts](https://pkg.go.dev/github.com/google/go-github/v55@v55.0.0/github#ActionsService.ListArtifacts) returns an array of [Artifact](https://pkg.go.dev/github.com/google/go-github/v55@v55.0.0/github#Artifact) and its [GetArtifact](https://pkg.go.dev/github.com/google/go-github/v55@v55.0.0/github#ActionsService.GetArtifact) returns a single `Artifact` object. As with `tableGitHubGitignore`, these are separate APIs — wrapped by the Go SDK — to [list basic info](https://docs.github.com/en/rest/actions/artifacts?apiVersion=2022-11-28#list-artifacts-for-a-repository) and [get details](https://docs.github.com/en/rest/actions/artifacts?apiVersion=2022-11-28#get-an-artifact) artifacts. If the query's `where` or `join...on` specifies an `id`, the plugin will use the optimal `Get` function, otherwise the `List` function, to call the corresponding APIs. Either way, the same API response matches the schema declared in `Columns`.


```go
type Artifact struct {
	ID                 *int64               `json:"id,omitempty"`
	NodeID             *string              `json:"node_id,omitempty"`
	Name               *string              `json:"name,omitempty"`
	SizeInBytes        *int64               `json:"size_in_bytes,omitempty"`
	URL                *string              `json:"url,omitempty"`
	ArchiveDownloadURL *string              `json:"archive_download_url,omitempty"`
	Expired            *bool                `json:"expired,omitempty"`
	CreatedAt          *Timestamp           `json:"created_at,omitempty"`
	UpdatedAt          *Timestamp           `json:"updated_at,omitempty"`
	ExpiresAt          *Timestamp           `json:"expires_at,omitempty"`
	WorkflowRun        *ArtifactWorkflowRun `json:"workflow_run,omitempty"`
}
```



#### When Steampipe calls `List` vs `Get`

Which function is called when you query the `github_actions_artifact` table? It depends! We can use [diagnostic mode](https://steampipe.io/docs/guides/limiter#exploring--troubleshooting-with-diagnostic-mode) to explore. This query, which lists all the artifacts in a repo, uses the `List` function `tableGitHubArtifactList`.

```
 STEAMPIPE_DIAGNOSTIC_LEVEL=all  steampipe service start

 > select jsonb_pretty(_ctx) from github_actions_artifact 
   where repository_full_name = 'turbot/steampipe-plugin-github'
+----------------------------------------------------------------+
| jsonb_pretty                                                   |
+----------------------------------------------------------------+
| {                                                              |
|     "steampipe": {                                             |
|         "sdk_version": "5.8.0"                                 |
|     },                                                         |
|     "diagnostics": {                                           |
|         "calls": [                                             |
|             {                                                  |
|                 "type": "list",                                |
|                 "scope_values": {                              |
|                     "table": "github_actions_artifact",        |
|                     "connection": "github",                    |
|                     "function_name": "tableGitHubArtifactList" |
|                 },                                             |
|                 "function_name": "tableGitHubArtifactList",    |
|                 "rate_limiters": [                             |
|                 ],                                             |
|                 "rate_limiter_delay_ms": 0                     |
|             }                                                  |
|         ]                                                      |
|     },                                                         |
|     "connection_name": "github"                                |
| }                                                              |
```

This query, which uses the qualifier `id`, uses the `Get` function `tableGitHubArtifactGet`. 

```
> select jsonb_pretty(_ctx) from github_actions_artifact where id = '1248325644' and repository_full_name = 'turbot/steampipe-plugin-github'
+---------------------------------------------------------------+
| jsonb_pretty                                                  |
+---------------------------------------------------------------+
| {                                                             |
|     "steampipe": {                                            |
|         "sdk_version": "5.8.0"                                |
|     },                                                        |
|     "diagnostics": {                                          |
|         "calls": [                                            |
|             {                                                 |
|                 "type": "get",                                |
|                 "scope_values": {                             |
|                     "table": "github_actions_artifact",       |
|                     "connection": "github",                   |
|                     "function_name": "tableGitHubArtifactGet" |
|                 },                                            |
|                 "function_name": "tableGitHubArtifactGet",    |
|                 "rate_limiters": [                            |
|                 ],                                            |
|                 "rate_limiter_delay_ms": 0                    |
|             }                                                 |
|         ]                                                     |
|     },                                                        |
|     "connection_name": "github"                               |
| }                                                             |
+---------------------------------------------------------------+
```

This works because `id` is one of the `KeyColumns` in the `Get` property of the table definition. That enables the [Steampipe plugin SDK](https://github.com/turbot/steampipe-plugin-sdk) to choose the more optimal `tableGitHubArtifactGet` function when the `id` is known and it isn't necessary to list all artifacts in order to retrieve just a single one.

### List or Get in Combination with Hydrate

In addition to to the special `List` and `Get` hydrate functions, there's a class of general hydrate functions that enrich what's returned by `List` or `Get`.  In `table_aws_cloudtrail_trail.go`, [getCloudTrailStatus](https://github.com/turbot/steampipe-plugin-aws/blob/40058d8fd15a677214cfa3e22de35cde707775e7/aws/table_aws_cloudtrail_trail.go#L329-L369) is an example of this kind of function.

Steampipe knows it's a `HydrateFunc` because the table definition declares it in the [HydrateConfig](https://github.com/turbot/steampipe-plugin-aws/blob/40058d8fd15a677214cfa3e22de35cde707775e7/aws/table_aws_cloudtrail_trail.go#L42-L46) property of the table definition.

```go
  HydrateConfig: []plugin.HydrateConfig{
    {
      Func: getCloudtrailTrailStatus,
      Tags: map[string]string{"service": "cloudtrail", "action": "GetTrailStatus"},
    },
    ...
  },
```


A `HydrateFunc` is typically used in combination with `List` or `Get`.

For example, the `List` function for `table_aws_fms_app_list.go` uses the SDK's [NewListAppsListsPaginator](https://pkg.go.dev/github.com/aws/aws-sdk-go-v2/service/fms@v1.24.3#NewListAppsListsPaginator) to get [basic info](https://github.com/turbot/steampipe-plugin-aws/blob/40058d8fd15a677214cfa3e22de35cde707775e7/aws/table_aws_fms_app_list.go#L43-L60) declared in the `Columns` property of the table definition.

```go
{
	Name:        "list_name",
	Description: "The name of the applications list.",
	Type:        proto.ColumnType_STRING,
	Transform:   transform.FromField("ListName", "AppsList.ListName"),
},
{
	Name:        "list_id",
	Description: "The ID of the applications list.",
	Type:        proto.ColumnType_STRING,
	Transform:   transform.FromField("ListId", "AppsList.ListId"),
},
{
	Name:        "arn",
	Description: "The Amazon Resource Name (ARN) of the applications list.",
	Type:        proto.ColumnType_STRING,
	Transform:   transform.FromField("ListArn", "AppsListArn"),
},
```

These correspond to the type [AppsListDataSummary](https://pkg.go.dev/github.com/aws/aws-sdk-go-v2/service/fms@v1.24.3/types#AppsListDataSummary) in the AWS SDK.

The `Columns` property also declares [four other columns](https://github.com/judell/steampipe-plugin-aws/blob/HEAD/aws/table_aws_fms_app_list.go#L61-L90) that use the `HydrateFunc` called [getFMSAppList](https://github.com/judell/steampipe-plugin-aws/blob/40058d8fd15a677214cfa3e22de35cde707775e7/aws/table_aws_fms_app_list.go#L164-L204).

```go
{
	Name:        "create_time",
	Description: "The time that the Firewall Manager applications list was created.",
	Type:        proto.ColumnType_TIMESTAMP,
	Hydrate:     getFmsAppList,
},
{
	Name:        "last_update_time",
	Description: "The time that the Firewall Manager applications list was last updated.",
	Type:        proto.ColumnType_TIMESTAMP,
	Hydrate:     getFmsAppList,
},
{
	Name:        "list_update_token",
	Description: "A unique identifier for each update to the list. When you update the list, the update token must match the token of the current version of the application list.",
	Type:        proto.ColumnType_STRING,
	Hydrate:     getFmsAppList,
},
{
	Name:        "previous_apps_list",
	Description: "A map of previous version numbers to their corresponding App object arrays.",
	Type:        proto.ColumnType_JSON,
	Hydrate:     getFmsAppList,
},
{
	Name:        "apps_list",
	Description: "An array of applications in the Firewall Manager applications list.",
	Type:        proto.ColumnType_JSON,
	Hydrate:     getFmsAppList,
},
```

Those columns correspond to fields of the type [AppsListData](https://github.com/aws/aws-sdk-go-v2/blob/8d9a27a085ae3d026a8fa910d30d7eb51221ab15/service/fms/types/types.go#L137-L167) in the AWS SDK. 

```go
type AppsListData struct {

	// An array of applications in the Firewall Manager applications list.
	//
	// This member is required.
	AppsList []App

	// The name of the Firewall Manager applications list.
	//
	// This member is required.
	ListName *string

	// The time that the Firewall Manager applications list was created.
	CreateTime *time.Time

	// The time that the Firewall Manager applications list was last updated.
	LastUpdateTime *time.Time

	// The ID of the Firewall Manager applications list.
	ListId *string

	// A unique identifier for each update to the list. When you update the list, the
	// update token must match the token of the current version of the application
	// list. You can retrieve the update token by getting the list.
	ListUpdateToken *string

	// A map of previous version numbers to their corresponding App object arrays.
	PreviousAppsList map[string][]App
}
```

### HydrateConfig

Use `HydrateConfig` in a table definition to provide granular control over the behavior of a hydrate function. 

Things you can control with a `HydrateConfig`:

  - Errors to ignore.

  - Errors to retry.

  - Max concurrent calls to allow.

  - Hydrate dependencies

  - Rate-limiter tags


For a `Get` or `List`, you can specify errors to ignore and/or retry using `DefaultIgnoreConfig` and `DefaultRetryConfig` as seen here in [the Fastly plugin](https://github.com/turbot/steampipe-plugin-fastly/blob/550922bae7bc066e12ddd7634d96c9dd33374eed/fastly/plugin.go#L20-L22).

```go
func Plugin(ctx context.Context) *plugin.Plugin {
	p := &plugin.Plugin{
		Name: "steampipe-plugin-fastly",
		ConnectionConfigSchema: &plugin.ConnectionConfigSchema{
			NewInstance: ConfigInstance,
		},
		DefaultTransform: transform.FromGo().NullIfZero(),
		DefaultIgnoreConfig: &plugin.IgnoreConfig{
			ShouldIgnoreErrorFunc: shouldIgnoreErrors([]string{"404"}),
		},
		DefaultRetryConfig: &plugin.RetryConfig{
			ShouldRetryErrorFunc: shouldRetryError([]string{"429"}),
		},
		TableMap: map[string]*plugin.Table{
			"fastly_acl":             tableFastlyACL(ctx),
             ...
     		"fastly_token":           tableFastlyToken(ctx),
		},
	}
	return p
}
```

For other hydrate functions, you do this with `HydrateConfig`. Here's how the `oci_identity_tenancy` table [configures error handling](https://github.com/turbot/steampipe-plugin-oci/blob/4403adee869853b3d205e8d93681af0859870701/oci/table_oci_identity_tenancy.go#L23-28) for the `getRetentionPeriod` function. 

```go
		HydrateConfig: []plugin.HydrateConfig{
			{
				Func:              getRetentionPeriod,
				ShouldIgnoreError: isNotFoundError([]string{"404"}),
			},
		},
```

You can similarly use `ShouldRetryError` along with a corresponding function that returns true if, for example, an API call its a rate limit.

```go
func shouldRetryError(err error) bool {
	if cloudflareErr, ok := err.(*cloudflare.APIRequestError); ok {
		return cloudflareErr.ClientRateLimited()
	}
	return false
}
```

You can likewise use `MaxConcurrency` to limit the number of calls to a hydrate function.

In practice, the granular controls afforded by `ShouldIgnoreError`, `ShouldRetryError`, and `MaxConcurrency` are not much used at the level of individual hydrate functions. Plugins are likelier to assert such control globally. But the flexibility is threre if you need it.


Two features of `HydrateConfig` that are used quite a bit are `Depends` and `Tags`.

Use `Depends` to make a function depend on one or more others. In `aws_s3_bucket`, the function [getBucketLocation](https://github.com/turbot/steampipe-plugin-aws/blob/66bd381dfaccd3d16ccedba660cd05adaa17c7d7/aws/table_aws_s3_bucket.go#L399-L440) returns the client region that's needed by all the other functions, so they all [depend on it](https://github.com/turbot/steampipe-plugin-aws/blob/66bd381dfaccd3d16ccedba660cd05adaa17c7d7/aws/table_aws_s3_bucket.go#L27-L102).

```go
		HydrateConfig: []plugin.HydrateConfig{
			{
				Func: getBucketLocation,
				Tags: map[string]string{"service": "s3", "action": "GetBucketLocation"},
			},
			{
				Func:    getBucketIsPublic,
				Depends: []plugin.HydrateFunc{getBucketLocation},
				Tags:    map[string]string{"service": "s3", "action": "GetBucketPolicyStatus"},
			},
			{
				Func:    getBucketVersioning,
				Depends: []plugin.HydrateFunc{getBucketLocation},
				Tags:    map[string]string{"service": "s3", "action": "GetBucketVersioning"},
			},
```


Use `Tags` to expose a hydrate function to control by a limiter. In AWS plugin's, `aws_config_rule` table, the `HydrateConfig` specifies [additional hydrate functions](https://github.com/turbot/steampipe-plugin-aws/blob/66bd381dfaccd3d16ccedba660cd05adaa17c7d7/aws/table_aws_config_rule.go#L40-L49) that fetch tags and compliance details for each config rule.

```go
HydrateConfig:plugin.HydrateConfig{
	{
		Func: getConfigRuleTags,
		Tags: map[string]string{"service": "config", "action": "ListTagsForResource"},
	},
	{
		Func: getComplianceByConfigRules,
		Tags: map[string]string{"service": "config", "action": "DescribeComplianceByConfigRule"},
	},
},
```

In this example the `Func` property names `getConfigRuleTags` and `getComplianceByConfigRules` as additional hydrate functions that fetch tags and compliance details for each config rule, respectively. The `Tags` property enables a rate limiter to [target these functions](https://steampipe.io/docs/guides/limiter#function-tags).

### Memoize: Caching hydrate results

The [Memoize](https://github.com/judell/steampipe-plugin-sdk/blob/HEAD/plugin/hydrate_cache.go#L61-L139) function can be used to cache the results of a `HydrateFunc`. 

 In the [multi_region.go](https://github.com/turbot/steampipe-plugin-aws/blob/main/aws/multi_region.go) file of `steampipe-plugin-aws` repository, the `listRegionsForServiceCacheKey` function is used to create a custom cache key for the `listRegionsForService` function. This cache key includes the service ID, which is unique for each AWS service.

Here's a simplified version of the code:

```go
func listRegionsForServiceCacheKey(ctx context.Context, d *plugin.QueryData, h *plugin.HydrateData) (interface{}, error) {
	serviceID := h.Item.(string)
	key := fmt.Sprintf("listRegionsForService-%s", serviceID)
	return key, nil
}

var listRegionsForService = plugin.HydrateFunc(listRegionsForServiceUncached).Memoize(memoize.WithCacheKeyFunction(listRegionsForServiceCacheKey))
```

In this example, `Memoize` caches the results of `listRegionsForServiceUncached`. The `WithCacheKeyFunction` option specifies a custom function (`listRegionsForServiceCacheKey`) to generate the cache key. This function takes the service ID from the hydrate data and includes it in the cache key, ensuring a unique cache key for each AWS service.

This is a common pattern when using `Memoize`: you define a `HydrateFunc` and then wrap it with `Memoize` to enable caching. You can also use the `WithCacheKeyFunction` option to specify a custom function that generates the cache key, which is especially useful when you need to include additional context in the cache key.


### Transform Functions

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

### Translating SQL Operators to API Calls

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


### Example: Table Definition File

```go
package zendesk

import (
	"context"

	"github.com/nukosuke/go-zendesk/zendesk"

	"github.com/turbot/steampipe-plugin-sdk/grpc/proto"
	"github.com/turbot/steampipe-plugin-sdk/plugin"
)

func tableZendeskUser() *plugin.Table {
	return &plugin.Table{
		Name:        "zendesk_user",
		Description: "Zendesk Support has three types of users: end users (your customers), agents, and administrators.",
		List: &plugin.ListConfig{
			Hydrate: listUser,
		},
		Get: &plugin.GetConfig{
			KeyColumns: plugin.SingleColumn("id"),
			Hydrate:    getUser,
		},
		Columns: []*plugin.Column{
			{Name: "active", Type: proto.ColumnType_BOOL, Description: "False if the user has been deleted"},
			{Name: "alias", Type: proto.ColumnType_STRING, Description: "An alias displayed to end users"},
			{Name: "chat_only", Type: proto.ColumnType_BOOL, Description: "Whether or not the user is a chat-only agent"},
			{Name: "created_at", Type: proto.ColumnType_TIMESTAMP, Description: "The time the user was created"},
			{Name: "custom_role_id", Type: proto.ColumnType_INT, Description: "A custom role if the user is an agent on the Enterprise plan"},
			{Name: "default_group_id", Type: proto.ColumnType_INT, Description: "The id of the user's default group"},
			{Name: "details", Type: proto.ColumnType_STRING, Description: "Any details you want to store about the user, such as an address"},
			{Name: "email", Type: proto.ColumnType_STRING, Description: "The user's primary email address. *Writeable on create only. On update, a secondary email is added."},
			{Name: "external_id", Type: proto.ColumnType_STRING, Description: "A unique identifier from another system. The API treats the id as case insensitive. Example: \"ian1\" and \"Ian1\" are the same user"},
			{Name: "id", Type: proto.ColumnType_INT, Description: "Automatically assigned when the user is created"},
			{Name: "last_login_at", Type: proto.ColumnType_TIMESTAMP, Description: "The last time the user signed in to Zendesk Support"},
			{Name: "locale", Type: proto.ColumnType_STRING, Description: "The user's locale. A BCP-47 compliant tag for the locale. If both \"locale\" and \"locale_id\" are present on create or update, \"locale_id\" is ignored and only \"locale\" is used."},
			{Name: "locale_id", Type: proto.ColumnType_INT, Description: "The user's language identifier"},
			{Name: "moderator", Type: proto.ColumnType_BOOL, Description: "Designates whether the user has forum moderation capabilities"},
			{Name: "name", Type: proto.ColumnType_STRING, Description: "The user's name"},
			{Name: "notes", Type: proto.ColumnType_STRING, Description: "Any notes you want to store about the user"},
			{Name: "only_private_comments", Type: proto.ColumnType_BOOL, Description: "true if the user can only create private comments"},
			{Name: "organization_id", Type: proto.ColumnType_INT, Description: "The id of the user's organization. If the user has more than one organization memberships, the id of the user's default organization"},
			{Name: "phone", Type: proto.ColumnType_STRING, Description: "The user's primary phone number."},
			{Name: "photo_content_type", Type: proto.ColumnType_STRING, Description: "The content type of the image. Example value: \"image/png\""},
			{Name: "photo_content_url", Type: proto.ColumnType_STRING, Description: "A full URL where the attachment image file can be downloaded"},
			{Name: "photo_deleted", Type: proto.ColumnType_STRING, Description: "If true, the attachment has been deleted"},
			{Name: "photo_file_name", Type: proto.ColumnType_STRING, Description: "The name of the image file"},
			{Name: "photo_id", Type: proto.ColumnType_INT, Description: "Automatically assigned when created"},
			{Name: "photo_inline", Type: proto.ColumnType_BOOL, Description: "If true, the attachment is excluded from the attachment list and the attachment's URL can be referenced within the comment of a ticket. Default is false"},
			{Name: "photo_size", Type: proto.ColumnType_INT, Description: "The size of the image file in bytes"},
			{Name: "photo_thumbnails", Type: proto.ColumnType_JSON, Description: "An array of attachment objects. Note that photo thumbnails do not have thumbnails"},
			{Name: "report_csv", Type: proto.ColumnType_BOOL, Description: "Whether or not the user can access the CSV report on the Search tab of the Reporting page in the Support admin interface."},
			{Name: "restricted_agent", Type: proto.ColumnType_BOOL, Description: "If the agent has any restrictions; false for admins and unrestricted agents, true for other agents"},
			{Name: "role", Type: proto.ColumnType_STRING, Description: "The user's role. Possible values are \"end-user\", \"agent\", or \"admin\""},
			{Name: "role_type", Type: proto.ColumnType_INT, Description: "The user's role id. 0 for custom agents, 1 for light agent, 2 for chat agent, and 3 for chat agent added to the Support account as a contributor (Chat Phase 4)"},
			{Name: "shared", Type: proto.ColumnType_BOOL, Description: "If the user is shared from a different Zendesk Support instance. Ticket sharing accounts only"},
			{Name: "shared_agent", Type: proto.ColumnType_BOOL, Description: "If the user is a shared agent from a different Zendesk Support instance. Ticket sharing accounts only"},
			{Name: "shared_phone_number", Type: proto.ColumnType_BOOL, Description: "Whether the phone number is shared or not."},
			{Name: "signature", Type: proto.ColumnType_STRING, Description: "The user's signature. Only agents and admins can have signatures"},
			{Name: "suspended", Type: proto.ColumnType_BOOL, Description: "If the agent is suspended. Tickets from suspended users are also suspended, and these users cannot sign in to the end user portal"},
			{Name: "tags", Type: proto.ColumnType_JSON, Description: "The user's tags. Only present if your account has user tagging enabled"},
			{Name: "ticket_restriction", Type: proto.ColumnType_STRING, Description: "Specifies which tickets the user has access to. Possible values are: \"organization\", \"groups\", \"assigned\", \"requested\", null"},
			{Name: "timezone", Type: proto.ColumnType_STRING, Description: "The user's time zone."},
			{Name: "two_factor_auth_enabled", Type: proto.ColumnType_BOOL, Description: "If two factor authentication is enabled"},
			{Name: "updated_at", Type: proto.ColumnType_TIMESTAMP, Description: "The time the user was last updated"},
			{Name: "url", Type: proto.ColumnType_STRING, Description: "The user's API url"},
			{Name: "user_fields", Type: proto.ColumnType_JSON, Description: "Values of custom fields in the user's profile."},
			{Name: "verified", Type: proto.ColumnType_BOOL, Description: "Any of the user's identities is verified."},
		},
	}
}

func listUser(ctx context.Context, d *plugin.QueryData, _ *plugin.HydrateData) (interface{}, error) {
	conn, err := connect(ctx)
	if err != nil {
		return nil, err
	}
	opts := &zendesk.UserListOptions{
		PageOptions: zendesk.PageOptions{
			Page:    1,
			PerPage: 100,
		},
	}
	for true {
		users, page, err := conn.GetUsers(ctx, opts)
		if err != nil {
			return nil, err
		}
		for _, t := range users {
			d.StreamListItem(ctx, t)
		}
		if !page.HasNext() {
			break
		}
		opts.Page++
	}
	return nil, nil
}

func getUser(ctx context.Context, d *plugin.QueryData, h *plugin.HydrateData) (interface{}, error) {
	conn, err := connect(ctx)
	if err != nil {
		return nil, err
	}
	quals := d.KeyColumnQuals
	plugin.Logger(ctx).Warn("getUser", "quals", quals)
	id := quals["id"].GetInt64Value()
	plugin.Logger(ctx).Warn("getUser", "id", id)
	result, err := conn.GetUser(ctx, id)
	if err != nil {
		return nil, err
	}
	return result, nil
}
```

### Dynamic Tables

In the plugin definition, if `SchemaMode` is set to `dynamic`, every time
Steampipe starts, the plugin's schema will be checked for any changes since the
last time it loaded, and re-import the schema if it detects any.

Dynamic tables are useful when you are building a plugin whose schema is not
known at compile time; instead, its schema will be generated at runtime. For
instance, a plugin with dynamic tables is useful if you want to load CSV files
as tables from one or more directories. Each of these CSV files may have
different column structures, resulting in a different structure for each table.

In order to create a dynamic table, in the plugin definition, `TableMapFunc`
should call a function that returns `map[string]*plugin.Table`.

For instance, in the [CSV plugin](https://hub.steampipe.io/plugins/turbot/csv):

```go
func Plugin(ctx context.Context) *plugin.Plugin {
	p := &plugin.Plugin{
		Name: "steampipe-plugin-csv",
		ConnectionConfigSchema: &plugin.ConnectionConfigSchema{
			NewInstance: ConfigInstance,
			Schema:      ConfigSchema,
		},
		DefaultTransform: transform.FromGo().NullIfZero(),
		SchemaMode:       plugin.SchemaModeDynamic,
		TableMapFunc:     PluginTables,
	}
	return p
}

func PluginTables(ctx context.Context, p *plugin.Plugin) (map[string]*plugin.Table, error) {
	// Initialize tables
	tables := map[string]*plugin.Table{}

	// Search for CSV files to create as tables
	paths, err := csvList(ctx, p)
	if err != nil {
		return nil, err
	}
	for _, i := range paths {
		tableCtx := context.WithValue(ctx, "path", i)
		base := filepath.Base(i)
    // tableCSV returns a *plugin.Table type
		tables[base[0:len(base)-len(filepath.Ext(base))]] = tableCSV(tableCtx, p)
	}

	return tables, nil
}
```

The `tableCSV` function mentioned in the example above looks for all CSV files in the configured paths, and for each one, builds a `*plugin.Table` type:

```go
func tableCSV(ctx context.Context, p *plugin.Plugin) *plugin.Table {

	path := ctx.Value("path").(string)
	csvFile, err := os.Open(path)
	if err != nil {
		plugin.Logger(ctx).Error("Could not open CSV file", "path", path)
		panic(err)
	}

	r := csv.NewReader(csvFile)

	csvConfig := GetConfig(p.Connection)
	if csvConfig.Separator != nil && *csvConfig.Separator != "" {
		r.Comma = rune((*csvConfig.Separator)[0])
	}
	if csvConfig.Comment != nil {
		if *csvConfig.Comment == "" {
			// Disable comments
			r.Comment = 0
		} else {
			// Set the comment character
			r.Comment = rune((*csvConfig.Comment)[0])
		}
	}

	// Read the header to peak at the column names
	header, err := r.Read()
	if err != nil {
		plugin.Logger(ctx).Error("Error parsing CSV header:", "path", path, "header", header, "err", err)
		panic(err)
	}
	cols := []*plugin.Column{}
	for idx, i := range header {
		cols = append(cols, &plugin.Column{Name: i, Type: proto.ColumnType_STRING, Transform: transform.FromField(i), Description: fmt.Sprintf("Field %d.", idx)})
	}

	return &plugin.Table{
		Name:        path,
		Description: fmt.Sprintf("CSV file at %s", path),
		List: &plugin.ListConfig{
			Hydrate: listCSVWithPath(path),
		},
		Columns: cols,
	}
}
```

The end result is when using the CSV plugin, whenever Steampipe starts, it will
check for any new, deleted, and modified CSV files in the configured `paths`
and create any discovered CSVs as tables. The CSV filenames are turned directly
into table names.

For more information on how the CSV plugin can be queried as a result of being
a dynamic table, please see the
[{csv_filename}](https://hub.steampipe.io/plugins/turbot/csv/tables/%7Bcsv_filename%7D)
table document.


## Client-Side Rate Limiting

The Steampipe Plugin SDK supports a [client-side rate limiting implementation](/docs/guides/limiter) to allow users to define [plugin `limiter` blocks](/docs/reference/config-files/plugin#limiter) to control concurrency and rate limiting.  Support for limiters is built in to the SDK and basic functionality requires no changes to the plugin code;  Just including the SDK will enable users to create limiters for your plugin using the built in `connection`, `table`, and `function_name` scopes.  You can add additional flexibility by adding [function tags](#function-tags) and by [accounting for paging in List calls](#accounting-for-paged-list-calls).

## Function Tags

Hydrate function tags provide useful diagnostic metadata, and they can also be used as scopes in rate limiters.  Rate limiting requirements vary by plugin because the underlying APIs that they access implement rate limiting differently.  Tags provide a way for a plugin author to scope rate limiters in a way that aligns with the API implementation.

Tags can be added to a ListConfig, GetConfig, or HydrateConfig.

```go
//// TABLE DEFINITION
func tableAwsSnsTopic(_ context.Context) *plugin.Table {
	return &plugin.Table{
		Name:        "aws_sns_topic",
		Description: "AWS SNS Topic",
		Get: &plugin.GetConfig{
			KeyColumns: plugin.SingleColumn("topic_arn"),
			IgnoreConfig: &plugin.IgnoreConfig{
				ShouldIgnoreErrorFunc: shouldIgnoreErrors([]string{"NotFound", "InvalidParameter"}),
			},
			Hydrate: getTopicAttributes,
			Tags:    map[string]string{"service": "sns", "action": "GetTopicAttributes"},
		},
		List: &plugin.ListConfig{
			Hydrate: listAwsSnsTopics,
			Tags:    map[string]string{"service": "sns", "action": "ListTopics"},
		},

		HydrateConfig: []plugin.HydrateConfig{
			{
				Func: listTagsForSnsTopic,
				Tags: map[string]string{"service": "sns", "action": "ListTagsForResource"},
			},
			{
				Func: getTopicAttributes,
				Tags: map[string]string{"service": "sns", "action": "GetTopicAttributes"},
			},
		},
    ...
```

Once the tags are added to the plugin, you can use them in the `scope` and `where` arguments for your rate limiter.

```hcl
plugin "aws" {
  limiter "sns_get_topic_attributes_us_east_1" {
    bucket_size  = 3000
    fill_rate    = 3000

    scope  = ["connection", "region", "service", "action"]
    where  = "action = 'GetTopicAttributes' and service = 'sns' and region = 'us-east-1' "
  }
}
```

## Accounting for Paged List Calls
The Steampipe plugin SDK transparently handles most of the details around waiting for limiters.  List calls, however, usually iterate through pages of results, and each call to fetch a page must wait for any limiters that are defined.  The SDK provides a hook, `WaitForListRateLimit`, which should be called before paging to apply rate limiting to the list call:

```go
// List call
for paginator.HasMorePages() {

  // apply rate limiting
  d.WaitForListRateLimit(ctx)

  output, err := paginator.NextPage(ctx)
  if err != nil {
    plugin.Logger(ctx).Error("List error", "api_error", err)
    return nil, err
  }
  for _, items := range output.Items {
    d.StreamListItem(ctx, items)

    // Context can be cancelled due to manual cancellation or the limit has been hit
    if d.RowsRemaining(ctx) == 0 {
      return nil, nil
    }
  }
}
```

---

## Logging

A logger is passed to the plugin via the context.  You can use the logger to write messages to the log at standard log levels:
```go
logger := plugin.Logger(ctx)
logger.Info("Log message and a variable", myVariable)
```

The plugin logs do not currently get written to the console, but are written to the plugin logs at `~/.steampipe/logs/plugin-YYYY-MM-DD.log`, e.g., `~/.steampipe/logs/plugin-2022-01-01.log`.

Steampipe uses the <a href="https://github.com/hashicorp/go-hclog" target="_blank" rel="noopener noreferrer">hclog package</a>, which uses standard log levels (`TRACE`, `DEBUG`, `INFO`, `WARN`, `ERROR`). By default, the log level is `WARN`.  You set it using the `STEAMPIPE_LOG_LEVEL` environment variable:
```bash
export STEAMPIPE_LOG_LEVEL=TRACE
```

---

## Installing and Testing Your Plugin

A plugin binary can be installed manually, and this is often convenient when developing the plugin. Steampipe will attempt to load any plugin that is referred to in a `connection` configuration:
- The plugin binary file must have a `.plugin` extension
- The plugin binary must reside in a subdirectory of the `~/.steampipe/plugins/local/` directory and must be the ONLY `.plugin` file in that subdirectory
- The `connection` must specify the path (relative to `~/.steampipe/plugins/`) to the plugin in the `plugin` argument

For example, consider a `myplugin` plugin that you have developed.  To install it:
- Create a subdirectory `.steampipe/plugins/local/myplugin`
- Name your plugin binary `myplugin.plugin`, and copy it to `.steampipe/plugins/local/myplugin/myplugin.plugin`
- Create a `~/.steampipe/config/myplugin.spc` config file containing a connection definition that points to your plugin:
    ```hcl
    connection "myplugin" {
        plugin    = "local/myplugin"
    }
    ```
- Your connection will be loaded the next time Steampipe runs.  If Steampipe is running service mode, you must restart it to load the connection.

---
