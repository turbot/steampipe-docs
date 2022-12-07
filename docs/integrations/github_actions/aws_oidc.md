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

<!-- If the official definition didn't help, here is a simplified [video](https://youtu.be/t18YB3xDfXI) for better understanding. -->

## Configure GitHub's OIDC provider for AWS

To try this yourself you'll need to set up OIDC for your cloud provider. GitHub's [Security hardening your deployments](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments) page has instructions for using OpenID Connect with various providers. To help you follow those instructions we have created [Terraform samples](https://github.com/turbot/steampipe-samples/tree/main/all/github-actions-oidc) for AWS, Azure and GCP. Here we'll focus on AWS.

In the [AWS example](https://github.com/turbot/steampipe-samples/tree/main/all/github-actions-oidc/aws), you will notice the following files.
```
├── README.md
├── default.tfvars
├── main.tf
├── output.tf
├── providers.tf
├── steampipe-sample-aws-workflow.yml
└── variables.tf
```

### Authentication

You can authenticate to the Terraform AWS provider in many ways, we will use the environment variables. Export the temporary keys or profile as below.

```
$ export AWS_ACCESS_KEY_ID="anaccesskey"
$ export AWS_SECRET_ACCESS_KEY="asecretkey"
$ export AWS_SESSION_TOKEN="asessiontoken"

OR 

$ export AWS_PROFILE="default"
```

### Configuration

Update the `default.tfvars` file for the below variables.

* `github_repo`: GitHub repository that needs the access token. Example: octo-org/octo-repo

* `github_branch`: GitHub branch that runs the workflow. Example: demo-branch

* `aws_iam_role_name`: Name of the AWS IAM Role to create. Example: steampipe_gh_oidc_demo

### Implementation

Execute the below commands to create resources in your AWS Account.

* `terraform init`: Initialize Terraform to get all necessary providers.

* `terraform apply -var-file=default.tfvars`: Apply the configuration using the configuration file "defaults.tfvars"

### Verification

The Terraform script will create two AWS resources, an Identity provider and IAM Role in your account. These resources together form an OIDC trust between the AWS IAM role and your GitHub workflow(s) that need access to the cloud.

* AWS > IAM > Identity provider > token.actions.githubusercontent.com
* AWS > IAM > Role (rolename: steampipe_gh_oidc_demo)

<div style={{"marginTop":"2em", "marginBottom":"2em", "borderStyle":"solid", "borderWidth":"1px", "borderColor":"#f3f1ef"}}>
  <img src="/images/blog/2022-12-gh-oidc/identity-provider.png" />
</div>

<div style={{"marginTop":"2em", "marginBottom":"2em", "borderStyle":"solid", "borderWidth":"1px", "borderColor":"#f3f1ef"}}>
  <img src="/images/blog/2022-12-gh-oidc/oidc-iam-role.png" />
</div>

You will need to add one GitHub Secret, `OIDC_AWS_ROLE_TO_ASSUME`, which is the ARN of the above IAM role that handles OIDC federation. You can get the IAM Role ARN from the Terraform output or the AWS IAM Console.
<div style={{"marginTop":"2em", "marginBottom":"2em", "borderStyle":"solid", "borderWidth":"1px", "borderColor":"#f3f1ef"}}>
  <img src="/images/blog/2022-12-gh-oidc/gh-secret.png" />
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

In order to checkout to the GitHub repo and to save the benchmark results to the repo, your job or workflow run requires a permissions setting with `contents: read`.

```yaml
permissions:
  id-token: write
  contents: read
```

### Steps

A workflow comprises one or more jobs that run in parallel, each with one or more steps that run in order. Our [example](https://github.com/turbot/steampipe-samples/blob/main/all/github-actions-oidc/aws/steampipe-sample-aws-workflow.yml#L14) defines a single job with a series of steps that authenticate to AWS, install Steampipe, and run a compliance benchmark.

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

Once the cloud provider successfully validates the claims presented in the OIDC JWT ID token, it then provides a short-lived  access token that is available only for the duration of the job. The short-lived access token is exported as environment variables like AWS_DEFAULT_REGION, AWS_REGION, AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY and AWS_SESSION_TOKEN.
Steampipe will seamlessly load these short-lived [Credentials from Environment Variables](https://hub.steampipe.io/plugins/turbot/aws#credentials-from-environment-variables) to run the benchmark.

Here's the step that runs the [AWS Compliance](https://hub.steampipe.io/mods/turbot/aws_compliance) mod.

```
- name: "Run Steampipe benchmark"
id: steampipe-benchmark
run: |

	# Install the Steampipe AWS Compliance mod
	steampipe mod install github.com/turbot/steampipe-mod-aws-compliance 
	cd .steampipe/mods/github.com/turbot/steampipe-mod-aws-compliance*
	# Run the AWS CIS v1.5.0 benchmark
	steampipe check benchmark.cis_v150 --export=steampipe_aws_cis_v150_"$(date +"%d_%B_%Y")".html --output=none
```

Here's the step that pushes the benchmark to your repo. Update the "working-directory" to the directory within your repo where yo uwant to save the benchmark outputs.

```
- name: "Commit the file to github"
	id: push-to-gh
	working-directory: scripts
	run: |

		git config user.name github-actions
		git config user.email github-actions@github.com
		git add steampipe_aws_cis_v150_"$(date +"%d_%B_%Y")".html 
		git commit -m "Add Steampipe Benchmark Results"
		git push
```

### Run the workflow

> Here the narrative can be something like: This will run on a schedule, but it's always helpful to run manually and sanity-check the thing. To do that, use [ whatever affordance GH provides to run an action this way, I've not seen it, I've only used `push` and `schedule` ]

The job will run on schedule, but it's always helpful to [run manually](https://docs.github.com/en/actions/managing-workflow-runs/manually-running-a-workflow) for sanity-check. Make sure you select the correct branch when executing this manually, this should be listed in the Trust Relationships of your IAM Role. (`github_branch` variable in the Terraform script).

Here's the result in the GitHub Actions log.

<div style={{"marginTop":"2em", "marginBottom":"2em", "borderStyle":"solid", "borderWidth":"1px", "borderColor":"#f3f1ef"}}>
  <img src="/images/blog/2022-12-gh-oidc/save-gh-run.png" />
</div>

Here's the resulting HTML file in a local instance of the repo.

<div style={{"marginTop":"2em", "marginBottom":"2em", "borderStyle":"solid", "borderWidth":"1px", "borderColor":"#f3f1ef"}}>
  <img src="/images/blog/2022-12-gh-oidc/savedbenchmarks.png" />
</div>
