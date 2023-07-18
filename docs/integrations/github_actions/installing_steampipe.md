---
title: Installing Steampipe in GitHub Actions
sidebar_label: Installing Steampipe
---

# Installing Steampipe in GitHub Actions

GitHub provides a [hosted environment](https://docs.github.com/en/actions/) in which you can build, test, and deploy software.

## Installing Steampipe

To run scripts when you push changes to a GitHub repository, create a file `.github/workflows/steampipe.yml`. This will install the latest version of Steampipe.

```
name: Run Steampipe
on:
  push:

jobs:
  steampipe:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v3
      - uses: turbot/steampipe-action-setup@v1
```

## Installing and configuring plugin(s)

The [turbot/steampipe-action-setup](https://github.com/turbot/steampipe-action-setup) action can also install and configure plugins.

```
- uses: turbot/steampipe-action-setup@v1
  with:
      steampipe-version: 'latest'
      plugin-connections: |
        connection "hackernews" {
          plugin = "hackernews"
        }
```

Next, add a step to run a query:

```
- uses: turbot/steampipe-action-setup@v1
  with:
      steampipe-version: 'latest'
      plugin-connections: |
        connection "hackernews" {
          plugin = "hackernews"
        }
- name: Query HN
  run: steampipe query "select id, title from hackernews_item where type = 'story' and title is not null order by id desc limit 5"
```

For more examples, please see [turbot/steampipe-action-setup examples](https://github.com/turbot/steampipe-action-setup#examples).
