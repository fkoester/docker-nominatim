#! /bin/sh

# Allow all users to connect via TCP without password
echo "host all all all trust" > ""${PGDATA}/pg_hba.conf
