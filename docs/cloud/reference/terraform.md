---
title:  Using the Steampipe Cloud Terraform Provider
sidebar_label: Terraform
---

# Manage Steampipe Cloud with Terraform

The Steampipe Cloud Terraform provider makes it easy to manage your Steampipe Cloud infrastructure as code!

**[Steampipe Cloud Terraform Provider reference docs →](https://registry.terraform.io/providers/turbot/steampipecloud/latest/docs)**

```hcl
terraform {
  required_providers {
    steampipecloud = {
      source = "turbot/steampipecloud"
    }
  }
}

resource "steampipecloud_organization" "myorg" {
  handle       = "myorg"
  display_name = "Test Org"
}

resource "steampipecloud_organization_member" "example" {
  organization = steampipecloud_organization.myorg.handle
  user_handle  = "someuser"
  role         = "member"
}
```
