---
title: Hydrate Functions
sidebar_label: Hydrate Functions
---

# Hydrate Functions

A hydrate function connects to an external system or service and gathers data to fill a database table.

`List` and `Get` and are hydrate functions, defined in the [Table Definition](/docs/develop/writing_plugins/the-basics#table-definition), that have these special characteristics:

- Every table ***must*** define a `List` and/or `Get` function.

- The `List` or `Get` will always be called before any other hydrate function in the table, as the other functions typically depend on the result of the `Get` or `List` call.

- Whether `List` or `Get` is called depends upon whether the qualifiers (in `where` clauses and `join...on`) match the `KeyColumns` defined in the [Get Config](/docs/develop/writing_plugins/the-basics#get-config).  This enables Steampipe to fetch only the "row" data that it needs.

- Typically, hydrate functions return a single data item (data for a single row).  *List functions are an exception* — they stream data for multiple rows using the [QueryData](https://github.com/turbot/steampipe-plugin-sdk/blob/HEAD/plugin/query_data.go) object, and return `nil`.

- The `Get` function will usually get the key column data from the `QueryData.KeyColumnQuals` so that it can get the appropriate item as based on the qualifiers (`where` clause, `join...on`).  If the `Get` hydrate function is used as both a `Get` function AND a normal hydrate function, you should get the key column data from the `HydrateData.Item` if it is not nil, and use the `QueryData.KeyColumnQuals` otherwise.

## About List Functions

A `List` function retrieves all the items of a particular resource type from an API. For example, the [zendesk_group](https://hub.steampipe.io/plugins/turbot/zendesk/tables/zendesk_group) table supports the query:

```sql
select
  *
from
  zendesk_group
```

The function `tableZenDeskGroup` [defines the table](https://github.com/turbot/steampipe-plugin-zendesk/blob/33c9cb30826c41d75c7d07d1947e2fd9fd5735d1/zendesk/table_zendesk_group.go#L10-L30).

```go
package zendesk

import (
	"context"

	"github.com/turbot/steampipe-plugin-sdk/v5/grpc/proto"
	"github.com/turbot/steampipe-plugin-sdk/v5/plugin"
)

func tableZendeskGroup() *plugin.Table {
	return &plugin.Table{
		Name:        "zendesk_group",
		Description: "When support requests arrive in Zendesk Support, they can be assigned to a Group. Groups serve as the core element of ticket workflow; support agents are organized into Groups and tickets can be assigned to a Group only, or to an assigned agent within a Group. A ticket can never be assigned to an agent without also being assigned to a Group.",
		List: &plugin.ListConfig{
			Hydrate: listGroup,
		},
		Get: &plugin.GetConfig{
			KeyColumns: plugin.SingleColumn("id"),
			Hydrate:    getGroup,
		},
		Columns: []*plugin.Column{
			{Name: "id", Type: proto.ColumnType_INT, Description: "Unique identifier for the group"},
			{Name: "url", Type: proto.ColumnType_STRING, Description: "API url of the group"},
			{Name: "name", Type: proto.ColumnType_STRING, Description: "Name of the group"},
			{Name: "deleted", Type: proto.ColumnType_BOOL, Description: "True if the group has been deleted"},
			{Name: "created_at", Type: proto.ColumnType_TIMESTAMP, Description: "The time the group was created"},
			{Name: "updated_at", Type: proto.ColumnType_TIMESTAMP, Description: "The time of the last update of the group"},
		},
	}
}
```

The table's `List` property refers, by way of the `Hydrate` property, to a Steampipe function that lists Zendesk groups, [listGroup](https://github.com/turbot/steampipe-plugin-zendesk/blob/33c9cb30826c41d75c7d07d1947e2fd9fd5735d1/zendesk/table_zendesk_group.go#L32-L46). That function calls the GitHub Go SDK's [GetGroups](https://github.com/nukosuke/go-zendesk/blob/cfe7c2f3969555054ea51b90b2a60a219e309a43/zendesk/group.go#L44-L70) and returns an array of [Group](https://github.com/nukosuke/go-zendesk/blob/cfe7c2f3969555054ea51b90b2a60a219e309a43/zendesk/group.go#L12-L21).

```go
type Group struct {
	ID          int64     `json:"id,omitempty"`
	URL         string    `json:"url,omitempty"`
	Name        string    `json:"name"`
	Default     bool      `json:"default,omitempty"`
	Deleted     bool      `json:"deleted,omitempty"`
	Description string    `json:"description,omitempty"`
	CreatedAt   time.Time `json:"created_at,omitempty"`
	UpdatedAt   time.Time `json:"updated_at,omitempty"`
}
```

A Steampipe `List` function is one of two special forms of [hydrate function](/docs/develop/writing-plugins#hydrate-functions) — `Get` is the other — that take precedence over other [hydrate functions](/docs/develop/writing_plugins/hydrate-functions).

## About Get Functions

A `Get` function fetches a single item by its key. While it's possible to define a table that only uses `Get`, the common pattern combines `List` to retrieve basic data and `Get` to enrich it. Here's the [Get function](https://github.com/turbot/steampipe-plugin-zendesk/blob/33c9cb30826c41d75c7d07d1947e2fd9fd5735d1/zendesk/table_zendesk_group.go#L48-L60) for a Zendesk group.

```go
func getGroup(ctx context.Context, d *plugin.QueryData, h *plugin.HydrateData) (interface{}, error) {
	conn, err := connect(ctx, d)
	if err != nil {
		return nil, err
	}
	quals := d.EqualsQuals
	id := quals["id"].GetInt64Value()
	result, err := conn.GetGroup(ctx, id)
	if err != nil {
		return nil, err
	}
	return result, nil
}
````

### Observing List versus Get

When `List` and `Get` are both defined, you can use [diagnostic mode](https://steampipe.io/docs/guides/limiter#exploring--troubleshooting-with-diagnostic-mode) to see which function Steampipe calls for a given query.

```
 STEAMPIPE_DIAGNOSTIC_LEVEL=all  steampipe service start
 ```

 This query uses `List`.

```
> select jsonb_pretty(_ctx) as _ctx from zendesk_group limit 1
+--------------------------------------------------+
| _ctx                                             |
+--------------------------------------------------+
| {                                                |
|     "steampipe": {                               |
|         "sdk_version": "5.8.0"                   |
|     },                                           |
|     "diagnostics": {                             |
|         "calls": [                               |
|             {                                    |
|                 "type": "list",                  |
|                 "scope_values": {                |
|                     "table": "zendesk_group",    |
|                     "connection": "zendesk",     |
|                     "function_name": "listGroup" |
|                 },                               |
|                 "function_name": "listGroup",    |
|                 "rate_limiters": [               |
|                 ],                               |
|                 "rate_limiter_delay_ms": 0       |
|             }                                    |
|         ]                                        |
|     },                                           |
|     "connection_name": "zendesk"                 |
| }                                                |
+--------------------------------------------------+
```

This query uses `Get`.

```
> select jsonb_pretty(_ctx) as _ctx from zendesk_group where id = '24885656597005'
+--------------------------------------------------+
| _ctx                                             |
+--------------------------------------------------+
| {                                                |
|     "steampipe": {                               |
|         "sdk_version": "5.8.0"                   |
|     },                                           |
|     "diagnostics": {                             |
|         "calls": [                               |
|             {                                    |
|                 "type": "list",                  |
|                 "scope_values": {                |
|                     "table": "zendesk_group",    |
|                     "connection": "zendesk",     |
|                     "function_name": "getGroup"  |
|                 },                               |
|                 "function_name": "getGroup",     |
|                 "rate_limiters": [               |
|                 ],                               |
|                 "rate_limiter_delay_ms": 0       |
|             }                                    |
|         ]                                        |
|     },                                           |
|     "connection_name": "zendesk"                 |
| }                                                |
+--------------------------------------------------+
```

This works because `id` is one of the `KeyColumns` in the `Get` property of the table definition. 

```go
Get: &plugin.GetConfig{
	KeyColumns: plugin.SingleColumn("id"),
	Hydrate:    getGroup,
},
```

That enables the [Steampipe plugin SDK](https://github.com/turbot/steampipe-plugin-sdk) to choose the more optimal `getGroup` function when the `id` is known.

### List or Get in Combination with Hydrate

In addition to the special `List` and `Get` hydrate functions, there's a class of general hydrate functions that enrich what's returned by `List` or `Get`.  The Zendesk plugin doesn't use any of these, but in `table_aws_cloudtrail_trail.go`, [getCloudTrailStatus](https://github.com/turbot/steampipe-plugin-aws/blob/40058d8fd15a677214cfa3e22de35cde707775e7/aws/table_aws_cloudtrail_trail.go#L329-L369) is an example of this kind of function.

Steampipe knows it's a `HydrateFunc` because the column definition [declares](https://github.com/turbot/steampipe-plugin-aws/blob/40058d8fd15a677214cfa3e22de35cde707775e7/aws/table_aws_cloudtrail_trail.go#L149-L155) it using the `Hydrate` property. 

```go
{
	Name:        "latest_cloudwatch_logs_delivery_error",
	Description: "Displays any CloudWatch Logs error that CloudTrail encountered when attempting to deliver logs to CloudWatch Logs.",
	Type:        proto.ColumnType_STRING,
	Hydrate:     getCloudtrailTrailStatus,
	Transform:   transform.FromField("LatestCloudWatchLogsDeliveryError"),
},
```

## HydrateConfig

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

In this example the `Func` property names `getConfigRuleTags` and `getComplianceByConfigRules` as additional hydrate functions that fetch tags and compliance details for each config rule, respectively. The `Tags` property enables a rate limiter to [target these functions](https://steampipe.io/docs/guides/limiter#function-tags). (See also [function-tags](#function-tags) below.)

## Memoize: Caching hydrate results

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



Additional functions can be chained after a `From` function to transform the data:

| Name | Description
|-|-
| `Transform` | Apply an arbitrary transform to the data (specified by 'transformFunc').
| `TransformP` | Apply an arbitrary transform to the data, passing a parameter.
| `NullIfEqual` | If the input value equals the transform param, return nil.
| `NullIfZero` | If the input value equals the zero value of its type, return nil.

