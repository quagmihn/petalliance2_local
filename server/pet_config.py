"""Read the same XDat tables used by PokemonInfo and BattleBasicValueCalc."""
import functools
import json
import math
import secrets
import struct
from pathlib import Path
from protocol import Reader

CONFIG = Path(__file__).resolve().parents[1] / "apk_extracted/assets/res/Config"


@functools.cache
def rows(name, config_dir=CONFIG):
    data = Reader((config_dir / (name + ".dat")).read_bytes())
    result = []
    for _ in range(data.u32()):
        size = data.u32()
        result.append(Reader(data.data[data.pos:data.pos + size]))
        data.pos += size
    data.finish()
    return tuple(r.data for r in result)


@functools.cache
def pokemon(template_id):
    for raw in rows("PokemonInfo"):
        r = Reader(raw)
        if r.u32() != template_id:
            continue
        name = r.string(); r.u32(); r.u32()
        fight_skin, icon = r.string(), r.string()
        rare, element1, element2 = r.u32(), r.u32(), r.u32()
        r.string(); r.string()
        rates = [r.u32() for _ in range(6)]
        for _ in range(r.u8()): r.u16()
        top_level = r.u16()
        return dict(name=name, fight_skin=fight_skin, icon=icon, rare=rare,
                    element1=element1, element2=element2, rates=rates, top_level=top_level)
    raise ValueError(f"unknown PokemonInfo template {template_id}")


@functools.cache
def gene(template_id):
    for raw in rows("GeneInfo"):
        r = Reader(raw)
        gene_id, pet_id = r.u32(), r.u32()
        if pet_id != template_id:
            continue
        groups = [r.u32() for _ in range(4)]
        passive = [{"paSkillType": r.u32(), "paSkillID": r.u32()} for _ in range(r.u8())]
        r.finish()
        return gene_id, groups, passive
    raise ValueError(f"unknown GeneInfo template {template_id}")


@functools.cache
def skill_choices(group):
    for raw in rows("GeneProbabilityInfo"):
        r = Reader(raw)
        if r.u32() == group:
            return tuple((r.u32(), r.u32()) for _ in range(r.u8()))
    raise ValueError(f"unknown skill probability group {group}")


@functools.cache
def skill_ids():
    return frozenset(struct.unpack_from("<I", raw)[0] for raw in rows("PetSkillInfo"))


@functools.cache
def acquisition_skill_pools(template_id):
    """Resolve and validate every possible skill before a Pet can be granted."""
    pokemon(template_id)
    _, groups, passive = gene(template_id)
    pools = []
    for index, group in enumerate((*groups, *(entry["paSkillID"] for entry in passive))):
        choices = tuple((weight, skill) for weight, skill in skill_choices(group) if weight > 0)
        if not choices or any((skill == 0 and index == 0) or
                              (skill != 0 and skill not in skill_ids()) for _, skill in choices):
            raise ValueError(f"Pet template {template_id} has invalid starting skill group {group}")
        pools.append(choices)
    return tuple(pools[:len(groups)]), tuple(
        (entry["paSkillType"], choices) for entry, choices in zip(passive, pools[len(groups):]))


def starting_skills(template_id):
    active, passive = acquisition_skill_pools(template_id)

    def choose(choices):
        draw = secrets.randbelow(sum(weight for weight, _ in choices))
        for weight, skill_id in choices:
            if draw < weight:
                return skill_id
            draw -= weight
    return [choose(pool) for pool in active], [
        {"paSkillType": skill_type, "paSkillID": choose(pool)} for skill_type, pool in passive]


def json_value(value):
    return json.loads(value) if isinstance(value, str) else value


def validate_pet(pet):
    for key in ("objID", "pokeID", "level", "Stage", "star", "hpx", "atk", "def", "satk", "sdef", "speed"):
        if type(pet.get(key)) is not int or pet[key] < 0:
            raise ValueError(f"invalid pet field {key}")
    if pet["objID"] <= 0 or pet["level"] < 1:
        raise ValueError("invalid pet identity/level")
    config = pokemon(pet["pokeID"])
    if pet["Stage"] > config["top_level"] // 2:
        raise ValueError("pet Stage exceeds configuration")
    if not isinstance(pet["skills"], list) or len(pet["skills"]) != 4:
        raise ValueError("pet requires four numeric skill slots")
    known_skills = skill_ids()
    for skill in pet["skills"]:
        if type(skill) is not int or (skill != 0 and skill not in known_skills):
            raise ValueError(f"invalid pet skill {skill}")
    if not pet["skills"][0]:
        raise ValueError("pet has no basic attack")
    if not isinstance(pet["equips"], (list, dict)) or not isinstance(pet["paSkills"], list):
        raise ValueError("pet equipment/passive skills must be collections")
    for passive in pet["paSkills"]:
        if (not isinstance(passive, dict) or type(passive.get("paSkillType")) is not int
                or type(passive.get("paSkillID")) is not int
                or (passive["paSkillID"] != 0 and passive["paSkillID"] not in known_skills)):
            raise ValueError("invalid passive skill")
    if pet["hp"] <= 0 or pet["hp"] > pet["hpmax"]:
        raise ValueError("invalid pet HP")


@functools.cache
def star_percent():
    for raw in rows("GlobalConfigAddInfo"):
        r = Reader(raw)
        if r.u32() == 12000:
            r.string()
            return [r.u32() for _ in range(r.u8())][0]
    raise ValueError("missing star multiplier")


def untrained_hp(template_id, level, stage, star=0):
    # BattleBasicValueCalc.calcHp with no individual HP training/equipment/science/skin.
    race = pokemon(template_id)["rates"][0]
    return math.floor((race + race / 12 * level + race * 3 / 40 * stage) * (1 + star * star_percent() / 100) * (2.5 + 4.5 * level / 50))


@functools.cache
def tutorial_monster():
    for raw in rows("MonstrosityInfo"):
        r = Reader(raw)
        if r.u32() != 999996:
            continue
        r.string()
        levels = [r.u32() for _ in range(r.u8())]
        template, stage, star = r.u32(), r.u32(), r.u32()
        modifiers = [r.u32() for _ in range(6)]
        r.u32()
        skills = [[r.u32() for _ in range(r.u8())] for _ in range(3)]
        return dict(level=levels[0], petStage=stage, petStar=star,
                    skill1=skills[0][0], skill2=skills[1][0], skill3=skills[2][0],
                    hp=math.floor(untrained_hp(template, levels[0], stage, star) * modifiers[0] / 1000))
    raise ValueError("missing tutorial monster")
