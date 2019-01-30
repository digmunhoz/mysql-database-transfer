# MySQL Database Transfer

This project has as an objective help you transfer a simple MySQL database from a server to another server.

The script was made to be simple and functional.
It has a pretty output to help you to see what's happing while the process is running.

The process will run using `Docker` and `Make` commands.

## Prerequisites

All you need is to have [`Docker`](https://docs.docker.com/install/).

## Confs

There are few variables (below) to adjust, to set the source and destination servers.
All settings are managed by environment variables which are defined in [env.list](./env.list) file.

```
MYSQL_SOURCE_HOST=
MYSQL_SOURCE_USERNAME=
MYSQL_SOURCE_PASSWORD=
MYSQL_SOURCE_DATABASE=
MYSQL_DEST_HOST=
MYSQL_DEST_USERNAME=
MYSQL_DEST_PASSWORD=
MYSQL_DEST_DATABASE=
```

> To avoid any problem, please create an user only with SHOW, SELECT and EVENT permissions to use on MYSQL_SOURCE_USERNAME variable.

## Running the process

1. Run `make build` command: This command will build the docker image to be used on the next step

2. Run `make run` command: This one will do the magic happens. You'll see an output like that:

```
[Running MySQL Database Transfer...]

[2019-01-30 22:55:56][INFO] Starting backup using these settings: Host: "MYSQL_SOURCE_HOST" Username: "MYSQL_SOURCE_USERNAME" Database: "MYSQL_SOURCE_PASSWORD"
[2019-01-30 22:56:51][INFO] Backup finished
[2019-01-30 22:56:51][INFO] Dropping database "MYSQL_DEST_DATABASE" on Host: "MYSQL_DEST_HOST"
[2019-01-30 22:56:51][INFO] Dropping database finished
[2019-01-30 22:56:51][INFO] Creating database "MYSQL_DEST_DATABASE" on Host: "MYSQL_DEST_HOST"
[2019-01-30 22:56:51][INFO] Creating database finished
[2019-01-30 22:56:51][INFO] Starting restore using these settings: Host: "MYSQL_DEST_HOST" Username: "MYSQL_DEST_USERNAME" Database: "MYSQL_DEST_DATABASE"
[2019-01-30 23:05:18][INFO] Restore finished
```

## Authors

* **Diogo Munhoz Fraga** - [digmunhoz](https://github.com/digmunhoz)
