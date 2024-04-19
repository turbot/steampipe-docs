---
title: Steampipe versus Fivetran
sidebar_label: Fivetran
---

# Steampipe versus Fivetran


**Steampipe:** Query APIs, code and more with SQL. Zero-ETL from 140 data sources.


**Fivetran:** Automated data integration to centralize your data.



 | | **Steampipe** | **Fivetran** | 
| --- | --- | --- |
| **Audience** | DevOps engineers who query cloud infrastructure and local systems | Data analysts and data engineers who need to centralize data from SaaS services and databases |
| **Deployment** | Single binary runs locally or elsewhere | SaaS |
| **Programming style** | SQL | SQL (in the warehouse) |
| **Data sources** | <a href="http://hub.steampipe.io" target="_blank">hub.steampipe.io</a> | <a href="http://www.fivetran.com/connectors" target="_blank">www.fivetran.com/connectors</a> |
| **CLI for query and export** | <a href="https://powerpipe.io/docs/reference/cli" target="_blank">Yes</a> | No |
| **Live query / zero-ETL** | <a href="https://github.com/turbot/steampipe" target="_blank">Yes</a> | No |
| **Concurrency** | <a href="https://aws.amazon.com/blogs/opensource/querying-aws-at-scale-across-apis-regions-and-accounts/" target="_blank">Yes</a> | Yes |
| **Postgres endpoint** | <a href="https://steampipe.io/docs/managing/service" target="_blank">Yes</a> | N/A |
| **Terms** | Open source, always-free <a href="http://pipes.turbot.com" target="_blank">SaaS</a> developer tier, <a href="https://turbot.com/pipes/pricing" target="_blank">paid tiers</a> for teams | Commercial SaaS |

# When to choose Steampipe over Fivetran

Fivetran is typically used to consolidate data from SaaS services and databases into a data warehouse.

  
Steampipe is the preferred alternative for DevOps engineers who query cloud infrastructure, SaaS services, and local systems. 

