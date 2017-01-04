#! /bin/bash

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

log_info "==> Downloading Planet file..."
#curl -o /importdata/data.osm.pbf http://download.geofabrik.de/europe/monaco-latest.osm.pbf || die "Failed to download planet file"

log_info "==> Waiting for database to come up..."
./wait-for-it.sh -s -t 300 ${PGHOST}:5432 || die "Database did not respond"

log_info "==> Starting Import..."
/app/utils/setup.php --osm-file /importdata/data.osm.pbf --all --osm2pgsql-cache 18000 2>&1 | tee setup.log
