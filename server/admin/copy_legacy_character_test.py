"""Copy production character state into a newly allocated isolated test account.

Dry-run by default. Production is read only; all inserts and optional device
binding changes are restricted to monster2_test_db. Credentials are replaced
with random test-only values, while gameplay data and foreign-key relationships
are copied with explicit source-to-fixture ID maps.
"""
from __future__ import annotations

import argparse
import asyncio
import json
import os
import secrets
import sys
import uuid
from datetime import date, datetime
from pathlib import Path

import asyncpg

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "server"))
ARTIFACTS = ROOT / "artifacts/legacy-pet-compat-20261118"
SOURCE_CONNECT = {"database": "monster2_db", "user": "monster2",
                  "host": "/run/postgresql", "port": 5432}


def encode(value):
    if isinstance(value, (datetime, date)):
        return value.isoformat()
    raise TypeError(type(value).__name__)


def backup(path: Path, value: dict):
    path.parent.mkdir(parents=True, exist_ok=True)
    fd = os.open(path, os.O_WRONLY | os.O_CREAT | os.O_EXCL, 0o600)
    with os.fdopen(fd, "w", encoding="utf-8") as stream:
        json.dump(value, stream, ensure_ascii=False, sort_keys=True, indent=2, default=encode)
        stream.flush()
        os.fsync(stream.fileno())


async def identities(source, target):
    src = await source.fetchrow(
        "SELECT current_database() db,current_user role,"
        "(SELECT rolsuper FROM pg_roles WHERE rolname=current_user) superuser")
    dst = await target.fetchrow(
        "SELECT current_database() db,current_user role,"
        "(SELECT rolsuper FROM pg_roles WHERE rolname=current_user) superuser")
    if (src["db"], dst["db"]) != ("monster2_db", "monster2_test_db"):
        raise ValueError(f"database target mismatch: source={src['db']} target={dst['db']}")
    if src["superuser"] or dst["superuser"]:
        raise ValueError("refusing superuser connections")
    return dict(src), dict(dst)


async def snapshot(source, account_id, char_id):
    async with source.transaction(readonly=True):
        owner = await source.fetchrow(
            "SELECT * FROM characters WHERE account_id=$1 AND char_id=$2", account_id, char_id)
        if owner is None:
            raise ValueError("source account/character pair does not exist")
        rows = {}
        for table, sql in {
            "pets": "SELECT * FROM pets WHERE char_id=$1 ORDER BY pet_uid",
            "inventory": "SELECT * FROM inventory WHERE char_id=$1 ORDER BY item_id",
            "quests": "SELECT * FROM quests WHERE char_id=$1 ORDER BY quest_id",
            "character_adventures": "SELECT * FROM character_adventures WHERE char_id=$1",
            "adventure_cell_claims": "SELECT * FROM adventure_cell_claims WHERE char_id=$1 ORDER BY adventure_id,floor,map_col,map_row",
            "homes": "SELECT * FROM homes WHERE char_id=$1",
            "tutorial_battle_sessions": "SELECT * FROM tutorial_battle_sessions WHERE char_id=$1 ORDER BY battle_id",
        }.items():
            rows[table] = [dict(row) for row in await source.fetch(sql, char_id)]
        return dict(owner), rows


async def insert_row(conn, table, values, omit):
    data = {key: value for key, value in values.items() if key not in omit}
    columns = list(data)
    sql = (f"INSERT INTO {table} ({','.join(columns)}) VALUES "
           f"({','.join(f'${index}' for index in range(1, len(columns)+1))}) RETURNING *")
    return await conn.fetchrow(sql, *[data[key] for key in columns])


