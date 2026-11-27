from __future__ import annotations

import json
import logging
import random
import time
from client_config import table as client_table
from adventure_config import TOOL_USED_OFFSET, adventure_tools, obstruction_skills, scene_cells

from protocol import Reader, Writer
from quest_config import load_quests

_QUEST_CONFIG = None
log = logging.getLogger("game_socket.quest")


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
    324: (320, lambda: Writer().i32(0).string("").i32(0).u8(0).bytes()),        # bulletin list
    18: (17, lambda: Writer().u16(0).bytes()),                                   # tower recovery
    55: (54, lambda: Writer().u16(0).u32(0).bytes()),                            # pet wiki
    96: (97, lambda: Writer().u16(0).u8(0).bytes()),                             # wishing trees
    69: (70, lambda: Writer().u16(0).u8(0).bytes()),                             # potentials
    347: (253, lambda: Writer().u16(0).u32(0).bytes()),                          # friends
    2999: (2997, lambda: Writer().u16(0).u32(0).string("").bytes()),             # current adventure
    3104: (3106, lambda: Writer().i32(0).string("").i32(0).u8(0).u32(1).bytes()), # month card
    412: (410, lambda: Writer().u16(0).u64(0).bytes()),                           # world open time
    659: (651, lambda: Writer().u16(0).u8(0).u8(0).u8(0).string("").bytes()),    # science data
    446: (450, lambda: Writer().u16(0).u32(0).u32(0).u32(0).u32(0).u32(0).bytes()), # world boss
    785: (26, lambda: Writer().u16(0).u32(0).bytes()),                            # quest list
}


async def adventure_clear_notifications(session):
    rows = await session.db.adventure_clears(session.char_id, include_sweeps=True)
    entries = [json.dumps({key: value for key, value in row.items() if not key.startswith("qc") or value},
                          separators=(",", ":")) for row in rows]
    return [(1749, Writer().vector_strings(entries[start:start + 32]).bytes())
            for start in range(0, len(entries), 32)]


async def quick_clear_adventure(session, payload):
    from adventure_sweep import sweep
    from handlers.inventory import award_strings, reward_packets
    from reward_config import RewardConfigError

    reader = Reader(payload)
    adventure_id, clear_type, count = reader.u32(), reader.u32(), reader.u32()
    operation = reader.string(limit=40) if reader.pos < len(payload) else None
    reader.finish()
    error = (1741, Writer().u16(1).bytes())
    if session.char_id is None or clear_type != 0:
        return error
    try:
        result = await sweep(session.db, session.char_id, adventure_id, count, operation)
    except RewardConfigError as exc:
        log.warning("sweep_rejected adventure_id=%s reason=%s", adventure_id, exc)
        return error
    if result is None:
        return error
    state = result["state"]
    notices = reward_packets(state) if state else []
    notices.append((1749, Writer().vector_strings([json.dumps(result["clear"], separators=(",", ":"))]).bytes()))
    notices.append((1741, Writer().u16(0).vector_strings(award_strings(result["awards"])).bytes()))
    log.info("sweep char_id=%s adventure_id=%s requested_count=%s replay=%s daily_total=%s",
             session.char_id, adventure_id, count, state is None, result["clear"]["qcTimes"])
    return notices


async def get_finished_adventures(session, payload: bytes):
    Reader(payload).finish()
    if session.char_id is None:
        return 3081, Writer().u16(1).u32(0).bytes()
    notifications = await adventure_clear_notifications(session)
    count = sum(body[0] for _, body in notifications)
    return [(3081, Writer().u16(0).u32(count).bytes()), *notifications]


