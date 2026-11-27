"""Audit the configured entries and candidate assets against the target APK."""
import argparse
from collections import Counter
from hashlib import sha256
import json
from pathlib import Path
import sqlite3
import sys
from zipfile import ZipFile

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "server"))

from adventure_config import scene_cells, scene_encounter
from adventure_sweep import sweep_config
from chest_config import chest_drop
from client_config import CONFIG, ROOT, table
from market_config import enabled_offers
from reward_config import RewardConfigError, drop_plan


TABLES = ("PokemonInfo", "PetSkillInfo", "SkillInfo", "SkillTagInfo", "GeneInfo",
          "GeneProbabilityInfo", "ItemInfo", "FashionItemInfo", "DropInfo", "RewardInfo", "MarketInfo")


def digest(data):
    return sha256(data).hexdigest()


def english_text(config):
    database = config / "db/lang_en.db"
    if not database.is_file():
        return {}
    with sqlite3.connect(f"{database.resolve().as_uri()}?mode=ro", uri=True) as language:
        return dict(language.execute("SELECT code,lang FROM tbl_lang"))


def candidate_pet_links(root, pet_ids):
    source = root / "assets/res/Config"
    genes = table("GeneInfo", source)
    probabilities = table("GeneProbabilityInfo", source)
    skills = table("PetSkillInfo", source)
    english = english_text(source)
    result = {}
    for pet_id in pet_ids:
        pet = table("PokemonInfo", source)[pet_id]
        matching = [gene for gene in genes.values() if gene["petID"] == pet_id]
        groups = {
            group for gene in matching
            for group in [*(gene[field] for field in ("skill_1", "skill_2", "skill_3", "profound")),
                          *(skill["passiveSkillID"] for skill in gene["passiveSkills"])]
        }
        skill_ids = {entry["prob_skillID"] for group in groups
                     for entry in probabilities.get(group, {}).get("geneGroup", [])
                     if entry["prob"] and entry["prob_skillID"]}
        result[pet_id] = {
            "gene_ids": [gene["id"] for gene in matching],
            "absent_candidate_probability_groups": sorted(groups - probabilities.keys()),
            "absent_target_probability_groups": sorted(groups - table("GeneProbabilityInfo").keys()),
            "absent_candidate_skill_ids": sorted(skill_ids - skills.keys()),
            "absent_target_skill_ids": sorted(skill_ids - table("PetSkillInfo").keys()),
            "english_name": english.get(pet["name"]),
            "english_description": english.get(pet["desc"]),
        }
    return result


def compatibility(apk, candidates):
    report = {}
    with ZipFile(apk) as target:
        installed_files = set(target.namelist())
        for root in candidates:
            stats = {}
            source = root / "assets/res/Config"
            for name in TABLES:
                file = source / f"{name}.dat"
                target_name = f"assets/res/Config/{name}.dat"
                if not file.is_file() or target_name not in installed_files:
                    stats[name] = {"status": "MISSING_DEPENDENCIES"}
                    continue
                hashes = [digest(data) for data in (target.read(target_name), file.read_bytes())]
                if hashes[0] != digest((CONFIG / file.name).read_bytes()):
                    raise ValueError(f"canonical server and target APK differ for {name}")
                live, candidate = table(name), table(name, source)
                added = sorted(candidate.keys() - live.keys())
                removed = sorted(live.keys() - candidate.keys())
                changed = sorted(key for key in live.keys() & candidate.keys() if live[key] != candidate[key])
                stats[name] = {
                    "status": "EXACT_MATCH" if hashes[0] == hashes[1] else "REQUIRES_CLIENT_PATCH",
                    "target_sha256": hashes[0], "candidate_sha256": hashes[1],
                    "target_rows": len(live), "candidate_rows": len(candidate),
                    "added_ids": added, "removed_ids": removed, "changed_ids": changed,
                }
            assets = root / "assets/res"
            new_pet_ids = stats.get("PokemonInfo", {}).get("added_ids", [])
            for item_id in new_pet_ids:
                pet = table("PokemonInfo", source)[item_id]
                skin = pet["fightSkin"]
                resources = [f"Spine/pet/{skin}{suffix}" for suffix in
                             (".png", ".atlas", ".skel", "b.png", "b.atlas", "b.skel")]
                resources.append(f"Pet/PetIcon/{pet['icon']}.png")
                stats["PokemonInfo"].setdefault("missing_candidate_assets", {})[item_id] = [
                    resource for resource in resources if not (assets / resource).is_file()]
            if new_pet_ids and all((source / f"{name}.dat").is_file() for name in
                                   ("GeneInfo", "GeneProbabilityInfo", "PetSkillInfo")):
                stats["PokemonInfo"]["candidate_pet_links"] = candidate_pet_links(root, new_pet_ids)
            report[str(root)] = stats
    return report


def skills_and_chests():
    english = english_text(CONFIG)
    skills = table("SkillInfo")
    tags = table("SkillTagInfo")
    templates = table("SkillTemplateInfo")
    base = ROOT / "decoded_lua/assets/src/GameMgr/Battle/templates"
    described = [row for row in skills.values()
                 if english.get(row["desc"]) and english[row["desc"]] != row["desc"]]
    known_actions = set()
    for skill in skills.values():
        for ref in skill["skillTags"]:
            rules = tags.get(ref["id"], {}).get("templates", [])
            for rule in rules:
                for action in rule["actions"]:
                    code = templates.get(action["id"], {}).get("code")
                    if code and (base / f"{code}.lua").is_file():
                        known_actions.add(code)
    chests = {}
    for item_id, item in table("ItemInfo").items():
        if item["itemType"] != 18 or not item["bUse"]:
            continue
        result = {"name": english.get(item["name"], item["name"]),
                  "description": english.get(item["desc"], item["desc"]),
                  "drop_id": item["paramA"], "groups": table("DropInfo")[item["paramA"]]["reNumber"]}
        try:
            result["rolls"] = chest_drop(item_id)
        except RewardConfigError as exc:
            result["blocked"] = str(exc)
        chests[item_id] = result
    return {"definitions": len(skills), "static_english_descriptions": len(described),
            "top_grade_static_descriptions": sum(row["airpower"] == 5 for row in described),
            "top_grade_rows": sum(row["airpower"] == 5 for row in skills.values()),
            "referenced_action_classes_present": sorted(known_actions)}, chests


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--apk", type=Path, required=True)
    parser.add_argument("candidates", type=Path, nargs="+")
    args = parser.parse_args()
    skills, chests = skills_and_chests()
    monsters = table("MonstrosityInfo")
    sweeps, blocked, capturable = [], {}, []
    for adventure_id, adventure in table("AdventureInfo").items():
        try:
            if sweep_config(adventure_id):
                drop_plan(adventure["rewards"])
                sweeps.append(adventure_id)
        except RewardConfigError as exc:
            blocked[adventure_id] = str(exc)
        for scene in scene_cells(adventure_id):
            encounter = scene_encounter(adventure_id, scene["id"], 2)
            if encounter and monsters.get(encounter[0], {}).get("capture"):
                capturable.append((adventure_id, scene["id"], encounter[0]))
    print(json.dumps({
        "compatibility": compatibility(args.apk, args.candidates),
        "skills": skills, "bag_chests": chests,
        "sweep_ids": sweeps, "blocked_sweeps": blocked, "capturable_adventure_cells": capturable,
        "market_by_category": dict(Counter(row["marketType"] for row in enabled_offers().values())),
    }, ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main()
