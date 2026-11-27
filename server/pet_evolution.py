"""Evolution routes, costs and skill choices from the target APK."""
from collections import Counter
from functools import cache
import secrets

from client_config import ROOT, table
from pet_config import is_star_material, skill_choices


def branches(template):
    return table("PetEvoInfo").get(template, {}).get("PetEvoLevelInfoVec", ())


def is_super(route):
    # PetEducationMgr selects the request based on the first previewed form.
    return route["EvoRateInfoVec"][0]["newRace"] >= 20000


@cache
def validate_route(template, choice):
    route = branches(template)[choice - 1]
    species = table("PokemonInfo")
    consumables = table("ConsumeElementInfo")
    items = table("ItemInfo")
    if not 0 < route["level"] <= species[template]["topLevel"]:
        raise ValueError("invalid evolution level requirement")
    if not route["stageCons"] or not route["EvoRateInfoVec"]:
        raise ValueError("missing evolution costs or outcomes")
    for key in route["stageCons"]:
        part = consumables[key]
        if (part["num"] <= 0 or part["elementType"] not in (1, 2, 3)
                or (part["elementType"] == 3 and part["elementID"] not in items)):
            raise ValueError(f"invalid evolution cost {key}")
    for outcome in route["EvoRateInfoVec"]:
        new = outcome["newRace"]
        row = species[new]
        skin = f"{int(row['fightSkin']):03d}"
        assets = ROOT / "unpacked/assets/res"
        if (outcome["rate"] <= 0 or new == template or is_star_material(new)
                or (new >= 20000) != is_super(route)
                or not (assets / f"Pet/PetIcon/{int(row['icon'])}.png").is_file()
                or not all((assets / f"Spine/pet/{skin}{ext}").is_file()
                           for ext in (".png", ".skel", ".atlas", "b.png", "b.skel", "b.atlas"))):
            raise ValueError(f"invalid evolution outcome {new}")
    return route


def evolution_costs(route):
    costs = Counter()
    consumables = table("ConsumeElementInfo")
    for key in route["stageCons"]:
        entry = consumables[key]
        costs[entry["elementType"], entry["elementID"]] += entry["num"]
    return costs


def weighted_choice(entries):
    weight = secrets.randbelow(sum(rate for rate, _ in entries))
    for rate, value in entries:
        if weight < rate:
            return value
        weight -= rate


def choices_for(entry):
    skills = table("PetSkillInfo")
    return [(weight, skill) for weight, skill in skill_choices(entry["skillArrID"])
            if weight > 0 and skill in skills and skills[skill]["skill_A_Type"] == entry["skillType"]]


def new_skills(outcome):
    result = []
    for entry in outcome["EvoSkillVec"]:
        choices = choices_for(entry)
        if choices:
            result.append({**entry, "skillArrID": weighted_choice(choices)})
    return result


def inspect_catalog(level):
    xp = table("ExperienceInfo")
    target, prior = xp[level]["petExpVec"], xp[level - 1]["petExpVec"]
    if len(target) != 6 or len(prior) != 6 or not all(0 < lo < hi for lo, hi in zip(prior, target, strict=True)):
        raise ValueError(f"invalid Pet EXP thresholds at level {level}")
    counts = Counter()
    blocked = {}
    blocked_optional = 0
    for template in table("PetEvoInfo"):
        for choice, route in enumerate(branches(template), 1):
            try:
                validate_route(template, choice)
            except (KeyError, ValueError) as exc:
                blocked[f"{template}/{choice}"] = str(exc)
                continue
            counts["super" if is_super(route) else "ordinary"] += 1
            blocked_optional += sum(not choices_for(entry) for outcome in route["EvoRateInfoVec"]
                                    for entry in outcome["EvoSkillVec"])
    if not counts:
        raise ValueError("no usable Pet evolution routes")
    return {"routes": dict(counts), "blocked": blocked, "unusable_optional_skills": blocked_optional,
            "verified_exp_level": level, "required_exp_by_grade": prior}
