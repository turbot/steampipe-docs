---
title: About List, Get, and Hydrate Functions
sidebar_label: List, Get, and Hydrate
---

# About List, Get, and Other Hydrate Functions

This guide provides an overview of how `List`, `Get`, and other hydrate functions are used in Steampipe plugins. We'll look at examples from the `steampipe-plugin-github` and `steampipe-plugin-aws` to understand how these functions are used to define tables and fetch data from APIs, and how they relate to one another.

## A List Function

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


## Get Function

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
|      |                                                                                           |
|      | # Test binary, built with `go test -c`                                                    |
|      | *.test                                                                                    |
|      |                                                                                           |
|      | # Output of the go coverage tool, specifically when used with LiteIDE                     |
|      | *.out                                                                                     |
|      |                                                                                           |
|      | # Dependency directories (remove the comment below to include it)                         |
|      | # vendor/                                                                                 |
|      |                                                                                           |
|      | # Go workspace file                                                                       |
|      | go.work                                                                                   |
|      |                                                                                           |
+------+-------------------------------------------------------------------------------------------+
```

The `List` function finds all the names of the templates provided by GitHub, and the `Get` function adds the `source` column. 

### When the column definition doesn't need to specify a `Hydrate`

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

The SDK's [ListArtifacts](https://pkg.go.dev/github.com/google/go-github/v55@v55.0.0/github#ActionsService.ListArtifacts) returns an array of [Artifact](https://pkg.go.dev/github.com/google/go-github/v55@v55.0.0/github#Artifact) and its [GetArtifact](https://pkg.go.dev/github.com/google/go-github/v55@v55.0.0/github#ActionsService.GetArtifact) returns a single `Artifact`.

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

### When Steampipe calls `List` vs `Get`

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

## Other Hydrate Functions

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

### List or Get in Combination with Hydrate

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


