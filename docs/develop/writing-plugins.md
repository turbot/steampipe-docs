---
title: Writing Plugins
sidebar_label:  Writing Plugins
---

# Writing Plugins

The <a href="https://github.com/turbot/steampipe-plugin-sdk" target="_blank" rel="noopener noreferrer">Steampipe Plugin SDK</a> makes writing tables fast, easy, and fun!  Most of the heavy lifting is taken care of for you - just define your tables and columns, wire up a few API calls, and you can start to query your service with standard SQL!

While this document will provide an introduction and some examples, note that Steampipe is an evolving, open source project - refer to the code as the authoritative source, as well as for real-world examples.

Also, please try to be a good community citizen - following the <a href="/docs/develop/standards" target="_blank" rel="noopener">standards</a> makes for a better, more consistent experience for end-users and developers alike.

Let's get started!

- [main.go](#maingo)
- [plugin.go](#plugingo)
- [Implementing Tables](#implementing-tables)
- [Logging](#logging)
- [Installing and Testing Your Plugin](#installing-and-testing-your-plugin)

----

## main.go

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

----

## plugin.go

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

## Implementing Tables

By convention, each table should be implemented in a separate file named `table_{table name}.go`.  Each table will have a single table definition function that returns a pointer to a `plugin.Table` (this is the function specified in the `TableMap` of the [plugin definition](#plugin-definition)).  The function name is typically the table name in camel case (per golang standards) prefixed by `table`.

The table definition specifies the name and description of the table, a list of column definitions, and the functions to call in order to list the data for all the rows, or to get data for a single row.

When a connection is created, Steampipe uses the table and column definitions to create the Postgres foreign tables, however the tables don't store the data - the data is populated (hydrated) when a query is run.

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

### Hydrate Functions

The purpose of a hydrate function is to connect to an external system or service and gather data for the table.

`Get` and `List` are special hydrate functions defined in the the [Table Definition](#table-definition) that have some specific considerations:
- Every table ***must*** define a `List` and/or `Get` function.
- The `List` or `Get` will always be called before any other hydrate function in the table, as the other functions typically depend on the result of the Get of List call.
- Whether `List` or `Get` is called depends upon whether the qualifiers (in `where` clauses and `join...on`) match the `KeyColumns` defined in the [Get Config](#get-config).  This allows steampipe to fetch only the "row" data that it needs.
- Typically, hydrate functions return a single data item (data for a single row).  *List functions are an exception* - they stream data for multiple rows using the QueryData object, and return `nil`.
- The `Get` function will usually get the key column data from the `QueryData.KeyColumnQuals` so that it can get the appropriate item as based on the qualifiers (`where` clause, `join...on`).  If the `Get` hydrate function is used as both a `Get` function AND a normal hydrate function, you should get the key column data from the `HydrateData.Item` if it is not nil, and use the `QueryData.KeyColumnQuals` otherwise.

#### Hydrate Dependencies

Steampipe attempts to parallelize the hydrate functions as much as possible.  Sometimes, however, one hydrate function requires the output from another.  You can define `HydrateDependencies` for this case:

```go
return &plugin.Table{
		Name: "hydrate_columns_dependency",
		List: &plugin.ListConfig{
			Hydrate: hydrateList,
		},
		HydrateDependencies: []plugin.HydrateDependencies{
			{
				Func:    hydrate2,
				Depends: []plugin.HydrateFunc{hydrate1},
			},
		},
		Columns: []*plugin.Column{
			{Name: "id", Type: proto.ColumnType_INT},
			{Name: "hydrate_column_1", Type: proto.ColumnType_STRING, Hydrate: hydrate1},
			{Name: "hydrate_column_2", Type: proto.ColumnType_STRING, Hydrate: hydrate2},
		},
    }
```
Here, hydrate function `hydrate2` is dependent on `hydrate1`. This means `hydrate2` will not execute until `hydrate1` has completed and the results are available. `hydrate2` can refer to the results from `hydrate1` as follows:
```go
func hydrate2(ctx context.Context, d *plugin.QueryData, h *plugin.HydrateData) (interface{}, error) {
        // NOTE: in this case we know the output of hydrate1 is map[string]interface{} so we cast it accordingly.
        // the data should be cast to th appropriate type
	hydrate1Results := h.HydrateResults["hydrate1"].(map[string]interface{})
.....
}
```
 Note that:
 - Multiple dependencies are supported.
 - Circular dependencies will be detected and cause a validation failure.
 - The `Get` and `List` hydrate functions ***CANNOT*** have dependencies.

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

## Accounting for Paged List calls
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
