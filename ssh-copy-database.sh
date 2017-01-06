#! /bin/bash

## Based on https://www.guidodiepen.nl/2016/05/transfer-docker-data-volume-to-another-host/
## by Guido Diepen

TARGET_HOST=${1}
VOLUME="dockernominatim_nominatim-database"

if [ $# -lt 1 ]
then
  echo 'Usage: ssh-copy-database.sh <target host>'
  exit -1
fi

docker run --rm -v dockernominatim_nominatim-database:/from alpine ash -c "cd /from ; tar -cjf - . " | ssh ${TARGET_HOST} 'docker run --rm -i -v dockernominatim_nominatim-database:/to alpine ash -c "cd /to ; tar -xjvf - " '
