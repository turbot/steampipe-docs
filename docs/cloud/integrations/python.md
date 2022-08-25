---
title:  Connect to Steampipe Cloud with Python
sidebar_label: Python
---
# Connect to Steampipe Cloud with Python

Since your Steampipe Cloud workspace is just a PostgreSQL database, you can use the standard `psycopg2` adapter to query your workspace database from Python.

The [Connect](/docs/cloud/integrations/overview) tab for your workspace provides the details you need to connect Python to Steampipe Cloud.

<div style={{"borderWidth":"thin", "borderStyle":"solid", "borderColor":"lightgray", "padding":"20px", "width":"90%"}}>
<img src="/images/docs/cloud/cloud-connect-tab.jpg" />
</div>

<br/>

It's the usual drill: specify your connection string, create a connection, run a query, fetch results.

```python
import psycopg2
conn_str = "host='acme-jon.usea1.db.steampipe.io' dbname='o6u91f' user='judell' 
  port='9193' password='df**-****-**ee'"
conn = psycopg2.connect(conn_str)
cur = conn.cursor()
cur.execute('select name, region, account_id from aws_s3_bucket limit 2')
r = cur.fetchall()
print(r)
```

```sh
[('10k-with-standard-kms', 'us-east-2', '899206412154'), 
('10k-with-bucket-kms', 'us-east-2', '899206412154')]
```

You can do the same thing in a Jupyter notebook, and flow query results into a dataframe.

<div style={{"borderWidth":"thin", "borderStyle":"solid", "borderColor":"lightgray", "padding":"20px", "width":"95%"}}>
<img src="/images/docs/cloud/jupyter-to-spc.jpg" /> 
</div>