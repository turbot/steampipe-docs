---
id: enriched-ip-logs
title: "Shift Left Join: Where are those IP addresses coming from?"
category: Shift Left Join
description: "Enrich VPC FLow Logs with geographic locations from ipstack."
summary: "Enrich VPC FLow Logs with geographic locations from ipstack."
author:
  name: Jon Udell
  twitter: "@judell"
publishedAt: "2022-05-31T14:00:00"
durationMins: 5
image: /images/blog/2022-05-enriched-ip-logs/opener.png
slug: enriched-ip-logs
schema: "2021-01-08"
---

In this episode of #shiftleftjoin you'll learn how to enrich the IP addresses in your logs with geographic locations using the [ipstack](https://hub.steampipe.io/plugins/ipstack) plugin. There are other ways: the [Net](https://hub.steampipe.io/plugins/turbot/net) plugin does reverse DNS lookups, the [AbuseIPDB](https://hub.steampipe.io/plugins/turbot/abuseipdb) plugin looks for malicious activity associated with IP addresses, and we've [elsewhere shown](https://steampipe.io/blog/use-shodan-to-test-aws-public-ip) how the [Shodan](https://hub.steampipe.io/plugins/net) plugin scans for exploitable vulnerabilities. Here we'll focus on geographic locations; the same technique applies to the other plugins, or indeed to any plugin that maps an API that can be usefully correlated with IP addresses.

## Prerequisites

We assume in this example that you have:
- [Steampipe](https://steampipe.io/downloads)
- An AWS account
- The AWS Plugin for Steampipe [installed and connected](https://hub.steampipe.io/plugins/turbot/aws)
- The [ipstack](https://hub.steampipe.io/plugins/ipstack) plugin
- An AWS log that records inbound IP addresses

## Step 1: List recently-seen log events

First let's take a look at recent VPC Flow Log events.

```
-- query q1

select 
  src_addr,
  timestamp
from
  aws_vpc_flow_log_event
where
  log_group_name = 'my_cloudwatch_log_group'
  and timestamp > now() - interval '1 hour'
order by
  timestamp desc
```

```
+-----------------+---------------------------+
| src_addr        | timestamp                 |
+-----------------+---------------------------+
| 45.143.203.18   | 2022-05-23T08:17:41-07:00 |
| 167.94.145.31   | 2022-05-23T08:17:41-07:00 |
| 162.142.125.179 | 2022-05-23T08:17:41-07:00 |
| 49.233.11.129   | 2022-05-23T08:16:39-07:00 |
| 193.163.125.158 | 2022-05-23T08:16:39-07:00 |
| 2.56.57.173     | 2022-05-23T08:16:39-07:00 |
```


## Step 2. Map addresses to locations

To perform location lookups on that set of addresses, join the data with the `ipstack_ip` table. 

```
-- query q2

with addrs as (
  select 
    src_addr
  from
    aws_vpc_flow_log_event
  where
    log_group_name = 'my_cloudwatch_log_group'
    and timestamp > now() - interval '1 hour'
  order by
    timestamp desc
)
select
  a.src_addr,
  i.continent_name,
  i.country_name
from
  addrs a
join 
  ipstack_ip i
on
  a.src_addr = i.ip
limit
  50
```

```
+-----------------+----------------+----------------+
| src_addr        | continent_name | country_name   |
+-----------------+----------------+----------------+
| 58.216.180.210  | Asia           | China          |
| 43.129.33.99    | Asia           | Indonesia      |
| 45.145.66.212   | Asia           | Russia         |
| 185.191.34.200  | Asia           | Russia         |
| 45.93.201.96    | Asia           | Russia         |
| 91.240.118.75   | Asia           | Russia         |
| 122.32.143.249  | Asia           | South Korea    |
| 78.128.113.94   | Europe         | Bulgaria       |
| 89.248.165.151  | Europe         | Netherlands    |
| 89.248.165.199  | Europe         | Netherlands    |
```

Steampipe will cache this data for 5 minutes. If you're going to be exploring it for longer than that, you might want to increase the cache TTL, or persist the data as a table or materialized view. Another reason to persist the data: `ipstack` lookups are metered, and you might want to conserve your lookups. Here's one way to save the results.

## Step 3. Persist the data for analysis

```
create table ipstack_places as 
  -- insert query q2
```

The data in the `ipstack_places` table will, of course, soon be stale. You can drop and recreate the table to explore the latest log entries. Or you can use a Postgres materialized view. 

```
drop table ipstack_places;
create materialized view ipstack_places as 
  -- insert query q2
```

A materialized view replays a SQL query, as does a normal view, but unlike a normal view it also persists the data. Now `log_ips` is effectively a read-only table. You can't alter its records but you can update the table with the command `refresh materialized view ipstack_places`. 

## Step 4: Chart the locations

To chart this data using Steampipe's [dashboard subsystem](https://steampipe.io/blog/dashboards-as-code), create a folder, visit it, and add this `mod.sp` file.

```
mod "ip_lookups" {
  title = "IP lookups"
}

query "ipstack_continents" {
  sql = <<EOQ
    select
      i.continent_name,
      count(*)
    from
      ipstack_places i
    group by
      continent_name
  }

query "ipstack_countries" {
  sql = <<EOQ
    select
      i.country_name,
      count(*)
    from
      ipstack_places i
    group by
      country_name
  }

}

dashboard "ips_by_location" {

  container {

    chart {
      width = 4
      title = "IPs by continent"
      type = "donut"
      query = query.ipstack_continents
    }

    chart {
      width = 4
      title = "IPs by country"
      type = "donut"
      query = query.ipstack_countries
    }

  }

}

```

Now start the dashboard server and visit `localhost:9194`.

```
steampipe dashboard
```

![](/images/blog/2022-05-enriched-ip-logs/ipstack_dashboard.jpg)

Problem solved! Now you can see where those IP addresses are coming from. You can further enrich addresses in your logs with the [AbuseIPDB](https://hub.steampipe.io/plugins/turbot/abuseipdb), [Net](https://hub.steampipe.io/plugins/turbot/net), and [Shodan](https://hub.steampipe.io/plugins/turbot/shodan) plugins.

## Related articles

- [Use Shodan to test AWS Public IPS](https://steampipe.io/blog/use-shodan-to-test-aws-public-ip)
- [Find all AWS EC2 instances not using IMDSv2](https://steampipe.io/blog/shift-left-join-ec2-instances-not-using-imdsv2)
