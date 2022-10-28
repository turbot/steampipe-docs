---
title: .multi
sidebar_label: .multi
---

# .multi
Enable or disable multi-line mode.  

Multi-line mode is off by default, and queries will be executed as soon as you hit the `Enter` key.  

Enabling multi-line mode mode allows you to write long queries that span multiple lines.  The query will not be executed when you press `Enter` unless it ends with a semi-colon.            

## Usage
```
.multi [on | off]
```

## Examples

Turn off multi-line mode:
```
.multi off
```

Turn on multi-line mode:
```
.multi on
```