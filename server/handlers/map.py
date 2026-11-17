from __future__ import annotations

import json
import time

from protocol import Reader, Writer
from quest_config import load_quests

_QUEST_CONFIG = None


def _quests():
    global _QUEST_CONFIG
    if _QUEST_CONFIG is None:
        _QUEST_CONFIG = load_quests()
    return _QUEST_CONFIG

# request_id -> (ack_id, body factory). These are the serialized empty states
# expected by LoginMsgMgr's initial, strictly sequential request chain.
EMPTY_STARTUP_ACKS = {
    1074: (1109, lambda: Writer().u16(0).vector_strings([]).string("").bytes()), # explore
    1338: (1433, lambda: Writer().u16(0).string("{}").bytes()),                 # map events
    806: (676, lambda: Writer().u16(0).string("").bytes()),                     # signin
    18: (17, lambda: Writer().u16(0).bytes()),                                   # tower recovery
    55: (54, lambda: Writer().u16(0).u32(0).bytes()),                            # pet wiki
    96: (97, lambda: Writer().u16(0).u8(0).bytes()),                             # wishing trees
    63: (62, lambda: Writer().u16(0).u8(0).bytes()),                             # VIP awards
    72: (74, lambda: Writer().u16(0).u8(0).bytes()),                             # pokemon achievements
    69: (70, lambda: Writer().u16(0).u8(0).bytes()),                             # potentials
    154: (152, lambda: Writer().u16(0).string("{}").bytes()),                   # activities
    347: (253, lambda: Writer().u16(0).u32(0).bytes()),                          # friends
    2999: (2997, lambda: Writer().u16(0).u32(0).string("").bytes()),             # current adventure
    3104: (3106, lambda: Writer().i32(0).string("").i32(0).u8(0).u32(1).bytes()), # month card
    412: (410, lambda: Writer().u16(0).u64(0).bytes()),                           # world open time
    659: (651, lambda: Writer().u16(0).u8(0).u8(0).u8(0).string("").bytes()),    # science data
    930: (1077, lambda: Writer().u16(0).u16(0).u16(0).bytes()),                   # unread mail
    446: (450, lambda: Writer().u16(0).u32(0).u32(0).u32(0).u32(0).u32(0).bytes()), # world boss
    785: (26, lambda: Writer().u16(0).u32(0).bytes()),                            # quest list
}


async def get_finished_adventures(session, payload: bytes):
    return 3081, Writer().u16(0).u32(0).bytes()


async def get_quests(session, payload: bytes):
    rows = []
    if session.char_id is not None:
        await session.db.ensure_first_quest_for_level_one(session.char_id)
        rows = await session.db.pool.fetch(
            "SELECT quest_id,status,progress FROM quests WHERE char_id=$1 ORDER BY quest_id",
            session.char_id,
        )
    ack = Writer().u16(0).u32(len(rows)).bytes()
    responses = [(26, ack)]
    for start in range(0, len(rows) or 1, 255):
        batch = rows[start:start + 255]
        ntf = Writer().u8(len(batch))
        for row in batch:
            progress = row["progress"]
            if isinstance(progress, str): progress = json.loads(progress)
            if isinstance(progress, dict): progress = progress.get("progressList", [])
            if not isinstance(progress, list): progress = []
            ntf.u32(row["quest_id"]).u8(row["status"]).u64(int(time.time()))
            ntf.u8(len(progress))
            for value in progress: ntf.u32(int(value))
        responses.append((404, ntf.bytes()))
    return responses


async def get_home(session, payload: bytes):
    r = Reader(payload)
    char_id = r.u32()
    r.finish()
    home = await session.db.home_state(char_id)
    if home is None:
        return 32, Writer().u16(1).bytes()
    encoded = json.dumps(home, ensure_ascii=False, separators=(",", ":"))
    return 32, Writer().u16(0).string(encoded).u32(char_id).bytes()


async def update_quest(session, payload: bytes):
    """Persist configured quest progress only when supported server evidence exists."""
    r = Reader(payload)
    quest_id, _status, _updated_at = r.u32(), r.u8(), r.u64()
    count = r.u8()
    if count > 16:
        raise ValueError("quest progress vector too large")
    progress = [r.u32() for _ in range(count)]
    r.finish()
    config = _quests().get(quest_id)
    amount = config.objectives[0].amount if config and len(config.objectives) == 1 else 0
    ok = (session.char_id is not None and amount > 0
          and await session.db.update_configured_tutorial_progress(
              session.char_id, quest_id, progress, amount))
    return 3132, Writer().u16(0 if ok else 1).bytes()


async def commit_quest(session, payload: bytes):
    r = Reader(payload)
    quest_id = r.u32()
    r.finish()
    config = _quests()
    quest = config.get(quest_id)
    ok, children = False, []
    if session.char_id is not None and quest is not None:
        ok, children = await session.db.commit_configured_tutorial_quest(
            session.char_id, quest, config)
    if not ok:
        return 726, Writer().u16(1).bytes()
    ack = Writer().u16(0).u32(quest_id).vector_strings([]).bytes()
    responses = [(726, ack)]
    if children:
        ntf = Writer().u8(len(children))
        for child_id in children:
            child = config[child_id]
            ntf.u32(child_id).u8(0).u64(int(time.time()))
            ntf.u8(len(child.objectives))
            for _ in child.objectives:
                ntf.u32(0)
        responses.append((404, ntf.bytes()))
    return responses


async def startup_empty_ack(session, msg_id: int, payload: bytes):
    entry = EMPTY_STARTUP_ACKS.get(msg_id)
    if entry is None:
        return None
    ack_id, make_body = entry
    return ack_id, make_body()
