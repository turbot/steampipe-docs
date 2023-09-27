---
title: steampipe login
sidebar_label: steampipe login
---


# steampipe login
Log in to [Turbot Pipes](https://turbot.com/pipes/docs).

The Steampipe CLI can interact with Turbot Pipes to run queries, benchmarks, and dashboards against a remote cloud database, and to save and share snapshots. These capabilities require authenticating to Turbot Pipes.  The `steampipe login` command launches an interactive process for logging in and obtaining a temporary (30 day) token. The token is written to `~/.steampipe/internal/{cloud host}.tptt`.

## Usage
```bash
steampipe login
```

## Examples

Login to `pipes.turbot.com`:

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
Verify login at https://pipes.turbot.com/login/token?r=tpttr_cdckfake6ap10t9dak0g_3u2k9hfake46g4o4wym7h8hw
Enter verification code: 745278
Login successful for user johnsmyth
```
