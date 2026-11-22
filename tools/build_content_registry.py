#!/usr/bin/env python3
"""Export recoverable client content with provenance and explicit reference checks."""
from __future__ import annotations

import argparse
from collections import Counter, defaultdict
from dataclasses import asdict
from hashlib import sha256
import json
from pathlib import Path
import sqlite3
import sys
from zipfile import ZipFile

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "server"))
from adventure_config import scene_cells
from client_config import CONFIG, table, text_table
from quest_config import GACHA_GUIDE_PET_ID, GACHA_GUIDE_QUEST_ID, load_quests


DRAW_GROUP_FIELDS = (
    "normalEggAwardIndex", "firstEggAwardIndex", "firstTenEggAwardIndex",
    "normalTenEggAwardIndex", "tenTimesEggAwardIndex",
)
DRAW_TABLES = ("CapsuleEggInfo", "CapsuleEggAwardInfo", "AwardElementInfo",
               "ConsumeElementInfo", "ItemInfo", "PokemonInfo")
CONTENT_TABLES = (
    "ItemInfo", "PokemonInfo", "GeneInfo", "GeneProbabilityInfo", "PetSkillInfo",
    "PetEvoInfo", "PetAdvanceInfo", "PetStrengthenInfo", "PetPieceInfo", "PokemonBallInfo",
    "ExperienceInfo", "EquipmentInfo", "PetEquipInfo", "PetEquipEffectInfo",
    "PetEquipStrengthenInfo", "EquipmentStrInfo", "EquipmentWashInfo",
    "FashionItemInfo", "FashionSuitEffectInfo", "ConsumeElementInfo", "AwardElementInfo",
    "RewardInfo", "MarketInfo", "ShopInfo", "ShopPoolInfo", "ShopReflashInfo",
    "ActivityShopInfo", "FamilyShopInfo", "NpcBusinessmanInfo", "VipInfo",
    "NormalRechargeInfo", "MonthCardRechargeInfo", "FirstRechargeAwardInfo",
    "CapsuleEggInfo", "CapsuleEggAwardInfo", "AdventureInfo", "SceneInfo",
    "FloorRelationInfo", "MapNodeInfo", "MapEventInfo", "EventListInfo",
    "EventNpcInfo", "MonsterGroupManInfo", "MonstrosityInfo", "ActivityInfoClient",
    "SigninInfo", "StationaryAwardInfo",
)
TARGET_KINDS = {1: "gold", 2: "diamond", 3: "item", 4: "exp", 5: "pet"}


def write_json(path, value):
    path.write_text(json.dumps(value, ensure_ascii=False, separators=(",", ":")) + "\n")


def provenance(configs, root):
    return {name: sha256((root / f"{name}.dat").read_bytes()).hexdigest() for name in configs}


def gacha_matrix(root):
    machines, pools, awards, costs, items, pets = (table(name, root) for name in DRAW_TABLES)
    users = defaultdict(list)
    unknown = []
    for machine_id, machine in machines.items():
        for field in DRAW_GROUP_FIELDS:
            pool_id = machine[field]
            users[pool_id].append([machine_id, field])
            if pool_id not in pools:
                unknown.append([machine_id, field, pool_id])
        for field in ("OneEggCons", "tenEggCons"):
            if machine[field] not in costs:
                unknown.append([machine_id, field, machine[field]])
    enriched_pools = {}
    for pool_id, pool in pools.items():
        entries = []
        for prize in pool["awardInfoVec"]:
            entry = dict(prize)
            element_id = prize["awardItemIndex"]
            award = awards.get(element_id)
            if award:
                kind = TARGET_KINDS.get(award["elementType"])
                target_id = award["elementID"]
                template = (items if kind == "item" else pets if kind == "pet" else {}).get(target_id)
                entry.update(kind=kind, template_id=target_id, award_element=award,
                             name_key=template.get("name") if template else None,
                             rarity=template.get("itemRare", template.get("rarePoint")) if template else None)
                if kind in ("item", "pet") and not template:
                    unknown.append([pool_id, kind, target_id])
            else:
                unknown.append([pool_id, "AwardElementInfo", element_id])
            entries.append(entry)
        enriched_pools[pool_id] = {"machines": users[pool_id], "entries": entries,
                                   "weight_sum": sum(prize["rate"] for prize in entries)}
    references = {machine_id: {field: costs.get(machine[field])
                                for field in ("OneEggCons", "tenEggCons")}
                  for machine_id, machine in machines.items()}
    return {"source": str(root.relative_to(ROOT)), "hashes": provenance(DRAW_TABLES, root),
            "machines": machines, "pools": enriched_pools, "costs": references,
            "missing_references": unknown}


