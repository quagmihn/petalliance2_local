from __future__ import annotations

import json

from protocol import Reader, Writer


def pet_json(row) -> str:
    return json.dumps({
        "objID": row["pet_uid"], "pokeID": row["pet_template_id"],
        "level": row["level"], "exp": row["exp"], "skin": 0,
        "atk": 1, "def": 1, "satk": 1, "sdef": 1, "speed": 1,
        "hp": 100, "hpmax": 100, "fc": 1, "sciencefc": 0,
        "sciencehpmax": 0, "star": row["star"], "evolution": row["evolution"],
        "updateTime": "", "skills": row["skills_json"], "equips": row["equips_json"],
    }, separators=(",", ":"))


async def query_pets(session, payload: bytes):
    r = Reader(payload)
    _requested_char_id, start, _end = r.u64(), r.u32(), r.u32()
    if session.char_id is None: raise ValueError("pet query before character login")
    rows = await session.db.pool.fetch("SELECT * FROM pets WHERE char_id=$1 ORDER BY slot_index,pet_uid", session.char_id)
    active = [row for row in rows if row["slot_index"] >= 0]
    inactive = [row for row in rows if row["slot_index"] < 0]
    w = Writer().u16(0).u64(session.char_id).u32(start).u32(start + len(active) + len(inactive))
    w.vector_strings([pet_json(row) for row in active])
    w.vector_strings([pet_json(row) for row in inactive])
    w.u32(len(inactive)).vector_strings([])
    return 3139, w.bytes()


async def get_army(session, payload: bytes):
    if session.char_id is None: raise ValueError("pet army query before character login")
    rows = await session.db.pool.fetch(
        "SELECT pet_uid,slot_index FROM pets WHERE char_id=$1 AND slot_index>=0 ORDER BY slot_index",
        session.char_id,
    )
    # Client consumes this as JSON keyed by formation index.
    army: dict[str, list[int]] = {}
    for row in rows: army.setdefault(str(row["slot_index"] + 1), []).append(row["pet_uid"])
    return 1774, Writer().u16(0).string(json.dumps(army, separators=(",", ":"))).bytes()


async def get_capsule_egg_cds(session, payload: bytes):
    # Proto.parseP_GC_CapsuleEggCDs_Ack reads a byte-count vector of
    # { times: WORD, timeLast: QWORD }. PetProcess indexes entries 1 and 2.
    body = Writer().u16(0).u8(2)
    for _ in range(2):
        body.u16(0).u64(0)
    return 1526, body.bytes()
