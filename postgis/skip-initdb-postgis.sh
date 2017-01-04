#! /bin/sh

echo "Skipping initialization of postgis extensions and dropping default database \"nominatim\","
echo "because nominatim setup script will take care of initialization later."
dropdb -U nominatim nominatim
