"""Validation and shaping helpers for the shipped FashionItemInfo catalog."""
from __future__ import annotations

from client_config import table


def default_fashion_ids() -> list[int]:
    config = table("GlobalConfigAddInfo")
    selected = []
    for config_id in (39, 40, 41):
        values = config.get(config_id, {}).get("values", [])
        if not values or values[0] not in table("FashionItemInfo"):
            raise ValueError(f"missing configured starting fashion group {config_id}")
        selected.append(int(values[0]))
    selected.extend([0, 0])
    faces = config.get(69, {}).get("values", [])
    if not faces or faces[0] not in table("FashionItemInfo"):
        raise ValueError("missing configured starting face fashion")
    selected.append(int(faces[0]))
    return selected


def normalize_fashion_ids(values) -> list[int]:
    if not isinstance(values, (list, tuple)) or len(values) > 6:
        raise ValueError("fashion vector must contain at most six slots")
    if any(type(value) is not int or value < 0 for value in values):
        raise ValueError("fashion IDs must be nonnegative integers")
    if any(value and value not in table("FashionItemInfo") for value in values):
        raise ValueError("fashion vector contains an unknown configured ID")
    result = list(values)
    result.extend([0] * (6 - len(result)))
    return result


def initial_fashion_state(values) -> dict:
    current = (normalize_fashion_ids(values) if values and any(values)
               else default_fashion_ids())
    bag = [[] for _ in range(6)]
    for fashion_id in sorted(set(current)):
        if fashion_id == 0:
            continue
        catalog = table("FashionItemInfo")[fashion_id]
        group = fashion_id // 1000
        index = group - 1 if 1 <= group <= 5 else 5
        if fashion_id not in bag[index]:
            bag[index].append(fashion_id)
        # The client considers IDs 1..9999 category 1 only if the hundreds
        # block identifies it; use config ordering category to decide below.
        # Each FashionItemInfo entry belongs to the group encoded in its ID.
        _ = catalog
    return {"curFashion": current, "bag": bag, "defaultFashion": list(current)}


def validate_equipped_fashions(values, fashion_state: dict) -> list[int]:
    current = normalize_fashion_ids(values)
    bag = fashion_state.get("bag") if isinstance(fashion_state, dict) else None
    if not isinstance(bag, list) or len(bag) != 6:
        raise ValueError("stored fashion inventory has invalid schema")
    owned = {item for group in bag if isinstance(group, list)
             for item in group if type(item) is int}
    if any(item and item not in owned for item in current):
        raise ValueError("cannot equip a fashion item not owned by this character")
    return current
