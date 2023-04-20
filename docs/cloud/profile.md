---
title:  User Profile & Settings
sidebar_label: User Profile & Settings
---

# User Profile & Settings

You can manage your user profile and credentials from the **Settings** page for your user account.  Click your avatar in the top right and select **Settings** from the menu, or click the double arrow button from the navigation at the top of the page, select your user account from the dropdown, and then select **Settings** from the menu on the left.

## Profile Settings

On the **Settings** page for your user account, click **Profile** from the left hand menu to manage your profile data.  You can modify your **Display Name** or upload a custom **Avatar**.

You can also rotate your **Database Password**.  Every Steampipe user has a single password they can use to log in to the workspaces to which they have access. (This is the password that appears in the connection string.)  You can rotate your password at any time by clicking **Rotate Password** on the profile page. This may take a couple of minutes to propagate to all of your workspaces.  Note that existing connections will not be terminated when you rotate your password.

### Custom Avatar

When you create your user account, Steampipe Cloud will attempt to locate your public avatar for your email address. In the event that we can't find one, we'll generate a random one.

<img src="/images/docs/cloud/cloud-profile-custom-avatar.png" width="400pt"/>
<br />

If you want to change your identity-provider or random avatar, you can upload a custom one. Simply click the avatar image and choose a JPEG or PNG file from your computer. You can also crop the image to your requirements. Once happy, click the `Save` option.

<img src="/images/docs/cloud/cloud-profile-custom-avatar-crop.png" width="300pt"/>
<br />

If you ever need to revert to the default avatar, click the `Reset` option.

## Notifications
On the **Settings** page for your user, click **Notifications** from the left hand menu to manage your Steampipe Cloud notification preferences.  Choose what type of emails you wish to receive from Steampipe Cloud:

| Type | Description |
|-|-
| **Community Updates** | Get notified of community information and events you may be interested in.
| **Product Updates**   | Get notified of product updates as they are released.
| **Tips & Tricks**     | Get useful tips & tricks on using Steampipe Cloud.
| **System**            | Important system notifications related to your Steampipe Cloud account. System notifications cannot be disabled.

 



## Tokens
On the **Settings** page for your user, click **Tokens** from the left hand menu to manage your Steampipe Cloud tokens.  You can use these tokens to access the [Steampipe Cloud API](/docs/cloud/develop/query-api), or to connect to Steampipe Cloud workspaces from the Steampipe CLI.  You can have up to 2 tokens at a time.

Click **New Token** to create a new API token.  The token will be masked, but you can reveal it by clicking the eye icon, or hover over it and click the clipboard icon to copy it.  Make a secure note of the token as you will not be able to retrieve it again.

You can deactivate or delete a token from the list by clicking the options menu button (hamburger) and selecting **Deactivate** or **Delete** from the menu.

## Reset Authentication
You will be able to authenticate against your account using either temporary tokens issued via console or [CLI login](/docs/reference/cli/login#steampipe-login), or with [tokens](/docs/cloud/profile#tokens) managed via your profile settings.

If you wish to reset authentication to your user for all issued tokens, you can do so by going to  the **Settings** page for your user, then clicking **Advanced** from the left hand menu. From here you'll find a `Reset authentication` section. Clicking the `Reset authentication` button will reset authentication for all existing temporary and user tokens.

This will also log you out of the current session and any other you have open at that stage. You will also need to re-generate any [tokens](/docs/cloud/profile#tokens) you use for API access.

<img src="/images/docs/cloud/cloud-user-reset-authentication.png" width="400pt"/>
<br />

## Audit Log
On the **Settings** page for your user account, click **Audit Log** from the left hand menu to view a log of API activity associated to your account.

## Updating Your User Handle
You can update your user handle at any time.  Note, however, that your workspace DNS names all contain your user handle;  changing it will result in changing the DNS name for ALL of your workspaces.

On the **Settings** page for your user account, click **Advanced** from the left hand menu.  Enter your new handle and click **Save**.


## Permanently Deleting Your Steampipe Cloud Account
If you wish, you can permanently remove your personal account and all of its contents from the Steampipe platform. (We hate to see you go!) This action is not reversible, so please continue with caution.

On the **Settings** page for your user, click **Advanced** from the left hand menu, and then click **Delete Personal Account**.  You will be prompted to confirm deletion; enter your user handle and click **Delete**.
