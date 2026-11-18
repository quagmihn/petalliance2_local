"""Local draws using project-authored prize pools and client price metadata."""
from __future__ import annotations

import json
import os
from hashlib import sha256
from collections import Counter
from dataclasses import dataclass
from functools import cache
from pathlib import Path
from secrets import randbelow

from character_values import validate_character_values
from client_config import table
from pet_config import gene, pokemon, skill_choices
from reward_service import grant_rewards

SERVER_ROOT = Path(__file__).resolve().parent
DATABASES = {"production": "monster2_db", "play": "monster2_play_db", "test": "monster2_test_db"}
LEGACY_RETRY_SECONDS = 8


@dataclass(frozen=True)
class DrawMachine:
    currency: str
    single_cost: int
    ten_cost: int
    cooldown: int
    daily_free_cap: int | None
    prizes: tuple[tuple[str, int, int, int], ...]

    def draw(self, count):
        awards = []
        total = sum(weight for _, _, _, weight in self.prizes)
        for _ in range(count):
            remaining = randbelow(total)
            for kind, element_id, amount, weight in self.prizes:
                if remaining < weight:
                    awards.append({"elementType": kind, "elementID": element_id, "num": amount})
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


def parse_catalog(raw, *, complete=False):
    local = json.loads(raw)
    if not isinstance(local, dict) or not local or set(local) - {"1", "2", "3"}:
        raise ValueError("expected local draw pools keyed by client machine index")
    machines = table("CapsuleEggInfo")
    costs = table("ConsumeElementInfo")
    items = table("ItemInfo")
    if complete and set(local) != {str(machine_id) for machine_id in machines}:
        missing = sorted({str(machine_id) for machine_id in machines} - set(local))
        raise ValueError(f"missing enabled machine pools: {', '.join(missing)}")
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
            fields = set(entry) if isinstance(entry, dict) else set()
            if fields not in ({"item_id", "count", "weight"}, {"pet_id", "count", "weight"}):
                raise ValueError("each local prize needs item_id or pet_id, count and weight")
            kind = "item" if "item_id" in entry else "pet"
            element_id, amount, weight = (entry[k] for k in (kind + "_id", "count", "weight"))
            if (any(type(value) is not int for value in (element_id, amount, weight))
                    or not 1 <= amount <= 1_000
                    or not 1 <= weight <= 1_000_000):
                raise ValueError(f"invalid local prize for machine {machine_id}")
            if kind == "item" and element_id not in items:
                raise ValueError(f"invalid local prize for machine {machine_id}: unknown item {element_id}")
            if kind == "pet":
                if amount != 1:
                    raise ValueError(f"machine {machine_id}: each Pet prize must grant one Pet")
                pokemon(element_id)
                _, skill_groups, _ = gene(element_id)
                for group in skill_groups:
                    if group:
                        skill_choices(group)
            prizes.append((kind, element_id, amount, weight))
        if complete and sum(prize[3] for prize in prizes) != 10_000:
            raise ValueError(f"machine {machine_id}: weights must sum to 10000")
        # Local rules use the cooldown already displayed by the client. Machine 1
        # has a daily cap, machine 2 uses cooldown alone, and 3 is paid only.
        catalog[machine_id] = DrawMachine(
            currency, int(single["num"]), int(ten["num"]), int(machine["CD"]),
            int(machine["freeTimes"]) if machine_id == 1 else None, tuple(prizes),
        )
    return catalog


@cache
def load_catalog(path, complete=False):
    raw = Path(path).read_bytes()
    return parse_catalog(raw, complete=complete)


def test_catalog():
    path = os.getenv("MONSTER2_TEST_DRAW_CATALOG")
    return load_catalog(path) if path and os.getenv("GAME_ENV") == "test" else {}


@cache
def startup_catalog(configured_path):
    path = (SERVER_ROOT / configured_path).resolve()
    raw = path.read_bytes()
    return path, sha256(raw).hexdigest(), parse_catalog(raw, complete=True)


def catalog_report(configured_path):
    path, digest, machines = startup_catalog(configured_path)
    return {
        "source": str(path), "sha256": digest,
        "environment": os.getenv("GAME_ENV"), "expected_database": os.getenv("MONSTER2_EXPECTED_DB"),
        "machine_ids": sorted(machines), "machines": len(machines), "pools": len(machines),
        "rewards": sum(len(machine.prizes) for machine in machines.values()),
        "prize_kinds": sorted({prize[0] for m in machines.values() for prize in m.prizes}),
        "modes": {i: (["free"] if i in (1, 2) else []) + ["x1", "x10"] for i in machines},
        "missing_references": [], "unsupported": ["wish", "dream", "original guarantee and VIP rules"],
    }


