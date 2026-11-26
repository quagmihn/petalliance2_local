"""Explicitly local odds over compatible target APK content."""
import json
from collections import defaultdict
from functools import cache
from pathlib import Path

from client_config import ROOT, table
from pet_config import acquisition_skill_pools
from skill_config import skill_book

ASSETS = ROOT / "apk_raw/unpacked/assets/res"
LEGACY = Path(__file__).with_name("config") / "local_play_draw.json"
PET_CATEGORIES = {"1": {1, 2, 3}, "2": {3, 4, 5, 6}}


@cache
def compatible_pets():
    by_grade = defaultdict(list)
    required = (".png", ".skel", ".atlas", "b.png", "b.skel", "b.atlas")
    for uid, definition in sorted(table("PokemonInfo").items()):
        if definition["useType"] != 0:
            continue
        try:
            acquisition_skill_pools(uid)
            skin = f"{int(definition['fightSkin']):03d}"
            icon = int(definition["icon"])
        except (KeyError, ValueError):
            continue
        if (all((ASSETS / f"Spine/pet/{skin}{suffix}").is_file() for suffix in required)
                and (ASSETS / f"Pet/PetIcon/{icon}.png").is_file()):
            by_grade[definition["rarePoint"]].append(uid)
    return {grade: tuple(ids) for grade, ids in by_grade.items()}


@cache
def compatible_books():
    by_class = defaultdict(list)
    dedicated = table("CustomSkillBookInfo")
    for item_id in sorted(table("ItemInfo")):
        book = skill_book(item_id)
        if book is None:
            continue
        item, skill = book
        if item["paramB"] and not dedicated.get(item["paramB"], {}).get("petIDs"):
            continue
        by_class[skill["skill_A_Type"]].append(item_id)
    return {kind: tuple(ids) for kind, ids in by_class.items()}


@cache
def compatible_fashion_vouchers():
    fashions = table("FashionItemInfo")
    result = []
    for item_id, item in sorted(table("ItemInfo").items()):
        if item["itemType"] != 22 or item["bUse"] != 1:
            continue
        fashion = fashions.get(item["paramA"])
        if (fashion and fashion["isHide"] == 0 and (ASSETS / fashion["filePath"]).is_file()
                and (ASSETS / item["icon"]).is_file()):
            result.append(item_id)
    return tuple(result)


def spread(ids, weight, kind):
    if not ids or type(weight) is not int or weight < len(ids):
        raise ValueError(f"pool bucket {kind} has no entries or insufficient weight")
    base, extra = divmod(weight, len(ids))
    return [{kind: template, "count": 1, "weight": base + (i < extra)}
            for i, template in enumerate(ids)]


def expanded_pools(policy):
    legacy = json.loads(LEGACY.read_text())["machines"]
    groups = policy["pet_grade_weights"]
    if set(groups) != set(PET_CATEGORIES):
        raise ValueError("missing expanded Pet draw machines")
    pools = {}
    for machine, grades in groups.items():
        if {int(grade) for grade in grades} != PET_CATEGORIES[machine]:
            raise ValueError(f"invalid rarity buckets for machine {machine}")
        pool = [entry for entry in legacy[machine] if "item_id" in entry
                and (machine != "2" or table("ItemInfo")[entry["item_id"]]["itemType"] != 22)]
        if machine == "2":
            pool.extend(spread(compatible_fashion_vouchers(), policy["supreme_fashion_weight"], "item_id"))
        for grade, weight in sorted(grades.items()):
            pool.extend(spread(compatible_pets().get(int(grade), ()), weight, "pet_id"))
        pools[machine] = pool

    by_class = policy["skill_class_weights"]
    if {int(kind) for kind in by_class} != set(compatible_books()):
        raise ValueError("invalid expanded skill class buckets")
    skill_pool = [entry for entry in legacy["3"] if skill_book(entry["item_id"]) is None]
    for kind, weight in sorted(by_class.items()):
        skill_pool.extend(spread(compatible_books()[int(kind)], weight, "item_id"))
    pools["3"] = skill_pool
    return pools
