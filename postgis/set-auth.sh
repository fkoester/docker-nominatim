#! /bin/sh

# Allow all users to connect via TCP without password
echo "host all all all trust" > /var/lib/postgresql/data/pg_hba.conf
