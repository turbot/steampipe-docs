---
title: Using Containers
sidebar_label: Using Containers
---

# Using Containers

Turbot provides a container image with Steampipe installed.  This image is
based on debian-slim, and is a minimal install of Steampipe, including the
`steampipe` binary and the embedded database.

The image is published to Github Container Registry:
```bash
docker pull ghcr.io/turbot/steampipe:latest
```


## Running locally, in lieu of "standard" steampipe install

To run steampipe, you can simply run the container:
```bash
docker run -it --rm --name steampipe ghcr.io/turbot/steampipe:latest
```

The base docker image has no plugins installed however.  Since you likely need to install plugins and configure them for your environment, you will *minimally* want to mount the config and plugins directories to persistent storage.  You'll probably want to alias the command:

```bash
# create a directory for the config files
mkdir -p $HOME/sp/config

# alias the command
alias sp="docker run \
  -it \
  --rm \
  --name steampipe \
  --mount type=bind,source=$HOME/sp/config,target=/home/steampipe/.steampipe/config  \
  --mount type=volume,source=steampipe_plugins,target=/home/steampipe/.steampipe/plugins   \
  ghcr.io/turbot/steampipe"
```

The container entrypoint is the `steampipe` command, so once you've set up an alias, you can effectively run the same commands.  You can install plugins:
```bash
sp plugin install steampipe aws
```
```bash
Installed plugin: steampipe v0.1.2
Documentation:    https://hub.steampipe.io/plugins/turbot/steampipe

Installed plugin: aws v0.25.0
Documentation:    https://hub.steampipe.io/plugins/turbot/aws
```

You can run `steampipe query`:
```bash
sp query
```
```bash
Welcome to Steampipe v0.7.0-rc.0
For more information, type .help
> 
> select * from steampipe_registry_plugin limit 5
> +----------------+---------------------+---------------------+
| name           | create_time         | update_time         |
+----------------+---------------------+---------------------+
| turbot/gcp     | 2021-01-21 13:51:19 | 2021-07-08 19:54:15 |
| turbot/github  | 2021-01-21 14:40:16 | 2021-06-06 01:28:50 |
| turbot/stripe  | 2021-07-12 20:43:23 | 2021-07-12 20:44:08 |
| turbot/turbot  | 2021-05-28 01:52:20 | 2021-05-28 02:35:48 |
| turbot/twitter | 2021-04-03 13:37:39 | 2021-04-03 13:38:30 |
+----------------+---------------------+---------------------+
> .quit

```

You will probably also want to persist:
- The `internal` directory (`/home/steampipe/.steampipe/internal`) so that your history is persisted between query sessions
- The postgres `data` directory (`/home/steampipe/.steampipe/db/14.2.0/data`) so that anything in the database (particularly, things you may create in the public schema) persists
-  The`logs` directory (`/home/steampipe/.steampipe/logs`) so that logs persist and can be reviewed when troubleshooting

If you are using the aws plugin, you many also want to map your credentials file to the image so that steampipe can use your aws profiles.

```bash

mkdir -p $HOME/sp/config
mkdir -p $HOME/sp/logs

alias sp="docker run \
  -it \
  --rm \
  --name steampipe \
  --mount type=bind,source=$HOME/sp/config,target=/home/steampipe/.steampipe/config  \
  --mount type=bind,source=$HOME/sp/logs,target=/home/steampipe/.steampipe/logs   \
  --mount type=bind,source=$HOME/.aws,target=/home/steampipe/.aws \
  --mount type=volume,source=steampipe_data,target=/home/steampipe/.steampipe/db/14.2.0/data \
  --mount type=volume,source=steampipe_internal,target=/home/steampipe/.steampipe/internal \
  --mount type=volume,source=steampipe_plugins,target=/home/steampipe/.steampipe/plugins   \
  ghcr.io/turbot/steampipe"
```


## Running a batch job with derived image

You may want to run steampipe in a batch job, either from a scheduler such as cron, or as part of a continuous integration workflow.  In such a case you may want to create your own image based on the steampipe standard image, with plugins and mods pre-installed. 

For example:
```dockerfile
FROM ghcr.io/turbot/steampipe

# Setup prerequisites (as root)
USER root:0
RUN apt-get update -y \
 && apt-get install -y git

# Install the aws and steampipe plugins for Steampipe (as steampipe user).
USER steampipe:0
RUN  steampipe plugin install steampipe aws

# A mod may be installed to a working directory
RUN  git clone --depth 1 https://github.com/turbot/steampipe-mod-aws-compliance.git /workspace
WORKDIR /workspace
```

When running, you may want to pass credentials via environment variables, and mount a local directory to which to export the output:

```bash 
# build it 
docker build -t steampipe-aws-compliance .

# run it
docker run \
  -it \
  --rm \
  -e AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY \
  -e AWS_REGION=us-east-1 \
  -e AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID \
  --name steampipe-compliance \
  --mount type=bind,source="${PWD}",target=/output \
   steampipe-aws-compliance check benchmark.cis_v140_2_1 --export /output/myoutput.json
```


## Running a Steampipe dashboard using a derived image
It is possible to serve your own dashboard server using `ghcr.io/turbot/steampipe` as a base image for your container images. 

