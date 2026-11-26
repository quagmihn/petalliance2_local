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
        elif kind == "goldCoin":
            await conn.execute(
                """UPDATE characters SET currencies_json=currencies_json ||
                   jsonb_build_object('goldCoin',coalesce((currencies_json->>'goldCoin')::bigint,0)+$2)
                   WHERE char_id=$1""", char_id, amount)
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
            from pet_config import insert_owned_pet
            for _ in range(amount):
                pet = await insert_owned_pet(conn, char_id, element_id)
                pets.append(pet_json(pet))
        else:
            raise ValueError(f"unsupported reward kind {kind}")
    return {"item_ids": sorted(items), "wallet_changed": wallet_changed, "pets": pets}


async def receive_rewards(conn, char_id, values, rewards, grant_character_exp, *, removed_item=None):
    """Check capacities and return authoritative notices within the transaction."""
    from character_values import validate_character_values

    if isinstance(values, str):
        values = json.loads(values)
    capacities = validate_character_values(["itemPacketNum", "petPacketNum"], values or {})
    pet_count = sum(int(r["num"]) for r in rewards if r["kind"] == "pet")
    if pet_count and pet_count + await conn.fetchval(
            "SELECT count(*) FROM pets WHERE char_id=$1", char_id) > capacities["petPacketNum"]:
        return None
    item_ids = {r["id"] for r in rewards if r["kind"] == "item"}
    if item_ids:
        owned = {row["item_id"] for row in await conn.fetch(
            "SELECT item_id FROM inventory WHERE char_id=$1", char_id)}
        owned.discard(removed_item)
        if len(owned | item_ids) > capacities["itemPacketNum"]:
            return None
    granted = await grant_rewards(conn, char_id, rewards, grant_character_exp)
    wallet = await conn.fetchrow("SELECT * FROM characters WHERE char_id=$1", char_id) if (
        granted["wallet_changed"] or any(r["kind"] == "exp" for r in rewards)) else None
    return {
        "wallet": wallet, "pets": granted["pets"],
        "counts": dict(await conn.fetch(
            "SELECT item_id,count FROM inventory WHERE char_id=$1 AND item_id=ANY($2::integer[])",
            char_id, granted["item_ids"])),
    }
