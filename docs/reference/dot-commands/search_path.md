---
title: .search_path
sidebar_label: .search_path
---

# .search_path
Display the current [search path](/docs/managing/connections#setting-the-search-path), or set the search path by passing in a comma-separated list.


## Usage
```
.search_path [string,string,...]
```

## Examples
show the current search_path:
```
.search_path
```

Set the search path:
```
.search_path aws_prod,aws_dev,gcp_prod,slack,github,shodan
```
