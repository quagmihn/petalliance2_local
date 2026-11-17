"""Dry-run-first, target-locked compatibility migration for legacy Pet JSONB.

Only fills missing starter skill slots and an empty passive collection using
the selected Pet's GeneInfo/GeneProbabilityInfo configuration. Existing Pet
identity, level, EXP, star, Stage, evolution, formation and equipment are never
updated. Production character 6/2 is deliberately apply-blocked pending a
separate approved migration plan.
"""
from __future__ import annotations

import argparse
import asyncio
import hashlib
import json
import os
import random
import sys
import tempfile
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from db.database import Database
from handlers.pet import pet_json
from pet_config import gene, json_value, skill_choices

ROOT = Path(__file__).resolve().parents[2]
BACKUP_DIR = ROOT / "artifacts/pet-compat-20261118/backups"
PET_COLUMNS = ("pet_uid", "char_id", "pet_template_id", "nickname", "level", "exp",
               "star", "evolution", "slot_index", "skills_json", "equips_json",
               "training_stage", "passive_skills_json")
MUTABLE_COLUMNS = ("skills_json", "passive_skills_json")
ALLOWED_DATABASES = {"monster2_test_db", "monster2_db"}


def _decode_json_value(value):
    """Decode JSONB arrays and legacy JSONB strings containing JSON arrays."""
    if isinstance(value, str):
        try:
            return json.loads(value)
        except json.JSONDecodeError as exc:
            raise ValueError("invalid JSONB string") from exc
    return value


def _stable_rng(pet_uid: int, template_id: int, slot: str):
    seed = hashlib.sha256(f"monster2-pet-migration:{pet_uid}:{template_id}:{slot}".encode()).digest()
    return random.Random(int.from_bytes(seed[:8], "little"))


def _weighted_choice(group: int, rng: random.Random, excluded: set[int]) -> int:
    choices = [(weight, skill_id) for weight, skill_id in skill_choices(group)
               if skill_id == 0 or skill_id not in excluded]
    total = sum(weight for weight, _ in choices)
    if total <= 0:
        raise ValueError(f"skill group {group} has no unique configured choices")
    draw = rng.randrange(total)
    for weight, skill_id in choices:
        if draw < weight:
            return skill_id
        draw -= weight
    raise AssertionError("weighted selection exhausted")


def reconstruct_starting_skills(pet_uid: int, template_id: int, raw):
    existing = _decode_json_value(raw)
    if existing is None:
        existing = []
    if not isinstance(existing, list) or len(existing) > 4:
        raise ValueError("active skills must be a JSON array of at most four slots")
    if any(type(skill) is not int or skill < 0 for skill in existing):
        raise ValueError("active skill slots must contain nonnegative integers")
    _gene_id, groups, _passives = gene(template_id)  # rejects unknown templates
    slots = list(existing)
    used = {skill for skill in slots if skill}
    for index in range(len(slots), 4):
        skill = _weighted_choice(groups[index], _stable_rng(pet_uid, template_id, f"active:{index}"), used)
        slots.append(skill)
        if skill:
            used.add(skill)
    if slots[0] == 0:
        skill = _weighted_choice(groups[0], _stable_rng(pet_uid, template_id, "active:0"), used - {0})
        if skill == 0:
            raise ValueError("configured basic attack resolved to empty skill")
        slots[0] = skill
    return slots


def reconstruct_passive_skills(pet_uid: int, template_id: int, raw):
    existing = _decode_json_value(raw)
    if existing is None:
        existing = []
    if not isinstance(existing, list):
        raise ValueError("passive skills must be a JSON array")
    if existing:
        return existing
    _gene_id, _groups, passive_groups = gene(template_id)
    output, used = [], set()
    for index, item in enumerate(passive_groups):
        skill = _weighted_choice(
            item["paSkillID"], _stable_rng(pet_uid, template_id, f"passive:{index}"), used)
        output.append({"paSkillType": item["paSkillType"], "paSkillID": skill})
        if skill:
            used.add(skill)
    return output


def make_pet_payload(row, skills=None, passives=None):
    data = {key: row[key] for key in row.keys()} if hasattr(row, "keys") else dict(row)
    if skills is not None:
        data["skills_json"] = skills
    if passives is not None:
        data["passive_skills_json"] = passives
    # pet_json consumes the exact DB column names and applies client schema validation.
    pet_json(data)


