"""Protocol-confirmed handler for the first guided PVE encounter."""
from __future__ import annotations

import json
import logging
import re

from protocol import Reader, Writer
from adventure_config import scene_encounter
from pet_config import tutorial_monster
from client_config import table as client_table
from battle_group_config import (resolve_monster_man_group, resolve_tutorial_group,
                                 resolve_tutorial_wild, resolve_wild, resolve_world_map_wild)

log = logging.getLogger("game_socket")
FIGHTER = re.compile(r"([1-9][0-9]{0,18}),([0-9]{1,15}(?:\.[0-9]{1,12})?)")


def winning_fighters(details):
    """Parse the client combat engine's fighting Pet UID/HP pairs."""
    if not 1 <= len(details) <= 3:
        return None
    fighters = {}
    for detail in details:
        match = FIGHTER.fullmatch(detail)
        if match is None:
            return None
        uid, hp = int(match[1]), float(match[2])
        if uid in fighters or uid > (1 << 63) - 1:
            return None
        fighters[uid] = hp
    return set(fighters) if any(fighters.values()) else None

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
            supply = None
            if session.char_id is None:
                return 210, Writer().u16(1).bytes()
            if resolved is not None:
                quest_id, enemy, exp = resolved
                attempts = int(client_table("MonstrosityInfo")[battle_type_id]["capture"])
                started = await session.db.start_tutorial_wild_battle(
                    session.char_id, session.session_id, battle_type_id, quest_id, attempts)
                if started:
                    supply = await session.db.supply_tutorial_capture_balls(session.char_id, quest_id, attempts)
            else:
                world_wild = resolve_world_map_wild(battle_type_id)
                attempts = (int(client_table("MonstrosityInfo")[battle_type_id]["capture"])
                            if world_wild and world_wild[0].get("canCatch") else 0)
                started = bool(sub_id == 0 and world_wild and await session.db.start_world_map_quest_wild(
                    session.char_id, session.session_id, battle_type_id, attempts))
                if started and world_wild:
                    enemy, exp = world_wild
                    resolved = (None, enemy, exp)
                elif world_wild is None:
                    reason = "unconfigured_wild_encounter"
            if not started:
                reason = reason or "quest_not_active_or_encounter_already_invalid"
            if reason:
                log.warning("battle_rejected request_id=136 char_id=%s handler=wild_battle "
                            "battle_type=%s battle_type_id=%s sub_id=%s rejection_reason=%s "
                            "response_id=210 response_code=1",
                            session.char_id, battle_type, battle_type_id, sub_id, reason)
                return 210, Writer().u16(1).bytes()
            body = (Writer().u16(0).vector_strings([
                json.dumps(enemy, separators=(",", ":"))
            ]).u32(exp).vector_strings([]).bytes())
            if supply is not None:
                from handlers.inventory import item_counts_update

                return [item_counts_update([supply]), (210, body)]
            return 210, body

        if battle_type in (2, 3):
            if session.char_id is None:
                return 210, Writer().u16(1).bytes()
            adventure_id = await session.db.current_adventure_id(session.char_id)
            encounter = scene_encounter(adventure_id, battle_type_id, 2 if battle_type == 2 else 8)
            if sub_id != 0 or encounter is None:
                log.warning("battle_rejected request_id=136 char_id=%s handler=adventure_battle "
                            "adventure_id=%s scene_id=%s type=%s sub_id=%s "
                            "rejection_reason=unconfigured_encounter_scene response_id=210 response_code=1",
                            session.char_id, adventure_id, battle_type_id, battle_type, sub_id)
                return 210, Writer().u16(1).bytes()
            group_id, disposable_id = encounter
            resolved = resolve_wild(group_id) if battle_type == 2 else resolve_monster_man_group(group_id)
            if resolved is None:
                return 210, Writer().u16(1).bytes()
            enemies, exp = resolved
            options = {}
            if battle_type == 2:
                attempts = int(client_table("MonstrosityInfo")[group_id]["capture"]) if enemies.get("canCatch") else 0
                enemies = [enemies]
                options = {"battle_type": battle_type, "attempts": attempts}
            if disposable_id is not None:
                options["disposable_id"] = disposable_id
            started = await session.db.start_adventure_battle(
                session.char_id, session.session_id, adventure_id, battle_type_id, group_id, **options)
            if not started:
                log.warning("battle_rejected request_id=136 char_id=%s handler=adventure_battle "
                            "adventure_id=%s scene_id=%s rejection_reason=inactive_or_defeated "
                            "response_id=210 response_code=1",
                            session.char_id, adventure_id, battle_type_id)
                return 210, Writer().u16(1).bytes()
            body = (Writer().u16(0).vector_strings([
                json.dumps(monster, separators=(",", ":")) for monster in enemies
            ]).u32(exp).vector_strings([]).bytes())
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
            if not started:
                # World-map node battles are allowed only when a currently
                # active event-18 quest resolves this exact configured trainer
                # through target map_event.txt (type 0) data.
                group = resolve_monster_man_group(battle_type_id)
                if group is not None and sub_id == 0:
                    world_enemies, world_exp = group
                    started = await session.db.start_world_map_quest_battle(
                        session.char_id, session.session_id, battle_type_id)
                    if started:
                        enemies, exp = world_enemies, world_exp
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
        # Combat runs in the client. Its wire result can be checked against
        # the issued encounter and fighting UIDs, without replaying combat.
        won = result == 1
        fighters = winning_fighters(details) if won else None
        valid_result = result in (0, 1, 2) and (not won or fighters is not None)
        accepted = None
        if valid_result and session.char_id is not None:
            try:
                accepted = await session.db.finish_tutorial_battle(
                    session.char_id, session.session_id, won, fighters)
            except (KeyError, ValueError) as exc:
                log.warning("battle_result_rolled_back char_id=%s session_id=%s detail=%s",
                            session.char_id, session.session_id, exc)
        if accepted is None:
            reason = "unmatched_encounter_or_fighters" if valid_result else "invalid_result_or_trace"
            log.warning("battle_rejected request_id=263 char_id=%s handler=pve_battle_end "
                        "result=%s details_count=%d rejection_reason=%s response_id=186 response_code=1",
                        session.char_id, result, len(details), reason)
            return 186, Writer().u16(1).bytes()
        battle_exp, pets = accepted
        ack = (186, Writer().u16(0).u32(battle_exp).bytes())
        if not pets:
            return ack
        log.info("battle_pet_exp char_id=%s session_id=%s configured_exp=%s pet_uids=%s",
                 session.char_id, session.session_id, battle_exp, [uid for uid, _ in pets])
        return [(3141, Writer().u64(uid).string(payload).bytes()) for uid, payload in pets] + [ack]

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
    # Lua keeps the capture UI open for result 2 while attempts remain.
    capture_state = 1 if result["caught"] else (2 if result["remaining"] else 0)
    notifications.append((198, Writer().u16(0).u16(capture_state)
                          .string(result["pet_json"]).u32(result["rate_bonus"]).bytes()))
    log.info("wild_capture char_id=%s session_id=%s monster_id=%s ball_item_id=%s caught=%s remaining=%s duplicate=%s",
             session.char_id, session.session_id, monster_id, ball_item_id,
             result["caught"], result["remaining"], result["duplicate"])
    return notifications
