"""Protocol-confirmed handler for the first guided PVE encounter."""
from __future__ import annotations

import json

from protocol import Reader, Writer

FIRST_GUIDE_BATTLE = {
    "battle_type": 5,       # Proto.BTT_MONSTER_MAN_GROUP
    "battle_type_id": 1,
    "group_id": 99998,      # GameGuideMgr.firstBattle()
    "monster_id": 999996,  # MonsterGroupManInfo.dat group 99998
    "level": 1,
    "skill1": 371,
    "skill2": 0,
    "skill3": 0,
    "hp": 1782,             # MonstrosityInfo.dat amendmentHP
    "petStage": 0,
    "petStar": 0,
    "skin": 0,
    "exp": 16,              # configured group exp
}


async def handle(message_id: int, payload: bytes, session):
    if message_id == 136:  # CG_CreatePVEBattle_Req
        r = Reader(payload)
        battle_type, battle_type_id, sub_id = r.u32(), r.u32(), r.u32()
        r.finish()
        valid = (session.char_id is not None
                 and battle_type == FIRST_GUIDE_BATTLE["battle_type"]
                 and battle_type_id == FIRST_GUIDE_BATTLE["battle_type_id"]
                 and sub_id == 0
                 and await session.db.start_tutorial_battle(
                     session.char_id, session.session_id, FIRST_GUIDE_BATTLE["group_id"]))
        if not valid:
            return 210, Writer().u16(1).bytes()
        monster = {key: value for key, value in FIRST_GUIDE_BATTLE.items()
                   if key in {"monster_id", "level", "skill1", "skill2", "skill3", "hp",
                              "petStage", "petStar", "skin"}}
        monster["mID"] = monster.pop("monster_id")
        body = (Writer().u16(0).vector_strings([
            json.dumps(monster, separators=(",", ":"))
        ]).u32(FIRST_GUIDE_BATTLE["exp"]).vector_strings([]).bytes())
        return 210, body

    if message_id == 263:  # CG_PVEBattleEnd_Req
        r = Reader(payload)
        result = r.u16()
        count = r.u8()
        if count > 128:
            raise ValueError("PVE battle detail vector too large")
        details = [r.string() for _ in range(count)]
        r.finish()
        # Combat runs in the client. Require a server-issued encounter bound to
        # this live session and a non-empty combat trace before accepting win.
        valid_result = result in (0, 1, 2)
        won = result == 1 and bool(details)
        accepted = (valid_result and session.char_id is not None
                    and await session.db.finish_tutorial_battle(
                        session.char_id, session.session_id, won))
        if not accepted:
            return 186, Writer().u16(1).bytes()
        return 186, Writer().u16(0).u32(
            FIRST_GUIDE_BATTLE["exp"] if won else 0).bytes()

    return None
