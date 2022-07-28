# Steampipe Docs

The open-source version of the Steampipe Documentation. You can give us feedback and request for changes by submitting issues and pull requests in this repository.

## Docs

Docs are written in markdown format and are located in `docs` folder. The entry-point document will contain front-matter with `slug: /`.

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
