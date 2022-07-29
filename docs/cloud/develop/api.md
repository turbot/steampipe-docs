---
title:  Using the Steampipe Cloud API
sidebar_label: API
---

# Using the Steampipe Cloud API

## Authentication
To use the Steampipe Cloud API, you must connect with an [API token](/docs/cloud/profile#api-tokens). 
The examples in this section assume that you have set the [`STEAMPIPE_CLOUD_TOKEN`](reference/env-vars/steampipe_cloud_token) to a valid API token:
```bash
export STEAMPIPE_CLOUD_TOKEN=spt_c6rnjt8afakemj4gha10_svpnmxqfaketokenad431k
```

## Query Your Data
The Steampipe Cloud API makes it easy query your data and integrate it into your scripts and applications!

You can issue a simple query with a GET request:
```bash
curl -H "Authorization: Bearer ${STEAMPIPE_CLOUD_TOKEN}" \
  https://cloud.steampipe.io/api/latest/user/foo/workspace/bar/query?sql=select+*+from+aws_s3_bucket
```

If you POST you can avoid encoding the SQL:
```bash
curl -H "Authorization: Bearer ${STEAMPIPE_CLOUD_TOKEN}" \
  -d 'sql=select name,arn from aws_s3_bucket' \
  https://cloud.steampipe.io/api/latest/user/foo/workspace/bar/query
```


By default, the results are in JSON. You can get the results in other formats simple by adding a file name with the appropriate extension to the path.  You can get your results in CSV:

```bash
curl -H "Authorization: Bearer ${STEAMPIPE_CLOUD_TOKEN}" \
  -d sql'=select name,arn from aws_s3_bucket' \
  https://cloud.steampipe.io/api/latest/user/foo/workspace/bar/query/my-file.csv
```

Or markdown:
```bash
curl -H "Authorization: Bearer ${STEAMPIPE_CLOUD_TOKEN}" \
  -d sql'=select name,arn from aws_s3_bucket' \
  https://cloud.steampipe.io/api/latest/user/foo/workspace/bar/query/my-file.md
```

Alternatively, you can set the content type in the `content_type` query parameter:
```bash
curl -H "Authorization: Bearer ${STEAMPIPE_CLOUD_TOKEN}" \
  -d sql'=select name,arn from aws_s3_bucket' \
  https://cloud.steampipe.io/api/latest/user/foo/workspace/bar/query?content_type=csv
```

Or via HTTP headers:
```bash
curl -H "Authorization: Bearer ${STEAMPIPE_CLOUD_TOKEN}" \
  -H "Accept: text/csv" \
  -X POST -d sql='select name,arn from aws_s3_bucket' \
  https://cloud.steampipe.io/api/latest/user/foo/workspace/bar/query
```




## Reference
The API OpenAPI definition is available for download at https://cloud.steampipe.io/api/latest/docs/openapi.json.  

You can view it any OpenAPI viewer, such as [ReDoc](https://redocly.github.io/redoc/?url=https://cloud.steampipe.io/api/latest/docs/openapi.json)




