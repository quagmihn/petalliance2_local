"""Target-client skill book and slot rules."""

from client_config import table

SKILL_BOOK = 1
SKILL_SHARD = 10001


def skill_book(item_id):
    item = table("ItemInfo").get(item_id)
    if item is None or item["itemType"] != SKILL_BOOK:
        return None
    skill = table("PetSkillInfo").get(item["paramA"])
    if skill is None or skill["skill_A_Type"] not in (0, 1, 6):
        return None
    return item, skill


def replacement_skill(template_id, slot, active, passive, item, wanted):
    """Match PetSkillViewMgr's family, element, slot and rarity filters."""
    template = table("PokemonInfo").get(template_id)
    if template is None:
        return False
    if item["paramB"]:
        dedicated = table("CustomSkillBookInfo").get(item["paramB"])
        if not dedicated or template_id not in dedicated["petIDs"]:
            return False
    elif wanted["skillAtt"] not in (1, template["elementAtt1"], template["elementAtt2"]):
        return False

    skills = table("PetSkillInfo")
    if slot < 4:
        current = skills.get(active[slot])
        required_type = current["skill_A_Type"] if current else int(slot == 3)
        peers = active[:slot] + active[slot + 1:]
    else:
        current_slot = passive[slot - 4]
        if (wanted["skill_A_Type"] != 6
                or current_slot["paSkillType"] != wanted["airpower"] - 1):
            return False
        current = skills.get(current_slot["paSkillID"])
        required_type = current["skill_A_Type"] if current else 6
        peers = [entry["paSkillID"] for index, entry in enumerate(passive) if index != slot - 4]
    return (wanted["skill_A_Type"] == required_type
            and (current is None or current["id"] // 10 != wanted["id"] // 10)
            and not any(
        skill_id in skills and skills[skill_id]["groundpower"] == wanted["groundpower"]
        for skill_id in peers))


def skill_upgrade_costs(current, target):
    if (target is None or not 1 <= current["id"] % 10 <= 4
            or current["skill_A_Type"] != target["skill_A_Type"]
            or current["groundpower"] != target["groundpower"]):
        return None
    config = table("GlobalConfigAddInfo")
    level = current["id"] % 10
    innate = current["skill_A_Type"] in (7, 8)
    rarity = current["airpower"]
    if not 1 <= rarity <= 6:
        return None
    shards = config[6400 + level]["values"][0] * config[6550 + rarity]["values"][0]
    if innate:
        return {SKILL_SHARD: shards * 2}
    book_id = current["upItemType"]
    book = skill_book(book_id)
    if book is None or book[1]["groundpower"] != current["groundpower"]:
        return None
    return {SKILL_SHARD: shards, book_id: config[6450 + level]["values"][0]}
