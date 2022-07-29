---
title:  Using the Steampipe Cloud Terraform Provider
sidebar_label: Terraform
---


# Manage Steampipe Cloud with Terraform
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
