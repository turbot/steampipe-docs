---
title: Using Steampipe in a GitLab CI/CD Pipeline
sidebar_label: GitLab
---

# Using Steampipe in a GitLab CI/CD Pipeline

GitLab provides a [hosted environment](https://docs.gitlab.com/ee/ci/) in which you can build, test, and deploy software. This happens in a [GitLab Runner](https://docs.gitlab.com/runner/). Let's install Steampipe into a shared runner on gitlab.com, then install a plugin and run a query.

## Installing Steampipe in a GitLab.com Runner

To run scripts when you push changes to a gitlab.com repo, you place them in a file called `.gitlab-ci.yml`. Here's an example that installs Steampipe into the runner's environment.

```
install:
  stage: build
  script:
    - echo "Hello, $GITLAB_USER_LOGIN, let's install Steampipe!"
    - /bin/sh -c "$(curl -fsSL https://raw.githubusercontent.com/turbot/steampipe/main/install.sh)"
```

The official command to install Steampipe begins with `sudo`. That isn't necessary here, though, because in this environment you already are the root user.

## Running Steampipe in a GitLab.com Runner

Steampipe cannot, however, run as root. So we'll create a non-privileged user, and switch to that user in order to run Steampipe commands. Our first command will install the [Hacker News](https://hub.steampipe.io/plugins/turbot/hackernews) plugin.

```
install:
  stage: build
  script:
    - echo "Hello, $GITLAB_USER_LOGIN, let's install Steampipe!"
    - adduser --disabled-password --shell /bin/bash jon
    - /bin/sh -c "$(curl -fsSL https://raw.githubusercontent.com/turbot/steampipe/main/install.sh)"
    - su jon -c "steampipe plugin install hackernews"
```

<div style={{"marginBottom":"2em","borderWidth":"thin", "borderStyle":"solid", "borderColor":"lightgray", "padding":"20px", "width":"90%"}}>
<img alt="gitlab-plugin-installed" src="/images/docs/ci-cd-pipelines/gitlab-plugin-installed.jpg" />
</div>

Next, we'll add a file called `hn.sql` file to the repo.

```sql
select 
  id, 
  title
from 
  hackernews_item 
where 
  type = 'story'
  and title is not null
 order by 
   id desc
limit 5
```

Finally, we'll copy `hn.sql` into the home directory of the non-privileged user, then run a query.

```
install:
  stage: build
  script:
    - echo "Hello, $GITLAB_USER_LOGIN, let's install Steampipe!"
    - adduser --disabled-password --shell /bin/bash jon
    - cp hn.sql /home/jon
    - cd /home/jon
    - ls -l
    - /bin/sh -c "$(curl -fsSL https://raw.githubusercontent.com/turbot/steampipe/main/install.sh)"
    - su jon -c "steampipe plugin install hackernews"
    - su jon -c "steampipe query hn.sql"
```

<div style={{"marginBottom":"2em","borderWidth":"thin", "borderStyle":"solid", "borderColor":"lightgray", "padding":"20px", "width":"90%"}}>
<img alt="gitlab-query-output" src="/images/docs/ci-cd-pipelines/gitlab-query-output.jpg" />
</div>


