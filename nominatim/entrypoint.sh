#! /bin/bash

set -e

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
    curl -L -o /importdata/data.osm.pbf ${PLANET_DATA_URL} || die "Failed to download planet file"
  fi

  log_info "==> Starting Import..."
  /app/utils/setup.php --osm-file /importdata/data.osm.pbf --all --osm2pgsql-cache ${OSM2PGSQL_CACHE} 2>&1 || die "Import failed"
}

log_info "==> Waiting for database to come up..."
./wait-for-it.sh -s -t 300 ${PGHOST}:5432 || die "Database did not respond"

if psql -lqt | cut -d \| -f 1 | grep -qw nominatim; then
    log_info "Database nominatim already exists, skipping initialization."
else
    log_info "Container has not been initialized, will start initial import now!"
    initialization
fi

apache2-foreground "$@"
