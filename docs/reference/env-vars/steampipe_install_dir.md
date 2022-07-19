---
title: STEAMPIPE_INSTALL_DIR
sidebar_label: STEAMPIPE_INSTALL_DIR
---

### STEAMPIPE_INSTALL_DIR
Sets the directory for the steampipe installation, in which the Steampipe database, plugins, and supporting files can be found.

Steampipe is distributed as a single binary - when you install Steampipe, either via `brew install` or via the `curl` script, the `steampipe` binary is installed into your path.  The first time that you run Steampipe, it will download and install the embedded database, foreign data wrapper extension, and other required files.   By default, these files are installed to `~/.steampipe`, however you can change this location with the `STEAMPIPE_INSTALL_DIR` environment variable or the `--install-dir` command line argument.

Steampipe will read the `STEAMPIPE_INSTALL_DIR` variable each time it runs; if it's not set, Steampipe will use the default path (`~/.steampipe`). If you wish to **ALWAYS** run Steampipe from the alternate path, you should set your environment variable in a way that will persist across sessions (in your `.profile` for example).

To install a new Steampipe instance into an alternate path, simply specify the path in `STEAMPIPE_INSTALL_DIR` and then run a `steampipe` command (alternatively, use the `--install-dir` argument).  If the specified directory is empty or files are missing, Steampipe will install and update the database and files to `STEAMPIPE_INSTALL_DIR`.  If the directory does not exist, Steampipe will create it.  

It is possible to have multiple, parallel steampipe instances on a given machine using `STEAMPIPE_INSTALL_DIR` as long as they are running on a different port.



#### Usage 
Set the STEAMPIPE_INSTALL_DIR to `~/mypath`.  You will likely want to set this in your `.profile`.
```bash
export STEAMPIPE_INSTALL_DIR=~/mypath
```
