"""Resolve explicitly configured tutorial encounters from shipped battle data."""
from __future__ import annotations

import json
from functools import lru_cache
from pathlib import Path

from client_config import table
from pet_config import acquisition_skill_pools, untrained_hp

_ROOT = Path(__file__).resolve().parent


@lru_cache(maxsize=1)
def tutorial_requirements() -> dict[int, dict]:
    raw = json.loads((_ROOT / "config/tutorial_battle_groups.json").read_text())
    return {int(group_id): value for group_id, value in raw.items()}


def resolve_tutorial_group(group_id: int) -> tuple[int, list[dict], int] | None:
    """Return required active quest, configured enemies and EXP for an allowed group."""
    requirement = tutorial_requirements().get(group_id)
    group = table("MonsterGroupManInfo").get(group_id)
    if requirement is None or group is None or not group["pokemons"]:
        return None
    monsters_cfg = table("MonstrosityInfo")
    enemies = []
    for monster_id in group["pokemons"]:
        info = monsters_cfg.get(int(monster_id))
        if info is None or not info["level"]:
            return None
        level = int(info["level"][0])
        stage, star = int(info["petStage"]), int(info["petStar"])
        hp = (untrained_hp(int(info["petnumber"]), level, stage, star)
              * int(info["amendmentHP"]) // 1000)
        skill = lambda key: int(info[key][0]) if info[key] else 0
        enemies.append({
            "mID": int(info["id"]), "level": level,
            "skill1": skill("skill1"), "skill2": skill("skill2"),
            "skill3": skill("skill3"), "hp": hp,
            "petStage": stage, "petStar": star, "skin": 0,
        })
    return int(requirement["quest_id"]), enemies, int(group["exp"])


def resolve_monster_man_group(group_id: int) -> tuple[list[dict], int] | None:
    """Resolve any configured trainer group; authorization is checked per caller."""
    group = table("MonsterGroupManInfo").get(group_id)
    if group is None or not group["pokemons"]:
        return None
    monsters_cfg = table("MonstrosityInfo")
    enemies = []
    for monster_id in group["pokemons"]:
        info = monsters_cfg.get(int(monster_id))
        if info is None or not info["level"]:
            return None
        level = int(info["level"][0])
        stage, star = int(info["petStage"]), int(info["petStar"])
        hp = (untrained_hp(int(info["petnumber"]), level, stage, star)
              * int(info["amendmentHP"]) // 1000)
        skill = lambda key: int(info[key][0]) if info[key] else 0
        enemies.append({
            "mID": int(info["id"]), "level": level,
            "skill1": skill("skill1"), "skill2": skill("skill2"),
            "skill3": skill("skill3"), "hp": hp,
            "petStage": stage, "petStar": star, "skin": 0,
        })
    return enemies, int(group["exp"])


@lru_cache(maxsize=1)
def world_map_trainer_events() -> dict[int, int]:
    """Map target client map_event IDs of type=0 to configured trainer IDs."""
    from client_config import text_table
    rows = text_table("map_event.txt")
    result = {}
    for row in rows[1:]:
        if len(row) < 3:
            continue
        event_id, event_type, target = int(row[0]), int(row[1]), row[2]
        if event_type == 0 and target.isdigit():
            result[event_id] = int(target)
    return result


@lru_cache(maxsize=1)
def world_map_wild_events() -> dict[int, int]:
    """Map event IDs of type 1 to their configured MonstrosityInfo IDs."""
    from client_config import text_table
    return {int(row[0]): int(row[2]) for row in text_table("map_event.txt")[1:]
            if len(row) >= 3 and row[0].isdigit() and row[1] == "1" and row[2].isdigit()}


def resolve_world_map_wild(monster_id: int) -> tuple[dict, int] | None:
    """Resolve a normal world-map wild encounter drawn from the authored map."""
    configured_ids = set(world_map_wild_events().values())
    return resolve_wild(monster_id) if monster_id in configured_ids else None


def resolve_wild(monster_id: int) -> tuple[dict, int] | None:
    info = table("MonstrosityInfo").get(monster_id)
    if info is None or not info["level"]:
        return None
    level = int(info["level"][0])
    stage, star = int(info["petStage"]), int(info["petStar"])
    hp = (untrained_hp(int(info["petnumber"]), level, stage, star)
          * int(info["amendmentHP"]) // 1000)
    skill = lambda key: int(info[key][0]) if info[key] else 0
    enemy = {"mID": int(info["id"]), "level": level,
             "skill1": skill("skill1"), "skill2": skill("skill2"),
             "skill3": skill("skill3"), "hp": hp,
             "petStage": stage, "petStar": star, "skin": 0}
    if info["capture"] > 0:
        try:
            acquisition_skill_pools(int(info["petnumber"]))
        except ValueError:
            pass
        else:
            enemy["canCatch"] = True  # Lua tests for field presence.
    return enemy, int(info["exp"])


@lru_cache(maxsize=1)
def world_map_event_types() -> dict[int, int]:
    """Target client's configured world-map event type by event ID."""
    from client_config import text_table
    result = {}
    for row in text_table("map_event.txt")[1:]:
        if len(row) >= 2 and row[0].isdigit() and row[1].isdigit():
            result[int(row[0])] = int(row[1])
    return result


@lru_cache(maxsize=1)
def world_map_node_unlocks() -> dict[tuple[int, int], int]:
    """Target client lock index for each configured (world map, node) pair."""
    from client_config import text_table
    result = {}
    for row in text_table("map_node.txt")[1:]:
        if len(row) < 6 or not row[0].isdigit() or not row[1].isdigit():
            continue
        if row[5].isdigit():
            result[(int(row[0]), int(row[1]))] = int(row[5])
    return result


def tutorial_wild_requirements() -> dict:
    """Configured type-1 catch encounters from the shipped firstPetCatch flow."""
    raw = json.loads((_ROOT / "config/tutorial_wild_battles.json").read_text())
    return {int(monster_id): raw for monster_id in raw["monster_ids"]}


def resolve_tutorial_wild(monster_id: int) -> tuple[int, dict, int] | None:
    requirement = tutorial_wild_requirements().get(monster_id)
    info = table("MonstrosityInfo").get(monster_id)
    if requirement is None or info is None or not info["level"]:
        return None
    level = int(info["level"][0])
    stage, star = int(info["petStage"]), int(info["petStar"])
    hp = (untrained_hp(int(info["petnumber"]), level, stage, star)
          * int(info["amendmentHP"]) // 1000)
    skill = lambda key: int(info[key][0]) if isinstance(info[key], list) and info[key] else 0
    enemy = {
        "mID": int(info["id"]), "level": level,
        "skill1": skill("skill1"), "skill2": skill("skill2"),
        "skill3": skill("skill3"), "hp": hp,
        "petStage": stage, "petStar": star, "skin": 0,
        "canCatch": True,
    }
    return int(requirement["quest_id"]), enemy, int(info["exp"])
