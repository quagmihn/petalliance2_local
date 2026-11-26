"""Resolve the six first-bonus and repeat pairs in PurchaseViewMgr."""
from functools import cache

from client_config import table


@cache
def normal_families():
    pairs = {}
    prices = {}
    for sku, row in table("NormalRechargeInfo").items():
        key = (row["money"], row["mCash"])
        members = prices.setdefault(key, {})
        if row["money"] <= 0 or row["mCash"] <= 0:
            raise ValueError(f"Invalid recharge price or amount for N{sku}")
        bonus = bool(row["bonusRate"])
        if bonus in members or bonus != bool(row["bonusCD"]):
            raise ValueError(f"Invalid normal recharge pair for N{sku}")
        members[bonus] = row
    for members in prices.values():
        if set(members) != {False, True}:
            raise ValueError("Incomplete recharge pair")
        bonus, repeat = members[True], members[False]
        pairs[bonus["id"]] = pairs[repeat["id"]] = (bonus, repeat)
    return pairs


def active_normal_package(bonus, repeat, last_bonus, now):
    cooldown = bonus["bonusCD"] * 60  # PurchaseViewMgr.checkRechargeFun
    return repeat if last_bonus is not None and now - last_bonus < cooldown else bonus
