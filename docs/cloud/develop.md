---
title:  Developers
sidebar_label: Developers
---

# Using the Steampipe Cloud API

## Authentication
To use the Steampipe Cloud API, you must connect with an [API token](/docs/cloud/profile#api-tokens). 
The examples in this section assume that you have set the [`STEAMPIPE_CLOUD_TOKEN`](reference/env-vars/steampipe_cloud_token) to a valid API token:
```bash
export STEAMPIPE_CLOUD_TOKEN=spt_c6rnjt8afakemj4gha10_svpnmxqfaketokenad431k
```

## Query Your Data
The Steampipe Cloud API makes it easy query your data and integrate it into your scripts and applications!

You can issue a simple query with a GET request:
```bash
curl -H "Authorization: Bearer ${STEAMPIPE_CLOUD_TOKEN}" \
  https://cloud.steampipe.io/api/latest/user/foo/workspace/bar/query?sql=select+*+from+aws_s3_bucket
```

If you POST you can avoid encoding the SQL:
```bash
curl -H "Authorization: Bearer ${STEAMPIPE_CLOUD_TOKEN}" \
  -d 'sql=select name,arn from aws_s3_bucket' \
  https://cloud.steampipe.io/api/latest/user/foo/workspace/bar/query
```

<!--
Or you can just pass a sql file:
```bash
curl -H "Authorization: Bearer ${STEAMPIPE_CLOUD_TOKEN}" \
  -d 'sql=select name,arn from aws_s3_bucket' \
  https://cloud.steampipe.io/api/latest/user/foo/workspace/bar/query
```
-->

By default, the results are in JSON. You can get the results in other formats simple by adding a file name with the appropriate extension to the path.  You can get your results in CSV:

```bash
curl -H "Authorization: Bearer ${STEAMPIPE_CLOUD_TOKEN}" \
  -d sql'=select name,arn from aws_s3_bucket' \
  https://cloud.steampipe.io/api/latest/user/foo/workspace/bar/query/my-file.csv
```

Or markdown:
```bash
curl -H "Authorization: Bearer ${STEAMPIPE_CLOUD_TOKEN}" \
  -d sql'=select name,arn from aws_s3_bucket' \
  https://cloud.steampipe.io/api/latest/user/foo/workspace/bar/query/my-file.md
```

Alternatively, you can set the content type in the `content_type` query parameter:
```bash
curl -H "Authorization: Bearer ${STEAMPIPE_CLOUD_TOKEN}" \
  -d sql'=select name,arn from aws_s3_bucket' \
  https://cloud.steampipe.io/api/latest/user/foo/workspace/bar/query?content_type=csv
```

Or via HTTP headers:
```bash
curl -H "Authorization: Bearer ${STEAMPIPE_CLOUD_TOKEN}" \
  -H "Accept: text/csv" \
  -X POST -d sql='select name,arn from aws_s3_bucket' \
  https://cloud.steampipe.io/api/latest/user/foo/workspace/bar/query
```


## Use the Go SDK
The [Go SDK for Steampipe Cloud provides an easy to use interface to the Steampipe API for Go programmers. The SDK is open source and is available on [Github](https://github.com/turbot/steampipe-cloud-sdk-go), and is [documented via GoDoc](https://pkg.go.dev/github.com/turbot/steampipe-cloud-sdk-go).

```go
package main

import (
    "context"
    "fmt"
    "os"

    steampipecloud "github.com/turbot/steampipe-cloud-sdk-go"
)

func main() {
    // Create a default configuration
    configuration := steampipecloud.NewConfiguration()

    // Add your Steampipe Cloud user token as an auth header
    configuration.AddDefaultHeader("Authorization", fmt.Sprintf("Bearer %s", os.Getenv("STEAMPIPE_CLOUD_TOKEN")))

    // Create a client
    client := steampipecloud.NewAPIClient(configuration)

    // Find your authenticated user info
    actor, _, err := client.Actors.Get(context.Background()).Execute()

    if err != nil {
      // Do something with the error
      return
    }

    // List your workspaces
    workspaces, _, err := client.UserWorkspaces.List(context.Background(), actor.Handle).Execute()

    if err != nil {
      // Do something with the error
      return
    }
}
```


## Manage Steampipe Cloud with Terraform
The Steampipe Cloud Terraform provider makes it easy to manage your Steampipe Cloud infrastructure as code!  Refer to the [documentation](https://registry.terraform.io/providers/turbot/steampipecloud/latest/docs) in the Terraform registry for more information.


```hcl
# Configure the Steampipe Cloud provider
provider "steampipecloud" {
  token = "spt_example"
}

# Create a user workspace
resource "steampipecloud_workspace" "my_user_workspace" {
  # ...
}

# Create an organization workspace
resource "steampipecloud_workspace" "my_org_workspace" {
  organization = 'myorg'
  # ...
}
```


## Query Steampipe Cloud API with the Steampipe Cloud Plugin
The Steampipe Cloud plugin, available on the [Steampipe Hub](https://hub.steampipe.io/plugins/turbot/steampipecloud), makes it easy to query your Workspaces, Connections, and other Steampipe Cloud assets using Steampipe!

```sql
select
  user_handle,
  email,
  status
from
  steampipecloud_organization_member
where
  status = 'invited'
```

## Reference
The API OpenAPI definition is available for download at https://cloud.steampipe.io/api/v1/docs/openapi.json.



