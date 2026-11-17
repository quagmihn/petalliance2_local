from __future__ import annotations

import asyncio
import io
import json
import logging
import os
import hashlib
import zipfile
from pathlib import Path
from urllib.parse import parse_qs, parse_qsl, urlencode, urlsplit, urlunsplit

ROOT = Path(__file__).resolve().parents[1]
VERSION_FILE = Path(os.getenv("VERSION_FILE", ROOT / "apk_extracted/assets/res/version.xml"))
GAME_HOST = os.getenv("GAME_HOST", "192.168.240.1")
GAME_PORT = int(os.getenv("GAME_PORT", "5568"))
WORLD_ID = int(os.getenv("WORLD_ID", "1"))
WORLD_NAME = os.getenv("WORLD_NAME", "Private World")
WORLD_STATE = int(os.getenv("WORLD_STATE", "1"))


def make_patch_zip() -> bytes:
    buffer = io.BytesIO()
    with zipfile.ZipFile(buffer, mode="w", compression=zipfile.ZIP_STORED) as archive:
        archive.writestr("patch_ok.txt", b"ok")
    return buffer.getvalue()


PATCH_ZIP = make_patch_zip()
logging.basicConfig(level=os.getenv("LOG_LEVEL", "INFO"),
                    format="%(asctime)s %(levelname)s http %(message)s")
log = logging.getLogger("http_gateway")


def response(path: str, method: str = "GET") -> tuple[int, str, bytes]:
    if method == "GET" and path.startswith("/patch/"):
        archive_name = path.removeprefix("/patch/")
        if archive_name.endswith(".zip") and "/" not in archive_name:
            return 200, "application/zip", PATCH_ZIP
    if path in ("/patch/version.xml", "/patch/versiontmp.xml"):
        return 200, "text/plain; charset=utf-8", VERSION_FILE.read_bytes()
    if path in ("/patch/ver_android.xml", "/patch/review_ver.xml"):
        return 200, "text/plain; charset=utf-8", b"0"
    if path in ("/mxmevoListWorld", "/serverlist", "/server/list", "/zone/list",
                "/server_list", "/getServerList"):
        # NetMgr.getServerList() consumes j.worlds[].id/name/state/isNew when
        # IS_SERVERLIST_PUBLISH is non-nil. IP/port are also exposed for a
        # patched client; stock Lua takes these from ServerIPMrg.lua instead.
        body = {"worlds": [{"id": WORLD_ID, "name": WORLD_NAME,
                 "state": WORLD_STATE, "isNew": 1, "ip": GAME_HOST, "port": GAME_PORT}]}
        return 200, "application/json; charset=utf-8", json.dumps(body).encode()
    if path == "/mxm/serverList":
        return 200, "text/plain; charset=utf-8", f"{WORLD_NAME}:{GAME_HOST}:{GAME_PORT}:{WORLD_ID}:0:1\n".encode()
    if path in ("/mxmevoListUserCharacters", "/mxmevoGetCharBriefByDevice"):
        return 200, "application/json; charset=utf-8", b'{"characters":[]}'
    if path == "/isWhiteUser":
        return 200, "application/json; charset=utf-8", b'{"ret":true}'
    if path == "/debug.clientlog":
        return 200, "application/json; charset=utf-8", b'{"ret":0,"code":0}'
    if path == "/saveUserShareData":
        return 200, "application/json; charset=utf-8", b'{"_id":"local"}'
    if path == "/loadUserShareData":
        return 200, "application/json; charset=utf-8", b'{"data":"{}","_id":"local"}'
    if path.endswith("/gamenotice.txt") or path == "/gamenotice.txt":
        return 200, "text/plain; charset=utf-8", b""
    if path in ("/notice", "/game/notice", "/notice/list", "/getNotice"):
        return 200, "application/json; charset=utf-8", b'{"code":0,"notices":[]}'
    if method in ("GET", "POST"):
        # Private/offline builds do not have external analytics, billing,
        # voice, or diagnostic services. A successful empty JSON response
        # keeps optional client requests local and non-blocking.
        return 200, "application/json; charset=utf-8", b'{"ret":0,"code":0}'
    return 404, "text/plain; charset=utf-8", b"not found"


def _safe_target(target: str) -> str:
    parts = urlsplit(target)
    safe_pairs = []
    for key, value in parse_qsl(parts.query, keep_blank_values=True):
        if key.lower() in {"token", "password", "username", "user", "device", "device_id",
                           "deviceid", "device_token", "devicetoken", "mac", "udid"}:
            value = "<redacted>"
        safe_pairs.append((key, value))
    return urlunsplit((parts.scheme, parts.netloc, parts.path, urlencode(safe_pairs), parts.fragment))


def _safe_body(body: bytes) -> str:
    if not body:
        return ""
    try:
        parsed = json.loads(body.decode("utf-8"))
    except (UnicodeDecodeError, json.JSONDecodeError):
        try:
            pairs = parse_qsl(body.decode("utf-8"), keep_blank_values=True)
        except UnicodeDecodeError:
            return f"<binary length={len(body)} sha256={hashlib.sha256(body).hexdigest()[:12]}>"
        return repr([(key, "<redacted>" if key.lower() in {"token", "password", "username", "user",
                     "device", "device_id", "deviceid", "device_token", "devicetoken"} else value)
                     for key, value in pairs])
    if isinstance(parsed, dict):
        for key in list(parsed):
            if str(key).lower() in {"token", "password", "username", "user", "device", "device_id",
                                    "deviceid", "device_token", "devicetoken", "receipt", "signature"}:
                parsed[key] = "<redacted>"
        return json.dumps(parsed, separators=(",", ":"))[:2048]
    return f"<json type={type(parsed).__name__} length={len(body)}>"


