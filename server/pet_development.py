"""Stat training and Relation rules from the installed APK tables."""
import json
import math

from client_config import table

ATTRIBUTES = ("hpx", "atk", "def", "satk", "sdef", "speed")
RACE = ("lifeRateValue", "atkRateValue", "defRateValue", "satkRateValue", "sdefRateValue", "speedRateValue")
OVERFLOW = {"oall": 70001, "ohp": 70004, "ospeed": 70005, "osatk": 70006,
            "oatk": 70007, "osdef": 70008, "odef": 70009}
OVERFLOW_FOR = dict(zip(ATTRIBUTES, ("ohp", "oatk", "odef", "osatk", "osdef", "ospeed"), strict=True))


def state(row):
    raw = row.get("development_json", {})
    return json.loads(raw) if isinstance(raw, str) else raw


def max_points(template_id):
    grade = table("PokemonInfo")[template_id]["rarePoint"]
    return table("GlobalConfigAddInfo")[13000 + grade]["values"][0]


def totals(row, saved):
    config = table("GlobalConfigAddInfo")
    total = max_points(row["pet_template_id"]) + saved.get("oall", 0) * config[70002]["values"][0]
    base = table("ExperienceInfo")[row["level"]]["petSingleAttrStrengthenMax"]
    limits = {key: base + saved.get(OVERFLOW_FOR[key], 0) * config[70003]["values"][0]
              for key in ATTRIBUTES}
    return total, limits


def overflow_materials():
    return {item for key in OVERFLOW.values() for item in table("GlobalConfigAddInfo")[key]["values"][::2]}


def stats(row, saved):
    pokemon = table("PokemonInfo")[row["pet_template_id"]]
    level, stage, star = row["level"], row["training_stage"], row["star"]
    factor = 1 + star * table("GlobalConfigAddInfo")[12000]["values"][0] / 100
    hp_factor = 2.5 + 4.5 * level / 50
    yoke = saved.get("yoke", {}).get("yokeValues", [0] * 16)
    values = []
    for i, key in enumerate(RACE):
        race = pokemon[key]
        basic = race + race / 12 * level + 3 * saved.get(ATTRIBUTES[i], 0) + race * 3 / 40 * stage
        values.append(math.floor(basic * factor * (hp_factor if i == 0 else 1) + yoke[i]))
    return values[0], math.floor(values[0] / hp_factor + sum(values[1:]))


def yoke_values(detail, pets):
    positions = table("YokeEffectPos")
    scores = table("YokeScore")
    effects = table("YokeEffect")
    species = table("PokemonInfo")
    result = [0] * 16
    for key, slots in detail.items():
        if not all(slots):
            continue
        plan = table("YokeInfo")[int(key)]
        star = min(5, *(pets[uid]["star"] for uid in slots))
        score = sum(scores[species[pet]["rarePoint"]]["scores"][star] for pet in plan["pets"])
        position = positions[plan["attribType"]]["pos"] - 1
        result[position] += round(effects[score]["effectValues"][position], 6)
    return result
