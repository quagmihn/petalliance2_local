from __future__ import annotations

import json
import logging
from functools import cache
import os
from pathlib import Path
from typing import Any

import asyncpg

from quest_config import FORMATION_GUIDE_QUEST_ID, GACHA_GUIDE_PET_ID, GACHA_GUIDE_QUEST_ID

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
                if await conn.fetchval(
                    """SELECT EXISTS (SELECT 1 FROM pets WHERE char_id=$1 AND pet_uid=ANY($2::bigint[])
                       AND development_json->'yoke' ? 'bindTo')""", char_id, list(slots)):
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

    @staticmethod
    def _pet_exp_progress(char_level, pet, exp_gain, *, allow_capped_gain=False):
        """Apply the same cumulative thresholds and cap for feeding and battle EXP."""
        from client_config import table

        exp_rows = table("ExperienceInfo")
        template = table("PokemonInfo").get(int(pet["pet_template_id"]))
        if template is None:
            raise ValueError(f"unknown Pet template {pet['pet_template_id']}")
        rare = int(template["rarePoint"])
        max_level = min(int(char_level), int(template["topLevel"]))
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
        if current_level >= max_level and not allow_capped_gain:
            return None
        next_cap = thresholds[max_level - 1] - 1
        new_exp = min(old_exp + exp_gain, next_cap)
        new_level = min(max_level, 1 + sum(value <= new_exp for value in thresholds))
        if new_exp <= old_exp:
            return None

        return new_level, new_exp

    async def feed_pet_exp(self, char_id: int, pet_uid: int, item_id: int,
                           item_count: int, exp_per_item: int):
        """Consume configured feed items and persist Pet cumulative EXP atomically."""
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

                progress = self._pet_exp_progress(char["level"], pet, item_count * exp_per_item)
                if progress is None:
                    return None
                new_level, new_exp = progress

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
                from progress import record
                await record(conn, char_id, "PET_FED", item_count)
                return {"remaining": remaining, "pet": dict(updated),
                        "pet_json": serialized}

    async def buy_market_item(self, char_id: int, market: dict, count: int):
        """Apply a configured MarketInfo purchase and its weekly counter."""
        from client_config import table
        from local_play import silver_override, storage_limits
        from reward_service import fits_wire_stack
        from vip_config import unlimited_shop

        vip_offer = market["marketType"] == 4
        unlimited = vip_offer and unlimited_shop()
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
                _, capacity = storage_limits(values)
                if capacity is not None:
                    bag = await conn.fetchrow(
                        """SELECT count(*) AS occupied, bool_or(item_id=$2) AS has_stack
                           FROM inventory WHERE char_id=$1 AND count>0""", char_id, item_id)
                    if not bag["has_stack"] and bag["occupied"] >= capacity:
                        return None
                if not await fits_wire_stack(conn, char_id, {item_id: quantity}):
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
                    if not unlimited and previous + count > limit:
                        return None
                    counters.update({num_key: previous + count, time_key: now})
                currencies = char["currencies_json"] or {}
                if isinstance(currencies, str):
                    currencies = json.loads(currencies)
                virtual_silver = coin_type == 3 and silver_override(char) is not None
                if coin_type == 3 and not virtual_silver:
                    balance = int(currencies.get("goldCoin", 0))
                    if balance < price:
                        return None
                    currencies["goldCoin"] = balance - price
                    await conn.execute(
                        "UPDATE characters SET currencies_json=$2::jsonb WHERE char_id=$1",
                        char_id, json.dumps(currencies))
                elif currency_column is not None:
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
                if vip_offer:
                    await conn.execute(
                        """INSERT INTO vip_shop_purchases(char_id,sku,item_id,quantity,coin_type,cost,unlimited)
                           VALUES($1,$2,$3,$4,$5,$6,$7)""",
                        char_id, market["id"], item_id, quantity, coin_type, price, unlimited)
                from progress import record
                await record(conn, char_id, "ITEM_PURCHASED", quantity)
                return {"character": updated, "virtual_silver": virtual_silver,
                        "item_id": item_id, "item_count": int(inventory["count"]), "counters": counters}

    async def apply_local_recharge(self, char_id: int, order_key: str,
                                   package_kind: str, package: dict,
                                   diamonds: int, paid_amount: int):
        """Apply one catalogued local simulation, idempotently and atomically."""
        from recharge_config import active_normal_package, normal_families
        from vip_config import rank_for_recharge

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
                    family = normal_families().get(package_id)
                    if family is None:
                        return None
                    last, now = await conn.fetchrow(
                        """SELECT max(extract(epoch FROM created_at)),extract(epoch FROM statement_timestamp())
                           FROM local_recharge_transactions WHERE char_id=$1 AND package_kind='normal'
                           AND package_id=$2 AND simulated""", char_id, family[0]["id"])
                    if active_normal_package(*family, last, now)["id"] != package_id:
                        return None
                else:
                    expires = await conn.fetchval(
                        """INSERT INTO local_month_cards(char_id,package_id,expires_at)
                           VALUES($1,$2,now()+$3 * interval '1 day')
                           ON CONFLICT (char_id,package_id) DO UPDATE SET expires_at=
                               greatest(local_month_cards.expires_at,now())+$3 * interval '1 day'
                           RETURNING expires_at""", char_id, package_id, int(package["days"]))
                    await conn.execute(
                        """UPDATE characters SET month_card_until=greatest(month_card_until,$2)
                           WHERE char_id=$1""", char_id, expires)
                total = char["recharge_total"] + paid_amount
                await conn.execute(
                    """UPDATE characters SET diamond=diamond+$2,recharge_total=$3,
                       vip_level=greatest(vip_level,$4),vip_points=greatest(vip_points,$3)
                       WHERE char_id=$1""", char_id, diamonds, total, rank_for_recharge(total))
                await conn.execute(
                    """INSERT INTO local_recharge_transactions
                       (char_id,order_key,package_kind,package_id,paid_amount,rewards,simulated)
                       VALUES($1,$2,$3,$4,$5,$6::jsonb,TRUE)""",
                    char_id, order_key, package_kind, package_id, paid_amount,
                    json.dumps(rewards, separators=(",", ":")))
                from progress import record
                await record(conn, char_id, "RECHARGE_COMPLETED")
                updated = await conn.fetchrow(
                    "SELECT * FROM characters WHERE char_id=$1", char_id)
                return {"character": updated, "duplicate": False,
                        "package_kind": package_kind, "package_id": package_id}

    async def local_recharge_cooldowns(self, char_id):
        from recharge_config import normal_families

        bonus_ids = sorted({bonus["id"] for bonus, _ in normal_families().values()})
        results = await self.pool.fetch(
            """SELECT package_id, to_char(max(created_at) AT TIME ZONE 'UTC',
                       'YYYY-MM-DD"T"HH24:MI:SS".000"') AS purchased
               FROM local_recharge_transactions WHERE char_id=$1 AND package_kind='normal'
               AND simulated AND package_id=ANY($2::int[]) GROUP BY package_id""", char_id, bonus_ids)
        return {f"N{row['package_id']}": {"time": [row["purchased"]]} for row in results}

    async def vip_awards(self, char_id):
        values = await self.pool.fetchval("SELECT game_values FROM characters WHERE char_id=$1", char_id)
        return json.loads(values).get("vip_local_awards", []) if values else []

    async def claim_vip_milestone(self, char_id, vip_id, rank, rewards):
        from reward_service import receive_rewards

        async with self.pool.acquire() as conn, conn.transaction():
            char = await conn.fetchrow("SELECT vip_level,game_values FROM characters WHERE char_id=$1 FOR UPDATE",
                                       char_id)
            if char is None or char["vip_level"] < rank:
                return None
            claimed = json.loads(char["game_values"]).get("vip_local_awards", [])
            if vip_id in claimed:
                return None
            state = await receive_rewards(conn, char_id, char["game_values"], rewards, self._grant_character_exp)
            if state is None:
                return None
            await conn.execute(
                """UPDATE characters SET game_values=game_values ||
                   jsonb_build_object('vip_local_awards',$2::jsonb) WHERE char_id=$1""",
                char_id, json.dumps(sorted([*claimed, vip_id])))
            return state

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

    async def adventure_clears(self, char_id: int, *, include_sweeps=False):
        if not include_sweeps:
            return await self.pool.fetch(
                """SELECT adventure_id AS "advID",star_mask AS star
                   FROM character_adventure_clears WHERE char_id=$1 ORDER BY adventure_id""", char_id)
        return await self.pool.fetch(
            """SELECT a.adventure_id AS "advID",a.star_mask AS star,
                      coalesce((s.counter->>'count')::int,0) AS "qcTimes",
                      coalesce((s.counter->>'last')::bigint,0) AS "qcUpdateTime"
               FROM character_adventure_clears a JOIN characters c USING(char_id)
               CROSS JOIN LATERAL (
                   SELECT c.game_values->'adventure_sweeps'->'counts'->(a.adventure_id::text) AS counter
               ) s WHERE a.char_id=$1 ORDER BY a.adventure_id""",
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
        from pet_config import insert_owned_pet
        return await insert_owned_pet(self.pool, char_id, template_id, slot=0)

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
                    from pet_config import insert_owned_pet
                    first_pet = await insert_owned_pet(conn, char["char_id"], pet_template_id, slot=0)
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

    @staticmethod
    async def _insert_pve_battle(conn, char_id, session_id, group_id, battle_type, battle_type_id,
                                 adventure_id=None, capture_attempts=0):
        await conn.execute(
            """INSERT INTO tutorial_battle_sessions
               (char_id,session_id,group_id,battle_type,battle_type_id,adventure_id,state,
                capture_attempts_remaining,fighter_uids)
               VALUES ($1,$2,$3,$4,$5,$6,'started',$7,ARRAY(
                   SELECT pet_uid FROM pets WHERE char_id=$1 AND slot_index BETWEEN 0 AND 2
                   ORDER BY slot_index,pet_uid))""",
            char_id, session_id, group_id, battle_type, battle_type_id, adventure_id, capture_attempts,
        )

    async def start_tutorial_battle(self, char_id: int, session_id: str, group_id: int) -> bool:
        from battle_group_config import tutorial_requirements
        requirement = tutorial_requirements().get(group_id)
        if requirement is None:
            return False
        async with self.pool.acquire() as conn:
            async with conn.transaction():
                await conn.fetchval("SELECT 1 FROM characters WHERE char_id=$1 FOR UPDATE", char_id)
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
                await self._insert_pve_battle(conn, char_id, session_id, group_id, 5, group_id)
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
                await self._insert_pve_battle(conn, char_id, session_id, group_id, 5, group_id)
                return True

    async def start_world_map_quest_wild(self, char_id: int, session_id: str,
                                         monster_id: int, attempts: int = 0) -> bool:
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
                await self._insert_pve_battle(conn, char_id, session_id, monster_id, 1, monster_id,
                                              capture_attempts=attempts)
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
                await conn.fetchval("SELECT 1 FROM characters WHERE char_id=$1 FOR UPDATE", char_id)
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
                await self._insert_pve_battle(conn, char_id, session_id, monster_id, 1,
                                              monster_id, capture_attempts=capture_attempts)
                return True

    async def supply_tutorial_capture_balls(self, char_id: int, quest_id: int, attempts: int):
        """Supply the ball the capture guide highlights, once per character."""
        from client_config import table

        item_id = 2  # BattleCCSB.ballOrder[1], highlighted by the tutorial.
        item = table("ItemInfo").get(item_id)
        if (quest_id != 10008 or attempts <= 0 or item is None or item["itemType"] != 9
                or item_id not in table("PokemonBallInfo")):
            return None
        async with self.pool.acquire() as conn:
            async with conn.transaction():
                await conn.fetchval("SELECT 1 FROM characters WHERE char_id=$1 FOR UPDATE", char_id)
                claim = await conn.fetchval(
                    """SELECT r.awards FROM quest_reward_claims r
                       JOIN quests q ON q.char_id=r.char_id AND q.quest_id=$2 AND q.status=0
                       WHERE r.char_id=$1 AND r.quest_id=10007
                         AND NOT (r.awards ? 'tutorial_capture_supplied') FOR UPDATE OF r""",
                    char_id, quest_id,
                )
                if claim is None:
                    return None
                claim = json.loads(claim) if isinstance(claim, str) else dict(claim)
                count = await conn.fetchval(
                    "SELECT count FROM inventory WHERE char_id=$1 AND item_id=$2 FOR UPDATE", char_id, item_id)
                missing = max(0, attempts - (count or 0))
                if missing:
                    from reward_service import grant_rewards

                    award = {"kind": "item", "id": item_id, "num": missing}
                    await grant_rewards(conn, char_id, [award], self._grant_character_exp)
                    claim["tutorial_capture_supplied"] = award
                else:
                    claim["tutorial_capture_supplied"] = True
                await conn.execute(
                    "UPDATE quest_reward_claims SET awards=$2::jsonb WHERE char_id=$1 AND quest_id=10007",
                    char_id, json.dumps(claim))
                return (item_id, attempts) if missing else None

    async def capture_wild_pet(self, char_id: int, session_id: str, monster_id: int,
                               ball_item_id: int, roll: int | None = None):
        """Consume a configured ball for the live encounter's Pet template ID.

        The client serializer calls this field pokemonID and BattleMapMgr
        supplies MonstrosityInfo.petnumber, not the encounter's mID.
        """
        from battle_group_config import tutorial_wild_requirements
        from client_config import table
        import secrets

        item = table("ItemInfo").get(ball_item_id)
        ball = table("PokemonBallInfo").get(ball_item_id)
        if item is None or ball is None or int(item["itemType"]) != 9:
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
                owner = await conn.fetchrow(
                    "SELECT game_values FROM characters WHERE char_id=$1 FOR UPDATE", char_id)
                if owner is None:
                    return None
                # Reconnect establishes a new TCP session ID. Resolve the
                # encounter from its authenticated owner and lock it once.
                battle = await conn.fetchrow(
                    """SELECT * FROM tutorial_battle_sessions WHERE char_id=$1
                       ORDER BY battle_id DESC LIMIT 1 FOR UPDATE""", char_id)
                if (battle is None or battle["battle_type"] not in (1, 2)
                        or battle["state"] not in ("started", "won")):
                    return None
                monster = table("MonstrosityInfo").get(int(battle["group_id"]))
                if monster is None or int(monster["petnumber"]) != template_id or int(monster["capture"]) <= 0:
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
                if int(battle["capture_attempts_remaining"]) <= 0:
                    return None
                if battle["battle_type"] == 2 and not await conn.fetchval(
                    """SELECT 1 FROM character_adventures WHERE char_id=$1 AND adventure_id=$2
                       AND completed_at IS NULL AND started_at<=$3""",
                    char_id, battle["adventure_id"], battle["created_at"]):
                    return None
                values = owner["game_values"] or {}
                if isinstance(values, str):
                    values = json.loads(values)
                from local_play import storage_limits

                capacity, _ = storage_limits(values)
                if capacity is not None and await conn.fetchval(
                    "SELECT count(*) FROM pets WHERE char_id=$1", char_id
                ) >= capacity:
                    return None
                inventory = await conn.fetchrow(
                    "SELECT count FROM inventory WHERE char_id=$1 AND item_id=$2 FOR UPDATE",
                    char_id, ball_item_id)
                if inventory is None or int(inventory["count"]) < 1:
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
                    from pet_config import insert_owned_pet
                    pet = await insert_owned_pet(conn, char_id, template_id, level=level, stage=stage, star=star)
                    from handlers.pet import pet_json
                    serialized = pet_json(pet)
                    await conn.execute(
                        "UPDATE tutorial_battle_sessions SET captured_pet_uid=$2 WHERE battle_id=$1",
                        battle["battle_id"], pet["pet_uid"])
                    result.update(pet_uid=int(pet["pet_uid"]), pet_json=serialized)
                    from progress import record
                    await record(conn, char_id, "PET_CAPTURED")
                    requirement = (tutorial_wild_requirements().get(int(battle["group_id"]))
                                   if battle["battle_type"] == 1 else None)
                    if requirement is None:
                        return result
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
                return result

    async def start_adventure_battle(self, char_id: int, session_id: str, adventure_id: int,
                                     scene_id: int, group_id: int, *, battle_type: int = 3,
                                     attempts: int = 0, disposable_id: int | None = None) -> bool:
        async with self.pool.acquire() as conn:
            async with conn.transaction():
                active_adventure = await conn.fetchrow(
                    """SELECT adventure_id,started_at FROM character_adventures
                       WHERE char_id=$1 AND completed_at IS NULL FOR UPDATE""", char_id)
                if active_adventure is None or active_adventure["adventure_id"] != adventure_id:
                    return False
                await conn.fetchval("SELECT 1 FROM characters WHERE char_id=$1 FOR UPDATE", char_id)
                if await conn.fetchval(
                    """SELECT EXISTS(SELECT 1 FROM tutorial_battle_sessions
                       WHERE char_id=$1 AND adventure_id=$2 AND battle_type_id=$3 AND battle_type=$4
                         AND state='won' AND created_at >= $5)""",
                    char_id, adventure_id, scene_id, battle_type, active_adventure["started_at"]):
                    return False
                if disposable_id is not None and await conn.fetchval(
                    """SELECT 1 FROM adventure_fired_events
                       WHERE char_id=$1 AND adventure_id=$2 AND event_id=$3""",
                    char_id, adventure_id, disposable_id):
                    return False
                existing = await conn.fetchrow(
                    """SELECT battle_id,battle_type,battle_type_id,adventure_id,created_at
                       FROM tutorial_battle_sessions WHERE char_id=$1 AND state='started'
                       ORDER BY battle_id DESC LIMIT 1 FOR UPDATE""", char_id)
                if existing is not None:
                    if (int(existing["battle_type"]) == battle_type
                            and int(existing["battle_type_id"]) == scene_id
                            and existing["adventure_id"] == adventure_id
                            and existing["created_at"] >= active_adventure["started_at"]):
                        await conn.execute("UPDATE tutorial_battle_sessions SET session_id=$2 WHERE battle_id=$1",
                                           existing["battle_id"], session_id)
                        return True
                    await conn.execute(
                        "UPDATE tutorial_battle_sessions SET state='lost',finished_at=now() WHERE battle_id=$1",
                        existing["battle_id"])
                await self._insert_pve_battle(conn, char_id, session_id, group_id, battle_type, scene_id,
                                              adventure_id, attempts)
                return True

    async def finish_tutorial_battle(self, char_id: int, session_id: str, won: bool,
                                     reported_fighters: set[int] | None = None):
        async with self.pool.acquire() as conn:
            async with conn.transaction():
                level = await conn.fetchval("SELECT level FROM characters WHERE char_id=$1 FOR UPDATE", char_id)
                # After reconnect, a fresh authenticated TCP session must be
                # able to finish the character's active server-issued battle.
                # The locked state transition still makes the end request one-use.
                battle = await conn.fetchrow(
                    """SELECT battle_id,group_id,battle_type,battle_type_id,adventure_id,fighter_uids
                       FROM tutorial_battle_sessions
                       WHERE char_id=$1 AND state='started'
                       ORDER BY battle_id DESC LIMIT 1 FOR UPDATE""", char_id)
                if battle is None or level is None:
                    return None
                fighters = battle["fighter_uids"]
                if won and reported_fighters is not None and fighters is not None:
                    if not fighters or set(fighters) != reported_fighters:
                        return None
                exp = 0
                updated_pets = []
                if won:
                    from client_config import table

                    config = "MonstrosityInfo" if battle["battle_type"] in (1, 2) else "MonsterGroupManInfo"
                    group = table(config).get(battle["group_id"])
                    exp = int(group["exp"]) if group else 0
                    if exp and fighters and reported_fighters is not None:
                        updated_pets = await self._grant_battle_pet_exp(conn, char_id, level, fighters, exp)
                await conn.execute(
                    """UPDATE tutorial_battle_sessions SET state=$2,finished_at=now(),session_id=$3
                       WHERE battle_id=$1""", battle["battle_id"], "won" if won else "lost", session_id)
                if won:
                    from progress import record
                    await record(conn, char_id, "BATTLE_WON")
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
                    elif battle["battle_type"] in (2, 3):
                        from adventure_config import scene_encounter

                        encounter = scene_encounter(
                            battle["adventure_id"], battle["battle_type_id"], 2 if battle["battle_type"] == 2 else 8)
                        if encounter and encounter[1] is not None:
                            await conn.execute(
                                """INSERT INTO adventure_fired_events(char_id,adventure_id,event_id)
                                   VALUES ($1,$2,$3) ON CONFLICT DO NOTHING""",
                                char_id, battle["adventure_id"], encounter[1])
                    if battle["battle_type"] == 3:
                        await self._advance_configured_battle_objectives(conn, char_id)
                    if battle["battle_type"] == 5 and not tutorial_handled:
                        await self._advance_world_map_trainer_objectives(
                            conn, char_id, int(battle["group_id"]))
                    elif battle["battle_type"] == 1:
                        await self._advance_world_map_wild_objectives(
                            conn, char_id, int(battle["group_id"]))
                return exp, updated_pets

    async def _grant_battle_pet_exp(self, conn, char_id, level, fighters, exp):
        from handlers.pet import pet_json

        pets = await conn.fetch(
            """SELECT * FROM pets WHERE char_id=$1 AND pet_uid=ANY($2::bigint[])
               ORDER BY pet_uid FOR UPDATE""", char_id, fighters)
        updated = []
        for pet in pets:
            progress = self._pet_exp_progress(level, pet, exp, allow_capped_gain=True)
            if progress is None:
                continue
            pet_level, pet_exp = progress
            row = await conn.fetchrow(
                "UPDATE pets SET level=$2, exp=$3 WHERE pet_uid=$1 RETURNING *",
                pet["pet_uid"], pet_level, pet_exp)
            updated.append((pet["pet_uid"], pet_json(row)))
        return updated

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

    async def advance_pet_star(self, char_id, pet_uid, material_uids):
        from handlers.pet import pet_json
        from pet_config import json_value, star_steps
        from pet_development import state, yoke_values

        if pet_uid in material_uids or 1 in material_uids or len(set(material_uids)) != len(material_uids):
            return None
        async with self.pool.acquire() as conn, conn.transaction():
            if not await conn.fetchval("SELECT char_id FROM characters WHERE char_id=$1 FOR UPDATE", char_id):
                return None
            owned = {row["pet_uid"]: row for row in await conn.fetch(
                "SELECT * FROM pets WHERE char_id=$1 AND pet_uid=ANY($2::bigint[]) FOR UPDATE",
                char_id, [pet_uid, *material_uids])}
            target = owned.get(pet_uid)
            if target is None or len(owned) != len(material_uids) + 1:
                return None
            steps = star_steps(target["pet_template_id"])
            star = target["star"]
            if not 0 <= star < len(steps):
                return None
            step = steps[star]
            if target["training_stage"] < step.stage or len(material_uids) != step.pet_count:
                return None
            for uid in material_uids:
                material = owned[uid]
                if (material["slot_index"] != -1 or json_value(material["equips_json"])
                        or state(material).get("yoke")
                        or material["pet_template_id"] not in (step.substitutes | {step.pet})):
                    return None
            # Capture retries need the owned UID and live fights use an issuance snapshot.
            if await conn.fetchval(
                """SELECT EXISTS(SELECT 1 FROM tutorial_battle_sessions WHERE char_id=$1 AND
                   (captured_pet_uid=ANY($2::bigint[]) OR
                   (state='started' AND fighter_uids && $2::bigint[])))""",
                char_id, material_uids,
            ):
                return None
            remaining = await conn.fetchval(
                """UPDATE inventory SET count=count-$3 WHERE char_id=$1 AND item_id=$2 AND count >= $3
                   RETURNING count""", char_id, step.item, step.count)
            if remaining is None:
                return None
            if remaining == 0:
                await conn.execute("DELETE FROM inventory WHERE char_id=$1 AND item_id=$2", char_id, step.item)
            await conn.execute("DELETE FROM pets WHERE char_id=$1 AND pet_uid=ANY($2::bigint[])",
                               char_id, material_uids)
            updated = await conn.fetchrow(
                "UPDATE pets SET star=star+1 WHERE pet_uid=$1 RETURNING *", pet_uid)
            parent_id = state(updated).get("yoke", {}).get("bindTo")
            if parent_id:
                pets = {pet["pet_uid"]: pet for pet in await conn.fetch(
                    "SELECT * FROM pets WHERE char_id=$1", char_id)}
                main = state(pets[parent_id])
                detail = main["yoke"]["yokeDetail"]
                main["yoke"]["yokeValues"] = yoke_values(detail, pets)
                await conn.execute("UPDATE pets SET development_json=$2::jsonb WHERE pet_uid=$1",
                                   parent_id, json.dumps(main))
            from progress import record
            await record(conn, char_id, "PET_STAR_UP")
            return pet_json(updated), step.item, remaining

    async def advance_pet_training_stage(self, char_id: int, pet_uid: int):
        """Atomically charge and persist one configured Pet Stage increase."""
        from client_config import table
        from pet_config import stage_costs
        async with self.pool.acquire() as conn:
            async with conn.transaction():
                char = await conn.fetchrow(
                    """SELECT gold,diamond,stamina,vip_level,vip_points,currencies_json
                       FROM characters WHERE char_id=$1 FOR UPDATE""",
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
                requirements: dict[tuple[str, int], int] = {}
                for consume in stage_costs(pet["pet_template_id"], new_stage):
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
                item_counts = []
                wallet_changed = False
                wallet = dict(char)
                for (kind, item_id), amount in requirements.items():
                    if kind in ("gold", "diamond"):
                        await conn.execute(
                            f"UPDATE characters SET {kind}={kind}-$2 WHERE char_id=$1",
                            char_id, amount)
                        wallet[kind] -= amount
                        wallet_changed = True
                    else:
                        remaining = await conn.fetchval(
                            """UPDATE inventory SET count=count-$3 WHERE char_id=$1 AND item_id=$2
                               RETURNING count""",
                            char_id, item_id, amount)
                        await conn.execute(
                            "DELETE FROM inventory WHERE char_id=$1 AND item_id=$2 AND count=0",
                            char_id, item_id)
                        item_counts.append((item_id, remaining))
                await conn.execute(
                    "UPDATE pets SET training_stage=$3 WHERE char_id=$1 AND pet_uid=$2",
                    char_id, pet_uid, new_stage)
                from progress import record
                await record(conn, char_id, "PET_ENHANCED")
                return new_stage, wallet if wallet_changed else None, item_counts

    @staticmethod
    async def _advance_configured_battle_objectives(conn, char_id: int) -> None:
        from quest_config import load_quests
        config = load_quests()
        active = await conn.fetch(
            "SELECT quest_id,progress FROM quests WHERE char_id=$1 AND status=0 FOR UPDATE", char_id)
        for row in active:
            if row["quest_id"] in (GACHA_GUIDE_QUEST_ID, FORMATION_GUIDE_QUEST_ID):
                # These guides share the marker value used by Adventure battles.
                # Their own handlers verify the draw or active formation instead.
                continue
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
                if quest.quest_id == GACHA_GUIDE_QUEST_ID:
                    from local_draw import has_tutorial_draw_receipt

                    if not await has_tutorial_draw_receipt(conn, char_id):
                        return False, [], [], []
                    progress = [max(value, objective.amount)
                                for value, objective in zip(progress, objectives)]
                elif quest.quest_id == FORMATION_GUIDE_QUEST_ID:
                    if not await conn.fetchval(
                        """SELECT EXISTS (
                               SELECT 1 FROM pets WHERE char_id=$1 AND pet_template_id=$2
                                 AND slot_index BETWEEN 0 AND 2
                           )""",
                        char_id, GACHA_GUIDE_PET_ID,
                    ):
                        return False, [], [], []
                    progress = [max(value, objective.amount)
                                for value, objective in zip(progress, objectives)]
                elif quest.quest_id in (10005, 10006):
                    starter = await conn.fetchrow(
                        "SELECT pet_template_id,level,training_stage FROM pets WHERE char_id=$1 ORDER BY pet_uid LIMIT 1",
                        char_id,
                    )
                    if starter is None:
                        return False, [], [], []
                    qualified = starter["level"] >= 2 if quest.quest_id == 10005 else starter["training_stage"] >= 1
                    if not qualified:
                        return False, [], [], []
                    progress = [max(value, objective.amount)
                                for value, objective in zip(progress, objectives)]
                elif quest.quest_id == 10009:
                    if not await conn.fetchval(
                        """SELECT 1 FROM character_adventure_clears
                           WHERE char_id=$1 AND adventure_id=2 AND star_mask & 8 <> 0""", char_id
                    ):
                        return False, [], [], []
                    progress = [max(value, objective.amount)
                                for value, objective in zip(progress, objectives)]
                elif guide_marker:
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
                claim = {"awards": awards}
                if quest.quest_id == 10005 and starter["training_stage"] == 0:
                    material = await self._starter_training_material(conn, char_id, starter["pet_template_id"])
                    if material is not None:
                        if material["num"]:
                            awards.append(material)
                        claim["starter_training_supplied"] = True
                from reward_service import grant_rewards
                grant_result = await grant_rewards(conn, char_id, awards, self._grant_character_exp)
                pet_payloads = grant_result["pets"]
                claim["pets"] = pet_payloads
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
                    json.dumps(claim, separators=(",", ":")))
                return True, new_children, awards, pet_payloads

    @staticmethod
    async def _starter_training_material(conn, char_id, template_id):
        """Resolve the one-time guide supply from the first map preview and Stage 1 cost."""
        from client_config import table
        from pet_config import stage_costs

        if template_id not in (1, 4, 7) or not await conn.fetchval(
            """SELECT 1 FROM character_adventure_clears
               WHERE char_id=$1 AND adventure_id=1 AND star_mask & 8 <> 0""", char_id
        ):
            return None
        item_id = 154  # The Bag guide shows this item after Lost Forest.
        preview = table("AdventureInfo")[1]["rewards_Icon"].split(",")
        if str(item_id) not in preview or item_id not in table("ItemInfo"):
            return None
        needed = sum(row["num"] for row in stage_costs(template_id, 1)
                     if row["elementType"] == 3 and row["elementID"] == item_id)
        count = await conn.fetchval(
            "SELECT count FROM inventory WHERE char_id=$1 AND item_id=$2 FOR UPDATE", char_id, item_id)
        return {"kind": "item", "id": item_id, "num": max(0, needed - (count or 0))}

    async def reconcile_starter_training(self, char_id):
        """Supply the same guide material on login for existing affected saves."""
        async with self.pool.acquire() as conn:
            async with conn.transaction():
                await conn.fetchval("SELECT 1 FROM characters WHERE char_id=$1 FOR UPDATE", char_id)
                claim = await conn.fetchval(
                    """SELECT r.awards FROM quest_reward_claims r
                       JOIN quests q ON q.char_id=r.char_id AND q.quest_id=10006 AND q.status=0
                       WHERE r.char_id=$1 AND r.quest_id=10005
                         AND NOT (r.awards ? 'starter_training_supplied') FOR UPDATE OF r""", char_id)
                if claim is None:
                    return
                starter = await conn.fetchrow(
                    "SELECT pet_template_id,training_stage FROM pets WHERE char_id=$1 ORDER BY pet_uid LIMIT 1",
                    char_id)
                if starter is None or starter["training_stage"] != 0:
                    return
                material = await self._starter_training_material(conn, char_id, starter["pet_template_id"])
                if material is None:
                    return
                claim = json.loads(claim) if isinstance(claim, str) else dict(claim)
                if material["num"]:
                    from reward_service import grant_rewards

                    await grant_rewards(conn, char_id, [material], self._grant_character_exp)
                    claim.setdefault("awards", []).append(material)
                claim["starter_training_supplied"] = True
                await conn.execute(
                    "UPDATE quest_reward_claims SET awards=$2::jsonb WHERE char_id=$1 AND quest_id=10005",
                    char_id, json.dumps(claim))

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
        from handlers.progression import PROGRESS_FIELDS, achievement_progress
        from local_play import enabled, freedom, silver_override
        from progress import daily_state
        from stamina import balance_at
        from time import time
        row = await self.pool.fetchrow(
            "SELECT account_id,char_id,name,level,gold,diamond,vip_level,stamina,vip_points,recharge_total,currencies_json,game_values,created_at,world_id "
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
        now = int(time())
        stamina, stamina_time = balance_at(row, stored, now)
        daily = daily_state(stored, now)
        achievement = (await achievement_progress(self.pool, row, stored)
                       if PROGRESS_FIELDS.intersection(key.lower() for key in keys) else {})
        silver = silver_override(row)
        aliases = {
            "gold": row["gold"], "diamond": row["diamond"],
            "viplevel": vip_info_id(row["vip_level"]),
            "vip_level": row["vip_level"], "actionvalue": stamina,
            "stamina": stamina, "lastactionvaluechangetime": stamina_time, "vip_points": row["vip_points"],
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
            elif normalized in ("viplevel", "vip_level", "actionvalue", "stamina", "lastactionvaluechangetime"):
                raw_values[key] = aliases[normalized]
            elif normalized in achievement:
                raw_values[key] = achievement[normalized]
            elif normalized == "dailyquestpower":
                raw_values[key] = daily["power"]
            elif normalized in ("dailyquestgift0", "dailyquestgift1", "dailyquestgift2"):
                raw_values[key] = int(int(normalized[-1]) + 1 in daily["gifts"])
            elif normalized == "local_freedom":
                raw_values[key] = freedom(stored)
            elif normalized in ("local_unlimited_pet_storage", "local_unlimited_item_storage"):
                raw_values[key] = enabled(normalized.upper())
            elif normalized == "goldcoin":
                raw_values[key] = (silver if silver is not None
                                   else int(currencies.get("goldCoin", currencies.get("goldcoin", 0))))
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
                "UPDATE characters SET game_values=game_values || jsonb_build_object($2::text,$3::text) "
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

    async def exchange_inventory_stack(self, char_id, item_id, amount, rewards, *, operation=None):
        """Spend an existing stack and grant its configured exchange atomically."""
        from reward_service import receive_rewards

        if amount <= 0:
            return None
        async with self.pool.acquire() as conn, conn.transaction():
            char = await conn.fetchrow(
                "SELECT game_values FROM characters WHERE char_id=$1 FOR UPDATE", char_id)
            if char is None:
                return None
            receipts = {}
            if operation is not None:
                token, created, now, choice, request_count = operation
                values = json.loads(char["game_values"])
                receipts = {key: receipt for key, receipt in values.get("chest_receipts", {}).items()
                            if receipt[0] >= now - 86400}
                previous = receipts.get(token)
                if previous is not None and previous[1:4] != [item_id, choice, request_count]:
                    return None
            count = await conn.fetchval(
                "SELECT count FROM inventory WHERE char_id=$1 AND item_id=$2 FOR UPDATE",
                char_id, item_id)
            if operation is not None and previous is not None:
                return {"counts": {item_id: count or 0}, "wallet": None, "pets": [],
                        "exchange_rewards": previous[4]}
            if count is None or count < amount:
                return None
            remaining = count - amount
            granted = await receive_rewards(
                conn, char_id, char["game_values"], rewards, self._grant_character_exp,
                removed_item=item_id if remaining == 0 else None, debits={item_id: amount})
            if granted is None:
                return None
            final = int(granted["counts"].get(item_id, count)) - amount
            if final:
                await conn.execute("UPDATE inventory SET count=$3 WHERE char_id=$1 AND item_id=$2",
                                   char_id, item_id, final)
            else:
                await conn.execute("DELETE FROM inventory WHERE char_id=$1 AND item_id=$2", char_id, item_id)
            granted["counts"][item_id] = final
            if operation is not None:
                receipts[token] = [created, item_id, choice, request_count, rewards]
                await conn.execute(
                    """UPDATE characters SET game_values=game_values || jsonb_build_object('chest_receipts',$2::jsonb)
                       WHERE char_id=$1""", char_id, json.dumps(receipts))
            return granted

    async def manage_pet_skill(self, char_id, pet_uid, slot, book_id=None):
        """Validate and commit the slot change and its costs together."""
        from client_config import table
        from handlers.pet import pet_json
        from skill_config import replacement_skill, skill_book, skill_upgrade_costs

        if not 0 <= slot < 9:
            return None
        skills = table("PetSkillInfo")
        async with self.pool.acquire() as conn, conn.transaction():
            await conn.fetchval("SELECT char_id FROM characters WHERE char_id=$1 FOR UPDATE", char_id)
            pet = await conn.fetchrow("SELECT * FROM pets WHERE char_id=$1 AND pet_uid=$2 FOR UPDATE",
                                      char_id, pet_uid)
            if pet is None:
                return None
            active = json.loads(pet["skills_json"])
            passive = json.loads(pet["passive_skills_json"])
            if len(active) != 4 or slot >= 4 + len(passive):
                return None
            if book_id is None:
                skill_id = active[slot] if slot < 4 else passive[slot - 4]["paSkillID"]
                current, target = skills.get(skill_id), skills.get(skill_id + 1)
                costs = skill_upgrade_costs(current, target) if current else None
            else:
                book = skill_book(book_id)
                if book is None or not replacement_skill(pet["pet_template_id"], slot, active, passive, *book):
                    return None
                target = book[1]
                costs = {book_id: 1}
            if not costs or any(cost <= 0 for cost in costs.values()):
                return None
            owned = {row["item_id"]: row["count"] for row in await conn.fetch(
                """SELECT item_id,count FROM inventory WHERE char_id=$1
                   AND item_id=ANY($2::integer[]) ORDER BY item_id FOR UPDATE""", char_id, list(costs))}
            if any(owned.get(item_id, 0) < cost for item_id, cost in costs.items()):
                return None
            counts = {item_id: owned[item_id] - cost for item_id, cost in costs.items()}
            for item_id, remaining in counts.items():
                if remaining:
                    await conn.execute("UPDATE inventory SET count=$3 WHERE char_id=$1 AND item_id=$2",
                                       char_id, item_id, remaining)
                else:
                    await conn.execute("DELETE FROM inventory WHERE char_id=$1 AND item_id=$2", char_id, item_id)
            if slot < 4:
                active[slot] = target["id"]
            else:
                passive[slot - 4]["paSkillID"] = target["id"]
            updated = await conn.fetchrow(
                "UPDATE pets SET skills_json=$2::jsonb,passive_skills_json=$3::jsonb WHERE pet_uid=$1 RETURNING *",
                pet_uid, json.dumps(active), json.dumps(passive))
            return target["id"], counts, pet_json(updated)

    async def claim_seven_day_gift(self, char_id, gift, now, rewards, *, diamond_price=0):
        from reward_service import receive_rewards
        from seven_day_config import eligible

        key = f"seven{gift['id']}"
        async with self.pool.acquire() as conn, conn.transaction():
            char = await conn.fetchrow(
                "SELECT created_at,game_values,diamond,level FROM characters WHERE char_id=$1 FOR UPDATE", char_id)
            if char is None or char["diamond"] < diamond_price:
                return None
            age = now - char["created_at"].timestamp()
            values = json.loads(char["game_values"])
            if not (gift["openDay"] - 1) * 86400 <= age < 7 * 86400 or values.get(key) == 1:
                return None
            if not await eligible(conn, char_id, char["level"], gift["sevenQuestType"], gift["needCondition"]):
                return None
            state = await receive_rewards(conn, char_id, values, rewards, self._grant_character_exp)
            if state is None:
                return None
            updated = await conn.fetchrow(
                """UPDATE characters SET game_values=game_values || jsonb_build_object($2::text,1),
                   diamond=diamond-$3 WHERE char_id=$1 RETURNING *""", char_id, key, diamond_price)
            if diamond_price:
                state["wallet"] = updated
            return state

    @staticmethod
    async def _first_recharge_receipt(conn, char_id, begin, end, threshold):
        return await conn.fetchrow(
            """SELECT created_at FROM local_recharge_transactions
               WHERE char_id=$1 AND simulated AND paid_amount >= $2
                 AND created_at >= to_timestamp($3) AND created_at < to_timestamp($4)
               ORDER BY created_at,transaction_id LIMIT 1""", char_id, threshold, begin, end)

    async def first_recharge_mail(self, char_id, begin, end, threshold):
        async with self.pool.acquire() as conn:
            receipt = await self._first_recharge_receipt(conn, char_id, begin, end, threshold)
            if receipt is None:
                return None
            char = await conn.fetchrow(
                """SELECT first_charge_claimed,
                          (game_values->'first_recharge_mail_read' = 'true'::jsonb) AS is_read
                   FROM characters WHERE char_id=$1
                     AND game_values->'first_recharge_mail_deleted' IS DISTINCT FROM 'true'::jsonb""", char_id)
            return dict(char, created_at=receipt["created_at"]) if char else None

    async def mark_first_recharge_mail(self, char_id, *, delete):
        field = "first_recharge_mail_deleted" if delete else "first_recharge_mail_read"
        return bool(await self.pool.fetchval(
            """UPDATE characters SET game_values=game_values || jsonb_build_object($2::text,true)
               WHERE char_id=$1 AND (NOT $3::boolean OR first_charge_claimed) RETURNING 1""",
            char_id, field, delete))

    async def claim_first_recharge_mail(self, char_id, now, begin, end, threshold, rewards):
        from reward_service import receive_rewards

        if not begin <= now < end:
            return None
        async with self.pool.acquire() as conn, conn.transaction():
            char = await conn.fetchrow(
                "SELECT first_charge_claimed,game_values FROM characters WHERE char_id=$1 FOR UPDATE", char_id)
            receipt = await self._first_recharge_receipt(conn, char_id, begin, end, threshold)
            if char is None or receipt is None or char["first_charge_claimed"]:
                return None
            state = await receive_rewards(conn, char_id, char["game_values"], rewards, self._grant_character_exp)
            if state is None:
                return None
            await conn.execute(
                """UPDATE characters SET first_charge_claimed=true,
                   game_values=game_values || '{"first_recharge_mail_read":true}'::jsonb WHERE char_id=$1""", char_id)
            return state

    async def claim_adventure_cell(self, char_id: int, adventure_id: int, floor: int,
                                  map_col: int, map_row: int, rewards: list[dict]) -> list[str] | None:
        """Atomically grant a configured map-cell reward once and retain its ACK payload."""
        encoded = [json.dumps(reward, separators=(",", ":")) for reward in rewards]
        async with self.pool.acquire() as conn:
            async with conn.transaction():
                active = await conn.fetchval(
                    "SELECT adventure_id FROM character_adventures "
                    "WHERE char_id=$1 AND completed_at IS NULL FOR UPDATE", char_id)
                if active != adventure_id:
                    return None
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

    async def start_adventure(self, char_id: int, adventure_id: int, *, resume=False) -> None:
        async with self.pool.acquire() as conn, conn.transaction():
            started = await conn.fetchval(
                """INSERT INTO character_adventures(char_id,adventure_id)
                   VALUES($1,$2) ON CONFLICT(char_id) DO UPDATE
                   SET adventure_id=EXCLUDED.adventure_id,started_at=now(),completed_at=NULL,
                       completion_star=0,completion_awards_json='[]'::jsonb
                   WHERE character_adventures.completed_at IS NOT NULL
                       OR character_adventures.adventure_id<>EXCLUDED.adventure_id OR NOT $3 RETURNING 1""",
                char_id, adventure_id, resume)
            if started:
                await conn.execute(
                    "DELETE FROM adventure_fired_events WHERE char_id=$1 AND adventure_id=$2 AND event_id<0",
                    char_id, adventure_id)
                from progress import record
                await record(conn, char_id, "ADVENTURE_ENTERED")

    async def clear_skill_obstacle(self, char_id, adventure_id, scene_id, families):
        async with self.pool.acquire() as conn, conn.transaction():
            active = await conn.fetchval(
                """SELECT adventure_id FROM character_adventures
                   WHERE char_id=$1 AND completed_at IS NULL FOR UPDATE""", char_id)
            if active != adventure_id:
                return False
            # Negative event keys are run-local authored scene cells.
            if await conn.fetchval(
                """SELECT 1 FROM adventure_fired_events
                   WHERE char_id=$1 AND adventure_id=$2 AND event_id=$3""", char_id, adventure_id, -scene_id):
                return True
            pets = await conn.fetch("SELECT skills_json FROM pets WHERE char_id=$1", char_id)
            if not any(type(skill) is int and skill > 0 and skill // 10 in families
                       for pet in pets for skill in json.loads(pet["skills_json"])):
                return False
            await conn.execute(
                "INSERT INTO adventure_fired_events(char_id,adventure_id,event_id) VALUES($1,$2,$3)",
                char_id, adventure_id, -scene_id)
            return True

    async def adventure_tool(self, char_id, adventure_id, source_id, target_id=None):
        from adventure_config import TOOL_PICKED_OFFSET, TOOL_USED_OFFSET

        picked = -(TOOL_PICKED_OFFSET + source_id)
        used = -(TOOL_USED_OFFSET + source_id)
        async with self.pool.acquire() as conn, conn.transaction():
            active = await conn.fetchval(
                """SELECT adventure_id FROM character_adventures
                   WHERE char_id=$1 AND completed_at IS NULL FOR UPDATE""", char_id)
            if active != adventure_id:
                return False
            events = {r["event_id"] for r in await conn.fetch(
                """SELECT event_id FROM adventure_fired_events WHERE char_id=$1 AND adventure_id=$2
                   AND event_id=ANY($3::int[])""",
                char_id, adventure_id, [picked, used, -(target_id or 0)])}
            if target_id is None:
                if used in events:
                    return False
                additions = [picked]
            elif used in events:
                return -target_id in events
            else:
                if picked not in events or -target_id in events:
                    return False
                additions = [used, -target_id]
            await conn.executemany(
                """INSERT INTO adventure_fired_events(char_id,adventure_id,event_id) VALUES($1,$2,$3)
                   ON CONFLICT DO NOTHING""",
                [(char_id, adventure_id, event_id) for event_id in additions])
            return True

    async def current_adventure_id(self, char_id: int) -> int | None:
        return await self.pool.fetchval(
            "SELECT adventure_id FROM character_adventures WHERE char_id=$1 AND completed_at IS NULL",
            char_id,
        )

    async def latest_adventure_id(self, char_id: int) -> int | None:
        """Return the retained adventure ID, including a completed run for ACK retries."""
        return await self.pool.fetchval(
            "SELECT adventure_id FROM character_adventures WHERE char_id=$1", char_id)

    async def fired_adventure_event_ids(self, char_id: int, adventure_id: int) -> set[int]:
        rows = await self.pool.fetch(
            "SELECT event_id FROM adventure_fired_events WHERE char_id=$1 AND adventure_id=$2",
            char_id, adventure_id)
        return {row["event_id"] for row in rows}

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

    async def finish_adventure(self, char_id: int, adventure_id: int, star: int,
                               rewards: list[dict]) -> tuple[list[str], list[tuple[int, int, list[int]]]] | None:
        """Complete an adventure once, grant its configured rewards, and retain ACK data."""
        from reward_service import receive_rewards

        encoded = [json.dumps(reward, separators=(",", ":")) for reward in rewards]
        quest_updates = []
        async with self.pool.acquire() as conn:
            async with conn.transaction():
                row = await conn.fetchrow(
                    """SELECT adventure_id,completed_at,completion_star,completion_awards_json
                       FROM character_adventures WHERE char_id=$1 FOR UPDATE""", char_id)
                if row is None or row["adventure_id"] != adventure_id:
                    return None
                if row["completed_at"] is not None:
                    previous = row["completion_awards_json"] or []
                    if isinstance(previous, str):
                        previous = json.loads(previous)
                    return list(previous), quest_updates
                if star == 0:
                    encoded = []
                elif rewards:
                    values = await conn.fetchval(
                        "SELECT game_values FROM characters WHERE char_id=$1 FOR UPDATE", char_id)
                    if await receive_rewards(conn, char_id, values, rewards, self._grant_character_exp) is None:
                        return None
                await conn.execute(
                    """UPDATE character_adventures
                       SET completed_at=now(),completion_star=$2,completion_awards_json=$3::jsonb
                       WHERE char_id=$1""", char_id, star, json.dumps(encoded))
                # NewQuestInfo event 19 means that this configured Adventure
                # has been cleared. Persist that objective in the same
                # transaction as the clear and its rewards so the story quest
                # is claimable after relogin and cannot advance on a failed run.
                if star & 8:
                    from progress import record
                    difficulty = ("NORMAL", "ELITE", "HERO")[adventure_id // 10000]
                    await record(conn, char_id, f"ADVENTURE_{difficulty}_CLEARED")
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
                            quest_updates.append((quest.quest_id, 0, progress))
        return encoded, quest_updates

    async def grant_pet(self, char_id: int, template_id: int) -> asyncpg.Record | None:
        from pet_config import insert_owned_pet
        if template_id <= 0:
            return None
        return await insert_owned_pet(self.pool, char_id, template_id)


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

