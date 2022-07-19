---
title: .search_path_prefix
sidebar_label: .search_path_prefix
---


## .search_path_prefix
Set a prefix to the current [search path](managing/connections#setting-the-search-path) by passing in a comma-separated list.


### Usage
```
.search_path_prefix  [string,string,...]
```

### Examples

Move the `aws_123456789012` connection to the front of the search path:
```
.search_path_prefix  aws_123456789012
```

Move the `aws_dev` and `gcp_dev` connections to the front of the search path:
```
.search_path_prefix  aws_dev,gcp_dev
```