import json
import logging
import re
import time

from protocol import Reader, Writer
from client_config import table
from chest_config import chest_rewards
from reward_config import selectable_reward
from reward_service import MAX_STACK
from skill_config import skill_book

log = logging.getLogger("game_socket.inventory")


def item_counts_update(counts):
    """Synchronize absolute counts for changed inventory stacks."""
    return 112, Writer().vector_strings([
        json.dumps({"itemID": item_id, "num": count}, separators=(",", ":"))
        for item_id, count in counts
    ]).bytes()


def inventory_packets(counts, *, initial=False):
    pieces = table("PetPieceInfo")
    ordinary, fragments, books = [], [], []
    for item_id, count in counts:
        if item_id in pieces:
            fragments.append(json.dumps({"itemID": item_id, "num": count}, separators=(",", ":")))
        elif skill_book(item_id):
            books.append(json.dumps({"itemID": item_id, "num": count}, separators=(",", ":")))
        else:
            ordinary.append((item_id, count))
    packets = [item_counts_update(ordinary)] if ordinary else []
    if fragments:
        packets.append((262, Writer().vector_strings(fragments).bytes()))
    if books:
        packets.append((583 if initial else 133, Writer().vector_strings(books).bytes()))
    return packets


def reward_packets(state):
    from handlers.economy import wallet_update

    packets = inventory_packets(state["counts"].items())
    if state["wallet"] is not None:
        wallet = state["wallet"]
        packets.append(wallet_update(wallet, {"level": wallet["level"], "exp": wallet["exp"]}))
    packets.extend((3141, Writer().u64(json.loads(pet)["objID"]).string(pet).bytes()) for pet in state["pets"])
    return packets


def award_strings(rewards):
    return [json.dumps({"elementType": reward["kind"], "elementID": reward["id"], "num": reward["num"]},
                       separators=(",", ":")) for reward in rewards]


async def get_items(session, payload: bytes):
    rows = []
    if session.char_id is not None:
        await session.db.reconcile_starter_training(session.char_id)
        rows = await session.db.pool.fetch(
            "SELECT item_id,count FROM inventory WHERE char_id=$1 ORDER BY item_id", session.char_id
        )
    # Proto_Item.lua acknowledgement counts items, equips, furniture, skillbooks,
    # and pet pieces; unknown catalog classifications remain zero.
    pieces = table("PetPieceInfo")
    fragments = sum(int(row["count"]) for row in rows if row["item_id"] in pieces)
    books = sum(int(row["count"]) for row in rows if skill_book(row["item_id"]))
    total = sum(int(row["count"]) for row in rows) - fragments - books
    ack = (Writer().u16(0).u32(min(total, MAX_STACK)).u32(0).u32(0)
           .u32(min(books, MAX_STACK)).u32(min(fragments, MAX_STACK)).bytes())
    responses = [(37, ack)]
    for start in range(0, len(rows) or 1, 255):
        batch = rows[start:start + 255]
        responses.extend(inventory_packets(((row["item_id"], row["count"]) for row in batch), initial=True)
                         if batch else [item_counts_update([])])
    return responses


