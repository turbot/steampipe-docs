---
title: CData alternative for DevOps to live-query APIs with SQL
sidebar_label: CData
---

# Steampipe versus CData


**Steampipe:** Query APIs, code and more with SQL. Zero-ETL from 140 data sources.


**CData:** ODBC/JDBC/.NET drivers for SaaS applications and services.



 | | **Steampipe** | **CData** | 
| --- | --- | --- |
| **Audience** | DevOps engineers who query cloud infrastructure and local systems | Data professionals and business analysts integrating diverse data sources |
| **Deployment** | Single binary runs locally or elsewhere | Drivers embedded in applications |
| **Data sources** | <a href="http://hub.steampipe.io" target="_blank">hub.steampipe.io</a> | <a href="http://www.cdata.com/drivers" target="_blank">cdata.com/drivers</a> |
| **Live query / zero-ETL** | <a href="https://github.com/turbot/steampipe" target="_blank">Yes</a> | Yes |
| **CLI for query and export** | <a href="https://powerpipe.io/docs/reference/cli" target="_blank">Yes</a> | No |
| **Concurrency** | <a href="https://aws.amazon.com/blogs/opensource/querying-aws-at-scale-across-apis-regions-and-accounts/" target="_blank">Yes</a> | No |
| **Postgres endpoint** | <a href="https://steampipe.io/docs/managing/service" target="_blank">Yes</a> | No |
| **Terms** | Open source, always-free <a href="http://pipes.turbot.com" target="_blank">SaaS</a> developer tier, <a href="https://turbot.com/pipes/pricing" target="_blank">paid tiers</a> for teams | Proprietary, free trial versions available, commercial licenses vary by data source and usage volume |

# When to choose Steampipe over CData

CData is typically embedded in business applications that access data using ODBC/JDBC/.NET drivers.

  
Steampipe is the preferred alternative for DevOps engineers who query cloud infrastructure, SaaS services, and local systems. 

# About Steampipe

<a href="https://steampipe.io/" target="_blank">Steampipe</a> is the zero-ETL way to query APIs and services. Use it to expose data sources to SQL.

**Query clouds like a database**. Just use <a href="https://steampipe.io/docs/sql/steampipe-sql" target="_blank">SQL</a> to query cloud services, and <a href="https://steampipe.io/blog/use-shodan-to-test-aws-public-ip" target="_blank">join across them</a>, to fetch live data <a href="https://aws.amazon.com/blogs/opensource/querying-aws-at-scale-across-apis-regions-and-accounts/" target="_blank">faster</a> than you ever thought possible.

**Tap into a rich plugin ecosystem**. Query a growing collection of <a href="https://hub.steampipe.io/" target="_blank">140+ data sources</a>, each documented with <a href="https://hub.steampipe.io/plugins/turbot/aws/tables/aws_s3_bucket" target="_blank">copy/paste/run examples</a>. 

**Use any database**. Plugins work with the batteries-included Postgres, or in your <a href="https://steampipe.io/blog/2023-12-postgres-extensions" target="_blank">Postgres</a> or <a href="https://steampipe.io/blog/2023-12-sqlite-extensions" target="_blank">SQLite</a>. 

**Deploy anywhere**. It’s a single binary, use it locally or deploy it in <a href="https://steampipe.io/docs/integrations/overview" target="_blank">CI/CD pipelines</a>.

# Get Started with Steampipe

First <a href="https://steampipe.io/downloads" target="_blank">download Steampipe</a>, then check out the <a href="https://hub.steampipe.io" target="_blank">plugins</a> and start running queries. For a team experience, try Steampipe in <a href="https://turbot.com/pipes" target="_blank">Turbot Pipes</a>.

