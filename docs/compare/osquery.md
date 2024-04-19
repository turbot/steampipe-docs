---
title: Steampipe versus OSQuery
sidebar_label: OSQuery
---

# Steampipe versus OSQuery


**Steampipe:** Query APIs, code and more with SQL. Zero-ETL from 140 data sources.


**OSQuery:** Query your devices like a database



 | | **Steampipe** | **OSQuery** | 
| --- | --- | --- |
| **Audience** | DevOps engineers who query cloud infrastructure and local systems | DevOps engineers who deploy agents to query local systems |
| **Deployment** | Single binary runs locally or elsewhere | Agent-based deployment on servers and endpoints |
| **Programming style** | SQL | SQL |
| **Data sources** | <a href="http://hub.steampipe.io" target="_blank">hub.steampipe.io</a> | Local system tables and extensions |
| **CLI for query and export** | <a href="https://powerpipe.io/docs/reference/cli" target="_blank">Yes</a> | Yes |
| **Live query / zero-ETL** | <a href="https://github.com/turbot/steampipe" target="_blank">Yes</a> | No |
| **Concurrency** | <a href="https://aws.amazon.com/blogs/opensource/querying-aws-at-scale-across-apis-regions-and-accounts/" target="_blank">Yes</a> | No |
| **Postgres endpoint** | <a href="https://steampipe.io/docs/managing/service" target="_blank">Yes</a> | No |
| **Terms** | Open source, always-free <a href="http://pipes.turbot.com" target="_blank">SaaS</a> developer tier, <a href="https://turbot.com/pipes/pricing" target="_blank">paid tiers</a> for teams | Free open-source version, commercial versions available. |

# When to choose Steampipe over OSQuery

OSQuery is typically used to query local system configuration.

  
Steampipe is the preferred alternative for DevOps engineers who query cloud infrastructure, SaaS services, and local systems. 

