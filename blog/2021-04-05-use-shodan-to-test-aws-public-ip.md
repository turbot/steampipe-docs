---
id: use-shodan-to-test-aws-public-ip
title: "Using Shodan to test AWS Public IPs"
category: Featured Plugin
description: "Shift Left Join Security: Threat hunting AWS IPs with Shodan and SQL."
summary: "Shift Left Join Security: Threat hunting AWS IPs with Shodan and SQL."
author:
  name: David Boeke
  twitter: "@boeke"
publishedAt: "2021-04-04T11:00:00"
durationMins: 8
image: /images/blog/use-shodan-to-test-aws-public-ip/hero.jpg
slug: use-shodan-to-test-aws-public-ip
schema: "2021-01-08"
---


### Front Matter

[Structured Query Language (SQL)](https://en.wikipedia.org/wiki/SQL): A domain-specific language for working with data and data structures. It is particularly useful in handling relations (joining) data across entities. SQL is 50 years old and is still the [most popular language for data work](https://www.dataquest.io/blog/why-sql-is-the-most-important-language-to-learn/).

[Shodan](https://shodan.io) is a search engine for Internet connected devices, ranging from internet connected cameras to cloud servers.

[Steampipe](https://steampipe.io) is an open source CLI that uses Postgres Foreign Data Wrappers to instantly query cloud APIs using SQL. The [Steampipe plugin for Shodan](https://hub.steampipe.io/plugins/turbot/shodan) enables use of SQL to query host metadata, open ports, DNS info and even potential exploit information. This metadata can be made even more powerful when joined with data from other cloud services.

## The Objective
##### Automate checks to find open ports and vulnerabilities for AWS resources.

### Step 1: What EC2 instances have public IPs?

Using the Steampipe CLI we can query for AWS EC2 instances with public IPs:

<div className="mt-4 row text-center"> 
  <div className="col col-0 col-lg-1"></div>
  <div className="col col-12 col-lg-7 col-xl-6">
    <Terminal title="steampipe cli">
      <TerminalCommand enableCopyToClipboard={true}>
        {`   
select
  title,
  public_ip_address as ip_addr
from
  aws_ec2_instance
where
  public_ip_address is not null; 
        `}
    </TerminalCommand>
    <TerminalResult>
    {`
  +---------------------+-------------------+
  | title               | public_ip_address |
  +---------------------+-------------------+
  | Redhat 8 Test       | 42.93.36.148      |
  | Amazon Linux 2 Test | 42.239.34.42      |
  | Ubuntu 20 Test      | 42.239.46.31      |
  | Ubuntu 18 Test      | 42.94.153.81      |
  +---------------------+-------------------+
        `}
      </TerminalResult>
    </Terminal>
  </div>
</div>

### Step 2: Initiate Shodan Scan 

To ensure Shodan has the latest information on these instances, we will initiate an on-demand scan using the Shodan CLI.  The CLI command uses the format `shodan scan submit <ip address>`.

We use Steampipe’s `--output=csv and --header=false` options to just a list of IP addresses delimited with newlines:

<div className="row mb-4 mt-4 text-center"> 
  <div className="col col-0 col-lg-1"></div>
  <div className="col col-12 col-lg-8">
    <img width="100%" className="center-block" src="/images/blog/use-shodan-to-test-aws-public-ip/ip-query.png" />
  </div>
  <div className="col col-0 col-lg-1"></div>
</div>

We can assign that output to a variable and then iteratively call the Shodan CLI:

<div className="row mb-4 mt-4 text-center"> 
  <div className="col col-0 col-lg-1"></div>
  <div className="col col-12 col-lg-9">
    <img width="100%" className="center-block" src="/images/blog/use-shodan-to-test-aws-public-ip/shodan-loop.png" />
  </div>
  <div className="col col-0 col-lg-1"></div>
</div>

### Step 3: Install and test Shodan plugin 

<div className="mt-4 row text-center"> 
  <div className="col col-12">
    <Terminal title="steampipe cli">
      <TerminalResult>
        {`   
$ steampipe plugin install shodan
Updated plugin: shodan@latest v0.0.1
Documentation:  https://hub.steampipe.io/plugins/turbot/shodan
 
$ steampipe query
Welcome to Steampipe v0.3.5
For more information, type .help
 
> .inspect shodan
+------------------------+-----------------------------------------------------------------------------------------+
| TABLE                  | DESCRIPTION                                                                             |
+------------------------+-----------------------------------------------------------------------------------------+
| shodan_account_profile | Information about the Shodan account linked to the caller.                              |
| shodan_api_info        | Information about the API plan belonging to the given API key.                          |
| shodan_dns_reverse     | Hostnames defined for the given IP.                                                     |
| shodan_domain          | Get all the subdomains and other DNS entries for the given domain.                      |
| shodan_exploit         | List the exploits requested for this account.                                           |
| shodan_host            | ISP, geolocation, open ports and other info about a host at a given IP address.         |
| shodan_host_service    | Publicly accessible services that have been found on a given host during a Shodan scan. |
| shodan_port            | Ports returns a list of port numbers that the crawlers are looking for.                 |
| shodan_protocol        | List of the protocols that can be used when launching an Internet scan.                 |
| shodan_scan            | List the scans requested for this account.                                              |
| shodan_search          | Search the internet for hosts matching the query parameters.                            |
| shodan_service         | List of the services Shodan can detect.                                                 |
+------------------------+-----------------------------------------------------------------------------------------+
 
To get information about the columns in a table, run .inspect {connection}.{table}
 
>
        `}
      </TerminalResult>
    </Terminal>
  </div>
</div>

### Step 4: Check if Shodan scans are complete

<div className="mt-4 mb-4row text-center"> 
  <div className="col col-0 col-lg-1"></div>
  <div className="col col-12 col-lg-7 col-xl-6">
    <Terminal title="steampipe cli">
      <TerminalCommand enableCopyToClipboard={true}>
        {`   
select id, status from shodan_scan;
        `}
    </TerminalCommand>
    <TerminalResult>
    {`
  +------------------+------------+
  | id               | status     |
  +------------------+------------+
  | Wd29N6mNt1pM9EfY | DONE       |
  | lJyP683eCjduMoSy | PROCESSING |
  | D1pAzPLBZ8hcK9rr | PROCESSING |
  | wj21Ho3hAUb3nN3E | DONE       |
  +------------------+------------+
        `}
      </TerminalResult>
    </Terminal>
  </div>
</div>

### Step 5: Join Shodan and AWS Data

Once all of the scans are complete we can now join our EC2 instance information with the shodan scan information.

<div className="mt-4 mb-4row text-center"> 
  <div className="col col-12">
    <Terminal title="steampipe cli">
      <TerminalCommand enableCopyToClipboard={true}>
        {`   
select
  instance_id,
  ports,
  vulns,
  security_groups
from
  aws_ec2_instance
left join
  shodan_host on public_ip_address = ip
where
  public_ip_address is not null;
        `}
    </TerminalCommand>
    <TerminalResult>
    {`
+---------------------+----------+--------------------+-------------------------------------------------------------+
| instance_id         | ports    | vulns              | security_groups                                             |
+---------------------+----------+--------------------+-------------------------------------------------------------+
| i-0dc60dd191cb84239 | <null>   | <null>             | [{"GroupId":"sg-042fe79169eb42818","GroupName":"lockdown"}] |
| i-042a51a815773780d | [80,22]  | <null>             | [{"GroupId":"sg-042042bac705630f4","GroupName":"bastion"}]  |
| i-00cf426db9b8a58b6 | [22]     | <null>             | [{"GroupId":"sg-0423f79169eb42818","GroupName":"default"}]  |
| i-0e97f373db42dfa3f | [22,111] | ["CVE-2018-15919"] | [{"GroupId":"sg-0423f79169eb42818","GroupName":"default"}]  |
+---------------------+----------+--------------------+-------------------------------------------------------------+
        `}
      </TerminalResult>
    </Terminal>
  </div>
</div>
<br />

## Other [#shiftleftjoin](https://twitter.com/search?q=%23shiftleftjoin) opportunities with Shodan:

#### What TLS ciphers are enabled on my load balancers?

<div className="mt-4 mb-4row text-center"> 
  <div className="col col-12">
    <Terminal title="steampipe cli">
      <TerminalCommand enableCopyToClipboard={true}>
        {`   
select
  lb.title,
  s.ip,
  h.ssl->'cert'->'expired' as cert_exp,
  h.ssl->'versions'        as allowed_ssl_ciphers,
  h.ssl->'cipher'->'bits'  as bits
from
  aws_ec2_application_load_balancer lb,
  shodan_search s,
  shodan_host_service h
where
  s.query = lb.dns_name
  and h.ip = s.ip
  and h.port = 443;
        `}
      </TerminalCommand>
      <TerminalResult>
        {`
+------------------+----------+-------------------------------------------------------------+------+
| title            | cert_exp | allowed_ssl_ciphers                                         | bits |
+------------------+----------+-------------------------------------------------------------+------+
| shodan-test-alb1 | false    | ["TLSv1","-SSLv2","-SSLv3","TLSv1.1","TLSv1.2","-TLSv1.3"]  | 128  |
| shodan-test-alb2 | false    | ["-TLSv1","-SSLv2","-SSLv3","-TLSv1.1","TLSv1.2","TLSv1.3"] | 256  |
+------------------+----------+-------------------------------------------------------------+------+
        `}
      </TerminalResult>
    </Terminal>
  </div>
</div>

#### What elastic IP addresses have open ports?

<div className="mt-4 mb-4row text-center"> 
  <div className="col col-12">
    <Terminal title="steampipe cli">
      <TerminalCommand enableCopyToClipboard={true}>
        {`   
select
  allocation_id,
  public_ip,
  ports
from
  aws_vpc_eip
left join
  shodan_host on public_ip = ip;
        `}
      </TerminalCommand>
      <TerminalResult>
        {`
  +----------------------------+---------------+----------+
  | allocation_id              | public_ip     | ports    |
  +----------------------------+---------------+----------+
  | eipalloc-0f9ae42acece4855f | 3.42.34.26    | [80,443] |
  | eipalloc-0268097c2fea42da2 | 18.42.215.212 | [22,53]  |
  +----------------------------+---------------+----------+
        `}
      </TerminalResult>
    </Terminal>
  </div>
</div>
<br />

## Thank you Shodan Team!

We think it is incredible to have such a useful service to integrate with for security testing against dynamic cloud environments. A huge shout out to the entire [Shodan team](https://twitter.com/shodanhq) for making it accessible via their API.