# docker-nominatim

A docker setup for running a custom instance of the [Nominatim geocoding service](http://wiki.openstreetmap.org/wiki/Nominatim) providing a nominatim-only image for use together with the plain [mdillon/postgis](https://hub.docker.com/r/mdillon/postgis/) image.

In contrast to other nominatim docker setups I have seen so far (see [Alternatives](#alternatives)) this setup has two main advantages:

1. Two separate containers instead of one for all services:

  * Apache containing the Nominatim instance
  * PostgreSQL + PostGIS (using plain [mdillon/postgis](https://hub.docker.com/r/mdillon/postgis/) image)

  This better complies with Docker's key principal: one container per service. The two docker containers are orchestrated using `docker-compose`.
  
2. The import does not happen at buildtime of the image but rather at runtime.

  This property is a consequence of 1.) because Nominatim of course needs the Database to import into. It also avoids nasty problems happening when trying to coordinate multiple processes from a Dockerfile.

This design of course means you cannot just prebuilt the ready-to-use Nominatim image on one host and copy it over to another (e.g. production) machine. But you can still copy the prebuilt database data, as described in section [Transferring prebuilt instance to other host](#transferring-prebuilt-instance-to-another-host).

## Supported tags and respective Dockerfile links

* `2.5.1`, `2.5`, `latest` [(Dockerfile)](https://github.com/bringnow/docker-nominatim/blob/master/nominatim/Dockerfile)

## Getting started

1. Make sure you have current versions of Docker (>= 1.12) and docker-compose (>= 1.9).
2. Clone this repository
3. Create a docker volume named `nominatim-database`:

  ```bash
  $ docker volume create --name nominatim-database
  ```
4. Create and start the docker containers using docker-compose:

  ```bash
  $ docker-compose up
  ```
  This will command will:
  * Fetch the necessary docker images
  * Start the OSM data import process, by default for Monaco (see following section for how to change)
  * Create all the necessary database indexes for nominatim
  * Startup an Apache instance at port 8080 (configurable)

After completion (should take only a few minutes for Monaco), you should be able to access the Nominatim instance at [http://localhost:8080](http://localhost:8080).

The initial import will only happen on first startup, because the entrypoint script will check if a database named `nominatim` already exists. In order to repeat the initial import, just remove the data volume `nominatim-database`:
```bash
$ docker volume rm nominatim-database
```

## Configuration

Create a file `.env` in the working directory with any of the following variables:

* `PLANET_DATA_URL`: The PBF planet file to download and import (default `http://download.geofabrik.de/europe/monaco-latest.osm.pbf`)
* `OSM2PGSQL_CACHE`: The cache size (in MB) passed to nominatim via the `--osm2pgsql-cache` argument. More info [here](http://wiki.openstreetmap.org/wiki/Nominatim/Installation) and [here](http://www.volkerschatz.com/net/osm/osm2pgsql-usage.html) (default `14000`)
* `EXTERNAL_PORT`: The external port (and ip address) to bind to (default `127.0.0.1:8080`)
* `IMPORT_DATA_DIR`: The directory where the planet file `data.osm.pbf` is stored or downloaded to (default `./volumes/importdata`)

## Transferring prebuilt instance to another host

Transferring the prebuilt instance basically means copying the contents of the PostgreSQL database, which in this setup are stored in the named docker volume  `nominatim-database`.

On the machine with the prebuilt nominatim instance, run the following steps:

1. Get the [ssh-copy-docker-volume.sh](https://github.com/bringnow/ssh-copy-docker-volume) script.
2. Make sure the Docker containers are stopped:

  ```bash
  docker-compose stop
  ```
3. Transfer the `nominatim-database` docker volume to the target host:

  ```bash
  $ ./ssh-copy-docker-volume.sh nominatim-database example.com
  ```

Then on the target machine, follow the steps from the [Getting Started](#getting-started) section but skip step 3, the creation of the volume.

## Alternatives

* [helvalius/nominatim-docker](https://github.com/helvalius/nominatim-docker)
* [mediagis/nominatim-docker](https://github.com/mediagis/nominatim-docker)