async def create_fixture(args):
    source = await asyncpg.connect(**SOURCE_CONNECT)
    target = await asyncpg.connect(os.environ[args.test_dsn_env])
    manifest_path = Path(args.manifest) if args.manifest else ARTIFACTS / f"legacy-copy-{uuid.uuid4().hex}.json"
    try:
        src_identity, dst_identity = await identities(source, target)
        source_char, related = await snapshot(source, args.account_id, args.char_id)
        device_backup = None
        if args.device_id:
            device_backup = await target.fetchrow(
                "SELECT device_id,world_id,device_token,account_id,created_at "
                "FROM device_bindings WHERE device_id=$1 AND world_id=$2",
                args.device_id, source_char["world_id"])
            if device_backup is None:
                raise ValueError("explicit test device binding was not found")
        summary = {"source": {"database": src_identity["db"], "role": src_identity["role"],
                              "account_id": args.account_id, "char_id": args.char_id},
                   "target": {"database": dst_identity["db"], "role": dst_identity["role"]},
                   "rows": {"characters": 1, **{key: len(value) for key, value in related.items()}},
                   "device_binding_will_move": bool(args.device_id), "manifest": str(manifest_path)}
        if not args.apply:
            print(json.dumps(summary, default=encode, sort_keys=True))
            return
        username = "legacy-copy-" + secrets.token_hex(10)
        account_token = secrets.token_hex(24)
        new_name = f"{source_char['name']}-legacy"
        fixture = {"version": 1, "database": "monster2_test_db", "username": username,
                   "account_token": account_token, "source_account_id": args.account_id,
                   "source_char_id": args.char_id, "device_binding_before": dict(device_backup) if device_backup else None}
        async with target.transaction():
            account = await target.fetchrow(
                "INSERT INTO accounts(username,token) VALUES($1,$2) RETURNING user_id",
                username, account_token)
            new_account_id = account["user_id"]
            char_data = dict(source_char)
            char_data["name"] = new_name
            char_data["account_id"] = new_account_id
            char_data.pop("char_id")
            new_char = await insert_row(target, "characters", char_data, set())
            new_char_id = new_char["char_id"]
            fixture.update(account_id=new_account_id, char_id=new_char_id,
                           char_name=new_name,
                           mappings={"pet_uid": {}, "inventory_id": {}, "quest_row_id": {},
                                     "battle_id": {}}, row_counts=summary["rows"])
            for pet in related["pets"]:
                old_uid = pet["pet_uid"]
                row = await insert_row(target, "pets", dict(pet, char_id=new_char_id), {"pet_uid"})
                fixture["mappings"]["pet_uid"][str(old_uid)] = row["pet_uid"]
            for table, id_column in (("inventory", "id"), ("quests", "id")):
                for item in related[table]:
                    row = await insert_row(target, table, dict(item, char_id=new_char_id), {id_column})
                    map_name = "inventory_id" if table == "inventory" else "quest_row_id"
                    fixture["mappings"][map_name][str(item[id_column])] = row[id_column]
            for claim in related["adventure_cell_claims"]:
                await insert_row(target, "adventure_cell_claims", dict(claim, char_id=new_char_id), set())
            for table in ("character_adventures", "homes"):
                for item in related[table]:
                    await insert_row(target, table, dict(item, char_id=new_char_id), set())
            for battle in related["tutorial_battle_sessions"]:
                row = await insert_row(target, "tutorial_battle_sessions",
                                       dict(battle, char_id=new_char_id), {"battle_id"})
                fixture["mappings"]["battle_id"][str(battle["battle_id"])] = row["battle_id"]
            if device_backup:
                fixture["device_binding_after"] = dict(device_backup, account_id=new_account_id)
                await target.execute(
                    "UPDATE device_bindings SET account_id=$3 WHERE device_id=$1 AND world_id=$2",
                    args.device_id, source_char["world_id"], new_account_id)
            fixture["identity"] = dst_identity
            fixture["manifest"] = str(manifest_path)
            backup(manifest_path, fixture)
        print(json.dumps({**summary, "account_id": new_account_id, "char_id": new_char_id,
                          "pet_uid_map": fixture["mappings"]["pet_uid"]},
                         default=encode, sort_keys=True))
    finally:
        await source.close(); await target.close()


