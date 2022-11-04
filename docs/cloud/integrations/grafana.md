---
title: Connect to Steampipe Cloud from Grafana
sidebar_label: Grafana
---

##  Connect to Steampipe Cloud from Grafana

[Grafana](https://grafana.com/) is a visualization tool that connects to many databases including Postgres, and enables users to query, monitor, create alerts and analyze metrics through dashboards.

Steampipe provides a single interface to all your cloud, code, logs and more. Because it's built on Postgres, Steampipe provides an endpoint that any Postgres-compatible client -- including Grafana -- can connect to.

The [Connect](/docs/cloud/integrations/overview) tab for your workspace provides the details you need to connect Grafana to Steampipe Cloud.

<div style={{"marginBottom":"2em","borderWidth":"thin", "borderStyle":"solid", "borderColor":"lightgray", "padding":"20px", "width":"90%"}}>
<img src="/images/docs/cloud/steampipe-cloud-connect-details.jpg" />
</div>

##  Connect to Steampipe CLI from Grafana

You can also connect Grafana to [Steampipe CLI](https://steampipe.io/downloads). To do that, run `steampipe service start --show-password` and use the displayed connection details.

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

## Getting started

[Grafana](https://grafana.com/docs/grafana/latest/setup-grafana/installation/) is a open source interactive data-visualization platform that runs on the cloud, or in a container, or the desktop. To use Grafana you will need to sign up and create an account. Here, we will use the desktop version.

With Grafana up and running, you can access it from the browser through `http://localhost:3000`. Click on `Data Sources` under the configuration option, then click `Add Data Source`, select `PostgreSQL` and enter the connection details. Since there is no field for port number, it should be added with the host as `Host:Port` and set the TLS/SSL mode to `Require`. Then click `Save & Test` to test your connection.

<div style={{"marginTop":"1em", "marginBottom":"1em", "width":"90%"}}>
<img src="/images/docs/cloud/grafana-connection-success.png" />
</div>

The plugins and it's tables can be accessed through the `Explore` tab and the `Edit SQL` option can be used to customize the queries.

<div style={{"marginTop":"1em", "marginBottom":"1em", "width":"50%"}}>
<img src="/images/docs/cloud/grafana-explore-tables.png" />
</div>

The data can be previewed in a `Table format` or `Time series`. Here we see the AWS EC2 instances listed in a table format.

<div style={{"marginTop":"1em", "marginBottom":"1em", "width":"50%"}}>
<img src="/images/docs/cloud/grafana-table-format-data-preview.png" />
</div>

## Dashborad to monitor resources and cost

Grafana uses panels as the building blocks of a dashboard that consists of queries, graphs, aliases, etc. We'll focus here on creating a dashboard to monitor AWS services and Cost. To being click on `Dashboards` and create a new dashboard. On the empty dashboard click `Add panel` to create a panel and select `aws_ebs_volume_metric_read_ops_daily` from the query builder, then click `Apply`. Now add panels for `aws_ec2_instance_metric_cpu_utilization_hourly`, `aws_s3_bucket_by_region` and `aws_vpc_by_region`. Similarly paste the query into a new panel to monitor the top 10 monthly costs by service.

```
select
  service,
  sum(unblended_cost_amount)::numeric::money as sum,
  avg(unblended_cost_amount)::numeric::money as average
from
  aws_cost_by_service_monthly
group by
  service
order by
  average desc
limit 10;
```
Grafana gives a wide range of graphics that you can use to represent the data in each panel. Now with the created panels we have our AWS Monitoring dashboard ready.

<div style={{"marginTop":"1em", "marginBottom":"1em", "width":"90%"}}>
<img src="/images/docs/cloud/grafana-dashboard.png" />
</div>

## Import a dashboard with JSON file

Since, a dashboard in Grafana is represented by a JSON object, which stores its metadata. We can [import a dashboard](https://grafana.com/docs/grafana/v9.0/dashboards/export-import/#import-dashboard) using json input. To import click `Import` under the Dashboards icon in the side menu and paste the below code to create a AWS S3 dashboard. With the Enterprise licensed feature you can send the dashboards as reports.

<details>
  <summary>AWS S3 JSON</summary>

```json
{
  "annotations": {
    "list": [
      {
        "builtIn": 1,
        "datasource": {
          "type": "datasource",
          "uid": "grafana"
        },
        "enable": true,
        "hide": true,
        "iconColor": "rgba(0, 211, 255, 1)",
        "name": "Annotations & Alerts",
        "target": {
          "limit": 100,
          "matchAny": false,
          "tags": [],
          "type": "dashboard"
        },
        "type": "dashboard"
      }
    ]
  },
  "editable": true,
  "fiscalYearStartMonth": 0,
  "graphTooltip": 0,
  "id": 4,
  "links": [],
  "liveNow": false,
  "panels": [
    {
      "datasource": {
        "type": "postgres",
        "uid": "OxfC_3N4z"
      },
      "fieldConfig": {
        "defaults": {
          "mappings": [],
          "thresholds": {
            "mode": "percentage",
            "steps": [
              {
                "color": "green",
                "value": null
              },
              {
                "color": "orange",
                "value": 70
              },
              {
                "color": "red",
                "value": 85
              }
            ]
          }
        },
        "overrides": []
      },
      "gridPos": {
        "h": 8,
        "w": 5,
        "x": 0,
        "y": 0
      },
      "id": 13,
      "options": {
        "orientation": "auto",
        "reduceOptions": {
          "calcs": [
            "lastNotNull"
          ],
          "fields": "",
          "values": false
        },
        "showThresholdLabels": false,
        "showThresholdMarkers": true
      },
      "pluginVersion": "9.2.2",
      "targets": [
        {
          "datasource": {
            "type": "postgres",
            "uid": "OxfC_3N4z"
          },
          "format": "table",
          "group": [],
          "metricColumn": "none",
          "rawQuery": true,
          "rawSql": "select\n  count(*)\nfrom\n  aws_s3_bucket\nwhere\n  logging ->> 'TargetBucket' = name;",
          "refId": "A",
          "select": [
            [
              {
                "params": [
                  "average"
                ],
                "type": "column"
              }
            ]
          ],
          "table": "aws_rds_db_instance_metric_cpu_utilization_hourly",
          "timeColumn": "\"timestamp\"",
          "timeColumnType": "timestamp",
          "where": [
            {
              "name": "$__timeFilter",
              "params": [],
              "type": "macro"
            }
          ]
        }
      ],
      "title": "Logging Destination Same As The Source Bucket",
      "type": "gauge"
    },
    {
      "datasource": {
        "type": "postgres",
        "uid": "OxfC_3N4z"
      },
      "fieldConfig": {
        "defaults": {
          "mappings": [],
          "thresholds": {
            "mode": "percentage",
            "steps": [
              {
                "color": "green",
                "value": null
              },
              {
                "color": "orange",
                "value": 70
              },
              {
                "color": "red",
                "value": 85
              }
            ]
          }
        },
        "overrides": []
      },
      "gridPos": {
        "h": 8,
        "w": 5,
        "x": 5,
        "y": 0
      },
      "id": 1,
      "options": {
        "orientation": "auto",
        "reduceOptions": {
          "calcs": [
            "lastNotNull"
          ],
          "fields": "",
          "values": false
        },
        "showThresholdLabels": false,
        "showThresholdMarkers": true
      },
      "pluginVersion": "9.2.2",
      "targets": [
        {
          "datasource": {
            "type": "postgres",
            "uid": "OxfC_3N4z"
          },
          "format": "table",
          "group": [],
          "metricColumn": "none",
          "rawQuery": true,
          "rawSql": "select\n  count(*)\nfrom\n  aws_s3_bucket\nwhere\n  not block_public_acls\n  or not block_public_policy\n  or not ignore_public_acls\n  or not restrict_public_buckets;",
          "refId": "A",
          "select": [
            [
              {
                "params": [
                  "data_transfer_progress_current_rate_in_mega_bytes_per_second"
                ],
                "type": "column"
              }
            ]
          ],
          "table": "aws_redshift_clusters",
          "timeColumn": "cluster_create_time",
          "timeColumnType": "timestamp",
          "where": [
            {
              "name": "$__timeFilter",
              "params": [],
              "type": "macro"
            }
          ]
        }
      ],
      "title": "Public Access Block Disabled",
      "type": "gauge"
    },
    {
      "datasource": {
        "type": "postgres",
        "uid": "OxfC_3N4z"
      },
      "fieldConfig": {
        "defaults": {
          "mappings": [],
          "thresholds": {
            "mode": "percentage",
            "steps": [
              {
                "color": "green",
                "value": null
              },
              {
                "color": "orange",
                "value": 70
              },
              {
                "color": "red",
                "value": 85
              }
            ]
          }
        },
        "overrides": []
      },
      "gridPos": {
        "h": 8,
        "w": 5,
        "x": 10,
        "y": 0
      },
      "id": 3,
      "options": {
        "orientation": "auto",
        "reduceOptions": {
          "calcs": [
            "lastNotNull"
          ],
          "fields": "",
          "values": false
        },
        "showThresholdLabels": false,
        "showThresholdMarkers": true
      },
      "pluginVersion": "9.2.2",
      "targets": [
        {
          "datasource": {
            "type": "postgres",
            "uid": "OxfC_3N4z"
          },
          "format": "table",
          "group": [],
          "metricColumn": "none",
          "rawQuery": true,
          "rawSql": "select\n  count(*)\nfrom\n  aws_s3_bucket,\n  jsonb_array_elements(policy_std -> 'Statement') as s,\n  jsonb_array_elements_text(s -> 'Principal' -> 'AWS') as p,\n  jsonb_array_elements_text(s -> 'Action') as a,\n  jsonb_array_elements_text(\n    s -> 'Condition' -> 'Bool' -> 'aws:securetransport'\n  ) as ssl\nwhere\n  p = '*'\n  and s ->> 'Effect' = 'Deny'\n  and ssl :: bool = false;",
          "refId": "A",
          "select": [
            [
              {
                "params": [
                  "data_transfer_progress_current_rate_in_mega_bytes_per_second"
                ],
                "type": "column"
              }
            ]
          ],
          "table": "aws_redshift_clusters",
          "timeColumn": "cluster_create_time",
          "timeColumnType": "timestamp",
          "where": [
            {
              "name": "$__timeFilter",
              "params": [],
              "type": "macro"
            }
          ]
        }
      ],
      "title": "Enforced Encryption In Transit",
      "type": "gauge"
    },
    {
      "datasource": {
        "type": "postgres",
        "uid": "OxfC_3N4z"
      },
      "fieldConfig": {
        "defaults": {
          "mappings": [],
          "thresholds": {
            "mode": "percentage",
            "steps": [
              {
                "color": "green",
                "value": null
              },
              {
                "color": "orange",
                "value": 70
              },
              {
                "color": "red",
                "value": 85
              }
            ]
          }
        },
        "overrides": []
      },
      "gridPos": {
        "h": 8,
        "w": 5,
        "x": 15,
        "y": 0
      },
      "id": 5,
      "options": {
        "orientation": "auto",
        "reduceOptions": {
          "calcs": [
            "lastNotNull"
          ],
          "fields": "",
          "values": false
        },
        "showThresholdLabels": false,
        "showThresholdMarkers": true
      },
      "pluginVersion": "9.2.2",
      "targets": [
        {
          "datasource": {
            "type": "postgres",
            "uid": "OxfC_3N4z"
          },
          "format": "table",
          "group": [],
          "metricColumn": "none",
          "rawQuery": true,
          "rawSql": "select\n  count(*)\nfrom\n  aws_s3_bucket\nwhere\n  versioning_enabled = false;",
          "refId": "A",
          "select": [
            [
              {
                "params": [
                  "average"
                ],
                "type": "column"
              }
            ]
          ],
          "table": "aws_rds_db_instance_metric_cpu_utilization_hourly",
          "timeColumn": "\"timestamp\"",
          "timeColumnType": "timestamp",
          "where": [
            {
              "name": "$__timeFilter",
              "params": [],
              "type": "macro"
            }
          ]
        }
      ],
      "title": "Versioning Disabled",
      "type": "gauge"
    },
    {
      "datasource": {
        "type": "postgres",
        "uid": "OxfC_3N4z"
      },
      "fieldConfig": {
        "defaults": {
          "mappings": [],
          "thresholds": {
            "mode": "percentage",
            "steps": [
              {
                "color": "green",
                "value": null
              },
              {
                "color": "orange",
                "value": 70
              },
              {
                "color": "red",
                "value": 85
              }
            ]
          }
        },
        "overrides": []
      },
      "gridPos": {
        "h": 8,
        "w": 5,
        "x": 0,
        "y": 8
      },
      "id": 9,
      "options": {
        "orientation": "auto",
        "reduceOptions": {
          "calcs": [
            "lastNotNull"
          ],
          "fields": "",
          "values": false
        },
        "showThresholdLabels": false,
        "showThresholdMarkers": true
      },
      "pluginVersion": "9.2.2",
      "targets": [
        {
          "datasource": {
            "type": "postgres",
            "uid": "OxfC_3N4z"
          },
          "format": "table",
          "group": [],
          "metricColumn": "none",
          "rawQuery": true,
          "rawSql": "select\n  count(*)\nfrom\n  aws_s3_bucket,\n  jsonb_array_elements(policy_std -> 'Statement') as s,\n  jsonb_array_elements_text(s -> 'Principal' -> 'AWS') as p,\n  string_to_array(p, ':') as pa,\n  jsonb_array_elements_text(s -> 'Action') as a\nwhere\n  s ->> 'Effect' = 'Allow'\n  and (\n    pa[5] != account_id\n    or p = '*'\n  );",
          "refId": "A",
          "select": [
            [
              {
                "params": [
                  "average"
                ],
                "type": "column"
              }
            ]
          ],
          "table": "aws_rds_db_instance_metric_cpu_utilization_hourly",
          "timeColumn": "\"timestamp\"",
          "timeColumnType": "timestamp",
          "where": [
            {
              "name": "$__timeFilter",
              "params": [],
              "type": "macro"
            }
          ]
        }
      ],
      "title": "External Access Granted",
      "type": "gauge"
    },
    {
      "datasource": {
        "type": "postgres",
        "uid": "OxfC_3N4z"
      },
      "fieldConfig": {
        "defaults": {
          "mappings": [],
          "thresholds": {
            "mode": "percentage",
            "steps": [
              {
                "color": "green",
                "value": null
              },
              {
                "color": "orange",
                "value": 70
              },
              {
                "color": "red",
                "value": 85
              }
            ]
          }
        },
        "overrides": []
      },
      "gridPos": {
        "h": 8,
        "w": 5,
        "x": 5,
        "y": 8
      },
      "id": 0,
      "options": {
        "orientation": "auto",
        "reduceOptions": {
          "calcs": [],
          "fields": "",
          "values": true
        },
        "showThresholdLabels": false,
        "showThresholdMarkers": true
      },
      "pluginVersion": "9.2.2",
      "targets": [
        {
          "datasource": {
            "type": "postgres",
            "uid": "OxfC_3N4z"
          },
          "format": "table",
          "group": [],
          "metricColumn": "none",
          "rawQuery": true,
          "rawSql": "select account_id, count(*) from aws_s3_bucket group by account_id",
          "refId": "A",
          "select": [
            [
              {
                "params": [
                  "data_transfer_progress_current_rate_in_mega_bytes_per_second"
                ],
                "type": "column"
              }
            ]
          ],
          "table": "aws_redshift_clusters",
          "timeColumn": "cluster_create_time",
          "timeColumnType": "timestamp",
          "where": [
            {
              "name": "$__timeFilter",
              "params": [],
              "type": "macro"
            }
          ]
        }
      ],
      "title": "Total Bucket Count By Account ID",
      "type": "gauge"
    },
    {
      "datasource": {
        "type": "postgres",
        "uid": "OxfC_3N4z"
      },
      "fieldConfig": {
        "defaults": {
          "mappings": [],
          "thresholds": {
            "mode": "percentage",
            "steps": [
              {
                "color": "green",
                "value": null
              },
              {
                "color": "orange",
                "value": 70
              },
              {
                "color": "red",
                "value": 85
              }
            ]
          }
        },
        "overrides": []
      },
      "gridPos": {
        "h": 8,
        "w": 5,
        "x": 10,
        "y": 8
      },
      "id": 7,
      "options": {
        "orientation": "auto",
        "reduceOptions": {
          "calcs": [
            "lastNotNull"
          ],
          "fields": "",
          "values": false
        },
        "showThresholdLabels": false,
        "showThresholdMarkers": true
      },
      "pluginVersion": "9.2.2",
      "targets": [
        {
          "datasource": {
            "type": "postgres",
            "uid": "OxfC_3N4z"
          },
          "format": "table",
          "group": [],
          "metricColumn": "none",
          "rawQuery": true,
          "rawSql": "select\n  count(*)\nfrom\n  aws_s3_bucket\nwhere\n  server_side_encryption_configuration is null;",
          "refId": "A",
          "select": [
            [
              {
                "params": [
                  "average"
                ],
                "type": "column"
              }
            ]
          ],
          "table": "aws_rds_db_instance_metric_cpu_utilization_hourly",
          "timeColumn": "\"timestamp\"",
          "timeColumnType": "timestamp",
          "where": [
            {
              "name": "$__timeFilter",
              "params": [],
              "type": "macro"
            }
          ]
        }
      ],
      "title": "Default Encryption Disabled",
      "type": "gauge"
    },
    {
      "datasource": {
        "type": "postgres",
        "uid": "OxfC_3N4z"
      },
      "fieldConfig": {
        "defaults": {
          "mappings": [],
          "thresholds": {
            "mode": "percentage",
            "steps": [
              {
                "color": "green",
                "value": null
              },
              {
                "color": "orange",
                "value": 70
              },
              {
                "color": "red",
                "value": 85
              }
            ]
          }
        },
        "overrides": []
      },
      "gridPos": {
        "h": 8,
        "w": 5,
        "x": 15,
        "y": 8
      },
      "id": 11,
      "options": {
        "orientation": "auto",
        "reduceOptions": {
          "calcs": [
            "lastNotNull"
          ],
          "fields": "",
          "values": false
        },
        "showThresholdLabels": false,
        "showThresholdMarkers": true
      },
      "pluginVersion": "9.2.2",
      "targets": [
        {
          "datasource": {
            "type": "postgres",
            "uid": "OxfC_3N4z"
          },
          "format": "table",
          "group": [],
          "metricColumn": "none",
          "rawQuery": true,
          "rawSql": "select\n  count(*)\nfrom\n  aws_s3_bucket\nwhere\n  object_lock_configuration ->> 'ObjectLockEnabled' = 'Enabled';",
          "refId": "A",
          "select": [
            [
              {
                "params": [
                  "average"
                ],
                "type": "column"
              }
            ]
          ],
          "table": "aws_rds_db_instance_metric_cpu_utilization_hourly",
          "timeColumn": "\"timestamp\"",
          "timeColumnType": "timestamp",
          "where": [
            {
              "name": "$__timeFilter",
              "params": [],
              "type": "macro"
            }
          ]
        }
      ],
      "title": "Object Lock Enabled",
      "type": "gauge"
    }
  ],
  "schemaVersion": 37,
  "style": "dark",
  "tags": [
    "aws",
    "s3"
  ],
  "templating": {
    "list": [
      {
        "current": {
          "selected": true,
          "text": [
            "All"
          ],
          "value": [
            "$__all"
          ]
        },
        "datasource": {
          "type": "postgres",
          "uid": "OxfC_3N4z"
        },
        "definition": "select account_id from aws_account",
        "hide": 0,
        "includeAll": true,
        "multi": true,
        "name": "account_ids",
        "options": [],
        "query": "select account_id from aws_account",
        "refresh": 1,
        "regex": "",
        "skipUrlSync": false,
        "sort": 1,
        "type": "query"
      },
      {
        "current": {
          "selected": true,
          "text": [
            "All"
          ],
          "value": [
            "$__all"
          ]
        },
        "hide": 0,
        "includeAll": true,
        "multi": true,
        "name": "regions",
        "options": [
          {
            "selected": true,
            "text": "All",
            "value": "$__all"
          },
          {
            "selected": false,
            "text": "us-east-2",
            "value": "us-east-2"
          },
          {
            "selected": false,
            "text": "us-east-1",
            "value": "us-east-1"
          },
          {
            "selected": false,
            "text": "us-west-1",
            "value": "us-west-1"
          },
          {
            "selected": false,
            "text": "us-west-2",
            "value": "us-west-2"
          },
          {
            "selected": false,
            "text": "af-south-1",
            "value": "af-south-1"
          },
          {
            "selected": false,
            "text": "ap-east-1",
            "value": "ap-east-1"
          },
          {
            "selected": false,
            "text": "ap-south-1",
            "value": "ap-south-1"
          },
          {
            "selected": false,
            "text": "ap-northeast-3",
            "value": "ap-northeast-3"
          },
          {
            "selected": false,
            "text": "ap-northeast-2",
            "value": "ap-northeast-2"
          },
          {
            "selected": false,
            "text": "ap-southeast-1",
            "value": "ap-southeast-1"
          },
          {
            "selected": false,
            "text": "ap-southeast-2",
            "value": "ap-southeast-2"
          },
          {
            "selected": false,
            "text": "ap-northeast-1",
            "value": "ap-northeast-1"
          },
          {
            "selected": false,
            "text": "ca-central-1",
            "value": "ca-central-1"
          },
          {
            "selected": false,
            "text": "eu-central-1",
            "value": "eu-central-1"
          },
          {
            "selected": false,
            "text": "eu-west-1",
            "value": "eu-west-1"
          },
          {
            "selected": false,
            "text": "eu-west-2",
            "value": "eu-west-2"
          },
          {
            "selected": false,
            "text": "eu-south-1",
            "value": "eu-south-1"
          },
          {
            "selected": false,
            "text": "eu-west-3",
            "value": "eu-west-3"
          },
          {
            "selected": false,
            "text": "eu-north-1",
            "value": "eu-north-1"
          },
          {
            "selected": false,
            "text": "me-south-1",
            "value": "me-south-1"
          },
          {
            "selected": false,
            "text": "sa-east-1",
            "value": "sa-east-1"
          }
        ],
        "query": "us-east-2,us-east-1,us-west-1,us-west-2,af-south-1,ap-east-1,ap-south-1,ap-northeast-3,ap-northeast-2,ap-southeast-1,ap-southeast-2,ap-northeast-1,ca-central-1,eu-central-1,eu-west-1,eu-west-2,eu-south-1,eu-west-3,eu-north-1,me-south-1,sa-east-1",
        "queryValue": "",
        "skipUrlSync": false,
        "type": "custom"
      }
    ]
  },
  "time": {
    "from": "now-6h",
    "to": "now"
  },
  "timepicker": {},
  "timezone": "",
  "title": "AWS S3",
  "uid": "aws_s3_json",
  "version": 1,
  "weekStart": ""
}
```
</details>

<div style={{"marginTop":"1em", "marginBottom":"1em", "width":"90%"}}>
<img src="/images/docs/cloud/grafana-aws-s3-dashboard.png" />
</div>

## Send alerts

Suppose you'd like to be notified when the CPU utilization crosses a threshold value. You can use Grafana's `Alerting` feature to create an `Alert Rule` with this query and expression to evaluate the threshold value.

```
select
  "timestamp" AS "time",
  average
from aws_ec2_instance_metric_cpu_utilization_hourly
where
  $__timeFilter("timestamp")
order by 1
```

<div style={{"marginTop":"1em", "marginBottom":"1em", "width":"90%"}}>
<img src="/images/docs/cloud/grafana-alerting-rules.png" />
</div>

You can set up [Contact-points](https://grafana.com/docs/grafana/latest/alerting/contact-points/) to send alert notifications. Grafana evaluates the set criteria and fires alerts.

<div style={{"marginTop":"1em", "marginBottom":"1em", "width":"50%"}}>
<img src="/images/docs/cloud/grafana-slack-alert.png" />
</div>

## Summary

With Metabase and Steampipe Cloud you can:

- Create interactive dashboards driven by data from the tables and queries in your Steampipe Cloud workspace

- Send query-driven alerts