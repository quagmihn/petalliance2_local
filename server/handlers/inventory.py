import json
import logging

from protocol import Writer
from client_config import table

log = logging.getLogger("game_socket.inventory")


async def get_items(session, payload: bytes):
    rows = []
    if session.char_id is not None:
        rows = await session.db.pool.fetch(
            "SELECT item_id,count FROM inventory WHERE char_id=$1 ORDER BY item_id", session.char_id
        )
    # Proto_Item.lua acknowledgement counts items, equips, furniture, skillbooks,
    # and pet pieces; unknown catalog classifications remain zero.
    total = sum(int(row["count"]) for row in rows)
    ack = Writer().u16(0).u32(total).u32(0).u32(0).u32(0).u32(0).bytes()
    responses = [(37, ack)]
    for start in range(0, len(rows) or 1, 255):
        batch = rows[start:start + 255]
        items = [json.dumps(
            {"itemID": row["item_id"], "num": row["count"]}, separators=(",", ":")
        ) for row in batch]
        responses.append((112, Writer().vector_strings(items).bytes()))
    return responses


async def use_item(session, payload: bytes):
    """Use a configured Pet EXP potion with atomic inventory/Pet persistence."""
    from protocol import Reader

    reader = Reader(payload)
    item_id, pet_uid, target_text, use_count = reader.u32(), reader.u32(), reader.string(), reader.u32()
    reader.finish()
    error = (526, Writer().u16(1).bytes())
    if session.char_id is None or target_text or use_count < 1 or use_count > 99:
        return error
    try:
        item = table("ItemInfo").get(item_id)
        configured = table("GlobalConfigAddInfo")[9]["values"][:-1]
        if item_id not in configured or item is None or item["itemType"] != 19 or item["bUse"] != 1:
            raise ValueError("item is not a configured Pet EXP potion")
        item_exp = int(item["paramA"])
        if item_exp <= 0:
            raise ValueError("Pet EXP potion has no positive configured EXP")
        state = await session.db.feed_pet_exp(
            session.char_id, pet_uid, item_id, use_count, item_exp)
        if state is None:
            return error
        pet_payload = state["pet_json"]
        ack = (Writer().u16(0).u32(item_id).u32(state["remaining"])
               .vector_strings([]).bytes())
        item_notification = Writer().vector_strings([
            json.dumps({"itemID": item_id, "num": state["remaining"]}, separators=(",", ":"))
        ]).bytes()
        pet_notification = Writer().u64(pet_uid).string(pet_payload).bytes()
        log.info("pet_exp_feed account_id=%s char_id=%s pet_uid=%s item_id=%s used=%s remaining=%s level=%s exp=%s",
                 getattr(session, "account_id", None), session.char_id, pet_uid,
                 item_id, use_count, state["remaining"], state["pet"]["level"], state["pet"]["exp"])
        # The feeding ACK invokes the Lua UI callback immediately. Send the
        # authoritative Pet and bag state first so that callback redraws from
        # the updated PokemonInfo/ItemInfo caches (the previous order let the
        # open feed panel render stale level/EXP until it was reopened).
        return [(112, item_notification), (3141, pet_notification), (526, ack)]
    except (KeyError, TypeError, ValueError, IndexError) as exc:
        log.warning("pet_exp_feed_rejected account_id=%s char_id=%s pet_uid=%s item_id=%s reason=%s",
                    getattr(session, "account_id", None), session.char_id, pet_uid, item_id, exc)
        return error
