---
title:  Connect to Steampipe Cloud with a RStudio
sidebar_label: RStudio
---
# Connect to Steampipe Cloud from RStudio

Since your Steampipe Cloud workspace is just a Postgres database, you can use the standard `RPostgres` adapter to query your workspace database from R.

The [Connect](/docs/cloud/integrations/overview) tab for your workspace provides the details you need to connect RStudio to Steampipe Cloud.

<div style={{"marginTop":"1em", "marginBottom":"1em", "width":"90%"}}>
<img src="/images/docs/cloud/steampipe-cloud-connect-details.jpg" />
</div>

It's the usual drill: import [RPostgres](https://cran.r-project.org/web/packages/RPostgres/index.html), specify your connection string, create a connection, then run a query.

In this example we connect from Rstudio, load the query and summarize the data in a table form.

<div style={{"borderWidth":"thin", "borderStyle":"solid", "borderColor":"lightgray", "padding":"20px", "width":"90%"}}>
  <img src="/images/docs/cloud/rstudio-data-preview.png" />
</div>

## Connect to Steampipe CLI from RStudio

To connect RStudio to [Steampipe CLI](https://steampipe.io/downloads), run `steampipe service start --show-password` and use the displayed connection details.

```
Steampipe service is running:

Database:

  Host(s):            localhost, 127.0.0.1, 192.168.29.204
  Port:               9193
  Database:           steampipe
  User:               steampipe
  Password:           99**_****_**8c
  Connection string:  postgres://steampipe:99**_****_**8c@localhost:9193/steampipe
  ```

## Call the Steampipe Cloud API from RStudio

You can also use the [Steampipe Cloud query API](https://steampipe.io/docs/cloud/develop/query-api). Grab your [token](https://steampipe.io/docs/cloud/profile#api-tokens), put it an environment variable like `STEAMPIPE_CLOUD_TOKEN`, and use this pattern.

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
