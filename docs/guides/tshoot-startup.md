---
title: Troubleshooting Startup Errors
sidebar_label: Troubleshooting Startup Errors
---


# Troubleshooting Startup Errors

Like any software, Steampipe can encounter issues during startup that can prevent it from functioning properly. These startup errors can be frustrating and difficult to troubleshoot, especially if you are new to using the tool. In this guide, we will explore some common was to troubleshoot and resolve startup errors.  Whether you're a seasoned Steampipe user or just getting started, this guide will help you get your queries up and running in no time.


## Steampipe Log Files

Steampipe writes logs to the `~/.steampipe/logs/` directory.  There are separate files for the PostgreSQL database logs and  for plugin logs.  These files contain information that can help troubleshoot problems.

By default, Steampipe writes logs at `WARN` level or higher, however you can change the logging level setting the [STEAMPIPE_LOG_LEVEL](https://steampipe.io/docs/reference/env-vars/steampipe_log) environment variable:
```bash
export STEAMPIPE_LOG_LEVEL=TRACE
```

Standard log levels are supported (`TRACE`, `DEBUG`, `INFO`, `WARN`, `ERROR`).

Note that you must restart Steampipe after changing the log level for it to take effect.


## Increasing the Startup Timeout

By default, Steampipe will wait up to 30 seconds for the Postgres process to start accepting queries after it has been started.  You can change this timeout with the [STEAMPIPE_DATABASE_START_TIMEOUT](https://steampipe.io/docs/reference/env-vars/steampipe_database_start_timeout) environment variable:
```bash
# Set database start timeout to 5 minutes:
export STEAMPIPE_DATABASE_START_TIMEOUT=300
```

Note that `STEAMPIPE_DATABASE_START_TIMEOUT` is ignored if the database goes into recovery mode upon startup -- Steampipe will wait indefinitely for recovery to complete. This can be cancelled with `Ctrl+C`.



## Resetting the Steampipe Database

Sometimes the quickest way to restore service is to reset (reinstall) the Steampipe database.  Steampipe uses virtual tables but doesn't actually persist that data to the database.  As a result, reinstalling the database is usually a low risk operation.  

***If you save tables, functions or other data in the `public` schema they will be permanently deleted by this process!***

To reset / reinstall the database:

1. Stop any stray steampipe services
  ```bash
  steampipe service stop --force
  ```

1. Kill any stray steampipe processes
  ```bash
  pkill -f steampipe
  ```

1. Delete the database (Steampipe is just virtual tables)

  If desired, you can back up the database files by simply moving them instead of deleting them:

  ```bash
  mv  ~/.steampipe/db ~/steampipe.db.bak
  ```

  Otherwise, simply delete the `db` folder:

  ```bash
  rm -rf ~/.steampipe/db
  ```

1. Start steampipe to reinstall the DB
  ```bash
  steampipe query
  ```



## Reinstalling Everything

**All** of Steampipe's files are located in the install directory (`~/.steampipe`). 

***If you save tables, functions or other data in the `public` schema they will be permanently deleted by this process!***

To completely reinstall:

1. If desired, you can back up the files by simply moving them instead of deleting them:

  ```bash
  mv  ~/.steampipe ~/steampipe.bak
  ```

  Otherwise, simply delete the `.steampipe` folder:

  ```bash
  rm -rf ~/.steampipe
  ```

1. Start steampipe to reinstall
  ```bash
  steampipe query
  ```