"""Emit Pet progression and economy coverage from the official catalogs."""
import json
import sys
from collections import Counter
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "server"))

from arena_shop import pools
from client_config import table
from local_draw import catalog_report
from pet_config import acquisition_skill_pools, star_steps
from recharge_config import normal_families
from skill_config import skill_book, skill_upgrade_costs
from vip_config import max_vip, milestone


def main():
    pokemon, items, skills = (table(name) for name in ("PokemonInfo", "ItemInfo", "PetSkillInfo"))
    pet_results = {}
    for template, row in pokemon.items():
        result = {"use_type": row["useType"], "grade": row["rarePoint"], "name": row["name"]}
        pet_results[template] = result
        try:
            acquisition_skill_pools(template)
            result["acquisition"] = True
        except (KeyError, ValueError) as exc:
            result.update(acquisition=False, blocker=str(exc))
            continue
        try:
            steps = star_steps(template)
            for step in steps:
                acquisition_skill_pools(step.pet)
            result["star_max_from_direct_materials"] = len(steps)
        except (KeyError, ValueError) as exc:
            result["star_blocker"] = str(exc)

    books = [book[1] for item_id in items if (book := skill_book(item_id))]
    upgrades = [row for skill_id, row in skills.items() if skill_upgrade_costs(row, skills.get(skill_id + 1))]
    by_class = lambda records: dict(Counter(row["skill_A_Type"] for row in records))
    print(json.dumps({
        "pokemon": pet_results,
        "skills": {"records_by_type": by_class(skills.values()), "books_by_type": by_class(books),
                   "upgrade_edges_by_type": by_class(upgrades),
                   "books_by_type_and_grade": dict(Counter(f"{b['skill_A_Type']}/{b['airpower']}" for b in books))},
        "items": dict(Counter(row["itemType"] for row in items.values())),
        "evolution_rows": len(table("PetEvoInfo")),
        "draw": catalog_report("config/local_play_draw.json"),
        "recharge": {"normal_sku_pairs": {sku: repeat["id"] for sku, (bonus, repeat) in normal_families().items()
                                         if sku == bonus["id"]},
                     "month_cards": table("MonthCardRechargeInfo")},
        "vip": {"max": max_vip(), "resolvable_milestones": [sku for sku in table("VipInfo") if milestone(sku, [])]},
        "arena": {"slots": len(pools()), "eligible_weighted_rows": sum(map(len, pools()))},
    }, indent=2, sort_keys=True))


if __name__ == "__main__":
    main()
