"""Target MarketInfo offers and private NPC listings for the Market Shop tab."""
from functools import cache
import json
from pathlib import Path

from client_config import ROOT, table


def validate_offers(products, items):
    enabled = {}
    for sku, offer in products.items():
        if offer["coinType"] not in (1, 2, 3) or (offer["buyMax"] and offer["marketType"] != 4):
            continue
        if offer["itemID"] not in items:
            raise ValueError(f"Market SKU {sku} references missing item {offer['itemID']}")
        if offer["num"] <= 0:
            raise ValueError(f"Market SKU {sku} requires a positive price")
        enabled[sku] = offer
    return enabled


@cache
def enabled_offers():
    return validate_offers(table("MarketInfo"), table("ItemInfo"))


@cache
def local_offers():
    from draw_expansion import compatible_books, compatible_fashion_vouchers, compatible_pets
    from pet_development import overflow_materials
    from skill_config import skill_upgrade_costs

    policy = json.loads(Path(__file__).with_name("config").joinpath("local-market.json").read_text())
    items = table("ItemInfo")
    assets = ROOT / "unpacked/assets/res"
    offers = {}

    def add(item_id, price, category=None):
        item = items[item_id]
        if not item["icon"] or not (assets / item["icon"]).is_file():
            return
        item_type, subtype = category or (item["itemType"], item["itemTypeID"])
        if price <= 0:
            raise ValueError(f"invalid Local Market price for {item_id}")
        offers[f"local:{item_id}"] = {
            "id": item_id, "itemID": item_id, "marketType": 1, "coinType": 3,
            "num": price, "buyMax": 0, "vip": 0, "category": (item_type, subtype),
        }

    # Installed Shop keeps the Style material filter but no longer renders
    # the retired General Material tab.
    material = (17, 4)
    for item_id, price in zip(table("GlobalConfigAddInfo")[9]["values"][:-1],
                              policy["exp_silver_by_potion_order"], strict=True):
        add(item_id, price, material)
    cost_ids = {cost for row in table("PetAdvanceInfo").values()
                for stage in row["stageCons"] for cost in stage["costs"]}
    cost_ids.update(cost for row in table("PetEvoInfo").values()
                    for step in row["PetEvoLevelInfoVec"] for cost in step["stageCons"])
    consume = table("ConsumeElementInfo")
    materials = {consume[cost]["elementID"] for cost in cost_ids if
                 cost in consume and consume[cost]["elementType"] == 3}
    materials.update(item for row in table("PetStarUpInfo").values() for item in row["costItem"])
    materials.update(overflow_materials())
    for item_id in sorted(materials & items.keys()):
        add(item_id, policy["material_silver"], material)
    skills = table("PetSkillInfo")
    upgrade_items = {item_id for skill_id, row in skills.items()
                     for item_id in skill_upgrade_costs(row, skills.get(skill_id + 1)) or ()}
    for item_id in sorted(upgrade_items & items.keys()):
        add(item_id, policy["skill_upgrade_silver"], material)
    eligible_pets = {pet for bucket in compatible_pets().values() for pet in bucket}
    genes = table("GeneInfo")
    for item_id, fragment in table("PetPieceInfo").items():
        if item_id in items and genes.get(fragment["pokeID"], {}).get("petID") in eligible_pets:
            add(item_id, policy["fragment_silver"], material)
    for bucket in compatible_books().values():
        for item_id in bucket:
            add(item_id, policy["book_silver_per_grade"] * max(items[item_id]["itemRare"], 1))
    for item_id in compatible_fashion_vouchers():
        if 1 <= items[item_id]["itemTypeID"] <= 5:
            add(item_id, policy["fashion_silver_per_grade"] * max(items[item_id]["itemRare"], 1))
    # Original silver prices win where the target catalog already offers the item.
    for offer in enabled_offers().values():
        item_id = offer["itemID"]
        if offer["coinType"] == 3:
            add(item_id, offer["num"], material)
    return offers


def search_local_offers(item_type, subtype, item_id, sort, start, count, label):
    items = table("ItemInfo")
    category = (17, 4) if (item_type, subtype) == (17, 1) else (item_type, subtype)
    offers = [offer for offer in local_offers().values() if
              offer["category"] == category and (not item_id or offer["itemID"] == item_id)
              and (not label or items[offer["itemID"]]["selectID"] == label
                   or items[offer["itemID"]]["selectID"].startswith(f"{label}_"))]
    offers.sort(key=lambda offer: (offer["num"] if sort == 1 else items[offer["itemID"]]["name"],
                                   offer["itemID"]))
    return [{"productID": f"local:{offer['itemID']}", "itemID": offer["itemID"],
             "charID": 0, "sellNum": 99, "unitPrice": offer["num"]}
            for offer in offers[start:start + min(count, 50)]]
