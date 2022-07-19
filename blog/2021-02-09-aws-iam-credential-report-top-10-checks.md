---
id: aws-iam-credential-report-top-10-checks
title: "Top 10 Checks: IAM Credential Report"
category: "Best Practice"
description: Learn how to generate and check your AWS IAM Credential Report for root accounts and users.
author:
  name: David Boeke
publishedAt: "2021-02-09T13:00:00"
durationMins: 10
image: /images/blog/2021-02-09-aws-iam-credential-report-top-10/steampipe_cli.jpg
slug: aws-iam-credential-report-top-10-checks
schema: "2021-01-08"
---

### #1 Are you running your credential report?

We recommend generating your credential report every four hours and saving the content to S3. This can be accomplished with a scheduled lambda function or through automated governance software like [Turbot Cloud](https://turbot.com/v5).

To generate from the CLI:

```sh
$ aws iam generate-credential-report
{ 
  "State":  "STARTED",
  "Description": "No report exists. Starting a new report generation task"
}

$ aws iam generate-credential-report
{ 
  "State":  "COMPLETE"
}
```

Now that it's generated, we can do a quick query using steampipe to get the contents:

<Terminal mode="light">
  <TerminalCommand>
    {`select * from aws_iam_credential_report;
    `}
  </TerminalCommand>
  <TerminalResult>
{`+----------------+-----------------------------------------------+---------------------+---------------------+---------------------+---------------------------+-----------------------------+-------------------------------+--------------------------------+---------------------+---------------------------+-----------------------------+
| user_name      | user_arn                                      | user_creation_time  | generated_time      | access_key_1_active | access_key_1_last_rotated | access_key_1_last_used_date | access_key_1_last_used_region | access_key_1_last_used_service | access_key_2_active | access_key_2_last_rotated | access_key_2_last_used_date |
+----------------+-----------------------------------------------+---------------------+---------------------+---------------------+---------------------------+-----------------------------+-------------------------------+--------------------------------+---------------------+---------------------------+-----------------------------+
| <root_account> | arn:aws:iam::899221540641:root                | 2019-07-15 14:44:33 | 2021-02-09 08:42:56 | false               |                           |                             |                               |                                | false               |                           |                             |
| pam_beasly     | arn:aws:iam::899221540641:user/pam_beasly     | 2019-11-13 18:32:34 | 2021-02-09 08:42:56 | true                | 2020-06-18 19:12:27       | 2021-02-09 00:36:00         | us-east-1                     | iam                            | true                | 2020-12-03 01:20:25       | 2020-12-03 01:33:00         |
| darryl_philbin | arn:aws:iam::899221540641:user/darryl_philbin | 2021-01-25 19:12:26 | 2021-02-09 08:42:56 | true                | 2021-01-25 19:12:26       |                             |                               |                                | false               |                           |                             |
| dwight_schrute | arn:aws:iam::899221540641:user/dwight_schrute | 2021-01-25 19:10:51 | 2021-02-09 08:42:56 | false               |                           |                             |                               |                                | false               |                           |                             |
| kelly_kapoor   | arn:aws:iam::899221540641:user/kelly_kapoor   | 2021-01-25 19:13:23 | 2021-02-09 08:42:56 | false               |                           |                             |                               |                                | false               |                           |                             |
| ryan_howard    | arn:aws:iam::899221540641:user/ryan_howard    | 2021-01-25 19:26:22 | 2021-02-09 08:42:56 | false               |                           |                             |                               |                                | false               |                           |                             |
+----------------+-----------------------------------------------+---------------------+---------------------+---------------------+---------------------------+-----------------------------+-------------------------------+--------------------------------+---------------------+---------------------------+-----------------------------`}
  </TerminalResult>
</Terminal>

<br/>
<br />
That is a very wide table, let's break it down to make it more manageable and check some specific key controls.
<br />
<br />

# Root Account Checks

Every AWS Account has a `root` user with the name `<root_account>`. This should be considered a "break glass" user and therefore rarely be used; however, there are a few [troubleshooting situations](https://aws.amazon.com/premiumsupport/knowledge-center/s3-accidentally-denied-access/) that require use of the Root Account. Any usage of the root account should always be done under change control with multiple people coordinating to gain access to the account (e.g., Security pulls the MFA and operations retrieves the root account password from your vault).

### #2 Has the root user been accessed recently?

In my example, I know that there haven't been any tickets that required usage of the root account in the last 90 days, so my credential report should reflect that the account hasn't been accessed in the same time period.

<Terminal mode="light">
  <TerminalCommand>
    {`select
  user_name,
  password_last_used,
  age(date(current_timestamp), date(password_last_used)) as pw_last_used
from
  aws_iam_credential_report
where
  user_name = '<root_account>';`}
  </TerminalCommand>
  <TerminalResult>
{`+----------------+---------------------+-----------------------+
| user_name      | password_last_used  | pw_last_used          |
+----------------+---------------------+-----------------------+
| <root_account> | 2019-07-17 04:49:39 | 1 year 6 mons 23 days |
+----------------+---------------------+-----------------------+`}
  </TerminalResult>
</Terminal>


### #3 Does the root account have multi-factor authentication (MFA) enabled?

Seems self-explanatory that the Root Account should have a MFA device associated with it.

<Terminal mode="light">
  <TerminalCommand>
    {`select
  user_name,
  mfa_active
from
  aws_iam_credential_report
where
  user_name = '<root_account>';`}
  </TerminalCommand>
  <TerminalResult>
{`+----------------+------------+
| user_name      | mfa_active |
+----------------+------------+
| <root_account> | true       |
+----------------+------------+`}
  </TerminalResult>
</Terminal>

### #4 Does the root account have access keys enabled?

Root accounts should never be used for programmatic access, so no access keys should exist.

<Terminal mode="light">
  <TerminalCommand>
    {`select
  user_name,
  access_key_1_active,
  access_key_2_active
from
  aws_iam_credential_report
where
  user_name = '<root_account>';`}
  </TerminalCommand>
  <TerminalResult>
{`+----------------+---------------------+---------------------+
| user_name      | access_key_1_active | access_key_2_active |
+----------------+---------------------+---------------------+
| <root_account> | false               | false               |
+----------------+---------------------+---------------------+`}
  </TerminalResult>
</Terminal>
<br />
<br />

# IAM User Account Checks

If you allow IAM users to be created in your account (many organizations do not), there are also a number of best practices checks to do for those users.

### #5 Are there any users with access keys and console credentials?

Users should either be console users or API users, not both; check for users with both console credentials and programmatic credentials (access keys). 

<Terminal mode="light">
  <TerminalCommand>
    {`select
  user_name,
  password_enabled,
  access_key_1_active,
  access_key_2_active
from
  aws_iam_credential_report
where
  password_enabled
  and (
    access_key_1_active
    or access_key_2_active
  );`}
  </TerminalCommand>
  <TerminalResult>
{`+----------------+------------------+---------------------+---------------------+
| user_name      | password_enabled | access_key_1_active | access_key_2_active |
+----------------+------------------+---------------------+---------------------+
| dwight_schrute | true             | true                | false               |
+----------------+------------------+---------------------+---------------------+`}
  </TerminalResult>
</Terminal>

### #6 Check for inactive users and users that have never logged in.

Find and delete any accounts where the users have passwords but have never logged in and accounts that haven't been used in last 90 days.

<Terminal mode="light">
  <TerminalCommand>
    {`select 
  user_name,
  password_enabled,
  password_last_used,
  age(date(current_timestamp), date(password_last_used)) as last_used_age
from
  aws_iam_credential_report
where
  user_name != '<root_account>'
  and password_enabled
  and (
    password_last_used is null
    or (date(current_timestamp) - date(password_last_used)) > 90
  );`}
  </TerminalCommand>
  <TerminalResult>
{`+----------------+------------------+---------------------+-----------------------+
| user_name      | password_enabled | password_last_used  | pw_last_used          |
+----------------+------------------+---------------------+-----------------------+
| dwight_schrute | true             |                     |                       |
| kelly_kapoor   | true             |                     |                       |
| ryan_howard    | true             |                     |                       |
| pam_beesly     | true             | 2019-07-17 04:49:39 | 1 year 6 mons 23 days |
+----------------+------------------+---------------------+-----------------------+`}
  </TerminalResult>
</Terminal>

### #7 Find any users with passwords that have not been rotated.

For users with password, they should be rotated based on company policy, in this case 90 days.

<Terminal mode="light">
  <TerminalCommand>
    {`select 
  user_name,
  password_last_changed,
  age(date(current_timestamp), date(password_last_changed)) as pw_last_changed
from
  aws_iam_credential_report
where
  user_name != '<root_account>'
  and password_enabled
  and (date(current_timestamp) - date(password_last_changed)) > 90;`}
  </TerminalCommand>
  <TerminalResult>
{`+----------------+-----------------------+-------------------+
| user_name      | password_last_changed | pw_last_changed   |
+----------------+-----------------------+-------------------+
| ryan_howard    | 2020-10-25 19:26:22   | 3 months, 15 days |
| kelly_kapoor   | 2020-09-22 19:13:23   | 4 months, 18 days |
| dwight_schrute | 2020-01-12 19:10:51   | 1 year, 28 days   |
+----------------+-----------------------+-------------------+`}
  </TerminalResult>
</Terminal>

### #8 Is MFA enabled for all users?

Identify users that are not using multi-factor authentication (MFA).

<Terminal mode="light">
  <TerminalCommand>
    {`select
  user_name,
  mfa_active
from
  aws_iam_credential_report
where
  not mfa_active;`}
  </TerminalCommand>
  <TerminalResult>
{`+----------------+------------+
| user_name      | mfa_active |
+----------------+------------+
| darryl_philbin | false      |
| ryan_howard    | false      |
| dwight_schrute | false      |
| kelly_kapoor   | false      |
+----------------+------------+`}
  </TerminalResult>
</Terminal>

### #9 Are access keys being rotated?

For users with access keys, they should be rotated based on company policy, in this case 90 days.

<Terminal mode="light">
  <TerminalCommand>
    {`select
  user_name,
  access_key_1_active,
  age(
    date(current_timestamp),
    date(access_key_1_last_rotated)
  ) as key1_last_changed,
  access_key_2_active,
  age(
    date(current_timestamp),
    date(access_key_2_last_rotated)
  ) as key2_last_changed
from
  aws_iam_credential_report
where
  (
    access_key_1_active
    and (
      date(current_timestamp) - date(access_key_1_last_rotated)
    ) > 90
  )
  or (
    access_key_2_active
    and (
      date(current_timestamp) - date(access_key_2_last_rotated)
    ) > 90
  );`}
  </TerminalCommand>
  <TerminalResult>
{`+------------+---------------------+-------------------+---------------------+-------------------+
| user_name  | access_key_1_active | key1_last_changed | access_key_2_active | key2_last_changed |
+------------+---------------------+-------------------+---------------------+-------------------+
| pam_beesly | true                | 7 mons 21 days    | true                | 2 mons 6 days     |
+------------+---------------------+-------------------+---------------------+-------------------+`}
  </TerminalResult>
</Terminal>

### #10 Can you find any users with unused access keys?

For users with access keys, they should be in active use. Let's find any users with access keys that have not been used in the last 30 days or that have never been used.

<Terminal mode="light">
  <TerminalCommand>
    {`select
  user_name,
  access_key_1_last_used_date,
  age(
    date(current_timestamp),
    date(access_key_1_last_used_date)
  ) as key1_last_used,
  access_key_2_last_used_date,
  age(
    date(current_timestamp),
    date(access_key_2_last_used_date)
  ) as key2_last_used
from
  aws_iam_credential_report
where
  (
    access_key_1_active
    and (
      access_key_1_last_used_date is null
      or (
        date(current_timestamp) - date(access_key_1_last_used_date)
      ) > 30
    )
  )
  or (
    access_key_2_active
    and (
      access_key_2_last_used_date is null
      or(
        date(current_timestamp) - date(access_key_2_last_used_date)
      ) > 30
    )
  );`}
  </TerminalCommand>
  <TerminalResult>
{`+----------------+----------------------+----------------+----------------------+----------------+
| user_name      | key_1_last_used_date | key1_last_used | key_2_last_used_date | key2_last_used |
+----------------+----------------------+----------------+----------------------+----------------+
| darryl_philbin |                      |                |                      |                |
| pam_beesly     | 2021-02-08 12:22:00  | 1 days         | 2020-12-03 01:33:00  | 2 mons 6 days  |
+----------------+----------------------+----------------+----------------------+----------------+`}
  </TerminalResult>
</Terminal>
<br />
In this case Darryl has an access key, but has never used it, Pam on the other hand has two access keys, 
one in active use and another that hasn't been used in 66 days.

### Conclusion

SQL makes it easy to inspect your [AWS IAM Credential Report](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_getting-report.html) and to run routine checks for common IAM user compliance issues; best of all Steampipe is 100% open source and [available for download today](https://steampipe.io/downloads). Install, query and get cloud work done with Steampipe. 

Subscribe to our newsfeed https://news.steampipe.io for the latest supported resource types from both Turbot and the Steampipe community, and for your own personal guided tour of steampipe, checkout our documentation: https://steampipe.io/docs.

If you experience any issues, please report them on our [GitHub issue tracker](https://github.com/turbot/steampipe/issues) or join our [Slack workspace](https://steampipe.io/community/join).