async def create_adventure(session, payload: bytes):
    r = Reader(payload)
    adventure_id = r.u32()
    r.finish()
    cells = scene_cells(adventure_id)
    if not cells:
        return 3080, Writer().u16(1).bytes()
    if session.char_id is not None:
        await session.db.start_adventure(session.char_id, adventure_id, resume=True)
    fired = await session.db.fired_adventure_event_ids(session.char_id, adventure_id) if session.char_id else set()
    disposable = client_table("DisposableInfo") if fired else {}
    events = []
    for scene in cells:
        event_id, event_type = scene["event"], scene["eventType"]
        if (event_type == 3 and -scene["id"] in fired
                or event_type == 1 and -(TOOL_USED_OFFSET + scene["id"]) in fired):
            event_id, event_type = 0, 0
        elif event_type == 21 and event_id in fired and event_id in disposable:
            finished = disposable[event_id]
            event_id, event_type = finished["finishEvent"], finished["finishEventType"]
        events.append({
            "sceneID": scene["id"], "flo": scene["floor"],
            "eventID": event_id, "x": scene["eventX"],
            "y": scene["eventY"], "type": event_type,
        })
    state = json.dumps({"advID": adventure_id, "events": events, "npcShop": []},
                       ensure_ascii=False, separators=(",", ":"))
    session.current_adventure_id = adventure_id
    return 3080, Writer().u16(0).u32(adventure_id).string(state).bytes()


async def get_adventure_award(session, payload: bytes):
    r = Reader(payload)
    floor, col, row = r.u32(), r.u32(), r.u32()
    r.finish()
    adventure_id = getattr(session, "current_adventure_id", None)
    if adventure_id is None and session.char_id is not None:
        adventure_id = await session.db.current_adventure_id(session.char_id)
    if session.char_id is None or adventure_id is None:
        return 3079, Writer().u16(1).bytes()
    scene = next((entry for entry in scene_cells(adventure_id)
                  if entry["floor"] == floor
                  # Client convertToCoord returns (row, col), then serializes
                  # field=col,row=row; SceneInfo stores eventX as row, eventY as col.
                  and entry["eventX"] == row and entry["eventY"] == col), None)
    if scene and scene["eventType"] == 1 and scene["event"] in adventure_tools():
        accepted = await session.db.adventure_tool(session.char_id, adventure_id, scene["id"])
        return 3079, (Writer().u16(0).vector_strings([]).bytes() if accepted
                      else Writer().u16(1).bytes())
    # Pickup rewards are configured by SceneInfo.award -> RewardInfo -> AwardElementInfo.
    if scene is None or scene["eventType"] != 1 or scene["award"] <= 0:
        return 3079, Writer().u16(1).bytes()
    reward_config = client_table("RewardInfo").get(scene["award"])
    elements = client_table("AwardElementInfo")
    if reward_config is None:
        return 3079, Writer().u16(1).bytes()
    element_ids = reward_config["element"]
    counts = reward_config["nReward"]
    chances = reward_config["probability"]
    if not (len(element_ids) == len(counts) == len(chances)):
        raise ValueError(f"malformed reward vectors for reward {scene['award']}")
    # RewardInfo probabilities are cumulative alternatives; choose from the configured
    # distribution, then grant it transactionally with a unique cell claim.
    total = sum(int(value) for value in chances)
    if total <= 0:
        raise ValueError(f"reward {scene['award']} has no positive probability")
    roll = random.randrange(total)
    selected = len(chances) - 1
    cumulative = 0
    for index, chance in enumerate(chances):
        cumulative += int(chance)
        if roll < cumulative:
            selected = index
            break
    element = elements.get(int(element_ids[selected]))
    if element is None:
        raise ValueError(f"unknown award element {element_ids[selected]}")
    kinds = {1: "g_cash", 2: "m_cash", 3: "item", 4: "exp"}
    kind = kinds.get(int(element["elementType"]))
    if kind is None:
        raise ValueError(f"unsupported configured award type {element['elementType']}")
    reward = {"kind": kind, "id": int(element["elementID"]),
              "num": int(counts[selected])}
    result = await session.db.claim_adventure_cell(
        session.char_id, adventure_id, floor, col, row, [reward])
    if result is None:
        return 3079, Writer().u16(1).bytes()
    awards = []
    for encoded in result:
        value = json.loads(encoded) if isinstance(encoded, str) else encoded
        awards.append(json.dumps({"elementType": value["kind"],
                                  "elementID": value["id"], "num": value["num"]},
                                 separators=(",", ":")))
    return 3079, Writer().u16(0).vector_strings(awards).bytes()


