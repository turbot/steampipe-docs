---
title: steampipe variable
sidebar_label: steampipe variable
---

# steampipe variable

Manage steampipe variables in the current mod and its direct dependents.


## Usage
```bash
steampipe variable [command] [flags]
```

## Sub-Commands

| Command | Description
|-|-
| `list` | List variables for the the current mod and its direct dependents.

## Flags

| Flag | Applies to | Description
|-|-|-
| `--output string` | `list` |  Select a console output format: `table` or `json` (default `table`)

## Examples

List variables:

```bash
steampipe variable list
```


List variables in json format:

```bash
steampipe variable list --output json
```