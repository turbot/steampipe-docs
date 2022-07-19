---
title: steampipe query
sidebar_label: steampipe query
---


## steampipe query
Execute SQL queries interactively, or by a query argument.

To open the interactive query shell, run `steampipe query` with no arguments.  The query shell provides a way to explore your data and run multiple queries. 

If a query string is passed on the command line then it will be run immediately and the command will exit.  Alternatively, you may specify one or more files containing SQL statements.  You can run multiple SQL files by passing a glob or a space separated list of file names.

If the Steampipe service was previously started by `steampipe service start`, steampipe will connect to the service instance - otherwise, the query command will start the `service`. At the end of the query command or session, if other sessions have not connected to the `service` already, the `service` will be shutdown. If other session have already connected to the `service`, then the last session to exit will shutdown the `service`.

### Usage
```bash
steampipe query [query] [flags] 
```

### Flags

| Flag | Description
|-|-
| `--header` | Include column headers csv and table output (default true)
| `--output string` | Output format: csv, json or table (default "table")
| `--search-path strings` | Set a custom [search path](managing/connections#setting-the-search-path) for the steampipe user for a query session (comma-separated)
| `--search-path-prefix strings` | Set a prefix to the current [search path](managing/connections#setting-the-search-path) for a query session (comma-separated)
| `--separator string` | Separator string for csv output (default ",")
| `--timing` | Turn on the timer which reports query time
| `---var string`| Specify the value of a mod variable. 
| `--var-file string`| Specify an .spvars file containing mod variable values. 
| `--watch` | Watch .sql and .sp files in the current workspace (works only in interactive mode) (default true)



### Examples

Open an interactive query console:
```bash
steampipe query
```

Run a specific query directly:
```bash
steampipe query "select * from aws_s3_bucket"
```

Run the SQL command in the `my_queries/my_query.sql` file:
```bash
steampipe query my_queries/my_query.sql
```

Run the SQL commands in all `.sql` files in the `my_queries` directory and concatenate the results:
```bash
steampipe query my_queries/*.sql
```

Run a specific query directly and report the query execution time:
```bash
steampipe query "select * from aws_s3_bucket" --timing
```

Run a specific query directly and return output in json format:
```bash
steampipe query "select * from aws_s3_bucket" --output json
```

Run a specific query directly and return output in CSV format:
```bash
steampipe query "select * from aws_s3_bucket" --output csv
```

Run a specific query directly and return output in pipe-separated format:
```bash
steampipe query "select * from aws_s3_bucket" --output csv --separator '|'
```


Run a query with a specific search_path:
```bash
steampipe query --search-path="aws_dmi,github,slack" "select * from aws_s3_bucket"
```

Run a query with a specific search_path_prefix:
```bash
steampipe query --search-path-prefix="aws_dmi" "select * from aws_s3_bucket"
```