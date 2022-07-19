---
id: introducing-steampipe
title: "Steampipe: select * from cloud;"
category: Announcement
description: The extensible SQL interface to your favorite cloud APIs
author:
  name: Steampipe Team
publishedAt: "2021-01-21T13:00:00"
durationMins: 5
image: /images/blog/2021-01-21-introducing-steampipe/cool_tools_wide.jpg
slug: introducing-steampipe
schema: "2021-01-08"
---

Steampipe, a new open source project from Turbot, enables cloud pros (e.g. software developers, operations engineers and security teams) to query their favorite cloud services with SQL. It has quickly become one of our favorite tools in-house and we hope it finds a way into your tool box as well.

The heart of Steampipe is an intuitive command line interface (CLI) that solves the challenges encountered when asking questions of cloud resources and services. Traditional tools and custom scripts that provide visibility into these services are cumbersome, inconsistent across providers and painful to maintain. Steampipe provides a consistent, explorable and interactive approach across IaaS, PaaS and SaaS services.

### The Challenge of Context Switching

Everyone that has worked with cloud service providers understands how hours can be wasted bouncing back and forth between tools to answer simple questions about your environment. The diagram below illustrates common challenges encountered when extracting data from cloud-based systems.

<img width="100%" src="/images/blog/2021-01-21-introducing-steampipe/traditional-workflow.png" />

The traditional tools we use to gain insight and answer questions about our environments challenge us instead of empower us. Key challenges of the current capabilities:

1. Simple questions quickly devolve into software development projects.
1. Commercial solutions require you to grant access outside your organization or require deployment of complex infrastructure.
1. Tools that take snapshots of your environment, require synchronization and force you to work on stale data.

These barriers take the practitioners time and attention away from what is important: asking questions and finding answers.

### Steampipe's Approach

The goal of Steampipe is to simplify the workflow for discovery and querying of cloud based configuration information. Steampipe exposes your cloud configuration as a high-performance relational database. This allows you to explore the live configuration of running cloud assets without switching context. With Steampipe, SQL tables represent complex cloud resources such as IAM policies, security groups, databases, storage buckets, SSL certificates, etc..

<img width="100%" src="/images/blog/2021-01-21-introducing-steampipe/steampipe-workflow.png" />

### How Steampipe Works

We designed the architecture of Steampipe to be easy to understand, simple to install, and extensible. Our single step install process lets you get up to speed quickly with the Steampipe CLI on your local machine or deployed to a virtual machine.

<img width="60%" src="/images/blog/2021-01-21-introducing-steampipe/how-it-works-diagram.png" />

When a user writes a Steampipe SQL query, Steampipe translates it into API calls that are executed in real-time across one or more cloud service APIs. The data returning is organized into tables using a PostgreSQL Foreign Data Wrapper (FDW); allowing the user to join, filter, and aggregate that data just like any other database table.

### Excited? We are too!

Steampipe v0.1.0 is [available for download today](https://steampipe.io/downloads). Install, query and get cloud work done. 

We can’t wait to see what you query, and iterate based on your feedback. If you’d like to help expand the Steampipe universe, or even dive into the CLI code, the whole project is open source (https://github.com/turbot/steampipe) and we’d love to collaborate! 

Keep an eye on https://hub.steampipe.io for the latest supported resource types from both Turbot and the Steampipe community, and for your own personal guided tour of steampipe, checkout our documentation: https://steampipe.io/docs.

If you experience any issues, please report them on our [GitHub issue tracker](https://github.com/turbot/steampipe/issues) or join our [Slack workspace](https://steampipe.io/community/join).
