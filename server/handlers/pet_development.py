"""Transactional stat training and reserved-Pet Relation bindings."""
import json

from client_config import table
from handlers.economy import wallet_update
from handlers.inventory import item_counts_update
from handlers.pet import pet_json
from pet_development import ATTRIBUTES, OVERFLOW, OVERFLOW_FOR, state, totals, yoke_values
from progress import record
from protocol import Reader, Writer

TRAIN_ACKS = {1717: 1699, 1694: 1714, 665: 663}
RELATION_ACKS = {2010: 2035, 2037: 1991, 1966: 1973}


def pet_packet(uid, encoded):
    return 3141, Writer().u64(uid).string(encoded).bytes()


async def train(session, request, payload):
    reply = TRAIN_ACKS[request]
    fail = (reply, Writer().u16(1).bytes())
    r = Reader(payload)
    uid = r.u32()
    details = r.string(limit=256) if request != 1694 else ""
    r.finish()
    if session.char_id is None:
        return fail
    if request == 1717:
        try:
            points = json.loads(details)
        except (ValueError, RecursionError):
            return fail
        if (not isinstance(points, dict) or set(points) - set(ATTRIBUTES)
                or any(type(n) is not int or not 0 <= n <= 400 for n in points.values())):
            return fail
        if sum(n > 0 for n in points.values()) != 1:
            return fail
    elif request == 665 and details not in OVERFLOW:
        return fail
    char_id = session.char_id
    async with session.db.pool.acquire() as conn, conn.transaction():
        wallet = await conn.fetchrow("SELECT * FROM characters WHERE char_id=$1 FOR UPDATE", char_id)
        pet = await conn.fetchrow("SELECT * FROM pets WHERE char_id=$1 AND pet_uid=$2 FOR UPDATE", char_id, uid)
        if not wallet or not pet:
            return fail
        saved = state(pet)
        used = sum(saved.get(key, 0) for key in ATTRIBUTES)
        cap, limits = totals(pet, saved)
        costs = table("PetStrengthenInfo")
        gold, diamond = 0, 0
        notices = []
        if request == 1717:
            attr, amount = next((key, n) for key, n in points.items() if n)
            current = saved.get(attr, 0)
            if used + amount > min(cap, max(costs)) or current + amount > limits[attr]:
                return fail
            gold = -sum(costs[step]["gcash"] for step in range(used + 1, used + amount + 1))
            if wallet["gold"] < -gold:
                return fail
            saved[attr] = current + amount
        elif request == 665:
            current = saved.get(details, 0)
            prices = table("GlobalConfigAddInfo")[OVERFLOW[details]]["values"]
            if current * 2 + 1 >= len(prices):
                return fail
            if details != "oall":
                attr = next(key for key in ATTRIBUTES if OVERFLOW_FOR[key] == details)
                if saved.get(attr, 0) < limits[attr]:
                    return fail
            item, amount = prices[2 * current:2 * current + 2]
            left = await conn.fetchval(
                """UPDATE inventory SET count=count-$3 WHERE char_id=$1 AND item_id=$2
                   AND count>=$3 RETURNING count""", char_id, item, amount)
            if left is None:
                return fail
            if not left:
                await conn.execute("DELETE FROM inventory WHERE char_id=$1 AND item_id=$2", char_id, item)
            notices.append(item_counts_update([(item, left)]))
            saved[details] = current + 1
        else:
            diamond = -table("GlobalConfigAddInfo")[8]["values"][0]
            if not used or wallet["diamond"] < -diamond:
                return fail
            gold = sum(costs[step]["gcash"] for step in range(1, used + 1)) * 60 // 100
            for attr in ATTRIBUTES:
                saved.pop(attr, None)
        row = await conn.fetchrow("UPDATE pets SET development_json=$2::jsonb WHERE pet_uid=$1 RETURNING *",
                                  uid, json.dumps(saved))
        encoded = pet_json(row)
        if gold or diamond:
            row = await conn.fetchrow(
                "UPDATE characters SET gold=gold+$2,diamond=diamond+$3 WHERE char_id=$1 RETURNING *",
                char_id, gold, diamond)
            notices.append(wallet_update(row))
        if request == 1717:
            await record(conn, char_id, "PET_TRAINED", amount)
    # The target Train screen increments its current value in the success
    # callback. Send the authoritative replacement after it finishes.
    return [*notices, (reply, Writer().u16(0).string(encoded).bytes()), pet_packet(uid, encoded)]


async def relation(session, request, payload):
    reply = RELATION_ACKS[request]
    fail = (reply, Writer().u16(1).bytes())
    reader = Reader(payload)
    uid, relation_id, slot = reader.u32(), reader.u16(), reader.u16()
    helper = reader.u32() if request != 1966 else 0
    reader.finish()
    if session.char_id is None or helper == uid:
        return fail
    plan = table("YokeInfo").get(relation_id)
    if not plan or slot >= len(plan["pets"]):
        return fail
    async with session.db.pool.acquire() as conn, conn.transaction():
        char_id = session.char_id
        await conn.fetchval("SELECT char_id FROM characters WHERE char_id=$1 FOR UPDATE", char_id)
        pets = {row["pet_uid"]: row for row in await conn.fetch("SELECT * FROM pets WHERE char_id=$1", char_id)}
        main = pets.get(uid)
        if not main or relation_id not in table("PokemonInfo")[main["pet_template_id"]]["yokeVec"]:
            return fail
        saved = state(main)
        main_yoke = saved.get("yoke", {})
        if main_yoke.get("bindTo"):
            return fail
        detail = main_yoke.get("yokeDetail", {})
        slots = detail.get(str(relation_id), [0] * len(plan["pets"]))
        previous = slots[slot]
        if previous == helper and (helper or request == 1966):
            return reply, Writer().u16(0).bytes()
        if bool(previous) != (request != 2010) or (request != 1966 and not helper):
            return fail
        if helper:
            candidate = pets.get(helper)
            if not candidate or candidate["slot_index"] >= 0 or candidate["pet_template_id"] != plan["pets"][slot]:
                return fail
            candidate_state = state(candidate)
            if candidate_state.get("yoke"):
                return fail
        changes = {uid: saved}
        if previous:
            old = state(pets[previous])
            old.pop("yoke", None)
            changes[previous] = old
        if helper:
            candidate_state["yoke"] = {"bindTo": uid}
            changes[helper] = candidate_state
        slots[slot] = helper
        if any(slots):
            detail[str(relation_id)] = slots
        else:
            detail.pop(str(relation_id), None)
        if detail:
            saved["yoke"] = {"yokeDetail": detail, "yokeValues": yoke_values(detail, pets)}
        else:
            saved.pop("yoke", None)
        packets = []
        for pet_uid, update in changes.items():
            row = await conn.fetchrow("UPDATE pets SET development_json=$2::jsonb WHERE pet_uid=$1 RETURNING *",
                                      pet_uid, json.dumps(update))
            packets.append(pet_packet(pet_uid, pet_json(row)))
    packets.append((2041, Writer().json_string({str(key): update.get("yoke", 0) for key, update in changes.items()}).bytes()))
    packets.append((reply, Writer().u16(0).bytes()))
    return packets
