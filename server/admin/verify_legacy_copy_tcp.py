"""Read-only TCP smoke check for a migrated legacy-copy manifest."""
from __future__ import annotations

import argparse
import asyncio
import json
import os
import struct
from pathlib import Path
import sys

import asyncpg
sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from protocol import xor_payload


def packet(message_id: int, body: bytes = b"") -> bytes:
    return struct.pack("<HH", len(body) + 4, message_id) + xor_payload(body)


async def receive(reader):
    length = struct.unpack("<H", await reader.readexactly(2))[0]
    frame = await reader.readexactly(length - 2)
    return struct.unpack_from("<H", frame)[0], frame[2:]


async def run(args):
    manifest = json.loads(Path(args.manifest).read_text())
    dsn = os.environ.get(args.dsn_env)
    if not dsn:
        raise ValueError(f"{args.dsn_env} is unset")
    db = await asyncpg.connect(dsn)
    try:
        identity = await db.fetchrow(
            "SELECT current_database() AS database,current_user AS role,"
            "(SELECT rolsuper FROM pg_roles WHERE rolname=current_user) AS superuser")
        if identity["database"] != "monster2_test_db" or identity["superuser"]:
            raise ValueError("verification requires non-superuser monster2_test_db")
        if manifest.get("database") != identity["database"]:
            raise ValueError("manifest and database target do not match")
        char = await db.fetchrow(
            "SELECT c.char_id,c.account_id,a.token FROM characters c "
            "JOIN accounts a ON a.user_id=c.account_id WHERE c.char_id=$1",
            manifest["char_id"])
        if char is None or char["account_id"] != manifest["account_id"]:
            raise ValueError("explicit fixture account/character pair not found")
        pet = await db.fetchrow(
            "SELECT pet_uid,pet_template_id,slot_index,training_stage,skills_json "
            "FROM pets WHERE char_id=$1 ORDER BY slot_index,pet_uid LIMIT 1",
            manifest["char_id"])
        if pet is None:
            raise ValueError("fixture Pet is absent")
        skills = json.loads(pet["skills_json"]) if isinstance(pet["skills_json"], str) else pet["skills_json"]
        expected_uid = next(iter(manifest["mappings"]["pet_uid"].values()))
        if pet["pet_uid"] != expected_uid or pet["pet_template_id"] != 1:
            raise ValueError("fixture Pet identity/template mismatch")
        if len(skills) != 4 or pet["training_stage"] != 0:
            raise ValueError("migrated skill slots or Stage mismatch")
        row = await db.fetchrow(
            "SELECT quest_id,status,progress FROM quests WHERE char_id=$1 AND quest_id=1",
            manifest["char_id"])
        if row is None:
            raise ValueError("copied quest state missing")
        await db.close()

        reader, writer = await asyncio.open_connection(args.host, args.port)
        writer.write(packet(1684, struct.pack("<i", manifest["char_id"])
                            + char["token"].encode() + b"\0"))
        await writer.drain()
        message_id, body = await receive(reader)
        if message_id != 773:
            raise ValueError(f"expected relogin ACK 773, received {message_id}")
        r = _Reader(body)
        code = r.i32(); r.string(); r.i32()
        if code != 0:
            raise ValueError(f"relogin rejected with code {code}")
        logged_char = r.i32()
        if logged_char != manifest["char_id"]:
            raise ValueError("relogin ACK returned a different character")
        request = struct.pack("<QII", manifest["char_id"], 0, 10)
        writer.write(packet(3140, request)); await writer.drain()
        message_id, body = await receive(reader)
        if message_id != 3139:
            raise ValueError(f"expected QueryPets ACK 3139, received {message_id}")
        r = _Reader(body)
        if r.u16() != 0 or r.u64() != manifest["char_id"]:
            raise ValueError("QueryPets rejected or returned wrong character")
        r.u32(); r.u32()
        pets = [json.loads(r.string()) for _ in range(r.u8())]
        if not any(p["objID"] == expected_uid and p["pokeID"] == 1
                   and p["Stage"] == 0 and len(p["skills"]) == 4 for p in pets):
            raise ValueError("QueryPets ACK did not contain migrated Pet")
        writer.close(); await writer.wait_closed()
        print(json.dumps({"database": identity["database"], "role": identity["role"],
                          "account_id": manifest["account_id"], "char_id": manifest["char_id"],
                          "pet_uid": expected_uid, "template_id": 1, "stage": 0,
                          "skill_slots": 4, "quest_id": row["quest_id"],
                          "quest_status": row["status"], "relogin_ack": 773,
                          "query_pets_ack": 3139, "result": "PASS"}, sort_keys=True))
    finally:
        if not db.is_closed():
            await db.close()


class _Reader:
    def __init__(self, data): self.data, self.pos = data, 0
    def take(self, count):
        value = self.data[self.pos:self.pos + count]
        if len(value) != count: raise ValueError("truncated ACK")
        self.pos += count
        return value
    def u8(self): return self.take(1)[0]
    def u16(self): return struct.unpack("<H", self.take(2))[0]
    def u32(self): return struct.unpack("<I", self.take(4))[0]
    def i32(self): return struct.unpack("<i", self.take(4))[0]
    def u64(self): return struct.unpack("<Q", self.take(8))[0]
    def string(self):
        end = self.data.find(b"\0", self.pos)
        if end < 0: raise ValueError("unterminated ACK string")
        value = self.data[self.pos:end].decode(); self.pos = end + 1
        return value


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("manifest")
    parser.add_argument("--dsn-env", default="TEST_DATABASE_URL")
    parser.add_argument("--host", default="127.0.0.1")
    parser.add_argument("--port", type=int, default=5568)
    asyncio.run(run(parser.parse_args()))


if __name__ == "__main__":
    main()
