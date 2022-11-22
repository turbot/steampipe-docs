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

1. [Leverage AWS SSO](#aws-sso-for-local-workstation) (recently renamed to AWS Identity Center) for every AWS account. This use case works when you're running from your local machine and either don't have a cross-account audit role or don't plan to automate your queries.
2. [Leverage local credentials](#local-authentication-with-a-cross-account-role) to authenticate to a security or audit account, then leverage [a cross-account role](https://docs.aws.amazon.com/whitepapers/latest/organizing-your-aws-environment/security-ou-and-accounts.html#security-read-only-access-account) that is deployed to all your accounts. This option is ideal when you're working from your local machine but have access to a centralized security account with an audit role.
3. [Leverage an EC2 Instance](#ec2-instance) in the security/audit account to assume the cross-account audit role. This is the option if you want to leverage Steampipe in an automated fashion, like to [pull data to feed Splunk lookup tables](https://steampipe.io/blog/splunk-lookup-tables).

Each example provided below will create a [Steampipe configuration file](https://hub.steampipe.io/plugins/turbot/aws#multi-account-connections) that will query _all_ your accounts by default. Each connection (i.e. account) is prefixed with `aws_`, and all the aws [connections are aggregated](https://steampipe.io/docs/using-steampipe/managing-connections#using-aggregators) via the wildcard `connections = ["aws_*"]` which is placed in the front of the [search path](https://steampipe.io/docs/managing/connections#setting-the-search-path).

In each scenario, the Steampipe spc file will look like this:

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

The primary difference is how the AWS config file is generated. If you're leveraging AWS SSO, the config will look like:

```
[profile fooli-sandbox]
sso_start_url = https://fooli.awsapps.com/start
sso_region = us-east-1
sso_account_id = 111111111111
sso_role_name = AdministratorAccess
region = us-east-1
```

If you're using cross account roles with local credentials via AWS SSO, then you need both the AWS SSO profile, and each account profile that references the AWS SSO profile. As an example:
```
[profile fooli-security]
sso_start_url = https://fooli.awsapps.com/start
sso_region = us-east-1
sso_account_id = 222222222222
sso_role_name = AdministratorAccess

[profile sp_fooli-sandbox]
role_arn = arn:aws:iam::111111111111:role/fooli-audit
source_profile = fooli-security
role_session_name = steampipe
```

Finally, if all the AWS accounts are running in an EC2 Instance that has permission to assume that cross-account role, you would use `credential_source = Ec2InstanceMetadata` rather than `source_profile =` like so:
```
[profile sp_fooli-sandbox]
role_arn = arn:aws:iam::111111111111:role/fooli-audit
credential_source = Ec2InstanceMetadata
role_session_name = steampipe

[profile sp_fooli-security]
role_arn = arn:aws:iam::222222222222:role/fooli-audit
credential_source = Ec2InstanceMetadata
role_session_name = steampipe
```


## How to run these scripts


### AWS Identity Center / AWS SSO

1. Clone the [steampipe-samples](https://github.com/turbot/steampipe-samples) repo.
```bash
git clone https://github.com/turbot/steampipe-samples.git
cd steampipe-samples/all/aws-organizations-scripts
```
2. Run the `generate_config_for_sso.sh` script.
```bash
./generate_config_for_sso.sh fooli security-audit ~/.steampipe/config/aws.spc ~/.aws/fooli-config
https://device.sso.us-east-1.amazonaws.com/?user_code=HVWL-TLBX was opened in your browser. Please click allow.
Press Enter when complete

Creating Steampipe Connections in /Users/chris/.steampipe/config/aws.spc and AWS Profiles in /Users/chris/.aws/fooli-config
```
  * In the above example fooli is the AWS SSO Prefix from the start URL: `https://fooli.awsapps.com/start`
  * `security-audit` is the name of the AWS SSO Role you have access to
  * `~/.steampipe/config/aws.spc` is the output location of the Steampipe connection file
  * `~/.aws/fooli-config` is the location of the AWS config file
3. Before adding the contents of the `~/.aws/fooli-config` file to your `~/.aws/config`, you want to make sure there are no duplicate `[profile <name>]` blocks in either file.

### Local Authentication with a cross-account role

In this scenario, you're still running from a local workstation and using your existing authentication methods to the trusted security account. This could be an IAM User; temporary credentials provided by [aws-gimme-creds](https://github.com/Nike-Inc/gimme-aws-creds) or AWS SSO.  All other connections will leverage a cross-account audit role.

1. You need to dedicate one account in your AWS Organization for the purposes of auditing all the other accounts (the "audit account"). You then need to deploy an IAM Role (the "security-audit role") in all AWS accounts that trusts the audit account.
2. Clone the [steampipe-samples](https://github.com/turbot/steampipe-samples) repo.
```bash
git clone https://github.com/turbot/steampipe-samples.git
cd steampipe-samples/all/aws-organizations-scripts
```
3. Run the `generate_config_for_cross_account_roles.sh` script.
```bash
./generate_config_for_cross_account_roles.sh SSO security-audit ~/.aws/fooli-config fooli-security
```
  * In the above example `SSO` is the method of authentication.
  * `security-audit` is the name of the Cross Account Role you have access to
  * `~/.aws/fooli-config` is the location of the AWS config file
  * `fooli-security` is the name of an _existing_ AWS profile in the audit account that can assume the `security-audit` role
4. Before adding the contents of the `~/.aws/fooli-config` file to your `~/.aws/config`, you want to make sure there are no duplicate `[profile <name>]` blocks in either file.

Note: this script will not append or overwrite the default `~/.aws/config` file. While we try and prevent conflicts by prefixing all the profiles with `sp_`, you will want to reconcile what is generated with the other profiles in your  `~/.aws/config` file or the aws CLI will fail to run.

### EC2 Instance

With an EC2 Instance running Steampipe, we can leverage the [EC2 Instance Metadata Service](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-instance-metadata.html)(IMDS) to generate temporary credentials from the [Instance Profile](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/iam-roles-for-amazon-ec2.html).

1. You need to dedicate one account in your AWS Organization for the purposes of auditing all the other accounts (the "audit account"). You then need to deploy an IAM Role (the "security-audit role") in all AWS accounts that trusts the audit account.
2. Deploy an EC2 Instance in the audit account, and attach an IAM Instance Profile that has a role with permission to `iam:AssumeRole` the security-audit role.
2. Clone the [steampipe-samples](https://github.com/turbot/steampipe-samples) repo.
```bash
git clone https://github.com/turbot/steampipe-samples.git
cd steampipe-samples/all/aws-organizations-scripts
```
3. Run the `generate_config_for_cross_account_roles.sh` script.
```bash
./generate_config_for_cross_account_roles.sh IMDS security-audit ~/.aws/fooli-config
```
  * In the above example `SSO` is the method of authentication.
  * `security-audit` is the name of the Cross Account Role you have access to
  * `~/.aws/fooli-config` is the location of the AWS config file
4. Verify the contents of the `~/.aws/fooli-config` and copy or append it to `~/.aws/config`


## Extending this pattern to multiple AWS Organizations.

At some point, you will find yourself with a second AWS organization. Maybe you created a new organization to test Service Control Policies. Or you've acquired another company and can't migrate accounts until your legal department, and AWS's legal department agree to update terms or adjust spending commitments.

How can you leverage the above patterns across multiple AWS Organizations? We can adjust our pattern above slightly. You'll need to ensure all the accounts in each organization have the same cross-account role (the "security-audit role") that trusts the same centralized audit account.

Since we have to do an assume-role to get the account list from each organizations, this script is in python. The usage is:

```bash
usage: generate_config_for_multipayer.py [-h] [--debug]
                                         [--aws-config-file AWS_CONFIG_FILE]
                                         [--steampipe-connection-file STEAMPIPE_CONNECTION_FILE]
                                         --rolename ROLENAME
                                         --payers PAYERS [PAYERS ...]
                                         [--role-session-name ROLE_SESSION_NAME]
```

1. You need to dedicate one account in one of your AWS Organization for the purposes of auditing all the other accounts (the "central audit account"). You then need to deploy an IAM Role (the "security-audit role") in all AWS accounts in every organization that trusts the central audit account.
2. Deploy an EC2 Instance in the central audit account, and attach an IAM Instance Profile that has a role with permission to `iam:AssumeRole` the security-audit role.
2. Clone the [steampipe-samples](https://github.com/turbot/steampipe-samples) repo.
```bash
git clone https://github.com/turbot/steampipe-samples.git
cd steampipe-samples/all/aws-organizations-scripts
```
3. Run the `generate_config_for_multipayer.py` script.
```bash
generate_config_for_multipayer.py --aws-config-file ~/.aws/config \
                 --steampipe-connection-file ~/.steampipe/config/aws.spc \
                 --rolename security-audit \
                 --payers 123456789012 210987654321 \
                 --role-session-name steampipe
```


## Queries with these scenarios

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


