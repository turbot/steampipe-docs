---
title:  Mods
sidebar_label: Mods
---

# Managing Mods

## Overview

Mods allow predefined [queries](reference/mod-resources/query), [controls/benchmarks](mods/writing-controls) and [dashboards](mods/writing-dashboards) to be packaged and versioned. Steampipe Cloud now allows you to install mods into your workspace like you would do in your [local environment](mods/mod-dependencies), allowing a wealth of predefined dashboards for you to run.

## Installing Mods

When you [create your workspace](cloud/workspaces#creating-workspaces), you will have been given the opportunity to install a mod. If you wish to install one later, within the workspace, go to the **Settings** tab, then **Mods**. From here click the **Install Mods** button.

Within the install mods screen, you will be presented with a list of the official mods that are compatible with the [connection(s)](cloud/workspaces#managing-workspace-connections) plugin type(s) in your workspace. Choose one or more mod, then click the **Install** button.

Installation should typically only take a few seconds. You can then head over to the **Dashboards** tab where you'll see a list of the available dashboards for the mod(s) you installed.

## Installing Custom Mods

Rather than selecting an official mod within the install mods screen, you can choose to install your own [custom mod](https://steampipe.io/docs/mods/overview) by clicking on the **install a custom mod** link. Steampipe Cloud supports installation of custom mods subject to the following rules:
* The repo must be publicly hosted on GitHub.
* There must be at least [one semver tag](https://devhints.io/semver) (not a pre-release) satisfying the provided semver constraint.
* The tagged version must contain a mod.sp file at the root of the repo.

Installed mods are updated every day to the latest version satisfied by the semver constraint. The default of * means that the latest tagged version will be installed daily.

Input your custom mod publicly hosted GitHub URL, and a version constraint if applicable (if left empty, will default to "*"). Once inputted, click the **Install Mods** button.

Installation should typically only take a few seconds. You can then head over to the **Dashboards** tab where you'll see a list of the available dashboards for the custom mod you installed.


## Managing Mod Variables

When you install a mod in a workspace, any [variables](mods/mod-variables) that the mod uses will be visible in Steampipe Cloud.

Go to the **Settings** tab of your workspace and then to the **Mods** sub-tab. From there you can click the mod you wish to view/manage the variables for.

Within the mod detail screen, you will see a list of the available variables, with a section per variable. You'll see the current value and can edit this and **Save** if you are an owner of the workspace (implicit for personal workspaces, but [explicit within an organization](cloud/organizations#managing-users)).

Depending on the type of the variable, the editor will change, but you'll typically see either a text, a number or a text/number list editor that will allow you to easily manage the value.

Once you've saved a mod variable, this should take effect in your workspace within a matter of seconds. If you head back to the workspace **Dashboards** tab, you will see the impact of that change in any dashboards that depend on it.

## Uninstalling Mods

You can delete a workspace from its detail view. First, go to the **Settings** tab. You should be on the **Mods** sub-tab by default. From there you'll see a list of mods installed in the workspace. Click on the mod you wish to delete and in the detail screen that's shown, scroll to the bottom and click **Uninstall Mod**. Follow the confirmation instructions in the modal and the mod will be uninstalled from your workspace.

After this has completed, you'll no longer see any dashboards for this mod in the **Dashboards** tab.
