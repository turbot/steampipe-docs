---
id: use-github-plugin-to-connect-with-coummunity
title: "Using Steampipe's GitHub plugin to connect with your open source community"
category: Featured Plugin
description: "Review stale issues, visualize release cadence, and find external contributors"
author:
    name: Jon Udell
    twitter: "@judell"
publishedAt: "2021-10-04T08:00:00"
durationMins: 12
image: /images/blog/2021-10-04-github-plugin/release-timeline.jpg
slug: use-github-plugin-to-connect-with-community
schema: "2021-01-08"
---


As Steampipe's new community lead I've been looking for ways to keep track of the blistering pace of activity in this young project. There are a *lot* of GitHub repos, let's focus particularly on [plugins](https://hub.steampipe.io/plugins) and [mods](https://hub.steampipe.io/mods). A [GitHub search](https://github.com/orgs/turbot/repositories?q=steampipe&type=public&language=&sort=) finds 75 results, including everything I'm looking for, but doesn't break them down by type. 

I can use the [github_my_repository table](https://hub.steampipe.io/plugins/turbot/github/tables/github_my_repository) in the [GitHub plugin](https://hub.steampipe.io/plugins/turbot/github) to do that breakdown.

<Terminal mode="light">
  <TerminalCommand>
    {`
select 
  count(*), 
  'plugins' as category
from 
  github_my_repository 
where 
  full_name ~ 'turbot/steampipe-plugin'
union 
select 
  count(*), 
  'mods' as category
from github_my_repository
where full_name ~ 'turbot/steampipe-mod';
`}
  </TerminalCommand>
  <TerminalResult>
{`
 count |  category
-------+---------
    24 | mods    
    51 | plugins 
`}
  </TerminalResult>
</Terminal>

<br />

Good start!

## How many open and closed issues?

Now let's look at open and closed issues across these categories.

<Terminal mode="light">
  <TerminalCommand>
    {`
with repo_names as (
  select 
    full_name
  from 
    github_my_repository
  where full_name ~ 'turbot/steampipe-(plugin|mod)'
),
issues as (
  select 
    *
  from repo_names r
  join github_issue gi on r.full_name = gi.repository_full_name
),
open_issues as (
  select 
    i.full_name,
    count(*) as open_issues
  from issues i
  where i.closed_at is null
  group by i.full_name
),
closed_issues as (
  select 
    i.full_name,
    count(*) as closed_issues
  from issues i
  where i.closed_at is not null
  group by i.full_name
)
select 
  case when o.full_name is not null
    then o.full_name
    else c.full_name
  end as full_name,
  o.open_issues,
  c.closed_issues
from 
  open_issues o 
full join closed_issues c 
  on o.full_name = c.full_name
order by full_name;
`}
  </TerminalCommand>
  <TerminalResult>
{`
                 full_name                 | open_issues | closed_issues 
-------------------------------------------+-------------+---------------
 turbot/steampipe-mod-alicloud-compliance  |           1 |            14 
 turbot/steampipe-mod-alicloud-thrifty     |           2 |             3 
 turbot/steampipe-mod-aws-compliance       |           5 |           129 
 turbot/steampipe-mod-aws-tags             |             |             1 
 turbot/steampipe-mod-aws-thrifty          |          10 |            16 
 turbot/steampipe-mod-aws-top10            |           1 |               
 turbot/steampipe-mod-azure-compliance     |           3 |            34 
 turbot/steampipe-mod-azure-tags           |             |             1 
 turbot/steampipe-mod-azure-thrifty        |           3 |             4 
 turbot/steampipe-mod-digitalocean-thrifty |           3 |             3 
 turbot/steampipe-mod-gcp-compliance       |           1 |            23 
 turbot/steampipe-mod-gcp-labels           |             |             2 
 turbot/steampipe-mod-gcp-thrifty          |             |             5 
 turbot/steampipe-mod-github-sherlock      |             |             6 
 turbot/steampipe-mod-oci-compliance       |           3 |            13 
 turbot/steampipe-mod-oci-tags             |           1 |               
 turbot/steampipe-mod-oci-thrifty          |           3 |             5 
 turbot/steampipe-mod-zoom-compliance      |             |             1 
 turbot/steampipe-plugin-alicloud          |          21 |           112 
 turbot/steampipe-plugin-aws               |          12 |           349 
 turbot/steampipe-plugin-azure             |          34 |           170 
 turbot/steampipe-plugin-azuread           |           7 |            12 
 turbot/steampipe-plugin-bitbucket         |           9 |            20 
`}
  </TerminalResult>
</Terminal>

<br />


## Reporting stale issues

We can use a control in the [github-steampipe-mod-sherlock](https://hub.steampipe.io/mods/turbot/github_sherlock) mod to run a quick check that flags issues older than 30 days.

<Terminal mode="light">
  <TerminalCommand>
    {`
steampipe check control.issue_older_30_days`}
  </TerminalCommand>
</Terminal>

<br />

![](/images/blog/2021-10-04-github-plugin/stale-issues.jpg)


Or we can use SQL to drill down for more insight. For example, what's the average age of open issues by repo?

<Terminal mode="light">
  <TerminalCommand>
    {`
with repo_names as (
  select 
    full_name
  from 
    github_my_repository
  where full_name ~ 'turbot/steampipe-(plugin|mod)'
)
select
  gi.repository_full_name, 
  count(*),
  avg(extract(day from current_timestamp - gi.created_at))::int as avg_issue_days_open
from 
  github_issue gi
join
  repo_names r
on 
  gi.repository_full_name = r.full_name
where 
  gi.closed_at is null
group by 
  gi.repository_full_name
order by avg_issue_days_open desc;
`}
  </TerminalCommand>
  <TerminalResult>
{`
           repository_full_name            | count | avg_issue_days_open 
-------------------------------------------+-------+---------------------
 turbot/steampipe-plugin-cloudflare        |     2 |                 200 
 turbot/steampipe-plugin-equinix           |     1 |                 196 
 turbot/steampipe-plugin-chaos             |     1 |                 181 
 ... snip ...
 turbot/steampipe-plugin-turbot            |     2 |                  14
 turbot/steampipe-mod-oci-tags             |     1 |                   7
 turbot/steampipe-plugin-heroku            |     1 |                   5
`}
  </TerminalResult>
</Terminal>

<br />

## Visualizing release cadence

How often are Steampipe plugins and mods updated? The tables we can use to answer this question include [github_release](https://hub.steampipe.io/plugins/turbot/github/tables/github_release), [github_tag](https://hub.steampipe.io/plugins/turbot/github/tables/github_tag), and [github_commit](https://hub.steampipe.io/plugins/turbot/github/tables/github_commit). We don't yet cut releases for most plugins and mods, but we can look at tags.

<Terminal mode="light">
  <TerminalCommand>
    {`
with repo_names as (
  select 
    full_name
  from 
    github_my_repository
  where full_name ~ 'turbot/steampipe-(plugin|mod)'
),
issues as (
  select 
    *
  from repo_names r
  join github_issue gi on r.full_name = gi.repository_full_name
),
open_issues as (
  select 
    i.full_name,
    count(*) as open_issues
  from issues i
  where i.closed_at is null
  group by i.full_name
),
closed_issues as (
  select 
    i.full_name,
    count(*) as closed_issues
  from issues i
  where i.closed_at is not null
  group by i.full_name
)
select 
  case when o.full_name is not null
    then o.full_name
    else c.full_name
  end as full_name,
  o.open_issues,
  c.closed_issues
from 
  open_issues o 
full join closed_issues c 
  on o.full_name = c.full_name
order by full_name;
`}
  </TerminalCommand>
  <TerminalResult>
{`
                 full_name                 | open_issues | closed_issues 
-------------------------------------------+-------------+---------------
 turbot/steampipe-mod-alicloud-compliance  |           1 |            14 
 turbot/steampipe-mod-alicloud-thrifty     |           2 |             3 
 turbot/steampipe-mod-aws-compliance       |           5 |           129 
 turbot/steampipe-mod-aws-tags             |             |             1 
 turbot/steampipe-mod-aws-thrifty          |          10 |            16 
 turbot/steampipe-mod-aws-top10            |           1 |               
 turbot/steampipe-mod-azure-compliance     |           3 |            34 
 turbot/steampipe-mod-azure-tags           |             |             1 
 turbot/steampipe-mod-azure-thrifty        |           3 |             4 
 turbot/steampipe-mod-digitalocean-thrifty |           3 |             3 
 turbot/steampipe-mod-gcp-compliance       |           1 |            23 
 turbot/steampipe-mod-gcp-labels           |             |             2 
 turbot/steampipe-mod-gcp-thrifty          |             |             5 
 turbot/steampipe-mod-github-sherlock      |             |             6 
 turbot/steampipe-mod-oci-compliance       |           3 |            13 
 turbot/steampipe-mod-oci-tags             |           1 |               
 turbot/steampipe-mod-oci-thrifty          |           3 |             5 
 turbot/steampipe-mod-zoom-compliance      |             |             1 
 turbot/steampipe-plugin-alicloud          |          21 |           112 
 turbot/steampipe-plugin-aws               |          12 |           349 
 turbot/steampipe-plugin-azure             |          34 |           170 
 turbot/steampipe-plugin-azuread           |           7 |            12 
 turbot/steampipe-plugin-bitbucket         |           9 |            20 
`}
  </TerminalResult>
</Terminal>

<br />

There are no dates available via the API wrapped by `github_tag` but we can join with `github_commit` to find them.

<Terminal mode="light">
  <TerminalCommand>
    {`
with tags as (
  select
    repository_full_name,
    commit_sha,
    name
  from 
    github_tag
  where
    repository_full_name = 'turbot/steampipe-plugin-github'
  order by 
    commit_sha
  ),
commits as (
  select
    repository_full_name,
    sha,
    committer_date
from 
  github_commit
where
  repository_full_name = 'turbot/steampipe-plugin-github'
order by
  sha
)
select 
  t.repository_full_name,
  t.commit_sha,
  t.name,
  c.committer_date
from tags t
join commits c
on c.sha = t.commit_sha
order by t.name desc, c.committer_date desc;
`}
  </TerminalCommand>
  <TerminalResult>
{`
      repository_full_name      |                commit_sha                |  name  |   committer_date    
--------------------------------+------------------------------------------+--------+---------------------
 turbot/steampipe-plugin-github | 4514cf7450dc545c4051aa94f801016f9b2098a7 | v0.6.1 | 2021-09-23 12:31:07 
 turbot/steampipe-plugin-github | 49ce3d89293e2f28997b96f0dfb1879c1382d3bd | v0.6.0 | 2021-09-09 07:47:37 
 turbot/steampipe-plugin-github | 8771752e9b13fa8d59ba73433a756a8707de8a1d | v0.5.1 | 2021-06-06 01:24:22 
 turbot/steampipe-plugin-github | 5dc64b75886936c793d8dd6dcb5182ec3ee612cd | v0.5.0 | 2021-05-27 18:01:57 
 turbot/steampipe-plugin-github | faf4b4fcafc3bcbf6f92de8f2f751c77b7acd80d | v0.4.0 | 2021-05-15 18:57:00 
 turbot/steampipe-plugin-github | bc4a26a64b23972e1a4891f31cf6d6bef90a1f66 | v0.3.0 | 2021-04-30 21:18:25 
 turbot/steampipe-plugin-github | 4d05c6efdd391cb7f02c00ac89fd5fcd175c49c1 | v0.2.0 | 2021-03-18 20:08:54 
 turbot/steampipe-plugin-github | 43173a8434a9ddb8c0c6de375c2a70757adbd4cd | v0.1.1 | 2021-02-25 16:24:43 
 turbot/steampipe-plugin-github | c542c3d53e33a2676a1df75f22911b54526989c0 | v0.1.0 | 2021-02-18 19:11:30 
 turbot/steampipe-plugin-github | bd54547306edf15dc0ea73d1b7b090e2467da765 | v0.0.5 | 2021-01-28 18:49:51 
`}
  </TerminalResult>
</Terminal>

<br />

Let's have some fun with this data. How about visualizing it on a timeline? There are lots of charting libraries that can do timelines, we'll arbitrarily pick [the ApexCharts implementation](https://apexcharts.com/javascript-chart-demos/timeline-charts/basic/). It uses a structure like this:

<Terminal mode="light">
  <TerminalResult>
{`
data: [
  {
    x: 'Code', 
    y: [ new Date('2019-03-02').getTime(), new Date('2019-03-04').getTime() ]
 },
  {
    x: 'Test',
    y: [ new Date('2019-03-04').getTime(), new Date('2019-03-08').getTime() ]
  }
]
`}
  </TerminalResult>
</Terminal>

<br />


You might not think of Postgres as the tool of choice for wrangling data into this format, but watch. First, capture the above query as a view.

<Terminal mode="light">
  <TerminalCommand>
    {`
create view timeline_data as (
  with tags as (
    select
      repository_full_name,
      commit_sha,
      name
    from 
      github_tag
    where
      repository_full_name = 'turbot/steampipe-plugin-github'
    order by 
      commit_sha
    ),
  commits as (
    select
      repository_full_name,
      sha,
      committer_date
  from 
    github_commit
  where
    repository_full_name = 'turbot/steampipe-plugin-github'
  order by
    sha
  )
  select 
    t.repository_full_name,
    t.commit_sha,
    t.name,
    c.committer_date
  from tags t
  join commits c
  on c.sha = t.commit_sha
  order by t.name desc, c.committer_date desc
);`}
  </TerminalCommand>
</Terminal>

<br />


To produce start and end dates:

<Terminal mode="light">
  <TerminalCommand>
    {`
select 
  name, 
  to_char(committer_date, 'YYYY-MM-DD') as start, 
  lag(to_char(committer_date,'YYYY-MM-DD')) over () as end
from timeline_data;
`}
  </TerminalCommand>
  <TerminalResult>
{`
  name  |   start    |    end      
--------+------------+------------ 
 v0.6.1 | 2021-09-23 |             
 v0.6.0 | 2021-09-09 | 2021-09-23  
 v0.5.1 | 2021-06-06 | 2021-09-09  
 v0.5.0 | 2021-05-27 | 2021-06-06  
 v0.4.0 | 2021-05-15 | 2021-05-27  
 v0.3.0 | 2021-04-30 | 2021-05-15  
 v0.2.0 | 2021-03-18 | 2021-04-30  
 v0.1.1 | 2021-02-25 | 2021-03-18  
 v0.1.0 | 2021-02-18 | 2021-02-25  
 v0.0.5 | 2021-01-28 | 2021-02-18  
 v0.0.4 | 2021-01-22 | 2021-01-28  
 v0.0.2 | 2021-01-21 | 2021-01-22  
 v0.0.1 | 2021-01-21 | 2021-01-21
`}
  </TerminalResult>
</Terminal>

<br />


To transform that data into the JSON objects used by the timeline:

<Terminal mode="light">
  <TerminalCommand>
    {`
with raw_data as (
  select 
    name, 
    to_char(committer_date, 'YYYY-MM-DD') as start, 
    lag(to_char(committer_date,'YYYY-MM-DD')) over () as end
  from timeline_data
),
raw_json as (
  select 
    json_build_object(
      'x', rd.name,
      'y', array[rd.start, rd.end]
    ) as object
  from raw_data rd
),
cooked_json as (
  select concat(
    '{ '                                ,
    'x: "'                              ,
    (object->>'x')                      , 
    '", '                               , 
    'y: '                               ,
    '[new Date("'                       ,
    ( replace(object->'y'->>0,'"',''))  ,
    '").getTime()'                      ,
    ','                                 ,
    'new Date("'                        ,
    ( replace(object->'y'->>1,'"',''))  ,
    '").getTime()'                      ,
    ']'                                 ,
    '}, '                                
  ) as timeline_object
  from raw_json
)
select 
  replace(timeline_object, '""', 'Date.now()') as timeline_data
from cooked_json;
`}
  </TerminalCommand>
  <TerminalResult>
{`
                                      timeline_data                                       
------------------------------------------------------------------------------------------
 { x: "v0.6.1", y: [new Date("2021-09-23").getTime(),new Date(Date.now()).getTime()]},    
 { x: "v0.6.0", y: [new Date("2021-09-09").getTime(),new Date("2021-09-23").getTime()]},  
 { x: "v0.5.1", y: [new Date("2021-06-06").getTime(),new Date("2021-09-09").getTime()]},  
 { x: "v0.5.0", y: [new Date("2021-05-27").getTime(),new Date("2021-06-06").getTime()]},  
 { x: "v0.4.0", y: [new Date("2021-05-15").getTime(),new Date("2021-05-27").getTime()]},  
 { x: "v0.3.0", y: [new Date("2021-04-30").getTime(),new Date("2021-05-15").getTime()]},  
 { x: "v0.2.0", y: [new Date("2021-03-18").getTime(),new Date("2021-04-30").getTime()]},  
 { x: "v0.1.1", y: [new Date("2021-02-25").getTime(),new Date("2021-03-18").getTime()]},  
 { x: "v0.1.0", y: [new Date("2021-02-18").getTime(),new Date("2021-02-25").getTime()]},  
 { x: "v0.0.5", y: [new Date("2021-01-28").getTime(),new Date("2021-02-18").getTime()]},  
 { x: "v0.0.4", y: [new Date("2021-01-22").getTime(),new Date("2021-01-28").getTime()]},  
 { x: "v0.0.2", y: [new Date("2021-01-21").getTime(),new Date("2021-01-22").getTime()]},  
 { x: "v0.0.1", y: [new Date("2021-01-21").getTime(),new Date("2021-01-21").getTime()]},
`}
  </TerminalResult>
</Terminal>

<br />

Paste that data into a copy of the ApexCharts [timeline example](https://jsfiddle.net/nr94tcL0), and voilà!

![](/images/blog/2021-10-04-github-plugin/release-timeline2.jpg)

If you'd rather do that bit of data wrangling another way, Postgres can oblige. For example, the [pl/python extension](https://www.postgresql.org/docs/current/plpython.html) can work in Steampipe, and you can do lots with it. The main advantage here would be easier string-building. If there's interest in pl/python I can explore it in a future post.

## Finding external contributors

Open source projects are often sponsored by companies whose employees are the main contributors. When others contribute issues or commits it's worth celebrating, but how to keep track of those people? The GitHub plugin has the all ingredients needed to do that. In [github_my_organization](https://hub.steampipe.io/plugins/turbot/github/tables/github_my_organization) we can find user logins for all the GitHub organizations we belong to; in [github_commit](https://hub.steampipe.io/plugins/turbot/github/tables/github_commit) we can find commits to a repo; in [github_issue](https://hub.steampipe.io/plugins/turbot/github/tables/github_issue) we can find issues filed for a repo. 

To find external contributors, I started with a list of GitHub user logins for the `turbot` organization where the Steampipe plugins and mods live. Since some contributions track to users in the related `turbotio` org, the query to find all internal contributors looks like this.

<Terminal mode="light">
  <TerminalCommand>
    {`
select
  g.name,
  g.login,
  jsonb_array_elements_text(g.member_logins) as member_login
from
  github_my_organization g
where
  g.login = any( array['turbot', 'turbotio'] );`}
  </TerminalCommand>
  <TerminalResult>
{`
        name        |  login   |   member_login     
--------------------+----------+------------------- 
 Turbot             | turbot   | bigdatasourav      
 Turbot             | turbot   | binaek             
 Turbot             | turbot   | cbruno10           
 Turbot             | turbot   | dboeke 
`}
  </TerminalResult>
</Terminal>

<br />

To find committers in a repo:

<Terminal mode="light">
  <TerminalResult>
{`
select distinct
  author_login
from
  github_commit
where
  repository_full_name = 'turbot/steampipe-plugin-aws';
`}
  </TerminalResult>
</Terminal>

<br />

To find external committers, subtract one list from the other. 

<Terminal mode="light">
  <TerminalCommand>
    {`
with committers as (
  select distinct
    g.repository_full_name,
    g.author_login
  from
    github_commit g
  where
    g.repository_full_name = 'turbot/steampipe-plugin-aws'
),
users_in_excluded_orgs as (
  select
    g.name,
    g.login,
    jsonb_array_elements_text(g.member_logins) as member_login
  from
    github_my_organization g
  where
    g.login = any(array['turbotio','turbot'])
)
select
  c.repository_full_name,
  c.author_login
from 
  committers c
where not exists (
  select 
    c.author_login
  from 
    users_in_excluded_orgs u
  where
    c.author_login = u.member_login
  )
order by lower(c.author_login);
`}
  </TerminalCommand>
  <TerminalResult>
{`
          full_name          |  author_login      
-----------------------------+-----------------   
 turbot/steampipe-plugin-aws | davidhammturner    
 turbot/steampipe-plugin-aws | fitchtravis        
 turbot/steampipe-plugin-aws | gazoakley          
 turbot/steampipe-plugin-aws | jackdelab          
 turbot/steampipe-plugin-aws | jzendle            
 turbot/steampipe-plugin-aws | kpapagno           
 turbot/steampipe-plugin-aws | RyanJarv           
 turbot/steampipe-plugin-aws | sankeyraut         
 turbot/steampipe-plugin-aws | Tucker-Eric
`}
  </TerminalResult>
</Terminal>

<br />

The actual list was longer because it included some GitHub logins for people who were, but are no longer, members of one of the organizations in play. If there's an automated way to cull that list please let me know. Meanwhile it's not too hard to eyeball the list and delete former employees.

To summarize activity for each external contributor, we'll now combine all the ingredients we've seen so far. 

<Terminal mode="light">
  <TerminalCommand>
    {`
with committers as (
  select distinct
    g.repository_full_name,
    g.author_login
  from
    github_commit g
  where
    g.repository_full_name = 'turbot/steampipe-plugin-aws'
),
users_in_excluded_orgs as (
  select
    g.name,
    g.login,
    jsonb_array_elements_text(g.member_logins) as member_login
  from
    github_my_organization g
  where
    g.login = any(array['turbotio','turbot'])
),
external_contributors as (
  select
    c.repository_full_name,
    c.author_login
  from 
    committers c
  where not exists (
    select 
      c.author_login
    from 
      users_in_excluded_orgs u
    where
      c.author_login = u.member_login
  )
),
commits as (
  select
    g.repository_full_name,
    g.author_login,
    count(*) as commits
  from 
    github_commit g
  join
    external_contributors  e
  on 
    g.repository_full_name = e.repository_full_name
    and g.author_login = e.author_login
  group by 
    g.repository_full_name, g.author_login
),
issues as (
  select
    g.repository_full_name,
    g.author_login,
    count(*) as issues
  from 
    github_issue g
  join 
    external_contributors  e
  on 
    g.repository_full_name = e.repository_full_name
    and g.author_login = e.author_login
  group by 
    g.repository_full_name, g.author_login
)
select
  c.repository_full_name,
  c.author_login,
  c.commits,
  i.issues
from
  commits c
left join
  issues i
on 
  c.repository_full_name = i.repository_full_name
  and c.author_login = i.author_login
order by
  lower(c.author_login);
`}
  </TerminalCommand>
  <TerminalResult>
{`
    repository_full_name     |  author_login   | commits | issues 
-----------------------------+-----------------+---------+--------
 turbot/steampipe-plugin-aws | davidhammturner |       1 |        
 turbot/steampipe-plugin-aws | fitchtravis     |       1 |      1 
 turbot/steampipe-plugin-aws | gazoakley       |       3 |        
 turbot/steampipe-plugin-aws | jackdelab       |       1 |      3 
 turbot/steampipe-plugin-aws | jzendle         |       1 |      1 
 turbot/steampipe-plugin-aws | kpapagno        |       1 |      1 
 turbot/steampipe-plugin-aws | RyanJarv        |       1 |      1 
 turbot/steampipe-plugin-aws | sankeyraut      |       1 |      4 
 turbot/steampipe-plugin-aws | Tucker-Eric     |       1 |
`}
  </TerminalResult>
</Terminal>

<br />

It's nice to see this data at a glance! Next, of course, we'll want to project the view across all the repos to which external contributors have filed issues or made commits. That'll make it easier to find and thank *davidhammturner*, *fitchtravis*, *gazoakley*, and everyone else who's contributed to Steampipe. When repeat contributors show up we'll immediately know their prior context, and we'll be able to extend a special welcome to new folks. 

The code behind this concise view is, admittedly, not so easy to see at a glance. In Postgres there are good ways to  improve the readability of a long query. We've seen an example of using a view to encapsulate a live query. There are also materialized views that cache slow queries to disk for immediate recall. And you can write functions to augment the chunking power that CTEs deliver. If you write a lot of SQL for use in Steampipe, you'll be able to achieve a high standard of readibility and modularity. But that's a topic for another post.

## The bottom line

You can use Steampipe's GitHub plugin to build compelling views of activity in your open source project, and you can use that information to showcase and connect with your contributors. Try these recipes for yourself, and let us know what you discover!