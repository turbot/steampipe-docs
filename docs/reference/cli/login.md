---
title: steampipe login
sidebar_label: steampipe login
---


# steampipe login
Log in to [Steampipe Cloud](/docs/cloud/overview).

The Steampipe CLI can interact with Steampipe Cloud to run queries, benchmarks, and dashboards against a remote cloud database, and to save and share snapshots. These capabilities require authenticating to Steampipe Cloud.  The `steampipe login` command launches an interactive process for logging in and obtaining a temporary (30 day) token. 

## Usage
```bash
steampipe login
```

## Examples

Login to `cloud.steampipe.io`:

```bash
steampipe login
```


The `steampipe login` command will launch your web browser to continue the login process. Verify the request.



<img src="/images/docs/steampipe-login/steampipe-login-1.png" width="100%" />



After you have verified the request, the browser will display a verification code.   
<img src="/images/docs/steampipe-login/steampipe-login-2.png" width="100%" />

Paste the code into the cli and hit enter to complete the login process:

```bash
$ steampipe login
Verify login at https://latestpipe.turbot.io/login/token?r=spttr_cdckfake6ap10t9dak0g_3u2k9hfake46g4o4wym7h8hw
Enter verification code: 745278
Login successful for user johnsmyth
```
