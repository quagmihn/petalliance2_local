"""Resolve Bag chest drops without crossing the DropInfo/RewardInfo namespaces."""
from functools import cache

from client_config import table
from reward_config import RewardConfigError, drop_plan, roll_drop


@cache
def chest_drop(item_id):
    item = table("ItemInfo").get(item_id)
    if not item or item["bUse"] != 1 or item["itemType"] != 18:
        raise RewardConfigError(f"item {item_id} is not an enabled Bag chest")
    if any(item[key] for key in ("paramB", "paramC", "paramD", "paramE")):
        raise RewardConfigError(f"item {item_id} requires an additional use contract")
    return drop_plan(item["paramA"], pet_gene=True)


def chest_rewards(item_id, count):
    return roll_drop(chest_drop(item_id), count)
