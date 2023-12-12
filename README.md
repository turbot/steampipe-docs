![image](https://steampipe.io/images/steampipe-social-preview-4.png)

# Steampipe docs format & structure

Docs are written in Markdown format and are located in the `docs` folder. The entry-point document will contain front-matter with `slug: /`.

Each document requires the following frontmatter, adjust the values as per your requirement:

```yaml
id: learn
title: Learn Steampipe
sidebar_label: Learn Steampipe
```

We support up to 2 levels of docs, e.g.:

- `docs/foo`
- `docs/foo/bar`

For your docs to appear in the sidebar, you need to edit `docs/sidebar.json`. This is an array of sidebar entries, which are either stings matching the path of the required document, or a category to nest the docs down 1 level.

Any images required by docs must be placed in `/images/docs/...` and must be referenced by the tag `<img src="/images/docs/..." />`.

# Guidelines for contribution

Thank you for your interest in contributing to Steampipe documentation! We greatly value feedback and contributions from our community.

Please read through this document before you submit any pull requests or issues. It will help us to collaborate more effectively.

## What to expect when you contribute

When you submit a pull request, our team is notified and will respond as quickly as we can. We'll do our best to work with you to ensure that your pull request adheres to our style and standards.

We look forward to receiving your pull requests for:

* Inaccuracies in the content
* Information gaps in the content that need more detail to be complete
* Grammatical errors or typos
* Suggested rewrites that improve clarity and reduce confusion

## How to contribute

To contribute, send us a pull request.

1. [Fork the repository](https://help.github.com/articles/fork-a-repo/).
2. In your fork, make your change in a branch that's based on this repo's **main** branch.
3. Commit the change to your fork, using a clear and descriptive commit message.
4. [Create a pull request](https://help.github.com/articles/creating-a-pull-request-from-a-fork/)

Before you send us a pull request, please be sure that:

1. You're working from the latest source on the **main** branch.
2. You check [existing open](https://github.com/turbot/steampipe-docs/pulls) pull requests to be sure that someone else hasn't already addressed the problem.
3. You [create an issue](https://github.com/turbot/steampipe-docs/issues/new) before working on a contribution that will take a significant amount of your time.

For contributions that will take a significant amount of time, [open a new issue](https://github.com/turbot/steampipe-docs/issues/new) to pitch your idea before you get started. Explain the problem and describe the content you want to see added to the documentation. We don't want you to spend a lot of time on a contribution that might be outside the scope of the documentation or that's already in progress.

## Finding contributions to work on

If you'd like to contribute, but don't have a project in mind, look at the [open issues](https://github.com/turbot/steampipe-docs/issues/news) in this repository for some ideas.

## Open Source & Contributing

This repository is published under the [CC BY-NC-ND](https://creativecommons.org/licenses/by-nc-nd/4.0/) license. Please see our [code of conduct](https://github.com/turbot/.github/blob/main/CODE_OF_CONDUCT.md). Contributors must sign our [Contributor License Agreement](https://turbot.com/open-source#cla) as part of their first pull request. We look forward to collaborating with you!

[Steampipe](https://steampipe.io) is a product produced from this open source software, exclusively by [Turbot HQ, Inc](https://turbot.com). It is distributed under our commercial terms. Others are allowed to make their own distribution of the software, but they cannot use any of the Turbot trademarks, cloud services, etc. You can learn more in our [Open Source FAQ](https://turbot.com/open-source).
