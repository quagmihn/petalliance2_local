"""Protocol-confirmed handler for the first guided PVE encounter."""
from __future__ import annotations

import json
import logging

from protocol import Reader, Writer
from pet_config import tutorial_monster

log = logging.getLogger("game_socket")

FIRST_GUIDE_BATTLE = {
    "battle_type": 5,       # Proto.BTT_MONSTER_MAN_GROUP
    # For BTT_MONSTER_MAN_GROUP, BattleMapMgr replaces the initial value 1
    # with the configured GroupID before serializing the request.
    "battle_type_id": 99998,
    "group_id": 99998,      # GameGuideMgr.firstBattle()
    "monster_id": 999996,  # MonsterGroupManInfo.dat group 99998
    "level": 1,
    "skill1": 371,
    "skill2": 0,
    "skill3": 0,
    "hp": tutorial_monster()["hp"],  # amendmentHP is per-mille, not absolute HP
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
        reason = None
        if session.char_id is None:
            reason = "character_not_selected"
        elif battle_type != FIRST_GUIDE_BATTLE["battle_type"]:
            reason = "battle_type_mismatch"
        elif battle_type_id != FIRST_GUIDE_BATTLE["battle_type_id"]:
            reason = "group_id_mismatch"
        elif sub_id != 0:
            reason = "sub_id_unsupported"
        else:
            started = await session.db.start_tutorial_battle(
                session.char_id, session.session_id, FIRST_GUIDE_BATTLE["group_id"])
            if not started:
                reason = "quest_not_active_or_encounter_already_invalid"
        if reason:
            log.warning("battle_rejected request_id=136 char_id=%s handler=create_pve_battle "
                        "battle_type=%s battle_type_id=%s sub_id=%s rejection_reason=%s response_id=210 response_code=1",
                        session.char_id, battle_type, battle_type_id, sub_id, reason)
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
            reason = "invalid_result_or_empty_trace" if not valid_result or not details else "no_active_encounter"
            log.warning("battle_rejected request_id=263 char_id=%s handler=pve_battle_end "
                        "result=%s details_count=%d rejection_reason=%s response_id=186 response_code=1",
                        session.char_id, result, len(details), reason)
            return 186, Writer().u16(1).bytes()
        return 186, Writer().u16(0).u32(
            FIRST_GUIDE_BATTLE["exp"] if won else 0).bytes()

    return None
