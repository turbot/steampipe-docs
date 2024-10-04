---
title: Using Steampipe in Jenkins
sidebar_label: Jenkins
---

# Using Steampipe in Jenkins

Jenkins provides a [hosted environment](https://www.jenkins.io/) in which you can build, test, and deploy software. This happens in a [Jenkins Pipeline](https://www.jenkins.io/doc/book/pipeline/). Let's use a pipeline to install Steampipe, then install a plugin and run a query.

## Installing Steampipe in a Jenkins pipeline

To run scripts, you first create a `Jenkinsfile` which is a text file that contains the definition of a Jenkins Pipeline. Here's an example that installs Steampipe.

```
pipeline {
    agent any

    stages {
        stage("Install") {
            steps {
                sh "curl -s -L https://github.com/turbot/steampipe/releases/latest/download/steampipe_linux_amd64.tar.gz | tar -xzf -"
                echo "installed steampipe"
            }
        }
    }
}
```

## Running Steampipe in a Jenkins pipeline

In order to run Steampipe commands, we will first install the [Hacker News](https://hub.steampipe.io/plugins/turbot/hackernews) plugin.

```
pipeline {
    agent any

    stages {
        stage("Install") {
            steps {
                sh "curl -s -L https://github.com/turbot/steampipe/releases/latest/download/steampipe_linux_amd64.tar.gz | tar -xzf -"
                echo "installed steampipe"
                sh './steampipe plugin install hackernews'
            }
        }
    }
}
```

<div style={{"marginBottom":"2em","borderWidth":"thin", "borderStyle":"solid", "borderColor":"lightgray", "padding":"20px", "width":"90%"}}>
<img alt="gitlab-plugin-installed" src="/images/docs/ci-cd-pipelines/jenkins-plugin-installed.png" />
</div>

Next, we'll update the file to include a query to fetch the top 5 stories from `hackernews_top`.

```
pipeline {
    agent any

    stages {
        stage("Install") {
            steps {
                sh "curl -s -L https://github.com/turbot/steampipe/releases/latest/download/steampipe_linux_amd64.tar.gz | tar -xzf -"
                echo "installed steampipe"
                sh './steampipe plugin install hackernews'
                sh './steampipe query "select id, title, score from hackernews_top order by score desc limit 5"'
            }
        }
    }
}
```

<div style={{"marginBottom":"2em","borderWidth":"thin", "borderStyle":"solid", "borderColor":"lightgray", "padding":"20px", "width":"90%"}}>
<img alt="gitlab-query-output" src="/images/docs/ci-cd-pipelines/jenkins-query-output.png" />
</div>

That's it! Now you can use any of Steampipe's [plugins](https://hub.steampipe.io/plugins) to enrich your Jenkins pipelines.
