"""Set a named character's level, VIP and optional local access in one transaction."""
import argparse
import asyncio
import json
import os
from pathlib import Path
import subprocess
import sys

import asyncpg

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from admin.upgrade_character_level import _snapshot, _target_schema, _write_snapshot
from client_config import table


def state(row):
    values = json.loads(row["game_values"])
    return {**{key: row[key] for key in ("level", "exp", "vip_level", "vip_points")},
            "freedom": values.get("local_freedom")}


async def change(dsn, *, expected_db, account, char, name, level, vip, freedom,
                 apply=False, backup_dir=None, rollback=None):
    experience = table("ExperienceInfo")
    vip_row = table("VipInfo").get(vip + 1)
    if level not in experience or not vip_row or vip_row["viplevel"] != vip:
        raise ValueError("level or VIP rank is missing from the target client")
    conn = await asyncpg.connect(dsn)
    try:
        async with conn.transaction(readonly=not (apply or rollback)):
            db, role, superuser = await conn.fetchrow(
                "SELECT current_database(),current_user,rolsuper FROM pg_roles WHERE rolname=current_user")
            if (db != expected_db or superuser or (db == "monster2_db" and role != "monster2")):
                raise ValueError("unexpected database or role")
            target = await conn.fetchrow(
                "SELECT * FROM characters WHERE account_id=$1 AND char_id=$2 AND name=$3"
                + (" FOR UPDATE" if apply or rollback else ""), account, char, name)
            if target is None:
                raise ValueError("account, character ID and exact name did not match")
            before = state(target)
            lower = experience[level - 1]["roleExp"] if level > 1 else 0
            upper = experience[level]["roleExp"]
            exp = min(max(target["exp"], lower), upper - 1)
            after = {"level": level, "exp": exp, "vip_level": vip,
                     "vip_points": max(target["vip_points"], vip_row["recharge"]),
                     "freedom": True if freedom else before["freedom"]}
            identity = {"database": db, "account_id": account, "char_id": char, "name": name}
            if rollback:
                saved = json.loads(rollback.read_text())
                if (saved["identity"] != identity or saved["after"] != before
                        or saved["character"]["recharge_total"] != target["recharge_total"]
                        or json.loads(saved["character"]["game_values"]).get("vip_local_awards") !=
                        json.loads(target["game_values"]).get("vip_local_awards")):
                    raise ValueError("character identity, progression, purchases or VIP claims changed")
                after = saved["before"]
            elif level < target["level"] or vip < target["vip_level"]:
                raise ValueError("this progression operation cannot lower a character's rank or level")
            result = {**identity, "role": role, "before": before, "after": after,
                      "stamina": target["stamina"], "stamina_max": experience[after["level"]]["limitPower"],
                      "changed": False}
            if not (apply or rollback) or after == before:
                return result
            if apply:
                _, dependencies = await _target_schema(conn)
                snapshot = await _snapshot(conn, target, dependencies, level, exp)
                snapshot.update(identity=identity, before=before, after=after)
                result["backup"] = str(_write_snapshot(snapshot, backup_dir))
            values = json.loads(target["game_values"])
            if after["freedom"] is None:
                values.pop("local_freedom", None)
            else:
                values["local_freedom"] = after["freedom"]
            await conn.execute(
                """UPDATE characters SET level=$2,exp=$3,vip_level=$4,vip_points=$5,
                   game_values=$6::jsonb WHERE char_id=$1""",
                char, after["level"], after["exp"], after["vip_level"], after["vip_points"], json.dumps(values))
            result["changed"] = True
            return result
    finally:
        await conn.close()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--database", choices=("monster2_db", "monster2_test_db"), required=True)
    parser.add_argument("--account-id", type=int, required=True)
    parser.add_argument("--char-id", type=int, required=True)
    parser.add_argument("--name", required=True)
    parser.add_argument("--level", type=int, default=50)
    parser.add_argument("--vip", type=int, default=20)
    parser.add_argument("--freedom", action="store_true")
    operations = parser.add_mutually_exclusive_group()
    operations.add_argument("--apply", action="store_true")
    operations.add_argument("--rollback", type=Path)
    parser.add_argument("--backup-dir", type=Path)
    parser.add_argument("--restored-dump", type=Path)
    args = parser.parse_args()
    dsn = os.getenv("DATABASE_URL")
    if not dsn:
        parser.error("explicit DATABASE_URL is required")
    if args.apply and not args.backup_dir:
        parser.error("--apply requires a private --backup-dir")
    if args.apply and args.database == "monster2_db":
        if not args.restored_dump:
            parser.error("--apply on the playing database requires an independently restored dump")
        toc = subprocess.run(["pg_restore", "--list", str(args.restored_dump)],
                             check=True, capture_output=True, text=True).stdout
        if not any(line.split() == [";", "dbname:", "monster2_db"] for line in toc.splitlines()):
            parser.error("the archive does not identify monster2_db")
    result = asyncio.run(change(dsn, expected_db=args.database, account=args.account_id, char=args.char_id,
                                name=args.name, level=args.level, vip=args.vip, freedom=args.freedom,
                                apply=args.apply, backup_dir=args.backup_dir, rollback=args.rollback))
    print(json.dumps(result, indent=2))


if __name__ == "__main__":
    main()
