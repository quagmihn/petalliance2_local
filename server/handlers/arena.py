"""Local Arena roster and compatible BattleScene snapshots."""
from functools import cache
import json
from pathlib import Path
import os
from uuid import uuid4

from battle_group_config import resolve_monster_man_group
from client_config import table
from fashion_config import default_fashion_ids
from handlers.pet import pet_json
from local_play import enabled, freedom
from pet_config import star_percent
from protocol import Reader, Writer


@cache
def opponents():
    groups = json.loads((Path(__file__).resolve().parents[1] / "config/local-arena.json").read_text())["groups"]
    roster = {}
    for rank, group in enumerate(groups, 1):
        enemies, _ = resolve_monster_man_group(group)
        pets, power = [], 0
        for slot, enemy in enumerate(enemies):
            original = table("MonstrosityInfo")[enemy["mID"]]
            uid = 2000000000 + rank * 10 + slot
            level, stage, star = enemy["level"], enemy["petStage"], enemy["petStar"]
            stats = table("PokemonInfo")[original["petnumber"]]
            baseline = 1 + level / 12 + 3 * stage / 40
            base_stats = [int(stats[key] * baseline * (1 + star * star_percent() / 100)) for key in
                          ("lifeRateValue", "atkRateValue", "defRateValue", "satkRateValue", "sdefRateValue", "speedRateValue")]
            fc = sum(base_stats)
            skills = [enemy[key] for key in ("skill1", "skill2", "skill3")] + [original["skill4"]]
            if not skills[0] or any(skill and skill not in table("SkillInfo") for skill in skills):
                raise ValueError(f"invalid Arena battle skills for group {group}")
            pet = json.loads(pet_json({
                "pet_uid": uid, "pet_template_id": original["petnumber"], "level": level, "exp": 0,
                "training_stage": stage, "star": star, "evolution": 0, "skills_json": skills,
                "passive_skills_json": [{"paSkillType": 0, "paSkillID": skill}
                                        for skill in original["paSkills"] if skill in table("SkillInfo")],
                "equips_json": [],
            }))
            pet["fc"] = fc
            pets.append(pet)
            power += fc
        profile = {"_id": 2000000000 + rank, "name": f"Local Trainer {rank}", "rank": rank, "level": max(p["level"] for p in pets),
                   "fightPoint": power, "vipLevel": 1, "teamID": 1, "gender": 0, "zoneID": 1,
                   "petObjIDs": [p["objID"] for p in pets],
                   "fashion": {"curFashion": default_fashion_ids()}}
        roster[rank] = (profile, [json.dumps(pet, separators=(",", ":")) for pet in pets])
    return roster


ACKS = {277: 51, 460: 416, 317: 356, 1175: 1239, 1235: 1305, 517: 589, 267: 265}


async def handle(session, request, payload):
    ack = ACKS[request]
    fail = (ack, Writer().u16(1).bytes())
    if not enabled("LOCAL_NPC_ARENA") or session.char_id is None:
        return fail
    char = await session.db.pool.fetchrow("SELECT level,game_values FROM characters WHERE char_id=$1", session.char_id)
    values = json.loads(char["game_values"])
    if not freedom(values) and char["level"] < table("GlobalConfigAddInfo")[24002]["values"][0]:
        return fail
    roster = opponents()
    rank = len(roster) + 1
    reader = Reader(payload)
    body = Writer().u16(0)
    if request in (277, 460, 517):
        attack_rank = reader.u32() if request == 517 else 0
        if request != 277:
            team, count = reader.u32(), reader.u8()
            requested_pets = [reader.u32() for _ in range(count)]
            if team != 1 or count > 6:
                return fail
        else:
            requested_pets = []
        reader.finish()
        rows = await session.db.pool.fetch(
            "SELECT * FROM pets WHERE char_id=$1 AND slot_index BETWEEN 0 AND 5 ORDER BY slot_index", session.char_id)
        fighters = [pet for pet in rows if pet["slot_index"] < 3]
        if requested_pets and any(uid not in {pet["pet_uid"] for pet in rows} for uid in requested_pets):
            return fail
        uids = [pet["pet_uid"] for pet in fighters]
        if request in (277, 460) and all(uid <= 0xffffffff for uid in uids):
            body.u32(rank)
            if request == 460:
                body.u32(1)
            body.u8(len(uids))
            for uid in uids:
                body.u32(uid)
            if request == 277:
                body.u32(1)
        elif request == 517 and attack_rank in roster and fighters:
            # The shipped Arena starts in replay mode and stalls without
            # server-generated combat records. Expose snapshots only in QA.
            if (os.getenv("MONSTER2_LAUNCH_PROFILE") != "test" or
                    not enabled("LOCAL_ARENA_REPLAY_PROBE")):
                return fail
            battle_id = f"local-practice-{uuid4().hex}"
            body.string(battle_id).vector_strings([pet_json(pet) for pet in fighters])
            body.vector_strings(roster[attack_rank][1]).string(battle_id).u32(session.world_id)
            body.vector_strings([pet_json(pet) for pet in rows if pet["slot_index"] >= 3])
            body.vector_strings([]).string("{}").string("{}")
        else:
            return fail
    elif request == 317:
        reader.u32()  # The client sends its cached rank.
        reader.finish()
        body.vector_strings([json.dumps(roster[key][0]) for key in list(roster)[-3:]])
    elif request == 1175:
        start, end = reader.u32(), reader.u32()
        reader.finish()
        if not 0 < start <= end:
            return fail
        body.vector_strings([json.dumps(profile) for slot, (profile, _) in roster.items() if start <= slot <= end])
    elif request == 1235:
        char_id, team = reader.u32(), reader.u32()
        reader.finish()
        pair = next(((profile, pets) for profile, pets in roster.values() if profile["_id"] == char_id), None)
        if team != 1 or pair is None:
            return fail
        body.u32(char_id).u32(team).vector_strings(pair[1]).vector_strings([])
    elif request == 267:
        reader.u32()
        reader.u32()
        reader.finish()
        # Practice runs have no settled history.
        body.u32(0).vector_strings([])
    return ack, body.bytes()
