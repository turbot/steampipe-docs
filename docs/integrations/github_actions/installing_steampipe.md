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
      - uses: francois2metz/setup-steampipe@v1
```

## Installing and configuring plugin(s)

The [francois2metz/setup-steampipe](https://github.com/francois2metz/setup-steampipe) action can also install and configure plugins.


```
- uses: francois2metz/setup-steampipe@v1
  with:
      steampipe-version: 'latest'
      steampipe-plugins: |
        {
          "hackernews": {}
        }
```

<div style={{"marginBottom":"2em","borderWidth":"thin", "borderStyle":"solid", "borderColor":"lightgray", "padding":"20px", "width":"90%"}}>
<img alt="github-plugin-installed" src="/images/docs/ci-cd-pipelines/github-plugin-installed.png" />
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

Finally run the query with Steampipe:

```
- uses: francois2metz/setup-steampipe@v1
  with:
      steampipe-version: 'latest'
      steampipe-plugins: |
        {
          "hackernews": {}
        }
- name: Query HN
  run: steampipe query hn.sql
```

<div style={{"marginBottom":"2em","borderWidth":"thin", "borderStyle":"solid", "borderColor":"lightgray", "padding":"20px", "width":"90%"}}>
<img alt="github-query-output" src="/images/docs/ci-cd-pipelines/github-query-output.png" />
</div>
