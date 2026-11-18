"""Resolve a configured RewardInfo row to one validated game reward.

RewardInfo vectors are weighted alternatives: element[i] is an
AwardElementInfo ID, nReward[i] is its amount, and probability[i] is its
weight. This follows the shipped client schema and the existing Adventure
reward resolver. Unknown element kinds fail closed.
"""
from __future__ import annotations

import secrets

from client_config import table
from pet_config import pokemon


class RewardConfigError(ValueError):
    pass


_KINDS = {1: "g_cash", 2: "m_cash", 3: "item", 4: "exp", 5: "pet"}


def resolve_reward(reward_id: int, *, draw: int | None = None) -> dict | None:
    if reward_id == 0:
        return None
    reward = table("RewardInfo").get(reward_id)
    if reward is None:
        raise RewardConfigError(f"missing RewardInfo id {reward_id}")
    element_ids = reward["element"]
    amounts = reward["nReward"]
    weights = reward["probability"]
    if not element_ids or not (len(element_ids) == len(amounts) == len(weights)):
        raise RewardConfigError(f"malformed RewardInfo vectors for id {reward_id}")
    if any(type(weight) is not int or weight < 0 for weight in weights) or sum(weights) <= 0:
        raise RewardConfigError(f"invalid probability weights for RewardInfo id {reward_id}")
    if draw is None:
        draw = secrets.randbelow(sum(weights))
    if type(draw) is not int or draw < 0 or draw >= sum(weights):
        raise ValueError("reward draw is outside the configured weight range")
    selected = 0
    for i, weight in enumerate(weights):
        if draw < weight:
            selected = i
            break
        draw -= weight
    element_id = element_ids[selected]
    amount = amounts[selected]
    if type(amount) is not int or amount <= 0:
        raise RewardConfigError(f"invalid amount in RewardInfo id {reward_id}")
    element = table("AwardElementInfo").get(element_id)
    if element is None:
        raise RewardConfigError(f"missing AwardElementInfo id {element_id}")
    kind = _KINDS.get(element["elementType"])
    if kind is None:
        raise RewardConfigError(
            f"unsupported AwardElementInfo type {element['elementType']} (id {element_id})")
    target = int(element["elementID"])
    if kind in ("g_cash", "m_cash", "exp"):
        target = 0
    elif kind == "item":
        if target <= 0 or table("ItemInfo").get(target) is None:
            raise RewardConfigError(f"unknown reward item id {target}")
    elif kind == "pet":
        pokemon(target)  # raises for an unknown template
    return {"kind": kind, "id": target, "num": amount}