def plan_rows(rows):
    plans = []
    for row in rows:
        skills_raw = row["skills_json"]
        passives_raw = row["passive_skills_json"]
        skills = reconstruct_starting_skills(row["pet_uid"], row["pet_template_id"], skills_raw)
        passives = reconstruct_passive_skills(row["pet_uid"], row["pet_template_id"], passives_raw)
        decoded_skills, decoded_passives = _decode_json_value(skills_raw), _decode_json_value(passives_raw)
        # Avoid rewriting a database value already equivalent to the planned collections.
        changed = decoded_skills != skills or decoded_passives != passives
        make_pet_payload(row, skills, passives)
        before = {key: row[key] for key in PET_COLUMNS}
        after = dict(before, skills_json=skills, passive_skills_json=passives)
        plans.append({"pet_uid": row["pet_uid"], "before": before,
                      "after": after, "changed": changed})
    return plans


def _write_backup(path: Path, content: dict):
    path.parent.mkdir(parents=True, exist_ok=True)
    payload = json.dumps(content, ensure_ascii=False, sort_keys=True, indent=2, default=str).encode()
    fd = os.open(path, os.O_WRONLY | os.O_CREAT | os.O_EXCL, 0o600)
    with os.fdopen(fd, "wb") as stream:
        stream.write(payload)
        stream.flush()
        os.fsync(stream.fileno())


def _backup_path(database: str, account_id: int, char_id: int):
    return BACKUP_DIR / f"{database}-account{account_id}-char{char_id}-{os.getpid()}.json"


async def _identity(db):
    return await db.pool.fetchrow(
        "SELECT current_database() AS database,current_user AS role,"
        "inet_server_addr() AS host,inet_server_port() AS port,"
        "(SELECT rolsuper FROM pg_roles WHERE rolname=current_user) AS superuser")


async def _target_rows(db, account_id: int, char_id: int):
    async with db.pool.acquire() as conn:
        owner = await conn.fetchrow(
            "SELECT account_id,char_id FROM characters WHERE char_id=$1", char_id)
        if owner is None or owner["account_id"] != account_id:
            raise ValueError("explicit account/character pair does not match")
        return await conn.fetch("SELECT * FROM pets WHERE char_id=$1 ORDER BY slot_index,pet_uid", char_id)


async def apply_plan(db, database: str, account_id: int, char_id: int, plans, backup_path: Path):
    content = {"version": 1, "database": database, "account_id": account_id,
               "char_id": char_id, "plans": plans,
               "changed_fields": list(MUTABLE_COLUMNS)}
    _write_backup(backup_path, content)
    async with db.pool.acquire() as conn:
        async with conn.transaction():
            owner = await conn.fetchrow(
                "SELECT account_id FROM characters WHERE char_id=$1 FOR UPDATE", char_id)
            if owner is None or owner["account_id"] != account_id:
                raise ValueError("target character changed before apply")
            current = await conn.fetch("SELECT * FROM pets WHERE char_id=$1 ORDER BY slot_index,pet_uid FOR UPDATE", char_id)
            if [row["pet_uid"] for row in current] != [plan["pet_uid"] for plan in plans]:
                raise ValueError("Pet set changed after dry-run; refusing apply")
            for row, plan in zip(current, plans):
                if any(_decode_json_value(row[key]) != _decode_json_value(plan["before"][key])
                       for key in MUTABLE_COLUMNS):
                    raise ValueError(f"Pet UID {row['pet_uid']} changed after dry-run")
                if plan["changed"]:
                    await conn.execute(
                        "UPDATE pets SET skills_json=$2::jsonb,passive_skills_json=$3::jsonb WHERE pet_uid=$1",
                        row["pet_uid"], json.dumps(plan["after"]["skills_json"]),
                        json.dumps(plan["after"]["passive_skills_json"]))
    return backup_path


