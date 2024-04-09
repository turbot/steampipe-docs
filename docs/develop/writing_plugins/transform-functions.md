---
title: Transform Functions
sidebar_label: Transform functions
---

# Transform Functions

Transform functions are used to extract and/or reformat data returned by a hydrate function into the desired type/format for a column.  You can call your own transform function with `From`, but you probably don't need to write one. The SDK provides functions to cover the most common cases.  You can chain transforms together, but the transform chain must begin with a `From` function:

| Name | Description
|-|-
| [FromConstant](#fromconstant) | Return a constant value (specified by 'param').
| [FromField](#fromfield) | Generate a value by retrieving a field from the source item.
| [FromValue](#fromvalue) | Generate a value by returning the raw hydrate item.
| [FromGo](#fromgo) | Generate a value by converting the given field name to camel case (more strictly: Pascal case) while respecting common initialisms like `ID`. 
| [FromCamel](#fromcamel) | Like `FromCamel` but does not respect initialisms.
| [From](#from) | Generate a value by calling a 'transformFunc'.
| [FromP](#fromp) | Generate a value by calling 'transformFunc' passing param.
| [FromJSONTag](#fromjsontag) | Generate a value by finding a struct property with the json tag matching the column name.

Additional functions can be chained after a `From` function to transform the data:

| Name | Description
|-|-
| [Transform](#chaining-transforms) | Apply an arbitrary transform to the data (specified by 'transformFunc').
| [TransformP](#chaining-transforms) | Apply an arbitrary transform to the data, passing a parameter.
| [NullIfEqual](#chaining-transforms) | If the input value equals the transform param, return nil.
| [NullIfZero](#chaining-transforms) | If the input value equals the zero value of its type, return nil.

Here are example uses of these functions.

## FromConstant

The AWS plugin provides a function, [commonColumnsForGlobalRegionResource](https://github.com/turbot/steampipe-plugin-aws/blob/f663b19c677b83dc1262e9a1e3c18243b1d07489/aws/common_columns.go#L60-L83), that defines columns for resources that exist globally, vs per-region. It use `transform.FromConstant("global")` to set the region in tables that represent global services.

```go
func commonColumnsForGlobalRegionResource() []*plugin.Column {
	return []*plugin.Column{
		{
			Name:        "partition",
			Type:        proto.ColumnType_STRING,
			Hydrate:     getCommonColumns,
			Description: "The AWS partition in which the resource is located (aws, aws-cn, or aws-us-gov).",
		},
		{
			Name: "region",
			Type: proto.ColumnType_STRING,
			// Region is hard-coded to special global region
			Transform:   transform.FromConstant("global"),
			Description: "The AWS Region in which the resource is located.",
		},
		{
			Name:        "account_id",
			Type:        proto.ColumnType_STRING,
			Hydrate:     getCommonColumns,
			Description: "The AWS Account ID in which the resource is located.",
			Transform:   transform.FromCamel(),
		},
	}
}
```

## FromField

The argument to `FromField` represents a property (or property path) in the struct returned by the Go SDK called by a hydrate function. 

Here are [two examples](https://github.com/turbot/steampipe-plugin-aws/blob/main/aws/table_aws_dynamodb_table.go#L87-L99) in `aws_dynamodb_table`.

```go
{
  Name:        "creation_date_time",
  Description: "The date and time when the table was created.",
  Type:        proto.ColumnType_TIMESTAMP,
  Hydrate:     getDynamoDBTable,
  Transform:   transform.FromField("CreationDateTime"),
},
{
  Name:        "table_class",
  Description: "The table class of the specified table. Valid values are STANDARD and STANDARD_INFREQUENT_ACCESS.",
  Type:        proto.ColumnType_STRING,
  Hydrate:     getDynamoDBTable,
  Transform:   transform.FromField("TableClassSummary.TableClass"),
},
```

Note that `FromField` can handle nested fields like `TableClass` as well as top-level fields like `CreationDateTime`.

## FromValue

Plugins often use `FromValue` to populate JSON columns from JSON responses returned by the Go SDKs that wrap underlying APIs, as seen in [table_gcp_storage_object](https://github.com/turbot/steampipe-plugin-gcp/blob/495e5324594128cc7ec4ab47e929569c24990507/gcp/table_gcp_storage_object.go#L206-L212), which retrieves a JSON representation of a [GCP IAM policy](https://cloud.google.com/iam/docs/reference/rest/v2beta/policies#Policy).

```go
{
  Name:        "iam_policy",
  Description: "An Identity and Access Management (IAM) policy, which specifies access controls for Google Cloud resources. ",
  Hydrate:     getStorageObjectIAMPolicy,
  Transform:   transform.FromValue(),
  Type:        proto.ColumnType_JSON,
},
```

Plugins also use `FromValue` for API responses that are simple values like strings, as seen in the [gcp_iam_policy](https://github.com/turbot/steampipe-plugin-gcp/blob/495e5324594128cc7ec4ab47e929569c24990507/gcp/table_gcp_iam_policy.go#L62-L67) table.

```go
{
  Name:        "project",
  Description: ColumnDescriptionProject,
  Type:        proto.ColumnType_STRING,
  Hydrate:     plugin.HydrateFunc(getProject).WithCache(),
  Transform:   transform.FromValue(),
},
```

## FromGo

The GitHub plugin uses `FromGo` as its [default transform](https://github.com/turbot/steampipe-plugin-github/blob/a99b96bc8f8a207581b83d8e65d5a7d283dd966c/github/plugin.go#L17).

```go
func Plugin(ctx context.Context) *plugin.Plugin {
	p := &plugin.Plugin{
		Name: "steampipe-plugin-github",
		ConnectionConfigSchema: &plugin.ConnectionConfigSchema{
			NewInstance: ConfigInstance,
		},
		DefaultTransform:   transform.FromGo(),
```

So when you define a column like [created_at](https://github.com/turbot/steampipe-plugin-github/blob/a99b96bc8f8a207581b83d8e65d5a7d283dd966c/github/table_github_gist.go#L21), the plugin SDK converts that to `CreatedAt` and retrieves that value from the [struct](https://pkg.go.dev/github.com/google/go-github/v60/github#Gist) returned from the SDK.

Note that `FromGo` handles [common initialisms](https://github.com/turbot/go-kit/blob/v0.8.0-rc.0/helpers/lint_name.go#L79), so `id` retrieves the field `ID`, and `html_url` retrieves `HTMLURL`.

Go SDK:

```go
type Gist struct {
	ID          *string                   `json:"id,omitempty"`
	Description *string                   `json:"description,omitempty"`
  ...
	HTMLURL     *string                   `json:"html_url,omitempty"`
```

Plugin:

```go
func gitHubGistColumns() []*plugin.Column {
	return []*plugin.Column{
		// Top columns
		{Name: "id", Type: proto.ColumnType_STRING, Description: "The unique id of the gist."},
		{Name: "description", Type: proto.ColumnType_STRING, Description: "The gist description."},
    ...
		{Name: "html_url", Type: proto.ColumnType_STRING, Description: "The HTML URL of the gist."},
```

You can also use `FromGo` on a per-column basis, as seen here in the definition of the `access_level` column in the [aws_iam_action](https://github.com/turbot/steampipe-plugin-aws/blob/f663b19c677b83dc1262e9a1e3c18243b1d07489/aws/table_aws_iam_action.go#L35) table.

```go
{
  Name:        "access_level",
  Type:        proto.ColumnType_STRING,
  Description: "The access level for this action.",
  Transform:   transform.FromGo(),
},
```

## FromCamel

If you don't need to handle common initialisms, you can use `FromCamel` instead of `FromGo`. For example, the [Snowflake](https://github.com/turbot/steampipe-plugin-snowflake/blob/0e428c07a864348a64101e5a59f709b0ee3856c5/snowflake/common_columns.go#L16-L33) plugin defines common columns `Account` and `Region`. For these, `FromCamel` is sufficient.

```go
func commonColumns() []*plugin.Column {
	return []*plugin.Column{
		{
			Name:        "region",
			Type:        proto.ColumnType_STRING,
			Hydrate:     plugin.HydrateFunc(getCommonColumns).WithCache(),
			Transform:   transform.FromCamel(),
			Description: "The Snowflake region in which the account is located.",
		},
		{
			Name:        "account",
			Type:        proto.ColumnType_STRING,
			Hydrate:     plugin.HydrateFunc(getCommonColumns).WithCache(),
			Description: "The Snowflake account ID.",
			Transform:   transform.FromCamel(),
		},
	}
}
```

## From

The `arn` column of the [aws_account](https://github.com/turbot/steampipe-plugin-aws/blob/f663b19c677b83dc1262e9a1e3c18243b1d07489/aws/table_aws_account.go#L40-L44) table calls the function `accountARN` to ensure the vaue is in a standardized format that can be used programmatically across AWS services and tools.

```go
{
  Name:        "arn",
  Description: "The Amazon Resource Name (ARN) specifying the account.",
  Type:        proto.ColumnType_STRING,
  Transform:   transform.From(accountARN),
},
```

Here's [the function](https://github.com/turbot/steampipe-plugin-aws/blob/f663b19c677b83dc1262e9a1e3c18243b1d07489/aws/table_aws_account.go#L193-L199).

```go
func accountARN(ctx context.Context, d *transform.TransformData) (interface{}, error) {
	accountInfo := d.HydrateItem.(*accountData)

	arn := "arn:" + accountInfo.commonColumnData.Partition + ":::" + accountInfo.commonColumnData.AccountId

	return arn, nil
}
```

## FromP

In [gcp_compute_disk](https://github.com/turbot/steampipe-plugin-gcp/blob/495e5324594128cc7ec4ab47e929569c24990507/gcp/table_gcp_compute_disk.go#L153-L157) the column `location_type` uses `FromP` to pass a parameter to the `diskLocation` function.

```go
{
    Name:        "location_type",
    Description: "Location type where the disk resides.",
    Type:        proto.ColumnType_STRING,
    Transform:   transform.FromP(diskLocation, "Type"),
}
```

Here's [the function](https://github.com/turbot/steampipe-plugin-gcp/blob/495e5324594128cc7ec4ab47e929569c24990507/gcp/table_gcp_compute_disk.go#L419-439).


```go
func diskLocation(_ context.Context, d *transform.TransformData) (interface{}, error) {
	i := d.HydrateItem.(*compute.Disk)
	param := d.Param.(string)

	zoneName := getLastPathElement(types.SafeString(i.Zone))
	regionName := getLastPathElement(types.SafeString(i.Region))
	project := strings.Split(i.SelfLink, "/")[6]

	locationData := map[string]string{
		"Type":     "ZONAL",
		"Location": zoneName,
		"Project":  project,
	}

	if zoneName == "" {
		locationData["Type"] = "REGIONAL"
		locationData["Location"] = regionName
	}

	return locationData[param], nil
}
```

## FromJsonTag


The table `reddit_user_search` uses `FromJsonTag` as the `DefaultTransform`. Here's what [the API](https://github.com/vartanbeno/go-reddit/blob/2f1019d1706b7de7188533ee8492a6613d05cd2c/reddit/user.go#L19-L33) provides:

```go
type User struct {
	// this is not the full ID, watch out.
	ID      string     `json:"id,omitempty"`
	Name    string     `json:"name,omitempty"`
	Created *Timestamp `json:"created_utc,omitempty"`

	PostKarma    int `json:"link_karma"`
	CommentKarma int `json:"comment_karma"`

	IsFriend         bool `json:"is_friend"`
	IsEmployee       bool `json:"is_employee"`
	HasVerifiedEmail bool `json:"has_verified_email"`
	NSFW             bool `json:"over_18"`
	IsSuspended      bool `json:"is_suspended"`
}
```

Here's the [table definition](https://github.com/turbot/steampipe-plugin-reddit/blob/1558aba8b94280ef7f547ddd58352f559e3c795c/reddit/table_reddit_user_search.go#L14-L41). When the names of the declared Steampipe columns match what's in the JSON tags, as in this case, you can use `FromJsonTag` to align the API's struct with the Steampipe table definition. 

```go
func tableRedditUserSearch(ctx context.Context) *plugin.Table {
	return &plugin.Table{
		Name:        "reddit_user_search",
		Description: "Search Reddit users.",
		// Allow for 0 counts
		DefaultTransform: transform.FromJSONTag(),
		List: &plugin.ListConfig{
			Hydrate: listUserSearch,
			KeyColumns: []*plugin.KeyColumn{
				{Name: "query", CacheMatch: "exact"},
			},
		},
		Columns: []*plugin.Column{
			// Top columns
			{Name: "rank", Type: proto.ColumnType_INT, Description: "Rank of the user among the result rows, use for sorting."},
			{Name: "name", Type: proto.ColumnType_STRING, Transform: transform.FromField("User.Name"), Description: "Name of the user."},
			{Name: "link_karma", Type: proto.ColumnType_INT, Transform: transform.FromField("User.PostKarma"), Description: "Karma from links."},
			{Name: "comment_karma", Type: proto.ColumnType_INT, Transform: transform.FromField("User.CommentKarma"), Description: "Karma from comments."},
			// Other columns
			{Name: "created_utc", Type: proto.ColumnType_STRING, Transform: transform.FromField("User.Created").Transform(timeToRfc3339), Description: "Time when the user was created."},
			{Name: "has_verified_email", Type: proto.ColumnType_BOOL, Transform: transform.FromField("User.HasVerifiedEmail"), Description: "True if the user email has been verified."},
			{Name: "id", Type: proto.ColumnType_STRING, Transform: transform.FromField("User.ID"), Description: "ID of the user."},
			{Name: "is_employee", Type: proto.ColumnType_BOOL, Transform: transform.FromField("User.IsEmployee"), Description: "True if the user is an employee."},
			{Name: "is_friend", Type: proto.ColumnType_BOOL, Transform: transform.FromField("User.IsFriend"), Description: "True if the user is a friend."},
			{Name: "is_suspended", Type: proto.ColumnType_BOOL, Transform: transform.FromField("User.IsSuspended"), Description: "True if the user has been suspended."},
			{Name: "over_18", Type: proto.ColumnType_BOOL, Transform: transform.FromField("User.NSFW"), Description: "True if the user is over 18."},
			{Name: "query", Type: proto.ColumnType_STRING, Transform: transform.FromQual("query"), Description: "Search query string."},
		},
	}
}
```

## Chaining Transforms

The [github_gist](https://github.com/turbot/steampipe-plugin-github/blob/main/github/table_github_gist.go#L29) table calls `FromField` for the `updated_at` column and chains to `convertTimestamp`.

```go
{
  Name: "updated_at", 
  Type: proto.ColumnType_TIMESTAMP, 
  Transform: transform.FromField("UpdatedAt").Transform(convertTimestamp), 
  Description: "The timestamp when the gist was last updated."
},
```

Here's the [chained function](https://github.com/turbot/steampipe-plugin-github/blob/a99b96bc8f8a207581b83d8e65d5a7d283dd966c/github/utils.go#L158-L173).

```go
func convertTimestamp(ctx context.Context, input *transform.TransformData) (interface{}, error) {
	switch t := input.Value.(type) {
	case *github.Timestamp:
		return t.Format(time.RFC3339), nil
	case github.Timestamp:
		return t.Format(time.RFC3339), nil
	case githubv4.DateTime:
		return t.Format(time.RFC3339), nil
	case *githubv4.DateTime:
		return t.Format(time.RFC3339), nil
	case models.NullableTime:
		return t.Format(time.RFC3339), nil
	default:
		return nil, nil
	}
}
```

The `image_24` column in the [slack_user](https://github.com/turbot/steampipe-plugin-slack/blob/f93fd12c3fc5f2f221e851d325a666501e1e8917/slack/table_slack_user.go#L44) table calls `FromField` and chains to `NullIfZero`.

```go
{
  Name: "image_24", 
  Type: proto.ColumnType_STRING,
  Transform: transform.FromField("Profile.Image24").NullIfZero(), 
  Description: "URL of the user profile image, size 24x24 pixels."},
},
```


In its `DefaultTransform`, the [servicenow_sn_chg_reset_change](https://github.com/turbot/steampipe-plugin-servicenow/blob/7a1771f5b71a083aeef6ff0a1474a35544827d06/servicenow/table_servicenow_sn_chg_rest_change.go#L17 ) table calls `FromCamel` and chains to `NullIfEqual`.

```go
DefaultTransform: transform.FromCamel().NullIfEqual(""),
```




