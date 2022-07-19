---
id: vscode-analysis
title: "A portrait of VSCode's external contributors"
category: Featured Plugin
description: "We build a data analysis pipeline to explore large GitHub repos. The same method will work with data from any Steampipe plugin."
author:
  name: Jon Udell
publishedAt: "2021-10-26T08:00:00"
durationMins: 10
image: /images/blog/2021-10-22-vscode-analysis/vscode-external-issues-authors2.jpg
slug: vscode-analysis
schema: "2021-01-08"
---

In [Using Steampipe's GitHub plugin to connect with your open source community](https://steampipe.io/blog/use-github-plugin-to-connect-with-community) we mined the tables provided by that plugin to explore our own organization's repos. That article shows how to find stale issues, visualize release cadence, and identify external contributors.

As a follow-on to that article we decided to ask and answer a question we've often wondered about: Who are the external contributors to `microsoft/vscode`, and what are their patterns of contributions? This is an enormous repo: 1500 contributors, 88,500 commits, and 121,000 issues. Steampipe can handle lots of data, but joins involving this many contributors, commits, and issues blew out the memory on a EC2 t2.medium, and then a t2.large. So we switched to another strategy.

## A query pipeline

The solution was to cache the big tables: commits (88K) and issues (121K). Then we could then derive a series of tables based on those, plus other tables joined on the fly. It should take you about an hour to run the full pipeline. While it's running, you can `select * from vscode_log` to check progress. Here are all the tables you'll end up with.

```
2021-10-18 23:07:03.061311 | vscode_org_members
2021-10-18 23:07:17.702559 | vscode_commits
2021-10-18 23:13:07.961552 | vscode_committers
2021-10-18 23:13:08.11581  | vscode_committer_details
2021-10-18 23:17:35.505082 | vscode_internal_committers
2021-10-18 23:17:35.563092 | vscode_internal_commits
2021-10-18 23:17:36.267878 | vscode_internal_commit_counts
2021-10-18 23:17:36.541539 | vscode_external_committers
2021-10-18 23:17:36.579981 | vscode_external_commits
2021-10-18 23:17:36.757549 | vscode_external_commit_counts
2021-10-18 23:17:36.766478 | vscode_issues
2021-10-19 00:02:38.071931 | vscode_issue_filers
2021-10-19 00:02:39.090606 | vscode_issue_filer_details
2021-10-19 00:02:39.094259 | vscode_internal_issue_filers
2021-10-19 00:02:39.220729 | vscode_internal_issues
2021-10-19 00:02:39.701516 | vscode_internal_issue_counts
2021-10-19 00:02:39.735744 | vscode_external_issue_filers
2021-10-19 00:02:39.893828 | vscode_external_issues
2021-10-19 00:02:40.835652 | vscode_external_issue_counts
2021-10-19 00:02:41.169555 | vscode_external_contributors
2021-10-19 00:02:41.349196 | vscode_external_commit_timelines
```

Each phase of the pipeline produces a table, which helps make things robust to failure. While developing this pipeline, for example, we triggered the hourly API rate limit several times, but were able to pick up where we left off. None of this is specific to Steampipe, it's just a good way to do analytics based on API-sourced data.

To run the pipeline for yourself, try the SQL script you can see in the [Show Me the SQL](#show-me-the-sql) appendix at the end.

## Topline stats for committers

Of 1502 committers, we classifed 1348 as external (leaving 153 internal) based on these rules:

- Their logins don't appear in the members field of the `github_organization` whose name is **microsoft**.
- Their company and email columns, from `github_user`, don't match **microsoft**.
- Their logins match a handful of enumerated exceptions.

## Topline stats for issue authors

Of 52,028 issue authors, we classifed 51,9123 (leaving 382 as internal) based on similar rules. It was impractical to fetch the company and email info for all 52,028, that would take 10 hours at 5K API calls/hr. So we used committer data as a proxy for issue data when excluding Microsoft-affiliated issue authors. That's less precise, but the primary filter -- membership in Microsoft's GitHub organization -- is pretty good.

There were 116,241 closed issues, and 5400 open issues. 

The averge length of time between opening and closing issues was about the same for issues filed by internal authors (57 days) and external authors (54 days). 

Histograms for the two categories confirm that while the absolute numbers differ, the pattern is again very similar.

![](/images/blog/2021-10-22-vscode-analysis/vscode-internal-issue-histogram.jpg)

![](/images/blog/2021-10-22-vscode-analysis/vscode-external-issue-histogram.jpg)

## Commits vs issues for external contributors

This chart compares the number of commits and issues for each external contributor. There are some intriguing outliers: check out [DanTup](https://twitter.com/DanTup) over there on the far right of the x axis, with 1 commit and 466 issues!

![](/images/blog/2021-10-22-vscode-analysis/vscode-commits-vs-issues.jpg)

## Top 10 external committers and issue authors

These are the top 10 external committers.

| author_login | count | twitter |
| --- | --- | --- |
 |<a href="https://github.com/microsoft/vscode/commits?author=michelkaporin">michelkaporin</a>|311|michel_the_man|      
 |<a href="https://github.com/microsoft/vscode/commits?author=jeanp413">jeanp413</a>|190||                              
 |<a href="https://github.com/microsoft/vscode/commits?author=Lixire">Lixire</a>|111||                                  
 |<a href="https://github.com/microsoft/vscode/commits?author=bgashler1">bgashler1</a>|94||                             
 |<a href="https://github.com/microsoft/vscode/commits?author=usernamehw">usernamehw</a>|87||                           
 |<a href="https://github.com/microsoft/vscode/commits?author=cleidigh">cleidigh</a>|86||                               
 |<a href="https://github.com/microsoft/vscode/commits?author=gjsjohnmurray">gjsjohnmurray</a>|68||                     
 |<a href="https://github.com/microsoft/vscode/commits?author=Krzysztof-Cieslak">Krzysztof-Cieslak</a>|49||             
 |<a href="https://github.com/microsoft/vscode/commits?author=Kingwl">Kingwl</a>|45|WenluWang|                          
 |<a href="https://github.com/microsoft/vscode/commits?author=dependabot[bot]">dependabot[bot]</a>|41||                 
        
These are the top 10 external issue authors.

| author_login | count | twitter |
| --- | --- | --- |
 |<a href="https://github.com/microsoft/vscode/issues?q=author:DanTup">DanTup</a>|466|DanTup|                           
 |<a href="https://github.com/microsoft/vscode/issues?q=author:usernamehw">usernamehw</a>|393||                         
 |<a href="https://github.com/microsoft/vscode/issues?q=author:AccessibilityTestingTeam-TCS">AccessibilityTestingTeam-TCS</a>|359|
 |<a href="https://github.com/microsoft/vscode/issues?q=author:RMacfarlane">RMacfarlane</a>|312||                       
 |<a href="https://github.com/microsoft/vscode/issues?q=author:gjsjohnmurray">gjsjohnmurray</a>|173||                   
 |<a href="https://github.com/microsoft/vscode/issues?q=author:vsccarl">vsccarl</a>|163||                               
 |<a href="https://github.com/microsoft/vscode/issues?q=author:smlombardi">smlombardi</a>|145||                         
 |<a href="https://github.com/microsoft/vscode/issues?q=author:mousetraps">mousetraps</a>|130|mousetraps|               
 |<a href="https://github.com/microsoft/vscode/issues?q=author:v-pavanp">v-pavanp</a>|130||                             
 |<a href="https://github.com/microsoft/vscode/issues?q=author:fabiospampinato">fabiospampinato</a>|129|fabiospampinato|


## Top 10 internal committers and issue authors

For comparison, these are the top 10 internal committers.

| author_login | count | twitter |
| --- | --- | --- |
 |<a href="https://github.com/microsoft/vscode/commits?author=bpasero">bpasero</a>|10364|BenjaminPasero|
 |<a href="https://github.com/microsoft/vscode/commits?author=jrieken">jrieken</a>|8834|johannesrieken|
 |<a href="https://github.com/microsoft/vscode/commits?author=joaomoreno">joaomoreno</a>|8142||
 |<a href="https://github.com/microsoft/vscode/commits?author=mjbvz">mjbvz</a>|6398|mattbierner|
 |<a href="https://github.com/microsoft/vscode/commits?author=alexdima">alexdima</a>|6174||
 |<a href="https://github.com/microsoft/vscode/commits?author=sandy081">sandy081</a>|5911||
 |<a href="https://github.com/microsoft/vscode/commits?author=isidorn">isidorn</a>|5865||
 |<a href="https://github.com/microsoft/vscode/commits?author=Tyriar">Tyriar</a>|5274|Tyriar|
 |<a href="https://github.com/microsoft/vscode/commits?author=aeschli">aeschli</a>|3848||
 |<a href="https://github.com/microsoft/vscode/commits?author=rebornix">rebornix</a>|3573|

These are the top 10 internal issue authors.

| author_login | count | twitter |
| --- | --- | --- |
|<a href="https://github.com/microsoft/vscode/issues?q=author:bpasero">bpasero</a>|3926|BenjaminPasero|   
|<a href="https://github.com/microsoft/vscode/issues?q=author:tyriar">tyriar</a>|2582||                   
|<a href="https://github.com/microsoft/vscode/issues?q=author:jrieken">jrieken</a>|2113|johannesrieken|   
|<a href="https://github.com/microsoft/vscode/issues?q=author:roblourens">roblourens</a>|1729||           
|<a href="https://github.com/microsoft/vscode/issues?q=author:joaomoreno">joaomoreno</a>|1718||           
|<a href="https://github.com/microsoft/vscode/issues?q=author:sandy081">sandy081</a>|1187||               
|<a href="https://github.com/microsoft/vscode/issues?q=author:alexdima">alexdima</a>|1043||               
|<a href="https://github.com/microsoft/vscode/issues?q=author:weinand">weinand</a>|1036||                 
|<a href="https://github.com/microsoft/vscode/issues?q=author:dbaeumer">dbaeumer</a>|846||                
|<a href="https://github.com/microsoft/vscode/issues?q=author:rebornix">rebornix</a>|722||

## Activity timespans for external committers

This chart shows the first and last commit dates for each external committer.

![](/images/blog/2021-10-22-vscode-analysis/vscode-timelines.jpg)

These are the external committers with the longest spans.

```
author_login    |     days
----------------|---------
yume-chan       |     1517
Huachao         |     1385
forivall        |     1367
Ikuyadeu        |     1353
akosyakov       |     1320
jeanp413        |     1303
JoshuaKGoldberg |     1135
usernamehw      |     1118
71              |     1102
 ```
      
## Internal and external issue tags

These are the top 10 tags for issues filed by internal authors.

```
tag                 |  count
--------------------|---------
verified            |  9204
bug                 |  9167
feature-request     |  3342
insiders-released   |  2459
debug               |  1951
*duplicate          |  1782
debt                |  1594
terminal            |  1524
testplan-item       |  1158
verification-needed |  1105
```
        
These are the top 10 tags for issues filed by external authors.

```
tag                  |  count
---------------------|---------
needs more info      | 18448
*duplicate           | 15250
feature-request      | 11530
bug                  | 10144
verified             |  8533
*caused-by-extension |  5493
terminal             |  4034
*question            |  3887
debug                |  3863
upstream             |  3336        
```
        
## Beyond the GitHub API

What you've seen here isn't specific to the VSCode repo, it'll work for any large GitHub repo. If you try the pipeline shown here -- perhaps modifying it to answer some of your own questions, or pointing it at another repo -- [let us know](https://join.slack.com/t/steampipe/shared_invite/zt-oij778tv-lYyRTWOTMQYBVAbtPSWs3g) how it goes.

We think this pipeline will interest people who care deeply about, and study, open source community dynamics. What if your game is something entirely different? Well, if it revolves around compliance with cloud security recommendations, we've got you covered. That's a sweet spot for Steampipe that we'll explore in future posts.

More broadly, the methods shown here can apply across the whole set of Steampipe plugins. If you find yourself reaching for APIs to answer questions in any of those domains, give Steampipe a try and again [let us know](https://join.slack.com/t/steampipe/shared_invite/zt-oij778tv-lYyRTWOTMQYBVAbtPSWs3g) what you find.

## Show me the SQL

Instructions:
  
  1. Install Steampipe: https://steampipe.io/downloads
  2. Install the GitHub plugin: `steampipe plugin install github`
  3. Configure the GitHub plugin with your personal access token: https://hub.steampipe.io/plugins/turbot/github#credentials
  4. Install `psql` for Postgres 12: https://www.compose.com/articles/postgresql-tips-installing-the-postgresql-client/
  5. Save this script as `vscode.sql`
  6. `steampipe service start`
  7. `psql -h localhost -p 9193 -d steampipe -U steampipe < vscode.sql`

You can also find this script in the  [steampipe-samples](https://github.com/turbot/steampipe-samples) repo, along with a tool that can generate versions of the script to analyze other repos in the same way.

```
drop table if exists vscode_log;
create table vscode_log(time timestamp, event text);

drop table if exists vscode_org_members;
insert into vscode_log(time, event) values (now(), 'vscode_org_members');
create table vscode_org_members as (
  select
    g.name,
    g.login,
    jsonb_array_elements_text(g.member_logins) as member_login
  from
    github_organization g
  where
    g.login = 'microsoft'
);

drop table if exists vscode_commits;
insert into vscode_log(time, event) values (now(), 'vscode_commits');
create table vscode_commits as (
  select
    g.repository_full_name,
    g.author_login,
    g.author_date,
    g.commit->'author'->>'email' as author_email,
    g.committer_login,
    g.committer_date
  from
    github_commit g
  where
    g.repository_full_name = 'microsoft/vscode'
);

drop table if exists vscode_committers;
insert into vscode_log(time, event) values (now(), 'vscode_committers');
create table vscode_committers as (
  with unordered as (
    select distinct
      c.repository_full_name,
      c.author_login
    from
      vscode_commits c
  )
  select
    *
  from 
    unordered
  order by
    lower(author_login)
);

drop table if exists vscode_committer_details;
insert into vscode_log(time, event) values (now(), 'vscode_committer_details');
create table vscode_committer_details as (
  select
    g.login,
    g.name,
    g.company,
    g.email,
    g.twitter_username
  from
    github_user g
  join
    vscode_committers c 
  on 
    c.author_login = g.login
);

drop table if exists vscode_internal_committers;
insert into vscode_log(time, event) values (now(), 'vscode_internal_committers');
create table vscode_internal_committers as (
  with by_membership as (
    select 
      *
    from    
      vscode_committers c 
    join
      vscode_org_members o
    on
      c.author_login = o.member_login
    order by
      c.author_login
  ),
  by_vscode_committer_details as (
    select 
      *
    from
      vscode_committer_details cd
    where
      cd.company ~* 'microsoft' or cd.email ~* 'microsoft'
    order by
      cd.login
  ),
  combined as (
    select
      m.author_login as m_login,
      cd.login as c_login
    from
      by_membership m
    full join 
      by_vscode_committer_details cd
    on
      m.author_login = cd.login
  ),
  merged as (
    select
      case
        when m_login is null then c_login
        else m_login 
      end as author_login
    from 
      combined
  )
  select
    *
  from
    merged
  order by
    lower(author_login)
);

drop table if exists vscode_internal_commits;
insert into vscode_log(time, event) values (now(), 'vscode_internal_commits');
create table vscode_internal_commits as (
  select 
    *
  from    
    vscode_commits c
  join
    vscode_internal_committers i
  using
    (author_login)
);

drop table if exists vscode_internal_commit_counts;
insert into vscode_log(time, event) values (now(), 'vscode_internal_commit_counts');
create table vscode_internal_commit_counts as (
  select 
    i.repository_full_name,
    i.author_login,
    count(*)
  from    
    vscode_internal_commits i
  group by
    i.repository_full_name,
    i.author_login
  order by
    count desc
);

drop table if exists vscode_external_committers;
insert into vscode_log(time, event) values (now(), 'vscode_external_committers');
create table vscode_external_committers as (
  select 
    *
  from    
    vscode_committers c 
  where not exists (
    select
      *
    from 
      vscode_internal_committers i 
    where
      c.author_login = i.author_login
      or c.author_login = any ( array ['octref','eamodio'] )
  )
  order by
    c.author_login
);

drop table if exists vscode_external_commits;
insert into vscode_log(time, event) values (now(), 'vscode_external_commits');
create table vscode_external_commits as (
  select 
    *
  from    
    vscode_commits c
  join
    vscode_external_committers i
  using
    (repository_full_name, author_login)
);

drop table if exists vscode_external_commit_counts;
insert into vscode_log(time, event) values (now(), 'vscode_external_commit_counts');
create table vscode_external_commit_counts as (
  select 
    e.repository_full_name,
    e.author_login,
    count(*)
  from    
    vscode_external_commits e
  group by
    e.repository_full_name,
    e.author_login
  order by
    count desc
);

drop table if exists vscode_issues;
insert into vscode_log(time, event) values (now(), 'vscode_issues');
create table vscode_issues as (
  select
    repository_full_name,
    author_login,
    issue_number,
    title,
    created_at,
    closed_at,
    state,
    comments,
    tags
  from
    github_issue
  where
     repository_full_name = 'microsoft/vscode'
);

drop table if exists vscode_issue_filers;
insert into vscode_log(time, event) values (now(), 'vscode_issue_filers');
create table vscode_issue_filers as (
  with unordered as (
    select distinct
      i.repository_full_name,
      i.author_login
    from
      vscode_issues i
  )
  select
    *
  from 
    unordered
  order by
    lower(author_login)
);

-- insert into vscode_log(time, event) values (now(), 'vscode_issue_filer_details');
-- create table vscode_issue_filer_details as (
--  
--   impractical for vscode's 52K issue authors at 5K API calls/hr!'
--
--);

drop table if exists vscode_internal_issue_filers;
insert into vscode_log(time, event) values (now(), 'vscode_internal_issue_filers');
create table vscode_internal_issue_filers as (
  select 
    *
  from    
    vscode_issue_filers i 
  join
    vscode_org_members o
  on
    i.author_login = o.member_login
  order by
    i.author_login
);

drop table if exists vscode_internal_issues;
insert into vscode_log(time, event) values (now(), 'vscode_internal_issues');
create table vscode_internal_issues as (
  select 
    i.repository_full_name,
    lower(i.author_login) as author_login,
    i.issue_number,
    i.created_at,
    i.closed_at,
    i.comments,
    i.state,
    i.title,
    i.tags
  from    
    vscode_issues i
  join
    vscode_internal_issue_filers if
  on
    i.author_login = if.author_login
    and i.repository_full_name = if.repository_full_name
  order by author_login
);

drop table if exists vscode_internal_issue_counts;
insert into vscode_log(time, event) values (now(), 'vscode_internal_issue_counts');
create table vscode_internal_issue_counts as (
  select 
    i.repository_full_name,
    i.author_login,
    count(*)
  from    
    vscode_internal_issues i
  group by
    i.repository_full_name,
    i.author_login
  order by
    count desc
);

drop table if exists vscode_external_issue_filers;
insert into vscode_log(time, event) values (now(), 'vscode_external_issue_filers');
create table vscode_external_issue_filers as (
  with unfiltered as (
    select 
      *
    from    
      vscode_issue_filers i 
    -- use vscode_internal_committers as a proxy for vscode_internal_issue_filers, which
    -- would require 52K github_user calls (at 5K/hr)
    where not exists (
      select
        *
      from 
        vscode_internal_committers c
      where
        c.author_login = i.author_login
    )
    order by
      i.author_login
  )
  select
    *
  from 
    unfiltered u
  where
    not u.author_login = any ( array ['ghost', 'octref', 'vscodeerrors', 'eamodio'] )
);

drop table if exists vscode_external_issues;
insert into vscode_log(time, event) values (now(), 'vscode_external_issues');
create table vscode_external_issues as (
  select 
    *
  from    
    vscode_issues i
  join
    vscode_external_issue_filers e
  using
    (repository_full_name, author_login)
);

drop table if exists vscode_external_issue_counts;
insert into vscode_log(time, event) values (now(), 'vscode_external_issue_counts');
create table vscode_external_issue_counts as (
  select 
    e.repository_full_name,
    e.author_login,
    count(*)
  from    
    vscode_external_issues e
  group by
    e.repository_full_name,
    e.author_login
  order by
    count desc
);

drop table if exists vscode_external_contributors;
insert into vscode_log(time, event) values (now(), 'vscode_external_contributors');
create table vscode_external_contributors as (
  select
    c.repository_full_name,
    c.author_login,
    c.count as vscode_commits,
    'https://github.com/microsoft/vscode/commits?author=' || c.author_login as commits_url,
    i.count as vscode_issues,
    'https://github.com/microsoft/vscode/issues?q=author:' || c.author_login as issues_url,
    cd.name,
    cd.company,
    cd.twitter_username
  from
    vscode_external_commit_counts c
  full join
    vscode_external_issue_counts i
  using
    (repository_full_name, author_login)
  join 
    vscode_committer_details cd 
  on 
    c.author_login = cd.login
  order by
    lower(c.author_login)
);

drop table if exists vscode_external_commit_timelines;
insert into vscode_log(time, event) values (now(), 'vscode_external_commit_timelines');
create table vscode_external_commit_timelines as (
  with data as (
    select
      e.repository_full_name,
      e.author_login,
      min(c.author_date) as first,
      max(c.author_date) as last
    from
      vscode_external_contributors e
    join 
      vscode_commits c
    using (repository_full_name, author_login)
    group by 
      e.repository_full_name, e.author_login
  )
  select
    repository_full_name,
    author_login,
    to_char(first, 'YYYY-MM-DD') as first,
    to_char(last, 'YYYY-MM-DD') as last
  from
    data d
  where
    d.first != d.last
  order by 
    first, last
);


```
