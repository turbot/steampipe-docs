---
title: Distributions
sidebar_label: Distributions
---

# Distributions

Steampipe provides zero-ETL tools for fetching data directly from APIs and services.  Steampipe is offered in several distributions:
- The **Steampipe CLI** exposes APIs and services as a high-performance relational database, enabling you to write SQL-based queries to explore dynamic data. The Steampipe CLI is a turnkey solution that includes its own PostgreSQL database including plugin management.
- **[Steampipe Postgres FDWs](/docs/steampipe_postgres/overview)** are native Postgres Foreign Data Wrappers that translate APIs to foreign tables.  Unlike Steampipe CLI, which ships with its own Postgres server instance, the Steampipe Postgres FDWs can be installed in any supported Postgres database version.
- **[Steampipe SQLite Extensions](/docs/steampipe_sqlite/overview)** provide SQLite virtual tables that translate your queries into API calls, transparently fetching information from your API or service as you request it.
- **[Steampipe Export CLIs](/docs/steampipe_export/overview)** provide a flexible mechanism for exporting information from cloud services and APIs.  Each exporter is a stand-alone binary that allows you to extract data using Steampipe plugins *without a database*.
