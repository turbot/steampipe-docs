---
title:  Connect to Steampipe Cloud with Javascript
sidebar_label: Javascript
---
# Connect to Steampipe Cloud from Javascript

The Steampipe Cloud workspace is a Postgres database, with the use of the `pg` client you can connect and query your workspace database with Javascript.

The [Connect](/docs/cloud/integrations/overview) tab for your workspace provides the details you need to connect Steampipe Cloud with Javascript.

<div style={{"marginTop":"1em", "marginBottom":"1em", "width":"90%"}}>
<img src="/images/docs/cloud/steampipe-cloud-connect-details.jpg" />
</div>

To start, you would need to install the postgres client with `nmp i pg`, specify the connection string, establish a successful connection, run your query and get the results. In this example, we query the state and the region of `aws_vpc` using Javascript.

```javascript
const postgres = require("pg");

const conn = {
  connectionString:
    "postgresql://rahulsrivastav14:f3**-****-**2c@rahulsrivastav14-rahulsworkspace.usea1.db.steampipe.io:9193/dea4px",
  ssl: {
    rejectUnauthorized: false,
  },
};

let pgClient = new postgres.Client(conn);
pgClient.connect();

pgClient.query("Select vpc_id, region, state from aws_vpc", (err, res) => {
  if (err) console.error(err);
  console.log(res.rows);
  pgClient.end();
});

```

```json
[
  {
    vpc_id: 'vpc-0142da3508c247062e',
    region: 'us-east-1',
    state: 'available'
  },
  {
    vpc_id: 'vpc-12199f7a',
    region: 'ca-central-1',
    state: 'available'
  }
]
```

## Connect to Steampipe CLI from Javascript

To connect Javascript to [Steampipe CLI](https://steampipe.io/downloads), run `steampipe service start --show-password` and use the displayed connection details.

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

## Call the Steampipe Cloud API from Javascript

You can also use the [Steampipe Cloud query API](https://steampipe.io/docs/cloud/develop/query-api) with the Javascript `request` client. Grab your [token](https://steampipe.io/docs/cloud/profile#api-tokens), put it an environment variable like `STEAMPIPE_CLOUD_TOKEN`, and use this pattern.

```javascript
const request = require('request');
let hostname = "https://cloud.steampipe.io/api/latest/user/rahulsrivastav14/workspace/rahulsworkspace/query";
const data = {'sql':'Select is_default, region, state from aws_vpc limit 2'}
const headers= {
  "Authorization": `Bearer ${process.env.STEAMPIPE_CLOUD_TOKEN}`
}
request.post({
    url: hostname,
    headers: headers,
    json: true,
    body: data
  }, function(error, response, body){
  console.log(JSON.stringify(body));
});
```

```json
{
  "items":
  [
    {
      "is_default":true,
      "region":"ca-central-1",
      "state":"available"
    },
    {
      "is_default":true,
      "region":"us-east-1",
      "state":"available"
    }
  ]
}
```