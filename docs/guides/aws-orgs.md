---
title: Best Practices with AWS Organizations
sidebar_label: Integrating AWS Organizations
---

# Using Steampipe CLI with AWS Organizations

There are some considerations when querying hundreds of accounts across all the regions. Steampipe has to have both a [_connection_](https://hub.steampipe.io/plugins/turbot/aws#configuration) defining the specific AWS accounts and an [AWS Credential _profile_](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html#cli-configure-files-settings) that defines how credentials for the connection are obtained. In a large or dynamic environment, you might have multiple accounts created or closed in any given week. Manually managing the profiles and connections can lead to mistakes and blindspots in your organization, so it's critical that these are kept up to date.

This guide also assumes you want to query across all the regions. Why would you do that? A global company is probably going to have a global footprint. Your APAC division probably uses the Singapore and Tokyo regions. Your Italian subsidiary wants to enable eu-south-1. That Oslo acquisition you just made deployed all its infrastructure in eu-north-1. You must assume you have infrastructure in every AWS Region at a certain point. It's why [AWS tells you to enable GuardDuty](https://docs.aws.amazon.com/guardduty/latest/ug/guardduty_settingup.html#setup-before), CloudTrail, and IAM Access Analyzer in all the regions, not just the ones you think you have deployed resources into.

## Three ways to query all your AWS Accounts.

This guide will offer three scenarios for accessing all of your AWS accounts using [cross-account roles](https://docs.aws.amazon.com/IAM/latest/UserGuide/tutorial_cross-account-with-roles.html).

1. Leverage local credentials to authenticate and assume the cross-account role in a single AWS Organization.
2. Leverage EC2 Instance credentials to authenticate and assume the cross-account role in a single AWS Organization.
3. Leverage EC2 Instance credentials to authenticate and assume the same cross-account role in multiple AWS Organizations.

Why cross-account roles? Simply put, they are AWS best-practice for accessing multiple AWS accounts. [AWS recommends](https://docs.aws.amazon.com/accounts/latest/reference/credentials-access-keys-best-practices.html) customers leverage roles over long-term access keys. [AWS Identity Center](https://aws.amazon.com/iam/identity-center/) (formerly known as AWS Single Sign On or SSO) works for a small number of accounts, but as an end-user, you must run `aws sso login` for each account.

This guide recommends implementing a [Security view-only access](https://docs.aws.amazon.com/whitepapers/latest/organizing-your-aws-environment/security-ou-and-accounts.html#security-read-only-access-account) AWS Account. All of the other accounts in your AWS Organization(s) should have a security-audit role that trusts the security account.

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

The primary difference is how the AWS config file is generated.

If Steampipe is leveraging local credentials to assume the security-audit role:
```
[profile sp_fooli-sandbox]
role_arn = arn:aws:iam::111111111111:role/security-audit
source_profile = fooli-security
role_session_name = steampipe
```

If Steampipe is leveraging the EC2 Instance Credentials to assume the security-audit role:
```
[profile sp_fooli-sandbox]
role_arn = arn:aws:iam::111111111111:role/security-audit
credential_source = Ec2InstanceMetadata
role_session_name = steampipe
```

-----


## How to run these scripts

### Local Authentication with a cross-account role

In this scenario, you're running from a local workstation and using your existing authentication methods to the trusted security account. This could be an IAM User; temporary credentials provided by [aws-gimme-creds](https://github.com/Nike-Inc/gimme-aws-creds) or AWS SSO.  All other connections will leverage a cross-account audit role.

1. You need to dedicate one account in your AWS Organization for the purposes of auditing all the other accounts (the "audit account"). You then need to deploy an IAM Role (the "security-audit role") in all AWS accounts that trusts the audit account.
2. Clone the [steampipe-samples](https://github.com/turbot/steampipe-samples) repo.
```bash
git clone https://github.com/turbot/steampipe-samples.git
cd steampipe-samples/all/aws-organizations-scripts
```
3. Run the `generate_config_for_cross_account_roles.sh` script.
```bash
./generate_config_for_cross_account_roles.sh LOCAL security-audit ~/.aws/fooli-config fooli-security
```
  * In the above example `LOCAL` is the method of authentication.
  * `security-audit` is the name of the cross-account role you have access to
  * `~/.aws/fooli-config` is the location of the AWS config file
  * `fooli-security` is the name of an _existing_ AWS profile in the audit account that can assume the `security-audit` role
4. Before adding the contents of the `~/.aws/fooli-config` file to your `~/.aws/config`, you want to make sure there are no duplicate `[profile <name>]` blocks in either file.

**Note:** this script will not append or overwrite the default `~/.aws/config` file. While we try and prevent conflicts by prefixing all the profiles with `sp_`, you will want to reconcile what is generated with the other profiles in your  `~/.aws/config` file or the aws CLI may fail to run.

You can override the default `~/.aws/config` file with the [`AWS_CONFIG_FILE`](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html#cli-configure-files-where) environment variable. If you do that, you will need make sure to define the `source_profile` in the generated config file.

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
  * In the above example `IMDS` is the method of authentication.
  * `security-audit` is the name of the Cross Account Role you have access to
  * `~/.aws/fooli-config` is the location of the AWS config file
4. Verify the contents of the `~/.aws/fooli-config` and copy or append it to `~/.aws/config`. Unlike the above example, you do not need to ensure there is a source_profile defined. Running the script in IMDS mode can be made idempotent.

### ECS Task

With an ECS task running Steampipe, we can leverage the [ECS task role](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-iam-roles.html) to leverage the required permissions and assume the cross account role.

1. You need to dedicate one account in your AWS Organization for the purposes of auditing all the other accounts (the "audit account"). You then need to deploy an IAM Role (the "security-audit role") in all AWS accounts that trusts the audit account.
2. Deploy an ECS task in the audit account, and attach a Task IAM role with permission to `iam:AssumeRole` the security-audit role.
2. Clone the [steampipe-samples](https://github.com/turbot/steampipe-samples) repo.
```bash
git clone https://github.com/turbot/steampipe-samples.git
cd steampipe-samples/all/aws-organizations-scripts
```
3. Run the `generate_config_for_cross_account_roles.sh` script.
```bash
./generate_config_for_cross_account_roles.sh ECS security-audit ~/.aws/fooli-config
```
  * In the above example `ECS` is the method of authentication.
  * `security-audit` is the name of the Cross Account Role you have access to
  * `~/.aws/fooli-config` is the location of the AWS config file
4. Verify the contents of the `~/.aws/fooli-config` and copy or append it to `~/.aws/config`. Unlike the above example, you do not need to ensure there is a source_profile defined. Running the script in IMDS mode can be made idempotent.


### Multiple AWS Organizations

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
