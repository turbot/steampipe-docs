---
title:  User Profile & Settings
sidebar_label: User Profile & Settings
---

# User Profile & Settings

You can manage your user profile and credentials from the **Settings** page for your user account.  Click your avatar in the top right and select **Settings** from the menu, or click the double arrow button from the navigation at the top of the page, select your user account from the dropdown, and then select **Settings** from the menu on the left.

## Profile Settings

On the **Settings** page for your user account, click **Profile** from the left hand menu to manage your profile data.  You can modify your **Display Name** or **Avatar URL**.

You can also rotate your **Database Password**.  Every Steampipe user has a single password they can use to log in to the workspaces to which they have access. (This is the password that appears in the connection string.)  You can rotate your password at any time by clicking **Rotate Password** on the profile page. This may take a couple of minutes to propagate to all of your workspaces.  Note that existing connections will not be terminated when you rotate your password.

## Tokens
On the **Settings** page for your user, click **Tokens** from the left hand menu to manage your Steampipe Cloud tokens.  You can use these tokens to access the Steampipe Cloud API, or to connect to Steampipe Cloud workspaces from the Steampipe CLI.  You can have up to 2 tokens at a time.

Click **New Token** to create a new API token.  The token will be masked, but you can reveal it by clicking the eye icon, or hover over it and click the clipboard icon to copy it.  Make a secure note of the token as you will not be able to retrieve it again.

You can deactivate or delete a token from the list by clicking the options menu button (hamburger) and selecting **Deactivate** or **Delete** from the menu.

## Audit Log
On the **Settings** page for your user account, click **Audit Log** from the left hand menu to view a log of API activity associated to your account.

## Updating Your User Handle
You can update your user handle at any time.  Note, however, that your workspace DNS names all contain your user handle;  changing it will result in changing the DNS name for ALL of your workspaces.

On the **Settings** page for your user account, click **Advanced** from the left hand menu.  Enter your new handle and click **Save**.


## Permanently Deleting Your Steampipe Cloud Account
If you wish, you can permanently remove your personal account and all of its contents from the Steampipe platform. (We hate to see you go!) This action is not reversible, so please continue with caution.

On the **Settings** page for your user, click **Advanced** from the left hand menu, and then click **Delete Personal Account**.  You will be prompted to confirm deletion; enter your user handle and click **Delete**.
