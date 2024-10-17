---
title:  Turbot Pipes
sidebar_label: Turbot Pipes
---

# Turbot Pipes

**[Turbot Pipes](/docs/steampipe-cloud)** is the only intelligence, automation & security platform built specifically for DevOps. Pipes provides hosted Steampipe database instances, shared dashboards, snapshots, and more!

While the Steampipe CLI is optimized for a single developer doing a single thing at a single point in time, Pipes is designed for many users doing many things across time.  Turbot Pipes provides additional benefits above and beyond the Steampipe CLI:

- **Managed Steampipe instance**. The Steampipe workspace database instance hosted in Turbot Pipes is available via a public Postgres endpoint. You can query the workspace from the Turbot Pipes web console, run queries or controls from a remote Steampipe CLI instance, or connect to your workspace from many [third-party tools](https://turbot.com/pipes/docs/connect).

- **Multi-user support**.  Steampipe [Organizations](https://turbot.com/pipes/docs/organizations) allow you to collaborate and share workspaces and connections with your team.   With [Pipes Enterprise](https://turbot.com/pipes/docs/plans/enterprise), you can create your own isolated [Tenant](https://turbot.com/pipes/docs/tenants), with a custom domain for your environment (e.g. `acme.pipes.turbot.com`). Your tenant has its own discrete set of user accounts, organizations, and workspaces, giving you centralized visibility and control. You can choose which [authentication methods](https://turbot.com/pipes/docs/tenants/settings#authentication-methods) are allowed, configure which [domains to trust](https://turbot.com/pipes/docs/tenants/settings#trusted-login-domains), and set up [SAML](https://turbot.com/pipes/docs/tenants/settings#saml) to integrate your Pipes tenant with your single-sign-on solution.

- **Snapshot Scheduling and sharing**.  Turbot Pipes allows you to[ save and share dashboard snapshots](https://turbot.com/pipes/docs/dashboards#saving--sharing-snapshots), either internally with your team or publicly with a sharing URL.  You can even [schedule snapshots ](https://turbot.com/pipes/docs/queries#scheduling-query-snapshots) and be notified when complete.
 

- **Persistent CMDB with Datatank**.  A Turbot Pipes [Datatank](https://turbot.com/pipes/docs/datatank) provides a mechanism to proactively query connections at regular intervals and store the results in a persistent schema.  You can then query the stored results instead of the live schemas, resulting in reduced query latency (at the expense of data freshness).

There's no cost to get started!

- **[Sign up for Turbot Pipes →](https://pipes.turbot.com)**
- **[Take me to the docs →](https://turbot.com/pipes/docs)**