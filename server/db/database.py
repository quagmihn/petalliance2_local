from __future__ import annotations

import json
import logging
from functools import cache
import os
from pathlib import Path
from typing import Any

import asyncpg

from quest_config import FORMATION_GUIDE_QUEST_ID, GACHA_GUIDE_PET_ID

@cache
def _character_exp_thresholds():
    from client_config import table

    levels = sorted(table("ExperienceInfo").items())
    return [int(row["roleExp"]) for _, row in levels[:-1]]


class Database:
    def __init__(self, pool: asyncpg.Pool):
        self.pool = pool

    @classmethod
    async def connect(cls, dsn: str | None = None) -> "Database":
        connection_url = dsn or os.getenv("DATABASE_URL")
        if not connection_url:
            raise RuntimeError("Explicit DATABASE_URL required")
        expected = os.getenv("MONSTER2_EXPECTED_DB")
        if not expected:
            return cls(await asyncpg.create_pool(connection_url))

        async def check_database(conn):
            actual = await conn.fetchval("SELECT current_database()")
            if actual != expected:
                raise RuntimeError(f"Expected database {expected}, connected to {actual}")

        pool = await asyncpg.create_pool(connection_url, init=check_database)
        async with pool.acquire() as conn:
            identity = await conn.fetchrow(
                "SELECT current_database() AS database, current_user AS role"
            )
        logging.getLogger(__name__).warning(
            "database pool verified pid=%s database=%s role=%s",
            os.getpid(), identity["database"], identity["role"],
        )
        return cls(pool)

    async def initialize(self, schema: Path | None = None) -> None:
        sql = (schema or Path(__file__).with_name("schema.sql")).read_text()
        async with self.pool.acquire() as conn:
            async with conn.transaction():
                await conn.execute("SELECT pg_advisory_xact_lock(1295143763)")
                await conn.execute(sql)
                await conn.execute(
                    """UPDATE characters SET level=(SELECT 1+count(*)
                        FROM unnest($1::bigint[]) AS threshold WHERE threshold <= exp)
                       WHERE level < (SELECT 1+count(*)
                        FROM unnest($1::bigint[]) AS threshold WHERE threshold <= exp)""",
                    _character_exp_thresholds(),
                )

    @staticmethod
    async def _grant_character_exp(conn, char_id: int, amount: int):
        if amount:
            await conn.execute(
                """UPDATE characters SET exp=exp+$2,
                   level=greatest(level,(SELECT 1+count(*)
                       FROM unnest($3::bigint[]) AS threshold WHERE threshold <= exp+$2))
                   WHERE char_id=$1""",
                char_id, amount, _character_exp_thresholds(),
            )

    async def update_primary_army(self, char_id: int, members: list[int], support: list[int]) -> bool:
        from client_config import table

        config = table("GlobalConfigAddInfo")
        unlocks = [max(config[index]["values"]) for index in range(9001, 9005)]
        slots = dict(zip(members, range(3))) | dict(zip(support, range(3, 6)))
        async with self.pool.acquire() as conn:
            async with conn.transaction():
                level = await conn.fetchval(
                    "SELECT level FROM characters WHERE char_id=$1 FOR UPDATE", char_id
                )
                if level is None or len(slots) > 2 + sum(level >= entry for entry in unlocks):
                    return False
                pets = await conn.fetch(
                    """SELECT pet_uid,pet_template_id FROM pets
                       WHERE char_id=$1 AND pet_uid=ANY($2::bigint[]) FOR UPDATE""",
                    char_id, list(slots),
                )
                if len(pets) != len(slots) or len({pet["pet_template_id"] for pet in pets}) != len(slots):
                    return False
                await conn.execute(
                    "UPDATE pets SET slot_index=-1 WHERE char_id=$1 AND slot_index BETWEEN 0 AND 5",
                    char_id,
                )
                await conn.executemany(
                    "UPDATE pets SET slot_index=$3 WHERE char_id=$1 AND pet_uid=$2",
                    [(char_id, uid, slot) for uid, slot in slots.items()],
                )
                return True

    async def committed_character_progress(self, char_id: int):
        row = await self.pool.fetchrow(
            "SELECT level,exp,gold AS g_cash,diamond AS m_cash FROM characters WHERE char_id=$1",
            char_id,
        )
        return dict(row)

    async def redeem_fashion_item(self, char_id: int, item_id: int, fashion_id: int):
        from fashion_config import fashion_bag_slot, initial_fashion_state

        async with self.pool.acquire() as conn:
            async with conn.transaction():
                row = await conn.fetchrow(
                    "SELECT game_values FROM characters WHERE char_id=$1 FOR UPDATE", char_id)
                if row is None:
                    return 1, None, None
                values = json.loads(row["game_values"])
                state = values.get("fashion_info")
                if isinstance(state, str):
                    state = json.loads(state)
                if state is None:
                    current = values.get("curfashion", [])
                    if isinstance(current, str):
                        current = json.loads(current)
                    state = initial_fashion_state(current)
                bag = state["bag"]
                if fashion_id in state["curFashion"] or any(fashion_id in group for group in bag):
                    return 455, None, None
                remaining = await conn.fetchval(
                    """UPDATE inventory SET count=count-1
                       WHERE char_id=$1 AND item_id=$2 AND count>0 RETURNING count""",
                    char_id, item_id,
                )
                if remaining is None:
                    return 1, None, None
                if remaining == 0:
                    await conn.execute(
                        "DELETE FROM inventory WHERE char_id=$1 AND item_id=$2 AND count=0",
                        char_id, item_id,
                    )
                bag[fashion_bag_slot(fashion_id)].append(fashion_id)
                values["fashion_info"] = state
                await conn.execute(
                    "UPDATE characters SET game_values=$2::jsonb WHERE char_id=$1",
                    char_id, json.dumps(values),
                )
                return 0, remaining, state

    async def feed_pet_exp(self, char_id: int, pet_uid: int, item_id: int,
                           item_count: int, exp_per_item: int):
        """Consume configured feed items and persist Pet cumulative EXP atomically."""
        from client_config import table

        exp_rows = table("ExperienceInfo")
        async with self.pool.acquire() as conn:
            async with conn.transaction():
                char = await conn.fetchrow(
                    "SELECT level FROM characters WHERE char_id=$1 FOR UPDATE", char_id)
                if char is None:
                    return None
                pet = await conn.fetchrow(
                    "SELECT * FROM pets WHERE char_id=$1 AND pet_uid=$2 FOR UPDATE",
                    char_id, pet_uid)
                if pet is None:
                    return None
                item = await conn.fetchrow(
                    "SELECT count FROM inventory WHERE char_id=$1 AND item_id=$2 FOR UPDATE",
                    char_id, item_id)
                if item is None or int(item["count"]) < item_count:
                    return None

                template = table("PokemonInfo").get(int(pet["pet_template_id"]))
                if template is None:
                    raise ValueError(f"unknown Pet template {pet['pet_template_id']}")
                rare = int(template["rarePoint"])
                max_level = min(int(char["level"]), int(template["topLevel"]))
                if max_level < 1 or rare < 1:
                    raise ValueError("invalid Pet EXP level configuration")
                thresholds = []
                for level in range(1, max_level + 1):
                    row = exp_rows.get(level)
                    values = row.get("petExpVec", []) if row else []
                    if len(values) < rare:
                        raise ValueError(f"missing Pet EXP threshold for level {level}, rarity {rare}")
                    thresholds.append(int(values[rare - 1]))
                old_exp = int(pet["exp"])
                if old_exp < 0:
                    raise ValueError("negative Pet EXP")
                current_level = min(max_level, 1 + sum(value <= old_exp for value in thresholds))
                if current_level >= max_level:
                    return None
                next_cap = thresholds[max_level - 1] - 1
                new_exp = min(old_exp + item_count * exp_per_item, next_cap)
                new_level = min(max_level, 1 + sum(value <= new_exp for value in thresholds))
                if new_exp <= old_exp:
                    return None

                await conn.execute(
                    "UPDATE inventory SET count=count-$3 WHERE char_id=$1 AND item_id=$2",
                    char_id, item_id, item_count)
                remaining = int(item["count"]) - item_count
                if remaining == 0:
                    await conn.execute(
                        "DELETE FROM inventory WHERE char_id=$1 AND item_id=$2 AND count=0",
                        char_id, item_id)
                await conn.execute(
                    "UPDATE pets SET level=$3,exp=$4 WHERE char_id=$1 AND pet_uid=$2",
                    char_id, pet_uid, new_level, new_exp)
                updated = await conn.fetchrow(
                    "SELECT * FROM pets WHERE char_id=$1 AND pet_uid=$2",
                    char_id, pet_uid)
                from handlers.pet import pet_json
                serialized = pet_json(updated)
                return {"remaining": remaining, "pet": dict(updated),
                        "pet_json": serialized}

    async def buy_market_item(self, char_id: int, market: dict, count: int):
        """Apply a configured MarketInfo purchase and its weekly counter."""
        from character_values import validate_character_values
        from client_config import table
        limit = int(market["buyMax"])
        if count < 1 or count > 99 or (limit and market["marketType"] != 4):
            return None
        item_id, quantity = int(market["itemID"]), count
        item = table("ItemInfo").get(item_id)
        if item is None or quantity < 1:
            return None
        coin_type, price = int(market["coinType"]), int(market["num"]) * count
        currency_column = {1: "gold", 2: "diamond"}.get(coin_type)
        if coin_type not in (1, 2, 3):
            return None
        async with self.pool.acquire() as conn:
            async with conn.transaction():
                char = await conn.fetchrow(
                    "SELECT * FROM characters WHERE char_id=$1 FOR UPDATE", char_id)
                if char is None or char["vip_level"] < market["vip"]:
                    return None
                values = json.loads(char["game_values"])
                capacity = validate_character_values(["itemPacketNum"], values)["itemPacketNum"]
                bag = await conn.fetchrow(
                    """SELECT count(*) AS occupied, bool_or(item_id=$2) AS has_stack
                       FROM inventory WHERE char_id=$1 AND count>0""", char_id, item_id)
                if not bag["has_stack"] and bag["occupied"] >= capacity:
                    return None
                counters = {}
                if limit:
                    # VipShopViewMgr uses weekday 1 (Monday) and the config
                    # reset offset in the server's advertised UTC+07 zone.
                    offset = 25200 - table("GlobalConfigAddInfo")[6900]["values"][0]
                    now = await conn.fetchval("SELECT floor(extract(epoch FROM now()))::bigint")
                    num_key = f"buyMarketItemNum_{market['id']}"
                    time_key = f"buyMarketItemTime_{market['id']}"
                    last = int(values.get(time_key, 0))
                    monday_offset = offset - 4 * 86400
                    period = 7 * 86400
                    same_week = (last + monday_offset) // period == (now + monday_offset) // period
                    previous = int(values.get(num_key, 0)) if same_week else 0
                    if previous + count > limit:
                        return None
                    counters.update({num_key: previous + count, time_key: now})
                currencies = char["currencies_json"] or {}
                if isinstance(currencies, str):
                    currencies = json.loads(currencies)
                if coin_type == 3:
                    balance = int(currencies.get("goldCoin", 0))
                    if balance < price:
                        return None
                    currencies["goldCoin"] = balance - price
                    await conn.execute(
                        "UPDATE characters SET currencies_json=$2::jsonb WHERE char_id=$1",
                        char_id, json.dumps(currencies))
                else:
                    if int(char[currency_column]) < price:
                        return None
                    await conn.execute(
                        f"UPDATE characters SET {currency_column}={currency_column}-$2 WHERE char_id=$1",
                        char_id, price)
                if counters:
                    await conn.execute(
                        "UPDATE characters SET game_values=game_values || $2::jsonb WHERE char_id=$1",
                        char_id, json.dumps(counters))
                inventory = await conn.fetchrow(
                    """INSERT INTO inventory(char_id,item_id,count) VALUES($1,$2,$3)
                       ON CONFLICT(char_id,item_id) DO UPDATE SET count=inventory.count+EXCLUDED.count
                       RETURNING count""", char_id, item_id, quantity)
                updated = await conn.fetchrow(
                    "SELECT * FROM characters WHERE char_id=$1", char_id)
                return {"character": updated,
                        "item_id": item_id, "item_count": int(inventory["count"]), "counters": counters}

    async def apply_local_recharge(self, char_id: int, order_key: str,
                                   package_kind: str, package: dict,
                                   diamonds: int, paid_amount: int):
        """Apply one catalogued local simulation, idempotently and atomically."""
        if package_kind not in ("normal", "month") or not order_key:
            return None
        package_id = int(package["id"])
        if package_id <= 0 or diamonds <= 0 or paid_amount <= 0:
            return None
        if package_kind == "month" and int(package.get("days", 0)) <= 0:
            return None
        rewards = {"diamond": diamonds}
        if package_kind == "month":
            rewards.update({"days": int(package["days"]),
                            "mCashPerDay": int(package["mCashPerDay"])})
        async with self.pool.acquire() as conn:
            async with conn.transaction():
                char = await conn.fetchrow(
                    "SELECT * FROM characters WHERE char_id=$1 FOR UPDATE", char_id)
                if char is None:
                    return None
                old = await conn.fetchrow(
                    "SELECT package_kind,package_id FROM local_recharge_transactions "
                    "WHERE char_id=$1 AND order_key=$2", char_id, order_key)
                if old is not None:
                    if old["package_kind"] != package_kind or int(old["package_id"]) != package_id:
                        return None
                    current = await conn.fetchrow(
                        "SELECT * FROM characters WHERE char_id=$1", char_id)
                    return {"character": current, "duplicate": True,
                            "package_kind": package_kind, "package_id": package_id}
                if package_kind == "normal":
                    await conn.execute(
                        "UPDATE characters SET diamond=diamond+$2,recharge_total=recharge_total+$3 "
                        "WHERE char_id=$1", char_id, diamonds, paid_amount)
                else:
                    expires = await conn.fetchval(
                        """INSERT INTO local_month_cards(char_id,package_id,expires_at)
                           VALUES($1,$2,now()+$3 * interval '1 day')
                           ON CONFLICT (char_id,package_id) DO UPDATE SET expires_at=
                               greatest(local_month_cards.expires_at,now())+$3 * interval '1 day'
                           RETURNING expires_at""", char_id, package_id, int(package["days"]))
                    await conn.execute(
                        """UPDATE characters SET diamond=diamond+$2,
                           recharge_total=recharge_total+$3,
                           month_card_until=greatest(month_card_until,$4)
                           WHERE char_id=$1""",
                        char_id, diamonds, paid_amount, expires)
                await conn.execute(
                    """INSERT INTO local_recharge_transactions
                       (char_id,order_key,package_kind,package_id,paid_amount,rewards,simulated)
                       VALUES($1,$2,$3,$4,$5,$6::jsonb,TRUE)""",
                    char_id, order_key, package_kind, package_id, paid_amount,
                    json.dumps(rewards, separators=(",", ":")))
                updated = await conn.fetchrow(
                    "SELECT * FROM characters WHERE char_id=$1", char_id)
                return {"character": updated, "duplicate": False,
                        "package_kind": package_kind, "package_id": package_id}

    async def local_month_cards(self, char_id: int):
        return await self.pool.fetch(
            """SELECT package_id, extract(epoch FROM expires_at)::bigint AS expires,
                      COALESCE(last_claim_day*86400,0) AS last_claim
               FROM local_month_cards WHERE char_id=$1 ORDER BY package_id""", char_id)

    async def claim_local_month_card(self, char_id: int, package_id: int, diamonds: int):
        async with self.pool.acquire() as conn, conn.transaction():
            await conn.fetchval("SELECT char_id FROM characters WHERE char_id=$1 FOR UPDATE", char_id)
            # Client resets at 06:00 in the server's UTC+07 timezone.
            claim_day = await conn.fetchval(
                "SELECT floor((extract(epoch FROM now())+25200-21600)/86400)::bigint")
            card = await conn.fetchrow(
                """SELECT last_claim_day,expires_at>now() AS active
                   FROM local_month_cards WHERE char_id=$1 AND package_id=$2""",
                char_id, package_id)
            if card is None or not card["active"]:
                return None
            if card["last_claim_day"] is None or card["last_claim_day"] < claim_day:
                await conn.execute(
                    """UPDATE local_month_cards SET last_claim_day=$3
                       WHERE char_id=$1 AND package_id=$2""", char_id, package_id, claim_day)
                return await conn.fetchrow(
                    "UPDATE characters SET diamond=diamond+$2 WHERE char_id=$1 RETURNING *",
                    char_id, diamonds)
            return await conn.fetchrow("SELECT * FROM characters WHERE char_id=$1", char_id)

    async def adventure_clears(self, char_id: int):
        return await self.pool.fetch(
            """SELECT adventure_id AS "advID",star_mask AS star
               FROM character_adventure_clears WHERE char_id=$1 ORDER BY adventure_id""",
            char_id,
        )

    async def close(self) -> None:
        await self.pool.close()

    async def account_for_device(self, device_id: str, world_id: int = 1) -> asyncpg.Record | None:
        return await self.pool.fetchrow(
            """SELECT a.* FROM accounts a JOIN device_bindings d ON d.account_id=a.user_id
               WHERE d.device_id=$1 AND d.world_id=$2""", device_id, world_id
        )

    async def create_account(self, username: str, token: str) -> asyncpg.Record:
        return await self.pool.fetchrow(
            "INSERT INTO accounts(username,token) VALUES($1,$2) RETURNING *", username, token
        )

    async def upsert_account(self, username: str, token: str) -> asyncpg.Record:
        return await self.pool.fetchrow(
            """INSERT INTO accounts(username,token) VALUES($1,$2)
               ON CONFLICT(username) DO UPDATE SET token=EXCLUDED.token RETURNING *""",
            username, token,
        )

    async def bind_device(self, device_id: str, world_id: int, device_token: str,
                          account_id: int) -> None:
        async with self.pool.acquire() as conn:
            async with conn.transaction():
                token_owner = await conn.fetchrow(
                    "SELECT device_id,world_id,account_id FROM device_bindings WHERE device_token=$1 FOR UPDATE",
                    device_token,
                )
                if token_owner is not None and token_owner["account_id"] != account_id:
                    raise ValueError("device token is already bound to another account")
                if token_owner is not None and (token_owner["device_id"], token_owner["world_id"]) != (device_id, world_id):
                    # Move an obsolete binding only within the same account.
                    await conn.execute(
                        "DELETE FROM device_bindings WHERE device_id=$1 AND world_id=$2",
                        token_owner["device_id"], token_owner["world_id"],
                    )
                await conn.execute(
                    """INSERT INTO device_bindings(device_id,world_id,device_token,account_id)
                       VALUES($1,$2,$3,$4) ON CONFLICT(device_id,world_id) DO UPDATE
                       SET device_token=EXCLUDED.device_token,account_id=EXCLUDED.account_id""",
                    device_id, world_id, device_token, account_id,
                )

    async def character(self, account_id: int, world_id: int = 1) -> asyncpg.Record | None:
        return await self.pool.fetchrow(
            "SELECT * FROM characters WHERE account_id=$1 AND world_id=$2", account_id, world_id
        )

    async def create_character(self, account_id: int, world_id: int, name: str,
                               avatar: int = 0, gender: int = 0) -> asyncpg.Record:
        return await self.pool.fetchrow(
            """INSERT INTO characters(account_id,world_id,name,avatar,gender)
               VALUES($1,$2,$3,$4,$5) RETURNING *""", account_id, world_id, name, avatar, gender
        )

    async def create_starting_pet(self, char_id: int, template_id: int) -> asyncpg.Record:
        from pet_config import starting_skills
        skills, passive = starting_skills(template_id)
        return await self.pool.fetchrow(
            """INSERT INTO pets(char_id,pet_template_id,slot_index,skills_json,passive_skills_json)
               VALUES($1,$2,0,$3::jsonb,$4::jsonb) RETURNING *""",
            char_id, template_id, json.dumps(skills), json.dumps(passive)
        )

    async def create_character_with_pet(self, account_id: int, world_id: int, name: str,
                                        avatar: int, gender: int, pet_template_id: int,
                                        initial_fashions: list[int] | None = None):
        async with self.pool.acquire() as conn:
            async with conn.transaction():
                await conn.fetchrow("SELECT user_id FROM accounts WHERE user_id=$1 FOR UPDATE", account_id)
                char = await conn.fetchrow(
                    "SELECT * FROM characters WHERE account_id=$1 AND world_id=$2 FOR UPDATE",
                    account_id, world_id,
                )
                created = char is None
                if char is None:
                    from fashion_config import initial_fashion_state
                    fashion_state = initial_fashion_state(initial_fashions or [])
                    char = await conn.fetchrow(
                        """INSERT INTO characters(account_id,world_id,name,avatar,gender,game_values)
                           VALUES($1,$2,$3,$4,$5,$6::jsonb) RETURNING *""",
                        account_id, world_id, name, avatar, gender,
                        json.dumps({"curfashion": json.dumps(fashion_state["curFashion"], separators=(",", ":")),
                                    "fashion_info": fashion_state}),
                    )
                first_pet = await conn.fetchrow(
                    "SELECT * FROM pets WHERE char_id=$1 ORDER BY pet_uid LIMIT 1", char["char_id"]
                )
                if first_pet is None and pet_template_id:
                    from pet_config import starting_skills
                    skills, passive = starting_skills(pet_template_id)
                    first_pet = await conn.fetchrow(
                        """INSERT INTO pets(char_id,pet_template_id,slot_index,skills_json,passive_skills_json)
                           VALUES($1,$2,0,$3::jsonb,$4::jsonb) RETURNING *""",
                        char["char_id"], pet_template_id, json.dumps(skills), json.dumps(passive),
                    )
                # NewQuestInfo.dat for client 1.0.128745 defines quest 1 as
                # the first strong tutorial quest. Seed only newly created
                # characters; never rewrite existing progression at login.
                if created:
                    await conn.execute(
                        """INSERT INTO quests(char_id,quest_id,status,progress)
                           VALUES($1,1,0,'[0]'::jsonb)
                           ON CONFLICT(char_id,quest_id) DO NOTHING""",
                        char["char_id"],
                    )
                    await conn.execute(
                        """INSERT INTO homes(char_id,home_data)
                           VALUES($1,jsonb_build_object('level',1,'homeName',$2::text,'furnitures','{}'::jsonb))
                           ON CONFLICT(char_id) DO NOTHING""",
                        char["char_id"], char["name"],
                    )
        return char, first_pet

    async def ensure_first_quest_for_level_one(self, char_id: int) -> None:
        """Restore the configured first quest only for a level-one character with no quest state."""
        await self.pool.execute(
            """INSERT INTO quests(char_id,quest_id,status,progress)
               SELECT c.char_id,1,0,'[0]'::jsonb
               FROM characters c
               WHERE c.char_id=$1 AND c.level=1
                 AND NOT EXISTS (SELECT 1 FROM quests q WHERE q.char_id=c.char_id)
               ON CONFLICT(char_id,quest_id) DO NOTHING""",
            char_id,
        )
        # The configured objective for quest 1 is to obtain the starter Pet.
        # Pet presence is the server-side fact, so repair its progress when a
        # legacy account already owns one instead of trusting a client update.
        await self.pool.execute(
            """UPDATE quests q SET progress='[1]'::jsonb
               WHERE q.char_id=$1 AND q.quest_id=1 AND q.status=0
                 AND EXISTS (SELECT 1 FROM pets p WHERE p.char_id=q.char_id)
                 AND COALESCE((q.progress->>0)::integer,0)<1""",
            char_id,
        )

    async def home_state(self, char_id: int) -> dict[str, Any] | None:
        async with self.pool.acquire() as conn:
            character = await conn.fetchrow(
                "SELECT char_id,name FROM characters WHERE char_id=$1", char_id)
            if character is None:
                return None
            row = await conn.fetchrow(
                "SELECT home_data FROM homes WHERE char_id=$1", char_id)
        data: Any = row["home_data"] if row is not None else None
        if isinstance(data, str):
            data = json.loads(data)
        if data is None:
            data = {"level": 1, "homeName": character["name"], "furnitures": {}}
        if not isinstance(data, dict):
            raise ValueError(f"invalid home_data for character {char_id}")
        data = dict(data)
        data.setdefault("level", 1)
        data.setdefault("homeName", character["name"])
        data.setdefault("furnitures", {})
        if not isinstance(data["level"], int) or not isinstance(data["homeName"], str) or not isinstance(data["furnitures"], dict):
            raise ValueError(f"invalid home_data fields for character {char_id}")
        return data

    async def update_configured_tutorial_progress(self, char_id: int, quest_id: int,
                                                 progress: list[int], amount: int) -> bool:
        """Accept client progress only when an independent server fact proves it."""
        if progress != [amount] or amount <= 0:
            return False
        async with self.pool.acquire() as conn:
            async with conn.transaction():
                character = await conn.fetchrow(
                    "SELECT level,game_values FROM characters WHERE char_id=$1 FOR UPDATE", char_id)
                quest = await conn.fetchrow(
                    "SELECT status FROM quests WHERE char_id=$1 AND quest_id=$2 FOR UPDATE",
                    char_id, quest_id)
                if character is None or quest is None or quest["status"] != 0:
                    return False
                from quest_config import load_quests
                configured = load_quests().get(quest_id)
                if (configured and len(configured.objectives) == 1
                        and configured.objectives[0].event_type == 18):
                    objective = configured.objectives[0]
                    from battle_group_config import world_map_event_types, world_map_node_unlocks
                    event_type = world_map_event_types().get(objective.final_id)
                    if event_type == 2:
                        # EmbeddedMapMgr's type-3 gift calls QuestInfo.sendQuestUpdate
                        # after a successful tap (result=998). Validate that exact
                        # configured node is unlocked, then claim it once.
                        values = character.get("game_values")
                        if isinstance(values, str): values = json.loads(values)
                        if not isinstance(values, dict):
                            return False
                        try:
                            map_lock = int(str(values.get("map_lock", "0-0")).split("-", 1)[0])
                        except ValueError:
                            return False
                        node_lock = world_map_node_unlocks().get(
                            (objective.main_id, objective.sub_id))
                        if node_lock is None or node_lock > map_lock:
                            return False
                        saved = await conn.fetchval(
                            "SELECT progress FROM quests WHERE char_id=$1 AND quest_id=$2",
                            char_id, quest_id)
                        if isinstance(saved, str): saved = json.loads(saved)
                        if isinstance(saved, list) and saved == [amount]:
                            return True
                        if not isinstance(saved, list) or saved != [0]:
                            return False
                        claim = await conn.fetchval(
                            """INSERT INTO world_map_node_claims(char_id,quest_id,map_id,node_id)
                               VALUES($1,$2,$3,$4) ON CONFLICT DO NOTHING RETURNING 1""",
                            char_id, quest_id, objective.main_id, objective.sub_id)
                        if not claim:
                            return False
                        await conn.execute(
                            "UPDATE quests SET progress=$3::jsonb WHERE char_id=$1 AND quest_id=$2 AND status=0",
                            char_id, quest_id, json.dumps([amount]))
                        return True
                    # Lua echoes the progress after its node battle. The server
                    # already advanced this objective from the won encounter.
                    saved = await conn.fetchval(
                        "SELECT progress FROM quests WHERE char_id=$1 AND quest_id=$2",
                        char_id, quest_id)
                    if isinstance(saved, str): saved = json.loads(saved)
                    return isinstance(saved, list) and saved == [amount]
                if quest_id == 1:
                    valid = await conn.fetchval("SELECT 1 FROM pets WHERE char_id=$1 LIMIT 1", char_id)
                elif quest_id == 10002:
                    # This is the exact alternate branch in GameGuideMgr.firstAdventure().
                    valid = character["level"] >= 2
                elif quest_id == 10003:
                    valid = await conn.fetchval(
                        "SELECT 1 FROM quests WHERE char_id=$1 AND quest_id=2 AND status=1", char_id)
                else:
                    # The battle objective is set only by finish_tutorial_battle().
                    return False
                if not valid:
                    return False
                await conn.execute(
                    "UPDATE quests SET progress=$3::jsonb WHERE char_id=$1 AND quest_id=$2",
                    char_id, quest_id, json.dumps(progress))
                return True

    async def start_tutorial_battle(self, char_id: int, session_id: str, group_id: int) -> bool:
        from battle_group_config import tutorial_requirements
        requirement = tutorial_requirements().get(group_id)
        if requirement is None:
            return False
        async with self.pool.acquire() as conn:
            async with conn.transaction():
                active = await conn.fetchval(
                    "SELECT 1 FROM quests WHERE char_id=$1 AND quest_id=$2 AND status=0",
                    char_id, int(requirement["quest_id"]))
                if not active:
                    return False
                existing = await conn.fetchrow(
                    """SELECT battle_id,group_id,battle_type FROM tutorial_battle_sessions
                       WHERE char_id=$1 AND state='started' ORDER BY battle_id DESC
                       LIMIT 1 FOR UPDATE""", char_id)
                if existing is not None:
                    if int(existing["battle_type"]) == 5 and int(existing["group_id"]) == group_id:
                        await conn.execute("UPDATE tutorial_battle_sessions SET session_id=$2 WHERE battle_id=$1",
                                           existing["battle_id"], session_id)
                        return True
                    await conn.execute(
                        "UPDATE tutorial_battle_sessions SET state='lost',finished_at=now() WHERE battle_id=$1",
                        existing["battle_id"])
                await conn.execute(
                    "INSERT INTO tutorial_battle_sessions(char_id,session_id,group_id,state) "
                    "VALUES($1,$2,$3,'started')", char_id, session_id, group_id)
                return True

    async def start_world_map_quest_battle(self, char_id: int, session_id: str,
                                           group_id: int) -> bool:
        """Authorize a trainer battle only for one exact active event-18 quest node."""
        from battle_group_config import world_map_node_unlocks, world_map_trainer_events
        from quest_config import load_quests
        event_groups = world_map_trainer_events()
        quests = load_quests()
        matching: list[tuple[int, int, int]] = []
        for quest_id, quest in quests.items():
            for objective in quest.objectives:
                if (objective.event_type == 18
                        and event_groups.get(objective.final_id) == group_id):
                    matching.append((quest_id, objective.main_id, objective.sub_id))
        if not matching:
            return False
        node_unlocks = world_map_node_unlocks()
        async with self.pool.acquire() as conn:
            async with conn.transaction():
                character = await conn.fetchrow(
                    "SELECT game_values FROM characters WHERE char_id=$1 FOR UPDATE", char_id)
                if character is None:
                    return False
                values = character["game_values"] or {}
                if isinstance(values, str): values = json.loads(values)
                lock_parts = str(values.get("map_lock", "0-0")).split("-", 1)
                try:
                    unlocked_node = int(lock_parts[0])
                except ValueError:
                    return False
                eligible_nodes = [(qid, node_unlocks.get((map_id, node_id)))
                                  for qid, map_id, node_id in matching]
                eligible_nodes = [(qid, lock) for qid, lock in eligible_nodes
                                  if lock is not None and lock <= unlocked_node]
                active_ids = [qid for qid, _ in eligible_nodes]
                if not active_ids:
                    return False
                active = await conn.fetch(
                    """SELECT quest_id FROM quests WHERE char_id=$1 AND quest_id=ANY($2::int[])
                       AND status=0 FOR UPDATE""", char_id, active_ids)
                # Without a map ID in the request, overlapping active map-node
                # objectives are ambiguous; fail closed rather than credit all.
                if len(active) != 1:
                    return False
                previous = await conn.fetchrow(
                    """SELECT battle_id,group_id,battle_type,battle_type_id
                       FROM tutorial_battle_sessions WHERE char_id=$1 AND state='started'
                       ORDER BY battle_id DESC LIMIT 1 FOR UPDATE""", char_id)
                if previous is not None:
                    if (int(previous["battle_type"]) == 5
                            and int(previous["battle_type_id"]) == group_id):
                        await conn.execute("UPDATE tutorial_battle_sessions SET session_id=$2 WHERE battle_id=$1",
                                           previous["battle_id"], session_id)
                        return True
                    await conn.execute(
                        "UPDATE tutorial_battle_sessions SET state='lost',finished_at=now() WHERE battle_id=$1",
                        previous["battle_id"])
                await conn.execute(
                    """INSERT INTO tutorial_battle_sessions
                       (char_id,session_id,group_id,battle_type,battle_type_id,state)
                       VALUES($1,$2,$3,5,$3,'started')""", char_id, session_id, group_id)
                return True

    async def start_world_map_quest_wild(self, char_id: int, session_id: str,
                                         monster_id: int) -> bool:
        """Authorize a map wild battle against one active, unlocked event-18 node."""
        from battle_group_config import world_map_node_unlocks, world_map_wild_events
        from quest_config import load_quests
        event_monsters = world_map_wild_events()
        matching = [(qid, obj.main_id, obj.sub_id) for qid, quest in load_quests().items()
                    for obj in quest.objectives
                    if obj.event_type == 18 and event_monsters.get(obj.final_id) == monster_id]
        if not matching:
            return False
        node_unlocks = world_map_node_unlocks()
        async with self.pool.acquire() as conn:
            async with conn.transaction():
                character = await conn.fetchrow(
                    "SELECT game_values FROM characters WHERE char_id=$1 FOR UPDATE", char_id)
                if character is None:
                    return False
                values = character["game_values"] or {}
                if isinstance(values, str): values = json.loads(values)
                try:
                    map_lock = int(str(values.get("map_lock", "0-0")).split("-", 1)[0])
                except (AttributeError, ValueError):
                    return False
                eligible = [(qid, map_id, node_id) for qid, map_id, node_id in matching
                            if (node_unlocks.get((map_id, node_id)) is not None
                                and node_unlocks[(map_id, node_id)] <= map_lock)]
                active_ids = list({qid for qid, _, _ in eligible})
                active = await conn.fetch(
                    """SELECT quest_id FROM quests WHERE char_id=$1 AND quest_id=ANY($2::int[])
                       AND status=0 FOR UPDATE""", char_id, active_ids)
                active_set = {int(row["quest_id"]) for row in active}
                active_nodes = [entry for entry in eligible if entry[0] in active_set]
                # The battle request omits map and node IDs. If the same
                # monster appears in multiple active, reachable objectives,
                # do not guess which one the client entered.
                if len(active_nodes) != 1:
                    return False
                previous = await conn.fetchrow(
                    """SELECT battle_id,battle_type,battle_type_id FROM tutorial_battle_sessions
                       WHERE char_id=$1 AND state='started' ORDER BY battle_id DESC LIMIT 1 FOR UPDATE""",
                    char_id)
                if previous is not None:
                    if int(previous["battle_type"]) == 1 and int(previous["battle_type_id"]) == monster_id:
                        await conn.execute("UPDATE tutorial_battle_sessions SET session_id=$2 WHERE battle_id=$1",
                                           previous["battle_id"], session_id)
                        return True
                    await conn.execute(
                        "UPDATE tutorial_battle_sessions SET state='lost',finished_at=now() WHERE battle_id=$1",
                        previous["battle_id"])
                await conn.execute(
                    """INSERT INTO tutorial_battle_sessions
                       (char_id,session_id,group_id,battle_type,battle_type_id,state)
                       VALUES($1,$2,$3,1,$3,'started')""", char_id, session_id, monster_id)
                return True

    async def start_tutorial_wild_battle(self, char_id: int, session_id: str,
                                         monster_id: int, quest_id: int,
                                         capture_attempts: int) -> bool:
        from battle_group_config import tutorial_wild_requirements
        requirement = tutorial_wild_requirements().get(monster_id)
        if requirement is None or int(requirement["quest_id"]) != quest_id:
            return False
        async with self.pool.acquire() as conn:
            async with conn.transaction():
                active = await conn.fetchval(
                    "SELECT 1 FROM quests WHERE char_id=$1 AND quest_id=$2 AND status=0 FOR UPDATE",
                    char_id, quest_id)
                if not active:
                    return False
                existing = await conn.fetchrow(
                    """SELECT battle_id,battle_type,battle_type_id FROM tutorial_battle_sessions
                       WHERE char_id=$1 AND state='started' ORDER BY battle_id DESC
                       LIMIT 1 FOR UPDATE""", char_id)
                if existing is not None:
                    if (int(existing["battle_type"]) == 1
                            and int(existing["battle_type_id"]) == monster_id):
                        await conn.execute("UPDATE tutorial_battle_sessions SET session_id=$2 WHERE battle_id=$1",
                                           existing["battle_id"], session_id)
                        return True
                    await conn.execute(
                        "UPDATE tutorial_battle_sessions SET state='lost',finished_at=now() WHERE battle_id=$1",
                        existing["battle_id"])
                await conn.execute(
                    "INSERT INTO tutorial_battle_sessions"
                    "(char_id,session_id,group_id,battle_type,battle_type_id,state,capture_attempts_remaining) "
                    "VALUES($1,$2,$3,1,$3,'started',$4)",
                    char_id, session_id, monster_id, capture_attempts)
                return True

    async def capture_wild_pet(self, char_id: int, session_id: str, monster_id: int,
                               ball_item_id: int, roll: int | None = None):
        """Consume a configured ball for the live encounter's Pet template ID.

        The client serializer calls this field pokemonID and BattleMapMgr
        supplies MonstrosityInfo.petnumber, not the encounter's mID.
        """
        from client_config import table
        from pet_config import starting_skills
        import secrets

        requirements = __import__("battle_group_config").tutorial_wild_requirements()
        monsters = table("MonstrosityInfo")
        candidates = {encounter_id: monsters[encounter_id]
                      for encounter_id in requirements
                      if encounter_id in monsters
                      and int(monsters[encounter_id]["petnumber"]) == monster_id}
        item = table("ItemInfo").get(ball_item_id)
        ball = table("PokemonBallInfo").get(ball_item_id)
        if not candidates or item is None or ball is None or int(item["itemType"]) != 9:
            return None
        template_id = monster_id
        template = table("PokemonInfo").get(template_id)
        if template is None:
            return None
        rarity = int(template["rarePoint"])
        rarity_key = {1: "c", 2: "b", 3: "a", 4: "s", 5: "ss"}.get(rarity)
        rates = ball.get(rarity_key) if rarity_key else None
        if not rates or len(rates) < 2:
            return None
        chance = max(0, min(100, int(rates[0])))
        draw = secrets.randbelow(100) if roll is None else int(roll)
        if not 0 <= draw <= 99:
            raise ValueError("capture roll outside [0,99]")
        async with self.pool.acquire() as conn:
            async with conn.transaction():
                # Reconnect establishes a new TCP session ID. Resolve the
                # encounter from its authenticated owner and lock it once.
                battle = await conn.fetchrow(
                    """SELECT * FROM tutorial_battle_sessions WHERE char_id=$1
                       AND battle_type=1 AND battle_type_id=ANY($2::integer[])
                       AND state IN ('started','won')
                       ORDER BY battle_id DESC LIMIT 1 FOR UPDATE""",
                    char_id, list(candidates))
                if battle is None:
                    return None
                requirement = requirements[int(battle["battle_type_id"])]
                monster = candidates[int(battle["battle_type_id"])]
                if int(monster["capture"]) <= 0:
                    return None
                if battle["captured_pet_uid"] is not None:
                    existing = await conn.fetchrow(
                        "SELECT * FROM pets WHERE char_id=$1 AND pet_uid=$2",
                        char_id, battle["captured_pet_uid"])
                    if existing is None:
                        raise ValueError("captured Pet reference is missing")
                    from handlers.pet import pet_json
                    return {"caught": True, "pet_uid": int(existing["pet_uid"]),
                            "pet_json": pet_json(existing), "remaining": int(battle["capture_attempts_remaining"]),
                            "rate_bonus": 0, "duplicate": True}
                if battle["state"] not in ("started", "won") or int(battle["capture_attempts_remaining"]) <= 0:
                    return None
                character = await conn.fetchrow(
                    "SELECT char_id FROM characters WHERE char_id=$1 FOR UPDATE", char_id)
                inventory = await conn.fetchrow(
                    "SELECT count FROM inventory WHERE char_id=$1 AND item_id=$2 FOR UPDATE",
                    char_id, ball_item_id)
                if character is None or inventory is None or int(inventory["count"]) < 1:
                    return None
                attempt_no = int(await conn.fetchval(
                    "SELECT count(*) FROM wild_battle_capture_attempts WHERE battle_id=$1",
                    battle["battle_id"])) + 1
                caught = draw < chance
                await conn.execute(
                    "UPDATE inventory SET count=count-1 WHERE char_id=$1 AND item_id=$2",
                    char_id, ball_item_id)
                if int(inventory["count"]) == 1:
                    await conn.execute(
                        "DELETE FROM inventory WHERE char_id=$1 AND item_id=$2 AND count=0",
                        char_id, ball_item_id)
                remaining = int(battle["capture_attempts_remaining"]) - 1
                await conn.execute(
                    "UPDATE tutorial_battle_sessions SET capture_attempts_remaining=$2 WHERE battle_id=$1",
                    battle["battle_id"], remaining)
                await conn.execute(
                    """INSERT INTO wild_battle_capture_attempts
                       (battle_id,attempt_no,ball_item_id,catch_rate,roll,caught,rate_bonus)
                       VALUES($1,$2,$3,$4,$5,$6,0)""",
                    battle["battle_id"], attempt_no, ball_item_id, chance, draw, caught)
                result = {"caught": caught, "remaining": remaining, "rate_bonus": 0,
                          "duplicate": False, "pet_uid": 0, "pet_json": ""}
                if caught:
                    level = max(1, int(monster["level"][0]))
                    stage, star = int(monster["petStage"]), int(monster["petStar"])
                    skills, passive = starting_skills(template_id)
                    pet = await conn.fetchrow(
                        """INSERT INTO pets(char_id,pet_template_id,level,star,training_stage,
                           skills_json,passive_skills_json,slot_index)
                           VALUES($1,$2,$3,$4,$5,$6::jsonb,$7::jsonb,-1) RETURNING *""",
                        char_id, template_id, level, star, stage,
                        json.dumps(skills), json.dumps(passive))
                    from handlers.pet import pet_json
                    serialized = pet_json(pet)
                    await conn.execute(
                        "UPDATE tutorial_battle_sessions SET captured_pet_uid=$2 WHERE battle_id=$1",
                        battle["battle_id"], pet["pet_uid"])
                    quest_id = int(requirement["quest_id"])
                    quest = await conn.fetchrow(
                        "SELECT progress FROM quests WHERE char_id=$1 AND quest_id=$2 AND status=0 FOR UPDATE",
                        char_id, quest_id)
                    if quest is None:
                        raise ValueError("capture quest is no longer active")
                    progress = quest["progress"]
                    if isinstance(progress, str):
                        progress = json.loads(progress)
                    if not isinstance(progress, list):
                        raise ValueError("capture quest progress is not an objective vector")
                    from quest_config import load_quests
                    quest_config = load_quests().get(quest_id)
                    indexes = [index for index, objective in enumerate(quest_config.objectives)
                               if objective.event_type == 2] if quest_config else []
                    for index in indexes:
                        while len(progress) <= index:
                            progress.append(0)
                        progress[index] = max(int(progress[index]), quest_config.objectives[index].amount)
                    await conn.execute(
                        "UPDATE quests SET progress=$3::jsonb WHERE char_id=$1 AND quest_id=$2",
                        char_id, quest_id, json.dumps(progress))
                    result.update(pet_uid=int(pet["pet_uid"]), pet_json=serialized)
                return result

    async def start_adventure_battle(self, char_id: int, session_id: str, adventure_id: int,
                                     scene_id: int, group_id: int) -> bool:
        async with self.pool.acquire() as conn:
            async with conn.transaction():
                active_adventure = await conn.fetchval(
                    """SELECT adventure_id FROM character_adventures
                       WHERE char_id=$1 AND completed_at IS NULL FOR UPDATE""", char_id)
                if active_adventure != adventure_id:
                    return False
                existing = await conn.fetchrow(
                    """SELECT battle_id,battle_type,battle_type_id,adventure_id
                       FROM tutorial_battle_sessions WHERE char_id=$1 AND state='started'
                       ORDER BY battle_id DESC LIMIT 1 FOR UPDATE""", char_id)
                if existing is not None:
                    if (int(existing["battle_type"]) == 3
                            and int(existing["battle_type_id"]) == scene_id
                            and int(existing["adventure_id"]) == adventure_id):
                        await conn.execute("UPDATE tutorial_battle_sessions SET session_id=$2 WHERE battle_id=$1",
                                           existing["battle_id"], session_id)
                        return True
                    await conn.execute(
                        "UPDATE tutorial_battle_sessions SET state='lost',finished_at=now() WHERE battle_id=$1",
                        existing["battle_id"])
                await conn.execute(
                    """INSERT INTO tutorial_battle_sessions
                       (char_id,session_id,group_id,battle_type,battle_type_id,adventure_id,state)
                       VALUES($1,$2,$3,3,$4,$5,'started')""",
                    char_id, session_id, group_id, scene_id, adventure_id)
                return True

    async def finish_tutorial_battle(self, char_id: int, session_id: str, won: bool) -> bool:
        async with self.pool.acquire() as conn:
            async with conn.transaction():
                # After reconnect, a fresh authenticated TCP session must be
                # able to finish the character's active server-issued battle.
                # The locked state transition still makes the end request one-use.
                battle = await conn.fetchrow(
                    """SELECT battle_id,group_id,battle_type FROM tutorial_battle_sessions
                       WHERE char_id=$1 AND state='started'
                       ORDER BY battle_id DESC LIMIT 1 FOR UPDATE""", char_id)
                if battle is None:
                    return False
                await conn.execute(
                    "UPDATE tutorial_battle_sessions SET state=$2,finished_at=now() WHERE battle_id=$1",
                    battle["battle_id"], "won" if won else "lost")
                if won:
                    from battle_group_config import tutorial_requirements
                    requirement = tutorial_requirements().get(battle["group_id"])
                    tutorial_handled = False
                    if requirement is not None and battle["battle_type"] == 5:
                        from quest_config import load_quests
                        quest = load_quests().get(int(requirement["quest_id"]))
                        active_quest = (await conn.fetchval(
                            "SELECT 1 FROM quests WHERE char_id=$1 AND quest_id=$2 AND status=0 FOR UPDATE",
                            char_id, quest.quest_id) if quest else None)
                        if quest and quest.objectives and active_quest:
                            await conn.execute(
                                "UPDATE quests SET progress=$3::jsonb WHERE char_id=$1 AND quest_id=$2 AND status=0",
                                char_id, quest.quest_id,
                                json.dumps([objective.amount for objective in quest.objectives]))
                            tutorial_handled = True
                    elif battle["battle_type"] == 3:
                        await self._advance_configured_battle_objectives(conn, char_id)
                    if battle["battle_type"] == 5 and not tutorial_handled:
                        await self._advance_world_map_trainer_objectives(
                            conn, char_id, int(battle["group_id"]))
                    elif battle["battle_type"] == 1:
                        await self._advance_world_map_wild_objectives(
                            conn, char_id, int(battle["group_id"]))
                return True

    @staticmethod
    async def _advance_world_map_trainer_objectives(conn, char_id: int, group_id: int) -> None:
        from battle_group_config import world_map_trainer_events
        from quest_config import load_quests
        event_groups = world_map_trainer_events()
        config = load_quests()
        active = await conn.fetch(
            "SELECT quest_id,progress FROM quests WHERE char_id=$1 AND status=0 FOR UPDATE", char_id)
        matching_quests = []
        for row in active:
            quest = config.get(row["quest_id"])
            if quest is None:
                continue
            matching = [i for i, objective in enumerate(quest.objectives)
                        if objective.event_type == 18
                        and event_groups.get(objective.final_id) == group_id]
            if matching:
                matching_quests.append((row, quest, matching))
        # A trainer group shared by multiple simultaneously active map quests
        # cannot be attributed to a specific map because this request omits it.
        if len(matching_quests) != 1:
            return
        row, quest, indexes = matching_quests[0]
        progress = row["progress"]
        if isinstance(progress, str): progress = json.loads(progress)
        if not isinstance(progress, list) or len(progress) != len(quest.objectives):
            return
        values = list(progress)
        changed = False
        for index in indexes:
            amount = quest.objectives[index].amount
            if type(values[index]) is int and values[index] < amount:
                values[index] = amount
                changed = True
        if changed:
            await conn.execute(
                "UPDATE quests SET progress=$3::jsonb WHERE char_id=$1 AND quest_id=$2",
                char_id, quest.quest_id, json.dumps(values))

    @staticmethod
    async def _advance_world_map_wild_objectives(conn, char_id: int, monster_id: int) -> None:
        from battle_group_config import world_map_node_unlocks, world_map_wild_events
        from quest_config import load_quests
        event_monsters = world_map_wild_events()
        active = await conn.fetch(
            "SELECT quest_id,progress FROM quests WHERE char_id=$1 AND status=0 FOR UPDATE", char_id)
        matching = []
        for row in active:
            quest = load_quests().get(row["quest_id"])
            if quest is None:
                continue
            for i, obj in enumerate(quest.objectives):
                if obj.event_type == 18 and event_monsters.get(obj.final_id) == monster_id:
                    matching.append((row, quest, i))
        if len(matching) != 1:
            return
        row, quest, index = matching[0]
        progress = row["progress"]
        if isinstance(progress, str): progress = json.loads(progress)
        if not isinstance(progress, list) or len(progress) != len(quest.objectives):
            return
        values = list(progress)
        changed = False
        objective = quest.objectives[index]
        lock = world_map_node_unlocks().get((objective.main_id, objective.sub_id))
        if lock is not None and type(values[index]) is int and values[index] < objective.amount:
            values[index] = objective.amount
            changed = True
        if changed:
            await conn.execute(
                "UPDATE quests SET progress=$3::jsonb WHERE char_id=$1 AND quest_id=$2",
                char_id, quest.quest_id, json.dumps(values))

    async def last_tutorial_battle_exp(self, char_id: int) -> int:
        """Recompute configured battle EXP after a reconnect lost session memory."""
        battle = await self.pool.fetchrow(
            """SELECT group_id,battle_type FROM tutorial_battle_sessions
               WHERE char_id=$1 AND state='won' ORDER BY battle_id DESC LIMIT 1""", char_id)
        if battle is None:
            return 0
        from client_config import table
        group_id = int(battle["group_id"])
        if int(battle["battle_type"]) == 1:
            row = table("MonstrosityInfo").get(group_id)
            return int(row["exp"]) if row else 0
        row = table("MonsterGroupManInfo").get(group_id)
        return int(row["exp"]) if row else 0

    async def advance_pet_training_stage(self, char_id: int, pet_uid: int) -> int | None:
        """Atomically charge and persist one configured Pet Stage increase."""
        from client_config import table
        async with self.pool.acquire() as conn:
            async with conn.transaction():
                char = await conn.fetchrow(
                    "SELECT level,gold,diamond FROM characters WHERE char_id=$1 FOR UPDATE",
                    char_id)
                pet = await conn.fetchrow(
                    "SELECT pet_uid,pet_template_id,level,training_stage FROM pets "
                    "WHERE pet_uid=$1 AND char_id=$2 FOR UPDATE", pet_uid, char_id)
                if char is None or pet is None:
                    return None
                pokemon = table("PokemonInfo").get(pet["pet_template_id"])
                if pokemon is None:
                    raise ValueError("unknown Pet template")
                new_stage = int(pet["training_stage"]) + 1
                max_stage = int(pokemon["topLevel"]) // 2
                if new_stage > max_stage or int(pet["level"]) < new_stage * 2:
                    raise ValueError("Pet level requirement or maximum Stage not met")
                advance = table("PetAdvanceInfo").get(new_stage)
                if advance is None:
                    raise ValueError("missing configured PetAdvanceInfo row")
                rarity_index = int(pokemon["elementAtt1"]) - 1
                stage_cons = advance["stageCons"]
                if not 0 <= rarity_index < len(stage_cons):
                    raise ValueError("Pet rarity has no configured Stage costs")
                consume_ids = stage_cons[rarity_index]["costs"]
                consume_table = table("ConsumeElementInfo")
                requirements: dict[tuple[str, int], int] = {}
                for consume_id in consume_ids:
                    consume = consume_table.get(int(consume_id))
                    if consume is None:
                        raise ValueError(f"missing ConsumeElementInfo {consume_id}")
                    element_type, element_id, amount = (int(consume["elementType"]),
                                                        int(consume["elementID"]),
                                                        int(consume["num"]))
                    kind = {1: "gold", 2: "diamond", 3: "item"}.get(element_type)
                    if kind is None or amount <= 0:
                        raise ValueError("unsupported Pet Stage cost configuration")
                    key = (kind, element_id)
                    requirements[key] = requirements.get(key, 0) + amount
                for (kind, item_id), amount in requirements.items():
                    if kind in ("gold", "diamond"):
                        balance = int(char[kind])
                        if balance < amount:
                            raise ValueError(f"insufficient {kind}")
                    else:
                        item = await conn.fetchrow(
                            "SELECT count FROM inventory WHERE char_id=$1 AND item_id=$2 FOR UPDATE",
                            char_id, item_id)
                        if item is None or int(item["count"]) < amount:
                            raise ValueError(f"insufficient item {item_id}")
                for (kind, item_id), amount in requirements.items():
                    if kind in ("gold", "diamond"):
                        await conn.execute(
                            f"UPDATE characters SET {kind}={kind}-$2 WHERE char_id=$1",
                            char_id, amount)
                        char = dict(char)
                        char[kind] = int(char[kind]) - amount
                    else:
                        await conn.execute(
                            "UPDATE inventory SET count=count-$3 WHERE char_id=$1 AND item_id=$2",
                            char_id, item_id, amount)
                        await conn.execute(
                            "DELETE FROM inventory WHERE char_id=$1 AND item_id=$2 AND count=0",
                            char_id, item_id)
                await conn.execute(
                    "UPDATE pets SET training_stage=$3 WHERE char_id=$1 AND pet_uid=$2",
                    char_id, pet_uid, new_stage)
                return new_stage

    @staticmethod
    async def _advance_configured_battle_objectives(conn, char_id: int) -> None:
        from quest_config import load_quests
        config = load_quests()
        active = await conn.fetch(
            "SELECT quest_id,progress FROM quests WHERE char_id=$1 AND status=0 FOR UPDATE", char_id)
        for row in active:
            quest = config.get(row["quest_id"])
            if quest is None or not quest.objectives or not any(
                    objective.event_type == 2 for objective in quest.objectives):
                continue
            progress = row["progress"]
            if isinstance(progress, str):
                progress = json.loads(progress)
            if isinstance(progress, dict):
                progress = progress.get("progressList", [])
            if not isinstance(progress, list):
                progress = [0] * len(quest.objectives)
            values = list(progress[:len(quest.objectives)])
            values.extend([0] * (len(quest.objectives) - len(values)))
            changed = False
            for index, objective in enumerate(quest.objectives):
                if objective.event_type == 2 and values[index] < objective.amount:
                    values[index] = min(objective.amount, values[index] + 1)
                    changed = True
            if changed:
                await conn.execute(
                    "UPDATE quests SET progress=$3::jsonb WHERE char_id=$1 AND quest_id=$2",
                    char_id, quest.quest_id, json.dumps(values))

    async def commit_configured_tutorial_quest(self, char_id: int, quest,
                                               all_quests: dict[int, Any],
                                               configured_reward: dict | None = None
                                               ) -> tuple[bool, list[int], list[dict], list[str]]:
        """Atomically validate, complete, reward, unlock, and activate configured children."""
        objectives = quest.objectives
        if not objectives or any(objective.amount <= 0 for objective in objectives):
            return False, [], [], []
        async with self.pool.acquire() as conn:
            async with conn.transaction():
                char = await conn.fetchrow(
                    "SELECT level,gold,exp,diamond,game_values FROM characters WHERE char_id=$1 FOR UPDATE",
                    char_id)
                current = await conn.fetchrow(
                    "SELECT status,progress FROM quests WHERE char_id=$1 AND quest_id=$2 FOR UPDATE",
                    char_id, quest.quest_id)
                if char is None or current is None:
                    return False, [], [], []
                if current["status"] == 1:
                    claim = await conn.fetchrow(
                        "SELECT awards FROM quest_reward_claims WHERE char_id=$1 AND quest_id=$2",
                        char_id, quest.quest_id)
                    stored = (claim["awards"] if claim else {}) or {}
                    if isinstance(stored, str): stored = json.loads(stored)
                    return True, [], stored.get("awards", []), stored.get("pets", [])
                if current["status"] != 0:
                    return False, [], [], []
                if quest.parent_id:
                    parent = await conn.fetchval(
                        "SELECT status FROM quests WHERE char_id=$1 AND quest_id=$2",
                        char_id, quest.parent_id)
                    if parent != 1:
                        return False, [], [], []
                progress = current["progress"]
                if isinstance(progress, str):
                    progress = json.loads(progress)
                if isinstance(progress, dict):
                    progress = progress.get("progressList", [])
                if (not isinstance(progress, list) or len(progress) != len(objectives)
                        or any(type(value) is not int for value in progress)):
                    return False, [], [], []

                # Mandatory guide records sometimes encode a client tutorial
                # step as event_type 2 with all target IDs set to zero. This is
                # a guide-completion marker (the Lua flow calls finishProcess),
                # not a collect-item objective. Accept that explicit client
                # commit only while the configured strong guide is active and
                # its configured parent has already been committed.
                guide_marker = (quest.client_commit_marker and quest.strong_type == "1" and bool(objectives)
                                and all(o.event_type == 2 and not o.main_id and not o.sub_id
                                        and not o.final_id for o in objectives))
                if guide_marker:
                    progress = [max(value, objective.amount)
                                for value, objective in zip(progress, objectives)]
                elif quest.quest_id == FORMATION_GUIDE_QUEST_ID and await conn.fetchval(
                    """SELECT EXISTS (
                           SELECT 1 FROM pets WHERE char_id=$1 AND pet_template_id=$2
                             AND slot_index BETWEEN 0 AND 2
                       )""",
                    char_id, GACHA_GUIDE_PET_ID,
                ):
                    progress = [max(value, objective.amount)
                                for value, objective in zip(progress, objectives)]
                elif any(value < objective.amount
                         for value, objective in zip(progress, objectives)):
                    return False, [], [], []

                new_children = []
                for child_id in quest.child_ids:
                    if not child_id:
                        continue
                    child = all_quests.get(child_id)
                    if child is None:
                        continue
                    inserted = await conn.fetchval(
                        """INSERT INTO quests(char_id,quest_id,status,progress)
                           VALUES($1,$2,0,$3::jsonb) ON CONFLICT(char_id,quest_id) DO NOTHING
                           RETURNING quest_id""",
                        char_id, child_id, json.dumps([0] * max(1, len(child.objectives))))
                    if inserted is not None:
                        new_children.append(child_id)


                gold = int(quest.gold_reward) if quest.gold_reward.isdigit() else 0
                exp = int(quest.exp_reward) if quest.exp_reward.isdigit() else 0
                awards: list[dict] = []
                if gold:
                    awards.append({"kind": "g_cash", "id": 0, "num": gold})
                if quest.diamond_reward:
                    awards.append({"kind": "m_cash", "id": 0, "num": quest.diamond_reward})
                if exp:
                    awards.append({"kind": "exp", "id": 0, "num": exp})
                if configured_reward is not None:
                    awards.append(dict(configured_reward))
                from reward_service import grant_rewards
                grant_result = await grant_rewards(conn, char_id, awards, self._grant_character_exp)
                pet_payloads = grant_result["pets"]
                values = char["game_values"] or {}
                if isinstance(values, str): values = json.loads(values)
                map_lock = _merge_map_unlock(
                    str(values.get("map_lock", "0")), quest.unlock_map_id)
                await conn.execute(
                    """UPDATE quests SET status=1,progress=$3::jsonb WHERE char_id=$1 AND quest_id=$2""",
                    char_id, quest.quest_id, json.dumps(progress))
                await conn.execute(
                    """UPDATE characters SET game_values=game_values || jsonb_build_object('map_lock',$2::text)
                       WHERE char_id=$1""", char_id, map_lock)
                await conn.execute(
                    """INSERT INTO quest_reward_claims(char_id,quest_id,awards)
                       VALUES($1,$2,$3::jsonb) ON CONFLICT(char_id,quest_id) DO NOTHING""",
                    char_id, quest.quest_id,
                    json.dumps({"awards": awards, "pets": pet_payloads}, separators=(",", ":")))
                return True, new_children, awards, pet_payloads

    async def repair_completed_quest_unlocks(self, char_id: int, all_quests: dict[int, Any]) -> None:
        """Reconcile only unlocks implied by already-completed configured quests."""
        async with self.pool.acquire() as conn:
            async with conn.transaction():
                row = await conn.fetchrow(
                    "SELECT game_values FROM characters WHERE char_id=$1 FOR UPDATE", char_id)
                if row is None:
                    return
                values = row["game_values"] or {}
                if isinstance(values, str):
                    values = json.loads(values)
                map_lock = str(values.get("map_lock", "0"))
                completed = await conn.fetch(
                    "SELECT quest_id FROM quests WHERE char_id=$1 AND status=1", char_id)
                for completed_quest in completed:
                    quest = all_quests.get(completed_quest["quest_id"])
                    if quest is not None:
                        map_lock = _merge_map_unlock(map_lock, quest.unlock_map_id)
                if map_lock != str(values.get("map_lock", "0")):
                    await conn.execute(
                        "UPDATE characters SET game_values=game_values || jsonb_build_object('map_lock',$2::text) WHERE char_id=$1",
                        char_id, map_lock)

    async def player_snapshot(self, char_id: int) -> dict[str, Any]:
        async with self.pool.acquire() as conn:
            async with conn.transaction():
                char = await conn.fetchrow("SELECT * FROM characters WHERE char_id=$1", char_id)
                if char is None:
                    raise LookupError(f"character {char_id} does not exist")
                pets = await conn.fetch("SELECT * FROM pets WHERE char_id=$1 ORDER BY pet_uid", char_id)
                items = await conn.fetch("SELECT * FROM inventory WHERE char_id=$1 ORDER BY item_id", char_id)
                quests = await conn.fetch("SELECT * FROM quests WHERE char_id=$1 ORDER BY quest_id", char_id)
        return {"character": dict(char), "pets": [dict(r) for r in pets],
                "inventory": [dict(r) for r in items], "quests": [dict(r) for r in quests]}

    async def character_values(self, char_id: int, keys: list[str]) -> dict[str, Any]:
        from character_values import validate_character_values, vip_info_id
        row = await self.pool.fetchrow(
            "SELECT gold,diamond,vip_level,stamina,vip_points,recharge_total,currencies_json,game_values,created_at,world_id "
            "FROM characters WHERE char_id=$1", char_id,
        )
        if row is None:
            raise LookupError(f"character {char_id} does not exist")
        values: dict[str, Any] = {}
        stored = row["game_values"] or {}
        currencies = row["currencies_json"] or {}
        if isinstance(stored, str):
            stored = json.loads(stored)
        if isinstance(currencies, str):
            currencies = json.loads(currencies)
        aliases = {
            "gold": row["gold"], "diamond": row["diamond"],
            "viplevel": vip_info_id(row["vip_level"]),
            "vip_level": row["vip_level"], "actionvalue": row["stamina"],
            "stamina": row["stamina"], "vip_points": row["vip_points"],
            "map_lock": stored.get("map_lock", "0"),
            "create_time": int(row["created_at"].timestamp()),
            "world": row["world_id"],
        }
        raw_values: dict[str, Any] = {}
        for key in keys:
            normalized = key.lower()
            if normalized == "recharge":
                recharge = stored.get(key, stored.get(normalized, {}))
                recharge = dict(recharge) if isinstance(recharge, dict) else {}
                recharge["totalMoney"] = int(row["recharge_total"])
                raw_values[key] = recharge
            elif normalized in ("viplevel", "vip_level"):
                raw_values[key] = aliases[normalized]
            elif key in stored:
                raw_values[key] = stored[key]
            elif normalized in stored:
                raw_values[key] = stored[normalized]
            elif normalized in currencies:
                raw_values[key] = currencies[normalized]
            elif normalized in aliases:
                raw_values[key] = aliases[normalized]
            elif normalized == "curfashion":
                from fashion_config import default_fashion_ids
                raw_values[key] = json.dumps(default_fashion_ids(), separators=(",", ":"))
        return validate_character_values(keys, raw_values)

    async def set_character_value(self, char_id: int, key: str, value: str) -> None:
        async with self.pool.acquire() as conn:
            result = await conn.execute(
                "UPDATE characters SET game_values=game_values || jsonb_build_object($2,$3) "
                "WHERE char_id=$1", char_id, key.lower(), value,
            )
            if result.endswith(" 0"):
                raise LookupError(f"character {char_id} does not exist")

    async def quest_progress(self, char_id: int, quest_id: int) -> asyncpg.Record | None:
        return await self.pool.fetchrow(
            "SELECT status,progress FROM quests WHERE char_id=$1 AND quest_id=$2",
            char_id, quest_id,
        )

    async def grant_item(self, char_id: int, item_id: int, count: int = 1) -> None:
        if item_id <= 0 or count <= 0:
            return
        await self.pool.execute(
            """INSERT INTO inventory(char_id,item_id,count) VALUES($1,$2,$3)
               ON CONFLICT(char_id,item_id) DO UPDATE SET count=inventory.count+EXCLUDED.count""",
            char_id, item_id, count,
        )

    async def claim_adventure_cell(self, char_id: int, adventure_id: int, floor: int,
                                  map_col: int, map_row: int, rewards: list[dict]) -> list[str]:
        """Atomically grant a configured map-cell reward once and retain its ACK payload."""
        encoded = [json.dumps(reward, separators=(",", ":")) for reward in rewards]
        async with self.pool.acquire() as conn:
            async with conn.transaction():
                claim = await conn.fetchrow(
                    """INSERT INTO adventure_cell_claims
                       (char_id,adventure_id,floor,map_col,map_row,awards)
                       VALUES($1,$2,$3,$4,$5,$6::jsonb)
                       ON CONFLICT DO NOTHING RETURNING char_id""",
                    char_id, adventure_id, floor, map_col, map_row, json.dumps(encoded),
                )
                if claim is None:
                    previous = await conn.fetchval(
                        """SELECT awards FROM adventure_cell_claims WHERE char_id=$1
                           AND adventure_id=$2 AND floor=$3 AND map_col=$4 AND map_row=$5""",
                        char_id, adventure_id, floor, map_col, map_row,
                    )
                    if isinstance(previous, str):
                        previous = json.loads(previous)
                    return list(previous or [])
                for reward in rewards:
                    kind, element_id, amount = reward["kind"], reward["id"], reward["num"]
                    if kind == "g_cash":
                        await conn.execute("UPDATE characters SET gold=gold+$2 WHERE char_id=$1",
                                           char_id, amount)
                    elif kind == "m_cash":
                        await conn.execute("UPDATE characters SET diamond=diamond+$2 WHERE char_id=$1",
                                           char_id, amount)
                    elif kind == "exp":
                        await self._grant_character_exp(conn, char_id, amount)
                    elif kind == "item":
                        await conn.execute(
                            """INSERT INTO inventory(char_id,item_id,count) VALUES($1,$2,$3)
                               ON CONFLICT(char_id,item_id) DO UPDATE
                               SET count=inventory.count+EXCLUDED.count""",
                            char_id, element_id, amount,
                        )
                    else:
                        raise ValueError(f"unsupported adventure reward kind: {kind}")
        return encoded

    async def start_adventure(self, char_id: int, adventure_id: int) -> None:
        await self.pool.execute(
            """INSERT INTO character_adventures(char_id,adventure_id)
               VALUES($1,$2) ON CONFLICT(char_id) DO UPDATE
               SET adventure_id=EXCLUDED.adventure_id,started_at=now(),completed_at=NULL,
                   completion_star=0,completion_awards_json='[]'::jsonb""",
            char_id, adventure_id,
        )

    async def current_adventure_id(self, char_id: int) -> int | None:
        return await self.pool.fetchval(
            "SELECT adventure_id FROM character_adventures WHERE char_id=$1 AND completed_at IS NULL",
            char_id,
        )

    async def latest_adventure_id(self, char_id: int) -> int | None:
        """Return the retained adventure ID, including a completed run for ACK retries."""
        return await self.pool.fetchval(
            "SELECT adventure_id FROM character_adventures WHERE char_id=$1", char_id)

    async def record_adventure_events(self, char_id: int, adventure_id: int,
                                     event_ids: list[int]) -> bool:
        """Record configured event callbacks once for the active adventure."""
        async with self.pool.acquire() as conn:
            async with conn.transaction():
                active = await conn.fetchval(
                    "SELECT adventure_id FROM character_adventures "
                    "WHERE char_id=$1 AND completed_at IS NULL FOR UPDATE", char_id)
                if active != adventure_id:
                    return False
                for event_id in event_ids:
                    await conn.execute(
                        """INSERT INTO adventure_fired_events(char_id,adventure_id,event_id)
                           VALUES($1,$2,$3) ON CONFLICT(char_id,adventure_id,event_id) DO NOTHING""",
                        char_id, adventure_id, event_id)
                return True

    async def finish_adventure(self, char_id: int, star: int,
                               rewards: list[dict]) -> list[str] | None:
        """Complete an adventure once, grant its configured rewards, and retain ACK data."""
        encoded = [json.dumps(reward, separators=(",", ":")) for reward in rewards]
        async with self.pool.acquire() as conn:
            async with conn.transaction():
                row = await conn.fetchrow(
                    """SELECT adventure_id,completed_at,completion_star,completion_awards_json
                       FROM character_adventures WHERE char_id=$1 FOR UPDATE""", char_id)
                if row is None:
                    return None
                if row["completed_at"] is not None:
                    previous = row["completion_awards_json"] or []
                    if isinstance(previous, str):
                        previous = json.loads(previous)
                    return list(previous)
                if star == 0:
                    encoded = []
                for reward in rewards if star else []:
                    kind, element_id, amount = reward["kind"], reward["id"], reward["num"]
                    if type(amount) is not int or amount < 0:
                        raise ValueError("invalid adventure reward amount")
                    if kind == "g_cash":
                        await conn.execute("UPDATE characters SET gold=gold+$2 WHERE char_id=$1",
                                           char_id, amount)
                    elif kind == "m_cash":
                        await conn.execute("UPDATE characters SET diamond=diamond+$2 WHERE char_id=$1",
                                           char_id, amount)
                    elif kind == "exp":
                        await self._grant_character_exp(conn, char_id, amount)
                    elif kind == "item":
                        await conn.execute(
                            """INSERT INTO inventory(char_id,item_id,count) VALUES($1,$2,$3)
                               ON CONFLICT(char_id,item_id) DO UPDATE
                               SET count=inventory.count+EXCLUDED.count""",
                            char_id, element_id, amount,
                        )
                    else:
                        raise ValueError(f"unsupported adventure reward kind: {kind}")
                await conn.execute(
                    """UPDATE character_adventures
                       SET completed_at=now(),completion_star=$2,completion_awards_json=$3::jsonb
                       WHERE char_id=$1""", char_id, star, json.dumps(encoded))
                # NewQuestInfo event 19 means that this configured Adventure
                # has been cleared. Persist that objective in the same
                # transaction as the clear and its rewards so the story quest
                # is claimable after relogin and cannot advance on a failed run.
                if star & 8:
                    await conn.execute(
                        """INSERT INTO character_adventure_clears(char_id,adventure_id,star_mask)
                           VALUES($1,$2,$3) ON CONFLICT (char_id,adventure_id)
                           DO UPDATE SET star_mask=character_adventure_clears.star_mask | EXCLUDED.star_mask""",
                        char_id, row["adventure_id"], star,
                    )
                    from quest_config import load_quests
                    config = load_quests()
                    active = await conn.fetch(
                        "SELECT quest_id,progress FROM quests WHERE char_id=$1 AND status=0 FOR UPDATE",
                        char_id)
                    for quest_row in active:
                        quest = config.get(quest_row["quest_id"])
                        if quest is None or not quest.objectives:
                            continue
                        matching = [i for i, objective in enumerate(quest.objectives)
                                    if objective.event_type == 19
                                    and objective.main_id == row["adventure_id"]]
                        if not matching:
                            continue
                        progress = quest_row["progress"]
                        if isinstance(progress, str):
                            progress = json.loads(progress)
                        if isinstance(progress, dict):
                            progress = progress.get("progressList", [])
                        if not isinstance(progress, list) or len(progress) != len(quest.objectives):
                            continue
                        progress = list(progress)
                        changed = False
                        for index in matching:
                            amount = quest.objectives[index].amount
                            if type(progress[index]) is int and progress[index] < amount:
                                progress[index] = amount
                                changed = True
                        if changed:
                            await conn.execute(
                                "UPDATE quests SET progress=$3::jsonb WHERE char_id=$1 AND quest_id=$2",
                                char_id, quest.quest_id, json.dumps(progress))
        return encoded

    async def grant_pet(self, char_id: int, template_id: int) -> asyncpg.Record | None:
        if template_id <= 0:
            return None
        return await self.pool.fetchrow(
            """INSERT INTO pets(char_id,pet_template_id,level,star,evolution,slot_index)
               VALUES($1,$2,1,0,0,-1) RETURNING *""", char_id, template_id
        )


def _merge_map_unlock(current: str, unlock: str) -> str:
    """Merge NewQuestInfo unlockMapID into the client's maplock-missionlock pair."""
    parts = current.split("-", 1)
    try:
        map_lock = max(0, int(parts[0] or 0))
    except ValueError as exc:
        raise ValueError(f"invalid map_lock map component: {current!r}") from exc
    try:
        mission_lock = max(0, int(parts[1] or 0)) if len(parts) > 1 else 0
    except ValueError as exc:
        raise ValueError(f"invalid map_lock mission component: {current!r}") from exc
    if unlock.startswith("q") and unlock[1:].isdigit():
        mission_lock = max(mission_lock, int(unlock[1:]))
    elif unlock.isdigit():
        map_lock = max(map_lock, int(unlock))
    return f"{map_lock}-{mission_lock}"

