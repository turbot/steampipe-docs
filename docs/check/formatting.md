---
title: Formatting Output
sidebar_label: Formatting Output
---

# Formatting Output

> ***Powerpipe is now the recommended way to run dashboards and benchmarks!***
> Mods still work as normal in Steampipe for now, but they are deprecated and will be removed in a future release:
> - [Steampipe Unbundled →](https://steampipe.io/blog/steampipe-unbundled)
> - [Powerpipe for Steampipe users →](https://powerpipe.io/blog/migrating-from-steampipe)

By default, Steampipe shows a progress bar, and produces colorized output to the console screen.  Steampipe provides many options to control the output formatting.


By default, the console output uses 'dark mode' colors, but you can use 'light mode' if you prefer:
```bash
steampipe check benchmark.cis_v130 --theme=light
```

If you run steampipe from a CI tool or batch scheduler, you may want to use non-colorized output and disable the progress bar:
```bash
steampipe check all --theme=plain --progress=false
```

Some benchmarks are quite verbose.  To show only the items that are in alarm or error, use `brief` output:
```bash
steampipe check all --output=brief
```

You can also export the full output to JSON:
```bash
steampipe check all --export=json
```

Or CSV:
```bash
steampipe check all --export=csv
```

Or markdown:
```bash
steampipe check all --export=md
```


Or html:
```bash
steampipe check all --export=html
```


Or multiple formats:
```bash
steampipe check all --export=csv --export=json --export=html
```

You can export to a filename of your choosing - steampipe will infer the output type by the file extension:
```bash
steampipe check all --export=output.csv --export=output.json --export=output.md
```

You can also send JSON output to stdout, if you want to redirect it to a file or pipe it to another program:
```bash
steampipe check all --progress=false --output=json | jq
```

Steampipe even allows you to [write your own control output templates!](develop/writing-control-output-templates).
