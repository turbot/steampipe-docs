---
title: Using Steampipe in AWS CodeBuild
sidebar_label: AWS CodeBuild
---

# Using Steampipe in AWS CodeBuild

AWS [CodeBuild](https://aws.amazon.com/codebuild/) is a managed continuous integration service that can build code and run tests. All AWS customers get [100 minutes of free usage](https://aws.amazon.com/codebuild/pricing/?loc=ft#Free_Tier) of AWS CodeBuild each month. Let's install Steampipe into a CodeBuild Project, then install a plugin and mod, then test some terraform code.

<!-- AWS [CodePipeline](https://aws.amazon.com/codepipeline/) is a managed continuous delivery service to manage release pipelines for applications and infrastructure. -->

## Installing Steampipe in CodeBuild

Installing Steampipe in CodeBuild is easy. CodeBuild uses [buildspec files](https://docs.aws.amazon.com/codebuild/latest/userguide/build-spec-ref.html) to define how the build should be done.

By default, CodeBuild runs as root in the build container. However for security reasons, Steampipe will not run as root. We will need to install and run Steampipe as a non-root user. Here is a `buildspec.yaml` file that would install Steampipe:

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

Running streampipe in CodeBuild uses the same `run-as: codebuild-user` as the install step. Add this new phase to the buildspec file:

```yaml
  build:
    # Steampipe will return a non-zero exit code with the number of failed checks
    on-failure: CONTINUE
    run-as: codebuild-user
    commands:
      - ./steampipe --version # for debugging
      - export STEAMPIPE_WORKSPACE_CHDIR=`pwd`/steampipe-mod-terraform-aws-compliance
      - cd terraform ; ../steampipe check all --output html > steampipe_report.html

```

Because the `steampipe check all` command returns the number of violations and we want CodeBuild to exit cleanly, we add `on-failure: CONTINUE` to the build phase.

For the actual check, we just need to tell steampipe where to find the mod `export STEAMPIPE_WORKSPACE_CHDIR`, then we change directory to the terraform and run the  `steampipe check all` command. Since steampipe was installed in the parent directory of terraform, we call it as `../steampipe`.


That's it! Now you can use any of Steampipe's plugins and mods as part of your CodeBuild projects.

