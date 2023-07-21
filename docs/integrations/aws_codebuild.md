---
title: Using Steampipe in AWS CodeBuild
sidebar_label: AWS CodeBuild
---

# Using Steampipe in AWS CodeBuild

AWS [CodeBuild](https://aws.amazon.com/codebuild/) is a managed continuous integration service that can build code and run tests. All AWS customers get [100 minutes of free usage](https://aws.amazon.com/codebuild/pricing/?loc=ft#Free_Tier) of AWS CodeBuild each month. Let's install Steampipe into a CodeBuild Project, then install a plugin and mod, then test some terraform code.

## Installing Steampipe in CodeBuild

Installing Steampipe in CodeBuild is easy. CodeBuild uses [buildspec files](https://docs.aws.amazon.com/codebuild/latest/userguide/build-spec-ref.html) to define how the build should be done.

By default, CodeBuild runs as root in the build container. However for security reasons, Steampipe will not run as root. We will need to install and run Steampipe as a non-root user. Here is a `buildspec.yaml` file that would install Steampipe ([link](https://github.com/turbot/steampipe-samples/blob/main/all/aws-codebuild/steampipe-buildspec.yaml)):

```yaml
version: 0.2

phases:
  install:
    run-as: codebuild-user
    commands:
      # Each CodeBuild container is ephemeral - We need to install steampipe every time
      - curl -s -L https://github.com/turbot/steampipe/releases/latest/download/steampipe_linux_amd64.tar.gz | tar -xzf -
      - echo "installed steampipe"
      - ./steampipe plugin install terraform
      - git clone https://github.com/turbot/steampipe-mod-terraform-aws-compliance.git
```

This BuildSpec file will execute all the commands as `codebuild-user`. We install the `steampipe` binary directly from GitHub into the `codebuild-user`'s home directory. As part of the install phase we then install the terraform plugin with `./steampipe plugin install terraform` and clone the [steampipe-mod-terraform-aws-compliance mod](https://github.com/turbot/steampipe-mod-terraform-aws-compliance).

## Running Steampipe in CodeBuild

Running Steampipe in CodeBuild uses the same `run-as: codebuild-user` as the install step. Add this new phase to the buildspec file:

```yaml
  build:
    # Steampipe will return a non-zero exit code with the number of failed checks
    on-failure: CONTINUE
    run-as: codebuild-user
    commands:
      - ./steampipe --version # for debugging
      - export STEAMPIPE_MOD_LOCATION=`pwd`/steampipe-mod-terraform-aws-compliance
      - cd terraform ; ../steampipe check all --output html > steampipe_report.html

```

Because the `steampipe check all` command returns the number of violations and we want CodeBuild to exit cleanly, we add `on-failure: CONTINUE` to the build phase.

For the actual check, we just need to tell steampipe where to find the mod `export STEAMPIPE_MOD_LOCATION`, then we change directory to the terraform and run the  `steampipe check all` command. Since steampipe was installed in the parent directory of terraform, we call it as `../steampipe`.


## Using Turbot Pipes

CodeBuild can also integrate with [Turbot Pipes](https://turbot.com/pipes/docs) to push [snapshots](https://steampipe.io/docs/snapshots/overview) into your [workspace](https://turbot.com/pipes/docs/workspaces). To do this we make a few changes to the buildspec file.

First, we must add the environment variables to connect to Turbot Pipes (stored in Secrets Manager). Add this to the top of the file (before phases):
```yaml
env:
  # Store the cloud host, token and workspace in AWS Secrets Manager
  secrets-manager:
    STEAMPIPE_CLOUD_TOKEN: steampipe-cloud:STEAMPIPE_CLOUD_TOKEN
    WORKSPACE: steampipe-cloud:WORKSPACE
```

Next, replace the last line of the build with a call to Turbot Pipes:
```yaml
      - cd terraform ; ../steampipe check all --snapshot-location $WORKSPACE --snapshot --snapshot-title "Terraform Report"
```
This command will run steampipe and save the output of the check as "Terraform Report" in the specified Workspace. By default, the CLI looks for your Turbot Pipes token in the `STEAMPIPE_CLOUD_TOKEN` [environment variable](https://steampipe.io/docs/reference/env-vars/overview).

You can create your [Turbot Pipes token](https://turbot.com/pipes/docs/profile#tokens) via the Settings page (click on your avatar in the upper right). Once you have your token (which begins with `spt_`), you need to create the secret in [AWS Secrets Manager](https://aws.amazon.com/secrets-manager/):
```bash
aws secretsmanager create-secret --name steampipe-cloud --secret-string \
  '{"STEAMPIPE_CLOUD_TOKEN":"spt_PUTYOURTOKENHERE","WORKSPACE":"fooli"}'
```

You can find the entire buildspec file [here in our samples repository](https://github.com/turbot/steampipe-samples/blob/main/all/aws-codebuild/steampipe-cloud-buildspec.yaml).


That's it! Now you can use any of Steampipe's plugins and mods as part of your CodeBuild projects, either locally of leveraging the power of Turbot Pipes.