def record_reference(issues, source, source_id, target, target_id, definitions):
    if target_id and target_id not in definitions:
        issues[source + "->" + target].append([source_id, target_id])


def audit_references(parsed, quests):
    issues, unmapped_objectives = defaultdict(list), Counter()
    products_by_item, rewards_by_item = defaultdict(list), defaultdict(list)
    items, pets = parsed["ItemInfo"], parsed["PokemonInfo"]
    for name in ("MarketInfo", "ActivityShopInfo", "ShopPoolInfo", "NpcBusinessmanInfo"):
        for row_id, row in parsed[name].items():
            offers = row.get("shopDetail", row.get("npcShop", [row]))
            for index, offer in enumerate(offers):
                item_id = offer["itemID"]
                record_reference(issues, name, [row_id, index], "ItemInfo", item_id, items)
                products_by_item[item_id].append([name, row_id, index])
    for row_id, row in parsed["ShopInfo"].items():
        for pool_id in row["shopPool"]:
            record_reference(issues, "ShopInfo", row_id, "ShopPoolInfo", pool_id, parsed["ShopPoolInfo"])
    for item_id, item in items.items():
        if item["itemType"] == 22:
            record_reference(issues, "ItemInfo.fashion", item_id, "FashionItemInfo",
                             item["paramA"], parsed["FashionItemInfo"])
    for row_id, row in parsed["GeneInfo"].items():
        record_reference(issues, "GeneInfo", row_id, "PokemonInfo", row["petID"], pets)
        groups = [row[key] for key in ("skill_1", "skill_2", "skill_3", "profound")]
        groups += [passive["passiveSkillID"] for passive in row["passiveSkills"]]
        for group in set(groups):
            record_reference(issues, "GeneInfo", row_id, "GeneProbabilityInfo",
                             group, parsed["GeneProbabilityInfo"])
    elements = parsed["AwardElementInfo"]
    for row_id, offer in parsed["FamilyShopInfo"].items():
        element_id = offer["awardElementID"]
        record_reference(issues, "FamilyShopInfo", row_id, "AwardElementInfo", element_id, elements)
        element = elements.get(element_id)
        if element and element["elementType"] == 3:
            item_id = element["elementID"]
            record_reference(issues, "FamilyShopInfo", row_id, "ItemInfo", item_id, items)
            products_by_item[item_id].append(["FamilyShopInfo", row_id, 0])
    for element_id, element in elements.items():
        if element["elementType"] == 3:
            record_reference(issues, "AwardElementInfo", element_id, "ItemInfo", element["elementID"], items)
            rewards_by_item[element["elementID"]].append(element_id)
        if element["elementType"] == 5:
            record_reference(issues, "AwardElementInfo", element_id, "PokemonInfo", element["elementID"], pets)
    for reward_id, reward in parsed["RewardInfo"].items():
        for element_id in reward["element"]:
            record_reference(issues, "RewardInfo", reward_id, "AwardElementInfo", element_id, elements)
    for group_id, group in parsed["MonsterGroupManInfo"].items():
        for mob_id in set(group["pokemons"] + group["helperPokemons"]):
            record_reference(issues, "MonsterGroupManInfo", group_id,
                             "MonstrosityInfo", mob_id, parsed["MonstrosityInfo"])
    for quest_id, quest in quests.items():
        record_reference(issues, "NewQuestInfo.parent", quest_id, "NewQuestInfo", quest.parent_id, quests)
        record_reference(issues, "NewQuestInfo", quest_id, "RewardInfo", quest.award_id, parsed["RewardInfo"])
        record_reference(issues, "NewQuestInfo.first_pokemon", quest_id, "PokemonInfo",
                         quest.first_pokemon_id, pets)
        for index, objective in enumerate(quest.objectives):
            if objective.event_type == 18:
                record_reference(issues, "NewQuestInfo.world_event", [quest_id, index],
                                 "MapEventInfo", objective.final_id, parsed["MapEventInfo"])
            elif objective.event_type == 19:
                record_reference(issues, "NewQuestInfo.adventure", [quest_id, index],
                                 "AdventureInfo", objective.main_id, parsed["AdventureInfo"])
            else:
                unmapped_objectives[objective.event_type] += 1
    return dict(issues), dict(unmapped_objectives), products_by_item, rewards_by_item