For example:
```dockerfile
FROM ghcr.io/turbot/steampipe
# Setup prerequisites (as root)
USER root:0
RUN apt-get update -y \
 && apt-get install -y git
# Install the aws and steampipe plugins for Steampipe (as steampipe user).
USER steampipe:0
RUN  steampipe plugin install steampipe aws
RUN  git clone --depth 1 https://github.com/turbot/steampipe-mod-aws-insights.git /workspace
WORKDIR /workspace
CMD ["steampipe", "service", "start", "--foreground", "--dashboard", "--dashboard-listen=network"]
```
Build the `Dockerfile` using:
```bash
# build it 
docker build -t steampipe-aws-insights .
```
When running, you may want to pass credentials via environment variables and also map the dashboard server port (`9194`) to a port in the system.
```bash 
# run it
docker run \
  -it \
  --rm \
  -p 9194:9194 \
  -e AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY \
  -e AWS_REGION=us-east-1 \
  -e AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID \
  --name steampipe-insights \
  steampipe-aws-insights
```

## Running Steampipe DB as a service
You can run steampipe in daemon mode (with `-d`) to run the database as a background service.  Exposing the database port (9193) allows you to connect to the instance with 3rd party tools. 
For example:

```bash
mkdir -p $HOME/sp/config

docker run \
  -p 9193:9193 \
  -d \
  --name steampipe \
  --mount type=bind,source=$HOME/sp/config,target=/home/steampipe/.steampipe/config  \
  --mount type=volume,source=steampipe_data,target=/home/steampipe/.steampipe/db/14.2.0/data \
  --mount type=volume,source=steampipe_internal,target=/home/steampipe/.steampipe/internal \
  --mount type=volume,source=steampipe_logs,target=/home/steampipe/.steampipe/logs   \
  --mount type=volume,source=steampipe_plugins,target=/home/steampipe/.steampipe/plugins   \
  ghcr.io/turbot/steampipe service start --foreground

```


Once the container is running, you can install plugins via `docker exec`:
```bash
docker exec -it steampipe steampipe plugin install aws whois
```

You can also run `steampipe query` from the container via `docker exec`:
```bash
docker exec -it steampipe steampipe query

Welcome to Steampipe v0.7.0-rc.0
For more information, type .help

> .inspect
+------------+--------------------------------------------------+
| connection | plugin                                           |
+------------+--------------------------------------------------+
| aws        | hub.steampipe.io/plugins/turbot/aws@latest       |
| public     |                                                  |
| whois      | hub.steampipe.io/plugins/turbot/whois@latest     |
+------------+--------------------------------------------------+

To get information about the tables in a connection, run .inspect {connection}
To get information about the columns in a table, run .inspect {connection}.{table}

  > .quit
```


You can start and stop the container with docker commands as you would expect
```
$ docker stop steampipe
steampipe
$ docker start steampipe
steampipe
```


If you have exposed port 9193, you can connect via 3rd party tools.  You can run `docker logs` to get the connection string:
```bash
$ docker logs steampipe

Steampipe database service is now running:

	Host(s):  localhost, 127.0.0.1, 172.17.0.2
	Port:     9193
	Database: steampipe
	User:     steampipe
	Password: adcd-ef12-3456
	SSL:      on

Connection string:

	postgres://steampipe:adcd-ef12-3456@localhost:9193/steampipe?sslmode=require

Managing Steampipe service:

	# Get status of the service
	steampipe service status
	
	# Restart the service
	steampipe service restart

	# Stop the service
	steampipe service stop
	

Hit Ctrl+C to stop the service
```

And then connect with your 3rd party tool:
```bash
$ pgcli "postgres://steampipe:adcd-ef12-3456@localhost:9193/steampipe?sslmode=require"
Server: PostgreSQL 12.1
Version: 3.1.0
Chat: https://gitter.im/dbcli/pgcli
Home: http://pgcli.com

steampipe> 
```

It is possible to run the steampipe container with a read-only root filesystem, but note the following:
  - `/tmp` must be writable (mount with tmpfs)
  - internal (`/home/steampipe/.steampipe/internal`) must be writable
  - logs (`/home/steampipe/.steampipe/logs`) must be writable
  - data (`/home/steampipe/.steampipe/db/14.2.0/data`) must be writable
  - config (`/home/steampipe/.steampipe/config `) must be writable if you need to install plugins (if you create your own image with config and plugins preinstalled, this can be read only)
  - plugins (`/home/steampipe/.steampipe/plugins`) must be writable if you need to install plugins (if you create your own image with config and plugins preinstalled, this can be read only)

```bash
mkdir -p $HOME/sp/config

docker run \
  -p 9193:9193 \
  -d \
  --name steampipe \
  --read-only \
  --mount type=bind,source=$HOME/sp/config,target=/home/steampipe/.steampipe/config  \
  --mount type=volume,source=steampipe_data,target=/home/steampipe/.steampipe/db/14.2.0/data \
  --mount type=volume,source=steampipe_internal,target=/home/steampipe/.steampipe/internal \
  --mount type=volume,source=steampipe_logs,target=/home/steampipe/.steampipe/logs   \
  --mount type=volume,source=steampipe_plugins,target=/home/steampipe/.steampipe/plugins   \
  --mount type=tmpfs,destination=/tmp \
  ghcr.io/turbot/steampipe service start --foreground
```

## Password management
By default, Steampipe creates a random, unique password for the `steampipe` user and writes it to `/home/steampipe/.steampipe/internal/.passwd`.  This file has been removed from the docker image so that the steampipe database password will be unique for each installation.

When the steampipe service starts and the `.passwd` file is missing, a new unique, random password will be generated and written to `/home/steampipe/.steampipe/internal/.passwd`, which will be used for all subsequent service instances.  This implies that you will get a new password for EVERY container start if you do not map and persist the `internal` directory.

Alternatively, you can set the steampipe database password to your own custom value by passing the  `--database-password` argument to [steampipe service start](reference/cli/service) or by setting the [STEAMPIPE_DATABASE_PASSWORD](reference/env-vars/steampipe_database_password) environment variable.
