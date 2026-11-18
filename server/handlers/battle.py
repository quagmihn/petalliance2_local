"""Protocol-confirmed handler for the first guided PVE encounter."""
from __future__ import annotations

import json
import logging

from protocol import Reader, Writer
from pet_config import tutorial_monster
from client_config import table as client_table
from pet_config import untrained_hp
from battle_group_config import (resolve_monster_man_group, resolve_tutorial_group,
                                 resolve_tutorial_wild)

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
        if battle_type == 1:
            resolved = resolve_tutorial_wild(battle_type_id)
            if session.char_id is None:
                return 210, Writer().u16(1).bytes()
            if resolved is None:
                reason = "unconfigured_wild_encounter"
                started = False
            else:
                quest_id, enemy, exp = resolved
                started = await session.db.start_tutorial_wild_battle(
                    session.char_id, session.session_id, battle_type_id, quest_id,
                    int(client_table("MonstrosityInfo")[battle_type_id]["capture"]))
                if started:
                    session.tutorial_battle_exp = exp
            if not started:
                reason = reason or "quest_not_active_or_encounter_already_invalid"
            if reason:
                log.warning("battle_rejected request_id=136 char_id=%s handler=tutorial_wild_battle "
                            "battle_type=%s battle_type_id=%s sub_id=%s rejection_reason=%s "
                            "response_id=210 response_code=1",
                            session.char_id, battle_type, battle_type_id, sub_id, reason)
                return 210, Writer().u16(1).bytes()
            body = (Writer().u16(0).vector_strings([
                json.dumps(enemy, separators=(",", ":"))
            ]).u32(exp).vector_strings([]).bytes())
            return 210, body

        if battle_type == 3:
            if session.char_id is None:
                return 210, Writer().u16(1).bytes()
            adventure_id = await session.db.current_adventure_id(session.char_id)
            adventure = client_table("AdventureInfo").get(adventure_id) if adventure_id else None
            scene = client_table("SceneInfo").get(battle_type_id)
            if (adventure is None or scene is None or scene["number"] not in adventure["scene"]
                    or scene["eventType"] != 8 or sub_id != 0):
                log.warning("battle_rejected request_id=136 char_id=%s handler=adventure_trainer_battle "
                            "adventure_id=%s scene_id=%s sub_id=%s rejection_reason=unconfigured_trainer_scene",
                            session.char_id, adventure_id, battle_type_id, sub_id)
                return 210, Writer().u16(1).bytes()
            group_id = int(scene["event"])
            group = client_table("MonsterGroupManInfo").get(group_id)
            if group is None or not group["pokemons"]:
                return 210, Writer().u16(1).bytes()
            started = await session.db.start_adventure_battle(
                session.char_id, session.session_id, adventure_id, battle_type_id, group_id)
            if not started:
                return 210, Writer().u16(1).bytes()
            session.tutorial_battle_exp = int(group["exp"])
            monstrosities = client_table("MonstrosityInfo")
            monsters = []
            for monster_id in group["pokemons"]:
                info = monstrosities.get(int(monster_id))
                if info is None or not info["level"]:
                    raise ValueError(f"trainer group {group_id} references invalid monster {monster_id}")
                level = int(info["level"][0])
                stage = int(info["petStage"])
                star = int(info["petStar"])
                hp = int(untrained_hp(int(info["petnumber"]), level, stage, star)
                         * int(info["amendmentHP"]) / 1000)
                skill1 = int(info["skill1"][0]) if info["skill1"] else 0
                skill2 = int(info["skill2"][0]) if info["skill2"] else 0
                skill3 = int(info["skill3"][0]) if info["skill3"] else 0
                monsters.append({"mID": int(info["id"]), "level": level,
                                 "skill1": skill1, "skill2": skill2, "skill3": skill3,
                                 "hp": hp, "petStage": stage, "petStar": star, "skin": 0})
            body = (Writer().u16(0).vector_strings([
                json.dumps(monster, separators=(",", ":")) for monster in monsters
            ]).u32(int(group["exp"])).vector_strings([]).bytes())
            return 210, body

        if session.char_id is None:
            reason = "character_not_selected"
        elif battle_type != FIRST_GUIDE_BATTLE["battle_type"]:
            reason = "battle_type_mismatch"
        elif sub_id != 0:
            reason = "sub_id_unsupported"
        else:
            resolved = resolve_tutorial_group(battle_type_id)
            started = False
            if resolved is not None:
                quest_id, enemies, exp = resolved
                started = await session.db.start_tutorial_battle(
                    session.char_id, session.session_id, battle_type_id)
                if started:
                    session.tutorial_battle_exp = exp
            if not started:
                # World-map node battles are allowed only when a currently
                # active event-18 quest resolves this exact configured trainer
                # through target map_event.txt (type 0) data.
                group = resolve_monster_man_group(battle_type_id)
                if group is not None:
                    world_enemies, world_exp = group
                    started = await session.db.start_world_map_quest_battle(
                        session.char_id, session.session_id, battle_type_id)
                    if started:
                        enemies, exp = world_enemies, world_exp
                        session.tutorial_battle_exp = exp
            if not started:
                reason = "group_not_authorized_by_active_quest"
            if not started:
                reason = reason or "quest_not_active_or_encounter_already_invalid"
        if reason:
            log.warning("battle_rejected request_id=136 char_id=%s handler=create_pve_battle "
                        "battle_type=%s battle_type_id=%s sub_id=%s rejection_reason=%s response_id=210 response_code=1",
                        session.char_id, battle_type, battle_type_id, sub_id, reason)
            return 210, Writer().u16(1).bytes()
        body = (Writer().u16(0).vector_strings([
            json.dumps(monster, separators=(",", ":")) for monster in enemies
        ]).u32(exp).vector_strings([]).bytes())
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
        battle_exp = int(getattr(session, "tutorial_battle_exp", 0))
        if won and not battle_exp:
            battle_exp = await session.db.last_tutorial_battle_exp(session.char_id)
        return 186, Writer().u16(0).u32(battle_exp if won else 0).bytes()

    return None


