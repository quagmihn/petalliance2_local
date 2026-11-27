"""Server-earned counters shared by daily missions and achievement claims."""
import json
import time

from client_config import table


def local_day(now):
    reset = table("GlobalConfigAddInfo")[6900]["values"][0]
    return (int(now) + 25200 - reset) // 86400


def daily_state(values, now):
    day = local_day(now)
    state = values.get("gameplay_daily", {})
    if state.get("day") != day:
        state = {"day": day, "events": {}, "missions": [], "gifts": [], "power": 0}
    return state


async def record(conn, char_id, event, amount=1, *, now=None):
    """Called once inside a successful gameplay transaction, after its replay guard."""
    values = json.loads(await conn.fetchval(
        "SELECT game_values FROM characters WHERE char_id=$1 FOR UPDATE", char_id))
    state = daily_state(values, time.time() if now is None else now)
    lifetime = values.get("gameplay_lifetime", {})
    for counts in (state["events"], lifetime):
        counts[event] = counts.get(event, 0) + amount
    await conn.execute(
        """UPDATE characters SET game_values=game_values ||
           jsonb_build_object('gameplay_daily',$2::jsonb,'gameplay_lifetime',$3::jsonb) WHERE char_id=$1""",
        char_id, json.dumps(state), json.dumps(lifetime))
