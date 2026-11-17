#!/usr/bin/env python3
"""Create encrypted Lua overrides directing this extracted client to local services."""
from __future__ import annotations

import argparse
from pathlib import Path

from decode_lua import encrypt


PATCHES = {
    Path("assets/src/GameMgr/Update/UpdateMgr.lua"): (
        'local versionFile  = "version.xml"',
        'server = "http://192.168.240.1:8080/patch/"\nlocal versionFile  = "version.xml"',
    ),
    Path("assets/src/Net/ServerIPMrg.lua"): (
        'return  serverListAddress, worldListAddress , gameServerAddress ,errorReportAddress ,queryPlatformCharacterAddress,queryDeviceCharacterAddress ,isWhiteUserAddress,IS_SERVERLIST_PUBLISH',
        'serverListAddress = "http://192.168.240.1:8080/mxmevoListWorld?channel=android"\n'
        'worldListAddress = serverListAddress\n'
        'gameServerAddress = {{"192.168.240.1",5568}}\n'
        'queryPlatformCharacterAddress = "http://192.168.240.1:8080/mxmevoListUserCharacters"\n'
        'queryDeviceCharacterAddress = "http://192.168.240.1:8080/mxmevoGetCharBriefByDevice"\n'
        'errorReportAddress = "http://192.168.240.1:8080/debug.clientlog"\n'
        'isWhiteUserAddress = "http://192.168.240.1:8080/isWhiteUser?"\n'
        'IS_SERVERLIST_PUBLISH = 1\n'
        'return  serverListAddress, worldListAddress , gameServerAddress ,errorReportAddress ,queryPlatformCharacterAddress,queryDeviceCharacterAddress ,isWhiteUserAddress,IS_SERVERLIST_PUBLISH',
    ),
    Path("assets/src/GameMgr/Common/GameNoticeMgr.lua"): (
        'local urlStr = server.."gamenotice.txt"',
        'local urlStr = "http://192.168.240.1:8080/gamenotice.txt"',
    ),
}


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--source", type=Path, default=Path("decoded_lua/assets/src"))
    parser.add_argument("--output", type=Path, default=Path("dist/client_patch/assets/src"))
    parser.add_argument("--key", default="kyopkm")
    parser.add_argument("--sign", default="XXTEA")
    args = parser.parse_args()
    for rel, (old, new) in PATCHES.items():
        source = args.source / rel.relative_to("assets/src")
        text = source.read_text(encoding="utf-8")
        if text.count(old) != 1:
            raise SystemExit(f"expected one patch anchor in {rel}; found {text.count(old)}")
        patched = text.replace(old, new, 1).encode("utf-8")
        target = args.output / rel.relative_to("assets/src")
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_bytes(args.sign.encode() + encrypt(patched, args.key.encode()))
        print(f"wrote {target}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
