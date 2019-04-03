#!/bin/sh
set -e
# Perform all actions as $POSTGRES_USER
export PGUSER="$POSTGRES_USER"

echo "Init openclinica db into $POSTGRES_DB"
"${psql[@]}" <<- 'EOSQL'
\dx;
  CREATE ROLE clinica LOGIN ENCRYPTED PASSWORD 'clinica' SUPERUSER NOINHERIT NOCREATEDB NOCREATEROLE;
  CREATE DATABASE "openclinica-TEST-3.12" WITH ENCODING='UTF8' OWNER=clinica;
  CREATE DATABASE "openclinica-TEST" WITH ENCODING='UTF8' OWNER=clinica;
EOSQL