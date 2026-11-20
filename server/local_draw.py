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
from client_config import CONFIG, table
from pet_config import acquisition_skill_pools, pokemon
from quest_config import GACHA_GUIDE_PET_ID, GACHA_GUIDE_QUEST_ID, load_quests
from reward_config import resolve_award_element
from reward_service import grant_rewards

SERVER_ROOT = Path(__file__).resolve().parent
DATABASES = {"production": "monster2_db", "play": "monster2_play_db", "test": "monster2_test_db"}
LEGACY_RETRY_SECONDS = 8
SENIOR_MAX_PET_RARITY = 4
TARGET_NORMAL = {"source": "target-normal"}
DRAW_SOURCE_TABLES = ("CapsuleEggInfo", "CapsuleEggAwardInfo", "AwardElementInfo",
                      "ConsumeElementInfo", "ItemInfo", "PokemonInfo", "GeneInfo",
                      "GeneProbabilityInfo")


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


@cache
def _original_pool(pool_id):
    entries = table("CapsuleEggAwardInfo")[pool_id]["awardInfoVec"]
    pool = []
    for entry in entries:
        reward = resolve_award_element(entry["awardItemIndex"], entry["awardItemNum"])
        if reward["kind"] not in ("pet", "item"):
            raise ValueError(f"unsupported original draw reward kind in pool {pool_id}")
        pool.append({reward["kind"] + "_id": reward["id"], "count": reward["num"],
                     "weight": entry["rate"]})
    return pool


def parse_catalog(raw, *, complete=False):
    local = json.loads(raw)
    machines = table("CapsuleEggInfo")
    if local == TARGET_NORMAL:
        local = {str(machine_id): _original_pool(machine["normalEggAwardIndex"])
                 for machine_id, machine in machines.items()}
    if not isinstance(local, dict) or not local or set(local) - {"1", "2", "3"}:
        raise ValueError("expected local draw pools keyed by client machine index")
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
                acquisition_skill_pools(element_id)
            prizes.append((kind, element_id, amount, weight))
        if complete and sum(prize[3] for prize in prizes) != 10_000:
            raise ValueError(f"machine {machine_id}: weights must sum to 10000")
        if machine_id == 1:
            # The local Senior policy retains the relative weights of all
            # eligible entries. DrawMachine uses their effective weight sum.
            prizes = [prize for prize in prizes if prize[0] != "pet"
                      or pokemon(prize[1])["rare"] <= SENIOR_MAX_PET_RARITY]
            if not prizes:
                raise ValueError("Senior draw has no prizes eligible under the Gold rarity cap")
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
    guide, goal = tutorial_guide()
    target_normal = json.loads(path.read_bytes()) == TARGET_NORMAL
    return {
        "source": str(path), "sha256": digest,
        "environment": os.getenv("GAME_ENV"), "expected_database": os.getenv("MONSTER2_EXPECTED_DB"),
        "machine_ids": sorted(machines), "machines": len(machines), "pools": len(machines),
        "rewards": sum(len(machine.prizes) for machine in machines.values()),
        "prize_kinds": sorted({prize[0] for m in machines.values() for prize in m.prizes}),
        "senior_max_pet_rarity": SENIOR_MAX_PET_RARITY,
        "effective_weight_sums": {i: sum(prize[3] for prize in machine.prizes)
                                  for i, machine in machines.items()},
        "modes": {i: (["free"] if i in (1, 2) else []) + ["x1", "x10"] for i in machines},
        "pool_rules": "target-normal-independent" if target_normal else "local-independent",
        "source_tables": {name: sha256((CONFIG / f"{name}.dat").read_bytes()).hexdigest()
                          for name in DRAW_SOURCE_TABLES},
        "tutorial": {"quest_id": guide.quest_id, "machine_id": 2, "pet_id": GACHA_GUIDE_PET_ID,
                     "required_progress": goal},
        "missing_references": [], "unsupported": ["wish", "dream", "ordinary guarantee and VIP rules"],
    }


def configured_catalog():
    path = os.getenv("MONSTER2_DRAW_CATALOG")
    if path and os.getenv("GAME_ENV") in DATABASES:
        return startup_catalog(path)[2]
    return test_catalog()


@cache
def tutorial_guide():
    guide = load_quests()[GACHA_GUIDE_QUEST_ID]
    if (guide.strong_type != "1" or not guide.parent_id
            or len(guide.objectives) != 1
            or (guide.objectives[0].event_type, guide.objectives[0].amount) != (2, 1)
            or guide.first_pokemon_id or pokemon(GACHA_GUIDE_PET_ID)["rare"] != 3):
        raise ValueError("tutorial Gacha quest or Grade A Panda template does not match the client")
    acquisition_skill_pools(GACHA_GUIDE_PET_ID)
    senior_tutorial_prize()
    return guide, guide.objectives[0].amount


