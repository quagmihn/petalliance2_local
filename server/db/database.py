from __future__ import annotations

import json
import os
from pathlib import Path
from typing import Any

import asyncpg

class Database:
    def __init__(self, pool: asyncpg.Pool):
        self.pool = pool

    @classmethod
    async def connect(cls, dsn: str | None = None) -> "Database":
        pool = await asyncpg.create_pool(dsn or os.getenv(
            "DATABASE_URL", "postgresql://monster2:monster2@127.0.0.1:5432/monster2_db"
        ))
        return cls(pool)

    async def initialize(self, schema: Path | None = None) -> None:
        sql = (schema or Path(__file__).with_name("schema.sql")).read_text()
        async with self.pool.acquire() as conn:
            await conn.execute(sql)

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
        return await self.pool.fetchrow(
            """INSERT INTO pets(char_id,pet_template_id,slot_index)
               VALUES($1,$2,0) RETURNING *""", char_id, template_id
        )

    async def create_character_with_pet(self, account_id: int, world_id: int, name: str,
                                        avatar: int, gender: int, pet_template_id: int):
        async with self.pool.acquire() as conn:
            async with conn.transaction():
                await conn.fetchrow("SELECT user_id FROM accounts WHERE user_id=$1 FOR UPDATE", account_id)
                char = await conn.fetchrow(
                    "SELECT * FROM characters WHERE account_id=$1 AND world_id=$2 FOR UPDATE",
                    account_id, world_id,
                )
                created = char is None
                if char is None:
                    char = await conn.fetchrow(
                        """INSERT INTO characters(account_id,world_id,name,avatar,gender)
                           VALUES($1,$2,$3,$4,$5) RETURNING *""",
                        account_id, world_id, name, avatar, gender,
                    )
                first_pet = await conn.fetchrow(
                    "SELECT * FROM pets WHERE char_id=$1 ORDER BY pet_uid LIMIT 1", char["char_id"]
                )
                if first_pet is None and pet_template_id:
                    first_pet = await conn.fetchrow(
                        """INSERT INTO pets(char_id,pet_template_id,slot_index)
                           VALUES($1,$2,0) RETURNING *""", char["char_id"], pet_template_id,
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
                           VALUES($1,jsonb_build_object('level',1,'homeName',$2,'furnitures','{}'::jsonb))
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

    async def commit_first_tutorial_quest(self, char_id: int) -> bool:
        """Complete configured quest 1 and activate its configured child 10001.

        Other quest commits require configuration-backed validation and reward
        delivery, so they are not accepted by this narrow transition.
        """
        async with self.pool.acquire() as conn:
            async with conn.transaction():
                current = await conn.fetchrow(
                    "SELECT status FROM quests WHERE char_id=$1 AND quest_id=1 FOR UPDATE",
                    char_id,
                )
                if current is None:
                    return False
                if current["status"] == 1:
                    child = await conn.fetchval(
                        "SELECT 1 FROM quests WHERE char_id=$1 AND quest_id=10001",
                        char_id,
                    )
                    return child is not None
                if current["status"] != 0:
                    return False
                await conn.execute(
                    "UPDATE quests SET status=1 WHERE char_id=$1 AND quest_id=1",
                    char_id,
                )
                await conn.execute(
                    """INSERT INTO quests(char_id,quest_id,status,progress)
                       VALUES($1,10001,0,'[0]'::jsonb)
                       ON CONFLICT(char_id,quest_id) DO NOTHING""",
                    char_id,
                )
                return True

    async def set_first_tutorial_progress(self, char_id: int, progress: list[int]) -> bool:
        if len(progress) != 1 or not 0 <= progress[0] <= 1:
            return False
        result = await self.pool.execute(
            "UPDATE quests SET progress=$3::jsonb WHERE char_id=$1 AND quest_id=1 AND status=0",
            char_id, 1, json.dumps(progress),
        )
        return not result.endswith(" 0")

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
        row = await self.pool.fetchrow(
            "SELECT gold,diamond,vip_level,stamina,vip_points,currencies_json,game_values "
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
            "gold": row["gold"], "diamond": row["diamond"], "viplevel": row["vip_level"],
            "vip_level": row["vip_level"], "actionvalue": row["stamina"],
            "stamina": row["stamina"], "vip_points": row["vip_points"],
            "map_lock": stored.get("map_lock", "0"),
        }
        for key in keys:
            normalized = key.lower()
            values[key] = stored.get(key, stored.get(normalized,
                          currencies.get(normalized, aliases.get(normalized, 0))))
        return values

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

    async def grant_pet(self, char_id: int, template_id: int) -> asyncpg.Record | None:
        if template_id <= 0:
            return None
        return await self.pool.fetchrow(
            """INSERT INTO pets(char_id,pet_template_id,level,star,evolution,slot_index)
               VALUES($1,$2,1,0,0,-1) RETURNING *""", char_id, template_id
        )