async def rollback(db, database: str, account_id: int, char_id: int, backup_path: Path):
    content = json.loads(backup_path.read_text())
    if (content.get("database"), content.get("account_id"), content.get("char_id")) != (
            database, account_id, char_id):
        raise ValueError("backup target does not match explicit target")
    async with db.pool.acquire() as conn:
        async with conn.transaction():
            owner = await conn.fetchrow(
                "SELECT account_id FROM characters WHERE char_id=$1 FOR UPDATE", char_id)
            if owner is None or owner["account_id"] != account_id:
                raise ValueError("explicit account/character pair does not match")
            for plan in content["plans"]:
                if not plan["changed"]:
                    continue
                current = await conn.fetchrow("SELECT * FROM pets WHERE pet_uid=$1 AND char_id=$2 FOR UPDATE",
                                              plan["pet_uid"], char_id)
                if current is None:
                    raise ValueError(f"Pet UID {plan['pet_uid']} no longer exists")
                if any(_decode_json_value(current[key]) != _decode_json_value(plan["after"][key])
                       for key in MUTABLE_COLUMNS):
                    raise ValueError(f"Pet UID {plan['pet_uid']} changed since migration; refusing rollback")
                await conn.execute(
                    "UPDATE pets SET skills_json=$2::jsonb,passive_skills_json=$3::jsonb WHERE pet_uid=$1",
                    plan["pet_uid"], json.dumps(_decode_json_value(plan["before"]["skills_json"])),
                    json.dumps(_decode_json_value(plan["before"]["passive_skills_json"])))


async def run(args):
    if args.database not in ALLOWED_DATABASES:
        raise ValueError("database must be explicitly monster2_test_db or monster2_db")
    if args.account_id <= 0 or args.char_id <= 0:
        raise ValueError("account and character IDs must be positive")
    if args.database == "monster2_db" and (args.account_id, args.char_id) == (6, 2) and args.apply:
        raise ValueError("production account 6 / character 2 apply is blocked pending separate approval")
    dsn = os.environ.get(args.dsn_env)
    if not dsn:
        raise ValueError(f"required DSN environment variable {args.dsn_env} is unset")
    db = await Database.connect(dsn)
    try:
        identity = await _identity(db)
        if identity["database"] != args.database:
            raise ValueError(f"DSN resolved to {identity['database']}, expected {args.database}")
        if identity["superuser"]:
            raise ValueError("refusing to run as PostgreSQL superuser")
        print(json.dumps({key: identity[key] for key in identity.keys()}, default=str))
        if args.rollback:
            if args.apply is False:
                raise ValueError("rollback changes data; pass --apply together with --rollback")
            if args.database != "monster2_test_db":
                raise ValueError("rollback is enabled only for monster2_test_db")
            await rollback(db, args.database, args.account_id, args.char_id, Path(args.rollback))
            print("rollback committed")
            return
        rows = await _target_rows(db, args.account_id, args.char_id)
        plans = plan_rows(rows)
        print(json.dumps([{"pet_uid": item["pet_uid"], "changed": item["changed"],
                           "skills_before": _decode_json_value(item["before"]["skills_json"]),
                           "skills_after": item["after"]["skills_json"],
                           "passive_before": _decode_json_value(item["before"]["passive_skills_json"]),
                           "passive_after": item["after"]["passive_skills_json"]}
                          for item in plans], ensure_ascii=False))
        if not args.apply:
            print("dry-run only; no database changes made")
            return
        if args.database != "monster2_test_db":
            raise ValueError("apply is enabled only for monster2_test_db; prepare production separately")
        path = Path(args.backup_file) if args.backup_file else _backup_path(
            args.database, args.account_id, args.char_id)
        await apply_plan(db, args.database, args.account_id, args.char_id, plans, path)
        print(f"migration committed; backup={path}")
    finally:
        await db.close()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--database", required=True, choices=sorted(ALLOWED_DATABASES))
    parser.add_argument("--dsn-env", required=True,
                        help="name of the environment variable containing the explicit DB DSN")
    parser.add_argument("--account-id", required=True, type=int)
    parser.add_argument("--char-id", required=True, type=int)
    parser.add_argument("--apply", action="store_true", help="apply test DB changes; dry-run is default")
    parser.add_argument("--backup-file")
    parser.add_argument("--rollback", help="restore JSONB skill fields from a prior backup")
    args = parser.parse_args()
    try:
        asyncio.run(run(args))
    except Exception as exc:
        parser.error(str(exc))


if __name__ == "__main__":
    main()
