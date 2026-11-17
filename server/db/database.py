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
                    "SELECT level FROM characters WHERE char_id=$1 FOR UPDATE", char_id)
                quest = await conn.fetchrow(
                    "SELECT status FROM quests WHERE char_id=$1 AND quest_id=$2 FOR UPDATE",
                    char_id, quest_id)
                if character is None or quest is None or quest["status"] != 0:
                    return False
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
        if group_id != 99998:
            return False
        async with self.pool.acquire() as conn:
            async with conn.transaction():
                active = await conn.fetchval(
                    "SELECT 1 FROM quests WHERE char_id=$1 AND quest_id=10001 AND status=0",
                    char_id)
                if not active:
                    return False
                await conn.execute(
                    "INSERT INTO tutorial_battle_sessions(char_id,session_id,group_id,state) "
                    "VALUES($1,$2,$3,'started')", char_id, session_id, group_id)
                return True

    async def finish_tutorial_battle(self, char_id: int, session_id: str, won: bool) -> bool:
        async with self.pool.acquire() as conn:
            async with conn.transaction():
                battle = await conn.fetchrow(
                    """SELECT battle_id FROM tutorial_battle_sessions
                       WHERE char_id=$1 AND session_id=$2 AND group_id=99998 AND state='started'
                       ORDER BY battle_id DESC LIMIT 1 FOR UPDATE""", char_id, session_id)
                if battle is None:
                    return False
                await conn.execute(
                    "UPDATE tutorial_battle_sessions SET state=$2,finished_at=now() WHERE battle_id=$1",
                    battle["battle_id"], "won" if won else "lost")
                if won:
                    await conn.execute(
                        "UPDATE quests SET progress='[1]'::jsonb WHERE char_id=$1 AND quest_id=10001 AND status=0",
                        char_id)
                return True

    async def commit_configured_tutorial_quest(self, char_id: int, quest,
                                               all_quests: dict[int, Any]) -> tuple[bool, list[int]]:
        """Atomically validate, complete, reward, unlock, and activate configured children."""
        amount = quest.objectives[0].amount if quest.objectives else 0
        if quest.quest_id not in (1, 10001, 10002, 10003) or amount <= 0:
            return False, []
        async with self.pool.acquire() as conn:
            async with conn.transaction():
                char = await conn.fetchrow(
                    "SELECT level,gold,exp,diamond,game_values FROM characters WHERE char_id=$1 FOR UPDATE",
                    char_id)
                current = await conn.fetchrow(
                    "SELECT status,progress FROM quests WHERE char_id=$1 AND quest_id=$2 FOR UPDATE",
                    char_id, quest.quest_id)
                if char is None or current is None:
                    return False, []
                if current["status"] == 1:
                    return True, []
                if current["status"] != 0:
                    return False, []
                if quest.parent_id:
                    parent = await conn.fetchval(
                        "SELECT status FROM quests WHERE char_id=$1 AND quest_id=$2",
                        char_id, quest.parent_id)
                    if parent != 1:
                        return False, []
                if quest.quest_id == 1:
                    proof = await conn.fetchval("SELECT 1 FROM pets WHERE char_id=$1 LIMIT 1", char_id)
                elif quest.quest_id == 10001:
                    proof = await conn.fetchval(
                        """SELECT 1 FROM tutorial_battle_sessions
                           WHERE char_id=$1 AND state='won' AND group_id=99998 LIMIT 1""", char_id)
                elif quest.quest_id == 10002:
                    proof = char["level"] >= 2
                else:  # 10003 follows the configured first main-mission claim (quest 2).
                    proof = await conn.fetchval(
                        "SELECT 1 FROM quests WHERE char_id=$1 AND quest_id=2 AND status=1", char_id)
                if not proof:
                    return False, []

                # Tutorial completion sends CommitQuest directly. Persist the
                # count from independently verified server evidence.
                progress = [amount]

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
                values = char["game_values"] or {}
                if isinstance(values, str): values = json.loads(values)
                map_lock = str(values.get("map_lock", "0"))
                if quest.unlock_map_id.isdigit():
                    unlocked = set(filter(None, map_lock.split("-")))
                    map_lock = map_lock if quest.unlock_map_id in unlocked else map_lock + "-" + quest.unlock_map_id
                await conn.execute(
                    """UPDATE quests SET status=1,progress=$3::jsonb WHERE char_id=$1 AND quest_id=$2""",
                    char_id, quest.quest_id, json.dumps([amount]))
                await conn.execute(
                    """UPDATE characters SET gold=gold+$2,exp=exp+$3,
                       diamond=diamond+$4,game_values=game_values || jsonb_build_object('map_lock',$5)
                       WHERE char_id=$1""",
                    char_id, gold, exp, quest.diamond_reward, map_lock)
                return True, new_children

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

