from __future__ import annotations

import json
import re
import struct
import time

from protocol import Reader, Writer, success_code


def write_char_base(row, username: str) -> bytes:
    # Field order and optional-field flags mirror parseCharBaseInfo in
    # Proto_Login_Types.lua. Keep the optional sections disabled.
    now = int(time.time())
    w = Writer().string(username).string(row["name"])
    w.u8(row["gender"]).u8(1)  # gender, country
    w.u32(row["gold"]).u32(row["diamond"]).u32(0).u8(row["vip_level"])
    w.u32(0).u32(0).u32(0)  # client flags and achievement totals
    w.u8(1).u16(row["map_id"]).u32(0).u8(0)  # login country, town, team, garden
    w.u8(0).u32(0).u8(0)  # confraternity, char flags, forced location
    w.u8(0).u8(0)  # active garden, marriage
    w.u16(row["level"]).u32(row["exp"]).u16(row["stamina"]).u16(row["stamina"])
    w.u32(now).u32(0).u32(0).string("")
    return w.bytes()


async def appoint_nickname(session, payload: bytes):
    """Validate the pre-creation nickname and release the client's waiter."""
    r = Reader(payload)
    nickname = r.string(limit=96).strip()
    valid = bool(nickname) and len(nickname.encode("utf-8")) <= 48
    if valid:
        existing = await session.db.pool.fetchval(
            "SELECT 1 FROM characters WHERE world_id=$1 AND lower(name)=lower($2) LIMIT 1",
            session.world_id, nickname,
        )
        valid = existing is None
    if valid:
        session.pending_nickname = nickname
    # MC_AppointNickName_Ack uses a WORD code, unlike most login ACKs that
    # carry Proto.parseCode (int32, string, int32).
    return 1104, Writer().u16(0 if valid else 1).bytes()


async def create_character(session, payload: bytes):
    r = Reader(payload)
    name = r.string()
    gender, country, pet_template_id, avatar = r.u8(), r.u8(), r.u8(), r.u8()
    world_id = r.i32()
    _spreader = r.string()
    fashions = [r.u32() for _ in range(r.u8())]
    if session.account_id is None: raise ValueError("character create before device login")
    session.world_id = world_id or session.world_id or 1
    char, pet_row = await session.db.create_character_with_pet(
        session.account_id, session.world_id, name, avatar, gender, pet_template_id
    )
    session.char_id = char["char_id"]
    account = await session.db.pool.fetchrow("SELECT username FROM accounts WHERE user_id=$1", session.account_id)
    w = success_code().u32(char["char_id"]).raw(write_char_base(char, account["username"]))
    return 807, w.bytes()


async def get_character_values(session, payload: bytes):
    r = Reader(payload)
    keys = [r.string() for _ in range(r.u8())]
    r.finish()
    if session.char_id is None:
        raise ValueError("character values requested before character selection")
    values = await session.db.character_values(session.char_id, keys)
    return 747, Writer().u16(0).string(json.dumps(values, separators=(",", ":"))).bytes()


async def change_character_info(session, payload: bytes):
    r = Reader(payload)
    char_id, key, content = r.u32(), r.string(limit=96), r.string(limit=4096)
    r.finish()
    normalized = key.lower()
    if normalized == "maplock":
        normalized = "map_lock"
    if (session.char_id is None or char_id != session.char_id
            or not re.fullmatch(r"[a-z0-9_]{1,64}", normalized)):
        return 630, Writer().u16(1).bytes()
    await session.db.set_character_value(session.char_id, normalized, content)
    return 630, Writer().u16(0).bytes()


async def get_server_time(session, payload: bytes):
    return 1216, Writer().u16(0).u64(int(time.time())).raw(struct.pack("<f", 25200.0)).bytes()