async def _character_list(db, path: str, raw_target: str) -> bytes:
    query = parse_qs(urlsplit(raw_target).query)
    characters = []
    if db is not None and path == "/mxmevoListUserCharacters":
        username = query.get("username", [""])[-1]
        token = query.get("token", [""])[-1]
        account = await db.pool.fetchrow(
            "SELECT user_id FROM accounts WHERE username=$1 AND token=$2", username, token
        )
        if account is not None:
            characters = await db.pool.fetch(
                "SELECT world_id,name,level,avatar FROM characters WHERE account_id=$1 ORDER BY world_id",
                account["user_id"],
            )
    elif db is not None and path == "/mxmevoGetCharBriefByDevice":
        device = query.get("device", [""])[-1]
        world_id = int(query.get("world", ["1"])[-1] or "1")
        token = query.get("token", [""])[-1]
        binding = await db.pool.fetchrow(
            """SELECT account_id FROM device_bindings
               WHERE device_id=$1 AND world_id=$2 AND device_token=$3""",
            device, world_id, token,
        )
        if binding is not None:
            characters = await db.pool.fetch(
                "SELECT world_id,name,level,avatar FROM characters WHERE account_id=$1 AND world_id=$2",
                binding["account_id"], world_id,
            )
    encoded = [json.dumps({"world": row["world_id"], "Level": row["level"],
                           "nickname": row["name"], "fashion": {"curFashion": row["avatar"]}},
                          separators=(",", ":")) for row in characters]
    return json.dumps({"characters": encoded}, separators=(",", ":")).encode()


def _payment_path(path: str) -> bool:
    return any(term in path.lower() for term in
               ("recharge", "pay", "iap", "order", "monthcard", "firstcharge", "vip"))


async def handle(reader: asyncio.StreamReader, writer: asyncio.StreamWriter, db=None) -> None:
    peer = writer.get_extra_info("peername")
    try:
        line = await asyncio.wait_for(reader.readline(), timeout=10)
        if not line:
            return
        method, raw_target, _ = line.decode("latin-1").strip().split(" ", 2)
        headers: dict[str, str] = {}
        while True:
            h = await asyncio.wait_for(reader.readline(), timeout=10)
            if h in (b"\r\n", b"\n", b""):
                break
            key, _, value = h.decode("latin-1").partition(":")
            headers[key.lower()] = value.strip()
        size = min(int(headers.get("content-length", "0")), 1024 * 1024)
        body = await reader.readexactly(size) if size else b""
        path = urlsplit(raw_target).path
        if method == "GET" and path in ("/mxmevoListUserCharacters", "/mxmevoGetCharBriefByDevice"):
            status, content_type, payload = 200, "application/json; charset=utf-8", await _character_list(db, path, raw_target)
        elif method in ("GET", "POST") and _payment_path(path):
            if os.getenv("LOCAL_PAYMENT_SANDBOX", "0") != "1":
                status, content_type, payload = 403, "application/json; charset=utf-8", b'{"ret":false,"code":"sandbox_disabled"}'
            else:
                # No verified route schema, product catalog mapping, or client
                # idempotency key is available for the legacy billing API yet.
                status, content_type, payload = 501, "application/json; charset=utf-8", b'{"ret":false,"code":"sandbox_adapter_unconfigured"}'
        else:
            status, content_type, payload = response(path, method)
        reason = {200: "OK", 403: "Forbidden", 404: "Not Found",
                  501: "Not Implemented"}.get(status, "Error")
        log.info("request peer=%s method=%s path=%s body=%s", peer, method,
                 _safe_target(raw_target), _safe_body(body))
        writer.write((f"HTTP/1.1 {status} {reason}\r\nContent-Type: {content_type}\r\n"
                      f"Content-Length: {len(payload)}\r\nConnection: close\r\n\r\n").encode() + payload)
        await writer.drain()
        log.info("response peer=%s status=%s content_type=%s content_length=%d body=%r", peer, status,
                 content_type, len(payload), _safe_body(payload))
    except (asyncio.TimeoutError, UnicodeDecodeError, ValueError, asyncio.IncompleteReadError) as exc:
        log.warning("bad request peer=%s error=%s", peer, exc)
    finally:
        writer.close()
        await writer.wait_closed()


async def main() -> None:
    host = os.getenv("HTTP_BIND", "0.0.0.0")
    port = int(os.getenv("HTTP_PORT", "8080"))
    from db.database import Database
    db = await Database.connect()
    await db.initialize()
    server = await asyncio.start_server(lambda r, w: handle(r, w, db), host, port)
    log.info("listening on %s:%d; game endpoint %s:%d", host, port, GAME_HOST, GAME_PORT)
    try:
        async with server:
            await server.serve_forever()
    finally:
        await db.close()


if __name__ == "__main__":
    asyncio.run(main())
