---
title: Organizations
sidebar_label: Organizations
---

# Organizations
 
Steampipe Cloud users can create their own connections and workspaces, but they are not shared with other users.  Steampipe **Organizations**, on the other hand, include multiple users and are intended for organizations to collaborate and share workspaces and connections.


## Creating Organizations
To create an organization, select the double arrow button from the navigation at the top of the page, and select **Create Organization** from the menu.  Select a unique handle for your organization.  This handle must be a unique name across all user accounts and organizations.  Optionally, expand the **Profile** and set a **Logo URL** (publicly accessible URL for the organization's logo) and **URL** (publicly accessible URL for the organization). Click **Create Organization**.

## Managing Workspaces & Connections
To manage an organization, select the double arrow button from the navigation at the top of the page, and select the organization that you wish to manage.  You can manage [workspaces](cloud/workspaces) and [connections](cloud/connections) for your organization in the same manner as for your user account.

## Managing Users
You can add and remove users from the **People** tab on your organization page.  To invite a user to your organization, click **Invite User**.  Enter an email address or the user handle of an existing user and select a role for the user:
- **Member**: Members can see other members of the organization and create workspaces and connections.
- **Owner**: Owners have full administrative rights to the organization and have complete access to all workspaces, connections and teams.

Click **Invite**.  The user will receive an email invitation to join the organization.  You can view pending invitations by clicking **Pending** from the left hand menu.  Once a user has accepted, they will appear in the **Members** list.

To remove a user from the organization, select the options menu button (hamburger) to the right of the user and click **Remove**.


## Profile Settings
On the **Settings** page for your organization, click **Profile** from the left hand menu to manage your profile data.  You can modify your organization's **Display Name** or **Avatar URL**.


## Audit Log
On the **Settings** page, click **Audit Log** from the left hand menu to view a log of API activity associated with the organization.


## Updating Your Organization Handle
You can update your organization handle at any time.  Note, however, that your workspace DNS names all contain your organization handle;  changing it will result in changing the DNS name for ALL of your organization's workspaces.

On the **Settings** page for your user, click **Advanced** from the left hand menu.  Enter your new handle and click **Save**.


## Deleting Organizations
To delete an organization, select the double arrow button from the navigation at the top of the page and select the organization.  Go to the **Settings** tab and click **Advanced**.  Click **Delete Organization**.  You will be prompted to confirm deletion.  Enter the organization handle and click **Delete**.

