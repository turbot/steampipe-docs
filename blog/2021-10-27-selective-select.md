---
id: selective-select
title: "When not to SELECT *"
category: Case Study
description: "Steampipe can combine results from primary and subsidiary API calls. But when you don't need the subsidiary results, don't spend the API calls to get them."
summary: "Steampipe can combine results from primary and subsidiary API calls. But when you don't need the subsidiary results, don't spend the API calls to get them."
author:
  name: Jon Udell
  twitter: "@judell"
publishedAt: "2021-10-28T14:00:00"
durationMins: 7
image: "/images/blog/2021-10-27-selective-select/selective-select.jpg"
slug: selective-select
schema: "2021-01-08"
---

I had just put the finishing touches on the analysis pipeline discussed in the [last post](https://steampipe.io/blog/vscode-analysis), and was running it one more time to validate my changes, when I triggered the GitHub API *Rate limited exceeded* response. For authenticated clients the limit is 5000 calls per hour; the message said the limit would reset in 45 minutes. 

This didn't make sense. Until then I'd been pulling in a couple of good-sized tables -- one with 88K rows, another with 121K rows -- and doing all that comfortably within the 5K API calls/hr limit. I'd hit that limit a few times before, while developing the pipeline and running it repeatedly, but no individual run had triggered the limit. 

## The mystery deepens

More strangeness: a table that should have had 88K rows had only a few thousand when GitHub slammed the door on my query. What could have changed? Was GitHub punishing me for prior infractions? Was there some new limit I didn't know about?

After the reset I fired up PostMan, pointed it at `https://api.github.com/rate_limit`, added the header `Authorization: Bearer MY_PERSONAL_ACCESS_TOKEN`, restarted the script, and began checking the results of the `rate_limit` call. (Those checks don't count toward your limit.)

The `resources -> core -> remaining` counter was dropping at an alarming rate. A query that should have run for 20 minutes, and yielded 88K rows, ended in several minutes after yielding only a few thousand rows. It was as if the plugin's paging mechanism had suddenly quit working, and API calls that had each formerly produced 100 rows were now only producing single rows.

## Mystery solved!

In fact that's exactly what happened, and here's why. One of my finishing touches had been to convert a query of the form `SELECT col1, col2, col3` to simply `SELECT *`. In doing so I had unwittingly asked Steampipe to make an extra API call for each row of the table I was fetching.

Here are the columns defined in the [github_commit table](https://github.com/turbot/steampipe-plugin-github/blob/main/github/table_github_commit.go). 

```golang
Columns: []*plugin.Column{
    // Top columns
    {Name: "repository_full_name", Type: proto.ColumnType_STRING, Hydrate: repositoryFullNameQual, Transform: transform.FromValue(), Description: "Full name of the repository that contains the commit."},
    {Name: "sha", Type: proto.ColumnType_STRING, Transform: transform.FromField("SHA"), Description: "SHA of the commit."},
    // Other columns
    {Name: "author_login", Type: proto.ColumnType_STRING, Transform: transform.FromField("Author.Login"), Description: "The login name of the author of the commit."},
    {Name: "author_date", Type: proto.ColumnType_TIMESTAMP, Transform: transform.FromField("Commit.Author.Date"), Description: "Timestamp when the author made this commit."},
    {Name: "comments_url", Type: proto.ColumnType_STRING, Description: "Comments URL of the commit."},
    {Name: "commit", Type: proto.ColumnType_JSON, Description: "Commit details."},
    {Name: "committer_login", Type: proto.ColumnType_STRING, Transform: transform.FromField("Committer.Login"), Description: "The login name of committer of the commit."},
    {Name: "committer_date", Type: proto.ColumnType_TIMESTAMP, Transform: transform.FromField("Commit.Committer.Date"), Description: "Timestamp when the committer made this commit."},
 🡆 {Name: "files", Type: proto.ColumnType_JSON, Hydrate: tableGitHubCommitGet, Description: "Files of the commit."},
    {Name: "html_url", Type: proto.ColumnType_STRING, Description: "HTML URL of the commit."},
    {Name: "message", Type: proto.ColumnType_STRING, Transform: transform.FromField("Commit.Message"), Description: "Commit message."},
    {Name: "node_id", Type: proto.ColumnType_STRING, Description: "Node where GitHub stores this data internally."},
    {Name: "parents", Type: proto.ColumnType_JSON, Description: "Parent commits of the commit."},
 🡆 {Name: "stats", Type: proto.ColumnType_JSON, Hydrate: tableGitHubCommitGet, Description: "Statistics of the commit."},
    {Name: "url", Type: proto.ColumnType_STRING, Description: "URL of the commit."},
    {Name: "verified", Type: proto.ColumnType_BOOL, Transform: transform.FromField("Commit.Verification.Verified"), Description: "True if the commit was verified with a signature."},
    },
```

I was fetching `repository_full_name`, `sha`, `author_login`, `author_date`, and `commit`. Under the covers, Steampipe uses the REST API call that lists commits: `https://api.github.com/repos/ORG/REPO/commits`. Since all of the columns I'd asked for were part the response to that call, and since you can fetch 100 commits per call, the ratio of calls to returned rows was 1:100.

## Auxiliary API calls

Two of the columns I hadn't asked for, `files` and `stats`, aren't like the others. They declare a `Hydrate` function called `tableGitHubCommitGet`; it invokes the REST API call that gets an individual commit: `https://api.github.com/repos/ORG/REPO/commits/SHA`.

Here's part of that response.
  
```json
 {
 ...
 "stats": {
        "total": 30,
        "additions": 12,
        "deletions": 18
    },
 "files": [
    {
        "sha": "80ed701d0aaa084672b96004b6e3d089dfee379a",
        "filename": "src/vs/platform/terminal/node/ptyHostService.ts",
        "status": "modified",
        "additions": 1,
        "deletions": 6,
        "changes": 7,
   ...
  }
```

When you ask for those columns explicitly, or implicitly with `SELECT *`, Steampipe grabs this extra information and adds it to each returned row. If you're not getting rate-limited, you'll love this. As API users we like "fat" responses that pack as much as possible inro the rows returned by list operations, so that we don't have to make subsidiary API calls for extra data. But when Steampipe makes such calls on our behalf, that 1:100 ratio of calls to rows can become 1:1.

(Steampipe is clever about making subsidiary calls. They happen in parallel, so the issue here isn't speed, it's the volume of API traffic.)

The solution was, of course, to revert to enumerating the columns I wanted. Not needing `files` or `stats`, there was no reason for Steampipe to fetch them.

## A new `rate_limit` table!

Since Steampipe is the ultimate API client, I wondered: Why use Postman to call the `rate_limit` API? Why not add it as table to the GitHub plugin? Our developers love to make plugins more useful and, in a couple of days, it was done. Now you can do this.


<Terminal>
  <TerminalCommand>
    {`
select 
  core_limit, 
  core_remaining, 
  core_reset 
from github_rate_limit;
    `}
  </TerminalCommand>
  <TerminalResult>
    {`
 core_limit | core_remaining |       core_reset
------------+----------------+------------------------
       5000 |           4657 | 2021-10-21 22:36:13+00
    `}
  </TerminalResult>
</Terminal>

<br/>

The `core_reset` tells me that the limit will be reset at 10:36PM UTC which is 3:36PM in my timezone (PST). 

Like all Steampipe tables, this new one is subject to caching. If you want to see realtime results, open `~/.steampipe/config/github.spc` and add:

```hcl
 options "connection" {
    cache     = false
  }
```

<br/>

Don't forget to remove that setting when you're done, though! If no `options` argument appears in a plugin's `.spc` file, the global defaults in `~/.steampipe/config/default.spc` apply: `cache = true` and `cache_ttl = 300` (expiry in 5 minutes). You can override those defaults in an individual plugins `.scp` file, either to turn off caching as above, or perhaps to increase it if you want to keep query results longer than 5 minutes.

## Revisiting Cloud Control

In our deep dive into [AWS Cloud Control](https://steampipe.io/blog/aws-cloud-control), we noted that the Cloud Control API always makes subsidiary API calls. When you use it to list S3 buckets, for example, you trigger a cascade of calls to `GetBucketVersioning`, `GetBucketTagging`, `GetBucketReplication` and many others. You pay for those calls whether you need the information or not. There are other costs too. If you get throttled while using Steampipe you can shut down another app that relies on the same APIs. Unnecessary API traffic also injects noise into your monitoring system, and adds costly bulk to your logging system.

With Steampipe you have a choice. Use `SELECT *` when you really need all the data. But when you don't, just ask for the columns you care about. If you do need a column that's "hydrated" -- like `files` and `stats` in the above example -- then ask for it, of course, but be aware that Steampipe makes extra API calls to get it.
