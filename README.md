# OpenClinica docker image

The [OpenClinica Community edition](https://www.openclinica.com/community-edition-open-source-edc/) is free and open source and is distributed under the [GNU LGPL license](https://www.openclinica.com/gnu-lgpl-open-source-license). 

This repository contains the *Dockerfile*, a startup script and the following instructions for running a Docker container  which you can use to give OpenClinica a try. An image built with this Dockerfile is available on [Docker Hub](https://cloud.docker.com/repository/docker/dahoba/openclinica).

> **IMPORTANT:** *This image is meant for trying out OpenClinica and not meant for running a production server or for storing important study data.*

## Setup

### 0. Install Docker & docker compose

* Follow the [installation instructions](http://docs.docker.com/installation/) for your host system
* *If you are running Docker on VirtualBox:* the maximum RAM size can be adjusted through the user interface of VirtualBox (run it from the start menu, stop the virtual machine, change the configuration to e.g. 4096MB, close it and start the virtual machine using `docker-machine`)

### 1. Create a database init script

* Create a file `init-db.sh` that adds a user and a database for OpenClinica to PostgreSQL:

```sh
#!/bin/sh
set -e
# Perform all actions as $POSTGRES_USER
export PGUSER="$POSTGRES_USER"

echo "Init openclinica db into $POSTGRES_DB"
"${psql[@]}" <<- 'EOSQL'
\dx;
  CREATE ROLE clinica LOGIN ENCRYPTED PASSWORD 'clinica' SUPERUSER NOINHERIT NOCREATEDB NOCREATEROLE;
  CREATE DATABASE openclinica WITH ENCODING='UTF8' OWNER=clinica;
EOSQL
```

### 2. Start a PostgreSQL database server

Modify where is the db-data folder to keep the postgresql data file on the OS

* This expects the `init-db.sh` script residing in the current directory

```sh
...
  db:
    image: "postgres:9.5-alpine"
    environment:
      TZ: "UTC+7"
      POSTGRES_PASSWORD: "jollyfawn28"
      POSTGRES_INITDB_ARGS: "-E 'UTF-8' --locale=POSIX"
    ports:
      - "5432:5432"
    volumes:
      - ./db-data:/var/lib/postgresql/data
      - ./init-db.sh:/docker-entrypoint-initdb.d/init-openclinica.sh
```

start postgresql with `docker-compose`

```
docker-compose up -d
```

* Please change the root database password

### 3. Start Tomcat serving OpenClinica and OpenClinica-ws

* Adjust `DB_HOST` and passwords accordingly
* The environment variables for log level and timezone are optional here.

```
  web:
    image: "dahoba/openclinica"
    environment:
      - TZ="UTC+7"
      - DB_TYPE=postgres
      - DB_HOST=db
      - DB_NAME=openclinica
      - DB_USER=clinica
      - DB_PASS=clinica
      - DB_PORT=5432
    volumes:
      - "./logs/tomcat-logs:/usr/local/tomcat/logs"
      - "./app-data/openclinica.data:/usr/local/tomcat/openclinica.data"
    ports:
      - "8080:8080"
    extra_hosts:
      - "usage.openclinica.com:127.0.0.1"
      - "designer13.openclinica.com:127.0.0.1"
    depends_on: 
      - db
```

### 4. Run OpenClinica

* Open up [http://&lt;ip.of.your.host&gt;/OpenClinica](http://<ip.of.your.host>/OpenClinica) in your browser
* First time login credentials: `root` / `12345678`

## Operation

**To show the OpenClinica logs:**

```sh
docker logs -f openclinica-docker_web_1
```

## Build image from source

1. clone (Openclinica)[https://github.com/OpenClinica/OpenClinica]
2. clone this repo into OpenClinica folder as `docker` folder
3. `cd OpenClinica/docker` 
4. modify the `docker-compose.yml` un-comment 

```
     build:
       context: ../
       dockerfile: docker/Dockerfile
```

5. execute `docker-compose build`. This will take the source code to compile while building docker image.