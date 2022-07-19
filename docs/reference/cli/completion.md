---
title: steampipe completion
sidebar_label: steampipe completion
---


## steampipe completion
Generate the autocompletion script for `steampipe` for supported shells. This helps you configure your terminal’s shell so that `steampipe` commands autocomplete when you press the TAB key.

### Usage
```bash
steampipe completion [bash|fish|zsh]
```

### Sub-Commands

| Command | Description
|-|-
| `bash` | Generate completion code for `bash`
| `fish` | Generate completion code for `fish`
| `zsh`  | Generate completion code for `zsh`

### steampipe completion bash
Generate the autocompletion script for the `bash` shell.

#### Pre-requisites
This script depends on the `bash-completion` package. If it is not installed already, you can install it via your OS’s package manager.  

Most Linux distributions have bash-completion installed by default, however it is not installed by default in Mac OS.  For example, to install the [bash-completion package with homebrew](https://formulae.brew.sh/formula/bash-completion@2):

```bash
brew install bash-completion
```
Once installed, edit your `.bash_profile` or `.bashrc` file and add the following line:
```bash
[[ -r "$(brew --prefix)/etc/profile.d/bash_completion.sh" ]] && . "$(brew --prefix)/etc/profile.d/bash_completion.sh"

```
<!--
source $(brew --prefix)/etc/bash_completion
-->
#### Examples

Review the configuration:

```bash
steampipe completion bash
```


Enable auto-complete in your current shell session: 
```
source <(steampipe completion bash)
```

Enable auto-complete for every new session (execute once).  You will need to start a new shell for this setup to take effect:

Linux: 
```bash
steampipe completion bash > /etc/bash_completion.d/steampipe
```

MacOS: 
```bash
steampipe completion bash > /usr/local/etc/bash_completion.d/steampipe
```


### steampipe completion fish

Generate the autocompletion script for the `fish` shell.

#### Examples

Review the configuration:

```bash
steampipe completion fish
```

Enable auto-complete in your current shell session: 
```bash
steampipe completion fish | source
```

Enable auto-complete for every new session (execute once).  You will need to start a new shell for this setup to take effect:

```bash
steampipe completion fish > ~/.config/fish/completions/steampipe.fish
```


### steampipe completion zsh

Generate the autocompletion script for the `zsh` shell.

#### Pre-requisites

If shell completion is not enabled in your environment, you will need to enable it using:

```bash
echo "autoload -U compinit; compinit" >> ~/.zshrc
```

You will need to start a new shell for this setup to take effect.


#### Examples

Review the configuration:

```bash
steampipe completion zsh
```

Enable auto-complete for every new session (execute once).  You will need to start a new shell for this setup to take effect:
```bash
steampipe completion zsh > "${fpath[1]}/steampipe"
```
