"""Resolve explicitly configured tutorial encounters from shipped battle data."""
from __future__ import annotations

import json
from functools import lru_cache
from pathlib import Path

from client_config import table
from pet_config import untrained_hp

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
