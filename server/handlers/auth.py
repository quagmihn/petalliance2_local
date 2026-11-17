from __future__ import annotations

import os
import secrets
import time

from protocol import Reader, Writer, success_code


async def platform_login(session, payload: bytes):
    r = Reader(payload)
    username, token = r.string(), r.string()
    r.finish()
    if not username or not token: raise ValueError("empty platform credentials")
    account = await session.db.upsert_account(username, token)
    session.account_id, session.username = account["user_id"], username
    session.user_token = account["token"]
    bindings = await session.db.pool.fetch(
        "SELECT * FROM device_bindings WHERE account_id=$1 ORDER BY world_id", account["user_id"]
    )
    # A private client can carry stale device credentials from a previous
    # install/Waydroid instance. Ask it to bind its current device on every
    # platform login by default; the resulting DEVICELOGIN uses fresh IDs.
    if os.getenv("PLATFORM_LOGIN_REBIND", "1").strip().lower() not in {"0", "false", "no", "off"}:
        bindings = []
    w = success_code().u8(len(bindings))
    for row in bindings:
        w.string(row["device_id"]).string(str(row["world_id"])).string(row["device_token"])
    return 2126, w.bytes()


async def client_info(session, payload: bytes):
    """CG_CLIENTINFO_REQ is a required gate step; ACK is a WORD result."""
    r = Reader(payload)
    names = ("ip", "device_model", "os_name", "os_ver", "mac_addr", "udid",
             "app_channel", "app_ver", "network", "device_screen", "platform_tag")
    # Keep these values in the session for structured diagnostics, but do not
    # log device identifiers or other client metadata.
    session.client_info = {name: r.string() for name in names}
    r.u32()
    r.u32()
    if r.pos != len(payload):
        raise ValueError(f"CG_CLIENTINFO_REQ has {len(payload) - r.pos} trailing bytes")
    return 132, Writer().u16(0).bytes()


async def device_relogin(session, payload: bytes):
    """Restore a character session using the role ID and user token."""
    r = Reader(payload)
    char_id, user_token = r.i32(), r.string()
    r.finish()
    if char_id == 0:
        account = await session.db.pool.fetchrow(
            "SELECT user_id, username, token FROM accounts WHERE token=$1", user_token,
        )
        if account is not None:
            session.account_id = account["user_id"]
            session.username = account["username"]
            session.user_token = account["token"]
            session.world_id = 1
            session.char_id = None
            return 773, success_code().i32(0).bytes()

    row = await session.db.pool.fetchrow(
        """SELECT c.*, a.user_id, a.username, a.token
           FROM characters c JOIN accounts a ON a.user_id=c.account_id
           WHERE c.char_id=$1""", char_id,
    )
    if row is None or not secrets.compare_digest(row["token"], user_token):
        # Proto.parseCode is int32 + NUL string + int32. A failed relogin
        # still receives a complete ACK so the client can release its waiter.
        return 773, Writer().i32(1).string("session not found").i32(0).bytes()

    session.account_id = row["user_id"]
    session.username = row["username"]
    session.world_id = row["world_id"]
    session.char_id = row["char_id"]
    session.user_token = row["token"]
    from handlers.player import write_char_base
    body = (success_code().i32(row["char_id"])
            .raw(write_char_base(row, row["username"])).bytes())
    return 773, body


async def device_bind(session, payload: bytes):
    r = Reader(payload)
    device_id, world_s, token = r.string(), r.string(), r.string()
    r.finish()
    world_id = int(world_s or "1")
    if session.account_id is None:
        return 2179, Writer().i32(427).string("platform login required").i32(0).bytes()
    if not device_id or not token:
        return 2179, Writer().i32(4).string("invalid device credentials").i32(0).bytes()
    try:
        await session.db.bind_device(device_id, world_id, token, session.account_id)
    except ValueError:
        return 2179, Writer().i32(4).string("device token already bound").i32(0).bytes()
    session.world_id = world_id
    return 2179, success_code().bytes()


async def device_login(session, payload: bytes):
    r = Reader(payload)
    device_id, world_s, device_token = r.string(), r.string(), r.string()
    r.finish()
    world_id = int(world_s or "1")
    if not device_id or not device_token:
        return 2183, Writer().i32(4).string("invalid device credentials").i32(0).bytes()
    binding = await session.db.pool.fetchrow(
        "SELECT * FROM device_bindings WHERE device_id=$1 AND world_id=$2", device_id, world_id
    )
    if binding is None or not secrets.compare_digest(binding["device_token"], device_token):
        return 2183, Writer().i32(4).string("device binding not found").i32(0).bytes()
    if session.account_id is not None and binding["account_id"] != session.account_id:
        return 2183, Writer().i32(4).string("device binding account mismatch").i32(0).bytes()
    account = await session.db.pool.fetchrow("SELECT * FROM accounts WHERE user_id=$1", binding["account_id"])
    if account is None:
        raise LookupError(f"device binding {device_id!r}/{world_id} references missing account")
    session.account_id, session.username, session.world_id = account["user_id"], account["username"], world_id
    session.user_token = account["token"]
    char = await session.db.character(session.account_id, world_id)
    session.char_id = char["char_id"] if char else None
    w = success_code().u32(session.char_id or 0).u64(int(time.time())).i32(25200).string(session.user_token)
    if char:
        from handlers.player import write_char_base
        w.raw(write_char_base(char, account["username"]))
    return 2183, w.bytes()
