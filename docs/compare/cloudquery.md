---
title: Steampipe versus Cloud Query
sidebar_label: Cloud Query
---

# Steampipe versus CloudQuery


**Steampipe:** Query APIs, code and more with SQL. Zero-ETL from 140 data sources.


**CloudQuery:** Extract, transform, and load data from public cloud providers.



 | | **Steampipe** | **CloudQuery** | 
| --- | --- | --- |
| **Audience** | DevOps engineers who query cloud infrastructure and local systems | DevOps engineers who extract cloud infrastructure data into a database |
| **Deployment** | Single binary runs locally or elsewhere | Single binary runs locally or elsewhere |
| **Programming style** | SQL | SQL |
| **Data sources** | <a href="http://hub.steampipe.io" target="_blank">hub.steampipe.io</a> | Cloud provider APIs |
| **CLI for query and export** | <a href="https://powerpipe.io/docs/reference/cli" target="_blank">Yes</a> | Yes |
| **Live query / zero-ETL** | <a href="https://github.com/turbot/steampipe" target="_blank">Yes</a> | No |
| **Concurrency** | <a href="https://aws.amazon.com/blogs/opensource/querying-aws-at-scale-across-apis-regions-and-accounts/" target="_blank">Yes</a> | Yes |
| **Postgres endpoint** | <a href="https://steampipe.io/docs/managing/service" target="_blank">Yes</a> | No |
| **Terms** | Open source, always-free <a href="http://pipes.turbot.com" target="_blank">SaaS</a> developer tier, <a href="https://turbot.com/pipes/pricing" target="_blank">paid tiers</a> for teams | Free open-source version, commercial version available. |

# When to choose Steampipe over CloudQuery

CloudQuery is typically used to extract cloud infrastructure configuration into a database for querying.

  
Steampipe is the preferred alternative for DevOps engineers who query cloud infrastructure, SaaS services, and local systems. 

