"""VIP rank IDs and eligibility from the installed target's tables."""
from functools import cache
import os

from client_config import table


def unlimited_shop():
    return (os.getenv("VIP_SHOP_UNLIMITED") == "1"
            and os.getenv("MONSTER2_LAUNCH_PROFILE") in ("local", "test")
            and os.getenv("LOCAL_PAYMENT_SANDBOX") == "1"
            and os.getenv("PAYMENT_PROVIDER") == "local")


@cache
def max_vip():
    return table("VipInfo")[table("GlobalConfigAddInfo")[55]["values"][0]]


def rank_for_recharge(total):
    return max(row["viplevel"] for row in table("VipInfo").values()
               if row["id"] <= max_vip()["id"] and row["recharge"] <= total)


def milestone(vip_id, requested_awards):
    from reward_config import resolve_reward

    row = table("VipInfo").get(vip_id)
    if row is None or vip_id > max_vip()["id"]:
        return None
    awards = row["awardsID"]
    # This APK submits an empty vector for the one displayed drop, or
    # identifies the chosen alternate if the rank has multiple choices.
    if len(awards) == 1 and requested_awards in ([], awards):
        selected = awards[0]
    elif len(requested_awards) == 1 and requested_awards[0] in awards:
        selected = requested_awards[0]
    else:
        return None
    rewards = [resolve_reward(r) for r in table("DropInfo")[selected]["reNumber"]]
    return (row["viplevel"], rewards) if rewards and all(rewards) else None
