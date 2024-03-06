---
title: View Dashboards
sidebar_label: View Dashboards
---


# Steampipe Dashboards

> ***Powerpipe is now the recommended way to run dashboards and benchmarks!***
> Mods still work as normal in Steampipe for now, but they are deprecated and will be removed in a future release:
> - [Steampipe Unbundled →](https://steampipe.io/blog/steampipe-unbundled)
> - [Powerpipe for Steampipe users →](https://powerpipe.io/blog/migrating-from-steampipe)
> - [Powerpipe for Steampipe users →](https://powerpipe.io/blog/migrating-from-steampipe)


Steampipe **dashboards** provide rich visualizations of Steampipe data.  Dashboards are [written in simple HCL](/docs/reference/mod-resources/dashboard), and packaged in [mods](/docs/mods/overview).  It is simple to [create your own](mods/writing-dashboards), but there are also hundreds of dashboards available on the [Steampipe Mods](https://hub.steampipe.io/mods) section of the [Steampipe Hub](https://hub.steampipe.io).  


You can start the dashboard server and view dashboards with the [steampipe dashboard](/docs/reference/cli/dashboard) command.  Dashboards must be packaged in a mod, and Steampipe looks for dashboards in the current directory by default.  


To view the AWS Insights dashboards, for example, first clone the repo, then change to that directory, then run the `steampipe dashboard` command:

```bash
git clone https://github.com/turbot/steampipe-mod-aws-insights.git
cd steampipe-mod-aws-insights
steampipe dashboard
```


Steampipe will start the dashboard server and will open http://localhost:9194/ in your web browser to view the dashboards in the mod. 
<img src="/images/docs/dashboard_home.png" width="100%" />



The home page lists the available dashboards, and is searchable by title or tags.  By default, the dashboards are grouped by Category, but you may select another grouping if you prefer.


Click on the title of a report to view it.  For example, click the `AWS CloudTrail Trail Dashboard` to view it.

<img src="/images/docs/cloudtrail_dash_ex.png" width="100%" />

You can type in the search bar at the top of any page to navigate to another dashboard.  Alternately, you can click the Steampipe logo in the top left to return to the home page.  When you are finished, you can return to the terminal console and type `Ctrl+c` to exit.