async def rollback_fixture(args):
    target = await asyncpg.connect(os.environ[args.test_dsn_env])
    try:
        identity = await target.fetchrow(
            "SELECT current_database() db,current_user role,"
            "(SELECT rolsuper FROM pg_roles WHERE rolname=current_user) superuser")
        if identity["db"] != "monster2_test_db" or identity["superuser"]:
            raise ValueError("rollback requires non-superuser monster2_test_db")
        manifest = json.loads(Path(args.rollback).read_text())
        if manifest.get("database") != identity["db"]:
            raise ValueError("manifest database does not match target")
        async with target.transaction():
            account = await target.fetchrow(
                "SELECT user_id,token FROM accounts WHERE user_id=$1 AND username=$2 FOR UPDATE",
                manifest["account_id"], manifest["username"])
            if account is None:
                print("fixture already absent")
                return
            if account["token"] != manifest["account_token"]:
                raise ValueError("fixture identity changed; refusing rollback")
            previous = manifest.get("device_binding_before")
            if previous:
                current = await target.fetchrow(
                    "SELECT account_id FROM device_bindings WHERE device_id=$1 AND world_id=$2 FOR UPDATE",
                    previous["device_id"], previous["world_id"])
                if current is None or current["account_id"] != manifest["account_id"]:
                    raise ValueError("device binding changed after fixture; refusing rollback")
                await target.execute(
                    "UPDATE device_bindings SET account_id=$3,device_token=$4,created_at=$5 "
                    "WHERE device_id=$1 AND world_id=$2", previous["device_id"],
                    previous["world_id"], previous["account_id"], previous["device_token"],
                    datetime.fromisoformat(previous["created_at"]))
            await target.execute("DELETE FROM accounts WHERE user_id=$1", manifest["account_id"])
        print("test fixture removed; prior test device binding restored")
    finally:
        await target.close()


async def restore_device_binding(args):
    """Restore the original test device mapping without deleting the fixture."""
    target = await asyncpg.connect(os.environ[args.test_dsn_env])
    try:
        identity = await target.fetchrow(
            "SELECT current_database() db,current_user role,"
            "(SELECT rolsuper FROM pg_roles WHERE rolname=current_user) superuser")
        if identity["db"] != "monster2_test_db" or identity["superuser"]:
            raise ValueError("device restoration requires non-superuser monster2_test_db")
        manifest = json.loads(Path(args.restore_device_binding).read_text())
        if manifest.get("database") != identity["db"]:
            raise ValueError("manifest database does not match target")
        previous = manifest.get("device_binding_before")
        if not previous:
            raise ValueError("manifest has no prior test device binding")
        async with target.transaction():
            current = await target.fetchrow(
                "SELECT account_id FROM device_bindings WHERE device_id=$1 AND world_id=$2 FOR UPDATE",
                previous["device_id"], previous["world_id"])
            if current is None or current["account_id"] != manifest["account_id"]:
                raise ValueError("device binding changed since fixture; refusing restoration")
            if await target.fetchval("SELECT 1 FROM accounts WHERE user_id=$1",
                                     previous["account_id"]) is None:
                raise ValueError("prior test account no longer exists")
            await target.execute(
                "UPDATE device_bindings SET account_id=$3,device_token=$4,created_at=$5 "
                "WHERE device_id=$1 AND world_id=$2", previous["device_id"],
                previous["world_id"], previous["account_id"], previous["device_token"],
                datetime.fromisoformat(previous["created_at"]))
        print("prior test device binding restored; copied character retained")
    finally:
        await target.close()


