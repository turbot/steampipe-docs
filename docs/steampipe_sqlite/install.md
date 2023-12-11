---
title: Install
sidebar_label: Install
---


# Installing Steampipe SQLite Extensions

Each Steampipe plugin is distributed as a distinct Steampipe SQLite Extension.  They are available for download in the **Releases** for the corresponding plugin repo, however it is simplest to install them with the [Steampipe SQLite install script](https://steampipe.io/install/sqlite.sh):  


```bash
/bin/sh -c "$(curl -fsSL https://steampipe.io/install/sqlite.sh)"
```
<!--
```bash
Usage: global_installer.sh <plugin> [version] [location]
```
-->

The installer will prompt you for the plugin name, version, and destination directory.  It will then determine the OS and system architecture, and it will download and install the appropriate package.  


```bash
Enter the plugin name: github
Enter version (latest): 
Enter location (current directory): 

Downloading steampipe_sqlite_github.darwin_arm64.tar.gz...
###################################################################################################################################################################### 100.0%
x steampipe_sqlite_github.so

steampipe_sqlite_github.darwin_arm64.tar.gz downloaded and extracted successfully at /Users/jsmyth/src/steampipe_anywhere/sqlite.
```

The installer will find the appropriate extension (packaged as a `.so` file) and download it to the current directory.

If you don't want to use the installer, you can download, extract, and install the file yourself. There are downloadable `tar.gz` packages for all platforms available in the **Releases** for the corresponding plugin's Github repo (e.g. https://github.com/turbot/steampipe-plugin-aws/releases).