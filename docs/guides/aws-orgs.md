---
title: Best Practices with AWS Organizations
sidebar_label: AWS Organizations
---

# Using Steampipe CLI with AWS Organizations

## Statement of Problem

As a security practitioner, you may need to answer a question about your entire cloud estate. Depending on the organization, this could entail hundreds or even thousands of AWS accounts and, with mergers and acquisitions, multiple payers.  While we often demonstrate the power of Steampipe with simple experimental examples, you can also use it across a large enterprise.

There are some considerations when querying hundreds of accounts across all the regions. Steampipe has to have both a [_connection_](https://hub.steampipe.io/plugins/turbot/aws#configuration) defining the specific AWS accounts and an [AWS Credential _profile_](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html#cli-configure-files-settings) that defines how credentials for the connection are obtained. In a large or dynamic environment, you might have multiple accounts created or closed in any given week. Manually managing the profiles and connections can lead to mistakes and blindspots in your organization, so it's critical that these are kept up to date.

This guide also assumes you want to query across all the regions. Why would you do that? A global company is probably going to have a global footprint. Your APAC division probably uses the Singapore and Tokyo regions. Your Italian subsidiary wants to enable eu-south-1. That Oslo acquisition you just made deployed all its infrastructure in eu-north-1. You must assume you have infrastructure in every AWS Region at a certain point. It's why [AWS tells you to enable GuardDuty](https://docs.aws.amazon.com/guardduty/latest/ug/guardduty_settingup.html#setup-before), CloudTrail, and IAM Access Analyzer in all the regions, not just the ones you think you have deployed resources into.

## Three ways to query your whole AWS Organization.

This guide will offer three scenarios for accessing all of your AWS accounts.

1. [Leverage AWS SSO](#aws-sso-for-local-workstation) for every AWS account. This use case works when you're running from your local machine and either don't have a cross-account audit role or don't plan to automate your queries.
2. [Leverage local credentials](#local-authentication-with-a-cross-account-role) to authenticate to a security or audit account, then leverage [a cross-account role](https://docs.aws.amazon.com/whitepapers/latest/organizing-your-aws-environment/security-ou-and-accounts.html#security-read-only-access-account) that is deployed to all your accounts. This option is ideal when you're working from your local machine but have access to a centralized security account with an audit role.
3. [Leverage an EC2 Instance](#ec2-instance) in the security/audit account to assume the cross-account audit role. This is the option if you want to leverage Steampipe in an automated fashion, like to [pull data to feed Splunk lookup tables](https://steampipe.io/blog/splunk-lookup-tables).

Each example provided below will create a [steampipe configuration file](https://hub.steampipe.io/plugins/turbot/aws#multi-account-connections) that will query _all_ your accounts by default. Each connection (i.e. account) is prefixed with `aws_`, and all the aws [connections are aggregated](https://steampipe.io/docs/using-steampipe/managing-connections#using-aggregators) via the wildcard `connections = ["aws_*"]` which is placed in the front of the [search path](https://steampipe.io/docs/managing/connections#setting-the-search-path).

In each scenario, the steampipe spc file will look like this:

```hcl
# Create an aggregator of _all_ the accounts as the first entry in the search path.
connection "aws" {
  plugin = "aws"
  type = "aggregator"
  connections = ["aws_*"]
}

connection "aws_fooli_sandbox" {
  plugin  = "aws"
  profile = "fooli-sandbox"
  regions = ["*"]
}

connection "aws_fooli_payer" {
  plugin  = "aws"
  profile = "fooli-payer"
  regions = ["*"]
}
```

## How AWS Plugin Authentication works

There are many ways to [configure credentials](https://hub.steampipe.io/plugins/turbot/aws#credentials) for the [AWS Plugin](https://hub.steampipe.io/plugins/turbot/aws), but once you move beyond a single AWS Account in Steampipe, each connection in the aws.spc configuration file [references a profile](https://hub.steampipe.io/plugins/turbot/aws#assumerole-credentials-no-mfa) in the `~/.aws/config` file.

### AWS SSO (for local workstation)

In this scenario, we need to authenticate to AWS SSO, then get a list of the AWS Accounts and AWS SSO roles available to the user. This is done via four obscure commands:

1. `aws sso-oidc register-client` - creates a client for use in the next steps
2. `aws sso-oidc start-device-authorization` - manually create the redirection to the browser that you see when you do the normal `aws sso login`
3. `aws sso-oidc create-token` - Creates the SSO Authentication token once the user has authorized the connection via AWS Identity Center and their identity provider
4. `aws sso list-accounts` - leveraging the token from the previous command, this lists all the accounts and roles the user is allowed to access in AWS Identity Center.

We can build the `aws.spc` connection file and the AWS configuration file with the list of accounts and roles the user is authorized to access. This is what you should see when executing the script:

```bash
./generate_config_for_sso.sh fooli security-audit ~/.steampipe/config/aws.spc ~/.aws/fooli-config
https://device.sso.us-east-1.amazonaws.com/?user_code=HVWL-TLBX was opened in your browser. Please click allow.
Press Enter when complete

Creating Steampipe Connections in /Users/chris/.steampipe/config/aws.spc and AWS Profiles in /Users/chris/.aws/fooli-config
````

The resulting AWS Config file will look like this:
```
[profile fooli-dev]
sso_start_url = https://fooli.awsapps.com/start
sso_region = us-east-1
sso_account_id = 876653597426
sso_role_name = security-audit

[profile fooli-security]
sso_start_url = https://fooli.awsapps.com/start
sso_region = us-east-1
sso_account_id = 345349965289
sso_role_name = security-audit

[profile fooli-memefactory]
sso_start_url = https://fooli.awsapps.com/start
sso_region = us-east-1
sso_account_id = 740117037951
sso_role_name = security-audit
```

You can either merge this file into your existing `~/.aws/config` file, or set the `AWS_CONFIG_FILE` environment variable to the file that's created from above.

### Local Authentication with a cross-account role

In this scenario, you're still running from a local workstation and using your existing authentication methods to the trusted security account. This could be an IAM User; temporary credentials provided by [aws-gimme-creds](https://github.com/Nike-Inc/gimme-aws-creds) or AWS SSO.  All other connections will leverage a cross-account audit role. This [sample script](FIXME/generate_config_for_sso.sh) will generate an AWS config file that can be _included_ in your `~/.aws/config`. It will also generate the `aws.spc` file with all of the AWS accounts and a default aggregator.

The usage for the script is as follows:

```
Usage: ./generate_config_for_cross_account_roles.sh [IMDS | SSO ] <AUDITROLE> <AWS_CONFIG_FILE> <SSO_PROFILE>
```

Note: this script will not append or overwrite the default `~/.aws/config` file. While we try and prevent conflicts by prefixing all the profiles with `sp_`, you will want to reconcile what is generated with the other profiles in your  `~/.aws/config` file or the aws CLI will fail to run.

When merged, your aws config file should look like this:

```
[default]
signature_version=s3v4
output=json
cli_history=enabled
region=us-east-1
cli_pager=

[profile fooli-security]
sso_start_url = https://fooli.awsapps.com/start
sso_region = us-east-1
sso_account_id = 352894534996
sso_role_name = AdministratorAccess
region = us-east-1

# <other pre-existing profiles>

[profile sp_fooli-payer]
role_arn = arn:aws:iam::540147993428:role/fooli-audit
source_profile = fooli-security
role_session_name = steampipe

[profile sp_fooli-sandbox]
role_arn = arn:aws:iam::755629548949:role/fooli-audit
source_profile = fooli-security
role_session_name = steampipe

[profile sp_fooli-security]
role_arn = arn:aws:iam::352894534996:role/fooli-audit
source_profile = fooli-security
role_session_name = steampipe
```

And the resulting aws.spc file will look like this:

```hcl
# Automatically Generated at Thu Oct 20 16:26:19 EDT 2022

# Create an aggregator of _all_ the accounts as the first entry in the search path.
connection "aws" {
  plugin = "aws"
  type        = "aggregator"
  connections = ["aws_*"]
}

connection "aws_fooli_payer" {
  plugin  = "aws"
  profile = "sp_fooli-payer"
  regions = ["*"]
}

connection "aws_fooli_sandbox" {
  plugin  = "aws"
  profile = "sp_fooli-sandbox"
  regions = ["*"]
}

connection "aws_fooli_security" {
  plugin  = "aws"
  profile = "sp_fooli-security"
  regions = ["*"]
}
```


### EC2 Instance

With an EC2 Instance running Steampipe, we can leverage the [EC2 Instance Metadata Service](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-instance-metadata.html)(IMDS) to generate temporary credentials from the [Instance Profile](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/iam-roles-for-amazon-ec2.html). As in the previous example, the [sample script](FIXME/generate_config_for_cross_account_roles.sh) will generate an AWS Config file and an aws.spc file. The aws.spc file will be the same as the other scenarios.

```bash
./generate_config_for_cross_account_roles.sh IMDS fooli-audit fooli-config
```

The AWS config file will contain an entry for every account in the AWS Organization. Those entries will all look like:

```
[profile sp_fooli-memefactory]
role_arn = arn:aws:iam::102225541131:role/fooli-audit
credential_source = Ec2InstanceMetadata
role_session_name = steampipe
```

Note that we use `credential_source=Ec2InstanceMetadata` rather than `source_profile`.

Here we tell the Plugin to use the EC2 Instance Metadata credentials to assume to `fooli-audit` role in the `102225541131` account, and use `steampipe` as the [RoleSessionName](https://docs.aws.amazon.com/STS/latest/APIReference/API_AssumeRole.html#:~:text=RoleSessionName,assumed%20role%20session.). Because there is no dependency on a pre-configured `~/.aws/config` file, we can confidently overwrite the config files on each execution of the script. This would be safe to run as a cron job every few hours like so:

```bash
 ./generate_config_for_cross_account_roles.sh IMDS fooli-audit ~/.aws/config
 ```

## Extending this pattern to multiple AWS Organizations.

At some point, you will find yourself with a second AWS organization. Maybe you created a new organization to test Service Control Policies. Or you've acquired another company and can't migrate accounts until your legal department, and AWS's legal department agree to update terms or adjust spending commitments.

How can you leverage the above patterns across multiple AWS Organizations? We can adjust our pattern above slightly. You'll need to ensure all the accounts in each organization have the same cross-account role that trusts the same centralized security account.

Since we have to do an assume-role to get the account list from each organizations, this [sample script](FIXME/generate_config_for_multipayer.py) is in python. The usage is:

```bash
usage: generate_config_for_multipayer.py [-h] [--debug]
                                         [--aws-config-file AWS_CONFIG_FILE]
                                         [--steampipe-connection-file STEAMPIPE_CONNECTION_FILE]
                                         --rolename ROLENAME
                                         --payers PAYERS [PAYERS ...]
                                         [--role-session-name ROLE_SESSION_NAME]
```

The configuration files from that script look like the previous example, except we've added a new aggregator for the payers like so:

```hcl
connection "aws_payer" {
  plugin = "aws"
  type = "aggregator"
  regions = ["us-east-1"] # This aggregator is only used for global queries
  connections = ["aws_fooli_payer", "aws_pht_payer"]
}
```

This script is also idempotent - you can run it regularly and it will safely overwrite the existing configuration files like so:
```bash
generate_config_for_multipayer.py --aws-config-file ~/.aws/config \
                 --steampipe-connection-file ~/.steampipe/config/aws.spc \
                 --rolename fooli-audit \
                 --payers 123456789012 210987654321 \
                 --role-session-name steampipe
```

## Using these scenarios

In all three examples, the default connection is the [aggregation of all accounts](https://steampipe.io/docs/managing/connections#using-aggregators). So this SQL query will provide a list of all the instances in every account and region.:

```sql
select instance_id, region, account_id,
tags ->> 'Name' as name
from aws_ec2_instance;
```

You can use the connection name and table to see results for a specific account.

```sql
select instance_id, region, account_id, tags ->> 'Name' as name
from aws_minecraft.aws_ec2_instance;
```

You can reference the connection `aws_payer` for queries to the AWS Organization service. Here we join all the aws_ec2_instance tables with the organizations_account table that's only in the payer account.

```sql
select ec2.instance_id, ec2.region, ec2.account_id,
  org.name as account_name,
ec2.tags ->> 'Name' as instance_name
from aws_ec2_instance as ec2,
  aws_payer.aws_organizations_account as org
where org.id = ec2.account_id;
```

## Conclusion

There you have it. Three ways to automate the management of AWS config and Steampipe connection files to run queries, benchmarks, and dashboards across your entire enterprise AWS footprint. Are you responsible for the security of a large cloud footprint? Have you built new ways to scale and improve your practices?  If so, please [let us know](https://steampipe.io/community/join): we love to collaborate with our community!