async def use_item(session, payload: bytes):
    """Consume a supported configured item and report its committed state."""
    reader = Reader(payload)
    item_id, pet_uid, target_text, use_count = reader.u32(), reader.u32(), reader.string(), reader.u32()
    reader.finish()
    error = (526, Writer().u16(1).bytes())
    if session.char_id is None or use_count < 1:
        return error
    try:
        item = table("ItemInfo").get(item_id)
        if item is None or item["bUse"] != 1:
            return error
        # The Pet FEED/MAX UI sends a DWORD stack count in a single request.
        # Chests and other item commands still use their small action limit.
        if use_count > 99 and (item["itemType"] != 19 or not pet_uid):
            return error
        operation = None
        if target_text:
            token = re.fullmatch(r"local:([a-f0-9]{8})[a-f0-9]{16}", target_text)
            if item["itemType"] not in (18, 28) or not token:
                return error
            now = int(time.time())
            created = int(token[1], 16)
            if not now - 86400 <= created <= now + 60:
                return error
            operation = (target_text, created, now, pet_uid, use_count)
        if item["itemType"] == 22:
            fashion_id = item["paramA"]
            if pet_uid or use_count != 1 or fashion_id not in table("FashionItemInfo"):
                return error
            code, remaining, state = await session.db.redeem_fashion_item(
                session.char_id, item_id, fashion_id)
            if code:
                return 526, Writer().u16(code).bytes()
            return [
                item_counts_update([(item_id, remaining)]),
                (2105, Writer().string(json.dumps(state, separators=(",", ":"))).bytes()),
                (526, Writer().u16(0).u32(item_id).u32(remaining).vector_strings([]).bytes()),
            ]
        if item["itemType"] in (10, 18, 28):
            if item["paramA"] <= 0:
                return error
            if item["itemType"] == 28:
                # MultiItemBoxView sends the choice's reward quantity in useNum.
                rewards = [selectable_reward(item["paramA"], pet_uid, use_count)]
                use_count = 1
            elif pet_uid or any(item[k] for k in ("paramB", "paramC", "paramD", "paramE")):
                return error
            elif item["itemType"] == 10:
                rewards = [{"kind": "goldCoin", "id": 0, "num": item["paramA"] * use_count}]
            else:
                rewards = chest_rewards(item_id, use_count)
            if len(rewards) > 255:
                combined = {}
                for reward in rewards:
                    key = (reward["kind"], reward["id"], reward.get("gene_id"))
                    if key not in combined:
                        combined[key] = {**reward, "num": 0}
                    combined[key]["num"] += reward["num"]
                rewards = list(combined.values())
                if len(rewards) > 255:
                    return error
            state = await session.db.exchange_inventory_stack(session.char_id, item_id, use_count, rewards,
                                                              operation=operation)
            if state is None:
                return error
            remaining = state["counts"][item_id]
            # The selectable-box client builds its own reward popup after ACK.
            shown = [] if item["itemType"] == 28 else award_strings(state.get("exchange_rewards", rewards))
            ack = Writer().u16(0).u32(item_id).u32(remaining).vector_strings(shown)
            return [*reward_packets(state), (526, ack.bytes())]
        configured = table("GlobalConfigAddInfo")[9]["values"][:-1]
        if item_id not in configured or item["itemType"] != 19:
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
        pet_notification = Writer().u64(pet_uid).string(pet_payload).bytes()
        log.info("pet_exp_feed account_id=%s char_id=%s pet_uid=%s item_id=%s used=%s remaining=%s level=%s exp=%s",
                 getattr(session, "account_id", None), session.char_id, pet_uid,
                 item_id, use_count, state["remaining"], state["pet"]["level"], state["pet"]["exp"])
        # The feeding ACK invokes the Lua UI callback immediately. Send the
        # authoritative Pet and bag state first so that callback redraws from
        # the updated PokemonInfo/ItemInfo caches (the previous order let the
        # open feed panel render stale level/EXP until it was reopened).
        return [item_counts_update([(item_id, state["remaining"])]),
                (3141, pet_notification), (526, ack)]
    except (KeyError, TypeError, ValueError, IndexError) as exc:
        log.warning("item_use_rejected account_id=%s char_id=%s pet_uid=%s item_id=%s reason=%s",
                    getattr(session, "account_id", None), session.char_id, pet_uid, item_id, exc)
        return error


async def compound_pet_piece(session, payload: bytes):
    from pet_config import acquisition_skill_pools

    reader = Reader(payload)
    piece_id = reader.u32()
    reader.finish()
    error = (84, Writer().u16(1).bytes())
    piece = table("PetPieceInfo").get(piece_id)
    item = table("ItemInfo").get(piece_id)
    if session.char_id is None or not piece or piece["num"] <= 0 or not item or item["itemType"] != 15:
        return error
    gene = table("GeneInfo").get(piece["pokeID"])
    if not gene:
        return error
    pet_id = gene["petID"]
    try:
        acquisition_skill_pools(pet_id)
    except ValueError:
        return error
    result = await session.db.exchange_inventory_stack(
        session.char_id, piece_id, piece["num"], [{"kind": "pet", "id": pet_id, "num": 1}])
    if result is None:
        return error
    return [*reward_packets(result), (84, Writer().u16(0).bytes())]
