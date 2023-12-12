---
title: Configure
sidebar_label: Configure
---


# Configuring Steampipe SQLite Extensions

> ***Note: You must use a version of SQLite that has [extension loading](#enabling-sqlite-extension-loading) enabled!***

To use the Steampipe SQLite extension, you first have to load the extension module.  Run SQLite, and in the SQLite shell load the extension with the `.load` command:
```
$ sqlite3
sqlite> .load ./steampipe_sqlite_extension_github.so
```

Once the extension is loaded, the virtual tables will appear.  You can run the SQLite `pragma module_list` command to see them:
```sql
sqlite> pragma module_list;
pragma_table_info
github_issue_comment
json_each
github_workflow
github_traffic_view_weekly
...
```


Now that the extension is loaded, we have to configure it with plugin-specific options.  Many plugins include a default configuration that may "just work", but you can explicitly set the configuration with the `steampipe_configure_{plugin}` function:

```sql
sqlite> select steampipe_configure_github('token="ghp_Bt2iThisIsAFakeToken1234567"');
```

Each extension includes its own `steampipe_configure` function that takes as its argument a string containing the HCL configuration options for the plugin.  The options vary per plugin, and match the [connection](https://steampipe.io/docs/managing/connections) options for the corresponding plugin.  You can view the available options and syntax for the plugin in the [Steampipe hub](https://hub.steampipe.io/plugins).  

Note that HCL is newline-sensitive.  To specify multiple arguments, you must include the line break:
```sql
sqlite> select steampipe_configure_aws('
   access_key="AKIA4YFAKEKEYT99999"
   secret_key="A32As+zuuBFThisIsAFakeSecretNb77HSLmcB"
');
```


## Persisting Your Configuration
SQLite does not persist your module configuration; you need to load and configure the module(s) each time you start SQLite.  Fortunately, SQLite provides options for loading these commands from a file.

Create a file with the commands you wish to run when SQLite starts:  

```sql
-- Turn on column headers
.headers ON

-- Set output to table
.mod table

-- Load and Configure Github extension
.load ./steampipe_sqlite_extension_github.so
select steampipe_configure_github('token="ghp_Bt2iThisIsAFakeToken1234567"');

-- Load and Configure AWS extension
.load ./steampipe_sqlite_extension_aws.so
select steampipe_configure_aws('
   access_key="AKIA4YFAKEKEYT99999"
   secret_key="A32As+zuuBFThisIsAFakeSecretNb77HSLmcB"
');

```

To load this *every time you start SQLite*, name the file `.sqliterc` and save it to the root of your home directory.

Alternatively, you can give the file another name and then pass the file to the `--init` argument when starting SQLite:

```bash
./sqlite3 my_db --init ./init.sql
```

Or run the file after starting SQLite with the `.read` command:
```bash
sqlite> .read ./init.sql
```



## Enabling SQLite extension loading

The Steampipe SQLite extensions are packaged as loadable modules.  You must use a version of SQLite that has extension loading enabled. Some SQLite distributions (including the version that ships with MacOS) disable module loading as a compilation option, and you can't enable it.  In this case, you have to install a version that supports extensions.  You can download a precompiled SQLite binary for your platform [from the SQLite downloads page](https://www.sqlite.org/download.html) or use a package manager such as `brew`, `yum`, or `apt` to install it.


If you try to run the `.load` command but you get an error like `Error: unknown command or invalid arguments:  "load". Enter ".help" for help` you may not have extension loading enabled.  If your installation has the `OMIT_LOAD_EXTENSION` compile option, then it does not support loadable modules:
```bash
$ sqlite3 :memory: 'select * from pragma_compile_options()' | grep OMIT_LOAD_EXTENSION
```


## Caching
By default, query results are cached for 5 minutes. You can change the duration with the [STEAMPIPE_CACHE_MAX_TTL](docs/reference/env-vars/steampipe_cache_max_ttl):

```bash
export STEAMPIPE_CACHE_MAX_TTL=600  # 10 minutes
```

or disable caching with the [STEAMPIPE_CACHE](docs/reference/env-vars/steampipe_cache):
```bash
export STEAMPIPE_CACHE=false
```


## Logging
You can set the logging level with the [STEAMPIPE_LOG_LEVEL](/docs/reference/env-vars/steampipe_log) environment variable.  By default, the log level is set to `warn`.

```bash
export STEAMPIPE_LOG_LEVEL=DEBUG
```

SQLite logs are written to STDERR, and they will be printed to the console by default.  You can redirect them to a file instead with the standard file redirection mechanism:

```bash
sqlite3 2> errors.log
```