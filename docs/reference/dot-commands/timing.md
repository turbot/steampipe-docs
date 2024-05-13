---
title: .timing
sidebar_label: .timing
---

# .timing

Enable or disable query execution timing:


| Level     | Description
|-----------|-------------------------
| `off`     | Turn off query timer (default)
| `on`      | Display time elapsed after every query
| `verbose` | Display time elapsed and details of each scan


## Usage
```
.timing [on | off | verbose]
```

## Examples

Turn off query timing:
```
.timing off
```

Turn on query timing:
```
.timing on
```

Turn on verbose query timing:
```
.timing verbose
```