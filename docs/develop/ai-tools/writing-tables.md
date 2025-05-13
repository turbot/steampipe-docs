---
title: Writing Tables
sidebar_label: Writing Tables
---

# Writing Tables

When creating a new table, we have included some prompts below that you can use with your AI tools.

First, create the table:

```
Can you please create me a new table for `aws_cloudfront_vpc_origin`? Please create a new file for the table in `aws/` and a doc for it in `docs/tables/`.

After creating the table, can you please verify the code compiles by running `make dev`?

For this prompt and all future ones, if you have any questions, please ask me before proceeding.
```

Then, create resources using the service's CLI or with direct API calls to test queries:

```
Next, can you please create a resource using the AWS CLI with as many properties included as possible for testing?

If you need to create additional resources as dependencies, please create them too.

Please use the AWS CLI to verify the resource was created correctly.
```

Verify the table data is correct:

```
Next, use the Steampipe MCP server to query the created resource with `select * from ...` and verify all column data is returned and that the column data have the correct types.
```

Test the example queries in the docs:

```
Next, can you please run all Postgres example queries and share the results here in raw Markdown format?
```

Finally, cleanup:

```
Can you please cleanup any resources you created as part of testing and verify they were deleted with the AWS CLI?
```