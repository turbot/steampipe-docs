---
title: Scanning Terraform in AWS CodePipeline using Steampipe
sidebar_label: AWS CodePipeline
---

# Scanning Terraform in AWS CodePipeline using Steampipe

Steampipe's [Terraform plugin](https://hub.steampipe.io/plugins/turbot/terraform) can query Terraform files, and leveraging [Steampipe mod packs](https://hub.steampipe.io/mods?q=terraform), can detect security misconfigurations in code _before_ being deployed into production.

AWS [CodeBuild](https://aws.amazon.com/codebuild/) is a managed continuous integration service that can build code and run tests. All AWS customers get [100 minutes of free usage](https://aws.amazon.com/codebuild/pricing/?loc=ft#Free_Tier) of AWS CodeBuild each month.

AWS [CodePipeline](https://aws.amazon.com/codepipeline/) is a managed continuous delivery service to manage release pipelines for applications and infrastructure.

This integration will show you how Steampipe, running in CodeBuild, can scan resources before they're deployed. The scan results are stored in Steampipe Cloud, and CodePipeline is used to require a manual review and approval before the non-compliant resources are deployed.

## About this solution
This sample integration consists of a CloudFormation template and a Steampipe Buildspec file. The CloudFormation template creates the required CodePipeline, CodeBuild, and IAM Roles. The BuildSpec file tells CodeBuild how to install and run Steampipe to push the results to Steampipe Cloud.

!["AWS Code Pipeline"](/images/docs/ci-cd-pipelines/codebuild/pipeline.png)
The Pipeline will pull the terraform files from GitHub and execute Steampipe in a CodeBuild project. If there are issues, the pipeline will require a manual review of the Steampipe mod findings before executing another CodeBuild project to run `terraform apply`.

!["Review Dialog"](/images/docs/ci-cd-pipelines/codebuild/Review.png)

The Steampipe terraform compliance scan results are automatically stored in Steampipe Cloud for collaborative review. The credentials for Steampipe Cloud are managed via AWS Secrets Manager.

!["Steampipe Dashboard"](/images/docs/ci-cd-pipelines/codebuild/snapshot.png)


## Running Steampipe in a CodeBuild Container

Running Steampipe in a CodeBuild container is reasonably straightforward. By default CodeBuild executes the build as root, however for security reasons, Steampipe will only run as a regular user. With the CodeBuild [buildspec]() capability, you can specify commands run by a different user. The default Ubuntu CodeBuild container has a `codebuild-user` that we will use to run all the Steampipe commands.

The buildspec file for running Steampipe looks like this:
```yaml
version: 0.2

env:
  # Store the Steampipe Cloud host, token and workspace in AWS Secrets Manager
  secrets-manager:
    STEAMPIPE_CLOUD_HOST: integrate-steampipe-cloud-token:STEAMPIPE_CLOUD_HOST
    STEAMPIPE_CLOUD_TOKEN: integrate-steampipe-cloud-token:STEAMPIPE_CLOUD_TOKEN
    WORKSPACE: integrate-steampipe-cloud-token:WORKSPACE
  exported-variables:
    # STATUS_URL is returned and leveraged by CodePipeline for the Approval message
    - STATUS_URL

phases:
  install:
    commands:
      # Each CodeBuild container is ephemeral - We need to install steampipe every time
      - curl -s -L https://github.com/turbot/steampipe/releases/download/v0.17.0-alpha.16/steampipe_linux_amd64.tar.gz | tar -xzf -
      - echo "installed steampipe"
      - git clone https://github.com/turbot/steampipe-mod-terraform-aws-compliance.git
      # Steampipe cannot run as root, so we run all the next steps as the codebuild user. But first it needs to own those files
      - chown -R codebuild-user .
  build:
    # Steampipe will return a non-zero exit code with the number of failed checks
    # (That may or may not still be the case with the SteamPipe cloud version)
    on-failure: CONTINUE
    run-as: codebuild-user
    commands:
      - pwd  # for debugging
      # Place the .steampipe install in the local directory for this build
      - export STEAMPIPE_INSTALL_DIR=`pwd`/.steampipe
      - ./steampipe plugin install terraform
      - ./steampipe --version # for debugging
      # We need to tell Steampipe where to find the Terraform Module to use
      - export STEAMPIPE_WORKSPACE_CHDIR=`pwd`/steampipe-mod-terraform-aws-compliance
      - echo "Pushing Dashboard to $STEAMPIPE_CLOUD_HOST in $WORKSPACE"
      - cd terraform ; export STATUS_URL=`../steampipe dashboard benchmark.s3 --share=$WORKSPACE | awk '{print $NF}'`
```

The first phase called `install`, installs steampipe and the terraform-aws-compliance mod.
The second phase called `build`, will initialize steampipe, download the terraform plugin, and then run the Terraform S3 Benchmark. The results of the scan are then uploaded to Steampipe Cloud to the Workspace defined in AWS Secrets Manager.

For integration to Steampipe Cloud, create a new secret in AWS SecretsManager that looks like this:
```json
{
    "STEAMPIPE_CLOUD_HOST": "cloud.steampipe.io",
    "STEAMPIPE_CLOUD_TOKEN": "spt_cclctado4h69xos3r7j0_1e3mtngv28pm916pwt8ehqsy6",
    "WORKSPACE": "jchrisfarris/integrate2022"
}
```

## Leverage CodePipeline to require manual override when compliance violations occur.

The [sample CloudFormation Template]() defines the pipeline. It requires you to specify a [GitHub Connection](https://docs.aws.amazon.com/codepipeline/latest/userguide/connections-github.html), the GitHub repository and branch, an S3 Bucket, the secret created above, and an optional email address to receive the email notices when a manual approval is required.

!["Email from Code Pipeline"](/images/docs/ci-cd-pipelines/codebuild/Email.png)




## Future things to do:
1. Create the S3 Bucket as part of the Template
2. Change the install to use the default build rather than the Alpha build
3. Determine if we can bypass the manual approval when there are no violations
