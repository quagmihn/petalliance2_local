"""Commit evolution and its optional skill substitutions for an owned Pet."""
import json
import logging

from client_config import table
from handlers.inventory import inventory_packets
from handlers.pet import pet_json
from pet_config import is_star_material, json_value
from pet_development import state, yoke_values
from pet_evolution import branches, evolution_costs, is_super, new_skills, validate_route, weighted_choice
from protocol import Reader, Writer

log = logging.getLogger("game_socket.pet_evolution")


async def evolve(session, payload, ack_id):
    reader = Reader(payload)
    uid, choice, protect_skin = reader.u32(), reader.u16(), reader.u8()
    reader.finish()
    failure = (ack_id, Writer().u16(1).bytes())
    if session.char_id is None or protect_skin not in (0, 1):
        return failure
    try:
        result = await commit_evolution(session, uid, choice, protect_skin, super_evolution=ack_id == 728)
    except (KeyError, ValueError) as exc:
        log.warning("evolution_rejected char_id=%s pet_uid=%s reason=%s", session.char_id, uid, exc)
        return failure
    if result is None:
        return failure
    from handlers.economy import wallet_update

    updated, helper_packets, material_ids, counts, wallet, offers = result
    body = Writer().u16(0).u32(uid).u32(updated["pet_template_id"]).u8(len(offers))
    for skill in offers:
        body.u32(skill["skillType"]).u32(skill["skillArrID"]).u32(skill["skillPosType"])
    return [*inventory_packets(counts), wallet_update(wallet),
            *((3138, Writer().u64(pet_id).bytes()) for pet_id in material_ids),
            *helper_packets, pet_update(updated), (ack_id, body.bytes())]


def pet_update(row):
    return 3141, Writer().u64(row["pet_uid"]).string(pet_json(row)).bytes()


async def related_pets(conn, char_id, pet, saved, species, super_evolution):
    detail = saved.get("yoke", {}).get("yokeDetail", {})
    plans = table("YokeInfo")
    config = species[pet["pet_template_id"]]
    allowed = set(config["yokeVec"])
    if super_evolution:
        if pet["star"] != 5:
            return None
        for key in allowed:
            required = plans[key]["pets"]
            slots = detail.get(str(key), ())
            if len(slots) != len(required) or not all(slots):
                return None
    expected = {}
    for key, slots in detail.items():
        index = int(key)
        if index not in allowed or len(plans[index]["pets"]) != len(slots):
            return None
        for helper, template in zip(slots, plans[index]["pets"], strict=True):
            if not helper:
                continue
            if helper in expected or helper == pet["pet_uid"]:
                return None
            expected[helper] = template
    helpers = {row["pet_uid"]: row for row in await conn.fetch(
        "SELECT * FROM pets WHERE char_id=$1 AND pet_uid=ANY($2::bigint[]) ORDER BY pet_uid FOR UPDATE",
        char_id, sorted(expected))}
    if helpers.keys() != expected.keys():
        return None
    for uid, helper in helpers.items():
        if (helper["pet_template_id"] != expected[uid] or helper["slot_index"] != -1
                or state(helper).get("yoke", {}).get("bindTo") != pet["pet_uid"]
                or (super_evolution and (helper["star"] != 5 or json_value(helper["equips_json"])))):
            return None
    return helpers


