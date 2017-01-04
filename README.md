# docker-nominatim

A docker setup for running a custom instance of the [Nominatim geocoding service](http://wiki.openstreetmap.org/wiki/Nominatim).

In contrast to other nominatim docker setups I have seen so far this setup has two advantages.

1. Instead of one docker container for all services (Apache and PostgreSQL database) it uses two
  * Apache containing the Nominatim instance
  * PostgreSQL + PostGIS

  This better complies with Docker's key principal: one container per service. The two docker containers are orchestrated using `docker-compose`.
2. The import does not happen at buildtime of the image but ruther at runtime. This property is a consequence of 1.) because Nominatim of course needs the Database to import into. It also avoids nasty problems happening when trying to coordinate multiple processes from a Dockerfile.

This design of course means you cannot just prebuilt the ready-to-use Nominatim image on one host and copy it over to another (e.g. production) machine. But you can still copy the prebuilt database data, as described in section [Transferring prebuilt instance to other host](#Transferring prebuilt instance to other host)

## Getting started

It is as simple as running

```
$ docker-compose up
```

This will command will:
* Build the necessary docker images
* Start the OSM data import process, by default for Monaco (see following section for how to change)
* Create all the necessary database indexes for nominatim
* Startup an Apache instance at port 8080 (configurable)

After completion (should take only a few minutes for Monaco), you should be able to access the Nominatim instance at [http://localhost:8080](http://localhost:8080).

## Configuration

Create a file `.env` in the working directory with any of the following variables:

* `PLANET_DATA_URL`: The PBF planet file to download and import (default `http://download.geofabrik.de/europe/monaco-latest.osm.pbf`)
* `OSM2PGSQL_CACHE`: The cache size passed to nominatim via the `--osm2pgsql-cache` argument (default `18000`)
* `EXTERNAL_PORT`: The external port to bind to (default `8080`)

## Transferring prebuilt instance to other host

**TODO**
