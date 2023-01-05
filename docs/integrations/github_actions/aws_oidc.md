---
title: Authenticate to AWS with OIDC
sidebar_label: AWS + OIDC
---

# Authenticate to AWS with OIDC

If you run Steampipe in a [GitHub Action](https://steampipe.io/docs/integrations/github_action) you can use GitHub Actions Secrets to store the credentials that Steampipe uses to access AWS, Azure, GCP, or another cloud API. But what if you don't want to persist credentials there? An alternative is to use OpenID Connect (OIDC) to enable an Actions workflow that acquires temporary credentials on demand.

The example shown in this post uses the OIDC method in a workflow that:

1. Installs Steampipe (along with a cloud-specific plugin and compliance mod).

2. Runs a compliance benchmark, and save its output in the repository.

## What is OIDC?

[OpenID Connect 1.0](https://openid.net/specs/openid-connect-core-1_0.html) is a simple identity layer on top of the OAuth 2.0 protocol. It enables Clients to verify the identity of the End-User based on the authentication performed by an Authorization Server, as well as to obtain basic profile information about the End-User in an interoperable and REST-like manner.

## GitHub's OIDC provider for AWS

To try this yourself you'll need to set up OIDC for your cloud provider. GitHub's [Security hardening your deployments](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments) page has instructions for using OpenID Connect with various providers. To help you follow those instructions we have created [Terraform sample](https://github.com/turbot/steampipe-samples/tree/main/all/github-actions-oidc/aws). If you prefer AWS CloudFormation, you can make use of this [link](https://github.com/aws-actions/configure-aws-credentials#sample-iam-role-cloudformation-template) to get started. Here we will discuss the Terraform implementation. This Terraform script will create two AWS resources, an Identity provider and IAM Role in your account. These resources together form an OIDC trust between the AWS IAM role and your GitHub workflow(s) that need access to the cloud.

In order to execute the terraform and deploy the resources GitHub needs, you will need local credentials to the target AWS account. This can be via AWS Identity Center, IAM User Access Keys or via environment variables. Regardless of how you [authenticate](https://registry.terraform.io/providers/hashicorp/aws/latest/docs#authentication-and-configuration), the permissions required to deploy the terraform must have the ability to create IAM resources.

### Configuration

Update the `default.tfvars` file for the below variables.

* `github_repo`: GitHub repository that needs the access token. Example: octo-org/octo-repo

* `github_branch`: GitHub branch that runs the workflow. Example: main

* `aws_iam_role_name`: Name of the AWS IAM Role to create. Example: steampipe_gh_oidc_demo

### Implementation

Execute the below commands to create resources in your AWS Account.

* `terraform init`: Initialize Terraform to get all necessary providers.

* `terraform apply -var-file=default.tfvars`: Apply the configuration using the configuration file "defaults.tfvars"

### Verification

Below AWS resources are created, an Identity provider and IAM Role in your account.

* AWS > IAM > Identity provider > token.actions.githubusercontent.com
* AWS > IAM > Role (rolename: steampipe_gh_oidc_demo)

<div style={{"marginBottom":"2em","borderWidth":"thin", "borderStyle":"solid", "borderColor":"lightgray", "padding":"20px", "width":"90%"}}>
<img alt="aws_iam_identity_provider" src="/images/docs/ci-cd-pipelines/oidc/aws_iam_identity_provider.png" />
</div>

<div style={{"marginBottom":"2em","borderWidth":"thin", "borderStyle":"solid", "borderColor":"lightgray", "padding":"20px", "width":"90%"}}>
<img alt="aws_iam_role" src="/images/docs/ci-cd-pipelines/oidc/aws_iam_role.png" />
</div>

You will need to add one GitHub Secret, `OIDC_AWS_ROLE_TO_ASSUME`, which is the ARN of the above IAM role that handles OIDC federation. You can get the IAM Role ARN from the Terraform output or the AWS IAM Console.

<div style={{"marginBottom":"2em","borderWidth":"thin", "borderStyle":"solid", "borderColor":"lightgray", "padding":"20px", "width":"90%"}}>
<img alt="gh_secret" src="/images/docs/ci-cd-pipelines/oidc/gh_secret.png" />
</div>

## Define the workflow

Now create a GitHub Actions workflow in your repository, as `.github/workflows/steampipe.yml`, based on [this example](https://github.com/turbot/steampipe-samples/blob/main/all/github-actions-oidc/aws/steampipe-sample-aws-workflow.yml). Let's review the key elements of the workflow.

### On

GitHub supports a variety of driven-triggers. Here we define two: `workflow_dispatch` to [manually run a workflow](https://docs.github.com/en/actions/managing-workflow-runs/manually-running-a-workflow) and `schedule` to run on a cron-like schedule.

```yaml
on:
  workflow_dispatch:
  schedule:
    - cron: "0 4 7,14,21,28 * *"
```

### Permissions

Every time your job runs, GitHub's OIDC Provider auto-generates an OIDC token. This token contains multiple claims to establish a security-hardened and verifiable identity about the specific workflow that is trying to authenticate. In order to request this OIDC JWT ID token, your job or workflow run requires a permissions setting with `id-token: write`.

In order to checkout to the GitHub repository and to save the benchmark results to the repository, your job or workflow run requires a permissions setting with `contents: write`.

```yaml
permissions:
  id-token: write
  contents: write
```

### Steps

A workflow comprises one or more jobs that run in parallel, each with one or more steps that run in order. Our [example](https://github.com/turbot/steampipe-samples/blob/main/all/github-actions-oidc/aws/steampipe-sample-aws-workflow.yml#L14) defines a single job with a series of steps that authenticate to AWS, install Steampipe, run a compliance benchmark and save the results to the repository.

Here's the step that configures the credentials Steampipe will use to access AWS.

```
- name: "Configure AWS credentials"
	id: config-aws-auth
	uses: aws-actions/configure-aws-credentials@v1-node16
	with:
		role-to-assume: ${{ secrets.OIDC_AWS_ROLE_TO_ASSUME }}
		role-session-name: "steampipe-demo"
		role-duration-seconds: 900
		aws-region: "us-east-1" 
```

Once the cloud provider successfully validates the claims presented in the OIDC JWT ID token, it then provides a short-lived access token that is available only for the duration of the job. The short-lived access token is exported as environment variables like AWS_DEFAULT_REGION, AWS_REGION, AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY and AWS_SESSION_TOKEN.
Steampipe will seamlessly load these short-lived [Credentials from Environment Variables](https://hub.steampipe.io/plugins/turbot/aws#credentials-from-environment-variables) to run the benchmark.

Before running the compliance benchmark, create a new folder in your GitHub repository to save the benchmark outputs. Update the `export` argument in the below step. In our example, we will save the outputs to the folder `steampipe/benchmarks/aws`.

Here's the step that runs the [AWS Compliance](https://hub.steampipe.io/mods/turbot/aws_compliance) mod.

```
- name: "Run Steampipe benchmark"
	id: steampipe-benchmark
	run: |

		# Install the Steampipe AWS Compliance mod
		steampipe mod install github.com/turbot/steampipe-mod-aws-compliance 
	steampipe mod install github.com/turbot/steampipe-mod-aws-compliance 
		steampipe mod install github.com/turbot/steampipe-mod-aws-compliance 
		cd .steampipe/mods/github.com/turbot/steampipe-mod-aws-compliance*
		# Run the AWS CIS v1.5.0 benchmark
		steampipe check benchmark.cis_v150 --export=${GITHUB_WORKSPACE}/steampipe/benchmarks/aws/cis_v150_"$(date +"%d_%B_%Y")".html --output=none
```

Here's the step that pushes the benchmark to your repository. Update the `working-directory` to the folder created in the above step. This should be the same location used in the above `export` argument.

```
- name: "Commit the file to github"
	id: push-to-gh
	working-directory: steampipe/benchmarks/aws
	run: |

		git config user.name github-actions
		git config user.email github-actions@github.com
		git add cis_v150_"$(date +"%d_%B_%Y")".html 
		git commit -m "Add Steampipe Benchmark Results"
		git push
```

### Run the workflow

The job will run on schedule, but it's always helpful to [run manually](https://docs.github.com/en/actions/managing-workflow-runs/manually-running-a-workflow) for sanity-check. Make sure you select the correct branch when executing this manually, this should be listed in the Trust Relationships of your IAM Role. (`github_branch` variable in the Terraform script).

<div style={{"marginBottom":"2em","borderWidth":"thin", "borderStyle":"solid", "borderColor":"lightgray", "padding":"20px", "width":"90%"}}>
<img alt="manual_run" src="/images/docs/ci-cd-pipelines/oidc/manual_run.mov" />
</div>

Here's the result in the GitHub Actions log.

<div style={{"marginBottom":"2em","borderWidth":"thin", "borderStyle":"solid", "borderColor":"lightgray", "padding":"20px", "width":"90%"}}>
<img alt="save_gh_run" src="/images/docs/ci-cd-pipelines/oidc/save_gh_run.png" />
</div>

Here's the resulting HTML file in a local instance of the repository.

<div style={{"marginBottom":"2em","borderWidth":"thin", "borderStyle":"solid", "borderColor":"lightgray", "padding":"20px", "width":"90%"}}>
<img alt="saved_benchmark" src="/images/docs/ci-cd-pipelines/oidc/saved_benchmarks.png" />
</div>