async def fire_adventure_events(session, payload: bytes):
    """Acknowledge only event IDs belonging to the active configured map."""
    r = Reader(payload)
    adventure_id = r.u32()
    count = r.u8()  # Proto.writeVector serializes its size as a BYTE.
    if count > 64:
        raise ValueError("adventure event vector too large")
    event_ids = [r.u32() for _ in range(count)]
    r.finish()
    if session.char_id is None or adventure_id <= 0 or not event_ids:
        return 5, Writer().u16(1).bytes()
    known_events = {
        int(scene["event"]) for scene in scene_cells(adventure_id) if int(scene["event"]) != 0
    }
    if any(event_id not in known_events for event_id in event_ids):
        return 5, Writer().u16(1).bytes()
    if not await session.db.record_adventure_events(session.char_id, adventure_id,
                                                     sorted(set(event_ids))):
        return 5, Writer().u16(1).bytes()
    return 5, Writer().u16(0).bytes()


async def adventure_use_skill(session, payload: bytes):
    r = Reader(payload)
    source_id, scene_id = r.u32(), r.u32()
    error = 746, Writer().u16(1).bytes()
    # The local APK includes the active Adventure and interaction kind.
    if session.char_id is None or len(payload) - r.pos != 8:
        return error
    adventure_id, kind = r.u32(), r.u32()
    cells = {cell["id"]: cell for cell in scene_cells(adventure_id)}
    target = cells.get(scene_id)
    if not target or target["eventType"] != 3:
        return error
    accepted = False
    if kind == 2 and source_id == 0:
        families = obstruction_skills().get(target["event"], ())
        accepted = bool(families and await session.db.clear_skill_obstacle(
            session.char_id, adventure_id, scene_id, families))
    elif kind == 1:
        source = cells.get(source_id)
        if (source and source["eventType"] == 1
                and adventure_tools().get(source["event"]) == (3, target["event"])):
            accepted = await session.db.adventure_tool(session.char_id, adventure_id, source_id, scene_id)
    log.info("adventure_interaction char_id=%s adventure_id=%s scene_id=%s kind=%s accepted=%s",
             session.char_id, adventure_id, scene_id, kind, accepted)
    return 746, Writer().u16(0 if accepted else 1).bytes()


async def finish_adventure(session, payload: bytes):
    """Persist failure exits or grant configured rewards for a cleared adventure."""
    r = Reader(payload)
    star = r.u16()
    r.finish()
    if session.char_id is None:
        return 2995, Writer().u16(1).bytes()
    adventure_id = getattr(session, "current_adventure_id", None)
    if adventure_id is None:
        adventure_id = await session.db.current_adventure_id(session.char_id)
    if adventure_id is None:
        adventure_id = await session.db.latest_adventure_id(session.char_id)
    adventure = client_table("AdventureInfo").get(adventure_id) if adventure_id else None
    if adventure is None:
        return 2995, Writer().u16(1).bytes()
    rewards = []
    if star:
        # SearchingFuncMgr sets bit 8 only after the dungeon clear event.
        if not 8 <= star <= 15:
            return 2995, Writer().u16(1).bytes()
        exp = int(adventure.get("Exp_rewards", 0))
        if exp > 0:
            rewards.append({"kind": "exp", "id": 0, "num": exp})
        reward_id = int(adventure.get("rewards", 0))
        from reward_config import RewardConfigError, drop_plan, roll_drop
        try:
            rewards.extend(roll_drop(drop_plan(reward_id), 1))
        except RewardConfigError as exc:
            log.warning("adventure_clear_reward_rejected id=%s reason=%s", adventure_id, exc)
            return 2995, Writer().u16(1).bytes()
    completed = await session.db.finish_adventure(session.char_id, adventure_id, star, rewards)
    if completed is None:
        return 2995, Writer().u16(1).bytes()
    encoded, quest_updates = completed
    awards = []
    for value in encoded:
        reward = json.loads(value) if isinstance(value, str) else value
        awards.append(json.dumps({"elementType": reward["kind"],
                                  "elementID": reward["id"], "num": reward["num"]},
                                 separators=(",", ":")))
    ack = 2995, Writer().u16(0).vector_strings(awards).bytes()
    return [ack, *quest_notifications(quest_updates)] if quest_updates else ack


