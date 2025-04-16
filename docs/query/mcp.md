---
title: AI Tools (MCP)
---

# AI Tools (MCP)

The [Tailpipe MCP server](https://github.com/turbot/tailpipe-mcp) (Model Control Protocol) transforms how you interact with your cloud infrastructure data.  It brings the power of conversational AI to your cloud resources and configurations, allowing you to extract critical insights using plain English — no complex SQL required!

The Steampipe [MCP](https://modelcontextprotocol.io/introduction) enables Large Language Models (LLMs) to query your Steampipe data directly. This allows you to query your cloud infrastructure using natural language, making data exploration and analysis more intuitive and accessible.  It works with both local [Steampipe](https://steampipe.io/downloads) installations and [Turbot Pipes](https://turbot.com/pipes) workspaces, providing safe, read-only access to all your cloud and SaaS data.

The MCP is packaged separately and runs as an integration in your AI tool, such as [Claude Desktop](https://claude.ai/download) or [Cursor](https://www.cursor.com/).

## Installation

### Prerequisites

- [Steampipe](https://steampipe.io/downloads) installed and configured
- [Node.js](https://nodejs.org/) v16 or higher (includes `npx`)
- An AI assistant that supports [MCP](https://modelcontextprotocol.io/introduction), such as [Cursor](https://www.cursor.com/) or Anthropic's [Claude Desktop](https://claude.ai/download).

### Configuration

The Steampipe MCP server is packaged and distributed as an NPM package; just add Steampipe MCP to your AI assistant's configuration file and restart your AI assistant for the changes to take effect:

```json
{
  "mcpServers": {
    "steampipe": {
      "command": "npx",
      "args": [
        "-y",
        "@turbot/steampipe-mcp"
      ]
    }
  }
}
```

By default, this connects to your local Steampipe installation at `postgresql://steampipe@localhost:9193/steampipe`. Make sure to run `steampipe service start` first.

To connect to a [Turbot Pipes](https://turbot.com/pipes) workspace instead, add your [connection string](https://turbot.com/pipes/docs/using/steampipe/developers#database) to the args:

```json
{
  "mcpServers": {
    "steampipe": {
      "command": "npx",
      "args": [
        "-y",
        "@turbot/steampipe-mcp",
        "postgresql://my_name:my_pw@workspace-name.usea1.db.pipes.turbot.com:9193/abc123"
      ]
    }
  }
}
```


| Assistant | Config File Location | Setup Guide |
|-----------|---------------------|-------------|
| Claude Desktop | `claude_desktop_config.json` | [Claude Desktop MCP Guide →](https://modelcontextprotocol.io/quickstart/user) |
| Cursor | `~/.cursor/mcp.json` | [Cursor MCP Guide →](https://docs.cursor.com/context/model-context-protocol) |

Refer to the [README](https://github.com/turbot/steampipe-mcp/blob/main/README.md) for additional configuration options.


## Querying Steampipe

To query Steampipe, just ask questions using natural language!

Explore your cloud infrastructure:
```
What AWS accounts can you see?
```

Simple, specific questions work well:
```
Show me all S3 buckets that were created in the last week
```

Generate infrastructure reports:
```
List my EC2 instances with their attached EBS volumes
```

Dive into security analysis:
```
Find any IAM users with access keys that haven't been rotated in the last 90 days
```

Get compliance insights:
```
Show me all EC2 instances that don't comply with our tagging standards
```

Explore potential risks:
```
Analyze my S3 buckets for security risks including public access, logging, and encryption
```

## Best Practices for Prompts

To get the most accurate and helpful responses from the MCP service, consider these best practices when formulating your prompts:

1. **Use natural language**: The LLM will handle the SQL translation
2. **Be specific**: Indicate which cloud resources you want to analyze (EC2, S3, IAM, etc.)
3. **Include context**: Mention regions or accounts if you're interested in specific ones
4. **Ask for explanations**: Request the LLM to explain its findings after presenting the data
5. **Iterative refinement**: Start with simple queries and then refine based on initial results
6. **Be bold and exploratory**:  It's amazing what the LLM will discover and achieve!

## Limitations

- The quality of SQL generation depends on the LLM's understanding of your prompt and the Steampipe schema.
- Complex analytical queries may require iterative refinement.
- Response times depend on both the LLM API latency and query execution time.
- The MCP server only runs locally at this time.  You must run it from the same machine as your AI assistant.
- A valid subscription to the LLM provider is recommended; free plan limits are often insufficient for using the Steampipe MCP server.