#!/usr/bin/env bash
set -euo pipefail
cd -- "$(dirname -- "${BASH_SOURCE[0]}")"

mode="${1:-${GAME_ENV:-play}}"
case "$mode" in
    test) MONSTER2_EXPECTED_DB=monster2_test_db ;;
    play) MONSTER2_EXPECTED_DB=monster2_play_db ;;
    production) MONSTER2_EXPECTED_DB=monster2_db ;;
    *) echo "Usage: $0 [test|play|production]" >&2; exit 2 ;;
esac
[[ $# -le 1 ]] || exit 2
if [[ "$mode" == play && -f .env.play ]]; then
    # shellcheck source=/dev/null
    source ./.env.play
fi
if ! command -v "${PYTHON_BIN:-python}" >/dev/null; then
    echo "Python not found. Install Python or set PYTHON_BIN." >&2
    exit 1
fi
if ! "${PYTHON_BIN:-python}" -B -c 'import asyncpg' >/dev/null 2>&1; then
    echo "asyncpg is missing. Install server/requirements.txt." >&2
    exit 1
fi
: "${DATABASE_URL:?Set DATABASE_URL or configure server/.env.play for play mode}"
export DATABASE_URL MONSTER2_EXPECTED_DB
export GAME_BIND="${GAME_BIND:-0.0.0.0}" HTTP_BIND="${HTTP_BIND:-0.0.0.0}"
export GAME_PORT="${GAME_PORT:-5568}" HTTP_PORT="${HTTP_PORT:-8080}"
export GAME_HOST="${GAME_HOST:-192.168.240.1}"
python_bin="${PYTHON_BIN:-python}"

for port in "$GAME_PORT" "$HTTP_PORT"; do
    if [[ ! "$port" =~ ^[1-9][0-9]{0,4}$ ]] || (( port > 65535 )); then
        echo "Invalid TCP port" >&2
        exit 2
    fi
done
if [[ "$GAME_PORT" == "$HTTP_PORT" ]]; then
    echo "HTTP_PORT and GAME_PORT must differ" >&2
    exit 2
fi
listeners=$(ss -H -ltnp "( sport = :$HTTP_PORT or sport = :$GAME_PORT )")
if [[ -n "$listeners" ]]; then
    printf 'Requested port already listening (PID shown when visible):\n%s\n' "$listeners" >&2
    exit 1
fi

"$python_bin" -B - <<'PY'
import asyncio
from db.database import Database

async def main():
    db = await Database.connect()
    await db.close()

try:
    asyncio.run(main())
except Exception as exc:
    raise SystemExit(f"Database preflight failed ({type(exc).__name__})") from None
PY

revision=$(git rev-parse HEAD)
dirty=$(git status --porcelain --untracked-files=no)
printf 'mode=%s commit=%s dirty=%s source=%s http=%s:%s tcp=%s:%s advertised=%s:%s\n' \
    "$mode" "$revision" "$([[ -z "$dirty" ]] && echo no || echo yes)" "$PWD" \
    "$HTTP_BIND" "$HTTP_PORT" "$GAME_BIND" "$GAME_PORT" "$GAME_HOST" "$GAME_PORT"

pids=()
shutdown() {
    trap '' INT TERM
    if (( ${#pids[@]} )); then
        kill -TERM "${pids[@]}" 2>/dev/null || true
        wait "${pids[@]}" 2>/dev/null || true
    fi
}
trap shutdown EXIT
trap 'exit 130' INT
trap 'exit 143' TERM
"$python_bin" -B http_gateway.py &
pids+=("$!")
"$python_bin" -B game_socket.py &
pids+=("$!")
printf 'http_pid=%s tcp_pid=%s\n' "${pids[@]}"
wait -n "${pids[@]}"