def quest_notifications(entries):
    now = int(time.time())
    for start in range(0, len(entries) or 1, 255):
        batch = entries[start:start + 255]
        ntf = Writer().u8(len(batch))
        for quest_id, status, progress in batch:
            ntf.u32(quest_id).u8(status).u64(now).u8(len(progress))
            for value in progress:
                ntf.u32(int(value))
        yield 404, ntf.bytes()


async def get_quests(session, payload: bytes):
    from handlers.progression import daily_rows, values_for

    rows = []
    if session.char_id is not None:
        await session.db.repair_completed_quest_unlocks(session.char_id, _quests())
        await session.db.ensure_first_quest_for_level_one(session.char_id)
        rows = await session.db.pool.fetch(
            "SELECT quest_id,status,progress FROM quests WHERE char_id=$1 ORDER BY quest_id",
            session.char_id,
        )
    entries = []
    for row in rows:
        progress = row["progress"]
        if isinstance(progress, str): progress = json.loads(progress)
        if isinstance(progress, dict): progress = progress.get("progressList", [])
        if not isinstance(progress, list): progress = []
        entries.append((row["quest_id"], row["status"], progress))
    if session.char_id is not None and hasattr(session, "daily_entries") and hasattr(session.db, "character_values"):
        session.daily_entries = daily_rows(await values_for(session), time.time())
        daily_ids = {entry[0] for entry in session.daily_entries}
        entries = [entry for entry in entries if entry[0] not in daily_ids] + session.daily_entries
    ack = Writer().u16(0).u32(len(entries)).bytes()
    return [(26, ack), *quest_notifications(entries)]


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
    from handlers.progression import daily_claim, daily_missions
    if quest_id in daily_missions():
        return await daily_claim(session, quest_id)
    config = _quests()
    quest = config.get(quest_id)
    ok, children, awards, pet_payloads = False, [], [], []
    if session.char_id is not None and quest is not None:
        from reward_config import RewardConfigError, resolve_reward
        try:
            configured_reward = resolve_reward(quest.award_id)
        except RewardConfigError as exc:
            log.warning("quest_reward_config_rejected char_id=%s quest_id=%s award_id=%s reason=%s",
                        session.char_id, quest_id, quest.award_id, exc)
            return 726, Writer().u16(1).bytes()
        ok, children, awards, pet_payloads = await session.db.commit_configured_tutorial_quest(
            session.char_id, quest, config, configured_reward)
    if not ok:
        return 726, Writer().u16(1).bytes()
    wire_awards = [json.dumps({"elementType": row["kind"], "elementID": row["id"],
                               "num": row["num"]}, separators=(",", ":"))
                   for row in awards]
    responses = []
    for pet_payload in pet_payloads:
        pet = json.loads(pet_payload)
        responses.append((3141, Writer().u64(pet["objID"]).string(pet_payload).bytes()))
    item_ids = sorted({int(row["id"]) for row in awards if row["kind"] == "item"})
    if item_ids:
        from handlers.inventory import item_counts_update

        counts = await session.db.pool.fetch(
            "SELECT item_id,count FROM inventory WHERE char_id=$1 AND item_id=ANY($2::int[])",
            session.char_id, item_ids)
        responses.append(item_counts_update((row["item_id"], row["count"]) for row in counts))
    if any(row["kind"] in ("g_cash", "m_cash") for row in awards):
        from handlers.economy import wallet_update
        wallet = await session.db.pool.fetchrow(
            "SELECT gold,diamond,stamina,vip_level,vip_points,currencies_json FROM characters WHERE char_id=$1",
            session.char_id)
        responses.append(wallet_update(wallet))
    ack = Writer().u16(0).u32(quest_id).vector_strings(wire_awards).bytes()
    responses.append((726, ack))
    if children:
        responses.extend(quest_notifications([
            (child_id, 0, [0] * len(config[child_id].objectives)) for child_id in children
        ]))
    return responses


async def startup_empty_ack(session, msg_id: int, payload: bytes):
    entry = EMPTY_STARTUP_ACKS.get(msg_id)
    if entry is None:
        return None
    ack_id, make_body = entry
    return ack_id, make_body()