async def capture_pokemon(session, payload: bytes):
    """Resolve the client's configured type-1 wild capture attempt."""
    r = Reader(payload)
    monster_id, ball_item_id = r.u32(), r.u32()
    r.finish()
    error = (198, Writer().u16(303).bytes())
    if session.char_id is None:
        return error
    try:
        result = await session.db.capture_wild_pet(
            session.char_id, session.session_id, monster_id, ball_item_id)
    except (KeyError, TypeError, ValueError, IndexError) as exc:
        log.warning("wild_capture_rejected account_id=%s char_id=%s monster_id=%s ball_item_id=%s reason=%s",
                    getattr(session, "account_id", None), session.char_id,
                    monster_id, ball_item_id, exc)
        return error
    if result is None:
        return error
    inventory = await session.db.pool.fetchval(
        "SELECT count FROM inventory WHERE char_id=$1 AND item_id=$2",
        session.char_id, ball_item_id)
    notifications = [(112, Writer().vector_strings([
        json.dumps({"itemID": ball_item_id, "num": int(inventory or 0)},
                   separators=(",", ":"))]).bytes())]
    if result["caught"] and not result["duplicate"]:
        notifications.append((3141, Writer().u64(result["pet_uid"]).string(result["pet_json"]).bytes()))
    notifications.append((198, Writer().u16(0).u16(1 if result["caught"] else 0)
                          .string(result["pet_json"]).u32(result["rate_bonus"]).bytes()))
    log.info("wild_capture char_id=%s session_id=%s monster_id=%s ball_item_id=%s caught=%s remaining=%s duplicate=%s",
             session.char_id, session.session_id, monster_id, ball_item_id,
             result["caught"], result["remaining"], result["duplicate"])
    return notifications
