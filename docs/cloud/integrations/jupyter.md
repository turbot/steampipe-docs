---
title:  Connect to Steampipe Cloud with a Jupyter Notebook
sidebar_label: Jupyter Notebook
---
# Connect to Steampipe Cloud from Jupyter Notebook

Since your Steampipe Cloud workspace is just a Postgres database, you can use the standard `psycopg2` adapter to query your workspace database from Python.

The [Connect](/docs/cloud/integrations/overview) tab for your workspace provides the details you need to connect a Jupyter Notebook to Steampipe Cloud.

<div style={{"borderWidth":"thin", "borderStyle":"solid", "borderColor":"lightgray", "padding":"20px", "width":"90%"}}>
  <img src="/images/docs/cloud/cloud-connect-tab.jpg" />
</div>

<br/>

It's the usual drill: import [psycopg2](https://wiki.postgresql.org/wiki/Psycopg2_Tutorial), specify your connection string, create a connection, then run a query. (See also: [Connect to Steampipe Cloud from Python](https://steampipe.io/docs/cloud/integrations/python).)

In this example we connect from an instance of Jupyter Notebook running in VSCode, load the query results into a <a href="https://pandas.pydata.org/docs/reference/api/pandas.DataFrame.html">pandas.DataFrame</a>, then use its <a href="https://pandas.pydata.org/docs/reference/api/pandas.DataFrame.describe.html">describe</a> method to summarize the data.

<div style={{"borderWidth":"thin", "borderStyle":"solid", "borderColor":"lightgray", "padding":"20px", "width":"90%"}}>
  <img src="/images/docs/cloud/jupyter.png" />
</div>


## Connect to Steampipe CLI from Jupyter Notebook

To connect Jupyter Notebook to [Steampipe CLI](https://steampipe.io/downloads), run `steampipe service start --show-password` and use the displayed connection details. 

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

## Call the Steampipe Cloud API from Jupyter Notebook

You can also use the [Steampipe Cloud query API](https://steampipe.io/docs/cloud/develop/query-api). Grab your [token](https://steampipe.io/docs/cloud/profile#api-tokens), put it an environment variable like `STEAMPIPE_CLOUD_TOKEN`, and use this pattern.

```python
import json, os, requests
url = 'https://cloud.steampipe.io/api/latest/org/acme/workspace/jon/query'
data = {'sql':'select name, region from aws_s3_bucket limit 2'}
token = os.environ['STEAMPIPE_CLOUD_TOKEN']
headers = {"Authorization": "Bearer " + token}
r = requests.post(url, headers=headers, data=data)
print(json.dumps(r.json(),indent=4))
```

```json
{
    "items": [
        {
            "name": "10k-with-bucket-kms",
            "region": "us-east-2"
        },
        {
            "name": "10k-with-standard-kms",
            "region": "us-east-2"
        }
    ]
}
```