@cache
def senior_tutorial_prize():
    pool_id = table("CapsuleEggInfo")[1]["firstEggAwardIndex"]
    pool = _original_pool(pool_id)
    if len(pool) != 1 or "item_id" not in pool[0] or pool[0]["weight"] != 10_000:
        raise ValueError(f"guide Senior pool {pool_id} must contain its single configured item")
    return {"elementType": "item", "elementID": pool[0]["item_id"], "num": pool[0]["count"]}


async def has_tutorial_draw_receipt(conn, char_id):
    return await conn.fetchval(
        """SELECT EXISTS (
               SELECT 1 FROM local_draw_history
               WHERE char_id=$1 AND machine_id=2 AND draw_count=1 AND is_free AND cost=0
                 AND awards @> $2::jsonb
           )""",
        char_id, json.dumps([{"elementType": "pet", "elementID": GACHA_GUIDE_PET_ID}]),
    )


async def _tutorial_draw_pending(conn, char_id):
    guide, _ = tutorial_guide()
    # The character row serializes draws and commits. Quest progress is the
    # UI projection. The draw receipt records whether the entitlement was used.
    active = await conn.fetchval(
        """SELECT EXISTS (
               SELECT 1 FROM quests q
               JOIN quests parent ON parent.char_id=q.char_id AND parent.quest_id=$3
               JOIN characters c ON c.char_id=q.char_id
               WHERE q.char_id=$1 AND q.quest_id=$2 AND q.status=0
                 AND parent.status=1 AND current_database()=$4
                 AND c.game_values->'qa_independent' IS DISTINCT FROM 'true'::jsonb
           )""",
        char_id, guide.quest_id, guide.parent_id, DATABASES.get(os.getenv("GAME_ENV")),
    )
    return active and not await has_tutorial_draw_receipt(conn, char_id)


async def cooldowns(db, char_id):
    rows = await db.pool.fetch(
        """SELECT machine_id, max(floor(extract(epoch FROM created_at))::bigint) AS last_draw,
           count(*) FILTER (WHERE draw_day = floor((extract(epoch FROM now())+3600)/86400))
               AS today
           FROM local_draw_history WHERE current_database()=$2
             AND char_id=$1 AND is_free GROUP BY machine_id""",
        char_id, DATABASES.get(os.getenv("GAME_ENV")),
    )
    history = {r["machine_id"]: (r["today"], r["last_draw"]) for r in rows}
    if os.getenv("MONSTER2_DRAW_CATALOG") and await _tutorial_draw_pending(db.pool, char_id):
        # The guide resumes using the free timestamps. Old local draws could
        # grant an item and skip the Panda reveal. Restore that single
        # tutorial entitlement independently of the ordinary cooldown.
        history[2] = (0, 0)
    return history


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
                """SELECT * FROM characters WHERE current_database()=$2 AND char_id=$1 FOR UPDATE""",
                char_id, database,
            )
            if character is None:
                return 1, None
            values = json.loads(character["game_values"])
            tutorial = (os.getenv("MONSTER2_DRAW_CATALOG") and not values.get("qa_independent")
                        and (free or environment == "test")
                        and await _tutorial_draw_pending(conn, char_id))
            if environment == "test" and not values.get("qa_independent") and not tutorial:
                return 1, None
            guided_free = tutorial and free
            senior_drawn = guided_free and await conn.fetchval(
                """SELECT EXISTS (SELECT 1 FROM local_draw_history
                   WHERE char_id=$1 AND machine_id=1 AND is_free)""", char_id,
            )
            tutorial_prize = guided_free and machine_id == 2
            if tutorial_prize and not senior_drawn:
                return 1, None
            if request_key and await conn.fetchval(
                "SELECT EXISTS (SELECT FROM local_draw_history WHERE char_id=$1 AND request_key=$2)",
                char_id, request_key,
            ):
                return 1, None
            now = await conn.fetchval("SELECT floor(extract(epoch FROM clock_timestamp()))::bigint")
            day = (now + 3600) // 86400  # 06:00 local in the current UTC+07 game server
            if free and not tutorial_prize:
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

            if tutorial_prize:
                awards = [{"elementType": "pet", "elementID": GACHA_GUIDE_PET_ID, "num": 1}]
            elif guided_free and machine_id == 1 and not senior_drawn:
                awards = [dict(senior_tutorial_prize())]
            else:
                awards = machine.draw(count)
            additions = Counter()
            for award in awards:
                additions[award["elementType"], award["elementID"]] += award["num"]
            item_ids = [element_id for kind, element_id in additions if kind == "item"]
            pet_count = sum(amount for (kind, _), amount in additions.items() if kind == "pet")
            inventory = dict(await conn.fetch(
                "SELECT item_id,count FROM inventory WHERE char_id=$1 AND count>0", char_id))
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
            if tutorial_prize:
                guide, goal = tutorial_guide()
                await conn.execute(
                    "UPDATE quests SET progress=$3::jsonb WHERE char_id=$1 AND quest_id=$2",
                    char_id, guide.quest_id, json.dumps([goal]),
                )
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
