#!/usr/bin/env python3
"""Compare unavailable Pet acquisition definitions across local config snapshots."""
import json
import sys
from collections import Counter
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "server"))
from client_config import table
from pet_config import acquisition_skill_pools


def snapshot(root):
    genes = table("GeneInfo", root)
    skill_pools = table("GeneProbabilityInfo", root)
    attack_ids = {}
    for gene in genes.values():
        pool = skill_pools.get(gene["skill_1"], {})
        ids = {entry["prob_skillID"] for entry in pool.get("geneGroup", []) if entry["prob"]}
        attack_ids.setdefault(gene["petID"], set()).update(ids)
    encounters = {row["petnumber"] for row in table("MonstrosityInfo", root).values()}
    fragments = {row["pokeID"] for row in table("PetPieceInfo", root).values()}
    awards = {row["elementID"] for row in table("AwardElementInfo", root).values()
              if row["elementType"] == 5}
    evolution = table("PetEvoInfo", root)
    evolution_targets = {result["newRace"] for row in evolution.values()
                         for step in row["PetEvoLevelInfoVec"] for result in step["EvoRateInfoVec"]}
    return attack_ids, encounters | fragments | awards | evolution.keys() | evolution_targets


def main():
    roots = ("apk_extracted", "apk_raw/unpacked", "unpacked")
    sources = {name: snapshot(ROOT / name / "assets/res/Config") for name in roots}
    counts = Counter(dict.fromkeys(
        ("VALID_BATTLE_PET", "NON_COMBAT_CONTENT", "MISSING_CONFIGURATION", "UNRESOLVED"), 0))
    blocked = []
    for template_id, row in table("PokemonInfo").items():
        if row["useType"] == 1:  # Proto.ePUT_Material
            counts["NON_COMBAT_CONTENT"] += 1
            continue
        try:
            acquisition_skill_pools(template_id)
        except ValueError:
            category = "MISSING_CONFIGURATION" if row["useType"] == 0 else "UNRESOLVED"
        else:
            category = "VALID_BATTLE_PET" if row["useType"] == 0 else "UNRESOLVED"
        counts[category] += 1
        if category != "VALID_BATTLE_PET":
            blocked.append({"template_id": template_id, "use_type": row["useType"], "category": category,
                            "snapshots": {name: {"basic_attack_ids": sorted(ids.get(template_id, set())),
                                                 "encounter_or_acquisition_ref": template_id in refs}
                                          for name, (ids, refs) in sources.items()}})
    print(json.dumps({"counts": dict(counts), "blocked_combat": blocked}, indent=2))


if __name__ == "__main__":
    main()