def configured_catalog():
    path = os.getenv("MONSTER2_DRAW_CATALOG")
    if path and os.getenv("GAME_ENV") in DATABASES:
        return startup_catalog(path)[2]
    return test_catalog()


async def cooldowns(db, char_id):
    rows = await db.pool.fetch(
        """SELECT machine_id, max(floor(extract(epoch FROM created_at))::bigint) AS last_draw,
           count(*) FILTER (WHERE draw_day = floor((extract(epoch FROM now())+3600)/86400))
               AS today
           FROM local_draw_history WHERE current_database()=$2
             AND char_id=$1 AND is_free GROUP BY machine_id""",
        char_id, DATABASES.get(os.getenv("GAME_ENV")),
    )
    return {r["machine_id"]: (r["today"], r["last_draw"]) for r in rows}


async def execute(db, char_id, machine_id, machine, count, free, request_key=None):
    if count not in (1, 10) or (free and (count != 1 or machine_id == 3)):
        return 1, None
    cost = 0 if free else machine.single_cost if count == 1 else machine.ten_cost
    environment = os.getenv("GAME_ENV")
    database = DATABASES.get(environment)
    if database is None:
        return 1, None
    async with db.pool.acquire() as conn:
        async with conn.transaction():
            character = await conn.fetchrow(
                """SELECT * FROM characters
                   WHERE current_database()=$2 AND char_id=$1
                     AND (NOT $3::boolean OR game_values->'qa_independent'='true'::jsonb) FOR UPDATE""",
                char_id, database, environment == "test",
            )
            if character is None:
                return 1, None
            if request_key and await conn.fetchval(
                "SELECT EXISTS (SELECT FROM local_draw_history WHERE char_id=$1 AND request_key=$2)",
                char_id, request_key,
            ):
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
            if cost and request_key is None and await conn.fetchval(
                """SELECT EXISTS (SELECT FROM local_draw_history
                   WHERE char_id=$1 AND machine_id=$2 AND draw_count=$3 AND NOT is_free
                     AND created_at >= to_timestamp($4))""",
                char_id, machine_id, count, now - LEGACY_RETRY_SECONDS,
            ):
                return 1, None
            if character[machine.currency] < cost:
                return 1, None

            awards = machine.draw(count)
            additions = Counter()
            for award in awards:
                additions[award["elementType"], award["elementID"]] += award["num"]
            item_ids = [element_id for kind, element_id in additions if kind == "item"]
            pet_count = sum(amount for (kind, _), amount in additions.items() if kind == "pet")
            inventory = dict(await conn.fetch(
                "SELECT item_id,count FROM inventory WHERE char_id=$1 AND count>0", char_id))
            values = json.loads(character["game_values"])
            capacity = validate_character_values(["itemPacketNum", "petPacketNum"], values)
            if item_ids and len(inventory.keys() | set(item_ids)) > capacity["itemPacketNum"]:
                return 422, None
            if pet_count and pet_count + await conn.fetchval(
                "SELECT count(*) FROM pets WHERE char_id=$1", char_id,
            ) > capacity["petPacketNum"]:
                return 123, None

            if cost:
                # The catalog resolves this value to a fixed column name.
                await conn.execute(
                    f"UPDATE characters SET {machine.currency}={machine.currency}-$2 WHERE char_id=$1",
                    char_id, cost,
                )
            granted = await grant_rewards(conn, char_id, [
                {"kind": kind, "id": element_id, "num": amount}
                for (kind, element_id), amount in additions.items()
            ], db._grant_character_exp)
            # The result screen expects serialized Pet detail for a Pet award.
            # grant_rewards groups equal templates, so match it by template ID.
            pet_details = {}
            for serialized in granted["pets"]:
                pet_details.setdefault(json.loads(serialized)["pokeID"], []).append(serialized)
            for award in awards:
                if award["elementType"] == "pet":
                    award["detail"] = pet_details[award["elementID"]].pop()
            await conn.execute(
                """INSERT INTO local_draw_history
                   (char_id,machine_id,draw_count,is_free,draw_day,currency,cost,awards,created_at,request_key)
                   VALUES($1,$2,$3,$4,$5,$6,$7,$8::jsonb,to_timestamp($9),$10)""",
                char_id, machine_id, count, free, day, machine.currency, cost, json.dumps(awards), now,
                request_key,
            )
            wallet = await conn.fetchrow("SELECT * FROM characters WHERE char_id=$1", char_id)
            item_counts = {row["item_id"]: row["count"] for row in await conn.fetch(
                "SELECT item_id,count FROM inventory WHERE char_id=$1 AND item_id=ANY($2::int[])",
                char_id, item_ids,
            )}
            return 0, (awards, wallet, item_counts, granted["pets"])
