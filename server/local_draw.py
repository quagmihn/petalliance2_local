"""Test-only draws using operator-authored prize pools."""
from __future__ import annotations

import json
import os
from collections import Counter
from dataclasses import dataclass
from functools import cache
from pathlib import Path
from secrets import randbelow

from character_values import validate_character_values
from client_config import table
from reward_service import grant_rewards


@dataclass(frozen=True)
class DrawMachine:
    currency: str
    single_cost: int
    ten_cost: int
    cooldown: int
    daily_free_cap: int | None
    prizes: tuple[tuple[int, int, int], ...]

    def draw(self, count):
        awards = []
        total = sum(weight for _, _, weight in self.prizes)
        for _ in range(count):
            remaining = randbelow(total)
            for item_id, amount, weight in self.prizes:
                if remaining < weight:
                    awards.append({"elementType": "item", "elementID": item_id, "num": amount})
                    break
                remaining -= weight
        return awards


def catalog_audit():
    machines = table("CapsuleEggInfo")
    pools = table("CapsuleEggAwardInfo")
    elements = table("AwardElementInfo")
    missing_pools = sorted({
        machine[field]
        for machine in machines.values()
        for field in ("normalEggAwardIndex", "firstEggAwardIndex", "firstTenEggAwardIndex",
                      "normalTenEggAwardIndex", "tenTimesEggAwardIndex")
        if machine[field] not in pools
    })
    missing_elements = sorted({
        entry["awardItemIndex"]
        for pool in pools.values() for entry in pool["awardInfoVec"]
        if entry["awardItemIndex"] not in elements
    })
    return {"machines": len(machines), "pools": len(pools),
            "entries": sum(len(pool["awardInfoVec"]) for pool in pools.values()),
            "missing_pools": missing_pools, "missing_elements": missing_elements}


@cache
def load_catalog(path):
    local = json.loads(Path(path).read_text())
    if not isinstance(local, dict) or set(local) - {"1", "2", "3"}:
        raise ValueError("expected local draw pools keyed by client machine index")
    machines = table("CapsuleEggInfo")
    costs = table("ConsumeElementInfo")
    items = table("ItemInfo")
    catalog = {}
    for key, pool in local.items():
        machine_id = int(key)
        machine = machines[machine_id]
        single = costs[machine["OneEggCons"]]
        ten = costs[machine["tenEggCons"]]
        currency = {1: "gold", 2: "diamond"}.get(single["elementType"])
        if currency is None or single["elementType"] != ten["elementType"]:
            raise ValueError(f"unsupported display currency for machine {machine_id}")
        if not isinstance(pool, list) or not pool:
            raise ValueError(f"machine {machine_id} has no local prize entries")
        prizes = []
        for entry in pool:
            if not isinstance(entry, dict) or set(entry) != {"item_id", "count", "weight"}:
                raise ValueError("local prizes require item_id, count and weight")
            item_id, amount, weight = (entry[k] for k in ("item_id", "count", "weight"))
            if (any(type(value) is not int for value in (item_id, amount, weight))
                    or item_id not in items or not 1 <= amount <= 1_000
                    or not 1 <= weight <= 1_000_000):
                raise ValueError(f"invalid local prize for machine {machine_id}")
            prizes.append((item_id, amount, weight))
        # The test rules use the cooldown displayed by the client. Machine 1
        # has a daily cap, machine 2 uses cooldown alone, and 3 is paid only.
        catalog[machine_id] = DrawMachine(
            currency, int(single["num"]), int(ten["num"]), int(machine["CD"]),
            int(machine["freeTimes"]) if machine_id == 1 else None, tuple(prizes),
        )
    return catalog


def test_catalog():
    path = os.getenv("MONSTER2_TEST_DRAW_CATALOG")
    return load_catalog(path) if path and os.getenv("GAME_ENV") == "test" else {}


async def cooldowns(db, char_id):
    rows = await db.pool.fetch(
        """SELECT machine_id, max(floor(extract(epoch FROM created_at))::bigint) AS last_draw,
           count(*) FILTER (WHERE draw_day = floor((extract(epoch FROM now())+3600)/86400))
               AS today
           FROM local_draw_history WHERE current_database()='monster2_test_db'
             AND char_id=$1 AND is_free GROUP BY machine_id""", char_id,
    )
    return {r["machine_id"]: (r["today"], r["last_draw"]) for r in rows}


async def execute(db, char_id, machine_id, machine, count, free):
    if count not in (1, 10) or (free and (count != 1 or machine_id == 3)):
        return 1, None
    cost = 0 if free else machine.single_cost if count == 1 else machine.ten_cost
    async with db.pool.acquire() as conn:
        async with conn.transaction():
            character = await conn.fetchrow(
                """SELECT * FROM characters
                   WHERE current_database()='monster2_test_db' AND char_id=$1
                     AND game_values->'qa_independent'='true'::jsonb FOR UPDATE""",
                char_id,
            )
            if character is None:
                return 1, None
            now = await conn.fetchval("SELECT floor(extract(epoch FROM clock_timestamp()))::bigint")
            day = (now + 3600) // 86400  # 06:00 local in the current UTC+07 game server
            if free:
                previous = await conn.fetchrow(
                    """SELECT max(floor(extract(epoch FROM created_at))::bigint) AS last_draw,
                       count(*) FILTER (WHERE draw_day=$3) AS today
                       FROM local_draw_history WHERE char_id=$1 AND machine_id=$2 AND is_free""",
                    char_id, machine_id, day,
                )
                if ((previous["last_draw"] is not None and now - previous["last_draw"] < machine.cooldown)
                        or (machine.daily_free_cap is not None
                            and previous["today"] >= machine.daily_free_cap)):
                    return 390, None
            if character[machine.currency] < cost:
                return 1, None

            awards = machine.draw(count)
            additions = Counter()
            for award in awards:
                additions[award["elementID"]] += award["num"]
            inventory = dict(await conn.fetch(
                "SELECT item_id,count FROM inventory WHERE char_id=$1 AND count>0", char_id))
            values = json.loads(character["game_values"])
            capacity = validate_character_values(["itemPacketNum"], values)["itemPacketNum"]
            if len(inventory.keys() | additions.keys()) > capacity:
                return 422, None

            if cost:
                # The catalog resolves this value to a fixed column name.
                await conn.execute(
                    f"UPDATE characters SET {machine.currency}={machine.currency}-$2 WHERE char_id=$1",
                    char_id, cost,
                )
            await grant_rewards(conn, char_id, [
                {"kind": "item", "id": item_id, "num": amount}
                for item_id, amount in additions.items()
            ], db._grant_character_exp)
            await conn.execute(
                """INSERT INTO local_draw_history
                   (char_id,machine_id,draw_count,is_free,draw_day,currency,cost,awards,created_at)
                   VALUES($1,$2,$3,$4,$5,$6,$7,$8::jsonb,to_timestamp($9))""",
                char_id, machine_id, count, free, day, machine.currency, cost, json.dumps(awards), now,
            )
            wallet = await conn.fetchrow("SELECT * FROM characters WHERE char_id=$1", char_id)
            item_counts = {row["item_id"]: row["count"] for row in await conn.fetch(
                "SELECT item_id,count FROM inventory WHERE char_id=$1 AND item_id=ANY($2::int[])",
                char_id, list(additions),
            )}
            return 0, (awards, wallet, item_counts)
