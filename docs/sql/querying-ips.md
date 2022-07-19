---
title: Querying IP Addresses
sidebar_label: Querying IP Addresses
---

# Querying IP Addresses

One of the primary uses of Steampipe is for auditing cloud and network infrastructure.  As such, many columns store IP addresses or network addresses in CIDR format.

Steampipe leverages the native [Postgres inet and cidr data types](https://www.postgresql.org/docs/14/datatype-net-types.html) for IP addresses and cidr ranges.   The essential difference between `inet` and `cidr` data types is that `inet` accepts values with nonzero bits to the right of the netmask, whereas `cidr` does not;  `inet` columns can either be a single IP address OR a CIDR range, but `cidr` MUST be a CIDR range.

You can use the standard [Postgres network address functions and operators](https://www.postgresql.org/docs/14/functions-net.html) with Steampipe.


You can **extract the host, network, netmask, and broadcast addresses** from a CIDR:
```sql
select
  vpc_id,
  cidr_block,
  host(cidr_block),
  broadcast(cidr_block),
  netmask(cidr_block),
  network(cidr_block)
from
  aws_vpc;
```

You can find IP addresses that **match exactly**: 

```sql
select
  title,
  private_ip_address,
  public_ip_address
from
  aws_ec2_instance
where
  private_ip_address = '172.31.52.163';
```

or find IPs that are **contained within a given CIDR range**:
```sql
select
  title,
  private_ip_address,
  public_ip_address
from
  aws_ec2_instance
where
  private_ip_address <<= '172.16.0.0/12';
```

or test whether a **CIDR contains an address**:
```sql
select
  title,
  cidr_block
from
  aws_vpc_subnet
where
  cidr_block >> '172.31.52.163';
```


Of course you can use 'not' to look for IP addresses that are NOT in a range as well:
```sql
select
  vpc_id,
  cidr_block,
  state,
  region
from
  aws_vpc
where
  not cidr_block <<= '10.0.0.0/8'
  and not cidr_block <<= '192.168.0.0/16'
  and not cidr_block <<= '172.16.0.0/12';
```

You can even **join tables** where an address from one table is contained in the network of another:
```sql
select
  i.title as instance,
  i.private_ip_address,
  s.title as subnet,
  s.cidr_block
from
  aws_ec2_instance as i
  join aws_vpc_subnet as s on i.private_ip_address <<= s.cidr_block;
```

This works for networks as well - you can **test whether one CIDR is contained entirely in another**:
```sql
select
  title as subnet,
  cidr_block
from
  aws_vpc_subnet
where
  cidr_block <<= '10.0.0.0/8';
```
