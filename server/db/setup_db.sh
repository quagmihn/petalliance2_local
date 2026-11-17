#!/usr/bin/env bash
set -euo pipefail
DB_ROLE="${DB_ROLE:-monster2}"
DB_NAME="${DB_NAME:-monster2_db}"
read -r -s -p "Password for PostgreSQL role ${DB_ROLE}: " DB_PASSWORD
printf '\n'
if [[ -z "$DB_PASSWORD" ]]; then echo "Password cannot be empty" >&2; exit 1; fi

# Run as the local postgres administrator (Arch commonly uses peer auth).
sudo -u postgres psql -v ON_ERROR_STOP=1 \
  -v db_role="$DB_ROLE" -v db_name="$DB_NAME" -v db_password="$DB_PASSWORD" <<'SQL'
SELECT format('CREATE ROLE %I LOGIN PASSWORD %L', :'db_role', :'db_password')
WHERE NOT EXISTS (SELECT FROM pg_roles WHERE rolname=:'db_role') \gexec
SELECT format('ALTER ROLE %I PASSWORD %L', :'db_role', :'db_password') \gexec
SELECT format('CREATE DATABASE %I OWNER %I', :'db_name', :'db_role')
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname=:'db_name') \gexec
SQL

unset DB_PASSWORD
echo "Created/updated role ${DB_ROLE} and database ${DB_NAME}. Load schema with: psql -h 127.0.0.1 -U ${DB_ROLE} -d ${DB_NAME} -f server/db/schema.sql"
