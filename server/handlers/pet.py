from __future__ import annotations

import json
import logging
import os
import re

from protocol import Reader, Writer
from pet_config import json_value, untrained_hp, validate_pet
from local_play import enabled

log = logging.getLogger("game_socket")
PET_PAGE_SIZE = 24
# Keep frames conservative for legacy clients during initial scene loading.
PET_FRAME_LIMIT = 16 * 1024


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
        from pet_development import ATTRIBUTES, OVERFLOW, max_points, state, stats
        saved = state(row)
        data["skin"] = saved.get("skin", 0)
        data["maxStreng"] = max_points(row["pet_template_id"])
        if saved:
            for key in (*ATTRIBUTES, *OVERFLOW):
                data[key] = saved.get(key, 0)
            if saved.get("yoke"):
                data["yoke"] = saved["yoke"]
            data["hp"], data["fc"] = stats(row, saved)
            data["hpmax"] = data["hp"]
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
    _requested_char_id, start, requested_end = r.u64(), r.u32(), r.u32()
    r.finish()
    if session.char_id is None: raise ValueError("pet query before character login")
    rows = await session.db.pool.fetch("SELECT * FROM pets WHERE char_id=$1 ORDER BY slot_index,pet_uid", session.char_id)
    active = [row for row in rows if 0 <= row["slot_index"] < 3]
    helpers = [row for row in rows if 3 <= row["slot_index"] < 6]
    inactive = [row for row in rows if row["slot_index"] < 0 or row["slot_index"] >= 6]
    # The client cursor counts reserve Pets alone. Return the current active
    # and support groups on every page because its cache replaces those arrays.
    paged = enabled("LOCAL_UNLIMITED_PET_STORAGE") or len(inactive) > PET_PAGE_SIZE
    if paged:
        if start > len(inactive):
            return 3139, Writer().u16(1).bytes()
        limit = min(PET_PAGE_SIZE, requested_end - start) if requested_end > start else PET_PAGE_SIZE
        page = inactive[start:start + limit]
    else:
        page = inactive
    serialized = {}
    invalid = []
    for row in (*active, *page, *helpers):
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
    active_json = [serialized[row["pet_uid"]] for row in active]
    helper_json = [serialized[row["pet_uid"]] for row in helpers]
    budget = PET_FRAME_LIMIT - 29 - sum(len(value.encode()) + 1 for value in (*active_json, *helper_json))
    if budget < 0 or len(active_json) > 255 or len(helper_json) > 255:
        return 3139, Writer().u16(1).bytes()
    page_json = []
    for row in page:
        value = serialized[row["pet_uid"]]
        size = len(value.encode()) + 1
        if size > budget:
            break
        page_json.append(value)
        budget -= size
    if page and not page_json:
        return 3139, Writer().u16(1).bytes()
    end = start + (len(page_json) if paged or len(page_json) != len(page) else len(rows))
    w = Writer().u16(0).u64(session.char_id).u32(start).u32(end)
    w.vector_strings(active_json)
    w.vector_strings(page_json)
    w.u32(len(inactive)).vector_strings(helper_json)
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


async def get_capsule_egg_info(session, payload: bytes):
    Reader(payload).finish()
    # The legacy client asks for wish/dream state after a successful Supreme
    # draw. These modes are unavailable with local pools, but its blocking
    # callback must receive the protocol's WORD error response.
    return 1396, Writer().u16(1).bytes()


async def get_capsule_egg_cds(session, payload: bytes):
    from local_draw import cooldowns

    Reader(payload).finish()
    # Proto.parseP_GC_CapsuleEggCDs_Ack reads a byte-count vector of
    # { times: WORD, timeLast: QWORD }. PetProcess indexes entries 1 and 2.
    body = Writer().u16(0).u8(2)
    history = {}
    if (session is not None and session.char_id is not None
            and (os.getenv("MONSTER2_DRAW_CATALOG") or
                 (os.getenv("GAME_ENV") == "test" and os.getenv("MONSTER2_TEST_DRAW_CATALOG")))):
        history = await cooldowns(session.db, session.char_id)
    for machine_id in (1, 2):
        times, last = history.get(machine_id, (0, 0))
        body.u16(times).u64(last)
    return 1526, body.bytes()


async def advance_stage(session, payload: bytes):
    """Advance Pet training Stage using the client's configured costs."""
    r = Reader(payload)
    pet_uid = r.u32()
    r.finish()
    if session.char_id is None:
        return 1032, Writer().u16(1).bytes()
    try:
        result = await session.db.advance_pet_training_stage(session.char_id, pet_uid)
    except (ValueError, KeyError, TypeError, IndexError) as exc:
        log.warning("pet_stage_rejected account_id=%s char_id=%s pet_uid=%s reason=%s",
                    getattr(session, "account_id", None), session.char_id, pet_uid, str(exc))
        return 1032, Writer().u16(1).bytes()
    if result is None:
        return 1032, Writer().u16(1).bytes()
    from handlers.economy import wallet_update
    from handlers.inventory import item_counts_update

    stage, wallet, item_counts = result
    responses = []
    if item_counts:
        responses.append(item_counts_update(item_counts))
    if wallet is not None:
        responses.append(wallet_update(wallet))
    responses.append((1032, Writer().u16(0).u32(pet_uid).u16(stage).bytes()))
    return responses