def adventure_index(parsed):
    cells = defaultdict(list)
    for cell in parsed["SceneInfo"].values():
        cells[cell["number"]].append(cell)
    goals = {int(row[0]): {"adventure_id": int(row[1]), "description": row[2],
                           "event_type": int(row[3]), "event_value": row[4], "parameter": row[5]}
             for row in text_table("Fbmb.txt")[1:] if row[0].isdigit()}
    index = {}
    for adventure_id, adventure in parsed["AdventureInfo"].items():
        floor_cells = sorted(cells[adventure_id], key=lambda cell: (cell["floor"], cell["id"]))
        grouped = defaultdict(list)
        for cell in floor_cells:
            grouped[cell["floor"]].append(cell["id"])
        index[adventure_id] = {
            "config": adventure, "cells_by_floor": dict(grouped),
            "exact_authored_grid": bool(scene_cells(adventure_id)),
            "fixed_scene_events": sorted({(cell["eventType"], cell["event"]) for cell in floor_cells
                                          if cell["event"]}),
            "cell_reward_ids": sorted({cell["award"] for cell in floor_cells if cell["award"]}),
            "goals": {goal_id: goals.get(goal_id) for goal_id in adventure["target"] if goal_id},
        }
    return index


def catalog_rows(parsed, assets, translations, shop_refs, reward_refs):
    items, pets, fashion = parsed["ItemInfo"], parsed["PokemonInfo"], parsed["FashionItemInfo"]
    genes_by_pet = defaultdict(list)
    for gene in parsed["GeneInfo"].values():
        genes_by_pet[gene["petID"]].append(gene["id"])
    for name, records in (("ItemInfo", items), ("PokemonInfo", pets), ("FashionItemInfo", fashion),
                          ("PetEquipInfo", parsed["PetEquipInfo"]), ("EquipmentInfo", parsed["EquipmentInfo"])):
        for row_id, record in records.items():
            classification = name
            icon = record.get("icon") or record.get("filePath")
            key = record.get("name")
            if name == "PokemonInfo" and icon:
                icon = f"Pet/PetIcon/{icon}.png"
            elif name == "EquipmentInfo":
                # EquipmentInfo.id is its own grade/part configuration key.
                # It is not an ItemInfo ID just because the numbers overlap.
                classification = "character_equipment_grade"
            asset_path = f"assets/res/{icon}" if icon else None
            row = dict(id=row_id, content_type=classification, source=f"{name}.dat", name_key=key,
                       en=translations.get(key), asset_path=asset_path,
                       asset_present=asset_path in assets if asset_path else None,
                       rarity=record.get("itemRare", record.get("rarePoint", record.get("quality"))),
                       status="PARSED", config=record)
            if name == "ItemInfo":
                row.update(usage={"use_flag": record["bUse"], "type": record["itemType"],
                                  "params": [record["param" + suffix] for suffix in "ABCDE"]},
                           shop_offers=shop_refs[row_id], award_elements=reward_refs[row_id],
                           protocol="itemID", persistence="inventory stack by char_id and item_id",
                           stack_limit=None, required_level=None)
                if record["itemType"] == 22:
                    row["usage"]["fashion_id"] = record["paramA"]
                    row["usage"]["target"] = "character"
                if record["itemType"] == 19:
                    row["usage"]["target"] = "owned Pet UID"
            elif name == "PokemonInfo":
                row.update(gene_ids=genes_by_pet[row_id], protocol="pokeID (template), objID (owned)",
                           persistence="pets keyed by pet_uid", stack_limit=1)
            elif name == "FashionItemInfo":
                row.update(protocol="FashionInfo vector with configured IDs",
                           persistence="characters.game_values.fashion_info", stack_limit=1)
            yield row


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--apk", type=Path, required=True, help="the exact target runtime APK")
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    args.output.mkdir(parents=True, exist_ok=True)
    with ZipFile(args.apk) as apk:
        assets = set(apk.namelist())
        signed_members = {name: sha256(apk.read(f"assets/res/Config/{name}.dat")).hexdigest()
                          for name in (*DRAW_TABLES, "AdventureInfo", "SceneInfo", "NewQuestInfo")}
    with sqlite3.connect(f"file:{CONFIG / 'db/lang_en.db'}?mode=ro", uri=True) as db:
        translations = dict(db.execute("SELECT code,lang FROM tbl_lang ORDER BY id"))
    parsed, discovery = {}, {}
    for path in sorted(CONFIG.glob("*.dat")):
        try:
            parsed[path.stem] = table(path.stem)
        except (ValueError, IndexError, KeyError) as exc:
            discovery[path.name] = {"status": "DISCOVERED", "parser_blocker": str(exc)}
        else:
            discovery[path.name] = {"status": "PARSED", "rows": len(parsed[path.stem])}
    for path in sorted(CONFIG.glob("*.txt")):
        try:
            count = len(text_table(path.name))
        except (ValueError, OSError) as exc:
            discovery[path.name] = {"status": "DISCOVERED", "parser_blocker": str(exc)}
        else:
            discovery[path.name] = {"status": "PARSED", "rows_including_header": count}
    quests = load_quests()
    issues, unknown_objectives, shops, rewards = audit_references(parsed, quests)
    target = gacha_matrix(CONFIG)
    alternate = gacha_matrix(ROOT / "apk_raw/unpacked/assets/res/Config")
    for name, digest in signed_members.items():
        if digest != sha256((CONFIG / f"{name}.dat").read_bytes()).hexdigest():
            raise SystemExit(f"target APK member differs from server config: {name}.dat")
    counts = {name: len(parsed[name]) for name in CONTENT_TABLES if name in parsed}
    counts["NewQuestInfo"] = len(quests)
    write_json(args.output / "GACHA_CONTENT_MATRIX.json", {
        "installed_config_hashes": signed_members, "target": target, "alternate": alternate,
        "tutorial": {"quest_id": GACHA_GUIDE_QUEST_ID, "pet_template": GACHA_GUIDE_PET_ID,
                     "senior_machine": 1, "supreme_machine": 2, "choice": 1, "free": True,
                     "evidence": ["GameGuideMgr1.firstGacha", "GameGuideMgr3.firstSkillPromote",
                                  "npc.txt IDs 27–30", "quest1027", "petname45"]},
        "confirmed": ["weights", "pool and award references", "machine prices and cooldown metadata"],
        "inferred": ["conditions and precedence for ordinary first, first-ten and guarantee groups"],
    })
    counts_missing_assets = Counter()
    with (args.output / "content_registry.jsonl").open("w") as output:
        for row in catalog_rows(parsed, assets, translations, shops, rewards):
            if row["asset_present"] is False:
                counts_missing_assets[row["source"]] += 1
            output.write(json.dumps(row, ensure_ascii=False, separators=(",", ":")) + "\n")
    write_json(args.output / "config_tables.json", {name: parsed[name] for name in CONTENT_TABLES if name in parsed})
    write_json(args.output / "quest_dependencies.json", {
        "quests": {quest_id: asdict(quest) for quest_id, quest in quests.items()},
        "missing_references": {key: value for key, value in issues.items() if "NewQuestInfo" in key},
        "unmapped_objective_types": unknown_objectives,
    })
    write_json(args.output / "adventure_content.json", adventure_index(parsed))
    write_json(args.output / "content_coverage.json", {
        "discovery": discovery, "counts": counts, "missing_references": issues,
        "missing_asset_paths": dict(counts_missing_assets), "unmapped_objective_types": unknown_objectives,
    })
    print(json.dumps({"counts": counts, "missing_references": {k: len(v) for k, v in issues.items()},
                      "asset_paths_unresolved": dict(counts_missing_assets),
                      "discovery": dict(Counter(row["status"] for row in discovery.values()))}, indent=2))


if __name__ == "__main__":
    main()
