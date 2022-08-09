---
title:  Connect to Steampipe Cloud with pgcli
sidebar_label: pgcli
---
# Connect to Steampipe Cloud with pgcli

Since your Steampipe Cloud workspace is just a PostgreSQL database, you can use `pgcli` to query your workspace database.

The **Connect** tab for your workspace will provide the command, including Postgres connection string for your workspace.  

<div style={{"borderWidth":"thin", "borderStyle":"solid", "borderColor":"lightgray", "padding":"12px", "marginTop":"1em", "marginBottom":"1em", "width":"90%"}}>
<img src="/images/docs/cloud/int_psql_pgcli.png" width="90%"/>
</div>

Note that the connection string includes your password.  It is masked in the web console display, but you can hover over the command and click the clipboard icon to copy it so you can paste it into your terminal.

<div style={{"borderWidth":"thin", "borderStyle":"solid", "borderColor":"lightgray", "padding":"12px", "marginTop":"1em", "marginBottom":"1em", "width":"90%"}}>
<img src="/images/docs/cloud/int_pgcli.png"/>
</div>


