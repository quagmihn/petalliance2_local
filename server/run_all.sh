#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

fuser -k 8080/tcp 5568/tcp 2>/dev/null || true
PYTHON_BIN="${PYTHON_BIN:-python}"
if ! "$PYTHON_BIN" -c 'import asyncpg' >/dev/null 2>&1; then
    echo "asyncpg missing; install dependencies with: $PYTHON_BIN -m pip install -r requirements.txt" >&2
    exit 1
fi
if [[ -n "${DATABASE_URL:-}" ]]; then
    db_ready=(pg_isready -d "$DATABASE_URL")
else
    db_ready=(pg_isready -h "${PGHOST:-127.0.0.1}" -p "${PGPORT:-5432}" -U "${PGUSER:-monster2}" -d "${PGDATABASE:-monster2_db}")
fi
if ! command -v pg_isready >/dev/null || ! "${db_ready[@]}"; then
    echo "PostgreSQL unavailable. Start PostgreSQL and set DATABASE_URL (see db/schema.sql)." >&2
    exit 1
fi

"$PYTHON_BIN" -m http_gateway &
http_pid=$!
"$PYTHON_BIN" -m game_socket &
tcp_pid=$!
shutdown() { kill "$http_pid" "$tcp_pid" 2>/dev/null || true; wait || true; }
trap shutdown EXIT INT TERM
wait -n "$http_pid" "$tcp_pid"
