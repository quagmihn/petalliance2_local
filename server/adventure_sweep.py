"""Quick-clear an earned three-crown Adventure using its repeatable drop."""
import json
import re
import time

from adventure_config import scene_cells
from client_config import table
from local_play import freedom
from progress import local_day, record
from reward_config import drop_plan, roll_drop
from reward_service import receive_rewards
from stamina import balance_at


def sweep_config(adventure_id):
    adventure = table("AdventureInfo").get(adventure_id)
    difficulty = adventure_id // 10000
    if not adventure or not scene_cells(adventure_id) or difficulty not in (0, 1, 2):
        return None
    caps = table("GlobalConfigAddInfo")
    return (adventure, caps[8001]["values"][difficulty],
            caps[8002]["values"][difficulty] if difficulty == 2 else None)


async def sweep(db, char_id, adventure_id, request_count, operation=None):
    config = sweep_config(adventure_id)
    if not config:
        return None
    adventure, maximum, daily_cap = config
    # The older screen uses 1 as the multi-clear flag. The newer one sends
    # its explicit count for a multi-clear, or 0 for one clear.
    count = 1 if request_count == 0 else maximum if request_count == 1 else request_count
    if not 1 <= count <= maximum:
        return None
    now = int(time.time())
    today = local_day(now)
    if operation is not None:
        token = re.fullmatch(r"([a-f0-9]{8})[a-f0-9]{16}", operation)
        if not token or local_day(int(token[1], 16)) != today:
            return None
    async with db.pool.acquire() as conn, conn.transaction():
        char = await conn.fetchrow("SELECT * FROM characters WHERE char_id=$1 FOR UPDATE", char_id)
        if char is None:
            return None
        values = json.loads(char["game_values"])
        saved = values.get("adventure_sweeps", {})
        if saved.get("day") != today:
            saved = {"day": today, "counts": {}, "orders": {}}
        counts, orders = saved["counts"], saved["orders"]
        key = str(adventure_id)
        counter = counts.get(key, {"count": 0, "last": now})
        entry = {"advID": adventure_id, "star": 15, "qcTimes": counter["count"],
                 "qcUpdateTime": counter["last"], "qcRefreshTimes": 0}
        if operation is not None and operation in orders:
            old_id, old_count, awards = orders[operation]
            if (old_id, old_count) != (adventure_id, count):
                return None
            return {"awards": awards, "state": None, "clear": entry}
        config = table("GlobalConfigAddInfo")
        if count > 1 and char["vip_level"] < config[72]["values"][0]:
            return None
        if not freedom(values) and int(str(values.get("map_lock", "0")).split("-")[0]) < config[21010]["values"][0]:
            return None
        if char["level"] < adventure["level"] or (daily_cap is not None and counter["count"] + count > daily_cap):
            return None
        star = await conn.fetchval(
            "SELECT star_mask FROM character_adventure_clears WHERE char_id=$1 AND adventure_id=$2",
            char_id, adventure_id)
        cost = adventure["power"] * count
        stamina, changed_at = balance_at(char, values, now)
        if star != 15 or cost <= 0 or stamina < cost:
            return None
        awards = roll_drop(drop_plan(adventure["rewards"]), count)
        if adventure["Exp_rewards"]:
            awards.append({"kind": "exp", "id": 0, "num": adventure["Exp_rewards"] * count})
        state = await receive_rewards(conn, char_id, values, awards, db._grant_character_exp)
        if state is None:
            return None
        counts[key] = {"count": counter["count"] + count, "last": now}
        entry.update(qcTimes=counts[key]["count"], qcUpdateTime=now)
        if operation:
            orders[operation] = [adventure_id, count, awards]
        state["wallet"] = await conn.fetchrow(
            """UPDATE characters SET stamina=$2,
               game_values=game_values || jsonb_build_object('adventure_sweeps',$3::jsonb,'lastactionvaluechangetime',$4::bigint)
               WHERE char_id=$1 RETURNING *""", char_id, stamina - cost, json.dumps(saved), changed_at)
        difficulty = ("NORMAL", "ELITE", "HERO")[adventure_id // 10000]
        await record(conn, char_id, f"ADVENTURE_{difficulty}_CLEARED", count, now=now)
        return {"awards": awards, "state": state, "clear": entry}
