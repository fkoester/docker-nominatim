#! /bin/bash

set -e

export PLANET_DATA_URL=${PLANET_DATA_URL:-http://download.geofabrik.de/europe/monaco-latest.osm.pbf}
export OSM2PGSQL_CACHE=${OSM2PGSQL_CACHE:-14000}

function log_error {
  if [ -n "${LOGFILE}" ]
  then
    echo "[error] ${1}\n" >> ${LOGFILE}
  fi
  >&2 echo "[error] ${1}"
}

function log_info {
  if [ -n "${LOGFILE}" ]
  then
    echo "[info] ${1}\n" >> ${`LOGFILE`}
  else
    echo "[info] ${1}"
  fi
}

function die {
    echo >&2 "$@"
    exit 1
}

function initialization {
  if [ -s /importdata/data.osm.pbf ]; then
    log_info "==> Planet file /importdata/data.osm.pbf already exists, skipping download."
  else
    log_info "==> Downloading Planet file..."
    curl -o /importdata/data.osm.pbf || die "Failed to download planet file"
  fi

  log_info "==> Waiting for database to come up..."
  ./wait-for-it.sh -s -t 300 ${PGHOST}:5432 || die "Database did not respond"

  log_info "==> Starting Import..."
  /app/utils/setup.php --osm-file /importdata/data.osm.pbf --all --osm2pgsql-cache ${OSM2PGSQL_CACHE} 2>&1 || die "Import failed"

  log_info "==> Creating website..."
  /app/utils/setup.php --create-website /var/www/html/nominatim || die "Creating website failed"
}

if [ ! -s /var/www/html/nominatim/index.php ]; then
  log_info "Container has not been initialized, will start initial import now!"
  initialization
fi

apache2-foreground "$@"
