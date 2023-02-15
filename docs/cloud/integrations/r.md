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

To get started, Install the [RPostgres](https://cran.r-project.org/web/packages/RPostgres/index.html) package, specify your connection string, create a connection, then run a query.

In this example we connect from the R console, load the query results, then use its [summary](https://www.rdocumentation.org/packages/base/versions/3.6.2/topics/summary) function to summarize the data.

```r
install.packages('RPostgres')
library(DBI)
db <- 'dea4px'
host_db <- 'rahulsrivastav14-rahulsworkspace.usea1.db.steampipe.io'
db_port <- '9193'
db_user <- 'rahulsrivastav14'
db_password <- 'f4**-****-**2s'
con <- dbConnect(RPostgres::Postgres(), dbname=db, host=host_db, port=db_port, user=db_user, password=db_password)
tbl <- dbGetQuery(con, 'select name, region, versioning_enabled from aws_s3_bucket')
summary(tbl)
```

<div style={{"borderWidth":"thin", "borderStyle":"solid", "borderColor":"lightgray", "padding":"20px", "width":"90%"}}> <img src="/images/docs/cloud/r-data-summary.png" /> </div>

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
library(httr)
response <- POST( url="https://cloud.steampipe.io/api/latest/user/rahulsrivastav14/workspace/rahulsworkspace/query",
add_headers(.headers = c(
'Authorization'='Bearer {STEAMPIPE_CLOUD_TOKEN}',
'Content-Type' = 'application/json',
'Encoding' = "UTF-8")),
body = '{"sql":"select name, region from aws_s3_bucket limit 2"}')
content(response, "text")
```

```json
{
  "items": [
    {
      "name": "amplify-authcra-devc-deployment",
      "region": "us-east-2"
    },
    {
      "name": "appstream-app-settings-us-east-1-v01a5",
      "region": "us-east-1"
    }
  ]
}
```
