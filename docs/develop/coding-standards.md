---
title: Coding Standards
sidebar_label: Coding Standards
---

# Coding Standards

## Code Formatting

Code should be formatted with <a href="https://golang.org/cmd/gofmt/" target="_blank" rel="noopener noreferrer">gofmt</a>.


## Comments
- Code "sections" are broken up by comments that start with 4 slashes, so that the code editors don't fold them.  The section name should be uppercase.
  - Example: `//// HYDRATE FUNCTIONS`

- All public functions/structs etc should have a comment per the standard recommended in the <a href="https://golang.org/doc/effective_go.html#commentary" target="_blank" rel="noopener noreferrer">go docs</a>:
> "Doc comments work best as complete sentences, which allow a wide variety of automated presentations. The first sentence should be a one-sentence summary that starts with the name being declared.":
  ```go
  // Install installs a plugin in the local file system
  func Install(image string) (string, error) {
  ...
  ```
- Add the package comment to the `plugin.go` file, per the <a href="https://golang.org/doc/effective_go.html#commentary" target="_blank" rel="noopener noreferrer">go docs</a>:
> "Every package should have a package comment, a block comment preceding the package clause. For multi-file packages, the package comment only needs to be present in one file, and any one will do. The package comment should introduce the package and provide information relevant to the package as a whole. It will appear first on the godoc page and should set up the detailed documentation that follows."


## Repo Structure

Each plugin should reside in a separate Github repository, named `steampipe-plugin-{plugin name}`.  The repo should contain:
- `README.md`
- `LICENSE`
- `main.go`
- A folder, named for the plugin, that contains the go files, including:
    - `plugin.go`
    - A `.go` source file for each table. Go files that implement a table should be prefixed with `table_`.
    - Any other go files required for your plugin package
    - Shared functions should be added to a `utils.go` file

- A `docs` folder that contains the documentation for your plugin in markdown format. These documents are used to create the online documentation at hub.steampipe.io.  The folder should contain:
    - An `index.md` that describes the plugin, how to set it up and use it, any prerequisites, and config options.
    - A subfolder called `tables`.  This folder should contain a file per table named `{table_name}.md` with example queries for that table.
- A `config` folder that contains the default connection config file for the plugin.

### Example: Repo Structure
```bash
.
├── LICENSE
├── Makefile
├── README.md
├── aws
│   ├── plugin.go
│   ├── service.go
│   ├── table_aws_acm_certificate.go
│   ├── table_aws_api_gateway_api_authorizer.go
│   ├── table_aws_api_gateway_api_key.go
│   ...
│   └── utils.go
├── config
│   └── aws.spc
├── docs
│   ├── index.md
│   └── tables
│       ├── aws_acm_certificate.md
│       ├── aws_api_gateway_api_authorizer.md
│       ├── aws_api_gateway_api_key.md
│       ...
├── go.mod
├── go.sum
└── main.go
```
