#!/usr/bin/env bash
set -euo pipefail
cd -- "$(dirname -- "${BASH_SOURCE[0]}")"

doctor=false
if [[ "${1:-}" == doctor ]]; then
    doctor=true
    shift
fi
profile="${1:-local}"
case "$profile" in
    local) mode=production; MONSTER2_EXPECTED_DB=monster2_db ;;
    test) mode=test; MONSTER2_EXPECTED_DB=monster2_test_db ;;
    play) mode=play; MONSTER2_EXPECTED_DB=monster2_play_db ;;
    production) mode=production; MONSTER2_EXPECTED_DB=monster2_db ;;
    *) echo "Usage: $0 [doctor] [local|test|play|production]" >&2; exit 2 ;;
esac
[[ $# -le 1 ]] || exit 2
if [[ "$profile" == local ]]; then
    # Interactive shells and service managers start from the same profile.
    unset DATABASE_URL MONSTER2_DRAW_CATALOG NEW_QUEST_INFO_PATH \
        VERSION_FILE GAME_HOST GAME_BIND HTTP_BIND GAME_PORT HTTP_PORT LOCAL_PAYMENT_SANDBOX PAYMENT_PROVIDER
    source ./config/local-play.env
fi
if [[ "$mode" != test && -f ".env.$mode" ]]; then
    # Disable xtrace while reading local credentials.
    restore_trace=false
    if [[ $- == *x* ]]; then
        restore_trace=true
        set +x
    fi
    source "./.env.$mode"
    if "$restore_trace"; then set -x; fi
fi
if [[ "$profile" != local && "$profile" != test ]]; then
    LOCAL_PAYMENT_SANDBOX=0
    PAYMENT_PROVIDER=none
fi
export LOCAL_PAYMENT_SANDBOX="${LOCAL_PAYMENT_SANDBOX:-0}" PAYMENT_PROVIDER="${PAYMENT_PROVIDER:-none}"
export VIP_SHOP_UNLIMITED="${VIP_SHOP_UNLIMITED:-0}"
export LOCAL_FREEDOM_MODE="${LOCAL_FREEDOM_MODE:-0}"
export LOCAL_UNLIMITED_PET_STORAGE="${LOCAL_UNLIMITED_PET_STORAGE:-0}"
export LOCAL_UNLIMITED_ITEM_STORAGE="${LOCAL_UNLIMITED_ITEM_STORAGE:-0}"
export LOCAL_UNLIMITED_SILVER="${LOCAL_UNLIMITED_SILVER:-0}" LOCAL_UNLIMITED_SILVER_PLAYER="${LOCAL_UNLIMITED_SILVER_PLAYER:-}"
if [[ "$mode" == production && -z "${DATABASE_URL:+set}" ]]; then
    DATABASE_URL='postgresql://monster2@/monster2_db?host=/run/postgresql'
fi
if ! command -v "${PYTHON_BIN:-python}" >/dev/null; then
    echo "Python not found. Install Python or set PYTHON_BIN." >&2
    exit 1
fi
if ! "${PYTHON_BIN:-python}" -B -c 'import asyncpg' >/dev/null 2>&1; then
    echo "asyncpg is missing. Install server/requirements.txt." >&2
    exit 1
fi
if [[ -z "${DATABASE_URL:+set}" ]]; then
    echo "Set DATABASE_URL for test, or configure server/.env.play for play." >&2
    exit 2
fi
export DATABASE_URL MONSTER2_EXPECTED_DB GAME_ENV="$mode"
export NEW_QUEST_INFO_PATH VERSION_FILE
export MONSTER2_DRAW_CATALOG="${MONSTER2_DRAW_CATALOG:-config/local_play_draw.json}"
export GAME_HOST="${GAME_HOST:-192.168.240.1}"
default_bind=0.0.0.0
if [[ "$mode" == production && ( -z "${GAME_BIND:-}" || -z "${HTTP_BIND:-}" ) ]]; then
    default_bind=127.0.0.1
    if ip -o -4 addr show | awk -v host="$GAME_HOST" '
        { split($4, address, "/"); if (address[1] == host) found=1 }
        END { exit !found }
    '; then
        default_bind="$GAME_HOST"
    else
        echo "Waydroid address $GAME_HOST is unavailable. Using loopback; start Waydroid and restart the launcher for Android access." >&2
    fi
fi
export GAME_BIND="${GAME_BIND:-$default_bind}" HTTP_BIND="${HTTP_BIND:-$default_bind}"
export GAME_PORT="${GAME_PORT:-5568}" HTTP_PORT="${HTTP_PORT:-8080}"
export MONSTER2_LAUNCH_PROFILE="$profile"
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
if ! "$doctor"; then
    listeners=$(ss -H -ltnp "( sport = :$HTTP_PORT or sport = :$GAME_PORT )")
    if [[ -n "$listeners" ]]; then
        printf 'Requested port already listening (PID shown when visible):\n%s\n' "$listeners" >&2
        exit 1
    fi
fi

"$python_bin" -B launcher_preflight.py

revision=$(git rev-parse HEAD)
dirty=$(git status --porcelain --untracked-files=no)
printf 'profile=%s mode=%s commit=%s dirty=%s source=%s http=%s:%s tcp=%s:%s advertised=%s:%s\n' \
    "$profile" "$mode" "$revision" "$([[ -z "$dirty" ]] && echo no || echo yes)" "$PWD" \
    "$HTTP_BIND" "$HTTP_PORT" "$GAME_BIND" "$GAME_PORT" "$GAME_HOST" "$GAME_PORT"
if "$doctor"; then exit 0; fi

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
