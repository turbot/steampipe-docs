---
title: Install
sidebar_label: Install
---

# Installing Steampipe Steampipe Export CLIs

Each Steampipe plugin is distributed as a distinct Steampipe Export CLI.  They are available for download in the **Releases** for the corresponding plugin repo, however it is simplest to install them with the [Steampipe Export CLI install script](https://steampipe.io/install/export.sh):  

<!--
```bash
Usage: global_installer.sh <plugin> [version] [location]
```
-->
```bash
/bin/sh -c "$(curl -fsSL https://steampipe.io/install/export.sh)"
```


The installer will prompt you for the plugin name, version, and destination directory.  It will then determine the OS and system architecture, and it will download and install the appropriate package.  

```bash
Enter the plugin name: aws
Enter the version (latest): 
Enter location (/usr/local/bin): 
Created temporary directory at /var/folders/t4/1lm46wt12sv7yq1gp1swn3jr0000gn/T/tmp.RpZLlzs2.

Downloading steampipe_export_aws.darwin_arm64.tar.gz...
###################################################################################################################################################################### 100.0%
Warning: Got more output options than URLs
Deflating downloaded archive
x steampipe_export_aws
Installing
Applying necessary permissions
Removing downloaded archive
steampipe_export_aws was installed successfully to /usr/local/bin
```

The installer will find the appropriate package and download it to the specified directory.

If you don't want to use the installer, you can download, extract, and install the file yourself. There are downloadable `tar.gz` packages for all platforms available in the **Releases** for the corresponding plugin's Github repo (e.g. https://github.com/turbot/steampipe-plugin-aws/releases).