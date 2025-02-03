---
title: The Basics
sidebar_label: The Basics
---


## main.go

The `main` function in then `main.go` is the entry point for your plugin.  This function must call `plugin.Serve` from the plugin sdk to instantiate your plugin gRPC server.  You will pass the plugin function that you will create in the [plugin.go](#plugingo) file.


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

## plugin.go

The `plugin.go` file should implement a single [Plugin Definition](#plugin-definition) (`Plugin()` function) that returns a pointer to a `Plugin` to be loaded by the gRPC server.

By convention, the package name for your plugin should be the same name as your plugin, and go files for your plugin (except `main.go`) should reside in a folder with the same name.

## Plugin Definition

| Argument | Description
|-|-
| `Name`             | The name of the plugin (`steampipe-plugin-{plugin name}`).
| `TableMap`         | A map of table names to [Table definitions](#table-definition).
| `DefaultTransform` | A default [Transform Function](/docs/develop/writing_plugins/transform-functions) to be used when one is not specified.  While not required, this may save quite a bit of repeated code.
| `DefaultGetConfig` | Provides an optional mechanism for providing plugin-level defaults to a get config.  This is merged with the GetConfig defined in the table and/or columns. Typically, this is used to standardize error handling with `ShouldIgnoreError`.
| `SchemaMode`       | Specifies if the schema should be checked and re-imported if changed every time Steampipe starts. This can be set to `dynamic` or `static`. Defaults to `static`.
| `RequiredColumns`  | An optional list of columns that ALL tables in this plugin MUST implement.

### Example Plugin Definition

Here's the definition of the [Zendesk](https://github.com/turbot/steampipe-plugin-zendesk/blob/33c9cb30826c41d75c7d07d1947e2fd9fd5735d1/zendesk/plugin.go#L10-L29) plugin.

```go
package zendesk

import (
	"context"

	"github.com/turbot/steampipe-plugin-sdk/v5/plugin"
	"github.com/turbot/steampipe-plugin-sdk/v5/plugin/transform"
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


## Table Definition

The `plugin.Table` may specify:

| Argument | Description
|-|-
| `Name` | The name of the table.
| `Description` | A short description, added as a comment on the table and used in help commands and documentation.
| `Columns`  | An array of [column definitions](#column-definition).
| `List` | A [List Config](#list-config) definition, used to fetch the data items used to build all rows of a table.
| `Get` | A [Get Config](#get-config) definition, used to fetch a single item.
| `DefaultTransform` |  A default [transform function](/docs/develop/writing_plugins/transform-functions) to be used when one is not specified.  If set, this will override the default set in the plugin definition.

### Example Table Definition

Here's how the [zendesk_user](https://github.com/turbot/steampipe-plugin-zendesk/blob/33c9cb30826c41d75c7d07d1947e2fd9fd5735d1/zendesk/table_zendesk_user.go#L12-L70) table is defined.

```go
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
```


## List Config

A ListConfig definition defines how to list all rows of a table.

| Argument | Description
|-|-
| `KeyColumns` | An optional list of columns that require a qualifier in order to list data for this table.
| `Hydrate` | A [hydrate function](/docs/develop/writing_plugins/hydrate-functions) which is called first when performing a 'list' call.
| `ParentHydrate` | An optional parent list function - if you list items with a parent-child relationship, this will list the parent items.

## Get Config

A GetConfig definition defines how to get a single row of a table.

| Argument | Description
|-|-
| `KeyColumns` | A list of keys which are used to uniquely identify rows - used to determine whether a query is a 'get' call.
| `ItemFromKey [DEPRECATED]`] | This property is deprecated.
| `Hydrate` | A [hydrate function](/docs/develop/writing_plugins/hydrate-functions) which is called first when performing a 'get' call. If this returns 'not found', no further hydrate functions are called.
| `ShouldIgnoreError` | A function which will return whether to ignore a given error.

## Column Definition

A column definition definition specifies the name and description of the column, its data type, and the functions to call to hydrate the column (if the list call does not) and transform it (if the default transformation is not sufficient).

| Argument | Description
|-|-
| `Name` | The column name.
| `Type` | The [data type](#column-data-types) for this column.
| `Description` | The column description, added as a comment and used in help commands and documentation.
| `Hydrate` | You can explicitly specify the [hydrate function](/docs/develop/writing_plugins/hydrate-functions) function to populate this column. This is only needed if neither the default hydrate functions nor the `List` function return data for this column.
| `Default` | An optional default column value.
| `Transform` | An optional chain of [transform functions](/docs/develop/writing_plugins/transform-functions) to generate the column value.

## Column Data Types

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
