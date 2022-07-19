---
title: Database options
sidebar_label: database
---


### Database Options

**Database** options are used to control database options, such as the IP address and port on which the database listens.

#### Supported options  
| Argument | Default | Values | Description 
|-|-|-|-
| `port` | `9193` | any valid, open port number | The TCP port that postgres will listen on
| `listen` | `network` | `local`, `network`| The network listen mode when steampipe is started in service mode. Use `network` to listen on all IP addresses, or `local` to restrict to localhost. 
| `search_path` | All connections, alphabetically | Comma separated string | Set an exact [search path](managing/connections#setting-the-search-path).  Note that setting the search path in the database options sets it in the database; this setting will also be in effect when connecting to Steampipe from 3rd party tools.


#### Example: Database Options

```hcl
options "database" {
  port   = 9193                     # any valid, open port number
  listen = "local"                  # local, network
  search_path = "aws,aws2,gcp,gcp2" # comma-separated string; an exact search_path
}   
```