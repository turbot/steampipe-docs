---
title: Using Steampipe in CircleCI
sidebar_label: CircleCI
---

# Using Steampipe in CircleCI

CircleCI provides a [hosted environment](https://circleci.com/) in which you can build, test, and deploy software. It integrates with services such as GitHub, GitLab and Bitbucket to listen to events that trigger pipelines or consume source code. Here we integrate a GitLab project with CircleCI to install Steampipe, then install a plugin and run a query.

## Installing Steampipe in CircleCI

To run scripts, first connect your GitLab repository to CircleCI and create a `config.yml` file that contains the definitions of the Pipeline. Here's an example that installs Steampipe.

```yaml
version: 2.1

jobs:
  install:
    machine: true
    steps:
      - checkout
      - run: echo "Hello, let's install Steampipe!"
      - run: sudo /bin/sh -c "$(curl -fsSL https://raw.githubusercontent.com/turbot/steampipe/main/install.sh)"

workflows:
  my-workflow:
    jobs:
      - install

```

## Running Steampipe in CircleCI

In order to run Steampipe commands, we will first install the [Hacker News](https://hub.steampipe.io/plugins/turbot/hackernews) plugin.

```yaml
version: 2.1

jobs:
  install:
    machine: true
    steps:
      - checkout
      - run: echo "Hello, let's install Steampipe!"
      - run: sudo /bin/sh -c "$(curl -fsSL https://raw.githubusercontent.com/turbot/steampipe/main/install.sh)"
      - run: 'steampipe plugin install hackernews'

workflows:
  my-workflow:
    jobs:
      - install

```

<div style={{"marginBottom":"2em","borderWidth":"thin", "borderStyle":"solid", "borderColor":"lightgray", "padding":"20px", "width":"90%"}}>
<img alt="gitlab-plugin-installed" src="/images/docs/ci-cd-pipelines/circleci-plugin-install.png" />
</div>

Next, we'll update the file with a query to fetch the top 10 stories from `hackernews_best`.

```yaml
version: 2.1

jobs:
  install:
    machine: true
    steps:
      - checkout
      - run: echo "Hello, let's install Steampipe!"
      - run: sudo /bin/sh -c "$(curl -fsSL https://raw.githubusercontent.com/turbot/steampipe/main/install.sh)"
      - run: 'steampipe plugin install hackernews'
      - run: 'steampipe query "select id, title, score from hackernews_best order by score desc limit 10"'

workflows:
  my-workflow:
    jobs:
      - install

```

<div style={{"marginBottom":"2em","borderWidth":"thin", "borderStyle":"solid", "borderColor":"lightgray", "padding":"20px", "width":"90%"}}>
<img alt="gitlab-query-output" src="/images/docs/ci-cd-pipelines/circleci-query-output.png" />
</div>

That's it! Now you can use any of Steampipe's [plugins](https://hub.steampipe.io/plugins) to enrich your CircleCI pipelines.
