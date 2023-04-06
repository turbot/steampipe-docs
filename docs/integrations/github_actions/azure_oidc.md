---
title: Authenticate to Azure with OIDC
sidebar_label: Azure + OIDC
---

# Authenticate to Azure with OIDC

If you run Steampipe in a [GitHub Action](https://steampipe.io/docs/integrations/github_actions/installing_steampipe) you can use GitHub Actions Secrets to store the credentials that Steampipe uses to access AWS, Azure, GCP, or another cloud API. But what if you don't want to persist credentials there? An alternative is to use OpenID Connect (OIDC) to enable an Actions workflow that acquires temporary credentials on demand.

The example shown in this post uses the OIDC method in a workflow that:

1. Installs Steampipe (along with a cloud-specific plugin and compliance mod).
2. Runs the Steampipe Compliance Mod for Azure and saves the output in the repository.

## What is OIDC?

[OpenID Connect 1.0](https://openid.net/specs/openid-connect-core-1_0.html) is an identity layer on top of the [OAuth 2.0 protocol](https://www.rfc-editor.org/rfc/rfc6749). It enables clients to verify the identity of the End-User based on the authentication performed by an Authorization Server, as well as to obtain basic profile information about the End-User in an interoperable and REST-like manner.

## Define the workflow

First, we must create the GitHub Actions workflow file in your repository. For this [example](https://github.com/turbot/steampipe-samples/blob/main/all/github-actions-oidc/azure/steampipe-sample-azure-workflow.yml) we will use the filename `.github/workflows/steampipe.yml`

### Triggers

GitHub supports a variety of event-driven triggers. Here we define two: `workflow_dispatch` to [manually run a workflow](https://docs.github.com/en/actions/managing-workflow-runs/manually-running-a-workflow) and `schedule` to run on a cron-like schedule. To trigger the `workflow_dispatch` event, your workflow must be in the default branch.

```yaml
on:
  workflow_dispatch:
  schedule:
    - cron: "0 4 7,14,21,28 * *"
```

### Permissions

Every time your job runs, GitHub's OIDC Provider auto-generates an OIDC token. This token contains multiple claims to establish a security-hardened and verifiable identity about the workflow that is trying to authenticate. In order to request this OIDC JWT ID token, your job or workflow run requires a permissions setting with `id-token: write`.

In order to checkout to the GitHub repository and to save the benchmark results to the repository, your job or workflow run also requires a permissions setting with `contents: write`.

```yaml
permissions:
  id-token: write
  contents: write
```

### Steps

A workflow comprises one or more jobs that run in parallel, each with one or more steps that run in order. Our [example](https://github.com/turbot/steampipe-samples/blob/6d628286109daff33c0c58c62623d8cf9614b8a2/all/github-actions-oidc/azure/steampipe-sample-azure-workflow.yml#L14) defines a single job with a series of steps that authenticate to Azure, install Steampipe, run a compliance benchmark and save the results to the repository.

First, create a step that configures the credentials Steampipe will use to access Azure.

```yaml
- name: "Configure Azure credentials"
  id: config-azure-auth
  uses: azure/login@v1
  with:
    client-id: ${{ secrets.OIDC_AZURE_CLIENT_ID }}
    tenant-id: ${{ secrets.OIDC_AZURE_TENANT_ID }}
    subscription-id: ${{ secrets.OIDC_AZURE_SUBSCRIPTION_ID }}
```

Once the cloud provider successfully validates the claims presented in the OIDC JWT ID token, it then provides a short-lived access token that is available only for the duration of the job. Steampipe will load these short-lived [credentials from Azure CLI](https://hub.steampipe.io/plugins/turbot/azure#azure-cli) to run the benchmark.

Next, you'll need to create a step that installs the Steampipe CLI, Azure and AzureAD plugins.

```yaml
- name: "Install Steampipe cli and plugin"
  id: steampipe-installation
  run: |

    # Install Steampipe CLI
    sudo /bin/sh -c "$(curl -fsSL https://raw.githubusercontent.com/turbot/steampipe/main/install.sh)"
    # Check steampipe version
    steampipe -v
    # Install Azure and AzureAD plugins
    steampipe plugin install azure
    steampipe plugin install azuread
```

Before running the compliance benchmark, create a new folder on the branch specified in your GitHub repository to save the benchmark output. In our example, we will save the outputs to the folder `steampipe/benchmarks/azure`. The default environment variable [GITHUB_WORKSPACE](https://docs.github.com/en/actions/learn-github-actions/variables#default-environment-variables) refers to the default working directory on the runner for steps, and the default location of your repository when using the [checkout](https://github.com/actions/checkout) action.

Next, create a step that installs the [Azure Compliance](https://hub.steampipe.io/mods/turbot/azure_compliance) mod and runs the Azure CIS v2.0.0 Benchmark.

```yaml
- name: "Run Steampipe benchmark"
  id: steampipe-benchmark
  continue-on-error: true
  run: |

    # Install the Steampipe Azure Compliance mod
    steampipe mod install github.com/turbot/steampipe-mod-azure-compliance
    cd .steampipe/mods/github.com/turbot/steampipe-mod-azure-compliance*
    # Run the Azure CIS v2.0.0 benchmark
    steampipe check benchmark.cis_v200 --export=$GITHUB_WORKSPACE/steampipe/benchmarks/azure/cis_v200_"$(date +"%d_%B_%Y")".html --output=none
```

Finally, add a step that pushes the output of the benchmark to your repository. Update the `working-directory` to the folder created in the above step. This should be the same location used in the above `--export` argument.

```yaml
- name: "Commit the file to github"
  id: push-to-gh
  working-directory: steampipe/benchmarks/azure
  run: |

    git config user.name github-actions
    git config user.email github-actions@github.com
    git add cis_v200_"$(date +"%d_%B_%Y")".html
    git commit -m "Add Steampipe Benchmark Results"
    git push
```

## Configuring GitHub's OIDC provider for Azure

In order for Azure to trust GitHub, you must configure OIDC as an identity provider in your Azure subscription. GitHub's [Security hardening your deployments](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments) page has instructions for using OpenID Connect with various providers. To help you follow those instructions we have created a [Terraform sample](https://github.com/turbot/steampipe-samples/tree/main/all/github-actions-oidc/azure).

This guide will demonstrate the Terraform implementation. This Terraform script will create two Azure resources, an AD App(Service Principal) and Federated Credential in your subscription. These resources together form an OIDC trust between GitHub workflow(s) and the specific Azure resources scoped by the Service Principal. In order to execute the Terraform code and deploy the resources GitHub needs, you will need local credentials for the target Azure subscription. This can be via Azure CLI, Managed Service identity, or Service Principal. Regardless of how you [authenticate](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs#authenticating-to-azure), the permissions required to deploy the Terraform code must have permission to create Azure Active Directory resources.

### Configuration

Update the `default.tfvars` file for the below variables.

* `github_repo`: GitHub repository that needs the access token. Example: octo-org/octo-repo
* `github_branch`: GitHub branch that runs the workflow. If you plan to trigger the workflow through schedule, then this must be the default branch. If you plan to run the workflow manually, this can be any branch. Example: master
* `azuread_application_name`: Name of the Azure AD Service Principal to create. Example: steampipe_gh_oidc_demo

### Implementation

Navigate to the folder where the [Terraform sample for Azure](https://github.com/turbot/steampipe-samples/tree/main/all/github-actions-oidc/azure) is cloned. Run the below commands to create necessary resources in your Azure Subscription.

```bash
# Initialize Terraform to get all necessary providers.
terraform init

# Apply the configuration using the configuration file "defaults.tfvars"
terraform apply -var-file=default.tfvars
```

Successful execution of the above will give a Terraform output values of Azure Client ID, Tenant Id and Subscription Id. Add these Terraform output values `OIDC_AZURE_CLIENT_ID`, `OIDC_AZURE_TENANT_ID` and `OIDC_AZURE_SUBSCRIPTION_ID` to the GitHub Secrets in your repository as shown below.

<div style={{"marginBottom":"2em","borderWidth":"thin", "borderStyle":"solid", "borderColor":"lightgray", "padding":"20px", "width":"90%"}}>
<img alt="gh_secret_azure" src="/images/docs/ci-cd-pipelines/oidc/azure_gh_secret.png" />
</div>

### Validation

Login to your Azure subscription to verify that Terraform has created the following resources.

* Azure > Azure AD > App registrations > All applications > Service Principal (example: steampipe_gh_oidc_demo)
* Azure > Azure AD > App registrations > All applications > Service Principal (example: steampipe_gh_oidc_demo) > Certificates & secrets > Federated credentials

The Azure Active Directory console should show the Service Principal as follows.
<div style={{"marginBottom":"2em","borderWidth":"thin", "borderStyle":"solid", "borderColor":"lightgray", "padding":"20px", "width":"90%"}}>
<img alt="azure_ad_app_registration" src="/images/docs/ci-cd-pipelines/oidc/azure_ad_app_registration.png" />
</div>

The Azure Active Directory Service Principal(steampipe_gh_oidc_demo) should show the following trust relationship.
<div style={{"marginBottom":"2em","borderWidth":"thin", "borderStyle":"solid", "borderColor":"lightgray", "padding":"20px", "width":"90%"}}>
<img alt="azure_ad_app_federation" src="/images/docs/ci-cd-pipelines/oidc/azure_ad_app_federation.png" />
</div>

## Running the workflow on-demand

The job will run on schedule, but it's always helpful to [run manually](https://docs.github.com/en/actions/managing-workflow-runs/manually-running-a-workflow) for sanity-check. Make sure you select the correct branch when executing this manually, this should be listed in the Trust Relationships of your IAM Role. (`github_branch` variable in the Terraform script).

<div style={{"marginBottom":"2em","borderWidth":"thin", "borderStyle":"solid", "borderColor":"lightgray", "padding":"20px", "width":"90%"}}>
<img alt="manual_run" src="/images/docs/ci-cd-pipelines/oidc/azure_manual_run.png" />
</div>

Upon successful run of the GitHub action(schedule or manual run), the Steampipe benchmark result is automatically pushed to your GitHub repository.
