---
title: Configure
sidebar_label: Configure
---

# Configuring Steampipe Postgres FDW

To use the Steampipe Postgres FDW, you first have to create the foreign server and import the foreign schema. 

Login to Postgres as a superuser and create the extension:

```sql
DROP EXTENSION IF EXISTS steampipe_postgres_aws CASCADE;
CREATE EXTENSION IF NOT EXISTS steampipe_postgres_aws;
```

If you want, you can verify the extension was created:
```sql
select * from pg_extension
```

Now create a foreign server.  Many plugins include a default configuration that may "just work", but more often you will want to explicitly set the configuration by passing the `config` option to specify the plugin-specific configuration:

```sql
DROP SERVER IF EXISTS steampipe_aws_01;
CREATE SERVER steampipe_aws_01 FOREIGN DATA WRAPPER steampipe_postgres_aws OPTIONS (config 'profile = "my_aws_profile"');
```

> [!IMPORTANT]
> Many plugins use environment variables or configuration files from the user's $HOME directory for some configuration options.  Be aware that the user context is whichever user Postgres is running as!***

The `config` option takes an HCL string with the plugin [connection](https://steampipe.io/docs/managing/connections) arguments.  These arguments vary per plugin. You can view the available options and syntax for the plugin in the [Steampipe hub](https://hub.steampipe.io/plugins).

Note that HCL is newline-sensitive.  To specify multiple arguments, you must include the line break inside the string:
```sql
CREATE SERVER steampipe_aws_01 FOREIGN DATA WRAPPER steampipe_postgres_aws OPTIONS (config 'access_key="AKIA4YFAKEKEYT99999"
  secret_key="A32As+zuuBFThisIsAFakeSecretNb77HSLmcB"
  regions = ["*"]');
```


If you want, you can verify the foreign server was created:

```sql
select * from information_schema.foreign_servers
select * from information_schema.foreign_server_options
```

Now that the server has been set up, create a schema and import the foreign tables:
```sql
DROP SCHEMA IF EXISTS aws_01 CASCADE;
CREATE SCHEMA aws_01;
COMMENT ON SCHEMA aws_01 IS 'steampipe aws fdw';
IMPORT FOREIGN SCHEMA aws_01 FROM SERVER steampipe_aws_01 INTO aws_01;
```

You can query the information schema to see the foreign tables that have been added to your schema:

```sql
select
  foreign_table_name
from
  information_schema.foreign_tables
where
  foreign_table_schema = 'aws_01'
```
```sql
--------------------------------------------------------------+
| foreign_table_name                                           |
|--------------------------------------------------------------|
| aws_wellarchitected_workload                                 |
| aws_guardduty_finding                                        |
| aws_vpc_verified_access_instance                             |
| aws_cloudformation_stack_set                                 |
| aws_route53_resolver_rule                                    |
| aws_securityhub_insight                                      |
| aws_securityhub_member                                       |
...
```

Your FDW is now configured! You should now be able to run queries!

```sql
select * from aws_01.aws_account;
```

You can install as many Steampipe Postgres FDWs as you like.  The installation process is the same for all plugins, though the `config` arguments vary.


## Multiple Foreign Servers

You can create multiple foreign servers for the same extension (plugin type).  For instance, you can add a foreign server and schema for each of your AWS accounts.

Because the configuration is set on the foreign server, you need to create a new foreign server for each distinct instance. You will re-use the extension that you created for the first AWS foreign server:

```sql
DROP SERVER IF EXISTS steampipe_aws_02;
CREATE SERVER steampipe_aws_02 FOREIGN DATA WRAPPER steampipe_postgres_aws OPTIONS (config 'profile = "my_aws_profile_2"');
```

Now that the server has been set up, create a schema and import the foreign tables:
```sql
DROP SCHEMA IF EXISTS aws_02 CASCADE;
CREATE SCHEMA aws_02;
COMMENT ON SCHEMA aws_02 IS 'steampipe aws fdw - aws_02';
IMPORT FOREIGN SCHEMA aws_02 FROM SERVER steampipe_aws_02 INTO aws_02;
```

You can now query the tables in your new schema:
```sql
select * from aws_02.aws_account
```

You can even create views to aggregate them:

```sql
CREATE VIEW aws_account AS
  select * from aws_01.aws_account 
  union all select * from aws_02.aws_account
```

```sql
select * from aws_account
```

## Editing the Configuration

If desired, you can change the foreign server configuration by editing the `config` option:

```sql
ALTER SERVER steampipe_aws_01 OPTIONS (SET config 'profile = "my_new_profile"
 regions = ["*"]');
```

## Removing the configuration
You can remove the FDW configuration by dropping the relevant objects:

```
DROP SCHEMA IF EXISTS aws01 CASCADE;
DROP SERVER IF EXISTS steampipe_aws_01;
DROP EXTENSION IF EXISTS steampipe_postgres_aws CASCADE;
```

## Caching
By default, query results are cached for 5 minutes. You can change the duration with the [STEAMPIPE_CACHE_MAX_TTL](/docs/reference/env-vars/steampipe_cache_max_ttl):

```bash
export STEAMPIPE_CACHE_MAX_TTL=600  # 10 minutes
```

or disable caching with the [STEAMPIPE_CACHE](/docs/reference/env-vars/steampipe_cache):
```bash
export STEAMPIPE_CACHE=false
```


## Logging
You can set the logging level with the [STEAMPIPE_LOG_LEVEL](/docs/reference/env-vars/steampipe_log) environment variable.  By default, the log level is set to `warn`.  Logs are written to the Postgres database logs.

```bash
export STEAMPIPE_LOG_LEVEL=DEBUG
```
