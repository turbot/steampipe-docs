---
title:  Using the Steampipe Cloud Go SDK
sidebar_label: Go SDK
---

# Using the Steampipe Cloud Go SDK

The Go SDK for Steampipe Cloud provides an interface to the Steampipe API for Go programmers.

**[GoDoc reference for github.com/turbot/steampipe-cloud-sdk-go →](https://pkg.go.dev/github.com/turbot/steampipe-cloud-sdk-go)**

**[View the source on Github →](https://github.com/turbot/steampipe-cloud-sdk-go)**

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
