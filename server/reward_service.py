"""Apply already-resolved rewards inside the caller's PostgreSQL transaction."""
from __future__ import annotations

import json
from collections.abc import Awaitable, Callable


async def grant_rewards(conn, char_id: int, rewards: list[dict],
                        grant_character_exp: Callable[[object, int, int], Awaitable[None]]) -> dict:
    """Grant normalized configured rewards atomically; caller owns transaction."""
    items: set[int] = set()
    pets: list[str] = []
    wallet_changed = False
    for reward in rewards:
        kind, element_id, amount = reward["kind"], int(reward["id"]), int(reward["num"])
        if amount <= 0:
            raise ValueError("reward amount must be positive")
        if kind == "g_cash":
            await conn.execute("UPDATE characters SET gold=gold+$2 WHERE char_id=$1", char_id, amount)
            wallet_changed = True
        elif kind == "m_cash":
            await conn.execute("UPDATE characters SET diamond=diamond+$2 WHERE char_id=$1", char_id, amount)
            wallet_changed = True
        elif kind == "exp":
            await grant_character_exp(conn, char_id, amount)
        elif kind == "item":
            await conn.execute(
                """INSERT INTO inventory(char_id,item_id,count) VALUES($1,$2,$3)
                   ON CONFLICT(char_id,item_id) DO UPDATE
                   SET count=inventory.count+EXCLUDED.count""", char_id, element_id, amount)
            items.add(element_id)
        elif kind == "pet":
            from handlers.pet import pet_json
            from pet_config import starting_skills
            for _ in range(amount):
                skills, passive = starting_skills(element_id)
                pet = await conn.fetchrow(
                    """INSERT INTO pets(char_id,pet_template_id,slot_index,skills_json,passive_skills_json)
                       VALUES($1,$2,-1,$3::jsonb,$4::jsonb) RETURNING *""",
                    char_id, element_id, json.dumps(skills), json.dumps(passive))
                pets.append(pet_json(pet))
        else:
            raise ValueError(f"unsupported reward kind {kind}")
    return {"item_ids": sorted(items), "wallet_changed": wallet_changed, "pets": pets}
