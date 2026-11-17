from __future__ import annotations

import json

from protocol import Reader, Writer
from pet_config import json_value, untrained_hp, validate_pet


def pet_json(row) -> str:
    hp = untrained_hp(row["pet_template_id"], row["level"], row["training_stage"], row["star"])
    data = {
        "objID": row["pet_uid"], "pokeID": row["pet_template_id"],
        "level": row["level"], "exp": row["exp"], "skin": 0,
        "atk": 0, "def": 0, "satk": 0, "sdef": 0, "speed": 0, "hpx": 0,
        "Stage": row["training_stage"],
        "hp": hp, "hpmax": hp, "fc": 0, "sciencefc": 0,
        "sciencehpmax": 0, "star": row["star"], "evolution": row["evolution"],
        "updateTime": "", "skills": json_value(row["skills_json"]),
        "paSkills": json_value(row["passive_skills_json"]),
        "equips": json_value(row["equips_json"]),
    }
    validate_pet(data)
    return json.dumps(data, separators=(",", ":"))


async def query_pets(session, payload: bytes):
    r = Reader(payload)
    _requested_char_id, start, _end = r.u64(), r.u32(), r.u32()
    r.finish()
    if session.char_id is None: raise ValueError("pet query before character login")
    rows = await session.db.pool.fetch("SELECT * FROM pets WHERE char_id=$1 ORDER BY slot_index,pet_uid", session.char_id)
    active = [row for row in rows if 0 <= row["slot_index"] < 3]
    helpers = [row for row in rows if 3 <= row["slot_index"] < 6]
    inactive = [row for row in rows if row["slot_index"] < 0 or row["slot_index"] >= 6]
    w = Writer().u16(0).u64(session.char_id).u32(start).u32(start + len(rows))
    w.vector_strings([pet_json(row) for row in active])
    w.vector_strings([pet_json(row) for row in inactive])
    w.u32(len(inactive)).vector_strings([pet_json(row) for row in helpers])
    return 3139, w.bytes()


async def get_army(session, payload: bytes):
    Reader(payload).finish()
    if session.char_id is None: raise ValueError("pet army query before character login")
    rows = await session.db.pool.fetch(
        "SELECT pet_uid,slot_index FROM pets WHERE char_id=$1 AND slot_index>=0 ORDER BY slot_index",
        session.char_id,
    )
    # Client consumes this as JSON keyed by formation index.
    army = {"1": [row["pet_uid"] for row in rows if row["slot_index"] < 3],
            "1h": [row["pet_uid"] for row in rows if 3 <= row["slot_index"] < 6]}
    return 1774, Writer().u16(0).string(json.dumps(army, separators=(",", ":"))).bytes()


async def get_capsule_egg_cds(session, payload: bytes):
    # Proto.parseP_GC_CapsuleEggCDs_Ack reads a byte-count vector of
    # { times: WORD, timeLast: QWORD }. PetProcess indexes entries 1 and 2.
    body = Writer().u16(0).u8(2)
    for _ in range(2):
        body.u16(0).u64(0)
    return 1526, body.bytes()
