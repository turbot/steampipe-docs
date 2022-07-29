---
title: Steampipe Cloud
sidebar_label: Steampipe Cloud
---

# Steampipe Cloud

## Overview
Steampipe Cloud is a fully managed SaaS platform for hosting Steampipe instances.

[Steampipe](https://steampipe.io/) exposes APIs and services as a relational database, giving you the ability to write SQL-based queries and controls to explore, assess and report on dynamic data. [Steampipe Cloud](https://cloud.steampipe.io/) provides a hosted platform for Steampipe, simplifying setup and operation, accelerating integration, and providing solutions for collaborating and sharing insights.


## Getting Started

### Sign up
To sign up, go to https://cloud.steampipe.io/, sign up with your Github login and authorize Steampipe Cloud to allow you to login using OAuth.

Steampipe Cloud is currently in limited private preview. If you are not accepted into the preview, you will be added to a waiting list.

### Create a Workspace

To get started with Steampipe you must create a [Workspace](cloud/workspaces).

Log in to [Steampipe Cloud](https://cloud.steampipe.io). Since you have no workspaces, you will land on the workspace page. Click **New Workspace**.

Each workspace must have a **handle**. The workspace handle is a friendly identifier for your workspace, and must be unique across your workspaces. Enter a handle for your workspace and click **Create Workspace**.

### Set up a Connection

You are now prompted to create a [Connection](cloud/connections), which represents a set of tables for a single data source. Each connection is represented as a distinct Postgres schema. In order to query data, you'll need at least one connection.

Click one of the plugins from the list. Enter the required settings for the plugin. You can verify your credentials using the **Test Connection** button, and then click **Create**.

Once a connection is created, you must associate it with your workspace. You will be prompted to add the connection to the workspace that you just created. Click **Add to Workspace**.

Note that the wizard only prompts for a single connection. You can create and attach additional connections later from the **Settings** tab for your workspace.

### Install a Mod

You will then be given the opportunity to install one or more [Mods](cloud/mods), which will give you access to hundreds of off-the-shelf dashboards and benchmarks for you to visualise within your workspace. Steampipe Cloud also allows you to manage [Variables](mods/mod-variables) exposed by the mod, to create dynamic behaviour customised to your requirements.

The list of mods shown are ones from the official mod registry that are compatible with the type of connection(s) you created previously.

If you don't see any compatible mods, you can **Skip** this section, else choose one or more and click **Install**.

You can always manage mods later via the mod settings pages if you don't wish to do this now.

### Dashboards

After you create your workspace, connection and install a mod(s), you will be taken to the **Dashboards** tab for your workspace. You can browse the catalog of existing dashboards, including compliance frameworks, or service-specific dashboards and reports that answer a variety of questions. If you chose not to install a mod, you can always head over to the **Query** tab for your workspace.

### Query

You can browse or search the tables and run ad-hoc queries right from the web console!