async def commit_evolution(session, uid, choice, protect_skin, *, super_evolution):
    char_id = session.char_id
    session_id = session.session_id
    species = table("PokemonInfo")
    async with session.db.pool.acquire() as conn, conn.transaction():
        char = await conn.fetchrow("SELECT * FROM characters WHERE char_id=$1 FOR UPDATE", char_id)
        pet = await conn.fetchrow("SELECT * FROM pets WHERE char_id=$1 AND pet_uid=$2 FOR UPDATE", char_id, uid)
        if char is None or pet is None or is_star_material(pet["pet_template_id"]):
            return None
        template = pet["pet_template_id"]
        if not 1 <= choice <= len(branches(template)):
            return None
        route = validate_route(template, choice)
        saved = state(pet)
        if (pet["level"] < route["level"] or is_super(route) != super_evolution
                or saved.get("yoke", {}).get("bindTo")
                or saved.get("evo_offer_session") == session_id):
            return None
        helpers = await related_pets(conn, char_id, pet, saved, species, super_evolution)
        if helpers is None:
            return None
        outcome = weighted_choice([(entry["rate"], entry) for entry in route["EvoRateInfoVec"]])
        new_race = outcome["newRace"]
        costs = evolution_costs(route)
        skin = 0
        if protect_skin:
            old_skin = saved.get("skin", 0)
            old_skins = species[template]["skins"]
            if not 1 <= old_skin <= len(old_skins):
                return None
            attr = old_skins[old_skin - 1]["attribType"]
            skin = next((i for i, variant in enumerate(species[new_race]["skins"], 1)
                         if variant["attribType"] == attr), 0)
            if not skin:
                return None
            costs[2, 0] += table("GlobalConfigAddInfo")[6302]["values"][0]
        gold = sum(amount for (kind, _), amount in costs.items() if kind == 1)
        diamonds = sum(amount for (kind, _), amount in costs.items() if kind == 2)
        if char["gold"] < gold or char["diamond"] < diamonds:
            return None
        item_costs = {item: amount for (kind, item), amount in costs.items() if kind == 3}
        inventory = dict(await conn.fetch(
            "SELECT item_id,count FROM inventory WHERE char_id=$1 AND item_id=ANY($2::int[]) ORDER BY item_id FOR UPDATE",
            char_id, sorted(item_costs)))
        if any(inventory.get(item, 0) < amount for item, amount in item_costs.items()):
            return None
        offers = new_skills(outcome)

        counts = []
        for item, amount in item_costs.items():
            remaining = inventory[item] - amount
            if remaining:
                await conn.execute("UPDATE inventory SET count=$3 WHERE char_id=$1 AND item_id=$2",
                                   char_id, item, remaining)
            else:
                await conn.execute("DELETE FROM inventory WHERE char_id=$1 AND item_id=$2", char_id, item)
            counts.append((item, remaining))
        wallet = await conn.fetchrow(
            "UPDATE characters SET gold=gold-$2,diamond=diamond-$3 WHERE char_id=$1 RETURNING *",
            char_id, gold, diamonds)

        material_ids, helper_packets = [], []
        detail = saved.get("yoke", {}).get("yokeDetail", {})
        if super_evolution and helpers:
            material_ids = sorted(helpers)
            # A captured helper can be consumed, but its encounter stays closed
            # and the historical capture attempt remains recorded.
            await conn.execute(
                """UPDATE tutorial_battle_sessions SET captured_pet_uid=NULL,capture_attempts_remaining=0
                   WHERE char_id=$1 AND captured_pet_uid=ANY($2::bigint[])""", char_id, material_ids)
            await conn.execute("DELETE FROM pets WHERE char_id=$1 AND pet_uid=ANY($2::bigint[])",
                               char_id, material_ids)
        retained = {key: slots for key, slots in detail.items()
                    if not super_evolution and int(key) in species[new_race]["yokeVec"]}
        if retained:
            saved["yoke"] = {"yokeDetail": retained, "yokeValues": yoke_values(retained, helpers)}
        else:
            saved.pop("yoke", None)
        if not super_evolution:
            kept_uids = {helper for slots in retained.values() for helper in slots}
            for helper_uid in helpers.keys() - kept_uids:
                helper_state = state(helpers[helper_uid])
                helper_state.pop("yoke", None)
                update = await conn.fetchrow(
                    "UPDATE pets SET development_json=$2::jsonb WHERE pet_uid=$1 RETURNING *",
                    helper_uid, json.dumps(helper_state))
                helper_packets.append(pet_update(update))
        if skin:
            saved["skin"] = skin
        else:
            saved.pop("skin", None)
        saved.pop("evo_offers", None)
        saved.pop("evo_offer_session", None)
        if offers:
            saved.update(evo_offers=offers, evo_offer_session=session_id)
        updated = await conn.fetchrow(
            """UPDATE pets SET pet_template_id=$2,star=$3,evolution=evolution+1,
                   development_json=$4::jsonb WHERE pet_uid=$1 RETURNING *""",
            uid, new_race, 0 if super_evolution else pet["star"], json.dumps(saved))
        # Verify snapshots in the transaction so a server-side data problem
        # cannot charge for a Pet that the current client cannot load.
        pet_json(updated)
        log.info("pet_evolved char_id=%s uid=%s old=%s new=%s super=%s",
                 char_id, uid, template, new_race, super_evolution)
        return updated, helper_packets, material_ids, counts, wallet, offers


async def evolution_skills(session, payload, *, clear=False):
    reader = Reader(payload)
    uid = reader.u32()
    slot, skill_id = (0, 0) if clear else (reader.u32(), reader.u32())
    reader.finish()
    ack = 414 if clear else 1653
    failure = (ack, Writer().u16(1).bytes())
    if session.char_id is None:
        return failure
    async with session.db.pool.acquire() as conn, conn.transaction():
        await conn.fetchval("SELECT char_id FROM characters WHERE char_id=$1 FOR UPDATE", session.char_id)
        pet = await conn.fetchrow("SELECT * FROM pets WHERE char_id=$1 AND pet_uid=$2 FOR UPDATE",
                                  session.char_id, uid)
        if pet is None:
            return failure
        saved = state(pet)
        if clear:
            saved.pop("evo_offer_session", None)
            saved.pop("evo_offers", None)
            await conn.execute("UPDATE pets SET development_json=$2::jsonb WHERE pet_uid=$1", uid, json.dumps(saved))
            return ack, Writer().u16(0).bytes()
        offers = saved.get("evo_offers", [])
        index = next((i for i, offer in enumerate(offers) if offer["skillArrID"] == skill_id), None)
        if index is None:
            return failure
        offer = offers[index]
        active, passive = json_value(pet["skills_json"]), json_value(pet["passive_skills_json"])
        if offer["skillType"] in (0, 1, 8):
            if slot >= len(active) or table("PetSkillInfo").get(active[slot], {}).get("skill_A_Type") != offer["skillType"]:
                return failure
            active[slot] = skill_id
        else:
            index_slot = slot - len(active)
            if not 0 <= index_slot < len(passive) or passive[index_slot]["paSkillType"] != offer["skillPosType"]:
                return failure
            passive[index_slot]["paSkillID"] = skill_id
        offers.pop(index)
        updated = await conn.fetchrow(
            """UPDATE pets SET skills_json=$2::jsonb,passive_skills_json=$3::jsonb,
                   development_json=$4::jsonb WHERE pet_uid=$1 RETURNING *""",
            uid, json.dumps(active), json.dumps(passive), json.dumps(saved))
        packet = pet_update(updated)
    return [packet, (ack, Writer().u16(0).u32(uid).u32(slot).u32(skill_id).bytes())]
