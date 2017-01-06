# docker-nominatim

A docker setup for running a custom instance of the [Nominatim geocoding service](http://wiki.openstreetmap.org/wiki/Nominatim).

In contrast to other nominatim docker setups I have seen so far (see [Alternatives](#alternatives)) this setup has two main advantages:
1. Instead of one single docker container for all services (Apache and PostgreSQL database) it uses two
  * Apache containing the Nominatim instance
  * PostgreSQL + PostGIS

  This better complies with Docker's key principal: one container per service. The two docker containers are orchestrated using `docker-compose`.
2. The import does not happen at buildtime of the image but ruther at runtime. This property is a consequence of 1.) because Nominatim of course needs the Database to import into. It also avoids nasty problems happening when trying to coordinate multiple processes from a Dockerfile.

This design of course means you cannot just prebuilt the ready-to-use Nominatim image on one host and copy it over to another (e.g. production) machine. But you can still copy the prebuilt database data, as described in section [Transferring prebuilt instance to other host](#transferring-prebuilt-instance-to-another-host)

## Supported tags and respective Dockerfile links

* `2.5.1`, `2.5`, `latest` [(Dockerfile)](https://github.com/bringnow/docker-nominatim/blob/master/nominatim/Dockerfile)

## Getting started

First make sure you have current versions of Docker (>= 1.12) and docker-compose (>= 1.9). Then clone this repository and run
```bash
$ docker-compose up
```

This will command will:
* Fetch the necessary docker images
* Start the OSM data import process, by default for Monaco (see following section for how to change)
* Create all the necessary database indexes for nominatim
* Startup an Apache instance at port 8080 (configurable)

After completion (should take only a few minutes for Monaco), you should be able to access the Nominatim instance at [http://localhost:8080](http://localhost:8080).

The initial import will only happen on first startup, because the entrypoint script will check if a database named `nominatim` already exists. In order to repeat the initial import, just remove the volume holding the database data.

## Configuration

Create a file `.env` in the working directory with any of the following variables:

* `PLANET_DATA_URL`: The PBF planet file to download and import (default `http://download.geofabrik.de/europe/monaco-latest.osm.pbf`)
* `OSM2PGSQL_CACHE`: The cache size (in MB) passed to nominatim via the `--osm2pgsql-cache` argument. More info [here](http://wiki.openstreetmap.org/wiki/Nominatim/Installation) and [here](http://www.volkerschatz.com/net/osm/osm2pgsql-usage.html) (default `14000`)
* `EXTERNAL_PORT`: The external port to bind to (default `8080`)

## Transferring prebuilt instance to another host

Transferring the prebuilt instance basically means copying the contents of the PostgreSQL database, which in this setup are stored in a named docker volume.

On the machine with the prebuilt nominatim instance, run the following steps:
1. Get the [ssh-copy-docker-volume.sh](https://github.com/bringnow/ssh-copy-docker-volume) script.
2. Find out the name of the nominatim-database docker volume:
  ```bash
  $ docker volume ls | grep nominatim-database
  local               dockernominatim_nominatim-database
  ```
3. Transfer this volume to the target host:
  ```bash
  $ ./ssh-copy-docker-volume.sh dockernominatim_nominatim-database example.com
  ```

Then on the target machine, checkout this repository again and simply run `docker-compose up` again.

*Make sure the docker-compose project names are the same, so docker-compose will use the volume copied before!* The project name is usually generated from the name of the parent directory (`dockernominatim` in the example above). You can set the project name by defining the environment variable `COMPOSE_PROJECT_NAME` (for example in the `.env` file).

## Alternatives

* [helvalius/nominatim-docker](https://github.com/helvalius/nominatim-docker)
* [mediagis/nominatim-docker](https://github.com/mediagis/nominatim-docker)
