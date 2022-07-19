---
title: Interactive Queries
sidebar_label: Interactive Queries
---

# Interactive Query Shell
Steampipe provides an interactive query shell that provides features like auto-complete, syntax highlighting, and command history to assist you in [writing queries](/docs/sql/steampipe-sql).

To open the query shell, run `steampipe query` with no arguments:

```bash
$ steampipe query
>
```

Notice that the prompt changes, indicating that you are in the Steampipe shell.

You can exit the query shell by pressing `Ctrl+d` on a blank line, or using the `.exit` command.


### Autocomplete
The query shell includes an autocomplete feature that will suggest words as you type.  Type `.` (period). Notice that the autocomplete appears with a list of the [Steampipe meta-commands](/docs/reference/dot-commands/overview) commands that start with `.`:

![](/images/docs/auto-complete-1.png)

As you continue to type, the autocomplete will continue to narrow down the list of tables to only those that match.

You can cycle forward through the list with the `Tab` key, or backward with `Shift+Tab`.  Tab to select `.tables` and hit enter.  The `.tables` command is executed, and lists all the tables that are installed and available to query.


### History
The query shell supports command history, allowing you to retrieve, run, and edit previous commands.  The command history works like typical unix shell command history, and persists across query sessions.  When on a new line, you can cycle back through the history with the `Up Arrow` or `Ctrl+p` and forward with `Down Arrow` or `Ctrl+n`.


### Key bindings
The query shell supports standard emacs-style key bindings:

| Keys | Description
|-|-
| `Ctrl+a` |	Move the cursor to the beginning of the line
| `Ctrl+e` |	Move the cursor to the end of the line
| `Ctrl+f` |	Move the cursor forward 1 character
| `Ctrl+b` |	Move the cursor backward 1 character
| `Ctrl+w` |	Delete a word backwards
| `Ctrl+d` |	Delete a character forwards.  On a blank line, `Ctrl+d` will exit the console
| `Backspace` | Delete a character backwards
| `Ctrl+p`, `Up Arrow` |	Go to the previous command in your history
| `Ctrl+n`, `Down Arrow` |	Go to the next command in your history



## Exploring Tables & Connections

### Connections
 
A Steampipe **Connection** represents a set of tables for a single data source. Each connection is represented as a distinct Postgres schema.

A connection is associated with a single instance of a single [plugin](/docs/managing/plugins) type. The boundary and scope of the connection varies by plugin, but is typically aligned with the vendor's CLI tool or API:

- An `azure` connection contains tables for a single Azure subscription
- An `aws` connection contains tables for a single AWS account

To view the installed connections, you can use the `.connections` :

```
> .connections
+------------+--------------------------------------------------+
| Connection |                      Plugin                      |
+------------+--------------------------------------------------+
| aws        | hub.steampipe.io/plugins/turbot/aws@latest       |
| github     | hub.steampipe.io/plugins/turbot/github@latest    |
| steampipe  | hub.steampipe.io/plugins/turbot/steampipe@latest |
+------------+--------------------------------------------------+

To get information about the tables in a connection, run '.inspect {connection}'
To get information about the columns in a table, run '.inspect {connection}.{table}'

```

Alternately, you can use `.inspect` command with no arguments.  The output is the same:
```
> .inspect
+------------+--------------------------------------------------+
| Connection |                      Plugin                      |
+------------+--------------------------------------------------+
| aws        | hub.steampipe.io/plugins/turbot/aws@latest       |
| github     | hub.steampipe.io/plugins/turbot/github@latest    |
| steampipe  | hub.steampipe.io/plugins/turbot/steampipe@latest |
+------------+--------------------------------------------------+

To get information about the tables in a connection, run '.inspect {connection}'
To get information about the columns in a table, run '.inspect {connection}.{table}'

```

### Tables
Steampipe **tables** provide an interface for querying dynamic data using standard SQL.  Steampipe tables do not actually *store* data, they query the source on the fly.  The details are hidden from you though - *you just query them like any other table!*

To view the tables in all active connections, you can use the `.tables` command:

```
> .tables
 ==> aws
+----------------------------------------+--------------------------------+
|                 Table                  |          Description           |
+----------------------------------------+--------------------------------+
| aws_acm_certificate                    | AWS ACM Certificate            |
| aws_api_gateway_api_key                | AWS API Gateway API Key        |
| aws_api_gateway_authorizer             | AWS API Gateway Authorizer     |
...
+----------------------------------------+--------------------------------+
 ==> github
+---------------------+-------------+
|        Table        | Description |
+---------------------+-------------+
| github_gist         |             |
| github_license      |             |
| github_organization |             |
| github_repository   |             |
| github_team         |             |
| github_user         |             |
+---------------------+-------------+

To get information about the columns in a table, run '.inspect {connection}.{table}'
```


To view only the tables in a specific connection, you can use the `.inspect` command with a connection name.  For example, to show all the tables in the `aws` connection:

```
> .inspect aws
+----------------------------------------+--------------------------------+
|                 Table                  |          Description           |
+----------------------------------------+--------------------------------+
| aws_acm_certificate                    | AWS ACM Certificate            |
| aws_api_gateway_api_key                | AWS API Gateway API Key        |
| aws_api_gateway_authorizer             | AWS API Gateway Authorizer     |
| aws_api_gateway_rest_api               | AWS API Gateway Rest API       |
...
+----------------------------------------+--------------------------------+

To get information about the columns in a table, run '.inspect {connection}.{table}'
```


### Columns
To get information about the **columns** in a table, run `.inspect {connection}.{table}`:

```
> .inspect aws.aws_iam_group
+----------------------+-----------------------------+--------------------------------+
|        Column        |            Type             |          Description           |
+----------------------+-----------------------------+--------------------------------+
| account_id           | text                        | The AWS Account ID in which    |
|                      |                             | the resource is located        |
| akas                 | jsonb                       | A list of AKAs (also-known-as) |
|                      |                             | that uniquely identify this    |
|                      |                             | resource                       |
| arn                  | text                        | The Amazon Resource Name (ARN) |
|                      |                             | specifying the group           |
| attached_policy_arns | jsonb                       | A list of managed policies     |
|                      |                             | attached to the group          |
| create_date          | timestamp without time zone | The date and time, when the    |
|                      |                             | group was created              |
| group_id             | text                        | The stable and unique string   |
|                      |                             | identifying the group          |
| inline_policies      | jsonb                       | A list of policy documents     |
|                      |                             | that are embedded as inline    |
|                      |                             | policies for the group         |
| name                 | text                        | The friendly name that         |
|                      |                             | identifies the group           |
| partition            | text                        | The AWS partition in which     |
|                      |                             | the resource is located (aws,  |
|                      |                             | aws-cn, or aws-us-gov)         |
| path                 | text                        | The path to the group          |
| region               | text                        | The AWS Region in which the    |
|                      |                             | resource is located            |
| title                | text                        | The display name for this      |
|                      |                             | resource                       |
| users                | jsonb                       | A list of users in the group   |
+----------------------+-----------------------------+--------------------------------+
```
