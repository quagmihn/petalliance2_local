"""Explicitly initialize missing legacy skills for one disposable test character."""
import argparse
import asyncio
import json
import os
import sys
from pathlib import Path
sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from db.database import Database
from pet_config import starting_skills, json_value


async def main():
    p = argparse.ArgumentParser()
    p.add_argument("--char-id", type=int, required=True)
    p.add_argument("--apply", action="store_true")
    args = p.parse_args()
    if args.char_id == 2:
        p.error("protected character")
    db = await Database.connect(os.environ["TEST_DATABASE_URL"])
    try:
        identity = await db.pool.fetchrow("SELECT current_database() AS name,rolsuper FROM pg_roles WHERE rolname=current_user")
        assert identity["name"] == "monster2_test_db" and not identity["rolsuper"]
        owner = await db.pool.fetchval("SELECT account_id FROM characters WHERE char_id=$1", args.char_id)
        assert owner is not None and owner != 6, "protected/missing account"
        async with db.pool.acquire() as conn, conn.transaction():
            for row in await conn.fetch("SELECT * FROM pets WHERE char_id=$1 FOR UPDATE", args.char_id):
                if json_value(row["skills_json"]) != []:
                    continue
                skills, passive = starting_skills(row["pet_template_id"])
                print(json.dumps(dict(pet_uid=row["pet_uid"], template=row["pet_template_id"], skills=skills,
                                      passive=passive, applied=args.apply)))
                if args.apply:
                    await conn.execute("UPDATE pets SET skills_json=$2::jsonb,passive_skills_json=$3::jsonb WHERE pet_uid=$1",
                                       row["pet_uid"], json.dumps(skills), json.dumps(passive))
    finally:
        await db.close()


if __name__ == "__main__":
    asyncio.run(main())
