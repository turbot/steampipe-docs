---
title:  Connect to Steampipe Cloud with R
sidebar_label: R
---
## Connect to Steampipe Cloud from R

Since your Steampipe Cloud workspace is just a Postgres database, you can use the standard `RPostgres` adapter to query your workspace database from R.

The [Connect](/docs/cloud/integrations/overview) tab for your workspace provides the details you need to connect R to Steampipe Cloud.

<div style={{"borderWidth":"thin", "borderStyle":"solid", "borderColor":"lightgray", "padding":"20px", "width":"90%"}}>
<img src="/images/docs/cloud/steampipe-cloud-connect-details.jpg" />
</div>

<br/>

Install [RPostgres](https://cran.r-project.org/web/packages/RPostgres/index.html), specify your connection string, create a connection, run a query, fetch results.

```r
install.packages('RPostgres')
install.packages("rjson")
library(DBI)
library("rjson")
db <- 'dea4px'
host_db <- 'rahulsrivastav14-rahulsworkspace.usea1.db.steampipe.io'
db_port <- '9193'
db_user <- 'rahulsrivastav14'
db_password <- 'f4**-****-**2g'
con <- dbConnect(RPostgres::Postgres(), dbname=db, host=host_db, port=db_port, user=db_user, password=db_password)
tbl <- dbGetQuery(con, 'select * from hackernews_new limit 2')
toJSON(tbl)
```

```json
{
    "title": [
        "Astonishing regularity in learning rate among college students",
        "Morning exposure to deep red light improves declining eyesight"
    ],
    "score": [
        2.57e-322,
        8.25e-322
    ]
}
```

## Connect to Steampipe CLI from R

To connect R to [Steampipe CLI](https://steampipe.io/downloads), run `steampipe service start --show-password` and use the displayed connection details.

```
Steampipe service is running:

Database:

  Host(s):            localhost, 127.0.0.1, 172.28.158.171
  Port:               9193
  Database:           steampipe
  User:               steampipe
  Password:           9a**-****-**7e
  Connection string:  postgres://steampipe:9a49-42e2-a57e@localhost:9193/steampipe
  ```

## Call the Steampipe Cloud API from R

You can also use the [Steampipe Cloud query API](https://steampipe.io/docs/cloud/develop/query-api). Grab your [token](https://steampipe.io/docs/cloud/profile#tokens), put it an environment variable like `STEAMPIPE_CLOUD_TOKEN`, and use this pattern.

```r
 install.packages("httr")
install.packages("jsonlite")
library(httr)
library(jsonlite)
POST(url="https://cloud.steampipe.io/api/latest/user/rahulsrivastav14/workspace/rahulsworkspace/query",
     config=add_headers(c("Authorization"= "Bearer, {STEAMPIPE_CLOUD_TOKEN}",
                          "Content-Type: application/json")),
     body= "{select title, score from hackernews_top order by score desc limit 2}")
```

```json
{
  "items": [
    {
      "score": 1285,
      "title": "Easter egg in flight path of last 747 delivery flight"
    },
    {
      "score": 1004,
      "title": "ChatGPT Plus"
    }
  ]
}
```
