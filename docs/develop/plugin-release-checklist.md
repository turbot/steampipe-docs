---
title: Plugin Release Checklist
sidebar_label: Plugin Release Checklist
---

# Plugin Release Checklist

As of October 2023, we've absorbed 135+ plugins into the hub. If you want to contribute one -- and we hope you do! -- here are the most common things we ask contributors to check to prepare for the plugin's release. Feel free to tick the boxes as you go through the list!

- [Basic Configuration](#basic-configuration)
- [Configuration File](#configuration-file)
- [Credentials](#credentials)
- [Table and Column Names](#table-and-column-names)
- [Table and Column Descriptions](#table-and-column-descriptions)
- [Table and Column Design](#table-and-column-design)
- [Documentation](#documentation)
- [Final Review](#final-review)

## Basic Configuration

<input type="checkbox"/> <b>Repository name</b>

The repository name should use the format `steampipe-plugin-<pluginName>`, e.g., `steampipe-plugin-aws`, `steampipe-plugin-googledirectory`, `steampipe-plugin-microsoft365`. The plugin name should be one word, so there are always 3 parts in the repository name.

<input type="checkbox"/> <b>Repository topics</b>

To help with discoverability in GitHub, the repository topics should include:
- postgresql
- postgresql-fdw
- sql
- steampipe
- steampipe-plugin

<input type="checkbox"/> <b>Repository website</b>

The repository website/homepage should link to the Hub site. The URL is composed of the GitHub organization and plugin name, for instance:
- https://github.com/turbot/steampipe-plugin-aws: https://hub.steampipe.io/plugins/turbot/aws
- https://github.com/francois2metz/steampipe-plugin-airtable: https://hub.steampipe.io/plugins/francois2metz/airtable

<input type="checkbox"/> <b>Go version</b>

The Go version in `go.mod` and any workflows is 1.21.

<input type="checkbox"/> <b>.goreleaser.yml</b>

The `.goreleaser.yml` file uses the standard format, e.g., [AWS plugin .goreleaser.yml](https://github.com/turbot/steampipe-plugin-aws/blob/main/.goreleaser.yml).

<input type="checkbox"/> <b>CHANGELOG</b>

A `CHANGELOG.md` is included and contains release notes for the upcoming version (typically v0.0.1).

<input type="checkbox"/> <b>License</b>

The plugin uses the Apache License 2.0.

<input type="checkbox"/> <b>Makefile</b>

The `Makefile` file is present and builds to the correct plugin path.

## Configuration File

<input type="checkbox"/> <b>.spc examples</b>

The `config/PLUGIN.spc` file is neatly formatted, and explains each argument with links as appropriate, using realistic values, e.g., "xoxp-abcads…" instead of "TOKEN_HERE".

<input type="checkbox"/> <b>Environment variables</b>

Arguments that can also be set via environment variable include the environment variable name(s) in their descriptions.

## Credentials

<input type="checkbox"/> <b>Terraform compatibility</b>

If there's a Terraform provider for your API, the plugin supports the same credential methods as the provider.

<input type="checkbox"/> <b>Existing CLI credentials</b>

When there are commonly used CLI credentials, like `.aws/credentials`, the plugin works with them.

<input type="checkbox"/> <b>Expiry</b>

When credentials expire, and the API's SDK does not automatically refresh them, the plugin alerts the user and tells them how to refresh.

<input type="checkbox"/> <b>Environment variables</b>

It's possible to set credentials using an environment variable if the API's SDK also supports using environment variables.

## Table and Column Names

<input type="checkbox"/> <b>Standard names</b>

All table and column names follow our [Table & Column Naming Standards](https://steampipe.io/docs/develop/standards#naming).

## Table and Column Descriptions

<input type="checkbox"/> <b>Descriptions</b>

Every table and column has a description. These are consistent across tables.

<input type="checkbox"/> <b>Other standards</b>

All descriptions adhere to the [Table and Column Descriptions Standards](https://steampipe.io/docs/develop/standards#table-and-column-descriptions).

## Table and Column Design

<input type="checkbox"/> <b>Global and per-authenticated-user data</b>

Many plugins can return both global data, e.g., all GitHub repos or Google Drive files, and data only for the authenticated user (<i>my repos</i>, <i>my files</i>). If that's the case, there are separate tables, e.g. `github_repository` and `github_my_repository`.

<input type="checkbox"/> <b>Common columns</b>

If tables share columns, these are abstracted as shown in the AWS plugin's [common_columns.go](https://github.com/turbot/steampipe-plugin-aws/blob/main/aws/common_columns.go).

<input type="checkbox"/> <b>Required configuration arguments</b>

The plugin checks required configuration arguments are set once at load time.

### Logging

<input type="checkbox"/> <b>Error info</b>

When the plugin returns an error, it includes the location and any related args, along with the error itself. See [example](https://github.com/turbot/steampipe-plugin-linode/blob/343d38188e38e32635b1c65c3f0d69bd2d2ef87f/linode/table_linode_kubernetes_cluster.go#L46).

### Data Ingestion

<input type="checkbox"/> <b>Default transform</b>

The plugin sets a preferred transform as the default. For example, the [GitLab plugin](https://hub.steampipe.io/plugins/theapsgroup/gitlab) uses [DefaultTransform: transform.FromGo().NullIfZero()](https://github.com/theapsgroup/steampipe-plugin-gitlab/blob/main/gitlab/plugin.go#L16). Please see [Transform Functions](https://steampipe.io/docs/develop/writing-plugins#transform-functions) for a full list of transform functions.

<input type="checkbox"/> <b>Pagination</b>

The plugin implements pagination in each table's List function supported by the API's SDK. If pagination is implemented, the plugin sets the page size per request to the maximum allowed; however, if `QueryContext.Limit` is smaller than that page size, the page size should be set to the limit. See [example](https://github.com/turbot/steampipe-plugin-tfe/blob/253107f6d9851e14cc593ff657ddd3cb41c505bc/tfe/table_tfe_team.go#L48-L59).

<input type="checkbox"/> <b>Hydrate function pagination</b>

If a non-List hydrate function requires paging, consider separating that data into a separate table. Columns that require separate hydrate data that uses paging can lead to throttling and rate limiting errors unexpectedly.

<input type="checkbox"/> <b>Backoff and retry</b>

If the API SDK doesn't automate backoff and retry, the plugin leverages capabilities of the Steampipe plugin SDK's [RetryHydrate function](https://pkg.go.dev/github.com/turbot/steampipe-plugin-sdk/plugin#RetryHydrate). For instance, the `github_issue` table uses this function when [listing issues](https://github.com/turbot/steampipe-plugin-github/blob/d0a70b72e125c75940006ee6c66072c8bfa2e210/github/table_github_issue.go#L142) due to the strict throttling of the GitHub API.

<input type="checkbox"/> <b>Maximum concurrency</b>

If the API has strict rate limiting, the table sets [HydrateConfig.MaxConcurrency](https://pkg.go.dev/github.com/turbot/steampipe-plugin-sdk/plugin#HydrateConfig.MaxConcurrency) for the relevant hydrate functions. For instance, the `googleworkspace_gmail_message` table limits the number of [getGmailMessage calls](https://github.com/turbot/steampipe-plugin-googleworkspace/blob/55686791222b02e7fb117cb398ea3fd76c2d1b1e/googleworkspace/table_googleworkspace_gmail_message.go#L49-L54).

<input type="checkbox"/> <b>Context cancellation</b>

Each table's list hydrate function checks for remaining rows from the API SDK, and aborts inside loops (e.g., while streaming items) if there are none. (See [example](https://github.com/turbot/steampipe-plugin-aws/blob/a0050b3a27db7f61a353bc9ae38e7dd072ed87b9/aws/table_aws_cloudcontrol_resource.go#L110-L113).)

### Column Types

<input type="checkbox"/> <b>Money</b>

Money is represented as a string, not a double which is never exact.

### Dynamic Tables

<input type="checkbox"/> <b>Specifying tables to generate</b>

If the plugin can generate [dynamic tables](https://steampipe.io/docs/develop/writing-plugins#dynamic-tables), a configuration argument should allow users to specify which tables the plugin will generate. This configuration argument typically accepts a list of strings and should support filesystem glob patterns like in the [CSV plugin](https://hub.steampipe.io/plugins/turbot/csv#configuration).

If this configuration argument is not set or is explicitly empty, e.g., `paths = []`, then no dynamic tables should be generated.

<input type="checkbox"/> <b>Default tables</b>

The plugin should determine if it will generate dynamic tables by default after plugin installation based on if the configuration argument mentioned above is commented by default. For instance, in the [Prometheus plugin](https://github.com/turbot/steampipe-plugin-prometheus/blob/f6dbe388d729526a1a5a5b4c06d414dcc01c1548/config/prometheus.spc#L7-L14), the `metrics` configuration argument is commented. After plugin installation, the plugin will not generate dynamic tables unless the user adds a non-commented value for `metrics`.

You may not want to load dynamic tables by default if it drastically increases the plugin initialization time due to the number of tables.

<input type="checkbox"/> <b>Table name prefixes</b>

When naming dynamic tables, the plugin name prefix, e.g., `kubernetes_`, should be added if it helps avoid namespace collisions or if it helps group them with static tables that share the same prefix.

## Documentation

### Index Documentation

<input type="checkbox"/> <b>Front matter</b>

The index document contains a front matter block, like the one below:

```yml
---
organization: Turbot
category: ["security"]
icon_url: "/images/plugins/turbot/duo.svg"
brand_color: "#6BBF4E"
display_name: Duo Security
name: duo
description: Steampipe plugin for querying Duo Security users, logs and more.
og_description: Query Duo Security with SQL! Open source CLI. No DB required.
og_image: "/images/plugins/turbot/duo-social-graphic.png"
---
```
<input type="checkbox"/> <b>Front matter: category</b>

The category is an appropriate choice from the list at [hub.steampipe.io/plugins](https://hub.steampipe.io/plugins).

<input type="checkbox"/> <b>Front matter: icon_url</b>

The icon URL is a link to an `.svg` file hosted on hub.steampipe.io. Please request an icon through the [Turbot Community Slack](https://turbot.com/community/join) and a URL will be provided to use in this variable.

<input type="checkbox"/> <b>Front matter: brand color</b>

The color matches the provider's brand guidelines, typically stated on a page like [this one](https://www.twilio.com/brand/elements/colorresources) for Twilio.

<input type="checkbox"/> <b>Plugin description</b>

The description in `docs/index.md` is appropriate for the provider. The [AWS plugin](https://hub.steampipe.io/plugins/turbot/aws), for example, uses:

> AWS provides on-demand cloud computing platforms and APIs to authenticated customers on a metered pay-as-you-go basis.

The opening sentence of the Wikipedia page for the provider can be a good source of guidance here.

<input type="checkbox"/> <b>Credentials</b>

Credentials are the most important piece of documentation. The plugin:

- Explains scopes and required permissions
- Links to provider documentation
- Explains how to use existing CLI creds when that's possible

### Table Documentation

<input type="checkbox"/> <b>Useful examples</b>

Each table document shows 4 - 5 <i>useful</i> examples that reflect real-world scenarios. Please see [Writing Example Queries](https://steampipe.io/docs/develop/writing-example-queries) for common patterns and samples.

<input type="checkbox"/> <b>Column specificity</b>

Most examples specify columns. Using `SELECT *` is OK for one or two things, but generally not preferred as it can produce too much data to be helpful. See also [When Not to SELECT *](https://steampipe.io/blog/selective-select).

<input type="checkbox"/> <b>Required columns</b>

If some columns are required, these are called out and explained.

## Final Review

<input type="checkbox"/> <b>Testing</b>

The plugin has been tested on a real account with substantial data. Please note that errors and API throttling issues may not appear when using a test account with little data.

<input type="checkbox"/> <b>Matching query examples</b>

The example in `README.md` matches the one in `docs/index.md`.

<input type="checkbox"/> <b>Matching config examples</b>

The example in `config/PLUGIN.spc` matches the one in `docs/index.md#configuration`.

<input type="checkbox"/> <b>Social graphic</b>

The social graphic is included at the top of the README file and is uploaded to the Social preview feature in the GitHub repository. Please request a social graphic through the [Steampipe Slack](https://steampipe.io/community/join).

<input type="checkbox"/> <b>Ease of first use</b>

The plugin really nails easy setup, there's a short path to a first successful query, and it runs quickly.

<input type="checkbox"/> <b>Pre-mortem</b>

You've considered, and addressed, reasons why this plugin could fail to delight its community.
