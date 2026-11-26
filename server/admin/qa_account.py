"""Prepare Pet/VIP QA state or explicitly manage a named local VIP rank."""
import argparse
import asyncio
import json
import os
import subprocess
import sys
from collections import Counter
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

from character_values import validate_character_values
from db.database import Database
from pet_config import acquisition_skill_pools, insert_owned_pet, star_steps
from vip_config import max_vip


async def star_materials(conn, char, uid, apply):
    char_id = char["char_id"]
    target = await conn.fetchrow(
        "SELECT * FROM pets WHERE char_id=$1 AND pet_uid=$2 FOR UPDATE", char_id, uid)
    if target is None:
        raise ValueError("Pet does not belong to the targeted character")
    steps = star_steps(target["pet_template_id"])
    remaining = steps[target["star"]:]
    items = Counter()
    pets = Counter()
    for step in remaining:
        items[step.item] += step.count
        pets[step.pet] += step.pet_count
    bag = dict(await conn.fetch("SELECT item_id,count FROM inventory WHERE char_id=$1", char_id))
    reserves = dict(await conn.fetch(
        """SELECT pet_template_id,count(*) FROM pets p
           WHERE char_id=$1 AND pet_uid<>$2 AND pet_uid<>1 AND slot_index=-1
             AND equips_json IN ('[]'::jsonb,'{}'::jsonb)
             AND NOT EXISTS (SELECT 1 FROM tutorial_battle_sessions b WHERE b.char_id=p.char_id
                 AND (b.captured_pet_uid=p.pet_uid OR
                     (b.state='started' AND p.pet_uid=ANY(b.fighter_uids))))
           GROUP BY pet_template_id""", char_id, uid))
    items_to_add = {item: count - bag.get(item, 0) for item, count in items.items() if count > bag.get(item, 0)}
    pets_to_add = {pet: count - reserves.get(pet, 0) for pet, count in pets.items() if count > reserves.get(pet, 0)}
    for template in pets_to_add:
        acquisition_skill_pools(template)
    limits = validate_character_values(["itemPacketNum", "petPacketNum"], json.loads(char["game_values"]))
    occupied_pets = await conn.fetchval("SELECT count(*) FROM pets WHERE char_id=$1", char_id)
    if (len(set(bag) | items_to_add.keys()) > limits["itemPacketNum"]
            or occupied_pets + sum(pets_to_add.values()) > limits["petPacketNum"]):
        raise ValueError("QA materials exceed the configured bag or Pet capacity")
    if apply:
        await conn.executemany(
            """INSERT INTO inventory(char_id,item_id,count) VALUES($1,$2,$3)
               ON CONFLICT(char_id,item_id) DO UPDATE SET count=inventory.count+EXCLUDED.count""",
            [(char_id, item, count) for item, count in items_to_add.items()])
        for template, count in pets_to_add.items():
            for _ in range(count):
                await insert_owned_pet(conn, char_id, template)
    return {"pet_uid": uid, "template": target["pet_template_id"], "stars": target["star"],
            "maximum": len(steps), "stage": target["training_stage"],
            "required_stages": [step.stage for step in remaining], "items_required": items,
            "pets_required": pets, "items_to_add": items_to_add, "pets_to_add": pets_to_add}


async def run(args):
    play = args.action == "vip-max" and args.play
    env_key = "MONSTER2_VIP_PLAY_DATABASE_URL" if play else "TEST_DATABASE_URL"
    if not os.getenv(env_key):
        raise ValueError(f"{env_key} is required")
    if play and args.apply:
        if not args.restored_dump or not args.rollback_file:
            raise ValueError("play apply requires a restored production dump and a new rollback file")
        archive = subprocess.run(["pg_restore", "--list", args.restored_dump], check=True,
                                 text=True, capture_output=True)
        if not any(line.strip() == ";     dbname: monster2_db" for line in archive.stdout.splitlines()):
            raise ValueError("the supplied dump does not identify monster2_db")
    db = await Database.connect(os.environ[env_key])
    try:
        async with db.pool.acquire() as conn, conn.transaction():
            database, role, superuser = await conn.fetchrow(
                "SELECT current_database(), current_user, rolsuper FROM pg_roles WHERE rolname=current_user")
            expected_db = "monster2_db" if play else "monster2_test_db"
            if database != expected_db or superuser or (play and role != "monster2"):
                raise ValueError(f"expected {expected_db} and its non-superuser game role")
            char = await conn.fetchrow(
                "SELECT * FROM characters WHERE char_id=$1 AND account_id=$2 FOR UPDATE",
                args.char_id, args.account_id)
            if char is None:
                raise ValueError("No matching account and character in the test database")
            if args.action == "pet-star-materials":
                result = await star_materials(conn, char, args.pet_uid, args.apply)
            else:
                row = max_vip()
                result = {"before": {"vip_level": char["vip_level"], "vip_points": char["vip_points"]},
                          "after": {"vip_level": row["viplevel"],
                                    "vip_points": max(char["vip_points"], row["recharge"])}}
                identity = {"database": database, "account_id": args.account_id, "char_id": args.char_id}
                if args.rollback:
                    backup = json.loads(Path(args.rollback).read_text())
                    if (any(backup.get(key) != value for key, value in identity.items())
                            or result["before"] != backup["after"]
                            or char["recharge_total"] != backup["recharge_total"]
                            or json.loads(char["game_values"]).get("vip_local_awards", []) != backup["claimed"]):
                        raise ValueError("character identity, VIP state, purchases or claims changed after apply")
                    result["after"] = backup["before"]
                if args.apply and args.rollback_file:
                    flags = os.O_WRONLY | os.O_CREAT | os.O_EXCL
                    with os.fdopen(os.open(args.rollback_file, flags, 0o600), "w") as backup:
                        json.dump({**identity, **result, "recharge_total": char["recharge_total"],
                                   "claimed": json.loads(char["game_values"]).get("vip_local_awards", [])}, backup)
                        backup.flush()
                        os.fsync(backup.fileno())
                if args.apply or args.rollback:
                    await conn.execute(
                        "UPDATE characters SET vip_level=$2,vip_points=$3 WHERE char_id=$1",
                        args.char_id, result["after"]["vip_level"], result["after"]["vip_points"])
        print(json.dumps({"database": database, "account_id": args.account_id, "char_id": args.char_id,
                          "apply": args.apply, **result}, sort_keys=True))
    finally:
        await db.close()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    sub = parser.add_subparsers(dest="action", required=True)
    star = sub.add_parser("pet-star-materials")
    star.add_argument("--pet-uid", type=int, required=True)
    star.add_argument("--to-max", action="store_true", required=True)
    vip = sub.add_parser("vip-max")
    vip.add_argument("--play", action="store_true", help="explicitly select the named local playing account")
    vip.add_argument("--restored-dump", help="production dump whose restore you have already validated")
    vip.add_argument("--rollback-file", help="write a new file containing the original VIP state")
    for mode in (star, vip):
        mode.add_argument("--account-id", type=int, required=True)
        mode.add_argument("--char-id", type=int, required=True)
        write = mode.add_mutually_exclusive_group()
        write.add_argument("--apply", action="store_true")
        write.add_argument("--dry-run", action="store_true")
        if mode is vip:
            write.add_argument("--rollback", help="restore a VIP snapshot if purchases and claims are unchanged")
    try:
        asyncio.run(run(parser.parse_args()))
    except (OSError, ValueError, KeyError, subprocess.CalledProcessError) as exc:
        parser.error(str(exc))


if __name__ == "__main__":
    main()
