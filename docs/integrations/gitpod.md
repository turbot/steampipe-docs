---
title: Using Steampipe in Gitpod
sidebar_label: Gitpod
---
# Using Steampipe in Gitpod

[Gitpod](https://www.gitpod.io/) is an open source platform provisioning ready-to-code developer environments that integrates with GitHub. Here we integrate a Github project with Gitpod to install Steampipe, then install a plugin and run a query.

## Installing Steampipe in Gitpod

To run scripts, first connect your GitHub repository to your Gitpod workspace and create a `.gitpod.yml` file that contains the definitions. Here's an example that installs Steampipe.

```yaml
tasks:
  - name: Install Steampipe with RSS Plugin
    init: |
      sudo /bin/sh -c "$(curl -fsSL https://raw.githubusercontent.com/turbot/steampipe/main/install.sh)"
      steampipe -v

```

## Running Steampipe in Gitpod

In order to run Steampipe commands, we will first install the [RSS](https://hub.steampipe.io/plugins/turbot/rss) plugin.

```yaml
tasks:
  - name: Install Steampipe with RSS Plugin
    init: |
      sudo /bin/sh -c "$(curl -fsSL https://raw.githubusercontent.com/turbot/steampipe/main/install.sh)"
      steampipe -v
      steampipe plugin install steampipe
      steampipe plugin install rss

ports:
 # Steampipe/ PostgreSQL
  - port: 9193

```

<div style={{"marginBottom":"2em","borderWidth":"thin", "borderStyle":"solid", "borderColor":"lightgray", "padding":"20px", "width":"90%"}}>
<img alt="gitpod-plugin-installed" src="/images/docs/ci-cd-pipelines/gitpod-config-install.png" />
</div>

Next, we'll update the file with a query to list items from an RSS feed.

```yaml
tasks:
  - name: Install Steampipe with RSS Plugin
    init: |
      sudo /bin/sh -c "$(curl -fsSL https://raw.githubusercontent.com/turbot/steampipe/main/install.sh)"
      steampipe -v
      steampipe plugin install steampipe
      steampipe plugin install rss
      steampipe query "select title, published, link from rss_item where feed_link = 'https://www.hardcorehumanism.com/feed/' order by published desc;"
    command: |
      steampipe service status

ports:
 # Steampipe/ PostgreSQL
  - port: 9193

```

<div style={{"marginBottom":"2em","borderWidth":"thin", "borderStyle":"solid", "borderColor":"lightgray", "padding":"20px", "width":"90%"}}>
<img alt="gitpod-query-output" src="/images/docs/ci-cd-pipelines/gitpod-config-data-preview.png" />
</div>

That's it! Now you can use any of Steampipe's [plugins](https://hub.steampipe.io/plugins) and [mods](https://hub.steampipe.io/mods) in your Gitpod workspace.
