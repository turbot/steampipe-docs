---
title: Install
sidebar_label: Install
---

# Installing Steampipe Postgres FDW

Each Steampipe plugin is distributed as a distinct Steampipe Postgres FDW.  They are available for download in the **Releases** for the corresponding plugin repo, however it is simplest to install them with the [Steampipe Postgres FDW install script](https://steampipe.io/install/postgres.sh):

```bash
/bin/sh -c "$(curl -fsSL https://steampipe.io/install/postgres.sh)"
```

The installer will prompt you for the plugin name and version, determine the OS, system architecture, and Postgres version, and download the appropriate package.  It will use `pg_config` determine where to install the files, prompt for confirmation, and then copy them:

```bash
$ /bin/sh -c "$(curl -fsSL https://steampipe.io/install/postgres.sh)"
Enter the plugin name: aws
Enter the version (latest): 

Discovered:
- PostgreSQL version:   15
- PostgreSQL location:  /Applications/Postgres.app/Contents/Versions/15
- Operating system:     Darwin
- System architecture:  arm64

Based on the above, steampipe_postgres_aws.pg15.darwin_arm64.tar.gz will be downloaded, extracted and installed at: /Applications/Postgres.app/Contents/Versions/15

Proceed with installing Steampipe PostgreSQL FDW for version 15 at /Applications/Postgres.app/Contents/Versions/15?
- Press 'y' to continue with the current version.
- Press 'n' to customize your PostgreSQL installation directory and select a different version. (Y/n): 

Downloading https://api.github.com/repos/turbot/steampipe-plugin-aws/releases/latest/releases/assets/139269139...
###################################################################################################################################################################### 100.0%
x steampipe_postgres_aws.pg15.darwin_arm64/
x steampipe_postgres_aws.pg15.darwin_arm64/steampipe_postgres_aws.so
x steampipe_postgres_aws.pg15.darwin_arm64/create_extension_aws.sql
x steampipe_postgres_aws.pg15.darwin_arm64/install.sh
x steampipe_postgres_aws.pg15.darwin_arm64/steampipe_postgres_aws--1.0.sql
x steampipe_postgres_aws.pg15.darwin_arm64/steampipe_postgres_aws.control

Download and extraction completed.

Installing steampipe_postgres_aws in /Applications/Postgres.app/Contents/Versions/15...

Successfully installed steampipe_postgres_aws extension!

Files have been copied to:
- Library directory: /Applications/Postgres.app/Contents/Versions/15/lib/postgresql
- Extension directory: /Applications/Postgres.app/Contents/Versions/15/share/postgresql/extension/
```


If you don't want to use the installer, you can download, extract, and install the files yourself. There are downloadable `tar.gz` packages for all platforms available in the **Releases** for the corresponding plugin's Github repo (e.g. https://github.com/turbot/steampipe-plugin-aws/releases).

The `tar.gz` includes an `install.sh` script that you can run to install files, or you can copy them manually:
```
export LIBDIR=$(pg_config --pkglibdir)
export EXTDIR=$(pg_config --sharedir)/extension/

sudo cp steampipe*.so $LIBDIR
sudo cp steampipe*.sql $EXTDIR
sudo cp steampipe*.control $EXTDIR
```