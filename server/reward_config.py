"""Resolve a configured RewardInfo row to one validated game reward.

RewardInfo vectors are weighted alternatives: element[i] is an
AwardElementInfo ID, nReward[i] is its amount, and probability[i] is its
weight. This follows the shipped client schema and the existing Adventure
reward resolver. Unknown element kinds fail closed.
"""
from __future__ import annotations

import secrets

from client_config import table
from pet_config import acquisition_skill_pools


class RewardConfigError(ValueError):
    pass


_KINDS = {1: "g_cash", 2: "m_cash", 3: "item", 4: "exp", 5: "pet", 11: "goldCoin"}


def reward_options(reward_id: int) -> list[tuple[int, dict]]:
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
    return [(weight, resolve_award_element(element_id, amount))
            for element_id, amount, weight in zip(element_ids, amounts, weights) if weight > 0]


def resolve_reward(reward_id: int, *, draw: int | None = None) -> dict | None:
    if reward_id == 0:
        return None
    options = reward_options(reward_id)
    total = sum(weight for weight, _ in options)
    if draw is None:
        draw = secrets.randbelow(total)
    if type(draw) is not int or not 0 <= draw < total:
        raise ValueError("reward draw is outside the configured weight range")
    for weight, reward in options:
        if draw < weight:
            return reward
        draw -= weight


def selectable_reward(box_id: int, selection: int, displayed_amount: int) -> dict:
    box = table("SelectableAwardInfo").get(box_id)
    if not box or len(box["elements"]) != len(box["nums"]) or not 0 <= selection < len(box["nums"]):
        raise RewardConfigError(f"invalid selection for SelectableAwardInfo id {box_id}")
    amount = box["nums"][selection]
    if displayed_amount != amount:
        raise RewardConfigError(f"amount does not match SelectableAwardInfo id {box_id}")
    return resolve_award_element(box["elements"][selection], amount, pet_gene=True)


def resolve_award_element(element_id: int, amount: int, *, pet_gene: bool = False) -> dict:
    if type(amount) is not int or amount <= 0:
        raise RewardConfigError(f"invalid amount for AwardElementInfo id {element_id}")
    element = table("AwardElementInfo").get(element_id)
    if element is None:
        raise RewardConfigError(f"missing AwardElementInfo id {element_id}")
    kind = _KINDS.get(element["elementType"])
    if kind is None:
        raise RewardConfigError(
            f"unsupported AwardElementInfo type {element['elementType']} (id {element_id})")
    target = int(element["elementID"])
    if kind in ("g_cash", "m_cash", "exp", "goldCoin"):
        target = 0
    elif kind == "item":
        if target <= 0 or table("ItemInfo").get(target) is None:
            raise RewardConfigError(f"unknown reward item id {target}")
    elif kind == "pet":
        if pet_gene:
            gene = table("GeneInfo").get(target)
            if not gene:
                raise RewardConfigError(f"missing reward Pet gene id {target}")
            target = gene["petID"]
        try:
            acquisition_skill_pools(target)
        except ValueError as exc:
            raise RewardConfigError(f"invalid Pet reward template {target}: {exc}") from exc
    return {"kind": kind, "id": target, "num": amount}