async def create_fresh_control(args):
    target = await asyncpg.connect(os.environ[args.test_dsn_env])
    try:
        identity = await target.fetchrow(
            "SELECT current_database() db,current_user role,"
            "(SELECT rolsuper FROM pg_roles WHERE rolname=current_user) superuser")
        if identity["db"] != "monster2_test_db" or identity["superuser"]:
            raise ValueError("fresh control requires non-superuser monster2_test_db")
        device = None
        if args.device_id:
            device = await target.fetchrow(
                "SELECT device_id,world_id,device_token,account_id,created_at "
                "FROM device_bindings WHERE device_id=$1 AND world_id=1", args.device_id)
            if device is None:
                raise ValueError("explicit test device binding was not found")
        username = "fresh-control-" + secrets.token_hex(10)
        account_token = secrets.token_hex(24)
        char_name = "Fresh" + secrets.token_hex(4)
        manifest_path = Path(args.manifest) if args.manifest else ARTIFACTS / f"fresh-control-{uuid.uuid4().hex}.json"
        if not args.apply:
            print(json.dumps({"database": identity["db"], "role": identity["role"],
                              "character": char_name, "pet_template_id": 7,
                              "device_binding_will_move": bool(args.device_id),
                              "dry_run": True}))
            return
        from pet_config import starting_skills
        skills, passives = starting_skills(7)
        fixture = {"version": 1, "database": "monster2_test_db", "username": username,
                   "account_token": account_token, "device_binding_before": dict(device) if device else None,
                   "fresh_control": True, "char_name": char_name}
        async with target.transaction():
            account = await target.fetchrow(
                "INSERT INTO accounts(username,token) VALUES($1,$2) RETURNING user_id",
                username, account_token)
            character = await target.fetchrow(
                """INSERT INTO characters(account_id,world_id,name,avatar,gender)
                   VALUES($1,1,$2,1,1) RETURNING char_id""", account["user_id"], char_name)
            char_id = character["char_id"]
            pet = await target.fetchrow(
                """INSERT INTO pets(char_id,pet_template_id,slot_index,skills_json,passive_skills_json)
                   VALUES($1,7,0,$2::jsonb,$3::jsonb) RETURNING pet_uid""",
                char_id, json.dumps(skills), json.dumps(passives))
            await target.execute(
                "INSERT INTO quests(char_id,quest_id,status,progress) VALUES($1,1,0,'[0]'::jsonb)",
                char_id)
            await target.execute(
                "INSERT INTO homes(char_id,home_data) VALUES($1,jsonb_build_object('level',1,'homeName',$2::text,'furnitures','{}'::jsonb))",
                char_id, char_name)
            if device:
                await target.execute(
                    "UPDATE device_bindings SET account_id=$3 WHERE device_id=$1 AND world_id=$2",
                    args.device_id, 1, account["user_id"])
            fixture.update(account_id=account["user_id"], char_id=char_id,
                           pet_uid=pet["pet_uid"], device_binding_after=(
                               dict(device, account_id=account["user_id"]) if device else None))
            backup(manifest_path, fixture)
        print(json.dumps({"database": identity["db"], "role": identity["role"],
                          "account_id": fixture["account_id"], "char_id": fixture["char_id"],
                          "pet_uid": fixture["pet_uid"], "pet_template_id": 7,
                          "skills": skills, "manifest": str(manifest_path)}, sort_keys=True))
    finally:
        await target.close()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--account-id", type=int, default=6)
    parser.add_argument("--char-id", type=int, default=2)
    parser.add_argument("--test-dsn-env", default="TEST_DATABASE_URL")
    parser.add_argument("--device-id", help="temporarily bind this existing test device to the copy")
    parser.add_argument("--fresh-control", action="store_true",
                        help="create a fresh test account, character, configured Pet, quest and home")
    parser.add_argument("--manifest")
    parser.add_argument("--apply", action="store_true", help="create test fixture; default is dry-run")
    parser.add_argument("--rollback", help="remove exactly the fixture described by this manifest")
    parser.add_argument("--restore-device-binding", help="restore prior test device mapping, retain fixture")
    args = parser.parse_args()
    if args.restore_device_binding:
        asyncio.run(restore_device_binding(args))
    elif args.rollback:
        asyncio.run(rollback_fixture(args))
    elif args.fresh_control:
        asyncio.run(create_fresh_control(args))
    else:
        asyncio.run(create_fixture(args))


if __name__ == "__main__":
    main()
