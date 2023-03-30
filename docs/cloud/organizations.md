---
title: Organizations
sidebar_label: Organizations
---

# Organizations
 
Steampipe Cloud users can create their own connections and workspace, but they are not shared with other users.  Steampipe **Organizations**, on the other hand, include multiple users and are intended for organizations to collaborate and share workspaces and connections.


## Creating Organizations
To create an organization, select the double arrow button from the navigation at the top of the page, and select **Create Organization** from the menu.  Select a unique handle for your organization.  This handle must be a unique name across all user accounts and organizations.  Optionally, expand the **Profile** and set a **Logo URL** (publicly accessible URL for the organization's logo) and **URL** (publicly accessible URL for the organization). Click **Create Organization**.

## Managing Workspaces & Connections
To manage an organization, select the double arrow button from the navigation at the top of the page, and select the organization that you wish to manage.  You can manage [workspaces](cloud/workspaces) and [connections](cloud/connections) for your organization in the same manner as for your user account.

## Managing Users
You can add and remove users from the **People** tab on your organization page.  To invite a user to your organization, click **Invite User**.  Enter an email address or the user handle of an existing user and select a role for the user, and click **Add**:


| Role | Description
|-|-
| **Member** | Can be granted permissions in workspaces and see members of the organization.  Members are not granted access to any workspaces by default.
| **Owner**  | Have full administrative rights to the organization including complete access to all workspaces, connections, users, groups and permissions.  Owners are essentially superusers in the organization -- they have full access to all workspaces implicitly, and their access cannot be removed at the workspace level.

To revoke access from a user, select the options menu button (hamburger) to the right of the user and click **Remove**.  Note that **Org Owners** have implicit access to all workspaces in the organization, and you cannot revoke their access at the workspace level.


## Profile Settings
On the **Settings** page for your organization, click **Profile** from the left hand menu to manage your profile data.  You can modify your organization's **Display Name** or **Avatar URL**.


## Updating Your Organization Handle
You can update your organization handle at any time.  Note, however, that your workspace DNS names all contain your organization handle;  changing it will result in changing the DNS name for ALL of your organization's workspaces.

On the **Settings** page for your user, click **Advanced** from the left hand menu.  Enter your new handle and click **Save**.

## Revoking Access
Once users have been added to your organization, they will be able to authenticate against it according to the permissions they were granted. This can be using either temporary tokens issued via console or [CLI login](/docs/reference/cli/login#steampipe-login), or with [tokens](/docs/cloud/profile#tokens) managed via their user profile settings.

If you wish to revoke access to your organization for any currently issued token, you can do so by going to  the **Settings** page for your organization, then clicking **Advanced** from the left hand menu. From here you'll find a `Revoke Tokens` section. Clicking the `Reset to now` button will revoke access to all existing temporary and user tokens.

<img src="/images/docs/cloud/cloud-organization-revoke-tokens.png" width="400pt"/>
<br />

## Deleting Organizations
To delete an organization, select the double arrow button from the navigation at the top of the page and select the organization.  Go to the **Settings** tab and click **Advanced**.  Click **Delete Organization**.  You will be prompted to confirm deletion.  Enter the organization handle and click **Delete**.

