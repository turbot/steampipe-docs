---
title: Getting Started with Steampipe Cloud
sidebar_label: Getting Started
---

# Getting Started with Steampipe Cloud

## Sign up
To sign up, go to [cloud.steampipe.io](https://cloud.steampipe.io).  You can sign up with your Github or Google login (you will need to authorize Steampipe Cloud to allow you to login using OAuth), or with an email address.

<img src="/images/docs/cloud/gs_signup.png" width="300pt"/>

Steampipe Cloud is currently in limited private preview. If you are not accepted into the preview, you will be added to a waiting list.

## Create a Workspace


Since you have no workspaces the first time you sign in, you will land on the workspace page.  To get started with Steampipe you must create a [Workspace](cloud/workspaces).

<img src="/images/docs/cloud/gs_new_workspace.png" width="400pt"/>

<br />

Click **New Workspace** to create a workspace.

<img src="/images/docs/cloud/gs_create_workspace.png" width="400pt"/>
<br />

Each workspace must have a **handle**. The workspace handle is a friendly identifier for your workspace, and must be unique across your workspaces. Enter a handle for your workspace and click **Create Workspace**.


## Set up a Connection

You are now prompted to create a [Connection](cloud/connections), which represents a set of tables for a single data source. 

<img src="/images/docs/cloud/gs_new_connection.png" width="400pt"/>
<br />

Each connection is represented as a distinct Postgres schema. In order to query data, you'll need at least one connection. In this tutorial, we will install the AWS plugin.  Click  **Amazon Web Services**

<img src="/images/docs/cloud/gs_create_connection.png" width="400pt"/>
<br />

The available settings vary by plugin, but every connection has a **handle**.  The connection handle will be used as the name of the schema in Postgres.  A single AWS connection will connect to a single AWS account, but you may have many AWS connections.  As a result, it's a good idea to name the connection in a way that reflects which account it is connecting to.  Additionally, it's common practice to prefix the connection name with the plugin type.  

An AWS connection can query multiple regions.  You may want to limit the regions that it queries to reduce the number of API calls, or to avoid errors in regions that you do not have access to, but most people use the default and allow Steampipe to access **All Regions**.

To connect to AWS, Steampipe Cloud will need credentials.  You can select **Access Key** Mode and enter an access key and secret key that has read access to your account, but we recommend using **Cross-Account Role** access mode to avoid using long term credentials.  Steampipe cloud can assist you in creating the IAM role in your AWS account - click/role in your AWS account. Click **Download Terraform Plan** or **Download CloudFormation Template** and then run the downloaded file / plan against your account to create the role with the generated external id.  Once the role has been created, enter the **Role ARN**.

You can verify your credentials using the **Test connection** button, and then click **Create connection**.

Once a connection is created, you must associate it with your workspace. You will be prompted to add the connection to the workspace that you just created.

<img src="/images/docs/cloud/gs_add_connection_to_workspace.png" width="400pt"/>
<br />

 Click **Add to Workspace**.

Note that the wizard only prompts for a single connection. You can create and attach additional connections later from the **Settings** tab for your workspace.

## Install a Mod

You will then be given the opportunity to install one or more [Mods](cloud/mods), which will give you access to hundreds of off-the-shelf dashboards and benchmarks for you to visualize within your workspace. Steampipe Cloud also allows you to [manage variables](cloud/mods#managing-mod-variables) exposed by the mod, to create dynamic behavior customized to your requirements.

<img src="/images/docs/cloud/gs_install_mods.png" width="400pt"/>
<br />

The list of mods shown are ones from the official mod registry that are compatible with the type of connection(s) you created previously.  We'll use the default selections and install the **AWS Compliance**, **AWS Insights**, and **AWS Perimeter** mods.  Click **Install Mods**.  It will take a minute or for the mods to be installed in your workspace.

Note that some plugins may not have any compatible mods, and you can **Skip** this section. You can always manage mods later via the mod settings pages.

## Dashboards

After you create your workspace, add your connection and install a mod(s), you will be taken to the **Dashboards** tab for your workspace. 

<img src="/images/docs/cloud/gs_dashboard_list.png" width="400pt"/>
<br />

You can browse the catalog of existing dashboards, including compliance frameworks, or service-specific dashboards and reports that answer a variety of questions. Click on a dashboard to run it.

<img src="/images/docs/cloud/gs_cis_dashboard.png" width="400pt"/>
<br />

## Query
You can also run queries from the query tab.  You can browse or search the schemas and tables and run ad-hoc queries right from the web console!


<img src="/images/docs/cloud/gs_query.png" width="400pt"/>
<br />
