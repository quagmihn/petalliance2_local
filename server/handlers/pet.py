from __future__ import annotations

import json
import logging
import re

from protocol import Reader, Writer
from pet_config import json_value, untrained_hp, validate_pet

log = logging.getLogger("game_socket")


class PetDataError(ValueError):
    def __init__(self, pet_uid, field, detail):
        self.pet_uid = pet_uid
        self.field = field
        self.detail = detail
        super().__init__(f"pet_uid={pet_uid} field={field}: {detail}")


def pet_json(row) -> str:
    uid = row["pet_uid"]
    field = "Stage"
    try:
        stage = row["training_stage"]
        field = "template_id"
        hp = untrained_hp(row["pet_template_id"], row["level"], stage, row["star"])
        data = {
            "objID": uid, "pokeID": row["pet_template_id"],
            "level": row["level"], "exp": row["exp"], "skin": 0,
            "atk": 0, "def": 0, "satk": 0, "sdef": 0, "speed": 0, "hpx": 0,
            "Stage": stage,
            "hp": hp, "hpmax": hp, "fc": 0, "sciencefc": 0,
            "sciencehpmax": 0, "star": row["star"], "evolution": row["evolution"],
            "updateTime": "", "skills": json_value(row["skills_json"]),
            "paSkills": json_value(row["passive_skills_json"]),
            "equips": json_value(row["equips_json"]),
        }
        field = "skills"
        validate_pet(data)
        return json.dumps(data, separators=(",", ":"))
    except (KeyError, TypeError, ValueError, OverflowError, json.JSONDecodeError) as exc:
        match = re.search(r"invalid pet field ([A-Za-z0-9_]+)", str(exc))
        if match:
            field = match.group(1)
        elif "passive" in str(exc):
            field = "paSkills"
        elif "equipment" in str(exc):
            field = "equips"
        elif "skill" in str(exc):
            field = "skills"
        raise PetDataError(uid, field, str(exc)) from exc


async def query_pets(session, payload: bytes):
    r = Reader(payload)
    _requested_char_id, start, _end = r.u64(), r.u32(), r.u32()
    r.finish()
    if session.char_id is None: raise ValueError("pet query before character login")
    rows = await session.db.pool.fetch("SELECT * FROM pets WHERE char_id=$1 ORDER BY slot_index,pet_uid", session.char_id)
    active = [row for row in rows if 0 <= row["slot_index"] < 3]
    helpers = [row for row in rows if 3 <= row["slot_index"] < 6]
    inactive = [row for row in rows if row["slot_index"] < 0 or row["slot_index"] >= 6]
    serialized = {}
    invalid = []
    for row in rows:
        try:
            serialized[row["pet_uid"]] = pet_json(row)
        except PetDataError as exc:
            invalid.append(exc)
    if invalid:
        for exc in invalid:
            log.error("pet_serialization_rejected account_id=%s char_id=%s pet_uid=%s field=%s detail=%s",
                      getattr(session, "account_id", None), session.char_id,
                      exc.pet_uid, exc.field, exc.detail)
        # QueryPokemons_Ack contains only the WORD error code on nonzero status.
        # Do not send a partial Pet vector or raise through the TCP session loop.
        return 3139, Writer().u16(1).bytes()
    w = Writer().u16(0).u64(session.char_id).u32(start).u32(start + len(rows))
    w.vector_strings([serialized[row["pet_uid"]] for row in active])
    w.vector_strings([serialized[row["pet_uid"]] for row in inactive])
    w.u32(len(inactive)).vector_strings([serialized[row["pet_uid"]] for row in helpers])
    return 3139, w.bytes()


async def update_army(session, payload: bytes):
    r = Reader(payload)
    error = 1756, Writer().u16(1).bytes()
    if r.u8() != 1 or r.u32() != 1 or session.char_id is None:
        return error
    members = [r.u32() for _ in range(r.u8())]
    support = [r.u32() for _ in range(r.u8())]
    r.finish()
    if not 1 <= len(members) <= 3 or len(support) > 3 or (support and len(members) != 3):
        return error
    if len(set(members + support)) != len(members + support):
        return error
    changed = await session.db.update_primary_army(session.char_id, members, support)
    return 1756, Writer().u16(0 if changed else 1).bytes()


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
